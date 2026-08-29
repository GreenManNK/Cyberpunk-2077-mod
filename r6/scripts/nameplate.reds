module E3HUD

//psiberx codeware black magic

@addMethod(inkImage)
public func SetNineSliceScale(enable: Bool) -> Void {
    this.useNineSliceScale = enable;
}

@addField(inkImage)
native let useNineSliceScale: Bool;

//Begin e3 nameplate

// Made by Spicy2332 & DJ_Kovrik & Erok

@addField(NameplateVisualsLogicController)
private let customContainer: ref<inkFlex>;

@addField(NameplateVisualsLogicController)
private let customContainer2: ref<inkFlex>;


@addField(NameplateVisualsLogicController)
private let customLevel: ref<inkText>;

@addField(NameplateVisualsLogicController)
private let customName: ref<inkText>;

@addField(NameplateVisualsLogicController)
private let customNameBorder: ref<inkImage>;

@addField(NameplateVisualsLogicController)
private let customLevelBorder: ref<inkImage>;

@wrapMethod(NameplateVisualsLogicController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();

  let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
  let mainSection: ref<inkFlex> = root.GetWidget(n"name_bar_holder/mainSection") as inkFlex;

  
  let newInfoContainer: ref<inkFlex> = new inkFlex();
  newInfoContainer.SetName(n"CustomInfo");
  newInfoContainer.SetFitToContent(true);
  newInfoContainer.SetHAlign(inkEHorizontalAlign.Left);
  newInfoContainer.SetVAlign(inkEVerticalAlign.Bottom);
  newInfoContainer.SetAnchor(inkEAnchor.BottomLeft);
  newInfoContainer.SetAnchorPoint(new Vector2(0.5, 0.5));
  newInfoContainer.SetMargin(new inkMargin(0.0, 0.0, 0.0, 8.0));
  newInfoContainer.Reparent(mainSection);

  let levelTextb: ref<inkImage> = new inkImage();
  levelTextb.SetName(n"levelTextb");
  levelTextb.SetFitToContent(true);
  levelTextb.SetAnchor(inkEAnchor.Fill);
  levelTextb.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
  levelTextb.SetTexturePart(n"rect_shape_fg");
  levelTextb.SetContentHAlign(inkEHorizontalAlign.Fill);
  levelTextb.SetContentVAlign(inkEVerticalAlign.Fill);
  levelTextb.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  levelTextb.BindProperty(n"tintColor", n"MainColors.ActiveRed");
  levelTextb.SetOpacity(1.0);
  levelTextb.SetHAlign(inkEHorizontalAlign.Fill);
  levelTextb.SetVAlign(inkEVerticalAlign.Fill);
  levelTextb.SetScale(new Vector2(1.4, 1.0));
  levelTextb.SetNineSliceScale(false);
  levelTextb.Reparent(newInfoContainer);

  let levelText: ref<inkText> = new inkText();
  levelText.SetName(n"CustomLevel");
  levelText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  levelText.SetFontStyle(n"Bold");
  levelText.SetFontSize(36);
  levelText.SetLetterCase(textLetterCase.OriginalCase);
  levelText.SetText("");
  levelText.SetFitToContent(true);
  levelText.SetMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
  levelText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  levelText.BindProperty(n"tintColor", n"MainColors.ActiveRed");
  levelText.SetHAlign(inkEHorizontalAlign.Left);
  levelText.SetVAlign(inkEVerticalAlign.Bottom);
  levelText.SetAnchor(inkEAnchor.BottomLeft);
  levelText.Reparent(newInfoContainer);
  
  let newInfoContainer2: ref<inkFlex> = new inkFlex();
  newInfoContainer2.SetName(n"CustomInfo2");
  newInfoContainer2.SetFitToContent(true);
  newInfoContainer2.SetHAlign(inkEHorizontalAlign.Left);
  newInfoContainer2.SetVAlign(inkEVerticalAlign.Bottom);
  newInfoContainer2.SetAnchor(inkEAnchor.BottomLeft);
  newInfoContainer2.SetAnchorPoint(new Vector2(0.5, 0.5));
  newInfoContainer2.SetMargin(new inkMargin(45.0, 0.0, 0.0, 8.0));
  newInfoContainer2.Reparent(mainSection);

  let nameTextb: ref<inkImage> = new inkImage();
  nameTextb.SetName(n"nameTextb");
  nameTextb.SetFitToContent(true);
  nameTextb.SetAnchor(inkEAnchor.Fill);
  nameTextb.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
  nameTextb.SetTexturePart(n"rect_shape_fg");
  nameTextb.SetContentHAlign(inkEHorizontalAlign.Fill);
  nameTextb.SetContentVAlign(inkEVerticalAlign.Fill);
  nameTextb.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  nameTextb.BindProperty(n"tintColor", n"MainColors.ActiveRed");
  nameTextb.SetOpacity(1.0);
  nameTextb.SetHAlign(inkEHorizontalAlign.Fill);
  nameTextb.SetVAlign(inkEVerticalAlign.Fill);
  nameTextb.SetScale(new Vector2(1.0, 1.0));
  nameTextb.SetNineSliceScale(true);
  nameTextb.Reparent(newInfoContainer2);

  let nameText: ref<inkText> = new inkText();
  nameText.SetName(n"CustomLabel");
  nameText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  nameText.SetFontStyle(n"Bold");
  nameText.SetFontSize(36);
  nameText.SetLetterCase(textLetterCase.UpperCase);
  nameText.SetText("");
  nameText.SetFitToContent(true);
  nameText.SetMargin(new inkMargin(10.0, 0.0, 10.0, 0.0));
  nameText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  nameText.BindProperty(n"tintColor", n"MainColors.ActiveRed");
  nameText.SetHAlign(inkEHorizontalAlign.Left);
  nameText.SetVAlign(inkEVerticalAlign.Bottom);
  nameText.SetAnchor(inkEAnchor.BottomLeft);
  nameText.Reparent(newInfoContainer2);

  this.customLevel = levelText;
  this.customLevelBorder = levelTextb;
  this.customName = nameText;
  this.customNameBorder = nameTextb;
  this.customContainer = newInfoContainer;
  this.customContainer2 = newInfoContainer2;

  

  this.customContainer.SetVisible(true);
  this.customContainer2.SetVisible(true);
  
}

// Nameplate settings

@wrapMethod(NameplateVisualsLogicController)
  public final func SetVisualData(puppet: ref<GameObject>, const incomingData: script_ref<NPCNextToTheCrosshair>, opt isNewNpc: Bool) -> Void {
  wrappedMethod(puppet, incomingData, isNewNpc);
  let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
  let NPCHBFull: ref<inkImage> = root.GetWidget(n"name_bar_holder/mainSection/name_health_holder/inkVerticalPanelWidget2/name_health_horiz_panel/healthBar/wrapper/logic/full_texture") as inkImage;
  let NPCHBChange: ref<inkImage> = root.GetWidget(n"name_bar_holder/mainSection/name_health_holder/inkVerticalPanelWidget2/name_health_horiz_panel/healthBar/wrapper/logic/changeP") as inkImage;

  this.m_levelContainerShouldBeVisible = true;

  let record: wref<Character_Record>;
  let sp: wref<ScriptedPuppet> = Deref(incomingData).npc as ScriptedPuppet;
  let archetypeName = record.ArchetypeData().Type().LocalizedName();
  let characterRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(sp.GetRecordID());

  this.customLevel.SetVisible(false);
  this.customName.SetVisible(false);

  if IsDefined(sp) {
    record = TweakDBInterface.GetCharacterRecord(sp.GetRecordID());
    this.customLevel.SetText(IntToString(Deref(incomingData).level));
	let npcType: gamedataNPCType = sp.GetRecord().CharacterType().Type();
  let affiliation: wref<Affiliation_Record> = TweakDBInterface.GetCharacterRecord(sp.GetRecordID()).Affiliation();  

//replace police first because the game is dumb as fuck

//NCPD


    if sp.IsPrevention() || sp.IsCharacterPolice() {


    if Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#1187")) || Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#48967")) || Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#44025"))
    {
    this.customName.SetText(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())));
    if Equals(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())), GetLocalizedText("LocKey#1187")) || Equals(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())), GetLocalizedText("LocKey#26430")) || Equals(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())), "None")
    {
    this.customName.SetText(GetLocalizedText("LocKey#22682"));
    };
    } else {
    if Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#1187")) || Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#26430")) || Equals(sp.GetTweakDBFullDisplayName(true), "None")
    {
    this.customName.SetText(GetLocalizedText("LocKey#22682"));
    };
    this.customName.SetText(sp.GetTweakDBFullDisplayName(true));
    };

    this.customLevel.SetVisible(true);
    this.customName.SetVisible(true);
    this.customLevel.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
    this.customLevelBorder.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
    this.customName.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
    this.customNameBorder.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
    NPCHBFull.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
    NPCHBChange.BindProperty(n"tintColor", n"MainColors.DarkBlue");


}

//Civvies
				    else {
    if sp.IsCharacterCivilian() || sp.IsCrowd() || sp.IsCharacterChildren(){
	  this.customName.SetText(sp.GetTweakDBFullDisplayName(true));
	  this.customLevel.SetVisible(false);
      this.customName.SetVisible(true);
	  this.customName.BindProperty(n"tintColor", n"MainColors.Grey");
	  this.customNameBorder.BindProperty(n"tintColor", n"MainColors.Grey");
	  NPCHBFull.BindProperty(n"tintColor", n"MainColors.Grey");
	  NPCHBChange.BindProperty(n"tintColor", n"MainColors.DarkGrey");
	  
    
            }
	else {

//Friendlies

    if Equals(Deref(incomingData).attitude, EAIAttitude.AIA_Friendly) {
    this.customName.SetText(sp.GetTweakDBDisplayName(true));
	  this.customName.BindProperty(n"tintColor", n"MainColors.Green");
	  this.customNameBorder.BindProperty(n"tintColor", n"MainColors.Green");
	  this.customLevel.BindProperty(n"tintColor", n"MainColors.Green");
	  this.customLevelBorder.BindProperty(n"tintColor", n"MainColors.Green");
	  NPCHBFull.BindProperty(n"tintColor", n"MainColors.Green");
	  NPCHBChange.BindProperty(n"tintColor", n"MainColors.DarkGreen");
      this.customLevel.SetVisible(false);
      this.customName.SetVisible(true);
    }
    else {
	
    if sp.IsVendor() {
    this.customName.SetText(sp.GetTweakDBDisplayName(true));
	  this.customName.BindProperty(n"tintColor", n"MainColors.Green");
	  this.customNameBorder.BindProperty(n"tintColor", n"MainColors.Green");
	  this.customLevel.SetVisible(false);
      this.customName.SetVisible(true);
    }	



//Fixes for the "NONE" NPC name bug


//Mechs, drones, androids

	else {
    if Equals(npcType, gamedataNPCType.Android) || Equals(npcType, gamedataNPCType.Drone) || Equals(npcType, gamedataNPCType.Mech) {
      this.customName.SetVisible(true);
      this.customLevel.SetVisible(true);
      this.customName.SetText(sp.GetTweakDBFullDisplayName(true));

        if Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#1187")) || Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#48967")) || Equals(sp.GetTweakDBFullDisplayName(true), GetLocalizedText("LocKey#44025"))
        {
            this.customName.SetText(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())));
        };
        if Equals(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())), GetLocalizedText("LocKey#1187")) || Equals(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())), GetLocalizedText("LocKey#23363"))
        {
            this.customName.SetText(LocKeyToString(record.Affiliation().LocalizedName()));
        };

        // This one checks if display name even exists and if it does overrides anything else
        if NotEquals(TweakDBInterface.GetCharacterRecord(sp.GetRecordID()).DisplayName(), n"")
        {
            this.customName.SetText(LocKeyToString(TweakDBInterface.GetCharacterRecord(sp.GetRecordID()).DisplayName()));
        };

      this.customLevel.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      this.customLevelBorder.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      this.customName.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      this.customNameBorder.BindProperty(n"tintColor", n"MainColors.EnemyBase");
	  NPCHBFull.BindProperty(n"tintColor", n"MainColors.EnemyBase");
	  NPCHBChange.BindProperty(n"tintColor", n"MainColors.DarkRed");
    }
	
	
//Generic hostile enemies

	
  else {
    if sp.IsAggressive() || sp.IsHostile() {
      this.customName.SetText(GetLocalizedText(NameToString(record.ArchetypeData().Type().LocalizedName())));
      this.customLevel.SetVisible(true);
      this.customName.SetVisible(true);
      this.customLevel.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      this.customLevelBorder.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      this.customName.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      this.customNameBorder.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      NPCHBFull.BindProperty(n"tintColor", n"MainColors.EnemyBase");
      NPCHBChange.BindProperty(n"tintColor", n"MainColors.DarkRed");
        
        if Equals(record.ArchetypeData().Type().LocalizedName(), n"") // && NotEquals(LocKeyToString(record.Affiliation().LocalizedName()), GetLocalizedText("LocKey#44338"))
        {
            this.customName.SetText(LocKeyToString(record.Affiliation().LocalizedName()));
        };

        // if Equals(GetLocalizedText(LocKeyToString(record.Affiliation().LocalizedName())), GetLocalizedText("LocKey#44338"))
        // {
        //     this.customName.SetText(sp.GetTweakDBFullDisplayName(true));
        // };
        
    } 


		else {

      this.customName.SetText(sp.GetTweakDBFullDisplayName(true));
      this.customLevel.SetVisible(false);
      this.customName.SetVisible(true);
      this.customName.BindProperty(n"tintColor", n"MainColors.Grey");
      this.customNameBorder.BindProperty(n"tintColor", n"MainColors.Grey");
      NPCHBFull.BindProperty(n"tintColor", n"MainColors.Grey");
      NPCHBChange.BindProperty(n"tintColor", n"MainColors.DarkGrey");
      


	          }
          };
        };
      };
    };
  };
};
}
  

  
  
    

//replacing shit below 
 
//@replaceMethod(StealthMappinController)
//  private final func UpdateArchetypeTexture() -> Void {}
		
@replaceMethod(NpcNameplateGameController)
  private final func HelperCheckDistance(entity: ref<Entity>) -> Bool {
    let playerPuppet: ref<PlayerPuppet>;
    playerPuppet = this.GetPlayerControlledObject() as PlayerPuppet;
    this.c_DisplayRange = playerPuppet.namePlateSettings.range;

    let displayMaxRange: Float;
    let displayRange: Float;
    let distToEntity: Float;
    let gameObject: wref<GameObject>;
    let max_dist: Float;
    let puppet: wref<ScriptedPuppet>;
    if entity == null {
      return false;
    };
    gameObject = entity as GameObject;
    puppet = entity as ScriptedPuppet;
    if IsDefined(puppet) && (Equals(this.m_attitude, EAIAttitude.AIA_Hostile) || puppet.IsAggressive() && NotEquals(this.m_attitude, EAIAttitude.AIA_Friendly)) {
      displayRange = this.c_DisplayRange;
      displayMaxRange = this.c_MaxDisplayRange;
    } else {
      if IsDefined(gameObject) && gameObject.IsTurret() && NotEquals(this.m_attitude, EAIAttitude.AIA_Friendly) {
        displayRange = this.c_DisplayRange;
        displayMaxRange = this.c_MaxDisplayRange;
      } else {
        displayRange = this.c_DisplayRange;
        displayMaxRange = this.c_MaxDisplayRange;
      };
    };
    distToEntity = MinF(this.GetDistanceToEntity(entity), displayMaxRange * this.m_zoom);
    max_dist = displayRange * this.m_zoom;
    if distToEntity < max_dist {
      return true;
    };
    return false;
  }
  
@replaceMethod(NameplateVisualsLogicController)
  private final func SetElementVisibility(const incomingData: script_ref<NPCNextToTheCrosshair>) -> Void {
    let enemyDifficulty: gameEPowerDifferential;
    let isTurret: Bool;
    let npc: ref<NPCPuppet>;
	let sp: wref<ScriptedPuppet> = Deref(incomingData).npc as ScriptedPuppet;
	
    inkWidgetRef.SetVisible(this.m_rarityHolder, true);
    inkWidgetRef.SetVisible(this.m_rarities[0], true);
    inkWidgetRef.SetVisible(this.m_rarities[1], true);

    //inkWidgetRef.SetVisible(this.m_bigIconArt, false);
    inkWidgetRef.SetVisible(this.m_nameTextMain, false);
    //inkWidgetRef.SetVisible(this.m_eliteStars, false);
    //inkWidgetRef.SetVisible(this.m_rareStars, false);
    //inkWidgetRef.SetVisible(this.m_civilianIcon, false);
    //inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, false);
    //inkWidgetRef.SetVisible(this.m_preventionIcon, false);
    this.m_levelContainerShouldBeVisible = false;
    this.m_isHardEnemy = false;
    isTurret = IsDefined(Deref(incomingData).npc) && Deref(incomingData).npc.IsTurret();
    npc = Deref(incomingData).npc as NPCPuppet;
    if IsDefined(npc) || isTurret {
      this.m_rootWidget.SetVisible(!this.m_forceHide && (Deref(incomingData).npc.IsPlayer() || !this.m_npcDefeated));
    };
    if this.m_npcIsAggressive {
      if isTurret {
        enemyDifficulty = gameEPowerDifferential.NORMAL;
      } else {
        enemyDifficulty = RPGManager.CalculatePowerDifferential(npc);
      };
      if !isTurret && (Equals(enemyDifficulty, gameEPowerDifferential.IMPOSSIBLE) || NPCManager.HasVisualTag(npc, n"Sumo")) {
        this.m_isHardEnemy = true;
        //inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, true);
      } else {
        this.m_isHardEnemy = false;
        this.m_isAnimating = false;
        if IsDefined(this.m_animProxy) {
          this.m_animProxy.Stop();
          this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeInComplete");
          this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnFadeOutComplete");
          this.m_animProxy.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnScreenDelayComplete");
        };
      };
      this.m_levelContainerShouldBeVisible = true;
      //inkWidgetRef.SetVisible(this.m_bigLevelText, true);
      //inkWidgetRef.SetVisible(this.m_nameTextMain, true);
      this.m_levelContainerShouldBeVisible = true;
      //if this.m_isPrevention {
      if this.m_isNCPD {
        //this.UpdateCenterIcon(n"");
        //inkWidgetRef.SetVisible(this.m_preventionIcon, true);
        //inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, false);
      } else {
        if this.m_isElite {
          inkWidgetRef.SetVisible(this.m_rarityHolder, true);
          inkWidgetRef.SetVisible(this.m_rarities[0], false);
          //inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, true);
        } else {
          if this.m_isBoss {
            inkWidgetRef.SetVisible(this.m_rarityHolder, true);
            inkWidgetRef.SetVisible(this.m_rarities[0], false);
            //inkWidgetRef.SetVisible(this.m_hardEnemyWrapper, true);
          };
        };
      };
    };

    let playerPuppet: ref<PlayerPuppet>;
    playerPuppet = this.playerPuppet as PlayerPuppet;

    switch Deref(incomingData).attitude {
      case sp.IsAggressive() || sp.IsHostile():
        if(!playerPuppet.namePlateSettings.showHostile){
          this.m_rootWidget.SetVisible(true);
        }
        break;
      case EAIAttitude.AIA_Friendly:
        if(!playerPuppet.namePlateSettings.showFriendly){
          this.m_rootWidget.SetVisible(true);
        }
        break;
      case sp.IsCharacterCivilian() || sp.IsCrowd():
        if(!playerPuppet.namePlateSettings.showCivilian){
          this.m_rootWidget.SetVisible(true);
        }
        break;
      default:
        if(!playerPuppet.namePlateSettings.showNeutral){
          this.m_rootWidget.SetVisible(true);
        }
    };
  }

@replaceMethod(NameplateVisualsLogicController)
  private final func SetAttitudeColors(puppet: wref<gamePuppetBase>, const incomingData: script_ref<NPCNextToTheCrosshair>) -> Void {
    let attitudeColor: CName;
    inkTextRef.SetLetterCase(this.m_nameTextMain, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_nameTextMain, Deref(incomingData).name);
    switch Deref(incomingData).attitude {
      case EAIAttitude.AIA_Hostile:
        attitudeColor = n"Hostile";
        break;
      case EAIAttitude.AIA_Friendly:
        attitudeColor = n"Friendly";
        break;
      case EAIAttitude.AIA_Neutral:
        attitudeColor = n"Neutral";
        break;
      default:
        attitudeColor = n"Civilian";
    };
    //if this.m_npcIsAggressive {
      //inkWidgetRef.SetState(this.m_bigLevelText, attitudeColor);
      //inkWidgetRef.SetState(this.m_bigLevelText, attitudeColor);
      //inkWidgetRef.SetState(this.m_bigIconArt, this.m_isQuestTarget ? n"Quest" : n"Hostile");
      //inkWidgetRef.SetState(this.m_civilianIcon, this.m_isQuestTarget ? n"Quest" : n"Hostile");
      //inkWidgetRef.SetState(this.m_rareStars, n"Hostile");
      //inkWidgetRef.SetState(this.m_eliteStars, n"Hostile");
      //inkWidgetRef.SetState(this.m_nameTextMain, this.m_isQuestTarget ? n"Quest" : n"Hostile");
    //} else {
      //inkWidgetRef.SetState(this.m_bigLevelText, attitudeColor);
      //inkWidgetRef.SetState(this.m_bigLevelText, attitudeColor);
      //inkWidgetRef.SetState(this.m_bigIconArt, this.m_isQuestTarget ? n"Quest" : attitudeColor);
      //inkWidgetRef.SetState(this.m_civilianIcon, this.m_isQuestTarget ? n"Quest" : attitudeColor);
      //inkWidgetRef.SetState(this.m_rareStars, attitudeColor);
      //inkWidgetRef.SetState(this.m_eliteStars, attitudeColor);
      //inkWidgetRef.SetState(this.m_nameTextMain, this.m_isQuestTarget ? n"Quest" : attitudeColor);
      //inkWidgetRef.SetState(this.m_hardEnemy, attitudeColor);
    //};
    if this.m_npcIsAggressive {
      inkWidgetRef.SetState(this.m_nameTextMain, this.m_isQuestTarget ? n"Quest" : n"Hostile");
      if this.m_isNCPD {
        inkWidgetRef.SetState(this.m_nameTextMain, this.m_isQuestTarget ? n"Quest" : n"Prevention_Blue");
      };
    } else {
      inkWidgetRef.SetState(this.m_nameTextMain, this.m_isQuestTarget ? n"Quest" : attitudeColor);
    };
    if this.m_isBoss {
      attitudeColor = n"Boss";
    };
    if puppet != null && puppet.IsPlayer() {
      inkWidgetRef.SetState(this.m_nameTextMain, n"CPO_Player");
    };
    //if this.m_isPrevention {
    //  this.PlayPreventionAnim();
    //} else {
    //  this.StopPreventionAnim();
    //};
  }

// Settings / CET part

class NamePlateSettings{
  public let showHostile: Bool;
  public let showFriendly: Bool;
  public let showNeutral: Bool;
  public let showCivilian: Bool;
  public let range: Float;
}

@addField(PlayerPuppet)
private let namePlateSettings: ref<NamePlateSettings>;

@wrapMethod(PlayerPuppet)
  protected cb func OnGameAttached() -> Bool {
    wrappedMethod();
    this.namePlateSettings = new NamePlateSettings();
  }

@addField(NameplateVisualsLogicController)
private let playerPuppet: ref<PlayerPuppet>;