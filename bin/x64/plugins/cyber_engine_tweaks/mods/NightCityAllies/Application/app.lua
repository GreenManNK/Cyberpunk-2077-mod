App = {}

function App:new(characterLoader, moduleLoader)
    self.characterLoader = characterLoader
    self.moduleLoader = moduleLoader
    self.availableNPCs = {}
    self.availableInteractions = {}
    self.modules = {}
	return App
end

function App:LoadModules()
    self.availableNPCs = self.characterLoader.Load() --
    self.availableInteractions = self.moduleLoader:LoadInteractions()
    self.modules = self.moduleLoader:LoadModules()
end

function App:OnSessionStart()
    local NCA = GetMod("NightCityAllies")

    -- legacy & amm loader
    for _, foundChar in ipairs(self.availableNPCs) do
        NCA:RegisterCharacter(foundChar)
    end

    print("[NCA] Loading modules ... ")
    for _, module in ipairs(self.modules) do
        local success, result = pcall(module.load, NCA)
        if not success then
            print("    " .. module.name .. " ERROR: " .. result)
        else
            print("    " .. module.name .. " OK")
        end
    end
end

function App:CollectInteractions(npc)
    local result = {}

    for _, choice in ipairs(self.availableInteractions) do
        local entries = { choice }

        if type(choice) == "function" then
            entries = {}
            local success, generated = pcall(choice, npc)
            if not success then
                print("[NCA] ERROR building interaction entries: " .. tostring(generated))
            elseif type(generated) == "table" then
                entries = generated
            end
        end

        for _, entry in ipairs(entries) do
            if entry.condition == nil or entry.condition(npc) then
                table.insert(result, entry)
            end
        end
    end

    return result
end

return App