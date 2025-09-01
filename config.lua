--[[
    Configuration File
    Global settings and constants for the script
]]--

local Config = {}

-- Script Information
Config.ScriptInfo = {
    Name = "Modern Fishing Script",
    Version = "2.0.0",
    Author = "DESIWULANRETNASIH",
    Description = "A modern, modular fishing automation script with dark UI",
    LastUpdated = "2025-09-01"
}

-- UI Configuration
Config.UI = {
    ThemeName = "dark",
    
    -- Window Settings
    DefaultWindowSize = UDim2.new(0, 400, 0, 400),
    MinWindowSize = UDim2.new(0, 300, 0, 250),
    MaxWindowSize = UDim2.new(0, 800, 0, 800),
    
    -- Floating Button
    FloatingButtonEnabled = true,
    FloatingButtonPosition = UDim2.new(1, -70, 0, 100),
    
    -- Animations
    EnableAnimations = true,
    AnimationSpeed = 0.25,
    
    -- Notifications
    NotificationDuration = 3,
    ShowNotifications = true
}

-- Feature Flags
Config.Features = {
    -- Automation
    EnableAutomation = true,
    EnableAdvancedAutomation = true,
    
    -- Teleportation
    EnableTeleports = true,
    EnablePlayerTeleports = true,
    SaveFavoriteLocations = true,
    
    -- Modifications
    EnableGameModifications = true,
    EnableHooks = true,
    
    -- Visuals
    EnableVisualMods = true,
    EnableFishRadar = true,
    EnableRodChams = true,
    
    -- Performance
    EnablePerformanceMonitoring = true,
    AutoSaveSettings = true,
    SaveInterval = 30 -- seconds
}

-- Performance Settings
Config.Performance = {
    -- Frame Rate
    TargetFPS = 60,
    LowFPSThreshold = 30,
    
    -- Memory Management
    AutoCleanup = true,
    CleanupInterval = 300, -- 5 minutes
    
    -- Connection Limits
    MaxConnections = 50,
    WarnConnectionThreshold = 40
}

-- Automation Settings
Config.Automation = {
    -- Timing
    CastDelay = 0.5,
    ReelDelay = 0.5,
    ShakeResponseTime = 0.1,
    
    -- Safety
    AntiAFKEnabled = true,
    RandomDelays = true,
    MinRandomDelay = 0.1,
    MaxRandomDelay = 0.3,
    
    -- Advanced Features
    AutoSellEnabled = false,
    AutoBuyBaitEnabled = false,
    AutoEquipBestRod = false,
    
    -- Rod Priorities (best to worst)
    RodPriorities = {
        "Mythical Rod",
        "Kings Rod", 
        "Trident Rod",
        "Midas Rod",
        "Heaven Rod",
        "Summit Rod",
        "Carbon Rod",
        "Lucky Rod",
        "Fast Rod",
        "Long Rod",
        "Nocturnal Rod",
        "Plastic Rod",
        "Training Rod",
        "Flimsy Rod"
    }
}

-- Visual Settings
Config.Visuals = {
    -- Rod Chams
    DefaultRodMaterial = "ForceField",
    RodChamsColor = Color3.fromRGB(100, 100, 255),
    
    -- Fish Abundance
    ShowFishAbundance = false,
    AbundanceUpdateRate = 1, -- seconds
    
    -- UI Colors (override theme if needed)
    CustomColors = {
        Primary = nil, -- Use theme default
        Secondary = nil,
        Background = nil
    }
}

-- Teleportation Settings
Config.Teleports = {
    -- Safety
    TeleportDelay = 0.1,
    SafeTeleport = true,
    ConfirmDangerousTeleports = true,
    
    -- Favorites
    MaxFavorites = 20,
    AutoSaveFavorites = true,
    
    -- Quick Access
    QuickTeleports = {
        "Moosewood",
        "The Depths",
        "Enchanted Altar",
        "Roslit Bay"
    }
}

-- Debug Settings
Config.Debug = {
    EnableDebugMode = false,
    ShowDebugNotifications = false,
    LogLevel = "INFO", -- ERROR, WARN, INFO, DEBUG
    SaveDebugLogs = false,
    MaxLogEntries = 1000
}

-- Security Settings
Config.Security = {
    -- Anti-Detection
    RandomizeTimings = true,
    HumanLikeDelays = true,
    
    -- Validation
    ValidateGameState = true,
    CheckForUpdates = false,
    
    -- Backup
    BackupSettings = true,
    MaxBackups = 5
}

-- File Paths
Config.Paths = {
    BaseFolder = "FischModern",
    SettingsFile = "settings.json",
    FavoritesFile = "favorites.json",
    LogFile = "debug.log",
    BackupFolder = "backups"
}

-- Game-Specific Settings
Config.Game = {
    GameId = 16732694052, -- Fisch game ID
    
    -- Game Objects
    WaterPartName = "Water",
    FishingZonesPath = "workspace.zones.fishing",
    
    -- Remote Events
    CastRemote = "cast",
    ReelRemote = "reelfinished",
    AFKRemote = "afk",
    
    -- UI Elements
    ShakeUIPath = "PlayerGui.shakeui",
    SafeZonePath = "safezone.button"
}

-- Default Settings
Config.Defaults = {
    -- Automation
    autocast = false,
    autoshake = false,
    autoreel = false,
    freezechar = false,
    freezecharmode = "Rod Equipped",
    
    -- Modifications
    noafk = false,
    perfectcast = false,
    alwayscatch = false,
    infoxygen = false,
    nopeakssystems = false,
    
    -- Visuals
    rodchams = false,
    bodyrodchams = false,
    rodmaterial = "ForceField",
    fishabundance = false,
    
    -- UI
    windowsVisible = true,
    floatingButtonEnabled = true
}

-- Validation Functions
function Config.ValidateSettings(settings)
    for key, defaultValue in pairs(Config.Defaults) do
        if settings[key] == nil then
            settings[key] = defaultValue
        end
    end
    return settings
end

function Config.GetSetting(key, default)
    return Config.Defaults[key] or default
end

function Config.IsFeatureEnabled(feature)
    return Config.Features[feature] == true
end

-- Version Compatibility
Config.Compatibility = {
    MinimumVersion = "1.0.0",
    SupportedVersions = {"1.0.0", "1.5.0", "2.0.0"},
    BreakingChanges = {
        ["2.0.0"] = "Complete UI rewrite with modular structure"
    }
}

return Config
