module Utils2077.SpatialUtils

public func isPointInPolygon(point: Vector2, polygon: array<Vector2>) -> Bool {
    let isIn: Bool = false;
    let maxY: Float;
    let maxX: Float;
    let minY: Float;
    let minX: Float;

    for p in polygon {
        minX = MinF(p.X, minX);
        maxX = MaxF(p.X, maxX);
        minY = MinF(p.Y, minY);
        maxY = MaxF(p.Y, maxY);
    };
    let isOutsideBoundingBox = (point.X < minX || point.X > maxX || point.Y < minY || point.Y > maxY);
    if isOutsideBoundingBox {
        return false;
    };

    let i: Int32 = 0;
    let j: Int32 = ArraySize(polygon) - 1;
    let isInside: Bool = false;
    while i < ArraySize(polygon) {
        let hasCrossedToOtherSideOfPolygon = (Equals(polygon[i].Y > point.Y, polygon[j].Y > point.Y) && point.X < (polygon[j].X - polygon[i].X) * (point.Y - polygon[i].Y) / (polygon[j].Y - polygon[i].Y) + polygon[i].X);
        if hasCrossedToOtherSideOfPolygon {
            if Equals(isInside, true) {
                isInside = false;
            } else {
                isInside = true;
            };

        };
        i += 1;
        j = i + 1;
    };

    return isInside;
};

public func GetEntitiesInPrism(ents: script_ref<array<ref<Entity>>>,
                               boundaries: array<Vector2>,
                               bottomZ: Float,
                               topZ: Float,
                               opt limit: Int32,
                               opt EntityFilters: array<CName>) -> array<wref<Entity>> {
    let gi: GameInstance = GetGameInstance();
    let out_ents: array<wref<Entity>>;
    let total_ents = ArraySize(Deref(ents));
    let ent_pos: Vector4;

    if ArraySize(EntityFilters) == 0 {
        ArrayPush(EntityFilters, n"entEntity");
    };

    let i: Int32;
    let ent: wref<Entity>;
    let ent_pos: Vector4;
    while i < total_ents && i < limit {
        let ent: wref<Entity> = ents[i];
        if IsDefined(ent) {
            ent_pos = ent.GetWorldPosition();
            if isPointInPolygon(Vector4.Vector4To2(ent_pos), boundaries)
            && ent_pos.Z > bottomZ
            && ent_pos.Z < topZ {
                for filter in EntityFilters {
                    if ent.IsA(filter) {
                        ArrayPush(out_ents, ent);
                        break;
                    };
                };
            };
        };
        i = i + 1;
    };
    return out_ents;
};

public func getCameraFrustumPoints(cam_transform: Transform,
                                   fov: Float,
                                   aspect_ratio: Float,
                                   far_distance: Float) -> array<Vector4> {

    let points: array<Vector4>;
    let cam_pos = cam_transform.GetPosition();
    let cam_fwd = cam_transform.GetForward();
    let cam_up = cam_transform.GetUp();
    let cam_right = cam_transform.GetRight();
    let near_distance = 0.400000006;

    let near_height = 2.00 * TanF(fov / 2.00) * near_distance;
    let near_width = near_height * aspect_ratio;
    let near_center = cam_pos + cam_fwd * near_distance;
    let far_height = 2.00 * TanF(fov / 2.00) * far_distance;
    let far_width = far_height * aspect_ratio;
    let far_center = cam_pos + cam_fwd * far_distance;

    let near_upperl = near_center + (cam_up * (near_height / 2.00)) - (cam_right * (near_width / 2.00));
    let near_upperr = near_center + (cam_up * (near_height / 2.00)) + (cam_right * (near_width / 2.00));
    let near_lowerl = near_center - (cam_up * (near_height / 2.00)) - (cam_right * (near_width / 2.00));
    let near_lowerr = near_center - (cam_up * (near_height / 2.00)) + (cam_right * (near_width / 2.00));
    let far_upperl = far_center + (cam_up * (far_height / 2.00)) - (cam_right * (far_width / 2.00));
    let far_upperr = far_center + (cam_up * (far_height / 2.00)) + (cam_right * (far_width / 2.00));
    let far_lowerl = far_center - (cam_up * (far_height / 2.00)) - (cam_right * (far_width / 2.00));
    let far_lowerr = far_center - (cam_up * (far_height / 2.00)) + (cam_right * (far_width / 2.00));

    ArrayPush(points, near_upperl);
    ArrayPush(points, near_upperr);
    ArrayPush(points, near_lowerl);
    ArrayPush(points, near_lowerr);

    ArrayPush(points, far_upperl);
    ArrayPush(points, far_upperr);
    ArrayPush(points, far_lowerl);
    ArrayPush(points, far_lowerr);

    return points;
};

public func isPointInCameraView(gi: GameInstance,
                                point: Vector4,
                                cam_transform: Transform,
                                cam_fov: Float,
                                cam_aspect_ratio: Float,
                                cam_far_distance: Float,
                                check_sight_block: Bool) -> Bool {

    let spatialQueriesSys = GameInstance.GetSpatialQueriesSystem(gi);
    let camSys = GameInstance.GetCameraSystem(gi);
    let cam_pos = cam_transform.GetPosition();
    let cam_fwd = cam_transform.GetForward();
    let cam_up = cam_transform.GetUp();
    let cam_right = cam_transform.GetRight();
    let up_fwd = Vector4.RotateAxis(cam_fwd,
                                    new Vector4(-1.00, 0.00, 0.00, 1.00),
                                    Deg2Rad(cam_fov / cam_aspect_ratio));
    let down_fwd = Vector4.RotateAxis(cam_fwd,
                                      new Vector4(1.00, 0.00, 0.00, 1.00),
                                      Deg2Rad(cam_fov / cam_aspect_ratio));

    let frustum_points = getCameraFrustumPoints(cam_transform,
                                                cam_fov,
                                                cam_aspect_ratio,
                                                cam_far_distance);
    let near_upperl_point = frustum_points[0];
    let near_upperr_point = frustum_points[1];
    let near_lowerl_point = frustum_points[2];
    let near_lowerr_point = frustum_points[3];
    let far_upperl_point = frustum_points[4];
    let far_upperr_point = frustum_points[5];

    let horizontal_plane_points: array<Vector2> = [Vector4.Vector4To2(near_upperl_point),
                                                   Vector4.Vector4To2(near_upperr_point),
                                                   Vector4.Vector4To2(far_upperl_point),
                                                   Vector4.Vector4To2(far_upperr_point)];

    let p_distance = Vector4.Distance2D(cam_pos, point);
    let frustum_up = near_upperr_point + (up_fwd * p_distance);
    let frustum_down = near_lowerr_point + (down_fwd * p_distance);

    if !isPointInPolygon(Vector4.Vector4To2(point), horizontal_plane_points) {
        return false;
    }

    if point.Z > frustum_up.Z || point.Z < frustum_down.Z {
        return false;
    }

    let tr: TraceResult;
    if check_sight_block {
        let is_sight_blocked = spatialQueriesSys.SyncRaycastByQueryPreset(cam_pos,
                                                                          point,
                                                                          n"Sight Blocker",
                                                                          tr);
        if is_sight_blocked {
            return false;
        };
    };

    return true;
};

public func isPointInAnyLoadedSecurityAreaRadius(point: Vector4,
                                                 zone_types: array<ESecurityAreaType>,
                                                 opt check_height: Bool) -> Bool {
    let gi: GameInstance = GetGameInstance();
    let depot = GameInstance.GetResourceDepot();
    let token = depot.LoadResource(r"base\\worlds\\03_night_city\\_compiled\\default\\03_night_city.areas");
    let zones = token.GetResource() as gameAreaResource;
    for zone in zones.cookedData {
        let zone_ent = GameInstance.FindEntityByID(gi, zone.entityID) as SecurityArea;
        if IsDefined(zone_ent) {
            let zone_type = zone_ent.GetController().GetPS().GetSecurityAreaType();
            if ArrayContains(zone_types, zone_type)
            && isPointInSecurityAreaRadius(point, zone, check_height) {
                return true;
            };
        };
    };
    return false;
};

public func isPointInSecurityAreaRadius(point: Vector4,
                                        zone: gameCookedAreaData,
                                        opt check_height: Bool) -> Bool {
    let zone_pos_v4 = Vector4.Vector3To4(zone.position);
    let dist_to_zone_sq = Vector4.DistanceSquared(point, zone_pos_v4);
    let is_inside_zone_radius = dist_to_zone_sq < zone.radius * zone.radius;

    if !is_inside_zone_radius {
        return false;
    };

    if !check_height {
        return true;
    };

    let zone_height = (zone.volume as gamemappinsOutlineMappinVolume).height;
    let zone_ceiling = zone.position.Z + zone_height;
    let zone_floor = zone.position.Z - zone_height;
    let point_height = point.Z;
    return point_height < zone_ceiling && point_height > zone_floor;
};

public func isPointInAnyLoadedSecurityAreaVolume(point: Vector4,
                                                 zone_types: array<ESecurityAreaType>,
                                                 opt check_height: Bool) -> Bool {
    let gi: GameInstance = GetGameInstance();
    let depot = GameInstance.GetResourceDepot();
    let token = depot.LoadResource(r"base\\worlds\\03_night_city\\_compiled\\default\\03_night_city.areas");
    let zones = token.GetResource() as gameAreaResource;
    for zone in zones.cookedData {
        let zone_ent = GameInstance.FindEntityByID(gi, zone.entityID) as SecurityArea;
        if IsDefined(zone_ent) {
            let zone_type = zone_ent.GetController().GetPS().GetSecurityAreaType();
            //FTLog(s"ZONE CENTER: \(zone.position)");
            //FTLog(s"ZONE TYPE: \(zone_ent.GetController().GetPS().GetSecurityAreaType())");
            if ArrayContains(zone_types, zone_type) 
            && isPointInSecurityAreaVolume(point, zone, check_height) {
                return true;
            };
        };
    };
    return false;
};

public func isPointInSecurityAreaVolume(point: Vector4,
                                        zone: gameCookedAreaData,
                                        opt check_height: Bool) -> Bool {
    let outline_points = (zone.volume as gamemappinsOutlineMappinVolume).outlinePoints;
    let worldspace_outline_points: array<Vector2>;
    for p in outline_points {
        let worldspace_point: Vector2;
        worldspace_point.X = zone.position.X + p.X;
        worldspace_point.Y = zone.position.Y + p.Y;
        ArrayPush(worldspace_outline_points, worldspace_point);
    };
    let is_point_in_zone_outline = isPointInPolygon(Vector4.Vector4To2(point),
                                                    worldspace_outline_points);
    let zone_height = (zone.volume as gamemappinsOutlineMappinVolume).height;
    let zone_ceiling = zone.position.Z + zone_height;
    let zone_floor = zone.position.Z - zone_height;
    let is_point_in_zone_height: Bool;
    if !check_height {
        is_point_in_zone_height = true;
    } else {
        is_point_in_zone_height = (point.Z < zone_ceiling && point.Z > zone_floor);
    };

    return is_point_in_zone_outline && is_point_in_zone_height;
};

public final static func HasSpaceInFrontOfPoint(queryPosition: Vector4,
                                                queryDirection: Vector4,
                                                groundClearance: Float,
                                                areaWidth: Float,
                                                areaLength: Float,
                                                areaHeight: Float) -> Bool {
    let boxDimensions: Vector4;
    let boxOrientation: EulerAngles;
    let fitTestOvelap: TraceResult;
    let overlapSuccessStatic: Bool;
    let overlapSuccessVehicle: Bool;
    let overlapSuccessDynamic: Bool;
    queryDirection.Z = 0.00;
    queryDirection = Vector4.Normalize(queryDirection);
    boxDimensions.X = areaWidth * 0.50;
    boxDimensions.Y = areaLength * 0.50;
    boxDimensions.Z = areaHeight * 0.50;
    queryPosition.Z += boxDimensions.Z + groundClearance;
    queryPosition += boxDimensions.Y * queryDirection;
    boxOrientation = Quaternion.ToEulerAngles(Quaternion.BuildFromDirectionVector(queryDirection));
    overlapSuccessStatic = GameInstance.GetSpatialQueriesSystem(GetGameInstance()).Overlap(boxDimensions, queryPosition, boxOrientation, n"Static", fitTestOvelap);
    overlapSuccessVehicle = GameInstance.GetSpatialQueriesSystem(GetGameInstance()).Overlap(boxDimensions, queryPosition, boxOrientation, n"Vehicle", fitTestOvelap);
    overlapSuccessDynamic = GameInstance.GetSpatialQueriesSystem(GetGameInstance()).Overlap(boxDimensions, queryPosition, boxOrientation, n"Dynamic", fitTestOvelap);
    return !overlapSuccessStatic && !overlapSuccessVehicle && !overlapSuccessDynamic;
};

public func GetDistrictManager() -> ref<DistrictManager> {
    let gi: GameInstance = GetGameInstance();
    let scriptableContainer = GameInstance.GetScriptableSystemsContainer(gi);
    let preventionSys = scriptableContainer.Get(n"PreventionSystem") as PreventionSystem;
    let districtManager = preventionSys.m_districtManager;
    return districtManager;
};

/* Why does the district manager have two stacks? And why is one persistent
   and the other isn't? And why does the current district NOT use the
   persistent stack, causing the current district to be null when loading a
   save until the player leaves and enters a new district? No idea. */
public func GetCurrentDistrict() -> ref<District> {
    let dm: ref<DistrictManager> = GetDistrictManager();
    let d: ref<District>; dm.GetCurrentDistrict().GetDistrictRecord().EnumName();
    let district_name = d.GetDistrictRecord().EnumName();
    if Equals(district_name, "") {
        let visited_district_count = ArraySize(dm.m_visitedDistricts);
        if visited_district_count > 0 {
            let last_district_index = visited_district_count - 1;
            let last_district = dm.m_visitedDistricts[last_district_index];
            let rec = TweakDBInterface.GetDistrictRecord(last_district);
            d = new District();
            d.Initialize(last_district);
        };
    };
    return d;
};

public func IsPlayerNearQuestMappin(min_distance: Float) -> Bool {
    let gi: GameInstance = GetGameInstance();
    let mappinSys = GameInstance.GetMappinSystem(gi);
    let pins: array<ref<IMappin>> = mappinSys.GetAllMappins();
    for p in pins {
        if p.IsActive() && p.IsQuestMappin() {
            if (p as QuestMappin).IsInsideTrigger()
            || p.GetDistanceToPlayer() < min_distance {
                return true;
            };
        };
    };
     return false;
};

func IsEntityNearQuestMappin(ent: wref<Entity>, min_distance: Float) -> Bool {
    if !IsDefined(ent) || !(ent as ScriptedPuppet).IsActive() {
        return false;
    };
    let gi: GameInstance = GetGameInstance();
    let mappinSys = GameInstance.GetMappinSystem(gi);
    let pins: array<ref<IMappin>> = mappinSys.GetAllMappins();
    let min_dist_sq: Float = min_distance * min_distance;
    for p in pins {
        if p.IsActive() && p.IsQuestMappin() {
            // FIXME no way to get if an entity outside player is in trigger
            // area and doesn't seem to be any function for getting the shape
            // so will likely have to load the resource from archive to get
            // the shape to make sure psycho spawn is not inside.
            let pin_pos = p.GetWorldPosition();
            let ent_pos = ent.GetWorldPosition();
            let distance_to_mappin = Vector4.DistanceSquared(pin_pos, ent_pos);
            if distance_to_mappin < min_dist_sq {
                return true;
            };
            // Get Depot
            // shape = Depot:LoadResource
            // if isPointInPolygon(ent.GetWorldPosition(), shape) {
            //  return true;
            //};
        };
    };
     return false;
 };
