-- Hidden Features: switchboard panel (Esc > Options > AddOns > Hidden Features, or /hf)
local ADDON, ns = ...
local HF = ns.HF
local L = ns.L

local ROW_H, HEADER_H = 26, 30
local panel, content, searchBox, category
local rows, headers = {}, {}

local function MatchesFilter(feat, filter)
    if filter == "" then return true end
    return (feat.name .. " " .. feat.cvar .. " " .. (feat.desc or "") .. " " .. feat.cat)
        :lower():find(filter, 1, true) ~= nil
end

local function ShowTooltip(row)
    local feat = row.feature
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(feat.name, 1, 1, 1)
    if feat.desc then GameTooltip:AddLine(feat.desc, nil, nil, nil, true) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L["CVar"], feat.cvar, 0.6, 0.6, 0.6, 1, 0.82, 0)
    GameTooltip:AddDoubleLine(L["Current"], tostring(HF:Get(feat.cvar)), 0.6, 0.6, 0.6, 1, 1, 1)
    GameTooltip:AddDoubleLine(L["On / Off"], feat.on .. " / " .. feat.off, 0.6, 0.6, 0.6, 1, 1, 1)
    if feat.extra then
        for cvar, v in pairs(feat.extra) do
            GameTooltip:AddDoubleLine("  " .. L["also %s"]:format(cvar), v[1] .. " / " .. v[2], 0.6, 0.6, 0.6, 0.8, 0.8, 0.8)
        end
    end
    if feat.reload then GameTooltip:AddLine(L["Needs /reload to fully apply."], 1, 0.5, 0.2) end
    if feat.experimental then GameTooltip:AddLine(L["Experimental: the client may show a warning popup."], 1, 0.5, 0.2) end
    if not row.exists then
        GameTooltip:AddLine(L["Not present in this client build."], 0.8, 0.3, 0.3)
    elseif row.locked then
        GameTooltip:AddLine(L["Locked by the client — cannot be changed."], 0.8, 0.3, 0.3)
    end
    GameTooltip:Show()
end

local function CreateRow(feat)
    local row = CreateFrame("Frame", nil, content)
    row:SetHeight(ROW_H)
    row.feature = feat

    local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("LEFT", 4, 0)
    cb:SetScript("OnClick", function(self)
        HF:SetFeature(feat, self:GetChecked())
    end)
    row.check = cb

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    label:SetText(feat.name)
    row.label = label

    local cvarText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    cvarText:SetPoint("LEFT", label, "RIGHT", 8, 0)
    cvarText:SetText(feat.cvar)
    row.cvarText = cvarText

    row:EnableMouse(true)
    row:SetScript("OnEnter", ShowTooltip)
    row:SetScript("OnLeave", GameTooltip_Hide)
    cb:SetScript("OnEnter", function() ShowTooltip(row) end)
    cb:SetScript("OnLeave", GameTooltip_Hide)
    return row
end

local function GetHeader(cat)
    if headers[cat] then return headers[cat] end
    local h = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    h:SetText(cat)
    headers[cat] = h
    return h
end

function HF:RefreshUI()
    if not panel or not panel:IsVisible() then return end
    local filter = searchBox and searchBox:GetText():lower() or ""
    local hideMissing = HiddenFeaturesDB.options.hideMissing

    for _, h in pairs(headers) do h:Hide() end

    local y, lastCat = -4, nil
    for i, feat in ipairs(ns.Features) do
        local row = rows[i]
        local exists, locked = HF:CVarStatus(feat.cvar)
        row.exists, row.locked = exists, locked

        if MatchesFilter(feat, filter) and (exists or not hideMissing) then
            if feat.cat ~= lastCat then
                local h = GetHeader(feat.cat)
                h:ClearAllPoints()
                h:SetPoint("TOPLEFT", 4, y - 6)
                h:Show()
                y = y - HEADER_H
                lastCat = feat.cat
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 10, y)
            row:SetPoint("RIGHT", content, "RIGHT", -4, 0)
            row:Show()
            y = y - ROW_H

            row.check:SetChecked(exists and HF:IsOn(feat))
            row.check:SetEnabled(exists and not locked)
            if exists and not locked then
                row.label:SetFontObject("GameFontHighlight")
            else
                row.label:SetFontObject("GameFontDisable")
            end
        else
            row:Hide()
        end
    end
    content:SetHeight(math.max(1, -y + 10))
end

local function MakeOptionCheck(parent, text, key, onChange)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    local fs = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    fs:SetText(text)
    cb:SetHitRectInsets(0, -fs:GetStringWidth() - 4, 0, 0)
    cb:SetScript("OnShow", function(self) self:SetChecked(HiddenFeaturesDB.options[key]) end)
    cb:SetScript("OnClick", function(self)
        HiddenFeaturesDB.options[key] = self:GetChecked() and true or false
        if onChange then onChange() end
    end)
    cb.label = fs
    return cb
end

function HF:CreateUI()
    if panel then return end

    panel = CreateFrame("Frame", "HiddenFeaturesPanel")
    panel.name = L["Hidden Features"]

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L["Hidden Features"])

    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    sub:SetPoint("RIGHT", -16, 0)
    sub:SetJustifyH("LEFT")
    sub:SetText(L["Built-in client features that are disabled and missing from the options menu. Greyed rows don't exist in this client build. Hover a row for details."])

    searchBox = CreateFrame("EditBox", nil, panel, "SearchBoxTemplate")
    searchBox:SetSize(200, 20)
    searchBox:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 6, -10)
    searchBox:HookScript("OnTextChanged", function() HF:RefreshUI() end)

    local reapply = MakeOptionCheck(panel, L["Re-apply on login"], "reapplyOnLogin")
    reapply:SetPoint("LEFT", searchBox, "RIGHT", 14, 0)

    local hideMissing = MakeOptionCheck(panel, L["Hide unavailable"], "hideMissing", function() HF:RefreshUI() end)
    hideMissing:SetPoint("LEFT", reapply.label, "RIGHT", 12, 0)

    local hidePopup = MakeOptionCheck(panel, L["Hide experimental warning"], "hideExperimentalPopup",
        function() HF:ApplyExperimentalPopupSetting() end)
    hidePopup:SetPoint("LEFT", hideMissing.label, "RIGHT", 12, 0)

    local restore = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    restore:SetSize(150, 22)
    restore:SetPoint("BOTTOMRIGHT", -16, 12)
    restore:SetText(L["Restore originals"])
    restore:SetScript("OnClick", function() StaticPopup_Show("HIDDENFEATURES_RESTORE") end)

    local reload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reload:SetSize(100, 22)
    reload:SetPoint("RIGHT", restore, "LEFT", -8, 0)
    reload:SetText(L["Reload UI"])
    reload:SetScript("OnClick", ReloadUI)

    local scroll = CreateFrame("ScrollFrame", "HiddenFeaturesScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -6, -10)
    scroll:SetPoint("BOTTOMRIGHT", restore, "TOPRIGHT", -24, 10)

    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnSizeChanged", function(self, w) content:SetWidth(w) end)

    for i, feat in ipairs(ns.Features) do
        rows[i] = CreateRow(feat)
    end

    panel:SetScript("OnShow", function() HF:RefreshUI() end)

    StaticPopupDialogs.HIDDENFEATURES_RESTORE = {
        text = L["Restore every setting Hidden Features changed to its previous value?"],
        button1 = YES, button2 = NO,
        OnAccept = function() HF:RestoreAll() end,
        timeout = 0, whileDead = true, hideOnEscape = true,
    }

    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

function HF:OpenUI()
    if not panel then self:CreateUI() end
    if category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
