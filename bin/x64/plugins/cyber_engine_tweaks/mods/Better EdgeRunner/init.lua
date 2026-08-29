registerForEvent("onInit", function()
  TweakDB:SetFlat("NewPerks.Tech_Master_Perk_3_inline3.value", 500.0) -- 义体容量
  -- TweakDB:SetFlat("NewPerks.Tech_Master_Perk_3_inline4.value", 1.0) -- 每超过1点?
  -- TweakDB:SetFlat("NewPerks.Tech_Master_Perk_3_inline5.value", 0.5) -- 边缘行者生命减少率 0.5
  -- TweakDB:SetFlat("NewPerks.Tech_Master_Perk_3_inline6.value", 0.5) -- 边缘行者生命减少率 0.5
  -- TweakDB:SetFlat("NewPerks.Tech_Master_Perk_3_inline7.value", 1.0) -- opSymbol *(1-x)
  -- TweakDB:SetFlat("NewPerks.Tech_Master_Perk_3_inline11.value", 0.001) -- 边缘行者大笑几率 0.001

  TweakDB:SetFlat("BaseStatusEffect.Tech_Master_Perk_3_Buff_inline2.value", 30.0) -- 边缘行者大笑持续时间12.0
  TweakDB:SetFlat("BaseStatusEffect.Tech_Master_Perk_3_Buff_inline4.value", 100.0) -- 边缘行者大笑暴击率30%
  TweakDB:SetFlat("BaseStatusEffect.Tech_Master_Perk_3_Buff_inline5.value", 100.0) -- 边缘行者大笑暴击伤害50%

  TweakDB:SetFlat("NewPerks.Tech_Master_Perk_3_inline0.floatValues", {
    500.0, -- 义体上限最大1000
    0.5, -- 每超过1点,减0.5%最大生命值
    0.1, -- 每超过1点, 几率增加0.1%
    10.0, -- 10%伤害
    100.0, -- 100% 暴击率
    100.0, -- 100% 暴击伤害
    30.0  -- 持续时间30s
  }) -- 义体容量
end)