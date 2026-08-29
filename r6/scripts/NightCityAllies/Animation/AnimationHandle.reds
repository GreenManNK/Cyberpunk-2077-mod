module NightCityAllies.Animation

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.* // For IEntityResolver

public class AnimationHandle extends IEntityResolver {
    private let m_animName: CName;
    private let m_workspotPath: String;
    private let m_actorDataCompName: CName;
    private let m_deviceDataCompName: CName;
    private let m_syncSlotName: CName;
    private let m_freeCamera: Bool;

    private let m_entity: wref<ScriptedPuppet>;
    private let m_workspotEntityID: EntityID;

    private let m_hasSource: Bool;
    private let m_isPlaying: Bool;

    private let m_workspotEntity: wref<GameObject>;
    private let m_cancelled: Bool;
    
    private static func GetBindCheckDelay() -> Float = 1.0; // How long to let a bind settle before reporting it as failed

    public static func Create(entity: wref<ScriptedPuppet>, animName: CName, opt workspotPath: String, opt actorDataCompName: CName, opt deviceDataCompName: CName, opt syncSlotName: CName) -> ref<AnimationHandle> {
        let handle = new AnimationHandle();
        handle.m_entity = entity;
        handle.m_animName = animName;

        handle.m_workspotPath = workspotPath;
        handle.m_actorDataCompName = actorDataCompName;
        handle.m_deviceDataCompName = deviceDataCompName;
        handle.m_syncSlotName = syncSlotName;
        return handle;
    }

    public static func Create(npc: ref<NpcHandle>, animName: String, binding: NCAWorkspotBinding) -> ref<AnimationHandle> {
        return AnimationHandle.CreateFor(npc.GetEntity() as ScriptedPuppet, animName, binding);
    }

    public static func CreateForPartner(partner: wref<ScriptedPuppet>, animName: String, binding: NCAWorkspotBinding, opt freeCamera: Bool) -> ref<AnimationHandle> {
        let handle = AnimationHandle.CreateFor(partner, animName, binding);
        handle.m_freeCamera = freeCamera;
        return handle;
    }

    private static func CreateFor(entity: wref<ScriptedPuppet>, animName: String, binding: NCAWorkspotBinding) -> ref<AnimationHandle> {
        let handle: ref<AnimationHandle>;

        let useDefaults: Bool = !IsStringValid(binding.workspot);
        let workspot: String = useDefaults ? NCAWorkspotDefaults.Workspot() : binding.workspot;
        let actorComp: CName = (useDefaults && !IsStringValid(binding.actorComp))
            ? NCAWorkspotDefaults.ActorComp()
            : StringToName(binding.actorComp);
        let deviceComp: CName = (useDefaults && !IsStringValid(binding.deviceComp))
            ? NCAWorkspotDefaults.DeviceComp()
            : StringToName(binding.deviceComp);

        if Equals(binding.syncSlot, "") {
            handle = AnimationHandle.Create(
                entity,
                StringToName(animName),
                workspot,
                actorComp,
                deviceComp
            );
        } else {
            handle = AnimationHandle.Create(
                entity,
                StringToName(animName),
                workspot,
                actorComp,
                deviceComp,
                StringToName(binding.syncSlot)
            );
        }

        handle.m_hasSource = true;
        return handle;
    }

    public func CanJumpTo(animation: NCAAnimation) -> Bool {
        return this.m_isPlaying
            && this.m_hasSource
            && IsStringValid(animation.animation);          // an unnamed clip has no entry to jump to
    }

    public func JumpTo(animName: String) -> Void {
        if !IsDefined(this.m_entity) {
            return;
        }

        let from: String = NameToString(this.m_animName);
        this.m_animName = StringToName(animName);
        GameInstance.GetWorkspotSystem(this.m_entity.GetGame())
            .SendJumpToAnimEnt(this.m_entity, this.m_animName, false);

        //NCA.CETLog("[jump] t=" + FloatToString(EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()))) + " '" + from + "' -> '" + animName + "'");
    }

    public func Play() -> Void {
        this.PlayAt(this.m_entity.GetWorldPosition(), this.m_entity.GetWorldOrientation());
    }

    public func PlayAt(position: Vector4, orientation: Quaternion) -> Void {
        let system = GameInstance.GetDynamicEntitySystem();
        let spec = new DynamicEntitySpec();
        
        // Create spec to spawn workspot
        let path: String = this.m_workspotPath;
        spec.templatePath = ResRef.FromString(path); 
        spec.position = position;
        spec.orientation = orientation;
        
        this.m_workspotEntityID = system.CreateEntity(spec);

        EntityResolver.ResolveEntityID(this, this.m_workspotEntityID);

        //NCA.CETLog("Spawning workspot for animation " + NameToString(this.m_animName));
    }

    public func Resolve(handle: ref<Entity>) -> Void {
        let animEntity: wref<GameObject> = handle as GameObject;
        if IsDefined(animEntity) {
            if Equals(animEntity.GetEntityID(), this.m_workspotEntityID) {
                // Never hand PlayInDeviceSimple a component the entity does not have. A wrong or
                // missing actor component name is not a quiet no-op on the native side - it takes
                // the game down, with nothing in the log to say why.
                if !IsDefined(animEntity.FindComponentByName(this.m_actorDataCompName)) {
                    NCA.CETLog("ERROR workspot entity '" + this.m_workspotPath
                        + "' has no component named '" + NameToString(this.m_actorDataCompName)
                        + "' - not playing, this would crash the game");
                    return;
                }

                this.m_workspotEntity = animEntity;
                this.TryBind();

                //NCA.CETLog("[jump] t=" + FloatToString(EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()))) + " SPAWN '" + NameToString(this.m_animName) + "'" + (named ? "" : " (unnamed)"));
                //NCA.CETLog("Playing animation " + NameToString(this.m_animName) + " in workspot " + this.m_workspotPath + " with actorDataComp " + NameToString(this.m_actorDataCompName) + ", deviceDataComp " + NameToString(this.m_deviceDataCompName) + " and syncSlot " + NameToString(this.m_syncSlotName));
            }   
        }
    }

    public func TryBind() -> Void {
        if this.m_cancelled || !IsDefined(this.m_entity) || !IsDefined(this.m_workspotEntity) {
            return;
        }

        let workspotSystem = GameInstance.GetWorkspotSystem(this.m_entity.GetGame());
        let named: Bool = !Equals(this.m_animName, n"");

        let sliding: WorkspotSlidingBehaviour = named
            ? WorkspotSlidingBehaviour.SlideActorAndRotateDevice
            : WorkspotSlidingBehaviour.PlayAtResourcePosition;

        workspotSystem.PlayInDeviceSimple(
            this.m_workspotEntity,
            this.m_entity,
            this.m_freeCamera,
            this.m_actorDataCompName,
            this.m_deviceDataCompName,
            this.m_syncSlotName,
            0.0,
            sliding
        );

        if named {
            workspotSystem.SendJumpToAnimEnt(this.m_entity, this.m_animName, false);
        }

        this.m_isPlaying = true;

        GameInstance.GetDelaySystem(this.m_entity.GetGame()).DelayCallback(
            NCABindCheckDelayCallback.Create(this),
            AnimationHandle.GetBindCheckDelay(),
            false
        );
    }

    public func VerifyBound() -> Void {
        if this.m_cancelled || !IsDefined(this.m_entity) {
            return;
        }

        if GameInstance.GetWorkspotSystem(this.m_entity.GetGame()).IsActorInWorkspot(this.m_entity) {
            return;
        }

        NCA.CETLog("ERROR actor never entered the workspot in '" + this.m_workspotPath
            + "' via component '" + NameToString(this.m_actorDataCompName)
            + "' - the entity spawned and the component is there, so the likeliest cause is "
            + "that the component's workspot resource is missing or points at a file that "
            + "does not exist");
    }

    public func Cancel() -> Void {
        this.m_cancelled = true;
        this.m_isPlaying = false;

        if IsDefined(this.m_entity) {
            GameInstance.GetWorkspotSystem(this.m_entity.GetGame()).StopInDevice(this.m_entity);
        }

        GameInstance.GetDynamicEntitySystem().DeleteEntity(this.m_workspotEntityID);
    }
}

// Reports a bind that never took. See AnimationHandle.VerifyBound.
public class NCABindCheckDelayCallback extends DelayCallback {
    let m_handle: ref<AnimationHandle>;

    public static func Create(handle: ref<AnimationHandle>) -> ref<NCABindCheckDelayCallback> {
        let created: ref<NCABindCheckDelayCallback> = new NCABindCheckDelayCallback();
        created.m_handle = handle;
        return created;
    }

    public func Call() -> Void {
        if IsDefined(this.m_handle) {
            this.m_handle.VerifyBound();
        }
    }
}