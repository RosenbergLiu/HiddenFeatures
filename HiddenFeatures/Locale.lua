-- Hidden Features: localization.
-- Any Chinese client (zhCN, zhTW — which covers Taiwan and Hong Kong) gets Simplified Chinese;
-- every other locale gets English.
local _, ns = ...

local locale = GetLocale()
ns.IsChinese = (locale == "zhCN" or locale == "zhTW")

-- English is the key; missing translations fall back to the key itself.
local L = setmetatable({}, { __index = function(_, key) return key end })
ns.L = L

-- Per-feature translations, keyed by CVar: { name, desc }. Applied in Features.lua.
ns.FeatureZH = {}
ns.CategoryZH = {}

if not ns.IsChinese then return end

---------------------------------------------------------------------------
-- UI / messages
---------------------------------------------------------------------------
L["Hidden Features"] = "隐藏功能"
L["Built-in client features that are disabled and missing from the options menu. Greyed rows don't exist in this client build. Hover a row for details."] =
    "客户端内置但默认关闭、且不在设置菜单中的功能。灰色的条目在当前客户端中不存在。鼠标悬停查看详情。"
L["Re-apply on login"] = "登录时重新应用"
L["Hide unavailable"] = "隐藏不可用项"
L["Hide experimental warning"] = "隐藏实验性功能警告"
L["Restore originals"] = "恢复原始设置"
L["Reload UI"] = "重载界面"
L["Restore every setting Hidden Features changed to its previous value?"] = "将隐藏功能修改过的所有设置恢复为原来的值？"

L["CVar"] = "控制台变量"
L["Current"] = "当前值"
L["On / Off"] = "开 / 关"
L["also %s"] = "同时设置 %s"
L["Needs /reload to fully apply."] = "需要 /reload 才能完全生效。"
L["Experimental: the client may show a warning popup."] = "实验性功能：客户端可能会弹出警告。"
L["Not present in this client build."] = "当前客户端版本中不存在此功能。"
L["Locked by the client — cannot be changed."] = "已被客户端锁定，无法修改。"

L["CVar '%s' does not exist in this client."] = "控制台变量 '%s' 在当前客户端中不存在。"
L["CVar '%s' is locked by the client."] = "控制台变量 '%s' 已被客户端锁定。"
L["%s will be applied after combat."] = "%s 将在脱离战斗后应用。"
L["%s: takes full effect after /reload."] = "%s：需要 /reload 后才能完全生效。"
L["Restored %d setting(s) to their previous values."] = "已将 %d 项设置恢复为原来的值。"
L["Not in catalog: %s (use /hf set)"] = "列表中没有：%s（请使用 /hf set）"
L["%s enabled."] = "%s 已开启。"
L["%s disabled."] = "%s 已关闭。"
L["%s = %s (default %s)"] = "%s = %s（默认 %s）"
L["%s set to %s"] = "%s 已设为 %s"
L["n/a"] = "不可用"
L["ON"] = "开"
L["off"] = "关"

L["/hf  - open the switchboard"] = "/hf  - 打开功能开关面板"
L["/hf list  - print every feature and its state"] = "/hf list  - 列出所有功能及其状态"
L["/hf on <cvar> | /hf off <cvar>  - toggle a catalog feature"] = "/hf on <变量> | /hf off <变量>  - 开启或关闭列表中的功能"
L["/hf get <cvar>  - show any CVar's current/default value"] = "/hf get <变量>  - 查看任意控制台变量的当前值和默认值"
L["/hf set <cvar> <value>  - set any CVar (remembered and re-applied)"] = "/hf set <变量> <值>  - 设置任意控制台变量（会被记住并在登录时重新应用）"
L["/hf restore  - put every changed CVar back how it was"] = "/hf restore  - 将所有修改过的变量恢复原样"

---------------------------------------------------------------------------
-- Categories
---------------------------------------------------------------------------
local C = ns.CategoryZH
C["Navigation & Map"]      = "导航与地图"
C["Combat & Action Bars"]  = "战斗与动作条"
C["Targeting & Interaction"] = "目标与交互"
C["Nameplates"]            = "姓名板"
C["Camera"]                = "镜头"
C["Graphics & Effects"]    = "图形与特效"
C["Quality of Life"]       = "便利功能"
C["Sound"]                 = "声音"
C["Chat & Text"]           = "聊天与文字"
C["Developer"]             = "开发者"

---------------------------------------------------------------------------
-- Features
---------------------------------------------------------------------------
local F = ns.FeatureZH
-- Navigation & Map
F.showInGameNavigation = { "游戏内导航", "为追踪的任务或地图标记显示悬浮导航指示和距离。" }
F.showDungeonEntrancesOnMap = { "地图显示副本入口", "在世界地图上标出地下城和团队副本入口。" }
F.questPOI = { "任务目标区域", "在世界地图和小地图上显示任务目标区域。" }
F.showQuestTrackingTooltips = { "鼠标提示显示任务信息", "在任务怪物和物品的鼠标提示中显示任务进度。" }
F.autoQuestWatch = { "自动追踪新任务", "新接的任务自动加入任务追踪栏。" }
F.mapFade = { "移动时地图淡化", "角色移动时世界地图变为半透明。" }
F.minimapTrackingShowAll = { "显示所有小地图追踪类型", "在小地图追踪菜单中列出全部追踪类型。" }
-- Combat & Action Bars
F.assistedCombatHighlight = { "辅助战斗高亮", "在动作条上高亮推荐的下一个技能（正式服输出循环助手）。" }
F.cooldownViewerEnabled = { "冷却管理器", "启用正式服内置的冷却追踪条/图标，可在编辑模式中设置。" }
F.damageMeterEnabled = { "内置伤害统计", "启用客户端自带的伤害/治疗统计（如果当前版本包含）。" }
F.countdownForCooldowns = { "按钮冷却数字", "在动作按钮上以数字显示剩余冷却时间，无需 OmniCC。" }
F.displaySpellActivationOverlays = { "法术触发提示", "在角色周围显示技能触发提示，并让动作按钮发光。" }
F.ActionButtonUseKeyDown = { "按下按键时施法", "按下按键时立即施放技能，而不是松开时。" }
F.AutoPushSpellToActionBar = { "不自动放置新技能", "新学会的技能不再自动放到动作条上。" }
F.floatingCombatTextCombatDamageDirectionalScale = { "定向伤害数字", "伤害数字沿受击方向飞离目标。" }
F.findYourselfMode = { "自身高亮：光圈+轮廓", "在角色身上显示光圈和轮廓，方便在混乱的战斗中找到自己。" }
F.findYourselfAnywhere = { "任何地方自身高亮", "在野外也启用自身高亮，而不仅限于队伍/副本中。" }
F.occludedSilhouettePlayer = { "被遮挡时显示轮廓", "角色被墙壁或物体挡住时显示轮廓。" }
-- Targeting & Interaction
F.SoftTargetInteract = { "软目标交互", "使用交互键拾取、对话NPC和使用面前的物体。请在按键设置中绑定“与目标互动”。" }
F.SoftTargetEnemy = { "软目标敌人", "没有选中目标时，技能自动施放给你面对的敌人。" }
F.SoftTargetFriend = { "软目标友方", "没有选中目标时，增益法术自动施放给你面对的友方玩家。" }
F.SoftTargetNameplateInteract = { "交互目标显示名字", "在当前软交互目标上方显示姓名板/名字。" }
F.outlineModeShowLootEffectWhenDisabled = { "关闭轮廓时保留拾取闪光", "即使关闭轮廓模式，可拾取尸体仍显示闪光效果。" }
F.graphicsOutlineMode = { "轮廓模式（高）", "为目标、鼠标指向和任务物品显示轮廓。" }
F.lootUnderMouse = { "拾取窗口跟随鼠标", "在鼠标位置打开拾取窗口。" }
F.autoLootDefault = { "自动拾取", "自动拾取所有物品（按住自动拾取键可反转）。" }
-- Nameplates
F.nameplateShowOnlyNames = { "友方姓名板仅显示名字", "友方姓名板只显示名字，不显示血条。" }
F.ShowClassColorInFriendlyNameplate = { "友方姓名板职业颜色", "按职业为友方玩家的名字/姓名板着色。" }
F.ShowClassColorInNameplate = { "敌方姓名板职业颜色", "按职业为敌方玩家的姓名板着色。" }
F.nameplateMotion = { "堆叠姓名板", "姓名板垂直堆叠排列，而不是互相重叠。" }
F.nameplateMaxDistance = { "远距离姓名板（60码）", "将姓名板显示距离从默认值提高到60码。" }
F.nameplateShowEnemyMinions = { "敌方仆从姓名板", "显示敌方宠物、图腾和守护者的姓名板。" }
-- Camera
F.cameraDistanceMaxZoomFactor = { "最大镜头距离", "让镜头可以拉得比设置滑块允许的更远。" }
F.test_cameraDynamicPitch = { "动作镜头：动态俯仰", "调整镜头角度，让角色位于画面偏下方，看到更多前方视野。" }
F.test_cameraOverShoulder = { "动作镜头：越肩视角", "镜头向一侧偏移，类似越肩视角的动作游戏。" }
F.test_cameraTargetFocusEnemyEnable = { "动作镜头：聚焦敌方目标", "镜头会轻微转动，让敌方目标保持在视野中。" }
F.test_cameraHeadMovementStrength = { "动作镜头：头部跟随", "镜头跟随角色头部的动作。" }
F.cameraIndirectVisibility = { "镜头穿过物体", "树木、柱子等小物体挡住时镜头不会突然拉近。" }
F.ShakeStrengthCamera = { "关闭镜头震动", "移除技能、首领和爆炸带来的画面震动。" }
-- Graphics & Effects
F.ffxGlow = { "全屏泛光", "全屏泛光/辉光后期处理效果。" }
F.ffxDeath = { "死亡灰屏效果", "死亡或灵魂状态时的灰色画面效果。" }
F.ffxNether = { "虚空/隐身效果", "隐身或相位时的全屏效果。" }
F.weatherDensity = { "最高天气效果", "最大强度的雨、雪和沙尘暴。" }
F.violenceLevel = { "完整血腥效果", "将血液飞溅等暴力效果调到最高。" }
F.screenshotQuality = { "最高截图质量", "以最高 JPEG 质量保存截图。" }
-- Quality of Life
F.showTutorials = { "隐藏教程", "不再弹出教程提示。" }
F.showNPETutorials = { "隐藏新手教程", "不再显示新手引导的帮助气泡。" }
F.alwaysCompareItems = { "始终对比物品", "无需按住 Shift 即可显示已装备物品的对比提示。" }
F.autoDismountFlying = { "飞行时自动下坐骑", "骑乘飞行坐骑时施法会自动下坐骑。" }
F.autoUnshift = { "自动取消变形", "施放需要人形的技能时自动退出变形形态。" }
F.lootLeftmostBag = { "拾取到最左侧背包", "新拾取的物品优先放入最左侧的背包。" }
F.reverseCleanupBags = { "反向整理背包", "整理背包时按相反方向排列物品。" }
F.worldPreloadNonCritical = { "加快读取画面", "跳过预加载非关键的世界数据，让读取画面更快结束。" }
-- Sound
F.Sound_EnableErrorSpeech = { "静音错误语音", "关闭“怒气不足”“我还不能这么做”之类的语音。" }
F.Sound_EnableSoundWhenGameIsInBG = { "后台播放声音", "游戏窗口不在前台时继续播放声音。" }
F.Sound_ListenerAtCharacter = { "以角色位置收听", "立体声以角色位置为准，而不是镜头位置。" }
F.Sound_EnableEmoteSounds = { "表情声音", "使用表情时播放语音。" }
-- Chat & Text
F.chatClassColorOverride = { "聊天中职业颜色名字", "在聊天中按职业为玩家名字着色。" }
F.profanityFilter = { "关闭语言过滤", "关闭聊天的不文明用语过滤。" }
F.removeChatDelay = { "取消聊天延迟", "去除聊天文字出现前的延迟。" }
F.breakUpLargeNumbers = { "数字千位分隔", "大数字显示为 1,234,567 的格式。" }
-- Developer
F.scriptErrors = { "显示 Lua 错误", "插件或界面脚本出错时弹出错误窗口。" }
F.taintLog = { "污染日志", "将界面污染记录写入 Logs/taint.log，可用于排查“动作被阻止”错误。" }
