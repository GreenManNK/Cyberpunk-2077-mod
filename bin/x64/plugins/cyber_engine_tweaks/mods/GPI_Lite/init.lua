local nativeSettings = nil
local settings = {
    Current = {
        cas = true,
        vrs = true,
        async = true,
        resscaling = true,
        rtx = false,
        ultra_latency = true,  
        vram_boost = true,
        lod_quality = 1.0,
        low_cpu_crowds = true,
        potato_volumetrics = true,
        fast_streaming = true,
        -- New for v2
        optimized_shadows = true,  -- Reduces shadow map resolution
        screen_space_clean = true, -- Disables heavy post-fx (Film Grain, Chromatic Aberration)
        anisotropy_fix = true      -- Optimizes texture filtering for mid-range cards
    },
    Default = {
        cas = true,
        vrs = true,
        async = true,
        resscaling = false,
        rtx = false,
        ultra_latency = true,
        vram_boost = true,
        lod_quality = 1.0,
        low_cpu_crowds = true,
        potato_volumetrics = false,
        fast_streaming = false,
        optimized_shadows = true,
        screen_space_clean = true,
        anisotropy_fix = true
    }
}

-- [File I/O logic remains the same for compatibility]
function SaveSettings()
    local file = io.open("config.json", "w")
    if file then
        file:write(json.encode(settings.Current))
        file:close()
    end
end

function LoadSettings()
    local file = io.open("config.json", "r")
    if file then
        local content = file:read("*a")
        file:close()
        settings.Current = json.decode(content) or {}
    end
    for key, defaultValue in pairs(settings.Default) do
        if settings.Current[key] == nil then settings.Current[key] = defaultValue end
    end
end

function NativeMenu()
    nativeSettings = GetMod("nativeSettings")
    nativeSettings.addTab("/GPI", "GPI Lite Pro v2")
    nativeSettings.addSubcategory("/GPI/main", "Performance & Stability")

    -- Existing Toggles
    nativeSettings.addSwitch("/GPI/main", "Low Latency Mode", "Reduces input lag.", settings.Current.ultra_latency, settings.Default.ultra_latency, function(state)
        settings.Current.ultra_latency = state
        SaveSettings()
    end)

    -- v1 Logic
    nativeSettings.addSwitch("/GPI/main", "CPU Crowd Relief", "Lowers NPC/Traffic count for CPU stability.", settings.Current.low_cpu_crowds, settings.Default.low_cpu_crowds, function(state)
        settings.Current.low_cpu_crowds = state
        SaveSettings()
    end)

    nativeSettings.addSwitch("/GPI/main", "Potato Volumetrics", "Reduces fog/clouds for GPU performance.", settings.Current.potato_volumetrics, settings.Default.potato_volumetrics, function(state)
        settings.Current.potato_volumetrics = state
        SaveSettings()
    end)

    -- NEW: Shadow Optimization
    nativeSettings.addSwitch("/GPI/main", "Optimized Shadows", "Lower shadow resolution & faster filtering.", settings.Current.optimized_shadows, settings.Default.optimized_shadows, function(state)
        settings.Current.optimized_shadows = state
        SaveSettings()
    end)

    -- NEW: Screen Space Clean
    nativeSettings.addSwitch("/GPI/main", "Clean View (Post-FX)", "Disables Film Grain and Aberration for clarity and small FPS gain.", settings.Current.screen_space_clean, settings.Default.screen_space_clean, function(state)
        settings.Current.screen_space_clean = state
        SaveSettings()
    end)

    nativeSettings.addSwitch("/GPI/main", "Slow Storage Optimization", "Prevents pop-in on HDDs.", settings.Current.fast_streaming, settings.Default.fast_streaming, function(state)
        settings.Current.fast_streaming = state
        SaveSettings()
    end)

    nativeSettings.addButton("/GPI/main", "Apply & Re-init", "Applies settings immediately.", "Apply", 45, function()
        LoadSettings()
        DoStuff()
    end)
end

function DoStuff()
    LoadSettings()

    -- 1. LATENCY & INPUT
    if settings.Current.ultra_latency then
        GameOptions.SetBool("NVIDIA_Reflex", "Enable", true)
        GameOptions.SetInt("NVIDIA_Reflex", "Mode", 1) 
        GameOptions.SetBool("Rendering", "AsyncCompute", true)
    end

    -- 2. CPU CROWD OPTIMIZATION
    if settings.Current.low_cpu_crowds then
        GameOptions.SetInt("Crowds", "Density", 0) 
        GameOptions.SetInt("Traffic", "Density", 0)
    end

    -- 3. VOLUMETRICS & SHADOWS
    if settings.Current.potato_volumetrics then
        GameOptions.SetInt("Rendering/VolumetricFog", "Resolution", 0)
        GameOptions.SetBool("Rendering/VolumetricClouds", "Enable", false)
    end

    if settings.Current.optimized_shadows then
        GameOptions.SetInt("Rendering/Shadows", "CascadeStatics", 0) -- Less detailed distant shadows
        GameOptions.SetInt("Rendering/Shadows", "CascadeStaticsResolution", 512)
        GameOptions.SetInt("Rendering/Shadows", "DistantShadowsResolution", 256)
    end

    -- 4. CLEAN VIEW & TEXTURES
    if settings.Current.screen_space_clean then
        GameOptions.SetBool("Rendering", "FilmGrain", false)
        GameOptions.SetBool("Rendering", "ChromaticAberration", false)
        GameOptions.SetBool("Rendering", "DepthOfField", false) -- Major clarity boost
    end

    if settings.Current.anisotropy_fix then
        GameOptions.SetInt("Rendering", "Anisotropy", 8) -- 8x is sweet spot for mid-range performance
    end

    -- 5. VRAM & ASSET STREAMING
    if settings.Current.vram_boost then
        GameOptions.SetInt("Streaming", "MaxNodesPerFrame", 300)
        GameOptions.SetFloat("Rendering/MeshLoading", "AutoRefreshTime", 0.15)
        -- Help prevent 'stretching' artifacts on low-end cards
        GameOptions.SetBool("Rendering/MeshLoading", "ForceHighestLOD", false)
    end

    if settings.Current.fast_streaming then
        GameOptions.SetBool("Streaming", "KeepIn Cache", true)
        GameOptions.SetInt("Streaming/Culling", "ForceSSDMode", 0)
    end
end

registerForEvent('onInit', function()
    DoStuff()
    NativeMenu()
end)