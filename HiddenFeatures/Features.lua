-- Hidden Features: catalog of switches.
--
-- Each entry maps a switch to a client CVar. Rows whose CVar doesn't exist in the
-- running client are detected at runtime and greyed out, so it's safe to list
-- features that only some builds have.
--
--   cat          category heading
--   cvar         console variable
--   name / desc  label and tooltip
--   on / off     values written when the switch is turned on / off
--   extra        { [cvar] = { onValue, offValue } } additional CVars set together
--   reload       true if it needs /reload to fully apply
--   experimental true if the client shows an "experimental feature" warning
local _, ns = ...

local NAV      = "Navigation & Map"
local COMBAT   = "Combat & Action Bars"
local TARGET   = "Targeting & Interaction"
local PLATES   = "Nameplates"
local CAMERA   = "Camera"
local GFX      = "Graphics & Effects"
local QOL      = "Quality of Life"
local SOUND    = "Sound"
local CHAT     = "Chat & Text"
local DEV      = "Developer"

ns.Features = {
    ---------------------------------------------------------------- Navigation
    { cat = NAV, cvar = "showInGameNavigation", on = "1", off = "0",
      name = "In-game navigation",
      desc = "Shows the floating waypoint/navigation marker and distance for the tracked quest or map pin." },
    { cat = NAV, cvar = "showDungeonEntrancesOnMap", on = "1", off = "0",
      name = "Dungeon entrances on map",
      desc = "Marks dungeon and raid entrances on the world map." },
    { cat = NAV, cvar = "questPOI", on = "1", off = "0",
      name = "Quest objective areas (POI)",
      desc = "Shows quest objective areas and blobs on the world map and minimap." },
    { cat = NAV, cvar = "showQuestTrackingTooltips", on = "1", off = "0",
      name = "Quest info in unit tooltips",
      desc = "Adds quest objective progress to tooltips of quest mobs and objects." },
    { cat = NAV, cvar = "autoQuestWatch", on = "1", off = "0",
      name = "Auto-track new quests",
      desc = "Automatically adds newly accepted quests to the objective tracker." },
    { cat = NAV, cvar = "mapFade", on = "1", off = "0",
      name = "Fade world map while moving",
      desc = "Makes the world map translucent while your character moves." },
    { cat = NAV, cvar = "minimapTrackingShowAll", on = "1", off = "0",
      name = "Show all minimap tracking types",
      desc = "Lists every tracking type in the minimap tracking menu." },

    ---------------------------------------------------------------- Combat
    { cat = COMBAT, cvar = "assistedCombatHighlight", on = "1", off = "0",
      name = "Assisted combat highlight",
      desc = "Highlights the recommended next ability on your action bars (retail rotation helper)." },
    { cat = COMBAT, cvar = "cooldownViewerEnabled", on = "1", off = "0",
      name = "Cooldown Manager",
      desc = "Enables the built-in cooldown tracking bars/icons from retail. Configure them in Edit Mode.",
      reload = true },
    { cat = COMBAT, cvar = "damageMeterEnabled", on = "1", off = "0",
      name = "Built-in damage meter",
      desc = "Enables the client's native damage/healing meter, if this build includes it.",
      reload = true },
    { cat = COMBAT, cvar = "countdownForCooldowns", on = "1", off = "0",
      name = "Cooldown numbers on buttons",
      desc = "Shows remaining cooldown time as numbers on action buttons — no OmniCC needed." },
    { cat = COMBAT, cvar = "displaySpellActivationOverlays", on = "1", off = "0",
      name = "Spell alert overlays",
      desc = "Shows proc alerts around your character and glows on action buttons." },
    { cat = COMBAT, cvar = "ActionButtonUseKeyDown", on = "1", off = "0",
      name = "Cast on key down",
      desc = "Fires abilities when the key is pressed instead of released." },
    { cat = COMBAT, cvar = "AutoPushSpellToActionBar", on = "0", off = "1",
      name = "Don't auto-place new spells",
      desc = "Stops newly learned spells from being dropped onto your action bars." },
    { cat = COMBAT, cvar = "floatingCombatTextCombatDamageDirectionalScale", on = "1", off = "0",
      name = "Directional damage numbers",
      desc = "Damage numbers fly away from the target in the direction of the hit." },
    { cat = COMBAT, cvar = "findYourselfMode", on = "1", off = "-1",
      name = "Self highlight: circle + outline",
      desc = "Draws a circle and outline on your character so you can find yourself in busy fights." },
    { cat = COMBAT, cvar = "findYourselfAnywhere", on = "1", off = "0",
      name = "Self highlight everywhere",
      desc = "Use self highlight in the open world, not only in groups/instances." },
    { cat = COMBAT, cvar = "occludedSilhouettePlayer", on = "1", off = "0",
      name = "Silhouette when hidden",
      desc = "Shows your character's outline when it's hidden behind walls or objects." },

    ---------------------------------------------------------------- Targeting
    { cat = TARGET, cvar = "SoftTargetInteract", on = "3", off = "0",
      name = "Soft-target interact",
      desc = "Lets the Interact key loot, talk to NPCs and use objects in front of you. Bind 'Interact With Target' in Key Bindings.",
      extra = { SoftTargetIconInteract = { "1", "0" }, SoftTargetIconGameObject = { "1", "0" } } },
    { cat = TARGET, cvar = "SoftTargetEnemy", on = "1", off = "0",
      name = "Soft-target enemies",
      desc = "Abilities fire at the enemy you're facing when you have no hard target." },
    { cat = TARGET, cvar = "SoftTargetFriend", on = "1", off = "0",
      name = "Soft-target friends",
      desc = "Helpful spells go to the friendly player you're facing when you have no hard target." },
    { cat = TARGET, cvar = "SoftTargetNameplateInteract", on = "1", off = "0",
      name = "Name over interact target",
      desc = "Shows a nameplate/name over the current soft interact target." },
    { cat = TARGET, cvar = "outlineModeShowLootEffectWhenDisabled", on = "1", off = "0",
      name = "Loot sparkle without outlines",
      desc = "Keeps the lootable-corpse sparkle effect even when Outline Mode is turned off." },
    { cat = TARGET, cvar = "graphicsOutlineMode", on = "2", off = "0",
      name = "Outline mode (high)",
      desc = "Outlines the target, mouseover and quest objects." },
    { cat = TARGET, cvar = "lootUnderMouse", on = "1", off = "0",
      name = "Loot window at cursor",
      desc = "Opens the loot window where your mouse is." },
    { cat = TARGET, cvar = "autoLootDefault", on = "1", off = "0",
      name = "Auto loot",
      desc = "Loots everything automatically (hold the auto-loot key to invert)." },

    ---------------------------------------------------------------- Nameplates
    { cat = PLATES, cvar = "nameplateShowOnlyNames", on = "1", off = "0",
      name = "Friendly plates: names only",
      desc = "Friendly nameplates show only the name, no health bar.", reload = true },
    { cat = PLATES, cvar = "ShowClassColorInFriendlyNameplate", on = "1", off = "0",
      name = "Class colors on friendly plates",
      desc = "Colors friendly player names/plates by class." },
    { cat = PLATES, cvar = "ShowClassColorInNameplate", on = "1", off = "0",
      name = "Class colors on enemy plates",
      desc = "Colors enemy player nameplates by class." },
    { cat = PLATES, cvar = "nameplateMotion", on = "1", off = "0",
      name = "Stacking nameplates",
      desc = "Nameplates stack vertically instead of overlapping." },
    { cat = PLATES, cvar = "nameplateMaxDistance", on = "60", off = "41",
      name = "Long nameplate range (60 yd)",
      desc = "Raises nameplate view distance from the default to 60 yards." },
    { cat = PLATES, cvar = "nameplateShowEnemyMinions", on = "1", off = "0",
      name = "Enemy minion plates",
      desc = "Shows nameplates for enemy pets, totems and guardians." },

    ---------------------------------------------------------------- Camera
    { cat = CAMERA, cvar = "cameraDistanceMaxZoomFactor", on = "2.6", off = "1.9",
      name = "Max camera distance",
      desc = "Lets the camera zoom out much further than the options slider allows." },
    { cat = CAMERA, cvar = "test_cameraDynamicPitch", on = "1", off = "0",
      name = "ActionCam: dynamic pitch",
      desc = "Tilts the camera so your character sits lower on screen and you see more ahead.",
      experimental = true },
    { cat = CAMERA, cvar = "test_cameraOverShoulder", on = "1", off = "0",
      name = "ActionCam: over the shoulder",
      desc = "Offsets the camera to the side, like an over-the-shoulder action game.",
      experimental = true },
    { cat = CAMERA, cvar = "test_cameraTargetFocusEnemyEnable", on = "1", off = "0",
      name = "ActionCam: focus enemy target",
      desc = "Camera turns slightly to keep your enemy target in view.",
      experimental = true },
    { cat = CAMERA, cvar = "test_cameraHeadMovementStrength", on = "1", off = "0",
      name = "ActionCam: head bob",
      desc = "Camera follows your character's head movement.",
      experimental = true },
    { cat = CAMERA, cvar = "cameraIndirectVisibility", on = "1", off = "0",
      name = "Camera passes through objects",
      desc = "Camera doesn't snap in when trees, poles or small objects get in the way." },
    { cat = CAMERA, cvar = "ShakeStrengthCamera", on = "0", off = "1",
      name = "Disable camera shake",
      desc = "Removes screen shake from spells, bosses and explosions.",
      extra = { ShakeStrengthUI = { "0", "1" } } },

    ---------------------------------------------------------------- Graphics
    { cat = GFX, cvar = "ffxGlow", on = "1", off = "0",
      name = "Full-screen glow",
      desc = "The bloom/glow post-processing effect." },
    { cat = GFX, cvar = "ffxDeath", on = "1", off = "0",
      name = "Death desaturation",
      desc = "Grey screen effect while dead / as a ghost." },
    { cat = GFX, cvar = "ffxNether", on = "1", off = "0",
      name = "Nether / invisibility effect",
      desc = "Full-screen effect while invisible or phased." },
    { cat = GFX, cvar = "weatherDensity", on = "3", off = "0",
      name = "Max weather",
      desc = "Full-intensity rain, snow and sandstorms." },
    { cat = GFX, cvar = "violenceLevel", on = "5", off = "2",
      name = "Full blood effects",
      desc = "Raises blood splatter/violence effects to the maximum." },
    { cat = GFX, cvar = "screenshotQuality", on = "10", off = "3",
      name = "Max screenshot quality",
      desc = "Saves screenshots at maximum JPEG quality." },

    ---------------------------------------------------------------- Quality of life
    { cat = QOL, cvar = "showTutorials", on = "0", off = "1",
      name = "Hide tutorials",
      desc = "Stops the pop-up tutorial tips." },
    { cat = QOL, cvar = "showNPETutorials", on = "0", off = "1",
      name = "Hide new-player tutorials",
      desc = "Stops the new player experience help bubbles." },
    { cat = QOL, cvar = "alwaysCompareItems", on = "1", off = "0",
      name = "Always compare items",
      desc = "Shows the equipped-item comparison tooltip without holding Shift." },
    { cat = QOL, cvar = "autoDismountFlying", on = "1", off = "0",
      name = "Auto dismount when flying",
      desc = "Casting a spell while on a flying mount dismounts you automatically." },
    { cat = QOL, cvar = "autoUnshift", on = "1", off = "0",
      name = "Auto cancel shapeshift",
      desc = "Leaves a shapeshift form automatically when casting something that needs it." },
    { cat = QOL, cvar = "lootLeftmostBag", on = "1", off = "0",
      name = "Loot into leftmost bag",
      desc = "New loot goes into the leftmost bag first." },
    { cat = QOL, cvar = "reverseCleanupBags", on = "1", off = "0",
      name = "Reverse bag sort",
      desc = "Bag cleanup sorts items in the other direction." },
    { cat = QOL, cvar = "worldPreloadNonCritical", on = "0", off = "2",
      name = "Faster loading screens",
      desc = "Skips preloading non-critical world data, so loading screens end sooner." },

    ---------------------------------------------------------------- Sound
    { cat = SOUND, cvar = "Sound_EnableErrorSpeech", on = "0", off = "1",
      name = "Mute error voice lines",
      desc = "Silences 'Not enough rage', 'I can't do that yet' and similar voice lines." },
    { cat = SOUND, cvar = "Sound_EnableSoundWhenGameIsInBG", on = "1", off = "0",
      name = "Sound in background",
      desc = "Keeps game audio playing when the window isn't focused." },
    { cat = SOUND, cvar = "Sound_ListenerAtCharacter", on = "1", off = "0",
      name = "Hear from character",
      desc = "Positional audio is heard from your character rather than the camera." },
    { cat = SOUND, cvar = "Sound_EnableEmoteSounds", on = "1", off = "0",
      name = "Emote sounds",
      desc = "Plays voice sounds for emotes." },

    ---------------------------------------------------------------- Chat
    { cat = CHAT, cvar = "chatClassColorOverride", on = "0", off = "1",
      name = "Class-colored names in chat",
      desc = "Colors player names in chat by class." },
    { cat = CHAT, cvar = "profanityFilter", on = "0", off = "1",
      name = "Disable profanity filter",
      desc = "Turns off the chat language filter." },
    { cat = CHAT, cvar = "removeChatDelay", on = "1", off = "0",
      name = "No chat bubble delay",
      desc = "Removes the delay before chat text appears." },
    { cat = CHAT, cvar = "breakUpLargeNumbers", on = "1", off = "0",
      name = "Thousands separators",
      desc = "Shows large numbers as 1,234,567." },

    ---------------------------------------------------------------- Developer
    { cat = DEV, cvar = "scriptErrors", on = "1", off = "0",
      name = "Show Lua errors",
      desc = "Pops up a window when an addon or UI script errors." },
    { cat = DEV, cvar = "taintLog", on = "1", off = "0",
      name = "Taint log",
      desc = "Writes UI taint to Logs/taint.log — useful for debugging 'blocked action' errors." },
}

-- Apply Simplified Chinese names/descriptions/categories on Chinese clients (see Locale.lua).
if ns.IsChinese then
    for _, feat in ipairs(ns.Features) do
        local zh = ns.FeatureZH[feat.cvar]
        if zh then
            feat.name, feat.desc = zh[1], zh[2]
        end
        feat.cat = ns.CategoryZH[feat.cat] or feat.cat
    end
end
