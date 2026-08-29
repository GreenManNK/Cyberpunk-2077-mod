local variantUtils = {}


---@param ref string Variant's nodeRef
---@param variant string Variant's name
---@param state boolean Variant's visibility
function variantUtils.setVariantVisibility(ref, variant, state)
    Game.GetWorldStateSystem():TogglePrefabVariant(CreateNodeRef(ref), variant, state)
end

---@param ref string Variant's ref
---@param variant string Variant's name
---@param state boolean Variant's visibility
function variantUtils.toggleVariant(ref, variant, state)
    Game.GetWorldStateSystem():ToggleVariant(CreateNodeRef(ref), variant, state)
end


---@param ref string Node's ref
---@param state boolean Node's visibility
function variantUtils.toggleNode(ref, state)
    Game.GetWorldStateSystem():ToggleNode(CreateNodeRef(ref), state)
end


---If you're changing a setting state and updating it, make sure to change the value of setting.state before calling this function
---@param setting any Setting to update
function variantUtils.updateVariantVisibility(setting)
    if setting.type == "boolean" then
        variantUtils.setVariantVisibility(setting.ref, setting.variant, setting.state)
    elseif setting.type == "swap" then
        variantUtils.setVariantVisibility(setting.ref, setting.variantTrue, setting.state)
        variantUtils.setVariantVisibility(setting.ref, setting.variantFalse, not setting.state)
    elseif setting.type == "selector" then
        -- Toggle off all variants but the one selected
        for variantKey, variantRef in pairs(setting.variants) do
            local isActive = (variantKey == setting.state)
            variantUtils.setVariantVisibility(setting.ref, variantRef, isActive)
        end
    end
end

return variantUtils