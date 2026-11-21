-- Hidden Features: core logic (CVar access, persistence, slash commands)
local ADDON, ns = ...

local L = ns.L
local HF = {}
ns.HF = HF
_G.HiddenFeatures = HF

local GetCVar  = (C_CVar and C_CVar.GetCVar) or GetCVar
local SetCVar  = (C_CVar and C_CVar.SetCVar) or SetCVar
local CVarInfo = (C_CVar and C_CVar.GetCVarInfo) or GetCVarInfo

local PREFIX = "|cff33ff99" .. L["Hidden Features"] .. "|r: "
local function Print(...) print(PREFIX .. string.join(" ", tostringall(...))) end
HF.Print = Print

-- Writes that failed because of combat lockdown; flushed on PLAYER_REGEN_ENABLED.
local pending = {}

---------------------------------------------------------------------------
-- CVar helpers
---------------------------------------------------------------------------

-- Returns exists, locked (read-only / locked from user)
function HF:CVarStatus(cvar)
    local value, _, _, _, isLocked, isSecure, isReadOnly = CVarInfo(cvar)
    if value == nil then return false, false, false end
    return true, (isLocked or isReadOnly) and true or false, isSecure and true or false
end

function HF:Get(cvar)
    return GetCVar(cvar)
end

local function same(a, b)
    if a == nil or b == nil then return false end
    local na, nb = tonumber(a), tonumber(b)
    if na and nb then return math.abs(na - nb) < 1e-4 end
    return tostring(a):lower() == tostring(b):lower()
end
HF.Same = same

function HF:IsOn(feature)
    return same(GetCVar(feature.cvar), feature.on)
end

-- Low-level write; remembers the user's original value the first time we touch a CVar.
function HF:Set(cvar, value, silent)
    value = tostring(value)
    local exists, locked, secure = self:CVarStatus(cvar)
    if not exists then
        if not silent then Print(L["CVar '%s' does not exist in this client."]:format(cvar)) end
        return false
    end
    if locked then
        if not silent then Print(L["CVar '%s' is locked by the client."]:format(cvar)) end
        return false
    end

    local db = HiddenFeaturesDB
    if db.original[cvar] == nil then
        db.original[cvar] = GetCVar(cvar)
    end
    db.applied[cvar] = value

    if secure and InCombatLockdown() then
        pending[cvar] = value
        if not silent then Print(L["%s will be applied after combat."]:format(cvar)) end
        return true
    end

    SetCVar(cvar, value)
    return true
end

function HF:SetFeature(feature, enabled)
    local ok = self:Set(feature.cvar, enabled and feature.on or feature.off, true)
    if ok and feature.extra then
        for cvar, values in pairs(feature.extra) do
            self:Set(cvar, enabled and values[1] or values[2], true)
        end
    end
    if ok and feature.reload then
        Print(L["%s: takes full effect after /reload."]:format(feature.name))
    end
    if self.RefreshUI then self:RefreshUI() end
    return ok
end

-- Restore every CVar this addon ever changed back to what it was before.
function HF:RestoreAll()
    local n = 0
    for cvar, value in pairs(HiddenFeaturesDB.original) do
        if CVarInfo(cvar) ~= nil then
            SetCVar(cvar, value)
            n = n + 1
        end
    end
    wipe(HiddenFeaturesDB.original)
    wipe(HiddenFeaturesDB.applied)
    Print(L["Restored %d setting(s) to their previous values."]:format(n))
    if self.RefreshUI then self:RefreshUI() end
end

-- Some hidden CVars get reset by the server / character profile on login.
-- Re-apply what the user chose so the switches stick.
function HF:ReapplyAll()
    for cvar, value in pairs(HiddenFeaturesDB.applied) do
        local exists, locked, secure = self:CVarStatus(cvar)
        if exists and not locked and not same(GetCVar(cvar), value) then
            if secure and InCombatLockdown() then
                pending[cvar] = value
            else
                SetCVar(cvar, value)
            end
        end
    end
end

function HF:ApplyExperimentalPopupSetting()
    if not UIParent then return end
    if HiddenFeaturesDB.options.hideExperimentalPopup then
        UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED")
    else
        UIParent:RegisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED")
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        HiddenFeaturesDB = HiddenFeaturesDB or {}
        local db = HiddenFeaturesDB
        db.original = db.original or {}
        db.applied  = db.applied  or {}
        db.options  = db.options  or {}
        if db.options.reapplyOnLogin == nil then db.options.reapplyOnLogin = true end
        if db.options.hideExperimentalPopup == nil then db.options.hideExperimentalPopup = false end
    elseif event == "PLAYER_LOGIN" then
        HF:ApplyExperimentalPopupSetting()
        if HiddenFeaturesDB.options.reapplyOnLogin then
            -- small delay: some CVars are pushed from the server right after login
            C_Timer.After(2, function() HF:ReapplyAll() end)
        end
        if HF.CreateUI then HF:CreateUI() end
    elseif event == "PLAYER_REGEN_ENABLED" then
        for cvar, value in pairs(pending) do
            SetCVar(cvar, value)
        end
        wipe(pending)
        if HF.RefreshUI then HF:RefreshUI() end
    end
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------

local function FindFeature(key)
    key = key:lower()
    for _, feat in ipairs(ns.Features) do
        if feat.cvar:lower() == key then return feat end
    end
end

local HELP = {
    L["/hf  - open the switchboard"],
    L["/hf list  - print every feature and its state"],
    L["/hf on <cvar> | /hf off <cvar>  - toggle a catalog feature"],
    L["/hf get <cvar>  - show any CVar's current/default value"],
    L["/hf set <cvar> <value>  - set any CVar (remembered and re-applied)"],
    L["/hf restore  - put every changed CVar back how it was"],
}

SLASH_HIDDENFEATURES1 = "/hf"
SLASH_HIDDENFEATURES2 = "/hiddenfeatures"
SlashCmdList.HIDDENFEATURES = function(msg)
    local cmd, a, b = strsplit(" ", strtrim(msg or ""), 3)
    cmd = (cmd or ""):lower()

    if cmd == "" then
        HF:OpenUI()
    elseif cmd == "help" then
        for _, line in ipairs(HELP) do Print(line) end
    elseif cmd == "list" then
        for _, feat in ipairs(ns.Features) do
            local exists = HF:CVarStatus(feat.cvar)
            local state = not exists and ("|cff888888" .. L["n/a"] .. "|r")
                or (HF:IsOn(feat) and ("|cff00ff00" .. L["ON"] .. "|r") or ("|cffff4040" .. L["off"] .. "|r"))
            Print(state, feat.cvar, "-", feat.name)
        end
    elseif (cmd == "on" or cmd == "off") and a then
        local feat = FindFeature(a)
        if not feat then return Print(L["Not in catalog: %s (use /hf set)"]:format(a)) end
        if HF:SetFeature(feat, cmd == "on") then
            Print((cmd == "on" and L["%s enabled."] or L["%s disabled."]):format(feat.name))
        end
    elseif cmd == "get" and a then
        local value, default = CVarInfo(a)
        if value == nil then return Print(L["CVar '%s' does not exist in this client."]:format(a)) end
        Print(L["%s = %s (default %s)"]:format(a, tostring(value), tostring(default)))
    elseif cmd == "set" and a and b then
        if HF:Set(a, b) then
            Print(L["%s set to %s"]:format(a, b))
            if HF.RefreshUI then HF:RefreshUI() end
        end
    elseif cmd == "restore" then
        HF:RestoreAll()
    else
        for _, line in ipairs(HELP) do Print(line) end
    end
end
