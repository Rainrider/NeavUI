
local _, nTooltip = ...
local cfg = nTooltip.Config

local _G = _G
local select = select

local format = string.format

local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitExists = UnitExists
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitFactionGroup = UnitFactionGroup
local UnitCreatureType = UnitCreatureType
local GetQuestDifficultyColor = GetQuestDifficultyColor

local tankIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t'
local healIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t'
local damagerIcon = '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t'

-- _G.TOOLTIP_DEFAULT_BACKGROUND_COLOR = {r = 0, g = 0, b = 0}

    -- Some tooltip changes

if (cfg.fontOutline) then
    GameTooltipHeaderText:SetFont('Fonts\\ARIALN.ttf', (cfg.fontSize + 2), 'THINOUTLINE')
    GameTooltipHeaderText:SetShadowOffset(0, 0)

    GameTooltipText:SetFont('Fonts\\ARIALN.ttf', (cfg.fontSize), 'THINOUTLINE')
    GameTooltipText:SetShadowOffset(0, 0)

    GameTooltipTextSmall:SetFont('Fonts\\ARIALN.ttf', (cfg.fontSize), 'THINOUTLINE')
    GameTooltipTextSmall:SetShadowOffset(0, 0)
else
    GameTooltipHeaderText:SetFont('Fonts\\ARIALN.ttf', (cfg.fontSize + 2))
    GameTooltipText:SetFont('Fonts\\ARIALN.ttf', (cfg.fontSize))
    GameTooltipTextSmall:SetFont('Fonts\\ARIALN.ttf', (cfg.fontSize))
end

GameTooltipStatusBar:SetHeight(7)
GameTooltipStatusBar:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8x8'})
GameTooltipStatusBar:SetBackdropColor(0, 1, 0, 0.3)

local function ApplyTooltipStyle(self)
    local bgsize, bsize
    if (self == ConsolidatedBuffsTooltip) then
        bgsize = 1
        bsize = 8
    elseif (self == FriendsTooltip) then
        FriendsTooltip:SetScale(1.1)

        bgsize = 1
        bsize = 9
    else
        bgsize = 3
        bsize = 12
    end

    local edgeTexture
    if (not IsAddOnLoaded('!Beautycase')) then
        edgeTexture = 'Interface\\Tooltips\\UI-Tooltip-Border'
    else
        edgeTexture = nil
    end

    self:SetBackdrop({
        bgFile = 'Interface\\Buttons\\WHITE8x8',    -- 'Interface\\Tooltips\\UI-Tooltip-Background',
        edgeFile = edgeTexture,
        edgeSize = 15,

        insets = {
            left = bgsize, right = bgsize, top = bgsize, bottom = bgsize
        }
    })

    self:HookScript('OnShow', function(self)
        self:SetBackdropColor(0, 0, 0, 0.7)
    end)

    self:HookScript('OnHide', function(self)
        self:SetBackdropColor(0, 0, 0, 0.7)
    end)

    self:HookScript('OnUpdate', function(self)
        self:SetBackdropColor(0, 0, 0, 0.7)
    end)

    if (IsAddOnLoaded('!Beautycase')) then
        self:CreateBeautyBorder(bsize)
    end
end

for _, tooltip in pairs({
    GameTooltip,
    ItemRefTooltip,

    ShoppingTooltip1,
    ShoppingTooltip2,
    ShoppingTooltip3,

    WorldMapTooltip,

    DropDownList1MenuBackdrop,
    DropDownList2MenuBackdrop,

    ConsolidatedBuffsTooltip,

    ChatMenu,
    EmoteMenu,
    LanguageMenu,
    VoiceMacroMenu,

    FriendsTooltip,

    FloatingGarrisonFollowerTooltip,
    FloatingBattlePetTooltip,
}) do
    ApplyTooltipStyle(tooltip)
end

    -- Itemquaility border, we use our beautycase functions

if (cfg.itemqualityBorderColor) then
    for _, tooltip in pairs({
        GameTooltip,
        ItemRefTooltip,

        ShoppingTooltip1,
        ShoppingTooltip2,
        ShoppingTooltip3,
    }) do
        if (tooltip.beautyBorder) then
            tooltip:HookScript('OnTooltipSetItem', function(self)
                local name, item = self:GetItem()
                if (item) then
                    local quality = select(3, GetItemInfo(item))
                    if (quality) then
                        local r, g, b = GetItemQualityColor(quality)
                        self:SetBeautyBorderTexture('white')
                        self:SetBeautyBorderColor(r, g, b)
                    end
                end
            end)

            tooltip:HookScript('OnTooltipCleared', function(self)
                self:SetBeautyBorderTexture('default')
                self:SetBeautyBorderColor(1, 1, 1)
            end)
        end
    end
end

    -- Itemlvl (by Gsuz) - http://www.tukui.org/forums/topic.php?id=10151

local function GetItemLevel(unit)
    local total, item = 0, 0
    for i, v in pairs({
        'Head',
        'Neck',
        'Shoulder',
        'Back',
        'Chest',
        'Wrist',
        'Hands',
        'Waist',
        'Legs',
        'Feet',
        'Finger0',
        'Finger1',
        'Trinket0',
        'Trinket1',
        'MainHand',
        'SecondaryHand',
    }) do
        local slot = GetInventoryItemLink(unit, GetInventorySlotInfo(v..'Slot'))
        if (slot ~= nil) then
            item = item + 1
            total = total + select(4, GetItemInfo(slot))
        end
    end

    if (item > 0) then
        return floor(total / item + 0.5)
    end

    return 0
end

    -- Make sure we get a correct unit

local function GetRealUnit(self)
    if (GetMouseFocus() and not GetMouseFocus():GetAttribute('unit') and GetMouseFocus() ~= WorldFrame) then
        return select(2, self:GetUnit())
    elseif (GetMouseFocus() and GetMouseFocus():GetAttribute('unit')) then
        return GetMouseFocus():GetAttribute('unit')
    elseif (select(2, self:GetUnit())) then
        return select(2, self:GetUnit())
    else
        return 'mouseover'
    end
end

local function GetFormattedUnitType(unit)
    local creaturetype = UnitCreatureType(unit)
    if (creaturetype) then
        return creaturetype
    else
        return ''
    end
end

local function GetFormattedUnitClassification(unit)
    local class = UnitClassification(unit)
    if (class == 'worldboss') then
        return '|cffFF0000'..BOSS..'|r '
    elseif (class == 'rareelite') then
        return '|cffFF66CCRare|r |cffFFFF00'..ELITE..'|r '
    elseif (class == 'rare') then
        return '|cffFF66CCRare|r '
    elseif (class == 'elite') then
        return '|cffFFFF00'..ELITE..'|r '
    else
        return ''
    end
end

local function GetFormattedUnitLevel(unit)
    local diff = GetQuestDifficultyColor(UnitLevel(unit))
    if (UnitLevel(unit) == -1) then
        return '|cffff0000??|r '
    elseif (UnitLevel(unit) == 0) then
        return '? '
    else
        return format('|cff%02x%02x%02x%s|r ', diff.r*255, diff.g*255, diff.b*255, UnitLevel(unit))
    end
end

local function GetFormattedUnitClass(unit)
    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
    if (color) then
        return format(' |cff%02x%02x%02x%s|r', color.r*255, color.g*255, color.b*255, UnitClass(unit))
    end
end

local function GetFormattedUnitString(unit, specIcon)
    if (UnitIsPlayer(unit)) then
        if (not UnitRace(unit)) then
            return nil
        end
        return GetFormattedUnitLevel(unit)..UnitRace(unit)..GetFormattedUnitClass(unit)..(cfg.showSpecializationIcon and specIcon or '')
    else
        return GetFormattedUnitLevel(unit)..GetFormattedUnitClassification(unit)..GetFormattedUnitType(unit)
    end
end

local function GetUnitRoleString(unit)
    local role = UnitGroupRolesAssigned(unit)
    local roleList = nil

    if (role == 'TANK') then
        roleList = '   '..tankIcon..' '..TANK
    elseif (role == 'HEALER') then
        roleList = '   '..healIcon..' '..HEALER
    elseif (role == 'DAMAGER') then
        roleList = '   '..damagerIcon..' '..DAMAGER
    end

    return roleList
end

    -- Healthbar coloring funtion

local function SetHealthBarColor(unit)
    local r, g, b
    if (cfg.healthbar.customColor.apply and not cfg.healthbar.reactionColoring) then
        r, g, b = cfg.healthbar.customColor.r, cfg.healthbar.customColor.g, cfg.healthbar.customColor.b
    elseif (cfg.healthbar.reactionColoring and unit) then
        r, g, b = UnitSelectionColor(unit)
    else
        r, g, b = 0, 1, 0
    end

    GameTooltipStatusBar:SetStatusBarColor(r, g, b)
    GameTooltipStatusBar:SetBackdropColor(r, g, b, 0.3)
end

local function GetUnitRaidIcon(unit)
    local index = GetRaidTargetIndex(unit)

    if (index) then
        if (UnitIsPVP(unit) and cfg.showPVPIcons) then
            return ICON_LIST[index]..'11|t'
        else
            return ICON_LIST[index]..'11|t '
        end
    else
        return ''
    end
end

local function GetUnitPVPIcon(unit)
    local factionGroup = UnitFactionGroup(unit)

    if (UnitIsPVPFreeForAll(unit)) then
        if (cfg.showPVPIcons) then
            return '|TInterface\\AddOns\\nTooltip\\media\\UI-PVP-FFA:12|t'
        else
            return '|cffFF0000# |r'
        end
    elseif (factionGroup and UnitIsPVP(unit)) then
        if (cfg.showPVPIcons) then
            return '|TInterface\\AddOns\\nTooltip\\media\\UI-PVP-'..factionGroup..':12|t'
        else
            return '|cff00FF00# |r'
        end
    else
        return ''
    end
end

local function AddMouseoverTarget(self, unit)
    local unitTargetName = UnitName(unit..'target')
    local unitTargetClassColor = RAID_CLASS_COLORS[select(2, UnitClass(unit..'target'))] or { r = 1, g = 0, b = 1 }
    local unitTargetReactionColor = {
        r = select(1, UnitSelectionColor(unit..'target')),
        g = select(2, UnitSelectionColor(unit..'target')),
        b = select(3, UnitSelectionColor(unit..'target'))
    }

    if (UnitExists(unit..'target')) then
        if (UnitName('player') == unitTargetName) then
            self:AddLine(format('   '..GetUnitRaidIcon(unit..'target')..'|cffff00ff%s|r', string.upper(YOU)), 1, 1, 1)
        else
            if (UnitIsPlayer(unit..'target')) then
                self:AddLine(format('   '..GetUnitRaidIcon(unit..'target')..'|cff%02x%02x%02x%s|r', unitTargetClassColor.r*255, unitTargetClassColor.g*255, unitTargetClassColor.b*255, unitTargetName:sub(1, 40)), 1, 1, 1)
            else
                self:AddLine(format('   '..GetUnitRaidIcon(unit..'target')..'|cff%02x%02x%02x%s|r', unitTargetReactionColor.r*255, unitTargetReactionColor.g*255, unitTargetReactionColor.b*255, unitTargetName:sub(1, 40)), 1, 1, 1)
            end
        end
    end
end

GameTooltip.inspectCache = {}

GameTooltip:HookScript('OnTooltipSetUnit', function(self, ...)
    local unit = GetRealUnit(self)

    if (cfg.hideInCombat and InCombatLockdown()) then
        self:Hide()
        return
    end

    if (UnitExists(unit) and UnitName(unit) ~= UNKNOWN) then
        local ilvl = 0
        local specIcon = ''
        local lastUpdate = 30
        for index, _ in pairs(self.inspectCache) do
            local inspectCache = self.inspectCache[index]
            if (inspectCache.GUID == UnitGUID(unit)) then
                ilvl = inspectCache.itemLevel or 0
                specIcon = inspectCache.specIcon or ''
                lastUpdate = inspectCache.lastUpdate and math.abs(inspectCache.lastUpdate - math.floor(GetTime())) or 30
            end
        end

            -- Fetch inspect information (ilvl and spec)

        if (unit and CanInspect(unit)) then
            if (not self.inspectRefresh and lastUpdate >= 30 and not self.blockInspectRequests) then
                if (not self.blockInspectRequests) then
                    self.inspectRequestSent = true
                    NotifyInspect(unit)
                end
            end
        end

        self.inspectRefresh = false

        local name, realm = UnitName(unit)

            -- Hide player titles

        if (cfg.showPlayerTitles) then
            if (UnitPVPName(unit)) then
                name = UnitPVPName(unit)
            end
        end

        GameTooltipTextLeft1:SetText(name)

            -- Color guildnames

        if (GetGuildInfo(unit)) then
            if (GetGuildInfo(unit) == GetGuildInfo('player') and IsInGuild('player')) then
               GameTooltipTextLeft2:SetText('|cffFF66CC'..GameTooltipTextLeft2:GetText()..'|r')
            end
        end

            -- Tooltip level text

        for i = 2, GameTooltip:NumLines() do
            if (_G['GameTooltipTextLeft'..i]:GetText():find('^'..TOOLTIP_UNIT_LEVEL:gsub('%%s', '.+'))) then
                _G['GameTooltipTextLeft'..i]:SetText(GetFormattedUnitString(unit, specIcon))
            end
        end

            -- Role text

        if (cfg.showUnitRole) then
            self:AddLine(GetUnitRoleString(unit), 1, 1, 1)
        end

            -- Mouse over target with raidicon support

        if (cfg.showMouseoverTarget) then
            AddMouseoverTarget(self, unit)
        end

            -- Pvp flag prefix

        for i = 3, GameTooltip:NumLines() do
            if (_G['GameTooltipTextLeft'..i]:GetText():find(PVP_ENABLED)) then
                _G['GameTooltipTextLeft'..i]:SetText(nil)
                GameTooltipTextLeft1:SetText(GetUnitPVPIcon(unit)..GameTooltipTextLeft1:GetText())
            end
        end

            -- Raid icon, want to see the raidicon on the left

        GameTooltipTextLeft1:SetText(GetUnitRaidIcon(unit)..GameTooltipTextLeft1:GetText())

            -- Afk and dnd prefix

        if (UnitIsAFK(unit)) then
            self:AppendText('|cff00ff00 <AFK>|r')
        elseif (UnitIsDND(unit)) then
            self:AppendText('|cff00ff00 <DND>|r')
        end

            -- Player realm names

        if (realm and realm ~= '') then
            if (cfg.abbrevRealmNames)   then
                self:AppendText(' (*)')
            else
                self:AppendText(' - '..realm)
            end
        end

            -- Move the healthbar inside the tooltip

        if GameTooltipStatusBar:IsShown() then
            self:AddLine(' ')
            GameTooltipStatusBar:ClearAllPoints()
            GameTooltipStatusBar:SetPoint('LEFT', self:GetName()..'TextLeft'..self:NumLines(), 1, -3)
            GameTooltipStatusBar:SetPoint('RIGHT', self, -10, 0)
        end

            -- Border coloring

        if (cfg.reactionBorderColor and self.beautyBorder) then
            local r, g, b = UnitSelectionColor(unit)

            self:SetBeautyBorderTexture('white')
            self:SetBeautyBorderColor(r, g, b)
        end

            -- Dead or ghost recoloring

        if (UnitIsDead(unit) or UnitIsGhost(unit)) then
            GameTooltipStatusBar:SetBackdropColor(0.5, 0.5, 0.5, 0.3)
        else
            if (not cfg.healthbar.customColor.apply and not cfg.healthbar.reactionColoring) then
                GameTooltipStatusBar:SetBackdropColor(27/255, 243/255, 27/255, 0.3)
            else
                SetHealthBarColor(unit)
            end
        end
    end
end)

GameTooltip:HookScript('OnTooltipCleared', function(self)
    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0.5, 3)
    GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -1, 3)
    GameTooltipStatusBar:SetBackdropColor(0, 1, 0, 0.3)

    if (cfg.reactionBorderColor and self.beautyBorder) then
        self:SetBeautyBorderTexture('default')
        self:SetBeautyBorderColor(1, 1, 1)
    end
end)

    -- Custom healthbar coloring

if (cfg.healthbar.reactionColoring or cfg.healthbar.customColor.apply) then
    GameTooltipStatusBar:HookScript('OnValueChanged', function(self)
        local unit = GetRealUnit(self:GetParent())
        SetHealthBarColor(unit)
    end)
end

    -- Hide coalesced/interactive realm information

if (cfg.hideRealmText) then
    local COALESCED_REALM_TOOLTIP1 = string.split(FOREIGN_SERVER_LABEL, COALESCED_REALM_TOOLTIP)
    local INTERACTIVE_REALM_TOOLTIP1 = string.split(INTERACTIVE_SERVER_LABEL, INTERACTIVE_REALM_TOOLTIP)
    -- Dirty checking of the coalesced realm text because it's added
    -- after the initial OnShow
    GameTooltip:HookScript('OnUpdate', function(self)
        for i = 3, self:NumLines() do
            local row = _G['GameTooltipTextLeft'..i]
            local rowText = row:GetText()

            if (rowText) then
                if (rowText:find(COALESCED_REALM_TOOLTIP1) or rowText:find(INTERACTIVE_REALM_TOOLTIP1)) then
                    row:SetText(nil)
                    row:Hide()

                    local previousRow = _G['GameTooltipTextLeft'..(i - 1)]
                    previousRow:SetText(nil)
                    previousRow:Hide()

                    self:Show()
                end
            end
        end
    end)
end

hooksecurefunc('GameTooltip_SetDefaultAnchor', function(self, parent)
    if (cfg.showOnMouseover) then
        self:SetOwner(parent, 'ANCHOR_CURSOR')
    else
        self:SetOwner(parent, 'ANCHOR_NONE')
        self:ClearAllPoints()
        self:SetPoint(unpack(cfg.position))
    end
end)


GameTooltip:RegisterEvent('INSPECT_READY')
GameTooltip:SetScript('OnEvent', function(self, event, GUID)
    if (not self:IsShown()) then
        return
    end

    local _, unit = self:GetUnit()

    if (not unit) then
        return
    end

    if (self.blockInspectRequests) then
        self.inspectRequestSent = false
    end

    if (UnitGUID(unit) ~= GUID or not self.inspectRequestSent) then
        if (not self.blockInspectRequests) then
            ClearInspectPlayer()
        end
        return
    end

    local _, _, _, icon = GetSpecializationInfoByID(GetInspectSpecialization(unit))
    local now = GetTime()

    local matchFound
    for index, _ in pairs(self.inspectCache) do
        local inspectCache = self.inspectCache[index]
        if (inspectCache.GUID == GUID) then
            inspectCache.specIcon = icon and ' |T'..icon..':0|t' or ''
            inspectCache.lastUpdate = math.floor(now)
            matchFound = true
        end
    end

    if not matchFound then
        local GUIDInfo = {
            ['GUID'] = GUID,
            ['specIcon'] = icon and ' |T'..icon..':0|t' or '',
            ['lastUpdate'] = math.floor(now)
        }
        table.insert(self.inspectCache, GUIDInfo)
    end

    if (#self.inspectCache > 30) then
        table.remove(self.inspectCache, 1)
    end

    self.inspectRefresh = true
    GameTooltip:SetUnit('mouseover')

    if (not self.blockInspectRequests) then
        ClearInspectPlayer()
    end
    self.inspectRequestSent = false
end)

local f = CreateFrame('Frame')
f:RegisterEvent('ADDON_LOADED')
f:SetScript('OnEvent', function(self, event)
    if IsAddOnLoaded('Blizzard_InspectUI') then
        hooksecurefunc('InspectFrame_Show', function(unit)
            GameTooltip.blockInspectRequests = true
        end)

        InspectFrame:HookScript('OnHide', function()
            GameTooltip.blockInspectRequests = false
        end)

        self:UnregisterEvent('ADDON_LOADED')
    end
end)
