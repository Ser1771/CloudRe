--// Cloudy Revolution UI Library (based on Obsidian) \\--
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    Name = "Cloudy Revolution",
    Version = "1.4",

    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {}, 

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = false, -- no custom cursor
    ElementGlow = true, -- soft UIShadow behind element cards
    ElementShadows = setmetatable({}, { __mode = "k" }),
    RowCards = setmetatable({}, { __mode = "k" }),
    TextScale = 1,
    AmbientGlow = true, -- soft accent light at the top of the window
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 24,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(14, 15, 18),
        MainColor = Color3.fromRGB(26, 28, 33),
        AccentColor = Color3.fromRGB(33, 128, 230),
        OutlineColor = Color3.fromRGB(40, 43, 50),
        FontColor = Color3.fromRGB(240, 243, 248),
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Subtitle = "",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(860, 580),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        CornerRadius = 24,
        NotifySide = "Right",
        ShowCustomCursor = false,

        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false,
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom",
        TabButtonsStyle = {
            Gap = 6,
            Padding = 10,
            CornerRadius = 14,
            Indicator = true,
            IndicatorWidth = 3,
            IndicatorHeight = 18,
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,
        KeepDisabledValuePosition = false,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
    full = 3, -- single (full width) groupbox
    single = 3,
    both = 3,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Fuzzy Search \\--
local function FuzzyScore(Text: string, Search: string): (boolean, number)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    --// Fast path: literal substring match (also the best possible score) \\--
    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    --// Fallback: fuzzy, in-order, non-consecutive character matching \\--
    local TextLen, SearchLen = Text:len(), Search:len()
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if Text:sub(TextIdx, TextIdx) == Search:sub(SearchIdx, SearchIdx) then
            local PrevChar = TextIdx > 1 and Text:sub(TextIdx - 1, TextIdx - 1) or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 --// Not every Search character was found, in order
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05 --// Slightly favour tighter matches
    return true, Score
end

local function NormalizeSearch(Search: string): string
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text: any, Search: string): (boolean, number)
    if typeof(Text) ~= "string" or Text == "" then
        return false, 0
    end

    return FuzzyScore(Text:lower(), Search)
end

local function FuzzyMatchScore(Text: any, Search: string): number
    if typeof(Text) ~= "string" or Text == "" then
        return 0
    end

    local Normalized = NormalizeSearch(Text:lower())
    local Matched, Score = FuzzyScore(Normalized, Search)
    if not Matched then
        return 0
    end

    if Normalized == Search then
        Score += 1000
    end

    return Score
end

local function MatchesSearch(ElementInfo, Search: string, ForceMatch: boolean?): boolean
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end

    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Description, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end

    --// Optional: search inside Dropdown value lists, so e.g. searching a specific option name reveals the Dropdown that contains it \\--
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end

            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end

    return false
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.UpdateRules then
        Library:UpdateRules()
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

function Library:UpdateAddons(Parent)
    if not Parent or not Parent.Addons then
        return
    end

    for _, Addon in Parent.Addons do
        Addon:Update()
    end
end

local function CheckDepbox(Box, Search, ForceVisible: boolean?)
    local VisibleElements = 0
    local BestScore = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        local DepVisible, DepScore = CheckDepbox(Depbox, Search, ForceVisible)
        VisibleElements += DepVisible
        if DepScore > BestScore then
            BestScore = DepScore
        end
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements, BestScore
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    Box:Resize()
    Box.Holder.Visible = true

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        RestoreDepbox(Depbox)
    end
end

--// Pop Out
function SyncPopOutVisibility(Box: any)
    if not Box.PopOutFloat then
        return
    end

    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function DimPopOutClone(Root: GuiObject)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point: Vector2): boolean
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end

    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point: Vector2): GuiObject?
    local Best: GuiObject? = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end

        local SiblingIndex = tonumber(select(2, pcall(function() return Surface:GetSiblingIndex() end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end

    return Best
end

local function GetPopOutBodyMaxHeight(Box: any, Reserved: number): number
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end

    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)
    local ScreenMax = math.max(0, Available / Library.DPIScale - Reserved)

    local CustomMax = Box.PopOutMaxHeight
    if typeof(CustomMax) == "number" then
        return math.min(ScreenMax, math.max(0, CustomMax))
    end

    return ScreenMax
end

--// Search
local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return false, 0
    end

    local HasVisible = false
    local BestScore = 0

    --// If the Tab itself matches Search (by name/description), don't filter out its contents -- pull everything in the Tab along with it \\--
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    BestScore = math.max(BestScore, FuzzyMatchScore(Tab.Name, Search), FuzzyMatchScore(Tab.Description, Search))

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        --// Optional: matching the Groupbox's own name/description reveals every element inside it, without needing each one to match too
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        BestScore = math.max(BestScore, FuzzyMatchScore(Groupbox.Name, Search), FuzzyMatchScore(Groupbox.Description, Search))

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
                else
                    ElementInfo.Base.Visible = false
                end

                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
                else
                    ElementInfo.SubButton.Base.Visible = false
                end

                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            local DepVisible, DepScore = CheckDepbox(Depbox, Search, GroupboxMatches)
            VisibleElements += DepVisible
            if DepScore > BestScore then
                BestScore = DepScore
            end
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}
        local SubTabScores = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            --// Optional: matching a Tabbox sub-tab's own name reveals every element inside it, without needing each one to match too
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)
            local SubScore = FuzzyMatchScore(SubTab.Name, Search)
            BestScore = math.max(BestScore, SubScore)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.Base.Visible = false
                    end

                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.SubButton.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end

                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                    local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                    SubScore = math.max(SubScore, ElementScore)
                    BestScore = math.max(BestScore, ElementScore)
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                local DepVisible, DepScore = CheckDepbox(Depbox, Search, SubTabMatches)
                VisibleElements[SubTab] += DepVisible
                SubScore = math.max(SubScore, DepScore)
                BestScore = math.max(BestScore, DepScore)
            end

            SubTabScores[SubTab] = SubScore
        end

        local BestSubTab = nil
        local BestSubScore = -1

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                local SubScore = SubTabScores[SubTab] or 0
                if SubScore > BestSubScore then
                    BestSubScore = SubScore
                    BestSubTab = SubTab
                end
            end
        end

        local ActiveSubTab = Tabbox.ActiveTab
        local ActiveSubVisible = ActiveSubTab and (VisibleElements[ActiveSubTab] or 0) > 0
        local ActiveSubScore = ActiveSubTab and (SubTabScores[ActiveSubTab] or -1) or -1

        if ActiveSubVisible and ActiveSubScore >= BestSubScore then
            ActiveSubTab:Resize()
        elseif BestSubTab then
            BestSubTab:Show()
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    return HasVisible, BestScore
end
local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToSearch = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and not Tab.IsKeyTab then
            table.insert(TabsToSearch, Tab)
        end
    end

    for _, Tab in TabsToSearch do
        ResetTab(Tab)
    end

    local Search = NormalizeSearch(SearchText:lower())
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local BestTab = nil
    local BestScore = -1
    local ActiveScore = -1
    local ActiveHasVisible = false

    for _, Tab in TabsToSearch do
        local HasVisible, Score = ApplySearchToTab(Tab, Search)
        if not HasVisible then
            continue
        end

        if Tab == Library.ActiveTab then
            ActiveHasVisible = true
            ActiveScore = Score
        end
        if Score > BestScore then
            BestScore = Score
            BestTab = Tab
        end
    end

    if not Library.GlobalSearch then
        for _, Tab in TabsToSearch do
            if Tab ~= BestTab then
                ResetTab(Tab)
            end
        end
    end

    local StayOnActive = ActiveHasVisible and ActiveScore >= BestScore
    if StayOnActive and Library.ActiveTab then
        Library.ActiveTab:RefreshSides()
    elseif BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            if Library.SearchText ~= SearchMarker then
                return
            end

            if Library.ActiveTab ~= BestTab then
                BestTab:Show()
            elseif Library.ActiveTab then
                Library.ActiveTab:RefreshSides()
            end
        end)
    end

    Library.LastSearchTab = nil
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

--// Built-in icon registry. Use Icon = "provider:icon-name", e.g. "lucide:target", "tabler:eye", "phosphor:sword" \\--
--// Providers: lucide, tabler, heroicons, solar, material, fluent, phosphor. Sprite sheets are downloaded once and cached
--// in workspace/CloudyRevolution/icons. Nothing to load or set up. \\--
local function BuildIconRegistry()
	local Registry = {}

	--// Helpers \\--
	local function Check(...)
		for index = 1, select("#", ...) do
			if typeof((select(index, ...))) ~= "function" then return false end
		end
		return true
	end

	local AssetManager = {}
	do
		local BASE_PATH = "CloudyRevolution/icons-v2"

		AssetManager.Supported = Check(isfile, isfolder, makefolder, readfile, writefile, getcustomasset)
		AssetManager.CanDelete = AssetManager.Supported and Check(listfiles, delfolder)

		function AssetManager.Path(relative: string?): string
			return if relative then `{BASE_PATH}/{relative}` else BASE_PATH
		end

		function AssetManager.EnsureFolder(relative: string?)
			local current = ""
			for _, part in string.split(AssetManager.Path(relative), "/") do
				current = if current == "" then part else `{current}/{part}`
				if not isfolder(current) then
					makefolder(current)
				end
			end
		end

		function AssetManager.IsFile(relative: string): boolean
			local success, result = pcall(isfile, AssetManager.Path(relative))
			return success and result == true
		end

		function AssetManager.Read(relative: string): string?
			return if AssetManager.IsFile(relative) then readfile(AssetManager.Path(relative)) else nil
		end

		function AssetManager.Write(relative: string, data: string)
			writefile(AssetManager.Path(relative), data)
		end

		function AssetManager.Download(relative: string, url: string, validate: ((string) -> boolean)?)
			if AssetManager.IsFile(relative) then return end

			local data = game:HttpGet(url)
			assert(not validate or validate(data), `Invalid download for {relative}`)
			AssetManager.Write(relative, data)
		end

		function AssetManager.ListNames(): { string }
			local names = {}
			for _, entry in listfiles(BASE_PATH) do
				local name = entry:gsub("\\", "/"):gsub("/$", ""):match("([^/]+)$")
				if name then
					table.insert(names, name)
				end
			end
			return names
		end

		function AssetManager.GetAsset(relative: string): string
			return getcustomasset(AssetManager.Path(relative))
		end
	end

	--// Constants \\--
	local ASSET_BASE_URL = "https://molto.pages.dev/"
	local DEFAULT_PROVIDER = "lucide"
	local PROVIDERS = {
		lucide = { Hash = "11d446c12405c3dcce9fcea63ca304378f0d002569c5be7431c2e946a896dd2c", Font = true, Name = "Lucide", Sheets = 2, License = "ISC", Count = 2095, FontParts = 2 },
		tabler = { Hash = "de0041ef23f9edba3c95e9f20f46d1a3c839d6f610a83bdcf44abd7229542e98", Font = true, Name = "Tabler", Sheets = 4, License = "MIT", Count = 6305, FontParts = 5 },
		heroicons = { Hash = "da3ef30e5bda1a0cf6586a6de9789a12537d550aec9598eccc85b4326be76615", Font = true, Name = "Heroicons", Sheets = 1, License = "MIT", Count = 1288, FontParts = 2 },
		solar = { Hash = "01d27f4a6f5ef2740f7080fb66f89fdaca0682cff34776dd71342aed31c4788b", Font = true, Name = "Solar", Sheets = 6, License = "CC BY 4.0", Count = 8859, FontParts = 6 },
		material = { Hash = "993be4ca36fcb877522411e30786f8fe60cfeef65173a101598a645d16767af7", Font = true, Name = "Material Symbols", Sheets = 11, License = "Apache 2.0", Count = 16475, FontParts = 17 },
		fluent = { Hash = "1d72f6702e4bbbf7d7b728f29f2b1d3f7f462b9aeebc112e07d1114ec7e28c9c", Font = true, Name = "Fluent UI", Sheets = 13, License = "MIT", Count = 20334, FontParts = 25 },
		phosphor = { Hash = "3a5e9b8ed33e68efb30de3f96814cb55320b7d7579fa375e29cf2f9fcea4d371", Font = true, Name = "Phosphor", Sheets = 6, License = "MIT", Count = 9161, FontParts = 7 },
	}

	local MAX_ALIAS_DEPTH = 8
	local PRELOAD_WORKERS = 6

	--// Providers \\--
	type ProviderState = {
		Id: string,
		Icons: { string },
		Aliases: { [string]: string },
		Rects: { { any } },
		NoFont: { [string]: boolean },
		Index: { [string]: number },
		SheetUrls: { [number]: string },
		Folder: string,
		FontParts: number?,
		FontName: string,
		Fonts: { [number]: Font | false },
	}

	local loadedProviders: { [string]: ProviderState } = {}
	local currentProvider = DEFAULT_PROVIDER

	-- Keeps only the newest build of a provider on disk
	local function PruneCache(id: string, currentFolder: string)
		if not AssetManager.CanDelete then return end

		for _, name in AssetManager.ListNames() do
			local hash = if name:sub(1, #id + 1) == `{id}-` then name:sub(#id + 2) else nil
			if hash and name ~= currentFolder and hash:match("^" .. string.rep("%x", 64) .. "$") then
				pcall(delfolder, AssetManager.Path(name))
			end
		end
	end

	local function LoadProvider(id: string): ProviderState
		local loaded = loadedProviders[id]
		if loaded then return loaded end

		local meta = PROVIDERS[id]
		assert(meta, `Unknown icon provider "{id}"`)

		local folder = `{id}-{meta.Hash}`
		local dataFile = `{folder}/data.lua`
		local dataUrl = `{ASSET_BASE_URL}providers/{id}.lua`

		local useCustomSprites = false
		local source: string? = nil

		if AssetManager.Supported then
			useCustomSprites = pcall(function()
				AssetManager.EnsureFolder(folder)
				for sheet = 1, meta.Sheets do
					AssetManager.Download(`{folder}/{sheet}.png`, `{ASSET_BASE_URL}spritesheets/{id}/{sheet}.png`, function(data)
						return data:sub(1, 8) == "\137PNG\r\n\26\n" -- PNG header
					end)
				end
				AssetManager.GetAsset(`{folder}/1.png`)
			end)

			pcall(function()
				AssetManager.EnsureFolder(folder)
				AssetManager.Download(dataFile, dataUrl, function(data)
					return data:sub(1, 6) == "return"
				end)
				source = AssetManager.Read(dataFile)
			end)

			if useCustomSprites then
				pcall(PruneCache, id, folder)
			end
		end

		local data = loadstring(source or game:HttpGet(dataUrl))()

		local sheetUrls = {}
		for sheet, fallback in data.Sheets do
			sheetUrls[sheet] = if useCustomSprites then AssetManager.GetAsset(`{folder}/{sheet}.png`) else fallback
		end

		local index = {}
		for position, name in data.Icons do
			index[name] = position
		end

		-- Icons with see-through layers cannot be drawn by a one color font, so they only exist as sprites
		local noFont = {}
		for _, name in data.NoFont or {} do
			noFont[name] = true
		end

		local state: ProviderState = {
			Id = id,
			Icons = data.Icons,
			Aliases = data.Aliases,
			Rects = data.Rects,
			NoFont = noFont,
			Index = index,
			SheetUrls = sheetUrls,
			Folder = folder,
			FontParts = if meta.Font then meta.FontParts else nil,
			FontName = meta.Name,
			Fonts = {},
		}

		loadedProviders[id] = state
		return state
	end

	-- Must match FontPartOf in scripts/build.luau
	local function FontPartOf(name: string, parts: number): number
		local hash = 7
		for index = 1, #name do
			hash = (hash * 131 + string.byte(name, index)) % 2147483629
		end
		return hash % parts + 1
	end

	-- Roblox does not shape a ligature whose text starts with a digit, so the font stores those icons with a letter prefix.
	-- Must match LigatureOf in scripts/build.luau
	local function LigatureOf(name: string): string
		return if name:match("^%d") then `x-{name}` else name
	end

	-- Big sets are split into several fonts, so a font is downloaded when its first icon is looked up
	local function GetFontFace(state: ProviderState, part: number): Font?
		local cached = state.Fonts[part]
		if cached ~= nil then return cached or nil end

		local face: Font? = nil
		if AssetManager.Supported then
			pcall(function()
				local ttfFile = `{state.Folder}/font-{part}.ttf`
				local familyFile = `{state.Folder}/font-{part}.json`

				AssetManager.EnsureFolder(state.Folder)
				AssetManager.Download(ttfFile, `{ASSET_BASE_URL}fonts/{state.Id}/{state.Id}-{part}.ttf`, function(data)
					return data:sub(1, 4) == "\0\1\0\0" -- TrueType header
				end)
				AssetManager.Write(familyFile, game:GetService("HttpService"):JSONEncode({
					name = `{state.FontName} {part}`,
					loadStrategy = "sameFamilyOnly",
					faces = {
						{ name = "Regular", weight = 400, style = "normal", assetId = AssetManager.GetAsset(ttfFile) },
					},
				}))

				face = Font.new(AssetManager.GetAsset(familyFile))
			end)
		end

		state.Fonts[part] = face or false
		return face
	end

	--// API \\--
	Registry.Providers = {}
	for id in PROVIDERS do
		table.insert(Registry.Providers, id)
	end
	table.sort(Registry.Providers)

	function Registry.GetProviderInfo(id: string?)
		local meta = PROVIDERS[id or currentProvider]
		if not meta then return nil end

		return { Id = id or currentProvider, Name = meta.Name, License = meta.License, Count = meta.Count }
	end

	function Registry.GetProvider(): string
		return currentProvider
	end

	function Registry.SetProvider(id: string)
		assert(PROVIDERS[id], `Unknown icon provider "{id}"`)

		LoadProvider(id)
		currentProvider = id
	end

	function Registry.GetIcons(provider: string?): { string }
		return LoadProvider(provider or currentProvider).Icons
	end

	function Registry.HasIcon(name: string, provider: string?): boolean
		return Registry.GetAsset(name, provider) ~= nil
	end

	local function Resolve(state: ProviderState, name: string): string
		local resolved = name
		for _ = 1, MAX_ALIAS_DEPTH do
			local target = state.Aliases[resolved]
			if not target then break end
			resolved = target
		end
		return resolved
	end

	-- Downloads everything up front so GetAsset never yields. Without names it fetches every font part of the provider.
	-- Returns the number of font parts that are ready
	function Registry.PreloadAsync(names: { string }?, provider: string?): number
		local state = LoadProvider(provider or currentProvider)
		if not state.FontParts then return 0 end

		local seen: { [number]: boolean } = {}
		local queue: { number } = {}
		local function Add(part: number)
			if not seen[part] then
				seen[part] = true
				table.insert(queue, part)
			end
		end

		if names then
			for _, name in names do
				local resolved = Resolve(state, name)
				if state.Index[resolved] and not state.NoFont[resolved] then
					Add(FontPartOf(resolved, state.FontParts))
				end
			end
		else
			for part = 1, state.FontParts do
				Add(part)
			end
		end

		local ready = 0
		local function Work()
			while true do
				local part = table.remove(queue)
				if not part then return end
				if GetFontFace(state, part) then
					ready += 1
				end
			end
		end

		-- Several parts download at once, the rest of the queue is picked up as workers finish
		local workers = math.min(PRELOAD_WORKERS, #queue)
		if typeof(task) ~= "table" or workers <= 1 then
			Work()
			return ready
		end

		local running = workers
		for _ = 1, workers do
			task.spawn(function()
				pcall(Work)
				running -= 1
			end)
		end
		while running > 0 do
			task.wait()
		end
		return ready
	end

	function Registry.GetAsset(name: string, provider: string?)
		local state = LoadProvider(provider or currentProvider)

		local resolved = Resolve(state, name)

		local position = state.Index[resolved]
		if not position then
			return nil
		end

		local rect = state.Rects[position]
		local fontPart = if state.FontParts and not state.NoFont[resolved] then FontPartOf(resolved, state.FontParts) else nil
		local fontFace = if fontPart then GetFontFace(state, fontPart) else nil

		return {
			IconName = name,
			Provider = state.Id,
			Url = state.SheetUrls[rect[1]],
			ImageRectSize = Vector2.new(rect[2][1], rect[2][2]),
			ImageRectOffset = Vector2.new(rect[3][1], rect[3][2]),

			-- Only present when the provider font loaded. The font shapes Text into one icon through a ligature
			FontFace = fontFace,
			FontPart = fontPart,
			Text = if fontFace then LigatureOf(resolved) else nil,
		}
	end

	function Registry.SetIcon(iconInstance: TextLabel | ImageLabel, name: string, provider: string?)
		assert(typeof(iconInstance) == "Instance" and (iconInstance:IsA("TextLabel") or iconInstance:IsA("ImageLabel")), "iconInstance must be a TextLabel or ImageLabel")

		local asset = Registry.GetAsset(name, provider)
		assert(asset, `Icon "{name}" not found in provider "{provider}"`)

		if iconInstance:IsA("TextLabel") then
			assert(asset.FontFace, "Environment does not support font icons. Try using an ImageLabel instead.")

			iconInstance.Text = asset.Text
			iconInstance.FontFace = asset.FontFace
		else
			iconInstance.Image = asset.Url
			iconInstance.ImageRectSize = asset.ImageRectSize
			iconInstance.ImageRectOffset = asset.ImageRectOffset
		end
	end

	return Registry
end

local IconRegistry = nil -- nil = not built yet, false = failed
local ProviderIconCache = {}

Library.DefaultIconProvider = nil -- optional: plain names ("target") are looked up in this provider first

local function GetIconRegistry()
    if IconRegistry == nil then
        local Success, Result = pcall(BuildIconRegistry)
        IconRegistry = Success and Result or false
    end

    return IconRegistry or nil
end

--// Optional: swap in your own registry module (needs GetAsset + Providers) \--
function Library:SetIconRegistry(Registry)
    assert(
        typeof(Registry) == "table" and typeof(Registry.GetAsset) == "function" and typeof(Registry.Providers) == "table",
        "Registry must be an icon registry module (needs GetAsset and Providers)."
    )

    IconRegistry = Registry
    table.clear(ProviderIconCache)
end

function Library:GetIconRegistry()
    return GetIconRegistry()
end

function Library:GetIconProviders(): { string }
    local Registry = GetIconRegistry()
    return Registry and Registry.Providers or {}
end

function Library:SetDefaultIconProvider(Provider: string?)
    Library.DefaultIconProvider = Provider
end

function Library:GetProviderIcon(Provider: string, Name: string)
    local Registry = GetIconRegistry()
    if not Registry then
        return nil
    end

    local Key = Provider .. ":" .. Name
    local Cached = ProviderIconCache[Key]
    if Cached ~= nil then
        return Cached or nil
    end

    local Success, Asset = pcall(Registry.GetAsset, Name, Provider)
    local Result = false
    if Success and typeof(Asset) == "table" and Asset.Url then
        Result = {
            Url = Asset.Url,
            ImageRectOffset = Asset.ImageRectOffset,
            ImageRectSize = Asset.ImageRectSize,
        }
    end

    ProviderIconCache[Key] = Result
    return Result or nil
end

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(IconName: string)
    if not FetchIcons or not Icons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if Success and Icon then return Icon end
    return Library:GetProviderIcon("lucide", IconName)
end

function Library:GetCustomIcon(IconName: string): any
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    --// "provider:icon-name" \\--
    if typeof(IconName) == "string" then
        local Provider, ProviderName = string.match(IconName, "^([%w_%-]+):([^/].*)$")
        if Provider then
            Provider = string.lower(Provider)
            if Provider == "lucide" then
                local Direct = Library:GetIcon(ProviderName)
                if Direct then return Direct end
            end
            local Registry = GetIconRegistry()
            if Registry and table.find(Registry.Providers, Provider) then
                return Library:GetProviderIcon(Provider, ProviderName)
            end
        end
    end

    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    if Library.DefaultIconProvider and typeof(IconName) == "string" then
        local DefaultIcon = Library:GetProviderIcon(Library.DefaultIconProvider, IconName)
        if DefaultIcon then
            return DefaultIcon
        end
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:ApplyLucideIcon(ImageGui: any, Icon: any, Rotation: number?)
    if not ImageGui or not Icon then
        return
    end

    if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then
        return
    end

    ImageGui.ScaleType = Enum.ScaleType.Fit
    ImageGui.Image = Icon.Url or ""
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or Vector2.zero 
    ImageGui.ImageRectSize = Icon.ImageRectSize or Vector2.zero
    ImageGui.Rotation = Rotation or ImageGui.Rotation
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if ClassName == "UIScale" and Properties.Scale == nil then
        Instance.Scale = Library.DPIScale
    end

    if
        (Library.TextScale or 1) ~= 1
        and (ClassName == "TextLabel" or ClassName == "TextButton" or ClassName == "TextBox")
        and not Instance.TextScaled
    then
        Instance:SetAttribute("CRBaseSize", Instance.TextSize)
        Instance.TextSize = math.max(8, math.floor(Instance.TextSize * Library.TextScale + 0.5))
    end

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui: ScreenGui, Enabled: boolean)
    if not Gui then
        return
    end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "CloudyRevolution",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    task.defer(function()
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end

        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Floats and Overlays
local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

--// Cursor
local Cursor
local CursorCross
local InnerCross = {}
local CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(1, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })

    CursorCross = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        Parent = Cursor,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -2, 0, 1),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 1, 1, -2),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    CursorCustomImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 3,
        Visible = false,
        Parent = Cursor,
    })
end

local function RestoreMouseIcon()
    pcall(function() 
        RunService:UnbindFromRenderStep(Library.ShowCursorBinding)
        RunService.RenderStepped:Wait()
    end)

    UserInputService.MouseIconEnabled = Library.OriginalMouseIconEnabled
    if Cursor then Cursor.Visible = false end
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

--// Icons \\--
local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon
function Library:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module

    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
    CloseIcon = Library:GetIcon("x")
end

-- Pinned Lucide names, rectangles and sheets: one immutable revision, no mixed caches.
local function BuildPinnedLucide()
    local Rects = {
    ["align-vertical-distribute-center"] = {1,24,24,175,0},
    ["chevron-down"] = {1,24,24,275,375},
    ["list-restart"] = {1,24,24,200,950},
    ["table-cells-split"] = {2,24,24,25,400},
    ["gavel"] = {1,24,24,875,125},
    ["dna-off"] = {1,24,24,325,525},
    ["refresh-ccw-dot"] = {1,24,24,725,775},
    ["venus"] = {2,24,24,350,275},
    ["bean"] = {1,24,24,350,75},
    ["circle-question-mark"] = {1,24,24,300,425},
    ["folder-code"] = {1,24,24,150,800},
    ["calendar-arrow-left"] = {1,24,24,0,550},
    ["bolt"] = {1,24,24,400,75},
    ["heater"] = {1,24,24,500,550},
    ["feather"] = {1,24,24,450,450},
    ["align-horizontal-distribute-center"] = {1,24,24,50,75},
    ["grip-vertical"] = {1,24,24,725,300},
    ["pill-bottle"] = {1,24,24,900,525},
    ["person-standing"] = {1,24,24,825,575},
    ["badge-swiss-franc"] = {1,24,24,200,175},
    ["between-horizontal-end"] = {1,24,24,400,50},
    ["file-braces-corner"] = {1,24,24,275,625},
    ["rotate-cw"] = {1,24,24,850,700},
    ["square-chevrons-down"] = {2,24,24,75,100},
    ["house-plus"] = {1,24,24,100,950},
    ["bus-front"] = {1,24,24,225,325},
    ["shield-ellipsis"] = {1,24,24,750,925},
    ["circle-letter-x"] = {1,24,24,600,125},
    ["between-vertical-end"] = {1,24,24,350,100},
    ["globe-lock"] = {1,24,24,175,825},
    ["tags"] = {2,24,24,200,250},
    ["concierge-bell"] = {1,24,24,525,275},
    ["bookmark-minus"] = {1,24,24,150,350},
    ["plant-pot"] = {1,24,24,675,750},
    ["circle-letter-a"] = {1,24,24,450,250},
    ["picture-in-picture"] = {1,24,24,450,950},
    ["messages-square"] = {1,24,24,675,575},
    ["scissors"] = {1,24,24,675,925},
    ["file-check-corner"] = {1,24,24,125,775},
    ["phone-call"] = {1,24,24,750,650},
    ["zoom-out"] = {2,24,24,500,200},
    ["zoom-in"] = {2,24,24,525,175},
    ["zodiac-virgo"] = {2,24,24,550,150},
    ["anchor"] = {1,24,24,100,100},
    ["hockey-stick"] = {1,24,24,375,675},
    ["zodiac-scorpio"] = {2,24,24,600,100},
    ["hand-helping"] = {1,24,24,375,650},
    ["stretch-vertical"] = {2,24,24,75,325},
    ["text-wrap"] = {2,24,24,25,450},
    ["birdhouse"] = {1,24,24,150,300},
    ["wifi-off"] = {2,24,24,575,100},
    ["cloud-alert"] = {1,24,24,625,150},
    ["message-square"] = {1,24,24,725,525},
    ["cloud-download"] = {1,24,24,525,250},
    ["folder-user"] = {1,24,24,550,425},
    ["zodiac-pisces"] = {2,24,24,650,50},
    ["folder-plus"] = {1,24,24,750,225},
    ["lasso"] = {1,24,24,600,500},
    ["zodiac-libra"] = {2,24,24,700,0},
    ["zodiac-leo"] = {2,24,24,0,675},
    ["cctv-off"] = {1,24,24,600,25},
    ["notebook-dot"] = {1,24,24,850,475},
    ["zodiac-gemini"] = {2,24,24,25,650},
    ["rows-4"] = {1,24,24,700,850},
    ["mirror-round"] = {1,24,24,950,325},
    ["shapes"] = {1,24,24,700,950},
    ["square-chevrons-right"] = {2,24,24,25,150},
    ["user-round"] = {2,24,24,225,375},
    ["pointer"] = {1,24,24,900,550},
    ["between-horizontal-start"] = {1,24,24,375,75},
    ["chevrons-up-down"] = {1,24,24,650,25},
    ["zodiac-aries"] = {2,24,24,100,575},
    ["brush"] = {1,24,24,425,125},
    ["zodiac-aquarius"] = {2,24,24,125,550},
    ["circle-letter-b"] = {1,24,24,425,275},
    ["message-circle-more"] = {1,24,24,600,625},
    ["parentheses"] = {1,24,24,700,675},
    ["package-open"] = {1,24,24,950,400},
    ["toggle-left"] = {2,24,24,25,475},
    ["book-up-2"] = {1,24,24,300,200},
    ["flame"] = {1,24,24,550,400},
    ["x-line-top"] = {2,24,24,225,450},
    ["wifi"] = {2,24,24,475,200},
    ["chevrons-up"] = {1,24,24,625,50},
    ["shield"] = {1,24,24,775,925},
    ["circle-arrow-out-down-left"] = {1,24,24,450,225},
    ["worm"] = {2,24,24,300,375},
    ["square-dashed"] = {2,24,24,200,25},
    ["square-mouse-pointer"] = {2,24,24,125,175},
    ["superscript"] = {2,24,24,250,175},
    ["workflow"] = {2,24,24,325,350},
    ["wine-off"] = {2,24,24,375,300},
    ["wine"] = {2,24,24,350,325},
    ["lock-keyhole"] = {1,24,24,625,550},
    ["signal"] = {1,24,24,950,825},
    ["wifi-cog"] = {2,24,24,675,0},
    ["square-letter-k"] = {2,24,24,0,250},
    ["wind-arrow-down"] = {2,24,24,450,225},
    ["square-letter-o"] = {2,24,24,200,75},
    ["hexagon"] = {1,24,24,450,600},
    ["navigation-2-off"] = {1,24,24,400,900},
    ["eye-off"] = {1,24,24,775,125},
    ["message-square-warning"] = {1,24,24,775,475},
    ["arrows-up-from-line"] = {1,24,24,200,125},
    ["file-code-corner"] = {1,24,24,50,850},
    ["wifi-sync"] = {2,24,24,525,150},
    ["square-centerline-dashed-horizontal"] = {2,24,24,100,50},
    ["panels-right-bottom"] = {1,24,24,825,550},
    ["scaling"] = {1,24,24,625,950},
    ["letter-q"] = {1,24,24,450,675},
    ["train-front-tunnel"] = {2,24,24,125,400},
    ["hash"] = {1,24,24,100,925},
    ["arrow-left-from-line"] = {1,24,24,50,225},
    ["rows-3"] = {1,24,24,725,825},
    ["ship"] = {1,24,24,975,750},
    ["ticket-percent"] = {2,24,24,300,200},
    ["wifi-lock"] = {2,24,24,625,50},
    ["circle-letter-l"] = {1,24,24,175,525},
    ["calendar-clock"] = {1,24,24,425,150},
    ["wifi-high"] = {2,24,24,650,25},
    ["x"] = {2,24,24,200,475},
    ["square-padding"] = {2,24,24,275,50},
    ["non-binary"] = {1,24,24,875,450},
    ["voicemail"] = {2,24,24,125,500},
    ["square-stack"] = {2,24,24,200,150},
    ["presentation"] = {1,24,24,750,700},
    ["tree-palm"] = {2,24,24,500,50},
    ["badge"] = {1,24,24,125,250},
    ["whistle"] = {2,24,24,25,625},
    ["captions-off"] = {1,24,24,400,200},
    ["align-vertical-justify-center"] = {1,24,24,100,75},
    ["wheat-off"] = {2,24,24,75,575},
    ["download"] = {1,24,24,875,0},
    ["mouse-right"] = {1,24,24,850,450},
    ["wheat"] = {2,24,24,50,600},
    ["text-align-justify-start"] = {2,24,24,225,250},
    ["lens-convex"] = {1,24,24,900,225},
    ["shrimp-off"] = {1,24,24,975,775},
    ["focus"] = {1,24,24,350,600},
    ["letter-d"] = {1,24,24,775,350},
    ["weight-tilde"] = {2,24,24,125,525},
    ["diamond-percent"] = {1,24,24,725,125},
    ["arrow-big-up"] = {1,24,24,100,150},
    ["volume-x"] = {2,24,24,0,625},
    ["mouse-pointer-click"] = {1,24,24,900,400},
    ["face-slightly-smiling-plus"] = {1,24,24,600,300},
    ["weight"] = {2,24,24,100,550},
    ["hard-drive"] = {1,24,24,150,875},
    ["grid-2x2-x"] = {1,24,24,850,175},
    ["package-minus"] = {1,24,24,975,375},
    ["cloud"] = {1,24,24,150,625},
    ["pipette"] = {1,24,24,800,625},
    ["rat"] = {1,24,24,750,725},
    ["file-play"] = {1,24,24,500,425},
    ["corner-left-down"] = {1,24,24,75,725},
    ["webcam-off"] = {2,24,24,225,425},
    ["badge-cent"] = {1,24,24,125,225},
    ["webcam"] = {2,24,24,200,450},
    ["waypoints"] = {2,24,24,250,400},
    ["cloud-lightning"] = {1,24,24,425,350},
    ["user-round-pen"] = {2,24,24,375,225},
    ["waves-vertical"] = {2,24,24,275,375},
    ["waves-ladder"] = {2,24,24,300,350},
    ["arrow-left-to-line"] = {1,24,24,0,275},
    ["book-open-text"] = {1,24,24,450,50},
    ["monitor-cloud"] = {1,24,24,875,400},
    ["parking-meter"] = {1,24,24,650,725},
    ["waves-horizontal"] = {2,24,24,325,325},
    ["play-off"] = {1,24,24,650,775},
    ["cat"] = {1,24,24,625,0},
    ["siren-off"] = {1,24,24,850,925},
    ["heart-handshake"] = {1,24,24,675,375},
    ["waves-arrow-down"] = {2,24,24,375,275},
    ["watch"] = {2,24,24,400,250},
    ["washing-machine"] = {2,24,24,425,225},
    ["dam"] = {1,24,24,300,525},
    ["trees"] = {2,24,24,450,100},
    ["warehouse"] = {2,24,24,450,200},
    ["wand-sparkles"] = {2,24,24,500,150},
    ["ham"] = {1,24,24,550,475},
    ["panel-right-open"] = {1,24,24,400,950},
    ["circle-pause"] = {1,24,24,475,250},
    ["chess-king"] = {1,24,24,400,250},
    ["bean-off"] = {1,24,24,375,50},
    ["wallpaper"] = {2,24,24,525,125},
    ["wallet-minimal"] = {2,24,24,575,75},
    ["clef-alto"] = {1,24,24,750,0},
    ["separator-horizontal"] = {1,24,24,950,700},
    ["wallet-cards"] = {2,24,24,600,50},
    ["wallet"] = {2,24,24,550,100},
    ["ambulance"] = {1,24,24,200,0},
    ["vote"] = {2,24,24,625,25},
    ["globe-code"] = {1,24,24,200,800},
    ["citrus"] = {1,24,24,25,700},
    ["volume-off"] = {2,24,24,25,600},
    ["piano"] = {1,24,24,525,875},
    ["circle-letter-s"] = {1,24,24,725,0},
    ["volume-1"] = {2,24,24,75,550},
    ["phone-missed"] = {1,24,24,650,750},
    ["calendar-off"] = {1,24,24,250,325},
    ["volume"] = {2,24,24,650,0},
    ["volleyball"] = {2,24,24,100,525},
    ["chart-column"] = {1,24,24,225,400},
    ["clapperboard"] = {1,24,24,0,725},
    ["virus"] = {2,24,24,150,475},
    ["battery-medium"] = {1,24,24,50,350},
    ["user-group"] = {2,24,24,50,525},
    ["square-minus"] = {2,24,24,150,150},
    ["badge-x"] = {1,24,24,150,225},
    ["square-chart-gantt"] = {2,24,24,50,100},
    ["video"] = {2,24,24,250,375},
    ["share"] = {1,24,24,975,700},
    ["star-check"] = {2,24,24,175,200},
    ["vibrate"] = {2,24,24,300,325},
    ["decimals-arrow-left"] = {1,24,24,0,825},
    ["folder-output"] = {1,24,24,800,175},
    ["venus-and-mars"] = {2,24,24,375,250},
    ["menu"] = {1,24,24,775,450},
    ["bangladeshi-taka"] = {1,24,24,375,25},
    ["image-down"] = {1,24,24,825,250},
    ["terminal"] = {2,24,24,425,50},
    ["building-complex-plus"] = {1,24,24,300,250},
    ["monitor-play"] = {1,24,24,700,575},
    ["panel-left-open"] = {1,24,24,525,825},
    ["circle-dot-dashed"] = {1,24,24,675,25},
    ["medal"] = {1,24,24,875,350},
    ["cake-slice"] = {1,24,24,125,425},
    ["circle-chevrons-up"] = {1,24,24,75,600},
    ["armchair"] = {1,24,24,50,175},
    ["tickets"] = {2,24,24,150,350},
    ["azerbaijani-manat"] = {1,24,24,250,100},
    ["qr-code"] = {1,24,24,525,925},
    ["copy"] = {1,24,24,175,625},
    ["goal"] = {1,24,24,75,925},
    ["layout-freeform"] = {1,24,24,300,800},
    ["book-bookmark"] = {1,24,24,225,250},
    ["trending-down"] = {2,24,24,425,125},
    ["vector-polygon"] = {2,24,24,475,150},
    ["vault"] = {2,24,24,500,125},
    ["creative-commons"] = {1,24,24,725,100},
    ["layers-arrow-down"] = {1,24,24,500,600},
    ["ev-charger"] = {1,24,24,900,0},
    ["user-star"] = {2,24,24,150,450},
    ["road"] = {1,24,24,775,750},
    ["nfc"] = {1,24,24,900,425},
    ["align-center-horizontal"] = {1,24,24,0,100},
    ["text-align-justify-end"] = {2,24,24,250,225},
    ["car"] = {1,24,24,275,325},
    ["notebook-tabs"] = {1,24,24,800,525},
    ["ear"] = {1,24,24,575,300},
    ["videotape"] = {2,24,24,225,400},
    ["sun-moon"] = {2,24,24,375,50},
    ["van"] = {2,24,24,550,75},
    ["chart-scatter"] = {1,24,24,600,50},
    ["podium"] = {1,24,24,950,500},
    ["lightbulb"] = {1,24,24,875,275},
    ["users-collaboration"] = {2,24,24,75,525},
    ["toolbox"] = {2,24,24,450,75},
    ["calendar"] = {1,24,24,50,525},
    ["calendar-cog"] = {1,24,24,400,175},
    ["gallery-horizontal"] = {1,24,24,125,850},
    ["clipboard-x"] = {1,24,24,425,325},
    ["list-sort-ascending"] = {1,24,24,175,975},
    ["book-open"] = {1,24,24,425,75},
    ["utensils"] = {2,24,24,600,25},
    ["germ"] = {1,24,24,775,225},
    ["circle-pile"] = {1,24,24,425,300},
    ["users-round"] = {2,24,24,25,575},
    ["rectangle-ellipsis"] = {1,24,24,925,575},
    ["badge-plus"] = {1,24,24,300,75},
    ["badge-info"] = {1,24,24,0,350},
    ["file-headphone"] = {1,24,24,800,125},
    ["bow-arrow"] = {1,24,24,450,75},
    ["clipboard-pen-line"] = {1,24,24,525,225},
    ["user-round-key"] = {2,24,24,425,175},
    ["folder-search"] = {1,24,24,675,300},
    ["utensils-crossed"] = {2,24,24,625,0},
    ["arrow-up"] = {1,24,24,225,100},
    ["users"] = {2,24,24,0,600},
    ["user-x"] = {2,24,24,125,475},
    ["arrow-up-from-dot"] = {1,24,24,75,225},
    ["square-slash"] = {2,24,24,325,25},
    ["align-vertical-justify-start"] = {1,24,24,50,125},
    ["layers-minus"] = {1,24,24,450,650},
    ["shield-house"] = {1,24,24,700,975},
    ["pause"] = {1,24,24,600,775},
    ["text-align-justify"] = {2,24,24,200,275},
    ["shrub"] = {1,24,24,900,850},
    ["user-round-x"] = {2,24,24,250,350},
    ["user-key"] = {2,24,24,25,550},
    ["message-circle-check"] = {1,24,24,725,500},
    ["flag"] = {1,24,24,600,350},
    ["user-round-search"] = {2,24,24,325,275},
    ["biceps-flexed"] = {1,24,24,300,150},
    ["align-horizontal-distribute-end"] = {1,24,24,25,100},
    ["letter-p"] = {1,24,24,475,650},
    ["letter-l"] = {1,24,24,575,550},
    ["donut"] = {1,24,24,175,675},
    ["calendar-plus-2"] = {1,24,24,225,350},
    ["move-vertical"] = {1,24,24,450,850},
    ["file-pen-line"] = {1,24,24,550,375},
    ["badge-russian-ruble"] = {1,24,24,225,150},
    ["user-round-group"] = {2,24,24,450,150},
    ["user-round-cog"] = {2,24,24,475,125},
    ["radius"] = {1,24,24,800,675},
    ["user-round-check"] = {2,24,24,500,100},
    ["pilcrow"] = {1,24,24,925,500},
    ["user-round-arrow-left"] = {2,24,24,525,75},
    ["corner-left-up"] = {1,24,24,50,750},
    ["square-play"] = {2,24,24,125,200},
    ["georgian-lari"] = {1,24,24,825,175},
    ["cable"] = {1,24,24,150,400},
    ["book-user"] = {1,24,24,250,250},
    ["cherry"] = {1,24,24,450,200},
    ["square-arrow-down"] = {2,24,24,25,50},
    ["user-minus"] = {2,24,24,600,0},
    ["circle-chevrons-left"] = {1,24,24,125,550},
    ["user-lock"] = {2,24,24,0,575},
    ["user-round-star"] = {2,24,24,275,325},
    ["view"] = {2,24,24,200,425},
    ["cctv"] = {1,24,24,575,50},
    ["user-cog"] = {2,24,24,75,500},
    ["receipt"] = {1,24,24,975,525},
    ["user"] = {2,24,24,100,500},
    ["usb-c-port"] = {2,24,24,150,425},
    ["kazakh-tenge"] = {1,24,24,250,825},
    ["upload"] = {2,24,24,175,400},
    ["unplug"] = {2,24,24,200,375},
    ["rotate-cw-clock"] = {1,24,24,925,625},
    ["circle-arrow-left"] = {1,24,24,475,200},
    ["square-off"] = {2,24,24,100,200},
    ["unlink"] = {2,24,24,225,350},
    ["octagon-alert"] = {1,24,24,600,725},
    ["panel-bottom-dashed"] = {1,24,24,650,700},
    ["university"] = {2,24,24,275,300},
    ["book-a"] = {1,24,24,300,175},
    ["ungroup"] = {2,24,24,300,275},
    ["align-end-vertical"] = {1,24,24,75,50},
    ["unfold-vertical"] = {2,24,24,325,250},
    ["thumbs-up"] = {2,24,24,400,100},
    ["triangle"] = {2,24,24,275,275},
    ["globe"] = {1,24,24,100,900},
    ["grip"] = {1,24,24,700,325},
    ["undo-2"] = {2,24,24,425,150},
    ["rabbit"] = {1,24,24,475,975},
    ["undo"] = {2,24,24,375,200},
    ["underline"] = {2,24,24,450,125},
    ["layers-plus"] = {1,24,24,425,675},
    ["umbrella-off"] = {2,24,24,500,75},
    ["door-stairwell"] = {1,24,24,25,825},
    ["tombstone"] = {2,24,24,500,25},
    ["type-outline"] = {2,24,24,550,25},
    ["clock-9"] = {1,24,24,100,650},
    ["banknote-arrow-down"] = {1,24,24,350,50},
    ["square-scissors"] = {2,24,24,0,325},
    ["message-square-off"] = {1,24,24,925,325},
    ["square-user-round"] = {2,24,24,75,275},
    ["earbuds-off"] = {1,24,24,550,325},
    ["file-digit"] = {1,24,24,875,50},
    ["dice-4"] = {1,24,24,575,275},
    ["turntable"] = {2,24,24,75,475},
    ["turkish-lira"] = {2,24,24,100,450},
    ["message-circle-x"] = {1,24,24,425,800},
    ["folder-x"] = {1,24,24,500,475},
    ["tube-lotion"] = {2,24,24,125,425},
    ["message-circle-warning"] = {1,24,24,450,775},
    ["stethoscope"] = {2,24,24,375,25},
    ["map"] = {1,24,24,425,775},
    ["truck"] = {2,24,24,150,400},
    ["move"] = {1,24,24,425,875},
    ["trophy"] = {2,24,24,200,350},
    ["caravan"] = {1,24,24,250,350},
    ["arrow-up-left"] = {1,24,24,25,275},
    ["award"] = {1,24,24,325,25},
    ["triangles-centerline-dashed-horizontal"] = {2,24,24,250,300},
    ["file-type-corner"] = {1,24,24,150,775},
    ["phi"] = {1,24,24,800,600},
    ["triangle-alert"] = {2,24,24,350,200},
    ["arrow-down-wide-narrow"] = {1,24,24,125,150},
    ["unfold-horizontal"] = {2,24,24,350,225},
    ["lens-concave"] = {1,24,24,925,200},
    ["handle-bottom-right"] = {1,24,24,250,775},
    ["square-split-vertical"] = {2,24,24,250,100},
    ["motorbike"] = {1,24,24,400,875},
    ["trending-up"] = {2,24,24,375,175},
    ["wind-arrow-up"] = {2,24,24,425,250},
    ["screw"] = {1,24,24,925,700},
    ["file-volume"] = {1,24,24,25,900},
    ["disc-3"] = {1,24,24,425,425},
    ["file-signal"] = {1,24,24,325,600},
    ["columns-4"] = {1,24,24,675,125},
    ["archive-x"] = {1,24,24,100,125},
    ["tree-deciduous"] = {2,24,24,525,25},
    ["square-dashed-kanban"] = {2,24,24,125,75},
    ["mouse-pointer-2"] = {1,24,24,950,350},
    ["clock-arrow-up"] = {1,24,24,775,0},
    ["clock-fading"] = {1,24,24,725,50},
    ["pencil-sparkles"] = {1,24,24,950,450},
    ["send-horizontal"] = {1,24,24,675,950},
    ["vegan"] = {2,24,24,425,200},
    ["star-plus"] = {2,24,24,75,300},
    ["transgender"] = {2,24,24,25,500},
    ["clef-bass"] = {1,24,24,725,25},
    ["message-circle-plus"] = {1,24,24,550,675},
    ["letter-y"] = {1,24,24,225,900},
    ["credit-card-plus"] = {1,24,24,650,175},
    ["square-percent"] = {2,24,24,200,125},
    ["calendar-chevrons-left"] = {1,24,24,475,100},
    ["user-pen"] = {2,24,24,575,25},
    ["chess-knight"] = {1,24,24,375,275},
    ["wifi-pen"] = {2,24,24,550,125},
    ["files"] = {1,24,24,900,50},
    ["send-to-back"] = {1,24,24,650,975},
    ["alarm-clock"] = {1,24,24,50,50},
    ["train-front"] = {2,24,24,100,425},
    ["trailer"] = {2,24,24,150,375},
    ["traffic-cone"] = {2,24,24,175,350},
    ["tractor"] = {2,24,24,200,325},
    ["shopping-basket"] = {1,24,24,900,825},
    ["send"] = {1,24,24,975,675},
    ["globe-x"] = {1,24,24,125,875},
    ["tower-control"] = {2,24,24,250,275},
    ["navigation"] = {1,24,24,325,975},
    ["touchpad-off"] = {2,24,24,325,200},
    ["touchpad"] = {2,24,24,300,225},
    ["square-letter-s"] = {2,24,24,75,200},
    ["germ-off"] = {1,24,24,800,200},
    ["brush-cleaning"] = {1,24,24,450,100},
    ["skip-back"] = {1,24,24,975,825},
    ["torus"] = {2,24,24,350,175},
    ["book-audio"] = {1,24,24,250,225},
    ["tornado"] = {2,24,24,375,150},
    ["file-scan"] = {1,24,24,400,525},
    ["cupcake"] = {1,24,24,375,450},
    ["midi-port"] = {1,24,24,425,825},
    ["message-square-dashed"] = {1,24,24,325,900},
    ["toothbrush-sparkles"] = {2,24,24,425,100},
    ["toothbrush"] = {2,24,24,400,125},
    ["chevrons-left"] = {1,24,24,25,625},
    ["tool-case"] = {2,24,24,475,50},
    ["umbrella"] = {2,24,24,475,100},
    ["skip-forward"] = {1,24,24,950,850},
    ["clipboard-copy"] = {1,24,24,625,125},
    ["map-pin-off"] = {1,24,24,675,525},
    ["arrow-up-from-line"] = {1,24,24,50,250},
    ["circle-chevron-up"] = {1,24,24,175,500},
    ["toilet"] = {2,24,24,525,0},
    ["key-square"] = {1,24,24,200,875},
    ["circle-small"] = {1,24,24,225,500},
    ["align-vertical-space-between"] = {1,24,24,0,175},
    ["lamp-desk"] = {1,24,24,925,175},
    ["circle-arrow-up"] = {1,24,24,325,350},
    ["zap"] = {2,24,24,150,525},
    ["beaker"] = {1,24,24,400,25},
    ["timer-reset"] = {2,24,24,75,425},
    ["milestone"] = {1,24,24,400,850},
    ["timer"] = {2,24,24,50,450},
    ["paintbrush"] = {1,24,24,750,600},
    ["timeline"] = {2,24,24,125,375},
    ["broccoli"] = {1,24,24,525,25},
    ["tally-3"] = {2,24,24,125,325},
    ["ticket-x"] = {2,24,24,225,275},
    ["chevron-up"] = {1,24,24,150,500},
    ["stone"] = {2,24,24,150,250},
    ["file-search-corner"] = {1,24,24,375,550},
    ["pen-tool"] = {1,24,24,475,900},
    ["database-check"] = {1,24,24,200,625},
    ["ticket-minus"] = {2,24,24,325,175},
    ["earbuds"] = {1,24,24,525,350},
    ["pencil-ruler"] = {1,24,24,975,425},
    ["dna"] = {1,24,24,300,550},
    ["arrow-big-down-dash"] = {1,24,24,0,225},
    ["chart-area"] = {1,24,24,525,100},
    ["bug-off"] = {1,24,24,375,175},
    ["pen-line"] = {1,24,24,525,850},
    ["database-search"] = {1,24,24,100,725},
    ["card-sim"] = {1,24,24,225,375},
    ["tic-tac-toe"] = {2,24,24,375,125},
    ["letter-c"] = {1,24,24,800,325},
    ["map-pin-search"] = {1,24,24,575,625},
    ["square-letter-z"] = {2,24,24,225,75},
    ["eye-dashed"] = {1,24,24,800,100},
    ["thermometer-sun"] = {2,24,24,475,25},
    ["ellipse"] = {1,24,24,275,600},
    ["spell-check"] = {1,24,24,925,975},
    ["thermometer-snowflake"] = {2,24,24,500,0},
    ["margin-vertical"] = {1,24,24,275,925},
    ["popcorn"] = {1,24,24,875,575},
    ["blocks"] = {1,24,24,25,425},
    ["thermometer"] = {2,24,24,450,50},
    ["layer-arrow-up"] = {1,24,24,550,550},
    ["microchip"] = {1,24,24,500,750},
    ["theater"] = {2,24,24,0,475},
    ["badge-minus"] = {1,24,24,350,25},
    ["cloud-sun"] = {1,24,24,225,550},
    ["circle"] = {1,24,24,75,650},
    ["shield-alert"] = {1,24,24,875,800},
    ["layers"] = {1,24,24,400,700},
    ["text-quote"] = {2,24,24,75,400},
    ["map-minus"] = {1,24,24,825,375},
    ["map-pin-x-inside"] = {1,24,24,550,650},
    ["text-cursor-input"] = {2,24,24,150,325},
    ["separator-vertical"] = {1,24,24,925,725},
    ["text-cursor"] = {2,24,24,125,350},
    ["file-braces"] = {1,24,24,250,650},
    ["scan-square"] = {1,24,24,800,800},
    ["ampersands"] = {1,24,24,150,50},
    ["text-align-justify-center"] = {2,24,24,275,200},
    ["user-search"] = {2,24,24,200,400},
    ["text-align-end"] = {2,24,24,300,175},
    ["fence"] = {1,24,24,425,475},
    ["circle-letter-d"] = {1,24,24,375,325},
    ["letter-h"] = {1,24,24,675,450},
    ["text-align-center"] = {2,24,24,325,150},
    ["test-tubes"] = {2,24,24,350,125},
    ["sunrise"] = {2,24,24,300,125},
    ["strikethrough"] = {2,24,24,50,350},
    ["calendar-days"] = {1,24,24,375,200},
    ["folder-bookmark"] = {1,24,24,250,700},
    ["test-tube-diagonal"] = {2,24,24,400,75},
    ["banknote-arrow-up"] = {1,24,24,325,75},
    ["layout-arrow-right"] = {1,24,24,350,750},
    ["square-padding-right"] = {2,24,24,0,300},
    ["dollar-sign"] = {1,24,24,225,625},
    ["message-square-quote"] = {1,24,24,875,375},
    ["brick-wall"] = {1,24,24,150,375},
    ["house-wifi"] = {1,24,24,75,975},
    ["tent"] = {2,24,24,450,25},
    ["list-minus"] = {1,24,24,300,850},
    ["cloud-hail"] = {1,24,24,450,325},
    ["telescope"] = {2,24,24,0,450},
    ["eye-closed"] = {1,24,24,825,75},
    ["app-window-mac"] = {1,24,24,225,0},
    ["grid-2x2-plus"] = {1,24,24,875,150},
    ["ellipsis"] = {1,24,24,225,650},
    ["copy-check"] = {1,24,24,300,500},
    ["tangent"] = {2,24,24,50,400},
    ["satellite"] = {1,24,24,875,700},
    ["bookmark-plus"] = {1,24,24,100,400},
    ["play"] = {1,24,24,625,800},
    ["folder-key"] = {1,24,24,925,50},
    ["coffee"] = {1,24,24,0,775},
    ["circle-power"] = {1,24,24,325,400},
    ["git-graph"] = {1,24,24,500,500},
    ["hourglass"] = {1,24,24,200,850},
    ["tickets-plane"] = {2,24,24,175,325},
    ["folder-git"] = {1,24,24,25,925},
    ["square-letter-b"] = {2,24,24,225,25},
    ["bomb"] = {1,24,24,375,100},
    ["layers-2"] = {1,24,24,525,575},
    ["battery-full"] = {1,24,24,100,300},
    ["chevrons-down"] = {1,24,24,100,550},
    ["circle-letter-q"] = {1,24,24,25,675},
    ["chart-gantt"] = {1,24,24,200,425},
    ["folder-tree"] = {1,24,24,600,375},
    ["command"] = {1,24,24,625,175},
    ["badge-dollar-sign"] = {1,24,24,75,275},
    ["align-start-vertical"] = {1,24,24,0,150},
    ["briefcase-conveyor-belt"] = {1,24,24,75,450},
    ["message-circle-question-mark"] = {1,24,24,525,700},
    ["tally-1"] = {2,24,24,175,275},
    ["bluetooth-off"] = {1,24,24,475,0},
    ["file-symlink"] = {1,24,24,225,700},
    ["square-square"] = {2,24,24,225,125},
    ["cannabis"] = {1,24,24,425,175},
    ["equal-approximately-not"] = {1,24,24,150,725},
    ["book"] = {1,24,24,200,300},
    ["grip-horizontal"] = {1,24,24,750,275},
    ["circle-minus"] = {1,24,24,525,200},
    ["audio-waveform"] = {1,24,24,0,325},
    ["moon-star"] = {1,24,24,525,750},
    ["arrow-down-narrow-wide"] = {1,24,24,250,25},
    ["letter-r"] = {1,24,24,425,700},
    ["database-backup"] = {1,24,24,225,600},
    ["wand"] = {2,24,24,475,175},
    ["receipt-turkish-lira"] = {1,24,24,500,975},
    ["tag"] = {2,24,24,225,225},
    ["calendar-minus-2"] = {1,24,24,300,275},
    ["copy-minus"] = {1,24,24,275,525},
    ["tablets"] = {2,24,24,300,150},
    ["folder-input"] = {1,24,24,975,0},
    ["book-image"] = {1,24,24,50,425},
    ["tablet-smartphone"] = {2,24,24,350,100},
    ["mouse-left"] = {1,24,24,325,950},
    ["tag-plus"] = {2,24,24,275,175},
    ["shirt"] = {1,24,24,950,775},
    ["maximize"] = {1,24,24,900,325},
    ["server-off"] = {1,24,24,825,825},
    ["move-up"] = {1,24,24,475,825},
    ["table-properties"] = {2,24,24,425,25},
    ["table-of-contents"] = {2,24,24,450,0},
    ["plug-2"] = {1,24,24,525,900},
    ["table-columns-split"] = {2,24,24,0,425},
    ["chess-rook"] = {1,24,24,300,350},
    ["brackets"] = {1,24,24,325,200},
    ["calendar-heart"] = {1,24,24,325,250},
    ["list-ordered"] = {1,24,24,250,900},
    ["table-cells-merge"] = {2,24,24,50,375},
    ["star-x"] = {2,24,24,50,325},
    ["mic-off"] = {1,24,24,600,650},
    ["table-2"] = {2,24,24,75,350},
    ["arrow-big-left"] = {1,24,24,200,50},
    ["square-split-horizontal"] = {2,24,24,275,75},
    ["table"] = {2,24,24,375,75},
    ["syringe"] = {2,24,24,100,325},
    ["clover"] = {1,24,24,100,675},
    ["sun-snow"] = {2,24,24,350,75},
    ["sofa"] = {1,24,24,950,900},
    ["sticky-note"] = {2,24,24,200,200},
    ["notepad-text"] = {1,24,24,700,625},
    ["funnel-x"] = {1,24,24,225,750},
    ["switch-camera"] = {2,24,24,175,250},
    ["clock-2"] = {1,24,24,275,475},
    ["calendar-fold"] = {1,24,24,350,225},
    ["fish-off"] = {1,24,24,800,150},
    ["baby"] = {1,24,24,225,125},
    ["database-x"] = {1,24,24,75,750},
    ["fold-vertical"] = {1,24,24,300,650},
    ["swiss-franc"] = {2,24,24,200,225},
    ["hop"] = {1,24,24,325,725},
    ["face-angry"] = {1,24,24,725,175},
    ["regex"] = {1,24,24,600,900},
    ["cigarette"] = {1,24,24,550,125},
    ["calendar-chevrons-right"] = {1,24,24,450,125},
    ["sunset"] = {2,24,24,275,150},
    ["sun-medium"] = {2,24,24,400,25},
    ["diamond-plus"] = {1,24,24,700,150},
    ["sun-dim"] = {2,24,24,425,0},
    ["file-chart-column"] = {1,24,24,200,700},
    ["triangle-dashed"] = {2,24,24,325,225},
    ["git-pull-request-closed"] = {1,24,24,400,600},
    ["badge-check"] = {1,24,24,100,250},
    ["list-chevrons-up-down"] = {1,24,24,500,650},
    ["subscript"] = {2,24,24,25,375},
    ["layers-arrow-up"] = {1,24,24,475,625},
    ["plug-zap"] = {1,24,24,500,925},
    ["heading-4"] = {1,24,24,850,200},
    ["chess-queen"] = {1,24,24,325,325},
    ["graduation-cap"] = {1,24,24,25,975},
    ["grid-3x2"] = {1,24,24,800,225},
    ["zodiac-sagittarius"] = {2,24,24,625,75},
    ["square-dashed-x-corner"] = {2,24,24,0,200},
    ["square-dashed-bottom-code"] = {2,24,24,175,25},
    ["clock-7"] = {1,24,24,150,600},
    ["ethernet-port"] = {1,24,24,25,850},
    ["scan-text"] = {1,24,24,775,825},
    ["stretch-horizontal"] = {2,24,24,100,300},
    ["shower-head"] = {1,24,24,775,950},
    ["equal-not"] = {1,24,24,100,775},
    ["ligature"] = {1,24,24,925,225},
    ["move-down"] = {1,24,24,625,675},
    ["clock-arrow-down"] = {1,24,24,50,700},
    ["ticket-slash"] = {2,24,24,250,250},
    ["ruler"] = {1,24,24,600,950},
    ["git-commit-vertical"] = {1,24,24,600,400},
    ["sticky-note-x"] = {2,24,24,225,175},
    ["circle-user-round"] = {1,24,24,150,575},
    ["chart-no-axes-column-decreasing"] = {1,24,24,125,500},
    ["dices"] = {1,24,24,500,350},
    ["list-filter"] = {1,24,24,375,775},
    ["map-pin-check"] = {1,24,24,775,425},
    ["egg-off"] = {1,24,24,400,475},
    ["sticky-note-minus"] = {2,24,24,300,100},
    ["cog"] = {1,24,24,800,0},
    ["dog"] = {1,24,24,250,600},
    ["sticky-note-check"] = {2,24,24,325,75},
    ["swords"] = {2,24,24,125,300},
    ["spotlight"] = {2,24,24,0,25},
    ["panel-right-dashed"] = {1,24,24,425,925},
    ["haze"] = {1,24,24,50,975},
    ["paper-bag"] = {1,24,24,775,600},
    ["truck-electric"] = {2,24,24,175,375},
    ["square-letter-h"] = {2,24,24,75,175},
    ["check-line"] = {1,24,24,525,125},
    ["step-back"] = {2,24,24,0,375},
    ["bubbles"] = {1,24,24,400,150},
    ["archive-arrow-down"] = {1,24,24,150,75},
    ["chart-bar-increasing"] = {1,24,24,450,175},
    ["star-off"] = {2,24,24,100,275},
    ["playing-card"] = {1,24,24,600,825},
    ["air-vent"] = {1,24,24,75,0},
    ["spade"] = {1,24,24,975,900},
    ["dot"] = {1,24,24,0,850},
    ["chart-bell-curve"] = {1,24,24,375,250},
    ["mouth"] = {1,24,24,775,525},
    ["armenian-dram"] = {1,24,24,25,200},
    ["clipboard-paste"] = {1,24,24,550,200},
    ["chevron-last"] = {1,24,24,225,425},
    ["book-heart"] = {1,24,24,75,400},
    ["panels-left-bottom"] = {1,24,24,850,525},
    ["monitor-activity"] = {1,24,24,925,350},
    ["globe-check"] = {1,24,24,225,775},
    ["cloud-check"] = {1,24,24,575,200},
    ["panel-left"] = {1,24,24,475,875},
    ["circle-chevron-right"] = {1,24,24,200,475},
    ["star"] = {2,24,24,25,350},
    ["stamp"] = {2,24,24,200,175},
    ["squares-unite"] = {2,24,24,300,75},
    ["arrow-down-up"] = {1,24,24,150,125},
    ["git-fork"] = {1,24,24,525,475},
    ["forward"] = {1,24,24,350,625},
    ["brain-circuit"] = {1,24,24,300,225},
    ["between-vertical-start"] = {1,24,24,325,125},
    ["database"] = {1,24,24,25,800},
    ["panel-right"] = {1,24,24,375,975},
    ["squirrel"] = {2,24,24,225,150},
    ["fast-forward"] = {1,24,24,500,400},
    ["squircle"] = {2,24,24,250,125},
    ["log-out"] = {1,24,24,525,650},
    ["git-branch-plus"] = {1,24,24,675,325},
    ["clipboard-minus"] = {1,24,24,575,175},
    ["file-text"] = {1,24,24,175,750},
    ["palette"] = {1,24,24,725,625},
    ["parasol"] = {1,24,24,725,650},
    ["squares-exclude"] = {2,24,24,375,0},
    ["table-rows-split"] = {2,24,24,400,50},
    ["milk-off"] = {1,24,24,375,875},
    ["tv-minimal"] = {2,24,24,0,550},
    ["cloud-upload"] = {1,24,24,175,600},
    ["banknote"] = {1,24,24,250,150},
    ["square-user"] = {2,24,24,50,300},
    ["message-circle-dashed-check"] = {1,24,24,675,550},
    ["drumstick"] = {1,24,24,650,225},
    ["square-text"] = {2,24,24,100,250},
    ["calendar-search"] = {1,24,24,150,425},
    ["square-kanban"] = {2,24,24,0,225},
    ["line-dot-top-vertical"] = {1,24,24,750,400},
    ["bell-ring"] = {1,24,24,450,0},
    ["circle-chevron-left"] = {1,24,24,225,450},
    ["list-chevrons-down-up"] = {1,24,24,525,625},
    ["arrow-down"] = {1,24,24,75,200},
    ["archive-arrow-up"] = {1,24,24,125,100},
    ["folder-dot"] = {1,24,24,100,850},
    ["shopping-bag"] = {1,24,24,925,800},
    ["circle-letter-r"] = {1,24,24,0,700},
    ["whole-word"] = {2,24,24,0,650},
    ["monitor"] = {1,24,24,550,725},
    ["disc-2"] = {1,24,24,450,400},
    ["trending-up-down"] = {2,24,24,400,150},
    ["save"] = {1,24,24,700,875},
    ["user-shield"] = {2,24,24,175,425},
    ["pyramid"] = {1,24,24,550,900},
    ["tv-minimal-play"] = {2,24,24,25,525},
    ["circle-stop"] = {1,24,24,175,550},
    ["align-vertical-space-around"] = {1,24,24,25,150},
    ["square-round-corner"] = {2,24,24,25,300},
    ["square-equal"] = {2,24,24,100,125},
    ["square-power"] = {2,24,24,75,250},
    ["arrow-big-down"] = {1,24,24,250,0},
    ["square-plus"] = {2,24,24,100,225},
    ["calendar-x-2"] = {1,24,24,100,475},
    ["user-plus"] = {2,24,24,550,50},
    ["move-diagonal-2"] = {1,24,24,725,575},
    ["bandage"] = {1,24,24,400,0},
    ["gallery-horizontal-end"] = {1,24,24,150,825},
    ["panel-top-dashed"] = {1,24,24,925,450},
    ["square-pilcrow"] = {2,24,24,150,175},
    ["square-pi"] = {2,24,24,175,150},
    ["tram-front"] = {2,24,24,50,475},
    ["line-squiggle"] = {1,24,24,700,450},
    ["square-pause"] = {2,24,24,250,75},
    ["square-padding-vertical"] = {2,24,24,300,25},
    ["audio-lines"] = {1,24,24,25,300},
    ["square-padding-top"] = {2,24,24,325,0},
    ["circle-letter-j"] = {1,24,24,225,475},
    ["square-padding-left"] = {2,24,24,25,275},
    ["square-padding-horizontal"] = {2,24,24,50,250},
    ["rocket"] = {1,24,24,700,825},
    ["dock"] = {1,24,24,275,575},
    ["ear-off"] = {1,24,24,600,275},
    ["copyleft"] = {1,24,24,150,650},
    ["save-check"] = {1,24,24,800,775},
    ["square-arrow-up-right"] = {2,24,24,50,75},
    ["square-letter-y"] = {2,24,24,250,50},
    ["printer"] = {1,24,24,650,800},
    ["megaphone-off"] = {1,24,24,850,375},
    ["square-letter-x"] = {2,24,24,275,25},
    ["arrow-big-right"] = {1,24,24,150,100},
    ["section"] = {1,24,24,700,925},
    ["file-clock"] = {1,24,24,75,825},
    ["logs"] = {1,24,24,500,675},
    ["toy-brick"] = {2,24,24,225,300},
    ["square-chevron-down"] = {2,24,24,175,0},
    ["dice-1"] = {1,24,24,650,200},
    ["drill"] = {1,24,24,800,75},
    ["app-window"] = {1,24,24,200,25},
    ["robot-vacuum"] = {1,24,24,725,800},
    ["hand-metal"] = {1,24,24,350,675},
    ["shrink"] = {1,24,24,925,825},
    ["spell-check-2"] = {1,24,24,950,950},
    ["square-letter-t"] = {2,24,24,50,225},
    ["square-letter-r"] = {2,24,24,100,175},
    ["list-plus"] = {1,24,24,225,925},
    ["square-letter-q"] = {2,24,24,125,150},
    ["rotate-ccw-key"] = {1,24,24,550,975},
    ["square-letter-p-off"] = {2,24,24,175,100},
    ["chart-pie"] = {1,24,24,0,625},
    ["eighth-notes"] = {1,24,24,325,550},
    ["circle-ellipsis"] = {1,24,24,625,75},
    ["copy-slash"] = {1,24,24,225,575},
    ["wind"] = {2,24,24,400,275},
    ["square-letter-n"] = {2,24,24,225,50},
    ["layout-panel-left"] = {1,24,24,200,900},
    ["square-letter-m"] = {2,24,24,250,25},
    ["circle-percent"] = {1,24,24,450,275},
    ["square-letter-l"] = {2,24,24,275,0},
    ["circle-arrow-out-down-right"] = {1,24,24,425,250},
    ["square-x"] = {2,24,24,25,325},
    ["italic"] = {1,24,24,450,625},
    ["chart-column-increasing"] = {1,24,24,275,350},
    ["flower"] = {1,24,24,375,575},
    ["step-forward"] = {2,24,24,400,0},
    ["file-chart-column-increasing"] = {1,24,24,225,675},
    ["a-arrow-down"] = {1,24,24,0,0},
    ["broom-sparkles"] = {1,24,24,500,50},
    ["sticker"] = {2,24,24,350,50},
    ["square-letter-e"] = {2,24,24,150,100},
    ["message-square-code"] = {1,24,24,350,875},
    ["square-letter-c"] = {2,24,24,200,50},
    ["brick-wall-fire"] = {1,24,24,200,325},
    ["square-kanban-plus"] = {2,24,24,25,200},
    ["margin-left"] = {1,24,24,350,850},
    ["import"] = {1,24,24,600,475},
    ["badge-turkish-lira"] = {1,24,24,175,200},
    ["square-terminal"] = {2,24,24,125,225},
    ["file-music"] = {1,24,24,600,325},
    ["square-function"] = {2,24,24,50,175},
    ["beef"] = {1,24,24,225,200},
    ["faucet"] = {1,24,24,475,425},
    ["file-user"] = {1,24,24,75,850},
    ["nut-off"] = {1,24,24,650,675},
    ["square-radical"] = {2,24,24,50,275},
    ["square-dot"] = {2,24,24,125,100},
    ["image-upscale"] = {1,24,24,675,400},
    ["book-type"] = {1,24,24,325,175},
    ["square-divide"] = {2,24,24,150,75},
    ["signpost-big"] = {1,24,24,900,875},
    ["receipt-euro"] = {1,24,24,675,800},
    ["cloudy"] = {1,24,24,125,650},
    ["square-letter-j"] = {2,24,24,25,225},
    ["rugby-ball"] = {1,24,24,650,900},
    ["repeat-2"] = {1,24,24,525,975},
    ["navigation-off"] = {1,24,24,350,950},
    ["arrow-left"] = {1,24,24,300,0},
    ["car-taxi-front"] = {1,24,24,300,300},
    ["rewind"] = {1,24,24,825,700},
    ["mouth-off"] = {1,24,24,800,500},
    ["chevrons-right-left"] = {1,24,24,0,650},
    ["square-padding-bottom"] = {2,24,24,75,225},
    ["git-commit-horizontal"] = {1,24,24,625,375},
    ["square-dashed-bottom"] = {2,24,24,150,50},
    ["square-code"] = {2,24,24,200,0},
    ["square-chevrons-up"] = {2,24,24,0,175},
    ["square-chevrons-left"] = {2,24,24,50,125},
    ["square-dimensions"] = {2,24,24,175,50},
    ["face-slightly-smiling"] = {1,24,24,575,325},
    ["align-end-horizontal"] = {1,24,24,100,25},
    ["layer-arrow-down"] = {1,24,24,575,525},
    ["equal"] = {1,24,24,75,800},
    ["megaphone"] = {1,24,24,825,400},
    ["calendar-x"] = {1,24,24,75,500},
    ["map-pin-x"] = {1,24,24,525,675},
    ["square-chevron-left"] = {2,24,24,150,25},
    ["egg"] = {1,24,24,375,500},
    ["container"] = {1,24,24,400,400},
    ["ruler-dimension-line"] = {1,24,24,625,925},
    ["ship-cargo"] = {1,24,24,750,950},
    ["circle-pound-sterling"] = {1,24,24,350,375},
    ["video-off"] = {2,24,24,275,350},
    ["japanese-yen"] = {1,24,24,350,725},
    ["square-centerline-dashed-vertical"] = {2,24,24,75,75},
    ["square-bottom-dashed-scissors"] = {2,24,24,125,25},
    ["square-bookmark"] = {2,24,24,150,0},
    ["library"] = {1,24,24,975,175},
    ["file-terminal"] = {1,24,24,200,725},
    ["circle-chevron-down"] = {1,24,24,250,425},
    ["accessibility"] = {1,24,24,50,0},
    ["square-asterisk"] = {2,24,24,0,125},
    ["square-library"] = {2,24,24,200,100},
    ["amphora"] = {1,24,24,125,75},
    ["hourglass-cog"] = {1,24,24,225,825},
    ["tally-2"] = {2,24,24,150,300},
    ["mop"] = {1,24,24,450,825},
    ["square-arrow-right-exit"] = {2,24,24,125,0},
    ["building-complex"] = {1,24,24,275,275},
    ["square-arrow-right-enter"] = {2,24,24,0,100},
    ["sheet"] = {1,24,24,950,725},
    ["circle-check-big"] = {1,24,24,300,375},
    ["square-arrow-right"] = {2,24,24,100,25},
    ["square-arrow-out-up-right"] = {2,24,24,25,75},
    ["map-pinned"] = {1,24,24,475,725},
    ["circle-letter-y"] = {1,24,24,575,150},
    ["circuit-board"] = {1,24,24,50,675},
    ["square-arrow-out-up-left"] = {2,24,24,50,50},
    ["loader-circle"] = {1,24,24,800,375},
    ["square-arrow-out-down-left"] = {2,24,24,100,0},
    ["square-arrow-left"] = {2,24,24,0,75},
    ["folder-open-dot"] = {1,24,24,850,125},
    ["book-dashed"] = {1,24,24,150,325},
    ["square-arrow-down-right"] = {2,24,24,50,25},
    ["flask-round"] = {1,24,24,425,525},
    ["bluetooth"] = {1,24,24,425,50},
    ["tree-pine"] = {2,24,24,475,75},
    ["receipt-indian-rupee"] = {1,24,24,650,825},
    ["square"] = {2,24,24,0,350},
    ["sprout"] = {2,24,24,25,25},
    ["spray-can"] = {2,24,24,50,0},
    ["sport-shoe"] = {2,24,24,25,0},
    ["refrigerator"] = {1,24,24,625,875},
    ["can-soda"] = {1,24,24,575,25},
    ["flask-conical"] = {1,24,24,450,500},
    ["radiation"] = {1,24,24,950,525},
    ["funnel"] = {1,24,24,200,775},
    ["square-star"] = {2,24,24,175,175},
    ["folder-sync"] = {1,24,24,625,350},
    ["monitor-pc"] = {1,24,24,725,550},
    ["zodiac-ophiuchus"] = {2,24,24,675,25},
    ["speech"] = {1,24,24,975,925},
    ["speaker"] = {1,24,24,900,975},
    ["arrow-up-narrow-wide"] = {1,24,24,0,300},
    ["fishing-hook"] = {1,24,24,725,225},
    ["phone-log"] = {1,24,24,675,725},
    ["sparkles"] = {1,24,24,925,950},
    ["sparkle"] = {1,24,24,950,925},
    ["frame"] = {1,24,24,325,650},
    ["calendar-arrow-down"] = {1,24,24,25,525},
    ["clock-12"] = {1,24,24,300,450},
    ["star-minus"] = {2,24,24,125,250},
    ["euro"] = {1,24,24,0,875},
    ["soup"] = {1,24,24,900,950},
    ["images"] = {1,24,24,625,450},
    ["lollipop"] = {1,24,24,475,700},
    ["book-text"] = {1,24,24,350,150},
    ["solar-panel"] = {1,24,24,925,925},
    ["lamp-floor"] = {1,24,24,900,200},
    ["file-plus-corner"] = {1,24,24,475,450},
    ["image"] = {1,24,24,650,425},
    ["soap-dispenser-droplet"] = {1,24,24,975,875},
    ["badge-euro"] = {1,24,24,50,300},
    ["bike"] = {1,24,24,275,175},
    ["angle"] = {1,24,24,75,125},
    ["snowflake"] = {1,24,24,850,975},
    ["snail"] = {1,24,24,875,950},
    ["smartphone-user-round"] = {1,24,24,925,900},
    ["smartphone-nfc"] = {1,24,24,950,875},
    ["smartphone-charging"] = {1,24,24,975,850},
    ["smartphone"] = {1,24,24,900,925},
    ["option"] = {1,24,24,450,875},
    ["banknote-check"] = {1,24,24,300,100},
    ["scroll-text"] = {1,24,24,900,725},
    ["server-plus"] = {1,24,24,800,850},
    ["sliders-vertical"] = {1,24,24,825,975},
    ["sliders-horizontal"] = {1,24,24,850,950},
    ["mouse-off"] = {1,24,24,300,975},
    ["toggle-right"] = {2,24,24,0,500},
    ["skull"] = {1,24,24,925,875},
    ["ferris-wheel"] = {1,24,24,400,500},
    ["camera-off"] = {1,24,24,0,575},
    ["sixteenth-notes"] = {1,24,24,800,975},
    ["siren"] = {1,24,24,825,950},
    ["server-cog"] = {1,24,24,900,750},
    ["signature"] = {1,24,24,925,850},
    ["signal-zero"] = {1,24,24,975,800},
    ["group"] = {1,24,24,650,375},
    ["signal-medium"] = {1,24,24,775,975},
    ["battery"] = {1,24,24,425,0},
    ["signal-low"] = {1,24,24,800,950},
    ["tent-tree"] = {2,24,24,475,0},
    ["sigma"] = {1,24,24,850,900},
    ["rectangle-horizontal"] = {1,24,24,875,625},
    ["shuffle"] = {1,24,24,875,875},
    ["square-letter-u"] = {2,24,24,25,250},
    ["shrimp"] = {1,24,24,950,800},
    ["bitcoin"] = {1,24,24,125,325},
    ["gap-vertical"] = {1,24,24,925,75},
    ["battery-plus"] = {1,24,24,25,375},
    ["circle-letter-h"] = {1,24,24,275,425},
    ["loader-pinwheel"] = {1,24,24,775,400},
    ["file-diff"] = {1,24,24,900,25},
    ["shopping-cart-plus"] = {1,24,24,850,875},
    ["rotate-ccw-clock"] = {1,24,24,575,950},
    ["message-circle-heart"] = {1,24,24,625,600},
    ["spline-pointer"] = {1,24,24,975,950},
    ["ship-wheel"] = {1,24,24,725,975},
    ["axis-3d"] = {1,24,24,275,75},
    ["shield-x"] = {1,24,24,800,900},
    ["shield-user"] = {1,24,24,825,875},
    ["binoculars"] = {1,24,24,225,225},
    ["shield-question-mark"] = {1,24,24,850,850},
    ["shield-plus"] = {1,24,24,875,825},
    ["shield-off"] = {1,24,24,900,800},
    ["rose"] = {1,24,24,625,900},
    ["folder-symlink"] = {1,24,24,650,325},
    ["mail-minus"] = {1,24,24,300,875},
    ["shield-lock"] = {1,24,24,950,750},
    ["shield-keyhole"] = {1,24,24,975,725},
    ["shield-half"] = {1,24,24,725,950},
    ["shield-cog-corner"] = {1,24,24,800,875},
    ["clipboard-pen"] = {1,24,24,500,250},
    ["bottle-wine"] = {1,24,24,475,50},
    ["alarm-clock-off"] = {1,24,24,100,0},
    ["shield-cog"] = {1,24,24,775,900},
    ["list"] = {1,24,24,825,350},
    ["shield-check"] = {1,24,24,825,850},
    ["margin-horizontal"] = {1,24,24,375,825},
    ["dome"] = {1,24,24,200,650},
    ["badge-pound-sterling"] = {1,24,24,275,100},
    ["bookmark-check"] = {1,24,24,175,325},
    ["shield-ban"] = {1,24,24,850,825},
    ["wrench-off"] = {2,24,24,275,400},
    ["shelving-unit"] = {1,24,24,900,775},
    ["a-arrow-up"] = {1,24,24,25,0},
    ["clock-check"] = {1,24,24,750,25},
    ["shell"] = {1,24,24,925,750},
    ["flask-conical-off"] = {1,24,24,475,475},
    ["vibrate-off"] = {2,24,24,325,300},
    ["face-grinning"] = {1,24,24,675,225},
    ["zodiac-cancer"] = {2,24,24,75,600},
    ["settings-2"] = {1,24,24,750,900},
    ["file-code"] = {1,24,24,25,875},
    ["letter-s"] = {1,24,24,400,725},
    ["carton-off"] = {1,24,24,175,425},
    ["credit-card-reader"] = {1,24,24,625,200},
    ["settings"] = {1,24,24,725,925},
    ["cassette-tape"] = {1,24,24,50,550},
    ["battery-low"] = {1,24,24,75,325},
    ["server-nas"] = {1,24,24,850,800},
    ["server-crash"] = {1,24,24,875,775},
    ["signpost"] = {1,24,24,875,900},
    ["server"] = {1,24,24,775,875},
    ["calendar-arrow-up"] = {1,24,24,550,25},
    ["landmark"] = {1,24,24,775,325},
    ["fish-symbol"] = {1,24,24,775,175},
    ["trash-off"] = {2,24,24,0,525},
    ["loader"] = {1,24,24,750,425},
    ["search-x"] = {1,24,24,750,875},
    ["dice-2"] = {1,24,24,625,225},
    ["file-type"] = {1,24,24,125,800},
    ["clipboard-clock"] = {1,24,24,650,100},
    ["beer"] = {1,24,24,175,250},
    ["lectern"] = {1,24,24,950,175},
    ["search-slash"] = {1,24,24,775,850},
    ["search-code"] = {1,24,24,800,825},
    ["crosshair"] = {1,24,24,475,350},
    ["binary"] = {1,24,24,250,200},
    ["move-diagonal"] = {1,24,24,700,600},
    ["search-alert"] = {1,24,24,850,775},
    ["door-closed"] = {1,24,24,75,775},
    ["cpu-ai"] = {1,24,24,775,50},
    ["layout-template"] = {1,24,24,150,950},
    ["file-database"] = {1,24,24,925,0},
    ["search"] = {1,24,24,725,900},
    ["scroll"] = {1,24,24,875,750},
    ["bookmark-off"] = {1,24,24,125,375},
    ["hand-heart"] = {1,24,24,400,625},
    ["screen-share-off"] = {1,24,24,975,650},
    ["scan-qr-code"] = {1,24,24,850,750},
    ["message-square-check"] = {1,24,24,375,850},
    ["screen-share"] = {1,24,24,950,675},
    ["link-2-off"] = {1,24,24,650,500},
    ["expand"] = {1,24,24,875,25},
    ["brain"] = {1,24,24,225,300},
    ["panel-top"] = {1,24,24,875,500},
    ["school"] = {1,24,24,725,875},
    ["numbers"] = {1,24,24,675,650},
    ["key"] = {1,24,24,175,900},
    ["clock-11"] = {1,24,24,325,425},
    ["scan-search"] = {1,24,24,825,775},
    ["ticket-plus"] = {2,24,24,275,225},
    ["arrow-up-0-1"] = {1,24,24,175,125},
    ["bell-electric"] = {1,24,24,75,350},
    ["list-checks"] = {1,24,24,550,600},
    ["monitor-pause"] = {1,24,24,750,525},
    ["book-open-check"] = {1,24,24,475,25},
    ["panel-top-close"] = {1,24,24,950,425},
    ["lasso-select"] = {1,24,24,625,475},
    ["scan-face"] = {1,24,24,925,675},
    ["sailboat"] = {1,24,24,975,600},
    ["scan-box"] = {1,24,24,975,625},
    ["scan-barcode"] = {1,24,24,600,975},
    ["bus"] = {1,24,24,200,350},
    ["scan"] = {1,24,24,750,850},
    ["audio-lines-x"] = {1,24,24,50,275},
    ["chart-no-axes-gantt"] = {1,24,24,25,600},
    ["file-spreadsheet"] = {1,24,24,275,650},
    ["save-off"] = {1,24,24,775,800},
    ["chart-radar"] = {1,24,24,625,25},
    ["move-down-right"] = {1,24,24,650,650},
    ["contact-round"] = {1,24,24,450,350},
    ["save-plus"] = {1,24,24,725,850},
    ["keyboard-off"] = {1,24,24,125,950},
    ["monitor-up"] = {1,24,24,600,675},
    ["file-badge"] = {1,24,24,325,575},
    ["battery-warning"] = {1,24,24,0,400},
    ["circle-letter-e"] = {1,24,24,350,350},
    ["arrow-down-from-line"] = {1,24,24,0,250},
    ["briefcase"] = {1,24,24,0,525},
    ["biohazard"] = {1,24,24,200,250},
    ["rectangle-circle"] = {1,24,24,950,550},
    ["braces"] = {1,24,24,350,175},
    ["scale-3d"] = {1,24,24,675,900},
    ["panel-top-bottom-dashed"] = {1,24,24,975,400},
    ["mail-x"] = {1,24,24,925,275},
    ["square-dashed-mouse-pointer"] = {2,24,24,100,100},
    ["square-sparkles"] = {2,24,24,300,50},
    ["lock-open"] = {1,24,24,600,575},
    ["saudi-riyal"] = {1,24,24,850,725},
    ["pizza"] = {1,24,24,775,650},
    ["list-indent-decrease"] = {1,24,24,350,800},
    ["arrow-up-wide-narrow"] = {1,24,24,275,50},
    ["satellite-dish"] = {1,24,24,900,675},
    ["clock-5"] = {1,24,24,200,550},
    ["sandwich"] = {1,24,24,925,650},
    ["rotate-ccw"] = {1,24,24,950,600},
    ["align-horizontal-justify-center"] = {1,24,24,150,0},
    ["salad"] = {1,24,24,950,625},
    ["antenna"] = {1,24,24,50,150},
    ["memory-stick"] = {1,24,24,800,425},
    ["scan-eye"] = {1,24,24,950,650},
    ["panel-left-right-dashed"] = {1,24,24,500,850},
    ["square-check"] = {2,24,24,0,150},
    ["heart-plus"] = {1,24,24,600,450},
    ["door-closed-cog"] = {1,24,24,150,700},
    ["map-pin-minus-inside"] = {1,24,24,725,475},
    ["git-merge"] = {1,24,24,450,550},
    ["gallery-vertical-end"] = {1,24,24,75,900},
    ["square-dashed-plus"] = {2,24,24,75,125},
    ["hand-coins"] = {1,24,24,475,550},
    ["zodiac-capricorn"] = {2,24,24,50,625},
    ["wifi-low"] = {2,24,24,600,75},
    ["rows-2"] = {1,24,24,750,800},
    ["clock"] = {1,24,24,675,100},
    ["file-pen"] = {1,24,24,525,400},
    ["git-compare-arrows"] = {1,24,24,575,425},
    ["cloud-sun-rain"] = {1,24,24,250,525},
    ["align-horizontal-justify-start"] = {1,24,24,100,50},
    ["router"] = {1,24,24,775,775},
    ["route-off"] = {1,24,24,825,725},
    ["route"] = {1,24,24,800,750},
    ["calendar-plus"] = {1,24,24,200,375},
    ["newspaper"] = {1,24,24,925,400},
    ["arrow-down-z-a"] = {1,24,24,100,175},
    ["bath"] = {1,24,24,150,250},
    ["rotate-cw-fading-clock"] = {1,24,24,900,650},
    ["unlink-2"] = {2,24,24,250,325},
    ["projector"] = {1,24,24,625,825},
    ["shopping-cart-minus"] = {1,24,24,875,850},
    ["belarusian-ruble"] = {1,24,24,150,275},
    ["rotate-3d"] = {1,24,24,600,925},
    ["book-key"] = {1,24,24,25,450},
    ["ribbon"] = {1,24,24,800,725},
    ["microwave"] = {1,24,24,450,800},
    ["roller-coaster"] = {1,24,24,650,875},
    ["gallery-vertical"] = {1,24,24,50,925},
    ["magnet"] = {1,24,24,425,750},
    ["robot-arm"] = {1,24,24,750,775},
    ["square-dashed-text"] = {2,24,24,50,150},
    ["map-pin-pen"] = {1,24,24,650,550},
    ["move-up-left"] = {1,24,24,525,775},
    ["heart-pulse"] = {1,24,24,575,475},
    ["folder-heart"] = {1,24,24,0,950},
    ["reply"] = {1,24,24,850,675},
    ["replace-all"] = {1,24,24,925,600},
    ["replace"] = {1,24,24,900,625},
    ["arrow-up-a-z"] = {1,24,24,125,175},
    ["repeat-off"] = {1,24,24,975,550},
    ["square-dashed-top-solid"] = {2,24,24,25,175},
    ["repeat-1"] = {1,24,24,550,950},
    ["repeat"] = {1,24,24,950,575},
    ["remove-formatting"] = {1,24,24,575,925},
    ["swatch-book"] = {2,24,24,225,200},
    ["receipt-cent"] = {1,24,24,700,775},
    ["spool"] = {2,24,24,0,0},
    ["folder-archive"] = {1,24,24,275,675},
    ["emirati-dirham"] = {1,24,24,200,675},
    ["can"] = {1,24,24,550,50},
    ["ban"] = {1,24,24,25,350},
    ["message-square-x"] = {1,24,24,750,500},
    ["paint-roller"] = {1,24,24,800,550},
    ["refresh-cw-off"] = {1,24,24,675,825},
    ["archive"] = {1,24,24,75,150},
    ["refresh-cw"] = {1,24,24,650,850},
    ["monitor-speaker"] = {1,24,24,650,625},
    ["cloud-backup"] = {1,24,24,600,175},
    ["circle-slash-2"] = {1,24,24,275,450},
    ["iteration-cw"] = {1,24,24,400,675},
    ["cake"] = {1,24,24,100,450},
    ["cloud-rain"] = {1,24,24,300,475},
    ["chart-bar"] = {1,24,24,400,225},
    ["redo"] = {1,24,24,750,750},
    ["wrench"] = {2,24,24,250,425},
    ["rectangle-vertical"] = {1,24,24,850,650},
    ["rectangle-goggles"] = {1,24,24,900,600},
    ["folder-root"] = {1,24,24,725,250},
    ["flag-triangle-right"] = {1,24,24,625,325},
    ["receipt-swiss-franc"] = {1,24,24,550,925},
    ["receipt-russian-ruble"] = {1,24,24,575,900},
    ["bell"] = {1,24,24,425,25},
    ["kayak"] = {1,24,24,275,800},
    ["receipt-japanese-yen"] = {1,24,24,625,850},
    ["square-chevron-up"] = {2,24,24,100,75},
    ["chart-bar-big"] = {1,24,24,500,125},
    ["user-check"] = {2,24,24,100,475},
    ["proportions"] = {1,24,24,600,850},
    ["ratio"] = {1,24,24,725,750},
    ["plane"] = {1,24,24,700,725},
    ["webhook-off"] = {2,24,24,175,475},
    ["carrot"] = {1,24,24,200,400},
    ["letter-v"] = {1,24,24,300,825},
    ["file-cog"] = {1,24,24,0,900},
    ["circle-dashed"] = {1,24,24,25,650},
    ["rainbow"] = {1,24,24,775,700},
    ["locate-fixed"] = {1,24,24,725,450},
    ["radio-receiver"] = {1,24,24,875,600},
    ["database-cog"] = {1,24,24,175,650},
    ["squares-subtract"] = {2,24,24,325,50},
    ["radio"] = {1,24,24,825,650},
    ["plug"] = {1,24,24,475,950},
    ["split"] = {1,24,24,975,975},
    ["hot-air-balloon"] = {1,24,24,275,775},
    ["radar"] = {1,24,24,975,500},
    ["forklift"] = {1,24,24,400,575},
    ["quote"] = {1,24,24,500,950},
    ["alarm-clock-minus"] = {1,24,24,0,75},
    ["heart-x"] = {1,24,24,550,500},
    ["eraser"] = {1,24,24,50,825},
    ["square-sigma"] = {2,24,24,350,0},
    ["puzzle"] = {1,24,24,575,875},
    ["bluetooth-connected"] = {1,24,24,0,450},
    ["rotate-ccw-square"] = {1,24,24,975,575},
    ["chart-no-axes-column"] = {1,24,24,75,550},
    ["cannabis-off"] = {1,24,24,450,150},
    ["folder-kanban"] = {1,24,24,950,25},
    ["heart"] = {1,24,24,525,525},
    ["mars-stroke"] = {1,24,24,225,975},
    ["printer-check"] = {1,24,24,700,750},
    ["letter-t"] = {1,24,24,350,775},
    ["power-off"] = {1,24,24,800,650},
    ["file-box"] = {1,24,24,300,600},
    ["power"] = {1,24,24,775,675},
    ["paint-bucket"] = {1,24,24,825,525},
    ["glass-water"] = {1,24,24,275,725},
    ["pound-sterling"] = {1,24,24,825,625},
    ["glasses"] = {1,24,24,250,750},
    ["piggy-bank"] = {1,24,24,425,975},
    ["popsicle"] = {1,24,24,850,600},
    ["cuboid"] = {1,24,24,425,400},
    ["cloud-off"] = {1,24,24,350,425},
    ["check-check"] = {1,24,24,550,100},
    ["activity"] = {1,24,24,25,25},
    ["axe"] = {1,24,24,300,50},
    ["plane-takeoff"] = {1,24,24,725,700},
    ["file-down"] = {1,24,24,850,75},
    ["cloud-rain-wind"] = {1,24,24,325,450},
    ["helicopter"] = {1,24,24,475,575},
    ["plus"] = {1,24,24,450,975},
    ["copy-x"] = {1,24,24,200,600},
    ["file-axis-3d"] = {1,24,24,350,550},
    ["radical"] = {1,24,24,925,550},
    ["chart-column-decreasing"] = {1,24,24,300,325},
    ["move-3d"] = {1,24,24,750,550},
    ["bug-play"] = {1,24,24,350,200},
    ["align-vertical-distribute-start"] = {1,24,24,125,50},
    ["playing-cards"] = {1,24,24,550,875},
    ["waves-arrow-up"] = {2,24,24,350,300},
    ["tally-5"] = {2,24,24,75,375},
    ["plane-landing"] = {1,24,24,750,675},
    ["pin-off"] = {1,24,24,850,575},
    ["pin"] = {1,24,24,825,600},
    ["circle-divide"] = {1,24,24,0,675},
    ["pill"] = {1,24,24,875,550},
    ["file-minus"] = {1,24,24,625,300},
    ["pilcrow-left"] = {1,24,24,975,450},
    ["life-buoy"] = {1,24,24,950,200},
    ["paw-print"] = {1,24,24,575,800},
    ["pickaxe"] = {1,24,24,500,900},
    ["volume-2"] = {2,24,24,50,575},
    ["battery-charging"] = {1,24,24,125,275},
    ["russian-ruble"] = {1,24,24,575,975},
    ["square-arrow-up-left"] = {2,24,24,75,50},
    ["brick-wall-shield"] = {1,24,24,175,350},
    ["footprints"] = {1,24,24,425,550},
    ["phone-off"] = {1,24,24,625,775},
    ["building"] = {1,24,24,250,300},
    ["phone-incoming"] = {1,24,24,700,700},
    ["phone-forwarded"] = {1,24,24,725,675},
    ["phone"] = {1,24,24,575,825},
    ["tag-x"] = {2,24,24,250,200},
    ["book-alert"] = {1,24,24,275,200},
    ["link-2"] = {1,24,24,625,525},
    ["astroid"] = {1,24,24,150,175},
    ["bell-minus"] = {1,24,24,50,375},
    ["image-up"] = {1,24,24,700,375},
    ["closed-caption"] = {1,24,24,650,125},
    ["drum"] = {1,24,24,675,200},
    ["arrow-up-z-a"] = {1,24,24,250,75},
    ["sun"] = {2,24,24,325,100},
    ["perfume-bottle"] = {1,24,24,850,550},
    ["percent"] = {1,24,24,875,525},
    ["file-key"] = {1,24,24,700,225},
    ["pentagon"] = {1,24,24,900,500},
    ["pencil-off"] = {1,24,24,400,975},
    ["scissors-line-dashed"] = {1,24,24,700,900},
    ["contact"] = {1,24,24,425,375},
    ["pen-off"] = {1,24,24,500,875},
    ["ball-wave"] = {1,24,24,75,300},
    ["ticket-check"] = {2,24,24,350,150},
    ["combine"] = {1,24,24,650,150},
    ["gamepad"] = {1,24,24,975,25},
    ["pc-case"] = {1,24,24,550,825},
    ["mountain"] = {1,24,24,350,925},
    ["mars"] = {1,24,24,975,250},
    ["picture-in-picture-2"] = {1,24,24,475,925},
    ["radio-off"] = {1,24,24,900,575},
    ["flower-2"] = {1,24,24,400,550},
    ["bed-single"] = {1,24,24,300,125},
    ["squares-intersect"] = {2,24,24,350,25},
    ["paperclip"] = {1,24,24,750,625},
    ["calculator"] = {1,24,24,75,475},
    ["keyboard-music"] = {1,24,24,150,925},
    ["star-half"] = {2,24,24,150,225},
    ["playing-cards-fan"] = {1,24,24,575,850},
    ["code-xml"] = {1,24,24,50,725},
    ["pencil-line"] = {1,24,24,425,950},
    ["circle-letter-t"] = {1,24,24,700,25},
    ["brain-cog"] = {1,24,24,275,250},
    ["tablet"] = {2,24,24,325,125},
    ["panel-right-close"] = {1,24,24,450,900},
    ["pi"] = {1,24,24,550,850},
    ["trash"] = {2,24,24,550,0},
    ["book-down"] = {1,24,24,125,350},
    ["hdmi-port"] = {1,24,24,950,100},
    ["calendar-arrow-right"] = {1,24,24,575,0},
    ["case-upper"] = {1,24,24,75,525},
    ["circle-fading-arrow-up"] = {1,24,24,550,150},
    ["chart-quadrant"] = {1,24,24,650,0},
    ["croissant"] = {1,24,24,550,275},
    ["panel-left-dashed"] = {1,24,24,550,800},
    ["letter-o"] = {1,24,24,500,625},
    ["barcode"] = {1,24,24,225,175},
    ["gap-horizontal"] = {1,24,24,950,50},
    ["panel-bottom-close"] = {1,24,24,675,675},
    ["bed"] = {1,24,24,275,150},
    ["panel-bottom"] = {1,24,24,600,750},
    ["divide"] = {1,24,24,350,500},
    ["grape"] = {1,24,24,975,50},
    ["panda"] = {1,24,24,700,650},
    ["party-popper"] = {1,24,24,625,750},
    ["file-chart-pie"] = {1,24,24,150,750},
    ["paintbrush-vertical"] = {1,24,24,775,575},
    ["network"] = {1,24,24,950,375},
    ["dice-6"] = {1,24,24,525,325},
    ["package-search"] = {1,24,24,900,450},
    ["blender"] = {1,24,24,75,375},
    ["package-plus"] = {1,24,24,925,425},
    ["zap-off"] = {2,24,24,175,500},
    ["square-check-big"] = {2,24,24,25,125},
    ["package-2"] = {1,24,24,375,950},
    ["package"] = {1,24,24,850,500},
    ["origami"] = {1,24,24,400,925},
    ["laptop-minimal"] = {1,24,24,700,400},
    ["orbit"] = {1,24,24,425,900},
    ["omega"] = {1,24,24,475,850},
    ["map-pin-minus"] = {1,24,24,700,500},
    ["ice-cream-bowl"] = {1,24,24,925,150},
    ["chart-spline"] = {1,24,24,575,75},
    ["message-square-more"] = {1,24,24,950,300},
    ["octagon-pause"] = {1,24,24,550,775},
    ["chart-candlestick"] = {1,24,24,350,275},
    ["octagon-minus"] = {1,24,24,575,750},
    ["arrow-down-a-z"] = {1,24,24,25,225},
    ["line-dot-right-horizontal"] = {1,24,24,775,375},
    ["certificate"] = {1,24,24,550,75},
    ["move-horizontal"] = {1,24,24,600,700},
    ["file-sliders"] = {1,24,24,300,625},
    ["circle-letter-c"] = {1,24,24,400,300},
    ["square-exclamation-point"] = {2,24,24,75,150},
    ["cup-soda"] = {1,24,24,400,425},
    ["nut"] = {1,24,24,625,700},
    ["notepad-text-dashed"] = {1,24,24,725,600},
    ["sword"] = {2,24,24,150,275},
    ["hospital"] = {1,24,24,300,750},
    ["notebook-pen"] = {1,24,24,825,500},
    ["earth"] = {1,24,24,475,400},
    ["slice"] = {1,24,24,875,925},
    ["dice-3"] = {1,24,24,600,250},
    ["milk"] = {1,24,24,350,900},
    ["mouse-pointer-ban"] = {1,24,24,925,375},
    ["crown"] = {1,24,24,450,375},
    ["circle-letter-k"] = {1,24,24,200,500},
    ["circle-star"] = {1,24,24,200,525},
    ["rotate-cw-square"] = {1,24,24,875,675},
    ["atom"] = {1,24,24,100,225},
    ["package-x"] = {1,24,24,875,475},
    ["bed-double"] = {1,24,24,325,100},
    ["nepali-rupee"] = {1,24,24,975,350},
    ["circle-dot"] = {1,24,24,650,50},
    ["file-exclamation-point"] = {1,24,24,825,100},
    ["hand-fist"] = {1,24,24,450,575},
    ["message-circle-code"] = {1,24,24,700,525},
    ["folder-git-2"] = {1,24,24,50,900},
    ["letter-k"] = {1,24,24,600,525},
    ["navigation-2"] = {1,24,24,375,925},
    ["towel-rack"] = {2,24,24,275,250},
    ["move-up-right"] = {1,24,24,500,800},
    ["arrow-big-left-dash"] = {1,24,24,225,25},
    ["move-right"] = {1,24,24,550,750},
    ["dumbbell"] = {1,24,24,625,250},
    ["move-left"] = {1,24,24,575,725},
    ["letter-a"] = {1,24,24,850,275},
    ["houses"] = {1,24,24,950,125},
    ["scale"] = {1,24,24,650,925},
    ["move-down-left"] = {1,24,24,675,625},
    ["flashlight"] = {1,24,24,500,450},
    ["panel-top-open"] = {1,24,24,900,475},
    ["layout-panel-top"] = {1,24,24,175,925},
    ["mouse-pointer"] = {1,24,24,875,425},
    ["notebook"] = {1,24,24,750,575},
    ["redo-2"] = {1,24,24,800,700},
    ["circle-alert"] = {1,24,24,525,150},
    ["square-menu"] = {2,24,24,175,125},
    ["margin"] = {1,24,24,250,950},
    ["monitor-smartphone"] = {1,24,24,675,600},
    ["laptop"] = {1,24,24,675,425},
    ["scan-line"] = {1,24,24,875,725},
    ["clock-4"] = {1,24,24,225,525},
    ["square-arrow-up"] = {2,24,24,25,100},
    ["book-minus"] = {1,24,24,500,0},
    ["file-question-mark"] = {1,24,24,425,500},
    ["moon"] = {1,24,24,500,775},
    ["line-style"] = {1,24,24,675,475},
    ["save-pen"] = {1,24,24,750,825},
    ["arrow-down-to-line"] = {1,24,24,175,100},
    ["monitor-stop"] = {1,24,24,625,650},
    ["refresh-ccw"] = {1,24,24,700,800},
    ["venetian-mask"] = {2,24,24,400,225},
    ["calendar-check-2"] = {1,24,24,525,50},
    ["monitor-off"] = {1,24,24,775,500},
    ["spline"] = {1,24,24,950,975},
    ["banknote-x"] = {1,24,24,275,125},
    ["git-pull-request-create-arrow"] = {1,24,24,375,625},
    ["monitor-dot"] = {1,24,24,825,450},
    ["circle-check"] = {1,24,24,275,400},
    ["monitor-cog"] = {1,24,24,850,425},
    ["monitor-check"] = {1,24,24,900,375},
    ["mirror-rectangular"] = {1,24,24,975,300},
    ["minus"] = {1,24,24,275,975},
    ["cookie"] = {1,24,24,350,450},
    ["iteration-ccw"] = {1,24,24,425,650},
    ["timer-off"] = {2,24,24,100,400},
    ["arrow-big-right-dash"] = {1,24,24,175,75},
    ["microscope"] = {1,24,24,475,775},
    ["mic-vocal"] = {1,24,24,550,700},
    ["mic-signal"] = {1,24,24,575,675},
    ["backpack"] = {1,24,24,200,150},
    ["mic-audio-lines"] = {1,24,24,625,625},
    ["letter-spacing"] = {1,24,24,375,750},
    ["mic"] = {1,24,24,525,725},
    ["case-lower"] = {1,24,24,125,475},
    ["letter-f"] = {1,24,24,725,400},
    ["arrow-down-right"] = {1,24,24,225,50},
    ["messages-circle"] = {1,24,24,700,550},
    ["letters"] = {1,24,24,175,950},
    ["wifi-zero"] = {2,24,24,500,175},
    ["message-square-text"] = {1,24,24,800,450},
    ["message-square-share"] = {1,24,24,825,425},
    ["letter-z"] = {1,24,24,200,925},
    ["layout-grid-circles"] = {1,24,24,275,825},
    ["image-off"] = {1,24,24,775,300},
    ["list-collapse"] = {1,24,24,450,700},
    ["message-square-plus"] = {1,24,24,900,350},
    ["message-square-lock"] = {1,24,24,975,275},
    ["message-square-heart"] = {1,24,24,250,975},
    ["square-chevron-right"] = {2,24,24,125,50},
    ["mail-search"] = {1,24,24,975,225},
    ["message-square-diff"] = {1,24,24,300,925},
    ["bone-fracture"] = {1,24,24,350,125},
    ["square-letter-d"] = {2,24,24,175,75},
    ["indian-rupee"] = {1,24,24,550,525},
    ["file-video-camera"] = {1,24,24,50,875},
    ["message-circle-off"] = {1,24,24,575,650},
    ["lambda"] = {1,24,24,975,125},
    ["ampersand"] = {1,24,24,175,25},
    ["ad"] = {1,24,24,0,50},
    ["shopping-cart"] = {1,24,24,825,900},
    ["align-vertical-justify-end"] = {1,24,24,75,100},
    ["message-circle-dashed"] = {1,24,24,650,575},
    ["alarm-smoke"] = {1,24,24,25,75},
    ["user-round-shield"] = {2,24,24,300,300},
    ["file-input"] = {1,24,24,725,200},
    ["clock-8"] = {1,24,24,125,625},
    ["hand-grab"] = {1,24,24,425,600},
    ["cloud-cog"] = {1,24,24,550,225},
    ["blend"] = {1,24,24,100,350},
    ["hd"] = {1,24,24,975,75},
    ["radio-tower"] = {1,24,24,850,625},
    ["list-tree"] = {1,24,24,900,275},
    ["droplet"] = {1,24,24,725,150},
    ["mail-pen"] = {1,24,24,250,925},
    ["eye"] = {1,24,24,750,150},
    ["maximize-2"] = {1,24,24,925,300},
    ["square-dashed-x"] = {2,24,24,225,0},
    ["banana"] = {1,24,24,0,375},
    ["gpu"] = {1,24,24,50,950},
    ["graph-hub"] = {1,24,24,950,75},
    ["margin-top"] = {1,24,24,300,900},
    ["circle-equal"] = {1,24,24,600,100},
    ["face-slightly-frowning"] = {1,24,24,625,275},
    ["ghost"] = {1,24,24,750,250},
    ["margin-bottom"] = {1,24,24,400,800},
    ["heading-2"] = {1,24,24,900,150},
    ["text-initial"] = {2,24,24,100,375},
    ["arrow-up-right"] = {1,24,24,325,0},
    ["laser"] = {1,24,24,650,450},
    ["leafy-green"] = {1,24,24,975,150},
    ["message-square-dot"] = {1,24,24,275,950},
    ["file-chart-line"] = {1,24,24,175,725},
    ["columns-3-cog"] = {1,24,24,725,75},
    ["form"] = {1,24,24,375,600},
    ["map-pin-plus"] = {1,24,24,600,600},
    ["minimize-2"] = {1,24,24,325,925},
    ["diff"] = {1,24,24,475,375},
    ["map-pin"] = {1,24,24,500,700},
    ["cone"] = {1,24,24,500,300},
    ["mails"] = {1,24,24,850,350},
    ["file-image"] = {1,24,24,750,175},
    ["mailbox"] = {1,24,24,875,325},
    ["circle-letter-n"] = {1,24,24,125,575},
    ["barrel"] = {1,24,24,200,200},
    ["gallery-thumbnails"] = {1,24,24,100,875},
    ["hand"] = {1,24,24,300,725},
    ["cpu"] = {1,24,24,750,75},
    ["mail-question-mark"] = {1,24,24,200,975},
    ["thumbs-down"] = {2,24,24,425,75},
    ["merge"] = {1,24,24,750,475},
    ["hamburger"] = {1,24,24,525,500},
    ["bell-off"] = {1,24,24,25,400},
    ["hat-glasses"] = {1,24,24,75,950},
    ["code"] = {1,24,24,25,750},
    ["circle-arrow-right"] = {1,24,24,350,325},
    ["mail-clock"] = {1,24,24,350,825},
    ["mail-check"] = {1,24,24,375,800},
    ["mail-badge"] = {1,24,24,400,775},
    ["carton"] = {1,24,24,150,450},
    ["mail"] = {1,24,24,900,300},
    ["kanban"] = {1,24,24,300,775},
    ["bone"] = {1,24,24,325,150},
    ["apple"] = {1,24,24,175,50},
    ["rocking-chair"] = {1,24,24,675,850},
    ["bot-off"] = {1,24,24,525,0},
    ["luggage"] = {1,24,24,450,725},
    ["square-letter-w"] = {2,24,24,300,0},
    ["log-in"] = {1,24,24,550,625},
    ["circle-arrow-out-up-left"] = {1,24,24,400,275},
    ["lock-keyhole-open"] = {1,24,24,650,525},
    ["cable-car"] = {1,24,24,175,375},
    ["arrow-down-left"] = {1,24,24,275,0},
    ["square-activity"] = {2,24,24,0,50},
    ["lock"] = {1,24,24,575,600},
    ["cigarette-off"] = {1,24,24,575,100},
    ["bug"] = {1,24,24,325,225},
    ["message-circle"] = {1,24,24,400,825},
    ["circle-arrow-out-up-right"] = {1,24,24,375,300},
    ["car-battery"] = {1,24,24,350,250},
    ["locate"] = {1,24,24,675,500},
    ["fold-horizontal"] = {1,24,24,325,625},
    ["shovel"] = {1,24,24,800,925},
    ["calendar-1"] = {1,24,24,50,500},
    ["cloud-moon"] = {1,24,24,375,400},
    ["square-arrow-out-down-right"] = {2,24,24,75,25},
    ["computer"] = {1,24,24,550,250},
    ["clock-plus"] = {1,24,24,700,75},
    ["circle-euro"] = {1,24,24,575,125},
    ["cloud-snow"] = {1,24,24,275,500},
    ["anvil"] = {1,24,24,25,175},
    ["arrow-big-up-dash"] = {1,24,24,125,125},
    ["list-video"] = {1,24,24,875,300},
    ["heart-minus"] = {1,24,24,650,400},
    ["earth-lock"] = {1,24,24,500,375},
    ["list-sort-descending"] = {1,24,24,975,200},
    ["list-music"] = {1,24,24,275,875},
    ["letter-g"] = {1,24,24,700,425},
    ["chevrons-down-up"] = {1,24,24,125,525},
    ["clipboard-plus"] = {1,24,24,475,275},
    ["circle-x"] = {1,24,24,100,625},
    ["list-end"] = {1,24,24,425,725},
    ["list-indent-increase"] = {1,24,24,325,825},
    ["grid-2x2-check"] = {1,24,24,900,125},
    ["chevrons-right"] = {1,24,24,675,0},
    ["audio-lines-off"] = {1,24,24,75,250},
    ["message-square-reply"] = {1,24,24,850,400},
    ["corner-down-right"] = {1,24,24,100,700},
    ["list-clock"] = {1,24,24,475,675},
    ["summary"] = {2,24,24,0,400},
    ["lamp-wall-down"] = {1,24,24,875,225},
    ["letter-e"] = {1,24,24,750,375},
    ["layout-arrow-down"] = {1,24,24,375,725},
    ["ellipsis-vertical"] = {1,24,24,250,625},
    ["globe-off"] = {1,24,24,150,850},
    ["square-stop"] = {2,24,24,150,200},
    ["arrow-up-1-0"] = {1,24,24,150,150},
    ["align-horizontal-justify-end"] = {1,24,24,125,25},
    ["scan-heart"] = {1,24,24,900,700},
    ["align-vertical-distribute-end"] = {1,24,24,150,25},
    ["heart-crack"] = {1,24,24,700,350},
    ["airplay"] = {1,24,24,50,25},
    ["list-check"] = {1,24,24,575,575},
    ["scratch-blocks"] = {1,24,24,625,975},
    ["link"] = {1,24,24,600,550},
    ["monitor-x"] = {1,24,24,575,700},
    ["bell-check"] = {1,24,24,125,300},
    ["database-minus"] = {1,24,24,150,675},
    ["square-pen"] = {2,24,24,225,100},
    ["bacon"] = {1,24,24,175,175},
    ["library-big"] = {1,24,24,150,975},
    ["dice-5"] = {1,24,24,550,300},
    ["octagon"] = {1,24,24,500,825},
    ["ticket"] = {2,24,24,200,300},
    ["line-dot-bottom-vertical"] = {1,24,24,825,325},
    ["lighthouse"] = {1,24,24,850,300},
    ["briefcase-plus"] = {1,24,24,25,500},
    ["bookmark"] = {1,24,24,50,450},
    ["calendar-minus"] = {1,24,24,275,300},
    ["utility-pole"] = {2,24,24,575,50},
    ["circle-letter-u"] = {1,24,24,675,50},
    ["chart-bar-decreasing"] = {1,24,24,475,150},
    ["database-plus"] = {1,24,24,125,700},
    ["calendar-sync"] = {1,24,24,125,450},
    ["funnel-plus"] = {1,24,24,250,725},
    ["store"] = {2,24,24,125,275},
    ["circle-arrow-down"] = {1,24,24,500,175},
    ["line-height"] = {1,24,24,725,425},
    ["egg-fried"] = {1,24,24,425,450},
    ["letter-x"] = {1,24,24,250,875},
    ["letter-w"] = {1,24,24,275,850},
    ["corner-right-up"] = {1,24,24,0,800},
    ["letter-u"] = {1,24,24,325,800},
    ["printer-3d"] = {1,24,24,725,725},
    ["user-round-plus"] = {2,24,24,350,250},
    ["panel-left-close"] = {1,24,24,575,775},
    ["letter-n"] = {1,24,24,525,600},
    ["pilcrow-right"] = {1,24,24,950,475},
    ["user-round-minus"] = {2,24,24,400,200},
    ["letter-j"] = {1,24,24,625,500},
    ["git-compare"] = {1,24,24,550,450},
    ["mail-plus"] = {1,24,24,225,950},
    ["letter-b"] = {1,24,24,825,300},
    ["lens"] = {1,24,24,875,250},
    ["leaf"] = {1,24,24,125,975},
    ["mouse-pointer-2-off"] = {1,24,24,975,325},
    ["drone"] = {1,24,24,775,100},
    ["slash"] = {1,24,24,900,900},
    ["credit-card-x"] = {1,24,24,600,225},
    ["aperture"] = {1,24,24,0,200},
    ["arrow-right-left"] = {1,24,24,250,50},
    ["layout-grid"] = {1,24,24,250,850},
    ["vector-square"] = {2,24,24,450,175},
    ["circle-gauge"] = {1,24,24,475,225},
    ["layout-dashboard"] = {1,24,24,325,775},
    ["check"] = {1,24,24,500,150},
    ["text-search"] = {2,24,24,50,425},
    ["arrow-down-to-dot"] = {1,24,24,200,75},
    ["monitor-down"] = {1,24,24,800,475},
    ["guitar-electric"] = {1,24,24,625,400},
    ["chef-hat"] = {1,24,24,475,175},
    ["bird"] = {1,24,24,175,275},
    ["avocado"] = {1,24,24,350,0},
    ["file-archive"] = {1,24,24,375,525},
    ["signal-high"] = {1,24,24,825,925},
    ["inbox"] = {1,24,24,575,500},
    ["land-plot"] = {1,24,24,800,300},
    ["lamp-wall-up"] = {1,24,24,850,250},
    ["image-play"] = {1,24,24,750,325},
    ["align-horizontal-space-between"] = {1,24,24,50,100},
    ["lamp-ceiling"] = {1,24,24,950,150},
    ["calendar-check"] = {1,24,24,500,75},
    ["database-zap"] = {1,24,24,50,775},
    ["droplets"] = {1,24,24,700,175},
    ["lamp"] = {1,24,24,825,275},
    ["broom"] = {1,24,24,475,75},
    ["keyboard"] = {1,24,24,100,975},
    ["layout-list"] = {1,24,24,225,875},
    ["file-search"] = {1,24,24,350,575},
    ["eighth-note"] = {1,24,24,350,525},
    ["alarm-clock-plus"] = {1,24,24,75,25},
    ["circle-dollar-sign"] = {1,24,24,700,0},
    ["usb"] = {2,24,24,125,450},
    ["house"] = {1,24,24,975,100},
    ["receipt-pound-sterling"] = {1,24,24,600,875},
    ["joystick"] = {1,24,24,325,750},
    ["iv-bag"] = {1,24,24,375,700},
    ["id-card"] = {1,24,24,850,225},
    ["mouse"] = {1,24,24,825,475},
    ["minimize"] = {1,24,24,300,950},
    ["inspection-panel"] = {1,24,24,475,600},
    ["info"] = {1,24,24,500,575},
    ["galaxy"] = {1,24,24,175,800},
    ["infinity"] = {1,24,24,525,550},
    ["book-x"] = {1,24,24,225,275},
    ["message-circle-text"] = {1,24,24,475,750},
    ["image-plus"] = {1,24,24,725,350},
    ["image-minus"] = {1,24,24,800,275},
    ["id-card-lanyard"] = {1,24,24,875,200},
    ["headphone-off"] = {1,24,24,775,275},
    ["asterisk"] = {1,24,24,175,150},
    ["ice-cream-cone"] = {1,24,24,900,175},
    ["octagon-x"] = {1,24,24,525,800},
    ["languages"] = {1,24,24,750,350},
    ["house-plug"] = {1,24,24,125,925},
    ["alarm-clock-check"] = {1,24,24,25,50},
    ["guitar"] = {1,24,24,600,425},
    ["house-heart"] = {1,24,24,150,900},
    ["beer-off"] = {1,24,24,200,225},
    ["scooter"] = {1,24,24,650,950},
    ["hotel"] = {1,24,24,250,800},
    ["notebook-text"] = {1,24,24,775,550},
    ["arrow-right-to-line"] = {1,24,24,225,75},
    ["clef-treble"] = {1,24,24,700,50},
    ["tally-4"] = {2,24,24,100,350},
    ["zodiac-taurus"] = {2,24,24,575,125},
    ["hiking-stick"] = {1,24,24,400,650},
    ["door-open"] = {1,24,24,50,800},
    ["flag-triangle-left"] = {1,24,24,650,300},
    ["grid-3x3"] = {1,24,24,775,250},
    ["file"] = {1,24,24,925,25},
    ["highlighter"] = {1,24,24,425,625},
    ["pocket-knife"] = {1,24,24,975,475},
    ["book-copy"] = {1,24,24,175,300},
    ["castle"] = {1,24,24,0,600},
    ["car-front"] = {1,24,24,325,275},
    ["clock-alert"] = {1,24,24,75,675},
    ["reply-all"] = {1,24,24,875,650},
    ["cloud-moon-rain"] = {1,24,24,400,375},
    ["clipboard-type"] = {1,24,24,450,300},
    ["heart-off"] = {1,24,24,625,425},
    ["list-todo"] = {1,24,24,925,250},
    ["printer-x"] = {1,24,24,675,775},
    ["headset"] = {1,24,24,725,325},
    ["list-start"] = {1,24,24,950,225},
    ["heading-6"] = {1,24,24,800,250},
    ["a-large-small"] = {1,24,24,0,25},
    ["heading-5"] = {1,24,24,825,225},
    ["heading-3"] = {1,24,24,875,175},
    ["map-plus"] = {1,24,24,450,750},
    ["heading-1"] = {1,24,24,925,125},
    ["square-letter-f"] = {2,24,24,125,125},
    ["hard-hat"] = {1,24,24,125,900},
    ["database-arrow-up"] = {1,24,24,250,575},
    ["arrow-right-from-line"] = {1,24,24,275,25},
    ["flame-kindling"] = {1,24,24,575,375},
    ["circle-letter-g"] = {1,24,24,300,400},
    ["hard-drive-upload"] = {1,24,24,175,850},
    ["bring-to-front"] = {1,24,24,550,0},
    ["hard-drive-download"] = {1,24,24,200,825},
    ["circle-letter-f"] = {1,24,24,325,375},
    ["bell-plus"] = {1,24,24,0,425},
    ["circle-letter-p-off"] = {1,24,24,75,625},
    ["handbag"] = {1,24,24,275,750},
    ["hand-platter"] = {1,24,24,325,700},
    ["boxes-linked"] = {1,24,24,400,125},
    ["mail-warning"] = {1,24,24,950,250},
    ["hammer"] = {1,24,24,500,525},
    ["half-note"] = {1,24,24,575,450},
    ["groceries"] = {1,24,24,675,350},
    ["bridge"] = {1,24,24,125,400},
    ["chart-line"] = {1,24,24,175,450},
    ["file-lock"] = {1,24,24,675,250},
    ["cast"] = {1,24,24,25,575},
    ["circle-fading-plus"] = {1,24,24,500,200},
    ["clock-10"] = {1,24,24,350,400},
    ["undo-dot"] = {2,24,24,400,175},
    ["target"] = {2,24,24,25,425},
    ["list-filter-plus"] = {1,24,24,400,750},
    ["grid-2x2"] = {1,24,24,825,200},
    ["drama"] = {1,24,24,825,50},
    ["graph-star"] = {1,24,24,925,100},
    ["baseline"] = {1,24,24,175,225},
    ["martini"] = {1,24,24,950,275},
    ["contrast"] = {1,24,24,375,425},
    ["square-letter-v"] = {2,24,24,0,275},
    ["candy-off"] = {1,24,24,500,100},
    ["git-pull-request-draft"] = {1,24,24,325,675},
    ["book-check"] = {1,24,24,200,275},
    ["git-pull-request-create"] = {1,24,24,350,650},
    ["book-lock"] = {1,24,24,0,475},
    ["clipboard-list"] = {1,24,24,600,150},
    ["briefcase-medical"] = {1,24,24,50,475},
    ["calendars"] = {1,24,24,25,550},
    ["text-align-start"] = {2,24,24,175,300},
    ["git-merge-conflict"] = {1,24,24,475,525},
    ["hop-off"] = {1,24,24,350,700},
    ["letter-i"] = {1,24,24,650,475},
    ["sticky-notes"] = {2,24,24,175,225},
    ["drafting-compass"] = {1,24,24,850,25},
    ["save-all"] = {1,24,24,825,750},
    ["circle-dashed-check"] = {1,24,24,50,625},
    ["git-branch"] = {1,24,24,650,350},
    ["gift"] = {1,24,24,725,275},
    ["circle-chevrons-down"] = {1,24,24,150,525},
    ["margin-right"] = {1,24,24,325,875},
    ["fishing-rod"] = {1,24,24,700,250},
    ["book-headphones"] = {1,24,24,100,375},
    ["credit-card"] = {1,24,24,575,250},
    ["users-round-collaboration"] = {2,24,24,50,550},
    ["gem"] = {1,24,24,850,150},
    ["gauge"] = {1,24,24,900,100},
    ["shredder"] = {1,24,24,750,975},
    ["panel-bottom-open"] = {1,24,24,625,725},
    ["door-closed-package"] = {1,24,24,100,750},
    ["gamepad-directional"] = {1,24,24,0,975},
    ["credit-card-check"] = {1,24,24,700,125},
    ["balloon"] = {1,24,24,50,325},
    ["map-pin-plus-inside"] = {1,24,24,625,575},
    ["bookmark-x"] = {1,24,24,75,425},
    ["badge-question-mark"] = {1,24,24,250,125},
    ["pen"] = {1,24,24,450,925},
    ["fullscreen"] = {1,24,24,275,700},
    ["candy-cane"] = {1,24,24,525,75},
    ["fuel"] = {1,24,24,300,675},
    ["circle-chevrons-right"] = {1,24,24,100,575},
    ["gamepad-2"] = {1,24,24,25,950},
    ["folders"] = {1,24,24,450,525},
    ["folder-users"] = {1,24,24,525,450},
    ["folder-up"] = {1,24,24,575,400},
    ["circle-letter-p"] = {1,24,24,50,650},
    ["shield-minus"] = {1,24,24,925,775},
    ["circle-off"] = {1,24,24,500,225},
    ["dessert"] = {1,24,24,800,50},
    ["eclipse"] = {1,24,24,450,425},
    ["church"] = {1,24,24,600,75},
    ["folder-search-2"] = {1,24,24,700,275},
    ["cylinder"] = {1,24,24,325,500},
    ["badge-japanese-yen"] = {1,24,24,375,0},
    ["circle-letter-o"] = {1,24,24,100,600},
    ["receipt-text"] = {1,24,24,525,950},
    ["folder"] = {1,24,24,475,500},
    ["folder-open"] = {1,24,24,825,150},
    ["folder-minus"] = {1,24,24,875,100},
    ["folder-lock"] = {1,24,24,900,75},
    ["file-output"] = {1,24,24,575,350},
    ["disc-album"] = {1,24,24,400,450},
    ["circle-slash"] = {1,24,24,250,475},
    ["arrow-down-0-1"] = {1,24,24,75,175},
    ["captions"] = {1,24,24,375,225},
    ["folder-cog"] = {1,24,24,125,825},
    ["folder-closed"] = {1,24,24,175,775},
    ["philippine-peso"] = {1,24,24,775,625},
    ["badge-alert"] = {1,24,24,150,200},
    ["folder-check"] = {1,24,24,225,725},
    ["folder-pen"] = {1,24,24,775,200},
    ["cross"] = {1,24,24,500,325},
    ["brain-off"] = {1,24,24,250,275},
    ["chevron-right"] = {1,24,24,175,475},
    ["square-letter-i"] = {2,24,24,50,200},
    ["square-arrow-down-left"] = {2,24,24,75,0},
    ["share-2"] = {1,24,24,675,975},
    ["flashlight-off"] = {1,24,24,525,425},
    ["flag-off"] = {1,24,24,675,275},
    ["fish"] = {1,24,24,750,200},
    ["fire-extinguisher"] = {1,24,24,825,125},
    ["fingerprint-pattern"] = {1,24,24,850,100},
    ["film"] = {1,24,24,875,75},
    ["chess-pawn"] = {1,24,24,350,300},
    ["file-x-corner"] = {1,24,24,0,925},
    ["briefcase-business"] = {1,24,24,100,425},
    ["file-x"] = {1,24,24,950,0},
    ["message-circle-reply"] = {1,24,24,500,725},
    ["file-up"] = {1,24,24,100,825},
    ["triangle-right"] = {2,24,24,300,250},
    ["folder-clock"] = {1,24,24,200,750},
    ["file-stack"] = {1,24,24,250,675},
    ["mop-sparkles"] = {1,24,24,475,800},
    ["type"] = {2,24,24,525,50},
    ["webhook"] = {2,24,24,150,500},
    ["file-minus-corner"] = {1,24,24,650,275},
    ["align-horizontal-distribute-start"] = {1,24,24,0,125},
    ["letter-m"] = {1,24,24,550,575},
    ["file-heart"] = {1,24,24,775,150},
    ["pointer-off"] = {1,24,24,925,525},
    ["turtle"] = {2,24,24,50,500},
    ["camera"] = {1,24,24,600,0},
    ["file-check"] = {1,24,24,100,800},
    ["square-letter-g"] = {2,24,24,100,150},
    ["git-pull-request"] = {1,24,24,300,700},
    ["bluetooth-searching"] = {1,24,24,450,25},
    ["arrow-up-to-line"] = {1,24,24,300,25},
    ["squircle-dashed"] = {2,24,24,275,100},
    ["clock-3"] = {1,24,24,250,500},
    ["badge-percent"] = {1,24,24,325,50},
    ["face-expressionless"] = {1,24,24,700,200},
    ["fan"] = {1,24,24,525,375},
    ["factory"] = {1,24,24,550,350},
    ["circle-letter-m"] = {1,24,24,150,550},
    ["face-neutral"] = {1,24,24,650,250},
    ["box"] = {1,24,24,425,100},
    ["external-link"] = {1,24,24,850,50},
    ["clock-1"] = {1,24,24,375,375},
    ["circle-letter-i"] = {1,24,24,250,450},
    ["house-cog"] = {1,24,24,175,875},
    ["space"] = {1,24,24,875,975},
    ["equal-approximately"] = {1,24,24,125,750},
    ["engine"] = {1,24,24,175,700},
    ["eject"] = {1,24,24,300,575},
    ["corner-up-left"] = {1,24,24,825,0},
    ["clock-6"] = {1,24,24,175,575},
    ["circle-letter-z"] = {1,24,24,550,175},
    ["key-round"] = {1,24,24,225,850},
    ["headphones"] = {1,24,24,750,300},
    ["tv"] = {2,24,24,575,0},
    ["droplet-off"] = {1,24,24,750,125},
    ["circle-letter-w"] = {1,24,24,625,100},
    ["rss"] = {1,24,24,675,875},
    ["disc"] = {1,24,24,375,475},
    ["at-sign"] = {1,24,24,125,200},
    ["map-pin-check-inside"] = {1,24,24,800,400},
    ["sticky-note-off"] = {2,24,24,275,125},
    ["diamond-minus"] = {1,24,24,750,100},
    ["handshake"] = {1,24,24,225,800},
    ["diameter"] = {1,24,24,775,75},
    ["circle-user"] = {1,24,24,125,600},
    ["copy-plus"] = {1,24,24,250,550},
    ["delete"] = {1,24,24,825,25},
    ["virus-off"] = {2,24,24,175,450},
    ["line-dot-left-horizontal"] = {1,24,24,800,350},
    ["database-arrow-down"] = {1,24,24,275,550},
    ["currency"] = {1,24,24,350,475},
    ["search-check"] = {1,24,24,825,800},
    ["clipboard-check"] = {1,24,24,675,75},
    ["columns-2"] = {1,24,24,750,50},
    ["crop"] = {1,24,24,525,300},
    ["candy"] = {1,24,24,475,125},
    ["align-center-vertical"] = {1,24,24,125,0},
    ["columns-3"] = {1,24,24,700,100},
    ["corner-right-down"] = {1,24,24,25,775},
    ["corner-down-left"] = {1,24,24,125,675},
    ["cloud-fog"] = {1,24,24,475,300},
    ["mosque"] = {1,24,24,425,850},
    ["bot"] = {1,24,24,500,25},
    ["map-pin-house"] = {1,24,24,750,450},
    ["package-check"] = {1,24,24,350,975},
    ["chevron-first"] = {1,24,24,250,400},
    ["pencil"] = {1,24,24,925,475},
    ["construction"] = {1,24,24,475,325},
    ["list-x"] = {1,24,24,850,325},
    ["component"] = {1,24,24,575,225},
    ["compass"] = {1,24,24,600,200},
    ["corner-up-right"] = {1,24,24,800,25},
    ["coins"] = {1,24,24,775,25},
    ["clock-arrow-left"] = {1,24,24,25,725},
    ["club"] = {1,24,24,75,700},
    ["cloud-sync"] = {1,24,24,200,575},
    ["badge-indian-rupee"] = {1,24,24,25,325},
    ["cloud-drizzle"] = {1,24,24,500,275},
    ["redo-dot"] = {1,24,24,775,725},
    ["clock-arrow-right"] = {1,24,24,0,750},
    ["align-start-horizontal"] = {1,24,24,25,125},
    ["chart-column-stacked"] = {1,24,24,250,375},
    ["file-plus"] = {1,24,24,450,475},
    ["git-pull-request-arrow"] = {1,24,24,425,575},
    ["clipboard"] = {1,24,24,400,350},
    ["decimals-arrow-right"] = {1,24,24,850,0},
    ["bell-dot"] = {1,24,24,100,325},
    ["folder-down"] = {1,24,24,75,875},
    ["circle-plus"] = {1,24,24,375,350},
    ["circle-play"] = {1,24,24,400,325},
    ["align-horizontal-space-around"] = {1,24,24,75,75},
    ["door-closed-locked"] = {1,24,24,125,725},
    ["chevron-left"] = {1,24,24,200,450},
    ["diamond"] = {1,24,24,675,175},
    ["blinds"] = {1,24,24,50,400},
    ["chevrons-left-right-ellipsis"] = {1,24,24,75,575},
    ["square-letter-p"] = {2,24,24,150,125},
    ["book-search"] = {1,24,24,375,125},
    ["git-branch-minus"] = {1,24,24,700,300},
    ["mail-dot"] = {1,24,24,325,850},
    ["recycle"] = {1,24,24,825,675},
    ["mountain-snow"] = {1,24,24,375,900},
    ["circle-fading-play"] = {1,24,24,525,175},
    ["chevrons-left-right"] = {1,24,24,50,600},
    ["bot-message-square"] = {1,24,24,0,500},
    ["phone-outgoing"] = {1,24,24,600,800},
    ["circle-letter-v"] = {1,24,24,650,75},
    ["chess-bishop"] = {1,24,24,425,225},
    ["train-track"] = {2,24,24,75,450},
    ["case-sensitive"] = {1,24,24,100,500},
    ["chart-no-axes-column-increasing"] = {1,24,24,100,525},
    ["sticky-note-plus"] = {2,24,24,250,150},
    ["chart-network"] = {1,24,24,150,475},
    ["chart-column-big"] = {1,24,24,325,300},
    ["chart-bar-stacked"] = {1,24,24,425,200},
    ["chart-no-axes-combined"] = {1,24,24,50,575},
    ["metronome"] = {1,24,24,650,600},
    ["triangles-centerline-dashed-vertical"] = {2,24,24,225,325},
    ["arrow-down-1-0"] = {1,24,24,50,200},
    ["credit-card-minus"] = {1,24,24,675,150},
    ["calendar-range"] = {1,24,24,175,400},
    ["arrow-left-right"] = {1,24,24,25,250},
    ["lightbulb-off"] = {1,24,24,900,250},
    ["panels-top-left"] = {1,24,24,800,575},
    ["beef-off"] = {1,24,24,250,175},
    ["locate-off"] = {1,24,24,700,475},
    ["square-letter-a"] = {2,24,24,250,0},
    ["test-tube"] = {2,24,24,375,100},
    ["boxes"] = {1,24,24,375,150},
    ["cooking-pot"] = {1,24,24,325,475},
    ["boom-box"] = {1,24,24,25,475},
    ["book-up"] = {1,24,24,275,225},
    ["book-plus"] = {1,24,24,400,100},
    ["laptop-minimal-check"] = {1,24,24,725,375},
    ["mail-open"] = {1,24,24,275,900},
    ["park"] = {1,24,24,675,700},
    ["baggage-claim"] = {1,24,24,100,275},
    ["variable"] = {2,24,24,525,100},
    ["arrow-up-down"] = {1,24,24,100,200},
    ["arrow-right"] = {1,24,24,200,100},
    }
    local Sheets = { "rbxassetid://110684213241563", "rbxassetid://103436477950249" }
    if isfile and isfolder and makefolder and readfile and writefile and getcustomasset then
        local Folder = "CloudyLucide-7d3ec23ee78d"
        for Sheet = 1, 2 do
            local Success, Asset = pcall(function()
                if not isfolder(Folder) then makefolder(Folder) end
                local File = Folder .. "/" .. Sheet .. ".png"
                local Data = isfile(File) and readfile(File) or nil
                if not Data or Data:sub(1, 8) ~= "\137PNG\r\n\26\n" then
                    Data = game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/7d3ec23ee78d77cb8b3aa8256bfa4691bb76ffe3/spritesheets/" .. Sheet .. ".png")
                    assert(Data:sub(1, 8) == "\137PNG\r\n\26\n", "Invalid icon sheet")
                    writefile(File, Data)
                end
                return getcustomasset(File)
            end)
            if Success and typeof(Asset) == "string" and Asset ~= "" then Sheets[Sheet] = Asset end
        end
    end
    return { GetAsset = function(Name)
        Name = tostring(Name):gsub("^lucide:", "")
        local Rect = Rects[Name]
        if not Rect then return nil end
        return { Url = Sheets[Rect[1]], ImageRectSize = Vector2.new(Rect[2], Rect[3]),
            ImageRectOffset = Vector2.new(Rect[4], Rect[5]), IconName = Name }
    end }
end
Library:SetIconModule(BuildPinnedLucide())

--// Lib Functions \\--
Library.Cursor = {}

function Library.Cursor:ResetCross()
    for _, Inner in InnerCross do
        Library.Registry[Inner].BackgroundColor3 = "WhiteColor"
        Inner.BackgroundColor3 = Library.Scheme.WhiteColor
    end
end

function Library.Cursor:ResetIcon()
    CursorCross.Visible = true
    CursorCustomImage.Visible = false
    CursorCustomImage.ImageColor3 = Color3.new(1, 1, 1)
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
end

function Library.Cursor:ResetCursor()
    Library.Cursor:ResetCross()
    Library.Cursor:ResetIcon()
end

function Library.Cursor:ChangeCrossColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    for _, Inner in InnerCross do
        Inner.BackgroundColor3 = Color
        Library.Registry[Inner].BackgroundColor3 = nil
    end
end

function Library.Cursor:ChangeIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library.Cursor:ResetIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCross.Visible = false
    CursorCustomImage.Visible = true
    Library:ApplyLucideIcon(CursorCustomImage, Icon)
end

function Library.Cursor:ChangeIconColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    CursorCustomImage.ImageColor3 = Color
end

function Library.Cursor:ChangeIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

--// DEPRECATED
function Library:ChangeCursorCrossColor(Color: Color3)
    warn("Obsidian:ChangeCursorCrossColor is deprecated, please use Obsidian.Cursor:ChangeCrossColor instead.")
    Library.Cursor:ChangeCrossColor(Color)
end

--// DEPRECATED
function Library:ResetCursorCross()
    warn("Obsidian:ResetCursorCross is deprecated, please use Obsidian.Cursor:ResetCross instead.")
    Library.Cursor:ResetCross()
end

--// DEPRECATED
function Library:ChangeCursorIcon(ImageId: string)
    warn("Obsidian:ChangeCursorIcon is deprecated, please use Obsidian.Cursor:ChangeIcon instead.")
    Library.Cursor:ChangeIcon(ImageId)
end

--// DEPRECATED
function Library:ChangeCursorIconColor(Color: Color3)
    warn("Obsidian:ChangeCursorIconColor is deprecated, please use Obsidian.Cursor:ChangeIconColor instead.")
    Library.Cursor:ChangeIconColor(Color)
end

--// DEPRECATED
function Library:ChangeCursorIconSize(Size: UDim2)
    warn("Obsidian:ChangeCursorIconSize is deprecated, please use Obsidian.Cursor:ChangeIconSize instead.")
    Library.Cursor:ChangeIconSize(Size)
end

--// DEPRECATED
function Library:ResetCursorIcon()
    warn("Obsidian:ResetCursorIcon is deprecated, please use Obsidian.Cursor:ResetIcon instead.")
    Library.Cursor:ResetIcon()
end

--// Colors \\--
function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Scale = Library.DPIScale
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size * Scale
    if Width then
        Params.Width = Width * Scale
    else
        Params.Width = workspace.CurrentCamera.ViewportSize.X - 32
    end

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize

    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize

    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        local Trace = debug.traceback(Error, 2)
        task.defer(error, Trace)
        if Library.NotifyOnError and Library.Notify then
            Library:Notify({
                Title = "Script error",
                Description = string.sub(tostring(Error), 1, 160),
                Time = 8,
                Closable = true,
                Icon = "triangle-alert",
                IconColor = Library.Scheme.RedColor,
                Action = typeof(setclipboard) == "function" and {
                    Text = "Copy error",
                    Callback = function()
                        setclipboard(Trace)
                    end,
                } or nil,
            })
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize

    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize

        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end

    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6

    local CurrentX = Start.X
    local CurrentY = Start.Y

    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end

    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end

        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end

        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding

            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end

            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end

    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

--// Window Snapping \\--
local function GetCoreGuiInset(): (Vector2, Vector2)
    local Success, TopLeft, BottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)

    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end

    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize: Vector2, ViewportSize: Vector2, Margin: number, AvoidCoreGui: boolean)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize

    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end

    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }

    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value: number, Targets: { [string]: number }, Distance: number): (number?, string?)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance

    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end

    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name: string, SnappedValue: number, ElemDimension: number): number
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end

    return SnappedValue -- LeftEdge / TopEdge
end

function Library:MakeDraggable(
    UI: GuiObject,
    DragFrame: GuiObject,
    IgnoreToggled: boolean?,
    IsMainWindow: boolean?,
    SnapConfig: { Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean? }?
)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    local SnapGuideX, SnapGuideY

    local function GetSnapGuides()
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8

                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY

                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end

                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end

            UI.Position = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

--// Roblox UIShadow (falls back to a dark stroke on clients without it) \\--
local ShadowSupported = pcall(function()
    Instance.new("UIShadow"):Destroy()
end)

function Library:AddShadow(Frame: GuiObject, Blur: number?, Offset: number?, Transparency: number?, ColorKey: string?)
    if not ShadowSupported then
        return nil
    end

    local Success, Shadow = pcall(New, "UIShadow", {
        BlurRadius = UDim.new(0, Blur or 18),
        Color = ColorKey or "DarkColor",
        Offset = UDim2.fromOffset(0, Offset or 6),
        Transparency = Transparency or 0.5,
        ZIndex = -1,
        Parent = Frame,
    })

    return Success and Shadow or nil
end

function Library:AddOutline(Frame: GuiObject, Blur: number?, Offset: number?, Transparency: number?)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })

    local Shadow = Library:AddShadow(Frame, Blur, Offset, Transparency)
    if not Shadow then
        Shadow = New("UIStroke", {
            Color = "DarkColor",
            Thickness = 1.5,
            ZIndex = 1,
            Parent = Frame,
        })
    end

    return OutlineStroke, Shadow
end

--// Row card: title + auto-wrapping description (no more stacked text) \\--
function Library:MakeRowCard(Parent: GuiObject, Config)
    local MinHeight = Config.MinHeight or 46
    local RightInset = Config.RightInset or 16
    local Inset = 16 + RightInset

    local Properties = {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.25,
        Size = UDim2.new(1, 0, 0, MinHeight),
        Visible = Config.Visible ~= false,
        Parent = Parent,
    }
    if Config.Button then
        Properties.Text = ""
        Properties.Active = Config.Active ~= false
    end

    local Card = New(Config.Button and "TextButton" or "Frame", Properties)
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Card,
        })
    )
    local Stroke = New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.45,
        Parent = Card,
    })
    local Shadow = Library:AddShadow(Card, 8, 3, 0.7)
    if Shadow then
        pcall(function()
            Shadow.Enabled = Library.ElementGlow == true
        end)
        Library.ElementShadows[Shadow] = true
    end

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -Inset, 1, 0),
        Text = Config.Text or "",
        TextSize = 16,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card,
    })
    if Config.Addons then
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })
    end

    local HasDescription = typeof(Config.Description) == "string" and Config.Description ~= ""
    local Description = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 31),
        Size = UDim2.new(1, -Inset, 0, 14),
        Text = HasDescription and Config.Description or "",
        TextSize = 12,
        TextTransparency = 0.55,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Visible = HasDescription,
        Parent = Card,
    })

    local Row = {
        Card = Card,
        Label = Label,
        Description = Description,
        Stroke = Stroke,
        Shadow = Shadow,
    }

    local LastKey
    local Busy = false
    function Row.Relayout()
        if Busy or not Card.Parent then
            return
        end

        local Width = (Card.AbsoluteSize.X / Library.DPIScale) - Inset
        local Key = Description.Visible and (tostring(math.floor(Width)) .. Description.Text) or "none"
        if Key == LastKey then
            return
        end
        LastKey = Key
        Busy = true

        if Description.Visible then
            local Height = 14
            if Width > 8 then
                local _, H = Library:GetTextBounds(Description.Text, Description.FontFace, Description.TextSize, Width)
                Height = H
            end

            Label.Position = UDim2.fromOffset(16, 10)
            Label.Size = UDim2.new(1, -Inset, 0, 20)
            Description.Position = UDim2.fromOffset(16, 31)
            Description.Size = UDim2.new(1, -Inset, 0, Height)
            Card.Size = UDim2.new(1, 0, 0, math.max(MinHeight, 31 + Height + 12))
        else
            Label.Position = UDim2.fromOffset(16, 0)
            Label.Size = UDim2.new(1, -Inset, 1, 0)
            Card.Size = UDim2.new(1, 0, 0, MinHeight)
        end

        Busy = false
    end

    function Row.Invalidate()
        LastKey = nil
    end
    Library.RowCards[Row] = true

    function Row.SetDescription(Text)
        local Has = typeof(Text) == "string" and Text ~= ""
        Description.Text = Has and Text or ""
        Description.Visible = Has
        LastKey = nil
        Row.Relayout()
    end

    function Row.SetText(Text)
        Label.Text = Text or ""
    end

    Card:GetPropertyChangedSignal("AbsoluteSize"):Connect(Row.Relayout)

    --// Hover: outline lights up, glow gets stronger \\--
    local function Hover(State: boolean)
        TweenService:Create(Stroke, Library.TweenInfo, {
            Transparency = State and 0.1 or 0.45,
        }):Play()

        if Shadow and not Config.Highlight then
            pcall(function()
                TweenService:Create(Shadow, Library.TweenInfo, {
                    Transparency = State and 0.5 or 0.7,
                }):Play()
            end)
        end
    end
    Card.MouseEnter:Connect(function()
        Hover(true)
    end)
    Card.MouseLeave:Connect(function()
        Hover(false)
    end)
    task.defer(Row.Relayout)

    return Row
end

--// Toggle tree: Library.Toggles["Idx"]:AddToggle / AddDropdown / AddSlider / ... draws children under the toggle with tree lines \\--
function Library:AttachToggleTree(Toggle, Groupbox, Container, Info)
    local Button = Toggle.Holder
    Toggle.TreeMode = Info.TreeMode == "Always" and "Always" or "Enabled"

    --// Placeholder that keeps the tree directly under its toggle in the list \\--
    local TreeFrame = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = Container,
    })
    Toggle.TreeFrame = TreeFrame

    local TrunkX, IndentX = 22, 40
    local function LineColor()
        return Library.Scheme.AccentColor:Lerp(Library.Scheme.OutlineColor, 0.55)
    end

    function Toggle:SetTreeMode(Mode: string)
        Toggle.TreeMode = Mode == "Always" and "Always" or "Enabled"

        if Toggle.Tree then
            Toggle.Tree:SetupDependencies(Toggle.TreeMode == "Always" and {} or { { Toggle, true } })
        end
    end

    function Toggle:GetTree()
        if Toggle.Tree then
            return Toggle.Tree
        end

        local Indent = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(IndentX, 0),
            Size = UDim2.new(1, -IndentX, 0, 0),
            Parent = TreeFrame,
        })

        local Trunk = New("Frame", {
            BackgroundColor3 = LineColor,
            Position = UDim2.fromOffset(TrunkX, -8),
            Size = UDim2.fromOffset(2, 0),
            Visible = false,
            Parent = TreeFrame,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Trunk,
        })

        local Tree = Groupbox:AddDependencyBox(Indent)
        Tree.IsTree = true
        Tree.ParentToggle = Toggle

        local Stubs = {}
        local function CreateStub()
            local Stub = New("Frame", {
                BackgroundColor3 = LineColor,
                Size = UDim2.fromOffset(IndentX - TrunkX - 4, 2),
                Visible = false,
                Parent = TreeFrame,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Stub,
            })

            local Dot = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "AccentColor",
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.fromOffset(6, 6),
                Parent = Stub,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Dot,
            })

            return Stub
        end

        --// One elbow per visible child, centered on the child's card \\--
        local function Refresh()
            if Tree.Destroyed or not TreeFrame.Parent or not TreeFrame.Visible then
                return
            end

            local Scale = Library.DPIScale
            local OriginY = TreeFrame.AbsolutePosition.Y
            local Count, LastY = 0, 0

            for _, Element in Tree.Elements do
                local Holder = Element.Holder
                if
                    typeof(Holder) ~= "Instance"
                    or Element.Type == "Divider"
                    or Element.Visible == false
                    or not Holder.Visible
                then
                    continue
                end

                Count += 1

                local CenterY = (Holder.AbsolutePosition.Y - OriginY + Holder.AbsoluteSize.Y / 2) / Scale
                local Stub = Stubs[Count]
                if not Stub then
                    Stub = CreateStub()
                    Stubs[Count] = Stub
                end

                Stub.Position = UDim2.fromOffset(TrunkX, math.floor(CenterY - 1))
                Stub.Visible = true
                LastY = CenterY
            end

            for Index = Count + 1, #Stubs do
                Stubs[Index].Visible = false
            end

            Trunk.Visible = Count > 0
            Trunk.Size = UDim2.fromOffset(2, math.max(0, math.floor(LastY + 8)))
        end

        local BaseResize = Tree.Resize
        function Tree:Resize()
            BaseResize(Tree)
            task.defer(Refresh)
        end

        table.insert(Tree.Connections, Tree.Holder:GetPropertyChangedSignal("Visible"):Connect(function()
            TreeFrame.Visible = Tree.Holder.Visible
            if TreeFrame.Visible then
                task.defer(Refresh)
            end
        end))

        Toggle.Tree = Tree
        Tree:SetupDependencies(Toggle.TreeMode == "Always" and {} or { { Toggle, true } })
        TreeFrame.Visible = Tree.Holder.Visible

        return Tree
    end

    Button.Destroying:Once(function()
        if Toggle.Tree and not Toggle.Tree.Destroyed then
            pcall(Toggle.Tree.Destroy, Toggle.Tree)
        end

        TreeFrame:Destroy()
    end)
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(Tab, Showing: boolean, OnComplete: (() -> ())?)
    if type(Tab) ~= "table" or not Tab.Container then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local TabContainer = Tab.Container :: Frame
    if Tab.Detached then
        if Tab.DetachedCard then
            Tab.DetachedCard.Visible = Showing
        end
        if OnComplete then
            OnComplete()
        end

        return
    end

    local Existing = ActiveTabTweens[TabContainer]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabContainer] = nil
    end

    local BaseZIndex = TabContainer.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabContainer.Visible = Showing
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition
        local StartingPositions = {
            Left = UDim2.fromOffset(-Offset, 0),
            Right = UDim2.fromOffset(Offset, 0),
            Top = UDim2.fromOffset(0, -Offset),
            Bottom = UDim2.fromOffset(0, Offset),
        }

        if SwipeFrom == "auto" and Library.PreviousTab then
            local CurrentOrder = Tab.Button.LayoutOrder
            local PreviousOrder = Library.PreviousTab.Button.LayoutOrder
            if CurrentOrder and PreviousOrder then -- this may be unnecessary but oh well
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Top or StartingPositions.Bottom -- bigger order means its under the current button
            else
                StartPosition = StartingPositions.Bottom
            end
        elseif SwipeFrom == "left" then
            StartPosition = StartingPositions.Left
        elseif SwipeFrom == "top" then
            StartPosition = StartingPositions.Top
        elseif SwipeFrom == "right" then
            StartPosition = StartingPositions.Right
        else -- bottom (Default)
            StartPosition = StartingPositions.Bottom
        end

        TabContainer.ZIndex = BaseZIndex + 1
        TabContainer.Position = StartPosition
        TabContainer.Visible = true

        local Tween = TweenService:Create(TabContainer, TweenInfo, {
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabContainer] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabContainer] == Tween then
                ActiveTabTweens[TabContainer] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabContainer.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabContainer.Visible = false
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Pop Out \\--
function Library:MakeBoxPopOut(Box: any, Options: {
    Enabled: boolean?,
    Header: GuiObject?,
    Children: (() -> { GuiObject })?,
    Before: (() -> ())?,
    After: (() -> ())?,
    MaxPopOutHeight: number?,
    PopOutWidth: number?,
})
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil
    Box.PopOutMaxHeight = if typeof(Options.MaxPopOutHeight) == "number" then Options.MaxPopOutHeight else nil
    Box.PopOutWidth = if typeof(Options.PopOutWidth) == "number" then Options.PopOutWidth else nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut(_Value: boolean, _SetPoppedOut: UDim2) end
        function Box:TogglePoppedOut() end
        function Box:RefreshPopOutPlaceholder() end
        function Box:SetMaxPopOutHeight(_Height: number?) end
        function Box:SetPopOutWidth(_Width: number?) end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header

    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale

    local HandledChildren: { GuiObject } = {}
    local OriginalParents: { [GuiObject]: Instance? } = {}
    local OriginalLayoutOrders: { [GuiObject]: number } = {}

    local DragState: "Idle" | "Holding" | "Dragging" = "Idle"
    local DragInput: InputObject?
    local PressMouse: Vector2?

    local DragStartPos: UDim2?
    local DragChanged: RBXScriptConnection?
    local DragDidMove = false

    --// UI Handler
    local function GetPopOutWidth(): number
        if typeof(Box.PopOutWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutWidth + 0.5))
        end

        if typeof(Box.PopOutDockedWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutDockedWidth + 0.5))
        end

        local Width = Holder.AbsoluteSize.X / Library.DPIScale
        if Width < 50 then
            Width = 200
        end

        return math.max(50, math.floor(Width + 0.5))
    end

    local function ApplyPopOutWidth()
        if not (Box.PoppedOut and Float) then
            return
        end

        Float.Size = UDim2.fromOffset(GetPopOutWidth(), Float.Size.Y.Offset)
        if Box.Resize then
            Box:Resize()
        end
    end

    local function RaiseFloat()
        if not Float or not Floats then
            return
        end

        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end

        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = New("ImageButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            })
            Library:ApplyLucideIcon(PlaceholderDockIcon, PopOutIcon)
            PlaceholderDockIcon.MouseButton1Click:Connect(function()
                Box:SetPoppedOut(false)
            end)
        end

        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end

        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value: boolean, FloatPosition: UDim2?)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end

        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end

            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}

            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end

                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end

            if #HandledChildren == 0 then
                return
            end

            local DockedWidth = Holder.AbsoluteSize.X / Library.DPIScale
            if DockedWidth < 50 then
                DockedWidth = 200
            end
            Box.PopOutDockedWidth = math.max(50, math.floor(DockedWidth + 0.5))

            local Width = GetPopOutWidth()

            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(
                    AbsolutePosition.X / Library.DPIScale,
                    AbsolutePosition.Y / Library.DPIScale
                ),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end

            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end

            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then
                continue
            end

            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end
        
        PlaceholderHeader = nil

        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PopOutDockedWidth = nil
        Box.PoppedOut = false

        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    function Box:SetMaxPopOutHeight(Height: number?)
        if Height ~= nil then
            assert(typeof(Height) == "number", "Height must be a number or nil")
            assert(Height >= 0, "Height must be higher than 0")
        end

        Box.PopOutMaxHeight = Height
        if Box.PoppedOut and Box.Resize then
            Box:Resize()
        end
    end

    function Box:SetPopOutWidth(Width: number?)
        if Width ~= nil then
            assert(typeof(Width) == "number", "Width must be a number or nil")
            assert(Width >= 0, "Width must be higher than 0")
        end

        Box.PopOutWidth = Width
        ApplyPopOutWidth()
    end

    --// Drag Handler
    local function StopDrag()
        if DragState == "Idle" then
            return
        end

        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input: InputObject)
        if DragState ~= "Idle" or Box.Destroyed or not (ScreenGui and ScreenGui.Parent) then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            if (DragState :: any) ~= "Holding" or DragInput ~= Input then
                return
            end

            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input: InputObject)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end

            Box:SetPoppedOut(true)
            if not Float then
                return
            end

            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui: GuiObject)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input: InputObject)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end

    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = IconImage or New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })

            Library:ApplyLucideIcon(IconImage, CustomIcon)
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableButton:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = New("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local MaxClickDistance = ExcludeDragging and 12 or math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local StartPos = Input.Position
        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if (Input.Position - StartPos).Magnitude <= MaxClickDistance then
                Library:SafeCallback(Func, DraggableImageButton)
            end

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        Icon = NewIcon or Icon

        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(IconImage, CustomIcon)
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?,
    SpecificCornersOnly: ("top" | "bottom" | "no_left" | "no_top_left")?, -- stupid way of doing this
    AnimationType: ("Dropdown" | "KeyPicker" | "none")?
)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })
    Library:AddShadow(Menu, 14, 4, 0.55)

    local Corner;
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,

        Active = false,
        ActiveCallback = ActiveCallback,

        Holder = Holder,
        Menu = Menu,
        Corner = Corner,

        List = nil,
        Signal = nil,

        Size = Size,
        AutoSizeY = List == 1,

        OpenCloseTween = nil,
        Animated = function()
            if not AnimationType or AnimationType == "none" then
                return false
            end

            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end

            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y

                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end

            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end

            local HolderAllowed = Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end

                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end

        Table.Active = false
        CurrentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end

            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    function Table:Destroy()
        Table.Destroyed = true

        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end

        if CurrentMenu == Table then
            Table:Close()
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end

        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)

local TooltipMeasureId = 0
local LastTooltipText = ""
local LastTooltipMaxWidth = 0

local function UpdateTooltipSize(Force: boolean?)
    if Library.Unloaded or not TooltipLabel.Visible then
        return
    end

    local MaxWidth = math.max(
        40,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    if
        not Force
        and TooltipLabel.Text == LastTooltipText
        and math.abs(MaxWidth - LastTooltipMaxWidth) < 1
        and TooltipLabel.Size.X.Offset > 0
    then
        return
    end

    TooltipMeasureId += 1
    local MeasureId = TooltipMeasureId
    local Text = TooltipLabel.Text

    local X, Y = Library:GetTextBounds(Text, TooltipLabel.FontFace, TooltipLabel.TextSize, MaxWidth)
    if MeasureId ~= TooltipMeasureId or TooltipLabel.Text ~= Text then
        return
    end

    LastTooltipText = Text
    LastTooltipMaxWidth = MaxWidth
    TooltipLabel.Size = UDim2.fromOffset(X + 8, Y + 4)
end

TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    UpdateTooltipSize(false)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Position = UDim2.fromOffset(
            Mouse.X + (Library.ShowCustomCursor and 8 or 14),
            Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
        )
        TooltipLabel.Visible = true
        UpdateTooltipSize(true)

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            MenuVisible = Info.NoUI ~= true,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel

        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local SlideForwardConn, SlideBackConn
        local CancelSlidingTweens = function()
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end

            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        local PickerHoverTween = nil

        local function ApplyPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)
            PickerHoverTween = nil

            Picker.TextTransparency = Transparency
            if SlidingLabel then
                SlidingLabel.TextTransparency = Transparency
            end
        end

        local function TweenPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)

            PickerHoverTween = TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = Transparency,
            })
            PickerHoverTween:Play()

            if SlidingLabel then
                TweenService:Create(SlidingLabel, Library.TweenInfo, {
                    TextTransparency = Transparency,
                }):Play()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseEnter:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseLeave:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0.4)
        end))

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 9),
                Parent = Holder,
            })

            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })
            if CheckIcon then
                Library:ApplyLucideIcon(CheckImage, CheckIcon)
            end

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            table.insert(KeyPicker.Connections, Holder.MouseButton1Click:Connect(function()
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                KeyPicker:Update()
            end))

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes)
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"

        local MenuTable
        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        KeyPicker.Menu = MenuTable
        KeyPicker.PickerButton = Picker

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
                if KeyPicker.Update then
                    KeyPicker:Update()
                end
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            table.insert(KeyPicker.Connections, Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end))

            table.insert(KeyPicker.Connections, Button.MouseEnter:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, Button.MouseLeave:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        local SetPickingState = function(State, SkipUpdate: boolean?)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end

            if SkipUpdate ~= true then
                (KeyPicker :: any):Update()
            end
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth

                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X

                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)

                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()

                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfo = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })

                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })

                            SlideForwardTween:Play()

                            if SlideForwardConn then
                                SlideForwardConn:Disconnect()
                            end

                            if SlideBackConn then
                                SlideBackConn:Disconnect()
                            end

                            SlideForwardConn = SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackConn = SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X / Library.DPIScale
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset((X + 9), (Y + 4))
            end
        end

        function KeyPicker:Update()
            local Disabled = ParentObj.Disabled == true

            if Disabled and Picking then
                SetPickingState(false, true)
            end

            KeyPicker:Display()

            Picker.Active = not Disabled
            ApplyPickerTextTransparency(Disabled and 0.8 or 0.4)

            if Disabled then
                if MenuTable.Active then
                    MenuTable:Close()
                end
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if Info.NoUI then
                return
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(KeyPicker.MenuVisible ~= false)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking or ParentObj.Disabled then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end

            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if ParentObj.Disabled then
                return
            end

            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        function KeyPicker:SetMenuVisibility(Visible: boolean)
            assert(typeof(Visible) == "boolean", "Visible must be a boolean")

            KeyPicker.MenuVisible = Visible
            KeyPicker:Update()
        end

        table.insert(KeyPicker.Connections, Picker.MouseButton1Click:Connect(function()
            if Picking or Library.IsPicking or ParentObj.Disabled then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 18)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            MenuTable:Toggle()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                ParentObj.Disabled
                or KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if HoldingKey then
                if KeyPicker.Mode == "Toggle" then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Hold" then
                    InputChanged = Input.Changed:Connect(function()
                        if KeyPicker:GetState() then
                            return
                        end

                        KeyPicker:Update()
                        if InputChanged and InputChanged.Connected then
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end

                KeyPicker:Update()
            end
        end))

        KeyPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, KeyPicker)

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true

            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end

                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = KeyPicker

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,

            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        }); table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local MapSize = Library.IsMobile and 140 or 200
        local BarWidth = 16
        local MenuWidth = MapSize + BarWidth + 6 + 12
        if Info.Transparency then
            MenuWidth += BarWidth + 6
        end

        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(MenuWidth, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active: boolean)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end

                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        --// Content Holder \\--
        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        --// Footer \\--
        local FooterHeight = Library.IsMobile and 30 or 22

        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, MapSize),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(MapSize, MapSize),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(BarWidth, MapSize),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(BarWidth, MapSize),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        --// Resizing \\--
        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = BarWidth
            local BasePadding = 6
            local MinMapSize = 140

            ColorPicker.MapWidth = MapSize
            ColorPicker.MapHeight = MapSize

            local function GetBarWidth(MapWidth)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end

            local function GetContentWidth(MapWidth)
                local CurrentBarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + CurrentBarWidth + BasePadding
                if Info.Transparency then
                    Width += (CurrentBarWidth + BasePadding)
                end

                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                local Camera = workspace.CurrentCamera
                if not Camera then
                    return NewWidth, NewHeight
                end

                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12

                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end

                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end

                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local CurrentBarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)

                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            local ResizeGrabberIcon = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })
            if ResizeIcon then
                Library:ApplyLucideIcon(ResizeGrabberIcon, ResizeIcon)
            end

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input: InputObject)
                Library.CantDragForced = true
                local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight

                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)

                    RunService.RenderStepped:Wait()
                end

                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                table.insert(ColorPicker.Connections, Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end))

                table.insert(ColorPicker.Connections, Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end))

                table.insert(ColorPicker.Connections, Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end))
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                if not Library.CopiedColor then
                    return
                end

                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// Copy/Paste Buttons \\--
        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseButton1Click:Connect(function()
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }

            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end

                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseButton1Click:Connect(function()
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId

            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end

                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            RefreshFooterInfo()
        end

        local function ApplyHolderVisual(Disabled: boolean)
            Holder.Active = not Disabled
            HolderStroke.Transparency = Disabled and 0.5 or 0
            Holder.BackgroundTransparency = Disabled and 0.5 or 0

            if Disabled then
                Holder.BackgroundColor3 = ColorPicker.Value:Lerp(Library.Scheme.BackgroundColor, 0.5)
                HolderTransparency.ImageTransparency = math.clamp((1 - ColorPicker.Transparency) + 0.5, 0, 1)
            else
                Holder.BackgroundColor3 = ColorPicker.Value
                HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
                HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)
            end
        end

        function ColorPicker:RunChanged()
            if ParentObj.Disabled then
                return
            end

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            local Disabled = ParentObj.Disabled == true
            ApplyHolderVisual(Disabled)

            if Disabled then
                if ColorMenu.Active then
                    ColorMenu:Close()
                end

                if ContextMenu.Active then
                    ContextMenu:Close()
                end
            end

            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, Holder.MouseButton1Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ColorMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ContextMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end))

        for _, BoxPair in {
            { HueBox, HueBoxStroke },
            { RgbBox, RgbBoxStroke }
        } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]

            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, ColorPicker)

        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            ColorPicker.Destroyed = true

            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if ColorMenu then
                ColorMenu:Destroy()
            end

            if ResizeGrabber then
                ResizeGrabber:Destroy()
            end

            if ContextMenu then
                ContextMenu:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        if self.Destroyed then return nil end

        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X / Library.DPIScale)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",

            Parent = Groupbox,
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",

            Parent = Groupbox,
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Visible = Label.Visible,
            Parent = Container,
        })

        function Label:Display()
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X / Library.DPIScale
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            table.insert(Label.Connections, TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end))
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then
                TextLabel:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)

                if LblIdx then
                    table.remove(Labels, LblIdx)
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick
                Info.HoldTime = tonumber(Params.HoldToConfirm)
                Info.Icon = Params.Icon or Params.IconName

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false
                Info.HoldTime = nil
                Info.Icon = nil

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,
            HoldTime = Info.HoldTime,
            Icon = Info.Icon,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Locked = false,

            Base = nil,
            Stroke = nil,
            Content = nil,
            Label = nil,
            IconImage = nil,

            Tween = nil,
            Type = "Button",

            Parent = Groupbox,
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function ApplyButtonIcon(Button, IconName)
            local Content = Button.Content
            if not Content then
                return
            end

            local ParsedIcon = Library:GetCustomIcon(IconName)
            if ParsedIcon then
                local ColorKey = Button.Risky and "RedColor" or (ParsedIcon.Custom and "WhiteColor" or "FontColor")

                if not Button.IconImage then
                    Button.IconImage = New("ImageLabel", {
                        BackgroundTransparency = 1,
                        ImageColor3 = ColorKey,
                        LayoutOrder = 0,
                        Size = UDim2.fromOffset(14, 14),
                        Parent = Content,
                    })
                else
                    Button.IconImage.ImageColor3 = Library.Scheme[ColorKey]
                    Library.Registry[Button.IconImage].ImageColor3 = ColorKey
                end

                Button.IconImage.ImageTransparency = Button.Disabled and 0.8 or 0.4
                Button.IconImage.Visible = true
                Library:ApplyLucideIcon(Button.IconImage, ParsedIcon)
            elseif Button.IconImage then
                Button.IconImage.Visible = false
            end
        end

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = "",
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            if Button.HoldTime then
                Button.Progress = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 0.55,
                    Size = UDim2.fromScale(0, 1),
                    Visible = false,
                    Parent = Base,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                        Parent = Button.Progress,
                    })
                )
            end

            local Content = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(0, 16),
                Parent = Base,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = Content,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Content,
            })

            Button.Content = Content
            Button.Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, 16),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = Button.Disabled and 0.8 or 0.4,
                Parent = Content,
            })

            if Button.Risky then
                Button.Label.TextColor3 = Library.Scheme.RedColor
                Library.Registry[Button.Label].TextColor3 = "RedColor"
            end

            ApplyButtonIcon(Button, Button.Icon)

            return Base, Stroke
        end

        local function InitEvents(Button)
            table.insert(Button.Connections, Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()
                TweenService:Create(Button.Base, Library.TweenInfo, {
                    BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 6),
                }):Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenService:Create(Button.IconImage, Library.TweenInfo, {
                        ImageTransparency = 0,
                    }):Play()
                end
            end))
            table.insert(Button.Connections, Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()
                TweenService:Create(Button.Base, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.MainColor,
                }):Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenService:Create(Button.IconImage, Library.TweenInfo, {
                        ImageTransparency = 0.4,
                    }):Play()
                end
            end))

            --// Hold to confirm: HoldToConfirm = seconds \--
            if Button.HoldTime then
                table.insert(Button.Connections, Button.Base.InputBegan:Connect(function(Input: InputObject)
                    if not IsClickInput(Input) or Button.Disabled or Button.Locked or not Button.Progress then
                        return
                    end

                    Button.Locked = true
                    Button.Label.Text = "Hold to confirm"
                    Button.Progress.Size = UDim2.fromScale(0, 1)
                    Button.Progress.Visible = true

                    local Fill = TweenService:Create(
                        Button.Progress,
                        TweenInfo.new(Button.HoldTime, Enum.EasingStyle.Linear),
                        { Size = UDim2.fromScale(1, 1) }
                    )
                    Fill:Play()

                    local Start = tick()
                    local Done = false
                    while Input.UserInputState ~= Enum.UserInputState.End and not Library.Unloaded do
                        if tick() - Start >= Button.HoldTime then
                            Done = true
                            break
                        end

                        RunService.RenderStepped:Wait()
                    end

                    Fill:Cancel()
                    Button.Progress.Visible = false
                    Button.Label.Text = Button.Text
                    RunService.RenderStepped:Wait()
                    Button.Locked = false

                    if Done then
                        Library:SafeCallback(Button.Func)
                    end
                end))
            end

            table.insert(Button.Connections, Button.Base.MouseButton1Click:Connect(function()
                if Button.Disabled or Button.Locked or Button.HoldTime then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    local IconWasVisible = false
                    if Button.IconImage then
                        IconWasVisible = Button.IconImage.Visible
                        Button.IconImage.Visible = false
                    end

                    Button.Label.Text = "Are you sure?"
                    Button.Label.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Label].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Label.Text = Button.Text
                    Button.Label.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Label].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Button.IconImage then
                        Button.IconImage.Visible = IconWasVisible
                    end

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait()
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end))
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,
                HoldTime = Info.HoldTime,
                Icon = Info.Icon,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,
                Locked = false,

                Base = nil,
                Stroke = nil,
                Content = nil,
                Label = nil,
                IconImage = nil,

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
                SubButton.Label.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                if SubButton.IconImage and SubButton.IconImage.Visible then
                    SubButton.IconImage.ImageTransparency = SubButton.Disabled and 0.8 or 0.4
                end

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
                Library:UpdateAddons(SubButton)
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Label.Text = Text
            end

            function SubButton:SetIcon(Icon: string?)
                SubButton.Icon = Icon
                ApplyButtonIcon(SubButton, Icon)
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker

            function SubButton:Destroy()
                SubButton.Destroyed = true

                if SubButton.Connections then
                    for _, Connection in SubButton.Connections do
                        Connection:Disconnect()
                    end
                end

                if SubButton.TooltipTable then
                    SubButton.TooltipTable:Destroy()
                end

                if SubButton.Tween then
                    SubButton.Tween:Destroy()
                end

                if SubButton.Base then
                    SubButton.Base:Destroy()
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)

                    if BIdx then
                        table.remove(Buttons, BIdx)
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Button.Label.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            if Button.IconImage and Button.IconImage.Visible then
                Button.IconImage.ImageTransparency = Button.Disabled and 0.8 or 0.4
            end

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
            Library:UpdateAddons(Button)
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Label.Text = Text
        end

        function Button:SetIcon(Icon: string?)
            Button.Icon = Icon
            ApplyButtonIcon(Button, Icon)
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker

        function Button:Destroy()
            Button.Destroyed = true

            if Button.Connections then
                for _, Connection in Button.Connections do
                    Connection:Disconnect()
                end
            end

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end

            if Button.Tween then
                Button.Tween:Destroy()
            end

            if Button.SubButton then
                Button.SubButton:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)

                if BIdx then
                    table.remove(Buttons, BIdx)
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })
        if CheckIcon then
            Library:ApplyLucideIcon(CheckImage, CheckIcon)
        end

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)
        Library:AttachToggleTree(Toggle, Groupbox, Container, Info)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Description = Info.Description,
            Highlight = Info.Highlight == true,
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Row = Library:MakeRowCard(Container, {
            Button = true,
            Active = not Toggle.Disabled,
            Text = Toggle.Text,
            Description = Info.Description,
            RightInset = 70,
            Addons = true,
            Highlight = Info.Highlight == true,
            Visible = Toggle.Visible,
        })
        local Button, Label, ButtonStroke = Row.Card, Row.Label, Row.Stroke
        Label.TextTransparency = 0.4

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(46, 26),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 3),
            PaddingTop = UDim.new(0, 3),
            Parent = Switch,
        })
        New("UIGradient", {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 200)),
            Rotation = 90,
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "BackgroundColor"

            --// Highlighted rows get an accent tint while enabled (like the "Silent Aim" card) \\--
            if Toggle.Highlight then
                Library.Registry[Button].BackgroundColor3 = function()
                    if Toggle.Value then
                        return Library.Scheme.AccentColor:Lerp(Library.Scheme.BackgroundColor, 0.65)
                    end

                    return Library.Scheme.MainColor
                end
                Button.BackgroundColor3 = Library.Registry[Button].BackgroundColor3()
                Button.BackgroundTransparency = Toggle.Value and 0 or 0.25
                ButtonStroke.Color = Toggle.Value and Library.Scheme.AccentColor:Lerp(Library.Scheme.OutlineColor, 0.6) or Library.Scheme.OutlineColor

                if Row.Shadow then
                    Library.Registry[Row.Shadow].Color = function()
                        return Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.DarkColor
                    end
                    Row.Shadow.Color = Library.Registry[Row.Shadow].Color()
                    Row.Shadow.Transparency = Toggle.Value and 0.5 or 0.7
                end
            end
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        function Toggle:SetDescription(Text: string?)
            Toggle.Description = Text
            Row.SetDescription(Text)
            Groupbox:Resize()
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)
        Library:AttachToggleTree(Toggle, Groupbox, Container, Info)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Description = Info.Description,

            Type = "Input",
        }

        local Row = Library:MakeRowCard(Container, {
            Text = Input.Text,
            Description = Info.Description,
            RightInset = 150,
            Visible = Input.Visible,
        })
        local Holder, Label = Row.Card, Row.Label

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = "BackgroundColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(130, 30),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 6),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
            BoxStroke.Transparency = Input.Disabled and 0.5 or 0

            Box.BackgroundColor3 = Library.Scheme.BackgroundColor
            Library.Registry[Box].BackgroundColor3 = "BackgroundColor"
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:RunChanged()
            if Input.Disabled then
                return
            end

            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            Input:RunChanged()
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        function Input:SetDescription(Text: string?)
            Input.Description = Text
            Row.SetDescription(Text)
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end

                Input:SetValue(Box.Text)
            end))
        end

        table.insert(Input.Connections, Box.Focused:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "AccentColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Input.Connections, Box.FocusLost:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "OutlineColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end

        Input:UpdateColors()
        Options[Idx] = Input

        function Input:Destroy()
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.TooltipTable then
                Input.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Description = Info.Description,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Compact = Info.Compact == true
        local Row
        local Holder
        local SliderLabel

        if Compact then
            Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Visible = Slider.Visible,
                Parent = Container,
            })
        else
            Row = Library:MakeRowCard(Container, {
                Text = Slider.Text,
                Description = Info.Description,
                RightInset = 190,
                Visible = Slider.Visible,
            })
            Holder, SliderLabel = Row.Card, Row.Label
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Compact and "MainColor" or "BackgroundColor",
            Position = Compact and UDim2.fromScale(1, 0.5) or UDim2.new(1, -14, 0.5, 0),
            Size = Compact and UDim2.new(1, 0, 0, 18) or UDim2.fromOffset(170, 24),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = Compact and 14 or 12,
            TextXAlignment = Compact and Enum.TextXAlignment.Center or Enum.TextXAlignment.Right,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        if not Compact then
            New("UIPadding", {
                PaddingRight = UDim.new(0, 10),
                Parent = DisplayLabel,
            })
        end
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local InputTextBox
        local InputTextBoxStroke
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 14,
                ZIndex = Bar.ZIndex + 3,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = Bar,
            })
            InputTextBoxStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })
        New("UIGradient", {
            Color = function()
                return ColorSequence.new(Library.Scheme.AccentColor:Lerp(Color3.new(1, 1, 1), 0.28), Library.Scheme.AccentColor)
            end,
            Parent = Fill,
        })

        local PillCorner = Compact and UDim.new(0, Library.CornerRadius / 2) or UDim.new(1, 0)
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = PillCorner,
                Parent = Bar,
            })
        )
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = PillCorner,
                Parent = Fill,
            })
        )

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax or not Compact then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetDescription(Text: string?)
            Slider.Description = Text
            if Row then
                Row.SetDescription(Text)
            end
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local LastValidText = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Text = InputTextBox.Text
                local AsNum = tonumber(Text)

                if #tostring(Text) > 0 and not AsNum and Text ~= "-" then
                    InputTextBox.Text = LastValidText
                else
                    if Slider.Rounding == 0 and Text:find("%.") then
                        InputTextBox.Text = LastValidText
                        return
                    end

                    local DecimalPos = Text:find("%.")
                    if DecimalPos and Slider.Rounding > 0 then
                        local Decimals = #Text - DecimalPos
                        if Decimals > Slider.Rounding then
                            InputTextBox.Text = LastValidText
                            return
                        end
                    end

                    LastValidText = Text

                    if AsNum then
                        if AsNum > Slider.Max then
                            InputTextBox.Text = tostring(Slider.Max)
                        elseif AsNum < Slider.Min then
                            InputTextBox.Text = tostring(Slider.Min)
                        end
                    end
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Num = tonumber(InputTextBox.Text)
                if not Num then
                    return
                end

                Num = Round(Num, Slider.Rounding)
                Slider:SetValue(Num)
            end))

            table.insert(Slider.Connections, InputTextBox.Focused:Connect(function()
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "AccentColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                if Slider.Disabled then
                    return
                end

                Library.Registry[InputTextBoxStroke].Color = "DarkColor"
                TweenService:Create(InputTextBoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.DarkColor,
                }):Play()
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end
            local InnerScroller = Container:IsA("ScrollingFrame") and Container or Container:FindFirstAncestorWhichIsA("ScrollingFrame")
            if InnerScroller then
                InnerScroller.ScrollingEnabled = false
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end
            if InnerScroller then
                InnerScroller.ScrollingEnabled = true
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,
            Description = Info.Description,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,

            Multi = Info.Multi,
            DragSelect = Info.Multi and not Library.IsMobile and Info.DragSelect == true,
            KeepDisabledValuePosition = Info.KeepDisabledValuePosition == true,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Dropdown",
        }

        local HasText = typeof(Dropdown.Text) == "string" and Dropdown.Text ~= ""
        local Row
        local Holder
        local Label

        if HasText then
            Row = Library:MakeRowCard(Container, {
                Text = Dropdown.Text,
                Description = Info.Description,
                RightInset = 196,
                MinHeight = 52,
                Visible = Dropdown.Visible,
            })
            Holder, Label = Row.Card, Row.Label
        else
            Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Visible = Dropdown.Visible,
                Parent = Container,
            })
            Label = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 0),
                Text = "",
                Visible = false,
                Parent = Holder,
            })
        end

        Dropdown.Card = Row
        Dropdown.IsCard = HasText

        local DisplayContainer = New("TextButton", {
            AnchorPoint = HasText and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
            BackgroundColor3 = HasText and "BackgroundColor" or "MainColor",
            Position = HasText and UDim2.new(1, -14, 0.5, 0) or UDim2.fromScale(0, 0.5),
            Size = HasText and UDim2.fromOffset(176, 32) or UDim2.new(1, 0, 0, 30),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        local DropdownCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = DisplayContainer,
        }); table.insert(Library.SpecificCorners, DropdownCorner)

        local DisplayImage = New("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, -4, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Image = "",
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local ArrowImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = DisplayContainer,
        })
        if ArrowIcon then
            Library:ApplyLucideIcon(ArrowImage, ArrowIcon)
        end

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })

            table.insert(Dropdown.Connections, SearchBox.Focused:Connect(function()
                Library.Registry[DisplayStroke].Color = "AccentColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Dropdown.Connections, SearchBox.FocusLost:Connect(function()
                Library.Registry[DisplayStroke].Color = "OutlineColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        local GetValueImage = function(Value, RawValue)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                local PlayerValue = Value
                if typeof(PlayerValue) ~= "Instance" and RawValue ~= nil then
                    PlayerValue = RawValue
                end

                if typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(PlayerValue.UserId)) }
                end
            end

            if Dropdown.ValueImages then
                local IconRef = Dropdown.ValueImages[Value]
                if IconRef == nil and RawValue ~= nil then
                    IconRef = Dropdown.ValueImages[RawValue]
                end

                if IconRef then
                    ValueImage = Library:GetCustomIcon(IconRef)
                end
            end

            return ValueImage
        end

        --// Menu is wider than the pill when the dropdown lives inside a card (right-aligned) \\--
        local function GetMenuWidth()
            local Width = DisplayContainer.AbsoluteSize.X / Library.DPIScale
            if Dropdown.IsCard then
                Width = math.max(Width, Info.MenuWidth or 236)
            end

            return Width
        end

        local MenuTable
        MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                return UDim2.fromOffset(GetMenuWidth(), 0)
            end,
            function()
                return {
                    DisplayContainer.AbsoluteSize.X - (GetMenuWidth() * Library.DPIScale) + 0.5,
                    DisplayContainer.AbsoluteSize.Y + (Dropdown.IsCard and 6 or 1.5),
                }
            end,
            2,
            function(Active: boolean)
                DisplayButton.TextTransparency = (Active and SearchBox) and 1 or 0

                ArrowImage.ImageTransparency = Active and 0 or 0.5
                ArrowImage.Rotation = Active and 180 or 0

                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end

                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                local Attached = not Dropdown.IsCard

                DropdownCorner.TopLeftRadius = Half
                DropdownCorner.TopRightRadius = Half
                DropdownCorner.BottomRightRadius = (Active and Attached) and Zero or Half
                DropdownCorner.BottomLeftRadius = (Active and Attached) and Zero or Half

                local MenuCorner = MenuTable and MenuTable.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Attached and Zero or Half
                    MenuCorner.TopRightRadius = Attached and Zero or Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end,
            false,
            "bottom",
            "Dropdown"
        )
        Dropdown.Menu = MenuTable

        local ItemHeight = 28
        local PoolSize = math.max(1, Info.MaxVisibleDropdownItems + 2)
        local Pool = {}
        local FilteredEntries = {}

        function Dropdown:RecalculateListSize(Count)
            local ItemCount = Count or #FilteredEntries
            local Y = math.clamp(ItemCount * ItemHeight, 0, Info.MaxVisibleDropdownItems * ItemHeight)

            MenuTable.Menu.CanvasSize = UDim2.fromOffset(0, ItemCount * ItemHeight)

            MenuTable:SetSize(function()
                return UDim2.fromOffset(GetMenuWidth(), Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayImage.ImageTransparency = Dropdown.Disabled and 0.8 or 0
            ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil
            local IsDictionary = not IsSequentialArray(Dropdown.Values)

            if Info.Multi then
                for Key, RawValue in Dropdown.Values do
                    local Value = IsDictionary and Key or RawValue

                    if Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value, RawValue)
                        end

                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(RawValue)) or tostring(RawValue))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                local DisplayValue = Dropdown.Value
                if IsDictionary and Dropdown.Value ~= nil then
                    DisplayValue = Dropdown.Values[Dropdown.Value]
                end

                ValueImage = GetValueImage(Dropdown.Value, DisplayValue)
                Str = DisplayValue and tostring(DisplayValue) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            if #Str > 25 then
                Str = Str:sub(1, 22) .. "..."
            end

            DisplayButton.Text = (Str == "" and "---" or Str)

            if ValueImage then
                Library:ApplyLucideIcon(DisplayImage, ValueImage)
                DisplayImage.ImageTransparency = 0
            else
                DisplayImage.Image = ""
                DisplayImage.ImageTransparency = 1
            end

            DisplayButton.Size = ValueImage and UDim2.new(1, -8, 1, 0) or UDim2.new(1, 0, 1, 0)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues(ReturnCount)
            local Table = {}

            if Info.Multi then
                for Value, _ in Dropdown.Value do
                    table.insert(Table, Value)
                end
            else
                if Dropdown.Value then
                    table.insert(Table, Dropdown.Value)
                end
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local DragSelecting = false
        local DragStartIndex = nil
        local DragPrevMin = nil
        local DragPrevMax = nil
        local DragLastIndex = nil
        local DragInitialValues = {}
        local DragInputEndedConn = nil
        local DragInputChangedConn = nil

        local function RecomputeFilteredEntries()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local IsDictionary = not IsSequentialArray(Values)

            --// Fuzzy-match dropdown values the same way the sidebar search
            --// does, so e.g. "clr" can find "Clear Inventory" in a list \\--
            local SearchQuery = SearchBox and NormalizeSearch(SearchBox.Text:lower()) or ""
            local IsSearching = SearchQuery ~= ""

            local EnabledList, DisabledList = {}, {}
            local Pending = {}

            for Key, RawValue in Values do
                local Value = IsDictionary and Key or RawValue

                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local MatchScore = 0
                if IsSearching then
                    local Matched, Score = FuzzyScore(FormattedValue:lower(), SearchQuery)
                    if not Matched then
                        continue
                    end
                    MatchScore = Score
                end

                local IsDisabled = table.find(DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(DisabledValues, RawValue) ~= nil)

                local Entry = {
                    Value = Value,
                    RawValue = RawValue,
                    FormattedValue = FormattedValue,
                    IsDisabled = IsDisabled,
                    ValueImage = GetValueImage(Value, RawValue),
                    SortKey = Key,
                    MatchScore = MatchScore,
                    Order = #Pending + 1,
                }

                table.insert(Pending, Entry)
            end

            if IsSearching then
                --// Best matches first; ties fall back to original order \\--
                table.sort(Pending, function(A, B)
                    if A.MatchScore ~= B.MatchScore then
                        return A.MatchScore > B.MatchScore
                    end
                    return A.Order < B.Order
                end)
            elseif not IsDictionary then
                table.sort(Pending, function(A, B)
                    return A.SortKey < B.SortKey
                end)
            end

            table.clear(FilteredEntries)

            if Dropdown.KeepDisabledValuePosition then
                for _, Entry in Pending do
                    table.insert(FilteredEntries, Entry)
                end
                return
            end

            for _, Entry in Pending do
                if Entry.IsDisabled then
                    table.insert(DisabledList, Entry)
                else
                    table.insert(EnabledList, Entry)
                end
            end

            for _, Entry in EnabledList do
                table.insert(FilteredEntries, Entry)
            end
            for _, Entry in DisabledList do
                table.insert(FilteredEntries, Entry)
            end
        end

        local function GetFirstVisibleIndex()
            local Total = #FilteredEntries
            if Total <= PoolSize then
                return 1
            end

            local MaxFirst = Total - PoolSize + 1
            local ScrollY = MenuTable.Menu.CanvasPosition.Y / Library.DPIScale
            local Index = math.floor(ScrollY / ItemHeight) + 1
            return math.clamp(Index, 1, MaxFirst)
        end

        function Dropdown:RefreshPool()
            local Total = #FilteredEntries
            local First = GetFirstVisibleIndex()

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = FilteredEntries[DataIndex]

                Row.Entry = Entry
                Row.Index = Entry and DataIndex or nil

                if not Entry then
                    Row.Container.Visible = false
                    continue
                end

                Row.Container.Visible = true
                Row.Container.Position = UDim2.fromOffset(0, (DataIndex - 1) * ItemHeight)

                local IsLast = DataIndex == Total
                Row.Corner.BottomRightRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                Row.Corner.BottomLeftRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)

                Row.Button.Text = Entry.FormattedValue

                if Entry.ValueImage then
                    Row.Image.Visible = true
                    Library:ApplyLucideIcon(Row.Image, Entry.ValueImage)
                    Row.Button.Size = UDim2.new(1, -18, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(18, 0)
                else
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, 0, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(0, 0)
                end

                Row:UpdateButton()
            end
        end

        function Dropdown:RunChanged()
            if Dropdown.Disabled then
                return
            end

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        local function StopDragSelect()
            DragSelecting = false
            DragStartIndex = nil
            DragPrevMin = nil
            DragPrevMax = nil
            DragLastIndex = nil
            table.clear(DragInitialValues)

            if DragInputEndedConn then
                DragInputEndedConn:Disconnect()
                DragInputEndedConn = nil
            end

            if DragInputChangedConn then
                DragInputChangedConn:Disconnect()
                DragInputChangedConn = nil
            end
        end

        local DragActiveCount = 0

        local function ApplyDragIndex(Index, InRange)
            local Entry = FilteredEntries[Index]
            if not Entry or Entry.IsDisabled then
                return
            end

            local Try = DragInitialValues[Entry.Value]
            if InRange then
                Try = not Try
            end

            local WantActive = Try and true or false
            local IsActive = Dropdown.Value[Entry.Value] and true or false
            if WantActive == IsActive then
                return
            end

            if not WantActive and DragActiveCount == 1 and not Info.AllowNull then
                return
            end

            Dropdown.Value[Entry.Value] = WantActive and true or nil
            DragActiveCount += WantActive and 1 or -1
        end

        local function ApplyDragRange(From, To, InRange)
            for Index = From, To do
                ApplyDragIndex(Index, InRange)
            end
        end

        local function UpdateDrag(CurrentIndex)
            if CurrentIndex == nil or CurrentIndex == DragLastIndex then
                return
            end

            DragLastIndex = CurrentIndex

            local Min = math.min(DragStartIndex, CurrentIndex)
            local Max = math.max(DragStartIndex, CurrentIndex)
            DragActiveCount = Dropdown:GetActiveValues(true)

            if DragPrevMin == nil then
                ApplyDragRange(Min, Max, true)
            else
                if DragPrevMin < Min then
                    ApplyDragRange(DragPrevMin, Min - 1, false)
                end
                if DragPrevMax > Max then
                    ApplyDragRange(Max + 1, DragPrevMax, false)
                end
                if Min < DragPrevMin then
                    ApplyDragRange(Min, DragPrevMin - 1, true)
                end
                if Max > DragPrevMax then
                    ApplyDragRange(DragPrevMax + 1, Max, true)
                end
            end

            DragPrevMin = Min
            DragPrevMax = Max

            for _, OtherRow in Pool do
                OtherRow:UpdateButton()
            end
        end

        local function CreatePoolRow()
            local Row = {
                Entry = nil,
                Index = nil
            }

            local Container = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Visible = false,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Container,
            }); table.insert(Library.SpecificCorners, Corner)

            local Image = New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(6, 6),
                Visible = false,
                Parent = Container,
            })

            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                Parent = Button,
            })

            Row.Container = Container
            Row.Corner = Corner
            Row.Image = Image
            Row.Button = Button

            function Row:UpdateButton()
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                Row.Selected = Selected and true or false

                Container.BackgroundTransparency = Selected and 0 or 1
                Button.TextTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5

                if Entry.ValueImage then
                    Image.ImageTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5
                end
            end

            table.insert(Dropdown.Connections, Button.MouseButton1Click:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or DragSelecting then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                local Try = not Selected
                if not (Dropdown:GetActiveValues(true) == 1 and not Try and not Info.AllowNull) then
                    Selected = Try
                    if Info.Multi then
                        Dropdown.Value[Entry.Value] = Selected and true or nil
                    else
                        Dropdown.Value = Selected and Entry.Value or nil
                    end

                    for _, OtherRow in Pool do
                        OtherRow:UpdateButton()
                    end
                end

                Row:UpdateButton()
                Dropdown:Display()

                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end))

            table.insert(Dropdown.Connections, Button.MouseEnter:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.25,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.25,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.MouseLeave:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()

                if Image then
                    TweenService:Create(Image, Library.TweenInfo, {
                        ImageTransparency = 0.5,
                    }):Play()
                end
            end))

            table.insert(Dropdown.Connections, Button.InputBegan:Connect(function(StartInput)
                if not (Info.Multi and Dropdown.DragSelect and not Library.IsMobile) then
                    return
                end

                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled then
                    return
                end

                if not IsMouseInput(StartInput) then
                    return
                end

                DragSelecting = true
                DragStartIndex = Row.Index
                table.clear(DragInitialValues)

                for _, FilteredEntry in FilteredEntries do
                    DragInitialValues[FilteredEntry.Value] = Dropdown.Value[FilteredEntry.Value]
                end

                UpdateDrag(Row.Index)

                if DragInputEndedConn then DragInputEndedConn:Disconnect() end
                if DragInputChangedConn then DragInputChangedConn:Disconnect() end

                DragInputChangedConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(ChangeInput)
                    if not IsMovementInput(ChangeInput) and ChangeInput ~= StartInput then
                        return
                    end

                    local Pos = ChangeInput.Position
                    for _, OtherRow in Pool do
                        if OtherRow.Entry and Library:MouseIsOverFrame(OtherRow.Button, Pos) then
                            UpdateDrag(OtherRow.Index)
                            break
                        end
                    end
                end))

                DragInputEndedConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= StartInput and not (IsMouseInput(EndInput) and EndInput.UserInputType == StartInput.UserInputType) then
                        return
                    end

                    Dropdown:Display()
                    Library:UpdateDependencyBoxes()
                    Dropdown:RunChanged()

                    StopDragSelect()
                end))

                table.insert(Dropdown.Connections, DragInputEndedConn)
                table.insert(Dropdown.Connections, DragInputChangedConn)
            end))

            return Row
        end

        function Dropdown:BuildDropdownList()
            StopDragSelect()

            RecomputeFilteredEntries()

            MenuTable.Menu.CanvasPosition = Vector2.new(0, 0)

            Dropdown:RefreshPool()
            Dropdown:RecalculateListSize(#FilteredEntries)
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreatePoolRow())
        end

        table.insert(Dropdown.Connections, MenuTable.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Dropdown:RefreshPool()
        end))

        local function ValueExists(Val)
            if IsSequentialArray(Dropdown.Values) then
                for _, Existing in Dropdown.Values do
                    if Existing == Val then
                        return true
                    end
                end

                return false
            end

            return Dropdown.Values[Val] ~= nil
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                if typeof(Value) == "string" then
                    Value = if Value == "" then {} else { [Value] = true }
                end

                local Table = {}

                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and ValueExists(Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if ValueExists(Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Row in Pool do
                Row:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            Dropdown:RunChanged()
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values

            local Changed = false
            if Info.Multi then
                for Val in Dropdown.Value do
                    if not ValueExists(Val) then
                        Dropdown.Value[Val] = nil
                        Changed = true
                    end
                end

            elseif Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then
                Dropdown.Value = nil
                Changed = true
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()

            if Changed and not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if Changed then
                Dropdown:RunChanged()
            end
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            if IsDictionary then
                if typeof(Values) == "string" then
                    Dropdown.Values[Values] = Values

                elseif IsSequentialArray(Values) then
                    for _, Val in Values do
                        Dropdown.Values[Val] = Val
                    end

                else
                    for Key, Val in Values do
                        Dropdown.Values[Key] = Val
                    end
                end
            else
                if typeof(Values) == "table" then
                    for _, Val in Values do
                        table.insert(Dropdown.Values, Val)
                    end
                else
                    table.insert(Dropdown.Values, Values)
                end
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            Dropdown.ValueImages = ValueImages
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()

            Library:UpdateDependencyBoxes()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            if Row then
                Row.SetText(Text)
            end
        end

        function Dropdown:SetDescription(Text: string?)
            Dropdown.Description = Text
            if Row then
                Row.SetDescription(Text)
            end
        end

        function Dropdown:SetDragSelect(Value: boolean)
            if not Info.Multi or Library.IsMobile then
                Value = false
            end

            Dropdown.DragSelect = Value == true
            Dropdown:BuildDropdownList()
        end

        local ToggleDropdown = function()
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end

        table.insert(Dropdown.Connections, DisplayContainer.MouseButton1Click:Connect(ToggleDropdown))
        table.insert(Dropdown.Connections, DisplayButton.MouseButton1Click:Connect(ToggleDropdown))

        if SearchBox then
            table.insert(Dropdown.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList))
        end

        local Defaults = (function()
            local Resolved = {}
            local Default = Info.Default
            if Default == nil then
                return Resolved
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                if IsDictionary then
                    return Dropdown.Values[Candidate] ~= nil and Candidate or nil
                end

                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then
                        return Existing
                    end
                end

                return nil
            end

            local DefaultType = typeof(Default)
            if DefaultType == "string" then
                local Value = ResolveOne(Default)
                if Value ~= nil then
                    table.insert(Resolved, Value)
                end

            elseif DefaultType == "table" then
                for _, Candidate in Default do
                    local Value = ResolveOne(Candidate)
                    if Value ~= nil then
                        table.insert(Resolved, Value)
                    end
                end

            elseif Dropdown.Values[Default] ~= nil then
                table.insert(Resolved, IsDictionary and Default or Dropdown.Values[Default])
            end

            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Info.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        function Dropdown:Destroy()
            Dropdown.Destroyed = true

            StopDragSelect()

            if Dropdown.Connections then
                for _, Connection in Dropdown.Connections do
                    Connection:Disconnect()
                end
            end

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable:Destroy()
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Dropdown)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Dropdown
    end

    --// ============================== Range slider ============================== \\--
    function Funcs:AddRangeSlider(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, {
            Text = "Range",
            Min = 0,
            Max = 100,
            Default = { 25, 75 },
            Rounding = 0,
            MinRange = 0,
            Prefix = "",
            Suffix = "",
            Callback = function() end,
            Changed = function() end,
            Disabled = false,
            Visible = true,
        })

        local Groupbox = self
        local Container = Groupbox.Container

        local Low = math.clamp(tonumber(Info.Default[1]) or Info.Min, Info.Min, Info.Max)
        local High = math.clamp(tonumber(Info.Default[2]) or Info.Max, Info.Min, Info.Max)
        if Low > High then
            Low, High = High, Low
        end

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Description = Info.Description,

            Min = Info.Min,
            Max = Info.Max,
            Rounding = Info.Rounding,
            MinRange = Info.MinRange,
            Prefix = Info.Prefix,
            Suffix = Info.Suffix,

            Low = Low,
            High = High,
            Value = { Low, High },

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "RangeSlider",
            Parent = Groupbox,
        }

        local Row = Library:MakeRowCard(Container, {
            Text = Slider.Text,
            Description = Info.Description,
            RightInset = 190,
            Visible = Slider.Visible,
        })
        local Holder = Row.Card

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(170, 24),
            Text = "",
            Parent = Holder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Bar }))

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })
        New("UIGradient", {
            Color = function()
                return ColorSequence.new(Library.Scheme.AccentColor:Lerp(Color3.new(1, 1, 1), 0.28), Library.Scheme.AccentColor)
            end,
            Parent = Fill,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill }))

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 12,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local function CreateKnob()
            local Knob = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "FontColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = Bar.ZIndex + 3,
                Parent = Bar,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
            New("UIStroke", { Color = "AccentColor", Thickness = 2, Parent = Knob })
            return Knob
        end
        local LowKnob, HighKnob = CreateKnob(), CreateKnob()

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
            LowKnob.Visible = not Slider.Disabled
            HighKnob.Visible = not Slider.Disabled
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local Span = math.max(Slider.Max - Slider.Min, 1e-9)
            local LowScale = (Slider.Low - Slider.Min) / Span
            local HighScale = (Slider.High - Slider.Min) / Span

            Fill.Position = UDim2.fromScale(LowScale, 0)
            Fill.Size = UDim2.fromScale(math.max(HighScale - LowScale, 0), 1)
            LowKnob.Position = UDim2.fromScale(LowScale, 0.5)
            HighKnob.Position = UDim2.fromScale(HighScale, 0.5)

            DisplayLabel.Text = string.format("%s%s%s  -  %s%s%s", Slider.Prefix, Slider.Low, Slider.Suffix, Slider.Prefix, Slider.High, Slider.Suffix)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:RunChanged()
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Low, Slider.High)
            Library:SafeCallback(Slider.Changed, Slider.Low, Slider.High)
        end

        function Slider:SetValue(NewLow, NewHigh)
            if typeof(NewLow) == "table" then
                NewLow, NewHigh = NewLow[1] or NewLow.Low, NewLow[2] or NewLow.High
            end

            NewLow = tonumber(NewLow)
            NewHigh = tonumber(NewHigh)
            if not NewLow or not NewHigh then
                return
            end

            NewLow = math.clamp(NewLow, Slider.Min, Slider.Max)
            NewHigh = math.clamp(NewHigh, Slider.Min, Slider.Max)
            if NewLow > NewHigh then
                NewLow, NewHigh = NewHigh, NewLow
            end
            if NewLow == Slider.Low and NewHigh == Slider.High then
                return
            end

            Slider.Low, Slider.High = NewLow, NewHigh
            Slider.Value = { NewLow, NewHigh }
            Slider:Display()
            Slider:RunChanged()
        end

        function Slider:GetValue()
            return Slider.Low, Slider.High
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled
            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Disabled
            end

            Bar.Active = not Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible
            Holder.Visible = Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            Row.SetText(Text)
        end

        function Slider:SetDescription(Text: string?)
            Slider.Description = Text
            Row.SetDescription(Text)
        end

        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) or Slider.Disabled then
                return
            end

            local function MouseScale()
                return math.clamp((Mouse.X - Bar.AbsolutePosition.X) / math.max(Bar.AbsoluteSize.X, 1), 0, 1)
            end

            local Span = Slider.Max - Slider.Min
            local Start = MouseScale()
            local LowScale = (Slider.Low - Slider.Min) / math.max(Span, 1e-9)
            local HighScale = (Slider.High - Slider.Min) / math.max(Span, 1e-9)

            --// grab the closest handle (the high one when both sit on the same spot and you pull right) \\--
            local Which
            if math.abs(Start - LowScale) == math.abs(Start - HighScale) then
                Which = Start > HighScale and "High" or "Low"
            else
                Which = math.abs(Start - LowScale) < math.abs(Start - HighScale) and "Low" or "High"
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end
            local InnerScroller = Container:IsA("ScrollingFrame") and Container or Container:FindFirstAncestorWhichIsA("ScrollingFrame")
            if InnerScroller then
                InnerScroller.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Value = Round(Slider.Min + Span * MouseScale(), Slider.Rounding)
                local OldLow, OldHigh = Slider.Low, Slider.High

                if Which == "Low" then
                    Slider.Low = math.clamp(Value, Slider.Min, Slider.High - Slider.MinRange)
                else
                    Slider.High = math.clamp(Value, Slider.Low + Slider.MinRange, Slider.Max)
                end

                if Slider.Low ~= OldLow or Slider.High ~= OldHigh then
                    Slider.Value = { Slider.Low, Slider.High }
                    Slider:Display()
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end
            if InnerScroller then
                InnerScroller.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)
        Slider.Default = { Slider.Low, Slider.High }
        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true
            for _, Connection in Slider.Connections do
                Connection:Disconnect()
            end
            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end
            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end
            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    --// ============================== Reorderable list ============================== \\--
    function Funcs:AddReorderList(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, {
            Text = "List",
            Items = {},
            ItemHeight = 30,
            Callback = function() end,
            Changed = function() end,
            Disabled = false,
            Visible = true,
        })

        local Groupbox = self
        local Container = Groupbox.Container
        local ItemHeight = Info.ItemHeight

        local List = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Description = Info.Description,
            Order = {},
            Value = {},

            Callback = Info.Callback,
            Changed = Info.Changed,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "ReorderList",
            Parent = Groupbox,
        }

        for _, Item in Info.Items do
            local Name = tostring(Item)
            if not table.find(List.Order, Name) then
                table.insert(List.Order, Name)
            end
        end
        List.Value = table.clone(List.Order)

        local Holder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = List.Visible,
            Parent = Container,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            Parent = Holder,
        })

        local Header = Library:MakeRowCard(Holder, {
            Text = List.Text,
            Description = Info.Description,
            RightInset = 16,
            MinHeight = 40,
        })
        Header.Card.LayoutOrder = 0

        local ListFrame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.25,
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = Holder,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = ListFrame }))
        New("UIStroke", { Color = "OutlineColor", Transparency = 0.45, Parent = ListFrame })
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            Parent = ListFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = ListFrame,
        })

        local Rows = {}
        local GripIcon = Library:GetIcon("grip-vertical")

        local function Refresh()
            for Position, Name in List.Order do
                local Row = Rows[Name]
                if Row then
                    Row.Frame.LayoutOrder = Position
                    Row.Index.Text = "#" .. Position
                end
            end
        end

        function List:RunChanged()
            if List.Disabled then
                return
            end

            Library:SafeCallback(List.Callback, List.Value)
            Library:SafeCallback(List.Changed, List.Value)
        end

        local function CreateRow(Name: string)
            local Frame = New("TextButton", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Text = "",
                Parent = ListFrame,
            })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = Frame }))
            local Stroke = New("UIStroke", { Color = "OutlineColor", Transparency = 0.3, Parent = Frame })

            if GripIcon then
                local Grip = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageColor3 = "FontColor",
                    ImageTransparency = 0.5,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    Parent = Frame,
                })
                Library:ApplyLucideIcon(Grip, GripIcon)
            end

            New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(34, 0),
                Size = UDim2.new(1, -80, 1, 0),
                Text = Name,
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame,
            })
            local Index = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(36, 16),
                Text = "",
                TextSize = 12,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Frame,
            })

            table.insert(List.Connections, Frame.InputBegan:Connect(function(Input: InputObject)
                if not IsClickInput(Input) or List.Disabled then
                    return
                end

                local Changed = false
                Stroke.Color = Library.Scheme.AccentColor
                Frame.BackgroundColor3 = Library.Scheme.MainColor

                if Library.ActiveTab then
                    for _, Side in Library.ActiveTab.Sides do
                        Side.ScrollingEnabled = false
                    end
                end

                while IsDragInput(Input) and not List.Destroyed do
                    local Step = (ItemHeight + 4) * Library.DPIScale
                    local Y = Mouse.Y - ListFrame.AbsolutePosition.Y - 8 * Library.DPIScale
                    local Target = math.clamp(math.floor(Y / Step) + 1, 1, #List.Order)
                    local Current = table.find(List.Order, Name)

                    if Current and Target ~= Current then
                        table.remove(List.Order, Current)
                        table.insert(List.Order, Target, Name)
                        Refresh()
                        Changed = true
                    end

                    RunService.RenderStepped:Wait()
                end

                Stroke.Color = Library.Scheme.OutlineColor
                Frame.BackgroundColor3 = Library.Scheme.BackgroundColor
                if Library.ActiveTab then
                    for _, Side in Library.ActiveTab.Sides do
                        Side.ScrollingEnabled = true
                    end
                end

                if Changed then
                    List.Value = table.clone(List.Order)
                    List:RunChanged()
                end
            end))

            Rows[Name] = { Frame = Frame, Index = Index, Stroke = Stroke }
        end

        local function Rebuild()
            for _, Row in Rows do
                Row.Frame:Destroy()
            end
            table.clear(Rows)

            for _, Name in List.Order do
                CreateRow(Name)
            end
            Refresh()
        end

        function List:OnChanged(Func)
            List.Changed = Func
        end

        function List:SetValue(NewOrder)
            if typeof(NewOrder) ~= "table" then
                return
            end

            local Result = {}
            for _, Name in NewOrder do
                Name = tostring(Name)
                if table.find(List.Order, Name) and not table.find(Result, Name) then
                    table.insert(Result, Name)
                end
            end
            for _, Name in List.Order do
                if not table.find(Result, Name) then
                    table.insert(Result, Name)
                end
            end

            List.Order = Result
            List.Value = table.clone(Result)
            Refresh()
            List:RunChanged()
        end

        function List:GetValue()
            return table.clone(List.Order)
        end

        function List:SetItems(Items)
            List.Order = {}
            for _, Item in Items do
                local Name = tostring(Item)
                if not table.find(List.Order, Name) then
                    table.insert(List.Order, Name)
                end
            end

            List.Value = table.clone(List.Order)
            Rebuild()
            List:RunChanged()
        end

        function List:AddItem(Item)
            local Name = tostring(Item)
            if table.find(List.Order, Name) then
                return
            end

            table.insert(List.Order, Name)
            List.Value = table.clone(List.Order)
            CreateRow(Name)
            Refresh()
            List:RunChanged()
        end

        function List:RemoveItem(Item)
            local Name = tostring(Item)
            local Position = table.find(List.Order, Name)
            if not Position then
                return
            end

            table.remove(List.Order, Position)
            List.Value = table.clone(List.Order)
            if Rows[Name] then
                Rows[Name].Frame:Destroy()
                Rows[Name] = nil
            end
            Refresh()
            List:RunChanged()
        end

        function List:SetDisabled(Disabled: boolean)
            List.Disabled = Disabled
        end

        function List:SetVisible(Visible: boolean)
            List.Visible = Visible
            Holder.Visible = Visible
            Groupbox:Resize()
        end

        function List:SetText(Text: string)
            List.Text = Text
            Header.SetText(Text)
        end

        function List:SetDescription(Text: string?)
            List.Description = Text
            Header.SetDescription(Text)
        end

        Rebuild()
        Groupbox:Resize()

        List.Holder = Holder
        table.insert(Groupbox.Elements, List)
        List.Default = table.clone(List.Order)
        Options[Idx] = List

        function List:Destroy()
            List.Destroyed = true
            for _, Connection in List.Connections do
                Connection:Disconnect()
            end
            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, List)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end
            Groupbox:Resize()
            Options[Idx] = nil
        end

        return List
    end

    --// ============================== Tree view ============================== \\--
    function Funcs:AddTreeView(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, {
            Text = "Tree",
            Nodes = {},
            Default = {},
            Expanded = true,
            MaxHeight = 240,
            Callback = function() end,
            Changed = function() end,
            Disabled = false,
            Visible = true,
        })

        local Groupbox = self
        local Container = Groupbox.Container

        local Tree = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Description = Info.Description,
            Value = {},

            Callback = Info.Callback,
            Changed = Info.Changed,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "TreeView",
            Parent = Groupbox,
        }

        --// node model \\--
        local Nodes = {}
        local function Build(Infos, Parent, Depth)
            local Result = {}
            for _, NodeInfo in Infos do
                local IsTable = typeof(NodeInfo) == "table"
                local Name = tostring(IsTable and NodeInfo.Name or NodeInfo)
                local Node = {
                    Name = Name,
                    Path = (Parent and (Parent.Path .. "/") or "") .. Name,
                    Parent = Parent,
                    Depth = Depth,
                    Children = {},
                    Expanded = Info.Expanded,
                }
                if IsTable and NodeInfo.Expanded ~= nil then
                    Node.Expanded = NodeInfo.Expanded
                end
                if IsTable and typeof(NodeInfo.Children) == "table" and #NodeInfo.Children > 0 then
                    Node.Children = Build(NodeInfo.Children, Node, Depth + 1)
                end

                Nodes[Node.Path] = Node
                table.insert(Result, Node)
            end
            return Result
        end
        local Roots = Build(Info.Nodes, nil, 0)
        local Checked = {}

        local function Leaves(Node, Out)
            Out = Out or {}
            if #Node.Children == 0 then
                table.insert(Out, Node)
            else
                for _, Child in Node.Children do
                    Leaves(Child, Out)
                end
            end
            return Out
        end

        --// 0 = none, 1 = all, 0.5 = some \\--
        local function State(Node)
            local All = Leaves(Node)
            local Count = 0
            for _, Leaf in All do
                if Checked[Leaf.Path] then
                    Count += 1
                end
            end

            if Count == 0 then
                return 0
            end
            return Count == #All and 1 or 0.5
        end

        local function Collect()
            local Result = {}
            local function Walk(List)
                for _, Node in List do
                    if #Node.Children == 0 then
                        if Checked[Node.Path] then
                            table.insert(Result, Node.Path)
                        end
                    else
                        Walk(Node.Children)
                    end
                end
            end
            Walk(Roots)
            return Result
        end

        local function CheckPath(Path)
            local Node = Nodes[Path]
            if not Node then
                return
            end

            for _, Leaf in Leaves(Node) do
                Checked[Leaf.Path] = true
            end
        end
        for _, Path in Info.Default do
            CheckPath(tostring(Path))
        end
        Tree.Value = Collect()

        --// ui \\--
        local Holder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = Tree.Visible,
            Parent = Container,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            Parent = Holder,
        })

        local Header = Library:MakeRowCard(Holder, {
            Text = Tree.Text,
            Description = Info.Description,
            RightInset = 16,
            MinHeight = 40,
        })
        Header.Card.LayoutOrder = 0

        local Scroll = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.25,
            CanvasSize = UDim2.fromScale(0, 0),
            LayoutOrder = 1,
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = 3,
            Size = UDim2.new(1, 0, 0, 60),
            Parent = Holder,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = Scroll }))
        New("UIStroke", { Color = "OutlineColor", Transparency = 0.45, Parent = Scroll })
        local Layout = New("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = Scroll,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = Scroll,
        })

        local function FitHeight()
            local Content = (Layout.AbsoluteContentSize.Y / Library.DPIScale) + 12
            Scroll.Size = UDim2.new(1, 0, 0, math.clamp(Content, 36, Info.MaxHeight))
        end
        table.insert(Tree.Connections, Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(FitHeight))

        local RowFrames = {}
        local Render

        function Tree:RunChanged()
            if Tree.Disabled then
                return
            end

            Library:SafeCallback(Tree.Callback, Tree.Value)
            Library:SafeCallback(Tree.Changed, Tree.Value)
        end

        local function ToggleCheck(Node)
            if Tree.Disabled then
                return
            end

            local All = State(Node) == 1
            for _, Leaf in Leaves(Node) do
                Checked[Leaf.Path] = (not All) or nil
            end

            Tree.Value = Collect()
            Render()
            Tree:RunChanged()
        end

        local function CreateRow(Node)
            local Frame = New("TextButton", {
                BackgroundColor3 = "BackgroundColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Text = "",
                Parent = Scroll,
            })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 3), Parent = Frame }))

            local X = 4 + Node.Depth * 18
            if #Node.Children > 0 and ArrowIcon then
                local Chevron = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageColor3 = "FontColor",
                    ImageTransparency = 0.4,
                    Position = UDim2.new(0, X, 0.5, 0),
                    Rotation = Node.Expanded and 180 or 90,
                    Size = UDim2.fromOffset(14, 14),
                    Parent = Frame,
                })
                Library:ApplyLucideIcon(Chevron, ArrowIcon, Node.Expanded and 180 or 90)
            end

            local Box = New("TextButton", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "BackgroundColor",
                Position = UDim2.new(0, X + 20, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                Text = "",
                Parent = Frame,
            })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box }))
            New("UIStroke", { Color = "OutlineColor", Parent = Box })

            local Current = State(Node)
            if Current == 1 and CheckIcon then
                local Tick = New("ImageLabel", {
                    ImageColor3 = "AccentColor",
                    Position = UDim2.fromOffset(1, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    Parent = Box,
                })
                Library:ApplyLucideIcon(Tick, CheckIcon)
            elseif Current == 0.5 then
                local Dash = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = "AccentColor",
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(8, 2),
                    Parent = Box,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dash })
            end

            New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(X + 44, 0),
                Size = UDim2.new(1, -(X + 48), 1, 0),
                Text = Node.Name,
                TextSize = 14,
                TextTransparency = Current == 0 and 0.4 or 0,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame,
            })

            Frame.MouseEnter:Connect(function()
                TweenService:Create(Frame, Library.TweenInfo, { BackgroundTransparency = 0.6 }):Play()
            end)
            Frame.MouseLeave:Connect(function()
                TweenService:Create(Frame, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            end)
            Frame.MouseButton1Click:Connect(function()
                if #Node.Children > 0 then
                    Node.Expanded = not Node.Expanded
                    Render()
                else
                    ToggleCheck(Node)
                end
            end)
            Box.MouseButton1Click:Connect(function()
                ToggleCheck(Node)
            end)

            table.insert(RowFrames, Frame)
        end

        Render = function()
            for _, Frame in RowFrames do
                Frame:Destroy()
            end
            table.clear(RowFrames)

            local function Walk(List)
                for _, Node in List do
                    CreateRow(Node)
                    if #Node.Children > 0 and Node.Expanded then
                        Walk(Node.Children)
                    end
                end
            end
            Walk(Roots)
        end

        function Tree:OnChanged(Func)
            Tree.Changed = Func
        end

        function Tree:SetValue(Paths)
            if typeof(Paths) ~= "table" then
                return
            end

            table.clear(Checked)
            for _, Path in Paths do
                CheckPath(tostring(Path))
            end

            Tree.Value = Collect()
            Render()
            Tree:RunChanged()
        end

        function Tree:GetValue()
            return table.clone(Tree.Value)
        end

        function Tree:IsChecked(Path: string): boolean
            local Node = Nodes[Path]
            return Node ~= nil and State(Node) == 1
        end

        function Tree:SetExpanded(Expanded: boolean)
            for _, Node in Nodes do
                if #Node.Children > 0 then
                    Node.Expanded = Expanded
                end
            end
            Render()
        end

        function Tree:SetDisabled(Disabled: boolean)
            Tree.Disabled = Disabled
        end

        function Tree:SetVisible(Visible: boolean)
            Tree.Visible = Visible
            Holder.Visible = Visible
            Groupbox:Resize()
        end

        function Tree:SetText(Text: string)
            Tree.Text = Text
            Header.SetText(Text)
        end

        function Tree:SetDescription(Text: string?)
            Tree.Description = Text
            Header.SetDescription(Text)
        end

        Render()
        Groupbox:Resize()

        Tree.Holder = Holder
        table.insert(Groupbox.Elements, Tree)
        Tree.Default = table.clone(Tree.Value)
        Options[Idx] = Tree

        function Tree:Destroy()
            Tree.Destroyed = true
            for _, Connection in Tree.Connections do
                Connection:Disconnect()
            end
            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Tree)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end
            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Tree
    end

    --// ============================== Feature card ============================== \\--
    function Funcs:AddFeatureCard(Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, {
            Title = "Feature",
            Description = "",
            Callback = function() end,
            Visible = true,
        })

        local Groupbox = self
        local Container = Groupbox.Container

        local Card = {
            Connections = {},
            Destroyed = false,

            Text = Info.Title,
            Title = Info.Title,
            Description = Info.Description,
            Target = Info.Target,
            Callback = Info.Callback,
            Visible = Info.Visible,

            Type = "FeatureCard",
            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.25,
            Size = UDim2.new(1, 0, 0, 0),
            Text = "",
            Visible = Card.Visible,
            Parent = Container,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Button }))
        local Stroke = New("UIStroke", { Color = "OutlineColor", Transparency = 0.45, Parent = Button })
        local Shadow = Library:AddShadow(Button, 8, 3, 0.7)
        if Shadow then
            Library.ElementShadows[Shadow] = true
        end

        New("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = Button,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 22),
            PaddingLeft = UDim.new(0, 18),
            PaddingRight = UDim.new(0, 18),
            PaddingTop = UDim.new(0, 22),
            Parent = Button,
        })

        local IconImage = New("ImageLabel", {
            ImageColor3 = "AccentColor",
            LayoutOrder = 1,
            Size = UDim2.fromOffset(38, 38),
            Visible = false,
            Parent = Button,
        })
        local TitleLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Size = UDim2.fromScale(1, 0),
            Text = Card.Title,
            TextSize = 18,
            TextWrapped = true,
            Parent = Button,
        })
        local DescriptionLabel = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 3,
            Size = UDim2.fromScale(0.9, 0),
            Text = Card.Description,
            TextSize = 13,
            TextTransparency = 0.45,
            TextWrapped = true,
            Visible = Card.Description ~= "",
            Parent = Button,
        })

        function Card:SetIcon(Icon: string?)
            local Parsed = Library:GetCustomIcon(Icon)
            if Parsed then
                IconImage.Visible = true
                Library:ApplyLucideIcon(IconImage, Parsed)
            else
                IconImage.Visible = false
            end
        end
        function Card:SetTitle(Text: string)
            Card.Title, Card.Text = Text, Text
            TitleLabel.Text = Text
        end
        function Card:SetText(Text: string)
            Card:SetTitle(Text)
        end
        function Card:SetDescription(Text: string?)
            Card.Description = Text or ""
            DescriptionLabel.Text = Card.Description
            DescriptionLabel.Visible = Card.Description ~= ""
        end
        function Card:SetVisible(Visible: boolean)
            Card.Visible = Visible
            Button.Visible = Visible
            Groupbox:Resize()
        end
        function Card:Click()
            local Target = Card.Target
            if typeof(Target) == "table" and typeof(Target.Show) == "function" then
                Target:Show()
            elseif typeof(Target) == "function" then
                Library:SafeCallback(Target)
            end
            Library:SafeCallback(Card.Callback)
        end

        Card:SetIcon(Info.Icon)

        table.insert(Card.Connections, Button.MouseEnter:Connect(function()
            TweenService:Create(Stroke, Library.TweenInfo, { Transparency = 0.1 }):Play()
        end))
        table.insert(Card.Connections, Button.MouseLeave:Connect(function()
            TweenService:Create(Stroke, Library.TweenInfo, { Transparency = 0.45 }):Play()
        end))
        table.insert(Card.Connections, Button.MouseButton1Click:Connect(function()
            Card:Click()
        end))

        Groupbox:Resize()
        Card.Holder = Button
        table.insert(Groupbox.Elements, Card)

        function Card:Destroy()
            Card.Destroyed = true
            for _, Connection in Card.Connections do
                Connection:Disconnect()
            end
            if Button then
                Button:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Card)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end
            Groupbox:Resize()
        end

        return Card
    end

    --// ============================== Rich label (markdown-lite) ============================== \\--
    function Funcs:AddRichLabel(Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "string" then
            Info = { Text = Info }
        end
        Info = Library:Validate(Info, { Text = "", Visible = true })

        local Groupbox = self
        local Container = Groupbox.Container

        local Rich = {
            Connections = {},
            Destroyed = false,

            Source = Info.Text,
            Text = "",
            Visible = Info.Visible,

            Type = "RichLabel",
            Parent = Groupbox,
        }

        local Holder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = Rich.Visible,
            Parent = Container,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = Holder,
        })

        local Pieces = {}
        local function Clear()
            for _, Piece in Pieces do
                Piece:Destroy()
            end
            table.clear(Pieces)
        end

        function Rich:SetText(Source: string)
            Rich.Source = Source
            Clear()

            local Blocks = Library.ParseRichText(Source)
            local Plain = {}

            for Index, Block in Blocks do
                if Block.Type == "code" then
                    table.insert(Plain, Block.Text)

                    local Frame = New("Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = "BackgroundColor",
                        LayoutOrder = Index,
                        Size = UDim2.new(1, 0, 0, 0),
                        Parent = Holder,
                    })
                    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = Frame }))
                    New("UIStroke", { Color = "OutlineColor", Parent = Frame })
                    New("UIPadding", {
                        PaddingBottom = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 58),
                        PaddingTop = UDim.new(0, 8),
                        Parent = Frame,
                    })

                    New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        FontFace = Font.fromEnum(Enum.Font.Code),
                        RichText = false,
                        Size = UDim2.fromScale(1, 0),
                        Text = Block.Text,
                        TextSize = 13,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame,
                    })

                    if typeof(setclipboard) == "function" then
                        local Copy = New("TextButton", {
                            AnchorPoint = Vector2.new(1, 0),
                            BackgroundColor3 = "MainColor",
                            Position = UDim2.new(1, -6, 0, 6),
                            Size = UDim2.fromOffset(46, 20),
                            Text = "Copy",
                            TextSize = 12,
                            TextTransparency = 0.3,
                            Parent = Frame,
                        })
                        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Copy })
                        Copy.MouseButton1Click:Connect(function()
                            setclipboard(Block.Text)
                            Copy.Text = "Copied"
                            task.delay(1, function()
                                if Copy.Parent then
                                    Copy.Text = "Copy"
                                end
                            end)
                        end)
                    end

                    table.insert(Pieces, Frame)
                else
                    table.insert(Plain, (Block.Text:gsub("<[^>]+>", "")))

                    local Label = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        LayoutOrder = Index,
                        Size = UDim2.fromScale(1, 0),
                        Text = Block.Text,
                        TextSize = 14,
                        TextTransparency = 0.15,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        Parent = Holder,
                    })
                    table.insert(Pieces, Label)
                end
            end

            Rich.Text = table.concat(Plain, " ")
        end

        function Rich:SetVisible(Visible: boolean)
            Rich.Visible = Visible
            Holder.Visible = Visible
            Groupbox:Resize()
        end

        Rich:SetText(Rich.Source)
        Groupbox:Resize()

        Rich.Holder = Holder
        table.insert(Groupbox.Elements, Rich)

        function Rich:Destroy()
            Rich.Destroyed = true
            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Rich)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end
            Groupbox:Resize()
        end

        return Rich
    end

    function Funcs:AddViewport(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        table.insert(Viewport.Connections, ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = (Viewport.Object :: PVInstance):GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, _, _, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            Viewport.Destroyed = true

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(Image.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            Library:ApplyLucideIcon(ImageLabel, Icon)
            Image.Image = Icon.Url
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            Image.Destroyed = true

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    --// Nested groupbox: Groupbox:AddGroupbox({ Name = "...", Side = "Left" | "Right" | nil }) \\--
    function Funcs:AddGroupbox(Info)
        if self.Destroyed then return nil end

        local Tab = self.Tab
        assert(Tab and Tab._BuildGroupbox, "Nested groupboxes can only be created inside a tab groupbox.")

        return Tab._BuildGroupbox(self, Info)
    end

    function Funcs:AddDependencyBox(ParentFrame)
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = ParentFrame or Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            IsDepbox = true,
            Tab = Groupbox.Tab,
            Page = Groupbox.Page,

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        table.insert(Depbox.Connections, DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end))

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        table.insert(Depbox.Connections, DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end))

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then
                DepboxContainer:Destroy()
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer, 8, 2, 0.7)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then
                DepGroupboxContainer:Destroy()
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then
                table.remove(Tab.DependencyGroupboxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

--// Toggle children: Toggle:AddToggle(...), Toggle:AddDropdown(...), ... (shown as a tree under the toggle) \--
for _, Name in {
    "AddToggle", "AddCheckbox", "AddSlider", "AddInput", "AddDropdown", "AddButton", "AddLabel",
    "AddDivider", "AddViewport", "AddImage", "AddVideo", "AddUIPassthrough", "AddDependencyBox", "AddGroupbox",
} do
    BaseAddons.__index[Name] = function(self, ...)
        assert(self.Type == "Toggle", string.format("%s can only be used as a child of a toggle (or a groupbox).", Name))

        local Tree = self:GetTree()
        return Tree[Name](Tree, ...)
    end
end

--// Reactive wrapper: EnabledWhen / VisibleWhen / computed Text / Help / :Bind work on every element \--
for _, Name in {
    "AddToggle", "AddCheckbox", "AddSlider", "AddRangeSlider", "AddInput", "AddDropdown", "AddButton", "AddLabel",
    "AddReorderList", "AddTreeView", "AddFeatureCard", "AddRichLabel",
} do
    local Original = BaseGroupbox.__index[Name]
    if not Original then
        continue
    end

    BaseGroupbox.__index[Name] = function(self, ...)
        local Args = table.pack(...)

        local InfoIndex
        for Index = 1, Args.n do
            if typeof(Args[Index]) == "table" then
                InfoIndex = Index
                break
            end
        end

        local Info
        local Computed
        if InfoIndex then
            Info = table.clone(Args[InfoIndex])
            Args[InfoIndex] = Info

            for _, Key in { "Text", "Title" } do
                if typeof(Info[Key]) == "function" then
                    Computed = { Key = Key, Fn = Info[Key] }
                    local Success, Value = pcall(Info[Key])
                    Info[Key] = Success and tostring(Value) or ""
                end
            end
        elseif typeof(Args[1]) == "function" and (Name == "AddLabel" or Name == "AddButton") then
            Computed = { Key = "Text", Fn = Args[1] }
            local Success, Value = pcall(Args[1])
            Args[1] = Success and tostring(Value) or ""
        end

        local Element = Original(self, table.unpack(Args, 1, Args.n))
        if typeof(Element) == "table" and not Element.ReactiveReady then
            Library:SetupReactive(Element, Info, Computed)
        end

        return Element
    end
end

--// Markdown-lite -> Roblox rich text. Blocks: { Type = "text" | "code", Text = string } \\--
--// **bold**  *italic*  `code`  [label](url)  ```fenced code blocks``` \\--
function Library.ParseRichText(Source: string)
    local Blocks = {}
    Source = tostring(Source or "")

    local function Escape(Text: string): string
        return (Text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end

    local function Inline(Text: string): string
        Text = Escape(Text)

        local Codes = {}
        Text = Text:gsub("`([^`\n]+)`", function(Code)
            table.insert(Codes, Code)
            return string.format("\0%d\0", #Codes)
        end)

        Text = Text:gsub("%*%*(.-)%*%*", "<b>%1</b>")
        Text = Text:gsub("%*([^%*\n]+)%*", "<i>%1</i>")
        Text = Text:gsub("%[([^%]]+)%]%(([^%)]+)%)", '<u><font color="#5aa9ff">%1</font></u>')

        Text = Text:gsub("\0(%d+)\0", function(Index)
            return '<font face="RobotoMono" color="#e5c07b">' .. Codes[tonumber(Index)] .. "</font>"
        end)

        return Text
    end

    local Position = 1
    local Open = true
    while true do
        local Fence = Source:find("```", Position, true)
        local Chunk = Source:sub(Position, (Fence or (#Source + 1)) - 1)

        if Open then
            Chunk = Trim(Chunk)
            if Chunk ~= "" then
                table.insert(Blocks, { Type = "text", Text = Inline(Chunk) })
            end
        else
            Chunk = Chunk:gsub("^[^\n]*\n", "", 1) -- drop an optional language tag line
            Chunk = Chunk:gsub("\n$", "")
            table.insert(Blocks, { Type = "code", Text = Chunk })
        end

        if not Fence then
            break
        end

        Position = Fence + 3
        Open = not Open
    end

    return Blocks
end

function Library:SetTabButtonState(Button: GuiObject, Selected: boolean)
    TweenService:Create(Button, Library.TweenInfo, {
        BackgroundTransparency = Selected and 0 or 1,
    }):Play()

    local Stroke = Button:FindFirstChildOfClass("UIStroke")
    if Stroke then
        TweenService:Create(Stroke, Library.TweenInfo, {
            Transparency = Selected and 0.35 or 1,
        }):Play()
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:SetBackgroundImage(Image: string | number)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))

    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

function Library:UpdateNotificationPositions(Snap: boolean?)
    local IsLeft = Library.NotifySide:lower() == "left"
    local XScale = IsLeft and 0 or 1
    local RunningY = 0

    for _, FakeBackground in NotifyOrder do
        local Data = Library.Notifications[FakeBackground]
        if not (Data and FakeBackground.Parent) then continue end

        local Target = UDim2.new(XScale, 0, 0, RunningY)
        if Snap or not Data.PositionInitialized then
            FakeBackground.Position = Target
            Data.PositionInitialized = true

        elseif FakeBackground.Position ~= Target then
            TweenService:Create(FakeBackground, Library.NotifyTweenInfo, {
                Position = Target,
            }):Play()
        end

        RunningY = RunningY + FakeBackground.AbsoluteSize.Y / Library.DPIScale + 8
    end
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    local IsLeft = Side:lower() == "left"
    if IsLeft then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
    end

    for FakeBackground in Library.Notifications do
        if not (FakeBackground and FakeBackground.Parent) then continue end
        FakeBackground.AnchorPoint = if IsLeft then Vector2.new(0, 0) else Vector2.new(1, 0)
    end

    if Library.UpdateNotificationPositions then
        Library:UpdateNotificationPositions(true)
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = tostring(Info.Title)
        Data.TitleColor = Info.TitleColor

        Data.Description = tostring(Info.Description)
        Data.DescriptionColor = Info.DescriptionColor

        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
        Data.Persist = Info.Persist

        Data.Callback = typeof(Info.Callback) == "function" and Info.Callback or nil
        Data.Closable = Info.Closable == true

        Data.Icon = Info.Icon
        Data.BigIcon = Info.BigIcon
        Data.IconColor = Info.IconColor

        Data.Volume = tonumber(Info.Volume) or 3
        Data.Action = typeof(Info.Action) == "table" and Info.Action or nil
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
        Data.Volume = select(4, ...) or 3
    end
    Data.Destroyed = false

    local DeletedInstance = false
    local DeleteConnection = nil
    if typeof(Data.Time) == "Instance" then
        DeleteConnection = Data.Time.Destroying:Connect(function()
            DeletedInstance = true

            DeleteConnection:Disconnect()
            DeleteConnection = nil
        end)
    end

    local FakeBackground = New("Frame", {
        AnchorPoint = Library.NotifySide:lower() == "left" and Vector2.new(0, 0) or Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 5,
        Parent = FakeBackground,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local AccentBar = New("Frame", {
        BackgroundColor3 = Data.IconColor or "AccentColor",
        Position = UDim2.fromOffset(2, 10),
        Size = UDim2.new(0, 3, 1, -20),
        ZIndex = 6,
        Parent = Holder,
    })
    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = AccentBar,
    })

    local ContentHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = ContentHolder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = ContentHolder,
    })

    local CloseButton
    if Data.Closable then
        CloseButton = New("ImageButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = CloseIcon and CloseIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = CloseIcon and CloseIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CloseIcon and CloseIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 6,
            Parent = Holder,
        })

        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                ImageTransparency = 0,
            }):Play()
        end)
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, Library.TweenInfo, {
                ImageTransparency = 0.5,
            }):Play()
        end)
        CloseButton.MouseButton1Click:Connect(function()
            Data:Destroy("user")
        end)
    end

    local ContentContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentHolder,
    })

    if Data.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ContentContainer,
        })
    end

    local BigIconLabel
    if Data.BigIcon then
        local ParsedIcon = Library:GetCustomIcon(Data.BigIcon)
        if ParsedIcon then
            BigIconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = Data.IconColor or "AccentColor",
                Parent = ContentContainer,
            })
            Library:ApplyLucideIcon(BigIconLabel, ParsedIcon)
        end
    end

    local TextContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentContainer,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TextContainer,
    })

    local TitleContainer
    if Data.Title then
        TitleContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            Parent = TextContainer,
        })
    end

    local IconLabel
    if Data.Icon and TitleContainer then
        local ParsedIcon = Library:GetCustomIcon(Data.Icon)
        if ParsedIcon then
            IconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                ImageColor3 = Data.IconColor or "FontColor",
                Parent = TitleContainer,
            })
            Library:ApplyLucideIcon(IconLabel, ParsedIcon)
        end
    end

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (IconLabel and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = Data.Title,
            TextColor3 = Data.TitleColor or "FontColor",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = TitleContainer,
        })
    end

    if Data.Description then
        Desc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = Data.Description,
            TextColor3 = Data.DescriptionColor or "FontColor",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = TextContainer,
        })
    end

    function Data:Resize()
        local ExtraWidth = BigIconLabel and 32 or 0
        local IconWidth = IconLabel and 21 or 0
        local CloseWidth = Data.Closable and 20 or 0
        local MaxTextWidth = math.max(
            40,
            (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth - CloseWidth
        )

        if Title then
            local X, Y = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, MaxTextWidth - IconWidth)
            Title.Size = UDim2.fromOffset(X, Y)
            TitleX = X + IconWidth
            TitleContainer.Size = UDim2.fromOffset(TitleX, math.max(Y, IconLabel and 16 or 0))
        end

        if Desc then
            local X, Y = Library:GetTextBounds(Desc.Text, Desc.FontFace, Desc.TextSize, MaxTextWidth)
            Desc.Size = UDim2.fromOffset(X, Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset(math.max(TitleX, DescX) + 24 + ExtraWidth + CloseWidth, 0)

        if Library.Notifications[FakeBackground] then
            task.defer(function()
                if Data.Destroyed or not FakeBackground.Parent then
                    return
                end

                if FakeBackground.AbsoluteSize.Y <= 0 then
                    task.defer(function()
                        if Data.Destroyed or not FakeBackground.Parent then
                            return
                        end

                        Library:UpdateNotificationPositions(true)
                    end)
                    return
                end

                Library:UpdateNotificationPositions(true)
            end)
        end
    end

    function Data:ChangeTitle(Text)
        if Title then
            Data.Title = tostring(Text)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(Text)
        if Desc then
            Data.Description = tostring(Text)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    function Data:Destroy(Reason)
        if Data.Destroyed then
            return
        end

        Reason = Reason or "script"
        Data.Destroyed = true

        if Data.Callback then
            pcall(Data.Callback, Reason)
        end

        if typeof(Data.Time) == "Instance" then
            pcall(Data.Time.Destroy, Data.Time)
        end

        if DeleteConnection then
            DeleteConnection:Disconnect()
        end

        if FakeBackground then
            local Idx = table.find(NotifyOrder, FakeBackground)
            if Idx then
                table.remove(NotifyOrder, Idx)
            end
        end

        Library:UpdateNotificationPositions()

        TweenService
            :Create(Holder, Library.NotifyTweenInfo, {
                Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
            })
            :Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end

    if Data.Action and typeof(Data.Action.Text) == "string" then
        local ActionButton = New("TextButton", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.fromOffset(0, 26),
            Text = Data.Action.Text,
            TextSize = 13,
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = ActionButton,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = ActionButton }))
        New("UIStroke", { Color = "OutlineColor", Parent = ActionButton })

        ActionButton.MouseButton1Click:Connect(function()
            Library:SafeCallback(Data.Action.Callback)
            if Data.Action.Dismiss ~= false then
                Data:Destroy("action")
            end
        end)
    end

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (Data.Persist ~= true and typeof(Data.Time) ~= "Instance") or typeof(Data.Steps) == "number",
        Parent = ContentHolder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })

    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.SoundId then
        local SoundId = Data.SoundId
        if typeof(SoundId) == "number" then
            SoundId = string.format("rbxassetid://%d", SoundId)
        end

        New("Sound", {
            SoundId = SoundId,
            Volume = tonumber(Data.Volume) or 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Data.Holder = Holder

    table.insert(NotifyOrder, FakeBackground)
    Library.Notifications[FakeBackground] = Data

    Data:Resize()

    FakeBackground.Visible = true
    TweenService:Create(Holder, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.defer(function()
        if not Data.Destroyed then
            Library:UpdateNotificationPositions(true)
        end
    end)

    task.delay(Library.NotifyTweenInfo.Time, function()
        if Data.Persist then
            return
        elseif typeof(Data.Time) == "Instance" then
            repeat
                task.wait()
            until DeletedInstance or Data.Destroyed
        else
            TweenService
                :Create(TimerFill, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromScale(0, 1),
                })
                :Play()
            task.wait(Data.Time)
        end

        Data:Destroy("timer")
    end)

    return Data
end

--// Reference-inspired shell styling. Controls deliberately retain their original implementation.
function Library:CreateWindow(WindowInfo)
    -- Surface-only treatment: no Lighting/BlurEffect or changes to the game camera.
    local function ShellSurface(Frame, Radius)
        local Corner = Frame:FindFirstChildOfClass("UICorner")
        if Corner then Corner.CornerRadius = UDim.new(0, Radius)
        else New("UICorner", { CornerRadius = UDim.new(0, Radius), Parent = Frame }) end
        New("UIGradient", {
            Rotation = 65,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.48, Color3.fromRGB(215, 216, 224)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 146, 160)),
            }),
            Parent = Frame,
        })
        local Stroke = Frame:FindFirstChildOfClass("UIStroke")
        if Stroke then Stroke.Transparency = 0.72 end
    end
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Vector2.new(math.min(WindowInfo.MinContainerWidth, MaxX), Library.OriginalMinSize.Y)

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 36)

    local TabButtonsStyle = WindowInfo.TabButtonsStyle

    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64 + TabButtonsStyle.Padding * 2, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.CompactWidthActivation)
    WindowInfo.SnapDistance = math.max(0, WindowInfo.SnapDistance)
    WindowInfo.SnapMargin = math.max(0, WindowInfo.SnapMargin)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch

    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowTitleLabel
    local WindowSubtitleLabel
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local HasBackgroundImage = false
    local BottomBackground
    local BottomBackgroundCorner
    local FooterLabel
    local TopBar
    local WindowSnapConfig = {
        Enabled = WindowInfo.Snapping,
        Distance = WindowInfo.SnapDistance,
        Margin = WindowInfo.SnapMargin,
        AvoidCoreGui = WindowInfo.SnapAvoidCoreGui,
    }

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame, 64, 12, 0.35)
        ShellSurface(MainFrame, WindowInfo.CornerRadius)
        -- The shell is almost black; its subtle purple cast lives in the ambient glow only.
        Library.Registry[MainFrame].BackgroundColor3 = function()
            return Library.Scheme.BackgroundColor:Lerp(Color3.fromRGB(5, 6, 11), 0.65)
        end
        MainFrame.BackgroundColor3 = Library.Registry[MainFrame].BackgroundColor3()

        --// Ambient light: faint accent glow fading out from the top edge \\--
        local AmbientGlow = New("Frame", {
            Active = false,
            BackgroundColor3 = Color3.fromRGB(112, 84, 160),
            Size = UDim2.new(1, 0, 0, 280),
            Visible = Library.AmbientGlow ~= false,
            Parent = MainFrame,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = AmbientGlow,
            })
        )
        New("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.88),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = AmbientGlow,
        })
        Library.AmbientGlowFrame = AmbientGlow

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            BackgroundTransparency = 0.75,
            Parent = MainFrame,
            ZIndex = 2
        })

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        HasBackgroundImage = BackgroundIcon ~= nil
        BackgroundImage = New("ImageLabel", {
            Active = false,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = Overlay.ZIndex + 1,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = false,
            Parent = ScreenGui,
        })
        if BackgroundIcon then
            Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
        end

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not (BackgroundImage and MainFrame) then
                return
            end

            local ShouldShow = HasBackgroundImage and MainFrame.Visible
            BackgroundImage.Visible = ShouldShow

            if not ShouldShow then
                return
            end

            BackgroundImage.Position = UDim2.fromOffset(
                MainFrame.AbsolutePosition.X,
                MainFrame.AbsolutePosition.Y
            )
            BackgroundImage.Size = UDim2.fromOffset(
                MainFrame.AbsoluteSize.X,
                MainFrame.AbsoluteSize.Y
            )
        end))

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true, WindowSnapConfig)

        --// Title \\--
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            local Icon = Library:GetCustomIcon(WindowInfo.Icon)
            WindowIcon = New("ImageLabel", {
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
            if Icon then
                Library:ApplyLucideIcon(WindowIcon, Icon)
            end
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local TitleX = Library:GetTextBounds(WindowInfo.Title, Library.Scheme.Font, 17, 400)
        local SubtitleX = (WindowInfo.Subtitle ~= "") and Library:GetTextBounds(WindowInfo.Subtitle, Library.Scheme.Font, 12, 400) or 0

        WindowTitle = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(math.max(TitleX, SubtitleX) + 4, 36),
            Parent = TitleHolder,
        })
        New("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = WindowTitle,
        })

        WindowTitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Text = WindowInfo.Title,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = WindowTitle,
        })
        WindowSubtitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 13),
            Text = WindowInfo.Subtitle,
            TextSize = 12,
            TextTransparency = 0.55,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = WindowInfo.Subtitle ~= "",
            Parent = WindowTitle,
        })

        --// Top Right Bar \\--
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -185, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 193 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search",
            Size = WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = false, -- replaced by the search panel button
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        local SearchBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "AccentColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "OutlineColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            local SearchIconImage = New("ImageLabel", {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
            Library:ApplyLucideIcon(SearchIconImage, SearchIcon)
        end

        --// Window Controls (maximize / close) \\--
        local function CreateControl(Offset: number, IconData: any, Callback: () -> ())
            local Control = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.2,
                Position = UDim2.new(1, Offset, 0.5, 0),
                Size = UDim2.fromOffset(34, 34),
                Text = "",
                Parent = TopBar,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Control,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Transparency = 0.3,
                Parent = Control,
            })

            local ControlIcon = New("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageColor3 = "FontColor",
                ImageTransparency = 0.4,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(16, 16),
                Parent = Control,
            })
            if IconData then
                Library:ApplyLucideIcon(ControlIcon, IconData)
            end

            Control.MouseEnter:Connect(function()
                TweenService:Create(ControlIcon, Library.TweenInfo, { ImageTransparency = 0 }):Play()
            end)
            Control.MouseLeave:Connect(function()
                TweenService:Create(ControlIcon, Library.TweenInfo, { ImageTransparency = 0.4 }):Play()
            end)
            Control.MouseButton1Click:Connect(Callback)

            return Control
        end

        local Maximized = false
        local RestoreSize, RestorePosition
        CreateControl(-54, Library:GetIcon("maximize"), function()
            if not Maximized then
                RestoreSize, RestorePosition = MainFrame.Size, MainFrame.Position

                local Viewport = workspace.CurrentCamera.ViewportSize / Library.DPIScale
                MainFrame.Size = UDim2.fromOffset(Viewport.X - 40, Viewport.Y - 40)
                MainFrame.Position = UDim2.fromOffset(20, 20)
            elseif RestoreSize and RestorePosition then
                MainFrame.Size = RestoreSize
                MainFrame.Position = RestorePosition
            end

            Maximized = not Maximized
            for _, Tab in Library.Tabs do
                Tab:Resize(true)
            end
        end)
        CreateControl(-12, CloseIcon, function()
            Library:Toggle(false)
        end)

        local SearchButton = CreateControl(-96, Library:GetIcon("search"), function()
            Library.SearchPanel:Toggle()
        end)
        Library.SearchButton = SearchButton
        Library.WindowIcon = WindowInfo.Icon

        --// minimize into a floating orb \--
        CreateControl(-138, Library:GetIcon("minus"), function()
            Library:Minimize()
        end)

        --// Search panel: Tab > Page > Groupbox > Element : Type \\--
        do
            local SearchPanel = { Active = false }
            local ModifiedOnly = false
            Library.SearchPanel = SearchPanel

            local Panel = New("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "BackgroundColor",
                Position = UDim2.new(1, -12, 0, 56),
                Size = UDim2.fromOffset(420, 66),
                Visible = false,
                ZIndex = 100,
                Parent = MainFrame,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Panel,
                })
            )
            Library:AddOutline(Panel, 30, 10, 0.35)

            local InputHolder = New("Frame", {
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromOffset(10, 10),
                Size = UDim2.new(1, -20, 0, 38),
                Parent = Panel,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = InputHolder,
                })
            )
            local InputStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = InputHolder,
            })

            local SearchIcon = Library:GetIcon("search")
            if SearchIcon then
                local SearchIconImage = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    ImageColor3 = "FontColor",
                    ImageTransparency = 0.5,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    Parent = InputHolder,
                })
                Library:ApplyLucideIcon(SearchIconImage, SearchIcon)
            end

            local SearchInput = New("TextBox", {
                BackgroundTransparency = 1,
                ClearTextOnFocus = false,
                PlaceholderText = "Search tabs, pages, groupboxes, elements...",
                Position = UDim2.fromOffset(36, 0),
                Size = UDim2.new(1, -126, 1, 0),
                Text = "",
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = InputHolder,
            })
            SearchInput.Focused:Connect(function()
                TweenService:Create(InputStroke, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()
            end)
            SearchInput.FocusLost:Connect(function()
                TweenService:Create(InputStroke, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()
            end)

            local ResultsFrame = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromOffset(10, 56),
                ScrollBarImageColor3 = "OutlineColor",
                ScrollBarThickness = 2,
                Size = UDim2.new(1, -20, 0, 28),
                Parent = Panel,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 4),
                Parent = ResultsFrame,
            })

            local EmptyLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Text = "Type to search",
                TextSize = 13,
                TextTransparency = 0.5,
                Parent = ResultsFrame,
            })

            local function Escape(Text)
                return (tostring(Text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
            end

            --// Navigate to a result: switch tab / page / sub-tab, expand groupboxes, scroll + flash \--
            local function Reveal(Context, Target)
                if Context.Tab and Context.Tab.Show then
                    Context.Tab:Show()
                end
                if Context.Page then
                    Context.Page:Show()
                end
                if Context.SubTab then
                    Context.SubTab:Show()
                end

                local Box = Context.Groupbox
                while Box do
                    if Box.Collapsed and Box.SetCollapsed then
                        Box:SetCollapsed(false)
                    end
                    Box = Box.ParentBox
                end

                if not Target then
                    return
                end

                task.spawn(function()
                    local Animated = Library.Animations and Library.Animations.TabSwitch
                    task.wait(Animated and (Library.TabTransitionInfo.Time + 0.05) or 0.08)

                    if not Target.Parent then
                        return
                    end

                    local Inner = Target.Parent
                    local ScrolledInner = false
                    while Inner do
                        if Inner:IsA("ScrollingFrame") and Inner.Name ~= "CloudyColumn" and Inner.ScrollBarThickness > 0 then
                            local InnerY = Target.AbsolutePosition.Y - Inner.AbsolutePosition.Y + Inner.CanvasPosition.Y
                            Inner.CanvasPosition = Vector2.new(0, math.max(0, InnerY - 12 * Library.DPIScale))
                            ScrolledInner = true
                        end
                        Inner = Inner.Parent
                    end
                    if ScrolledInner then
                        RunService.RenderStepped:Wait()
                    end

                    local Scroller = Target.Parent
                    while Scroller and not (Scroller:IsA("ScrollingFrame") and Scroller.Name == "CloudyColumn") do
                        Scroller = Scroller.Parent
                    end

                    if Scroller then
                        local Y = Target.AbsolutePosition.Y - Scroller.AbsolutePosition.Y + Scroller.CanvasPosition.Y
                        Scroller.CanvasPosition = Vector2.new(0, math.max(0, Y - 24 * Library.DPIScale))
                    end

                    local Flash = New("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = "AccentColor",
                        Thickness = 2,
                        Parent = Target,
                    })
                    TweenService:Create(Flash, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Transparency = 1,
                    }):Play()
                    task.delay(1.3, function()
                        Flash:Destroy()
                    end)
                end)
            end

            local function Collect(Query)
                local Search = NormalizeSearch(Query:lower())
                local Found = {}
                if Trim(Search) == "" and not ModifiedOnly then
                    return Found
                end

                local function Score(Text, Description, Tooltip)
                    if Search == "" then
                        return 0
                    end

                    local Value = FuzzyMatchScore(Text, Search)
                    if Value > 0 then
                        return Value
                    end
                    if TryFuzzyMatch(Description, Search) or TryFuzzyMatch(Tooltip, Search) then
                        return 1
                    end

                    return 0
                end

                local function Push(Value, Segments, Name, Type, Go)
                    if ModifiedOnly and (Type == "Tab" or Type == "Page" or Type == "Groupbox") then
                        return
                    end

                    table.insert(Found, { Score = Value, Segments = Segments, Name = Name, Type = Type, Go = Go })
                end

                local function ScanElements(Elements, Boxes, Segments, Context)
                    for _, Element in Elements do
                        if Element.Type == "Divider" or Element.Destroyed or typeof(Element.Text) ~= "string" then
                            continue
                        end

                        local Value = Score(Element.Text, Element.Description, Element.Tooltip)
                        if ModifiedOnly then
                            if not Library:IsModified(Element) then
                                Value = 0
                            elseif Value == 0 and Search == "" then
                                Value = 1
                            end
                        end
                        if Value > 0 then
                            Push(Value, Segments, Element.Text, Element.Type or "Element", function()
                                Reveal(Context, Element.Holder)
                            end)
                        end

                        local Sub = Element.SubButton
                        if Sub and typeof(Sub.Text) == "string" then
                            local SubValue = Score(Sub.Text, nil, Sub.Tooltip)
                            if SubValue > 0 then
                                Push(SubValue, Segments, Sub.Text, "Button", function()
                                    Reveal(Context, Element.Holder)
                                end)
                            end
                        end
                    end

                    for _, Box in Boxes or {} do
                        if Box.Visible ~= false and not Box.Destroyed then
                            ScanElements(Box.Elements, Box.DependencyBoxes, Segments, Context)
                        end
                    end
                end

                for _, Tab in Library.Tabs do
                    if typeof(Tab) ~= "table" or Tab.IsKeyTab or Tab.Destroyed then
                        continue
                    end

                    local TabName = tostring(Tab.Name)
                    local Value = Score(Tab.Name, Tab.Description, Tab.Tooltip)
                    if Value > 0 then
                        Push(Value, {}, TabName, "Tab", function()
                            Reveal({ Tab = Tab })
                        end)
                    end

                    for _, Page in Tab.Pages or {} do
                        Value = Score(Page.Name)
                        if Value > 0 then
                            Push(Value, { TabName }, Page.Name, "Page", function()
                                Reveal({ Tab = Tab, Page = Page })
                            end)
                        end
                    end

                    for _, Groupbox in Tab.Groupboxes do
                        if Groupbox.Destroyed or Groupbox.Visible == false then
                            continue
                        end

                        local Segments = { TabName }
                        if Groupbox.Page then
                            table.insert(Segments, Groupbox.Page.Name)
                        end

                        local Chain = {}
                        local Parent = Groupbox.ParentBox
                        while Parent do
                            if Parent.Name then
                                table.insert(Chain, 1, tostring(Parent.Name))
                            end
                            Parent = Parent.ParentBox
                        end
                        for _, Name in Chain do
                            table.insert(Segments, Name)
                        end

                        local Context = { Tab = Tab, Page = Groupbox.Page, Groupbox = Groupbox }

                        Value = Score(Groupbox.Name, Groupbox.Description)
                        if Value > 0 then
                            Push(Value, Segments, Groupbox.Name, "Groupbox", function()
                                Reveal(Context, Groupbox.Holder)
                            end)
                        end

                        local Inner = table.clone(Segments)
                        table.insert(Inner, tostring(Groupbox.Name))
                        ScanElements(Groupbox.Elements, Groupbox.DependencyBoxes, Inner, Context)
                    end

                    for _, Tabbox in Tab.Tabboxes do
                        if Tabbox.Destroyed then
                            continue
                        end

                        local Segments = { TabName }
                        if Tabbox.Page then
                            table.insert(Segments, Tabbox.Page.Name)
                        end

                        for SubName, SubTab in Tabbox.Tabs do
                            local Inner = table.clone(Segments)
                            table.insert(Inner, tostring(SubName))
                            ScanElements(SubTab.Elements, SubTab.DependencyBoxes, Inner, {
                                Tab = Tab,
                                Page = Tabbox.Page,
                                SubTab = SubTab,
                            })
                        end
                    end
                end

                table.sort(Found, function(A, B)
                    if A.Score ~= B.Score then
                        return A.Score > B.Score
                    end

                    return tostring(A.Name) < tostring(B.Name)
                end)

                for Index = #Found, 41, -1 do
                    Found[Index] = nil
                end

                return Found
            end

            local RowButtons = {}
            local function Refresh()
                for _, Row in RowButtons do
                    Row:Destroy()
                end
                table.clear(RowButtons)

                local Query = SearchInput.Text
                local Found = Collect(Query)

                EmptyLabel.Visible = #Found == 0
                EmptyLabel.Text = (Trim(Query) == "" and not ModifiedOnly) and "Type to search" or (ModifiedOnly and "Nothing modified" or "No results")

                for Index, Result in Found do
                    local Path = table.concat(Result.Segments, " > ")
                    local Text
                    if Path ~= "" then
                        Text = string.format(
                            '<font transparency="0.55">%s &gt;</font> %s <font transparency="0.55">: %s</font>',
                            Escape(Path),
                            Escape(Result.Name),
                            Escape(Result.Type)
                        )
                    else
                        Text = string.format('%s <font transparency="0.55">: %s</font>', Escape(Result.Name), Escape(Result.Type))
                    end

                    local Row = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        BackgroundTransparency = 0.35,
                        LayoutOrder = Index,
                        Size = UDim2.new(1, 0, 0, 34),
                        Text = Text,
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ResultsFrame,
                    })
                    table.insert(
                        Library.Corners,
                        New("UICorner", {
                            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                            Parent = Row,
                        })
                    )
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                        Parent = Row,
                    })

                    Row.MouseEnter:Connect(function()
                        TweenService:Create(Row, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                    end)
                    Row.MouseLeave:Connect(function()
                        TweenService:Create(Row, Library.TweenInfo, { BackgroundTransparency = 0.35 }):Play()
                    end)
                    Row.MouseButton1Click:Connect(function()
                        SearchPanel:Close()
                        Library:SafeCallback(Result.Go)
                    end)

                    table.insert(RowButtons, Row)
                end

                local ListHeight = #Found == 0 and 28 or (math.min(#Found, 8) * 38 - 4)
                ResultsFrame.Size = UDim2.new(1, -20, 0, ListHeight)
                Panel.Size = UDim2.fromOffset(420, 56 + ListHeight + 12)
            end

            SearchInput:GetPropertyChangedSignal("Text"):Connect(Refresh)

            --// "Modified" pill: only list settings that differ from their defaults \--
            local ModifiedButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "BackgroundColor",
                Position = UDim2.new(1, -7, 0.5, 0),
                Size = UDim2.fromOffset(76, 26),
                Text = "Modified",
                TextSize = 12,
                TextTransparency = 0.35,
                Parent = InputHolder,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ModifiedButton })
            ModifiedButton.MouseButton1Click:Connect(function()
                ModifiedOnly = not ModifiedOnly
                ModifiedButton.BackgroundColor3 = ModifiedOnly and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor
                ModifiedButton.TextTransparency = ModifiedOnly and 0 or 0.35
                Refresh()
            end)

            function SearchPanel:Open()
                SearchPanel.Active = true
                Panel.Visible = true
                Refresh()
                task.defer(function()
                    if SearchPanel.Active then
                        SearchInput:CaptureFocus()
                    end
                end)
            end

            function SearchPanel:Close()
                SearchPanel.Active = false
                Panel.Visible = false
                if SearchInput:IsFocused() then
                    SearchInput:ReleaseFocus()
                end
            end

            function SearchPanel:Toggle()
                if SearchPanel.Active then
                    SearchPanel:Close()
                else
                    SearchPanel:Open()
                end
            end

            Library:GiveSignal(UserInputService.InputBegan:Connect(function(InputObj: InputObject)
                if not SearchPanel.Active or not IsClickInput(InputObj) then
                    return
                end

                local Point = Vector2.new(Mouse.X, Mouse.Y)
                if Library:MouseIsOverFrame(Panel, Point) or Library:MouseIsOverFrame(SearchButton, Point) then
                    return
                end

                SearchPanel:Close()
            end))
        end

        --// Bottom Bar \\--
        local BottomClip = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 3,
            Parent = MainFrame,
        })

        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, math.max(20, WindowInfo.CornerRadius * 2)),
            ZIndex = 3,
            Parent = BottomClip,
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 3,
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 4,
            Parent = MainFrame,
        })
        BottomBackgroundCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
            BottomRightRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = BottomBackground,
        })

        --// Footer \\-
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = BottomBar,
        })

        --// sidebar collapse button (footer, left) \--
        local CollapseIcon = Library:GetIcon("panel-left")
        local CollapseButton = New("ImageButton", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            Parent = BottomBar,
        })
        if CollapseIcon then
            Library:ApplyLucideIcon(CollapseButton, CollapseIcon)
        end
        CollapseButton.MouseEnter:Connect(function()
            TweenService:Create(CollapseButton, Library.TweenInfo, { ImageTransparency = 0 }):Play()
        end)
        CollapseButton.MouseLeave:Connect(function()
            TweenService:Create(CollapseButton, Library.TweenInfo, { ImageTransparency = 0.5 }):Play()
        end)
        CollapseButton.MouseButton1Click:Connect(function()
            if Library.Window then
                Library.Window:SetCompact(not Library.Window:IsSidebarCompacted())
            end
        end)

        --// Resize Button \\--
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)
        end

        if ResizeButton then
            local WindowResizeIcon = New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                ImageColor3 = "FontColor", ImageTransparency = 0.35,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(16, 16), Parent = ResizeButton,
            })
            if ResizeIcon then Library:ApplyLucideIcon(WindowResizeIcon, ResizeIcon) end
        end

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, TabButtonsStyle.Gap),
            Parent = Tabs,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, TabButtonsStyle.Padding),
            PaddingLeft = UDim.new(0, TabButtonsStyle.Padding),
            PaddingRight = UDim.new(0, TabButtonsStyle.Padding),
            PaddingTop = UDim.new(0, TabButtonsStyle.Padding),
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })

        Library.WindowContainer = Container
        Library.SidebarFrame = Tabs
    end

    --// Window Table \\--
    local Window = {}
    local Fading = false

    local function SetUICorner(UICorner, Corner, HalfValue)
        local Current = UICorner[Corner]
        if Current.Offset == 0 and Current.Scale == 0 then
            return
        end

        UICorner[Corner] = HalfValue
    end

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitleLabel.Text = title
        WindowInfo.Title = title
    end

    function Window:SetSubtitle(subtitle)
        assert(typeof(subtitle) == "string", "Expected string for subtitle got: " .. typeof(subtitle))

        WindowSubtitleLabel.Text = subtitle
        WindowSubtitleLabel.Visible = subtitle ~= ""
        WindowInfo.Subtitle = subtitle
    end

    function Window:SetBackgroundImage(Image: string)
        local ValidIcon = false

        if typeof(Image) == "string" then
            local BackgroundIcon = Library:GetCustomIcon(Image)

            if BackgroundIcon then
                ValidIcon = true

                Library:ApplyLucideIcon(BackgroundImage, BackgroundIcon)
            elseif Image:match("http://") or Image:match("https://") then
                local RawFileName = Image:match("(.+)%..+$")
                local _, Domain = Image:match("^(https?://)([^/]+)");

                if RawFileName and Domain then
                    local Extention = string.sub(Image, #RawFileName + 1, #Image)
                    local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                    local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                    if FileName then
                        ValidIcon = true

                        local AssetName = Domain .. FileName
                        if #AssetName > 255 then
                            local NewLength = 255 - #Domain - #Extention
                            if NewLength < 0 then
                                AssetName = Domain .. Extention
                            else
                                AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                            end
                        end

                        if CustomImageManagerAssets[FileName] == nil then
                            CustomImageManager.AddAsset(FileName, 0, Image)
                        else
                            CustomImageManager.DownloadAsset(FileName, true)
                        end

                        BackgroundImage.Image = CustomImageManager.GetAsset(FileName)
                        BackgroundImage.ImageRectOffset = Vector2.zero
                        BackgroundImage.ImageRectSize = Vector2.zero
                    end
                end
            end
        end

        if not ValidIcon then
            BackgroundImage.Image = ""
            BackgroundImage.ImageRectOffset = Vector2.zero
            BackgroundImage.ImageRectSize = Vector2.zero
        end

        HasBackgroundImage = ValidIcon
        WindowInfo.BackgroundImage = Image
    end

    function Window:SetFooter(Footer: string)
        assert(typeof(Footer) == "string", "Expected string for footer got: " .. typeof(Footer))

        FooterLabel.Text = Footer
        WindowInfo.Footer = Footer
    end

    function Window:SetAlwaysOnTop(Enabled: boolean)
        WindowInfo.AlwaysOnTop = Enabled == true
        SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
    end

    function Window:SetSnapping(Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean?)
        WindowInfo.Snapping = Enabled == true
        WindowSnapConfig.Enabled = WindowInfo.Snapping

        if Distance then
            WindowInfo.SnapDistance = math.max(0, Distance)
            WindowSnapConfig.Distance = WindowInfo.SnapDistance
        end

        if Margin then
            WindowInfo.SnapMargin = math.max(0, Margin)
            WindowSnapConfig.Margin = WindowInfo.SnapMargin
        end

        if AvoidCoreGui ~= nil then
            WindowInfo.SnapAvoidCoreGui = AvoidCoreGui == true
            WindowSnapConfig.AvoidCoreGui = WindowInfo.SnapAvoidCoreGui
        end
    end

    function Window:SetCornerRadius(Radius: number)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        Radius = math.min(Radius, 36)

        local RadiusHalf = UDim.new(0, Radius / 2)
        local RadiusUDim = UDim.new(0, Radius)
        local HalfCurrent = Library.CornerRadius / 2

        for _, UICorner in Library.Corners do
            if math.abs(UICorner.CornerRadius.Offset - HalfCurrent) < 0.001 then
                UICorner.CornerRadius = RadiusHalf
            else
                UICorner.CornerRadius = RadiusUDim
            end
        end

        for _, UICorner in Library.SpecificCorners do
            SetUICorner(UICorner, "TopRightRadius", RadiusHalf)
            SetUICorner(UICorner, "TopLeftRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomRightRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomLeftRadius", RadiusHalf)
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        if ResizeButton then
            ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0)
        end
        if BottomBackgroundCorner then
            BottomBackground.Size = UDim2.new(1, 0, 0, math.max(20, Radius * 2))
            BottomBackgroundCorner.BottomLeftRadius = RadiusUDim
            BottomBackgroundCorner.BottomRightRadius = RadiusUDim
        end

        for _, Menu in Library.ContextMenus do
            if Menu.Destroyed then
                continue
            end

            if typeof(Menu.ActiveCallback) ~= "function" then
                continue
            end

            if not Menu.Active then
                local HolderActive = false
                for _, Other in Library.ContextMenus do
                    if Other == Menu then 
                        continue
                    end
   
                    if Other.Active and Other.Holder == Menu.Holder then
                        HolderActive = true
                        break
                    end
                end

                if HolderActive then
                    continue
                end

                Menu.ActiveCallback(false)
                continue
            end

            Menu.ActiveCallback(true)
        end

        for _, Option in Options do
            if Option.Type == "Dropdown" and Option.RefreshPool then
                Option:RefreshPool()
            end
        end

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
        if typeof(Animations) == "table" then
            WindowInfo.Animations = Animations
            Library.Animations = Animations
        end

        if typeof(TabTransitionTime) == "number" then
            local TweenInfo = TweenInfo.new(
                math.max(0, TabTransitionTime or 0.22),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            WindowInfo.TabTransitionInfo = TweenInfo
            Library.TabTransitionInfo = TweenInfo
        end

        if typeof(TabSwipeOffset) == "number" then
            TabSwipeOffset = math.max(1, TabSwipeOffset)

            WindowInfo.TabSwipeOffset = TabSwipeOffset
            Library.TabSwipeOffset = TabSwipeOffset
        end

        if typeof(TabSwipeFrom) == "string" then
            TabSwipeFrom = string.lower(TabSwipeFrom)

            WindowInfo.TabSwipeFrom = TabSwipeFrom
            Library.TabSwipeFrom = TabSwipeFrom
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        for _, Group in Library.SidebarGroups do
            Group.Header.Visible = not IsCompact
            Group:Refresh()
        end
        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            if not Button.Icon then
                continue
            end

            Button.Label.Visible = not IsCompact
            Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
            Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
            Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY
        end
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        Width = math.clamp(Width, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, Width, 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - 193 - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end

    function Window:HideTabInfo()
        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight
        local TabFull

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 44),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            --// Selected look: soft accent tinted pill + thin accent stroke + indicator bar \\--
            Library.Registry[TabButton].BackgroundColor3 = function()
                return Library.Scheme.MainColor:Lerp(Color3.fromRGB(118, 119, 132), 0.26)
            end
            TabButton.BackgroundColor3 = Library.Registry[TabButton].BackgroundColor3()
            New("UIStroke", {
                Color = function()
                    return Library.Scheme.OutlineColor:Lerp(Color3.fromRGB(139, 140, 154), 0.24)
                end,
                Transparency = 1,
                Parent = TabButton,
            })

            ShellSurface(TabButton, TabButtonsStyle.CornerRadius)
            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "FontColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(5, 5),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })
            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "FontColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            TabLeft = New("ScrollingFrame", {
                Name = "CloudyColumn",
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -6, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                Name = "CloudyColumn",
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -6, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end

            --// Full width column (single groupbox pages) \\--
            TabFull = New("ScrollingFrame", {
                Name = "CloudyColumn",
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = TabFull,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabFull,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabFull,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabFull,
                })
            end
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Button = TabButton,
            Container = TabContainer,
            Sides = { TabLeft, TabRight, TabFull },
            Columns = { Left = TabLeft, Right = TabRight, Full = TabFull },
            Pages = {},
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }

        --// Glow behind the active tab button \\--
        Tab.Glow = nil -- sidebar glow was clipped by the sidebar scroll frame, selected tab uses a tinted pill instead

        --// Empty tab card (icon + title + description) \\--
        do
            local EmptyCard = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.25,
                Position = UDim2.fromOffset(2, 4),
                Size = UDim2.new(1, -4, 0, 0),
                Parent = TabContainer,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = EmptyCard,
                })
            )
            Library:AddOutline(EmptyCard, 10, 3, 0.7)

            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 10),
                Parent = EmptyCard,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 28),
                PaddingLeft = UDim.new(0, 24),
                PaddingRight = UDim.new(0, 24),
                PaddingTop = UDim.new(0, 28),
                Parent = EmptyCard,
            })

            if Icon then
                local EmptyIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    LayoutOrder = 1,
                    Size = UDim2.fromOffset(44, 44),
                    Parent = EmptyCard,
                })
                Library:ApplyLucideIcon(EmptyIcon, Icon)
            end

            New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0),
                Text = tostring(Name),
                TextSize = 22,
                TextWrapped = true,
                Parent = EmptyCard,
            })

            local EmptyDescription = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = 3,
                Size = UDim2.new(0.8, 0, 0, 0),
                Text = (typeof(Description) == "string" and Description ~= "") and Description or "Nothing here yet.",
                TextSize = 15,
                TextTransparency = 0.45,
                TextWrapped = true,
                Parent = EmptyCard,
            })
            Tab.EmptyCard = EmptyCard
            Tab.EmptyDescription = EmptyDescription

            function Tab:UpdateEmptyState()
                local Empty = next(Tab.Groupboxes) == nil and next(Tab.Tabboxes) == nil and #Tab.Pages == 0
                EmptyCard.Visible = Empty
            end
        end

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            Library:AddToRegistry(WarningBox, {
                BackgroundColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                end
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)
            Library:AddToRegistry(WarningBoxOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                end
            })
            Library:AddToRegistry(WarningBoxShadowOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                end
            })

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })
            Library:AddToRegistry(WarningTitle, {
                TextColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                end
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
            Library:AddToRegistry(WarningStroke, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                end
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Handlers \\--
        function Tab:UpdateWarningBox(Info)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Library.Registry[WarningBox].BackgroundColor3()
            WarningBoxShadowOutline.Color = Library.Registry[WarningBoxShadowOutline].Color()
            WarningBoxOutline.Color = Library.Registry[WarningBoxOutline].Color()
            WarningTitle.TextColor3 = Library.Registry[WarningTitle].TextColor3()
            WarningStroke.Color = Library.Registry[WarningStroke].Color()
        end

        function Tab:RefreshSides()
            local Offset = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0
            local PagesOffset = (#Tab.Pages > 0) and (Offset + 44) or Offset

            for _, Side in Tab.Sides do
                if Side:GetAttribute("PageSide") then
                    continue
                end

                if Side == TabFull then
                    Side.Position = UDim2.fromOffset(0, PagesOffset)
                    Side.Size = UDim2.new(1, 0, 1, -PagesOffset)
                else
                    Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, PagesOffset)
                    Side.Size = UDim2.new(0.5, -3, 1, -PagesOffset)
                end
            end

            if Tab.PageBar then
                Tab.PageBar.Position = UDim2.fromOffset(0, Offset + 4)
            end
            if Tab.EmptyCard then
                Tab.EmptyCard.Position = UDim2.fromOffset(2, Offset + 4)
            end
            for _, Page in Tab.Pages do
                Page.Frame.Position = UDim2.fromOffset(0, PagesOffset)
                Page.Frame.Size = UDim2.new(1, 0, 1, -PagesOffset)
            end
        end

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor((TabContainer.AbsoluteSize.Y / Library.DPIScale) / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X / Library.DPIScale
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        --// Column helpers (single side / nested columns) \\--
        local function SideFrame(Columns, Side)
            if Side == 3 or Columns.UsesFull then
                Columns.UsesFull = true
                Columns.Left.Visible = false
                Columns.Right.Visible = false
                Columns.Full.Visible = true

                return Columns.Full
            end

            return Side == 2 and Columns.Right or Columns.Left
        end

        local function GetNestedColumn(Owner, Side)
            if not Owner.NestedColumns then
                local Holder = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = Owner.Container,
                })

                local function Column(Scale, Offset)
                    local Frame = New("Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(Scale, Offset, 0, 0),
                        Size = UDim2.new(0.5, -4, 0, 0),
                        Parent = Holder,
                    })
                    New("UIListLayout", {
                        Padding = UDim.new(0, 2),
                        Parent = Frame,
                    })

                    return Frame
                end

                Owner.NestedColumns = { Column(0, 0), Column(0.5, 4) }
            end

            return Owner.NestedColumns[Side == 2 and 2 or 1]
        end

        local function ResolveParent(Owner, Info, IsNested, RawSide)
            if IsNested then
                if RawSide ~= nil and (Info.Side == 1 or Info.Side == 2) then
                    return GetNestedColumn(Owner, Info.Side)
                end

                return Owner.Container
            end

            return SideFrame(Owner.Columns or Tab.Columns, Info.Side)
        end

        local function AddTabbox(self, Info)
            local RawSide = typeof(Info) == "table" and Info.Side or nil
            Info = Library:Validate(Info, Templates.Tabbox)
            local ParentObj = self
            local IsNested = ParentObj.Type == "Groupbox" or ParentObj.Type == "SubTab" or ParentObj.IsDepbox == true

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = ResolveParent(ParentObj, Info, IsNested, RawSide),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder, 8, 2, 0.7)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalTabs = 0
            local FirstTab
            local LastTab

            local Tabbox: any = {
                Type = "Tabbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                ActiveTab = nil,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {},

                ParentBox = if IsNested then ParentObj else nil,
            }

            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:Resize()
                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
            end

            function Tabbox:AddTab(Name, IconName)
                TotalTabs = TotalTabs + 1
                local TabIndex = TotalTabs

                LastTab = TabIndex
                if not FirstTab then
                    FirstTab = TabIndex
                end

                local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonCorner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                    TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                    BottomRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, 0),
                    Parent = Button,
                }); table.insert(Library.SpecificCorners, ButtonCorner)

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                local BoxIcon = Library:GetCustomIcon(IconName)
                if BoxIcon then
                    ButtonIcon = New("ImageLabel", {
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageTransparency = 0.5,
                        Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                        Parent = ButtonContent,
                    })
                    Library:ApplyLucideIcon(ButtonIcon, BoxIcon)
                end

                local ButtonLabel
                if not IsNameEmpty then
                    ButtonLabel = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 16),
                        Text = Name,
                        TextSize = 15,
                        TextTransparency = 0.5,
                        Parent = ButtonContent,
                    })
                end

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    ScrollBarThickness = 0,
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local Tab = {
                    Type = "SubTab",
                    Name = Name,

                    Connections = {},
                    Destroyed = false,

                    ButtonHolder = Button,
                    Container = Container,
                    ButtonCorner = ButtonCorner,

                    Tab = Tab,
                    Tabbox = Tabbox,

                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0
                    end

                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                    Tabbox:RefreshPopOutPlaceholder()
                end

                function Tab:Hide()
                    Button.BackgroundTransparency = 0

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0.5
                    end
                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0.5
                    end
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    local ContentSize = (List.AbsoluteContentSize.Y / Library.DPIScale) + 14
                    if Tabbox.PoppedOut then
                        ContentSize = math.min(ContentSize, GetPopOutBodyMaxHeight(Tabbox, 35))
                    end

                    TabboxHolder.Size = UDim2.new(1, 0, 0, ContentSize + 35)
                    if IsNested then
                        ParentObj:Resize()
                    end
                end

                function Tab:UpdateCorners()
                    local Radius = WindowInfo.CornerRadius

                    ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                    ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                end

                function Tab:Destroy()
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Element in Tab.Elements do
                        if Element.Destroy then
                            Element:Destroy()
                        end
                    end

                    for _, SubDepbox in Tab.DependencyBoxes do
                        if SubDepbox.Destroy then
                            SubDepbox:Destroy()
                        end
                    end

                    if Container then
                        Container:Destroy()
                    end

                    if Button then
                        Button:Destroy()
                    end
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                Tab.AddTabbox = AddTabbox
                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[TabStoringIndex] = Tab
                Tabbox:UpdateCorners()

                return Tab, TabStoringIndex
            end

            Library:MakeBoxPopOut(Tabbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = TabboxButtons,
                Children = function()
                    return { TabboxHolder }
                end,

                After = function()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Resize()
                    end
                    if IsNested then
                        ParentObj:Resize()
                    end
                end,
            })

            function Tabbox:Destroy()
                if Tabbox.PoppedOut then
                    Tabbox:SetPoppedOut(false)
                end

                Tabbox.Destroyed = true

                if Tabbox.Connections then
                    for _, Connection in Tabbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Tab in Tabbox.Tabs do
                    if Tab.Destroy then
                        Tab:Destroy()
                    end
                end

                if TabboxHolder then
                    TabboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            Tabbox.Page = ParentObj.Type == "Page" and ParentObj or ParentObj.Page
            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end
            Tab:UpdateEmptyState()

            return Tabbox
        end

        Tab.AddTabbox = AddTabbox

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        local function BuildGroupbox(Owner, Info)
            local RawInfo = typeof(Info) == "table" and Info or {}
            local RawSide = RawInfo.Side
            local RawPopOut = RawInfo.PopOut
            local IsNested = Owner.Type == "Groupbox" or Owner.Type == "SubTab" or Owner.IsDepbox == true

            Info = Library:Validate(Info, Templates.Groupbox)

            --// Collapsing is opt-in: Collapsible = true (or Collapsed = true/false). Otherwise only the title is shown. \\--
            local CanCollapse = (
                RawInfo.Collapsible == true
                or RawInfo.Collapse == true
                or RawInfo.Collapsed ~= nil
                or RawInfo.DisableCollapsing == false
            ) and RawInfo.DisableCollapsing ~= true
            Info.DisableCollapsing = not CanCollapse

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = ResolveParent(Owner, Info, IsNested, RawSide),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder

            local GroupboxTop
            local GroupboxLabel
            local GroupboxDescription

            local GroupboxContainer
            local GroupboxList

            local GroupboxCollapseArrow
            local GroupboxLine

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = function()
                        return Library.Scheme.MainColor:Lerp(Color3.fromRGB(37, 38, 46), 0.35)
                    end,
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, math.min(WindowInfo.CornerRadius, 16)),
                        Parent = GroupboxHolder,
                    })
                )
                New("UIListLayout", {
                    Parent = GroupboxHolder,
                })
                Library:AddOutline(GroupboxHolder, 16, 4, 0.82)
                ShellSurface(GroupboxHolder, math.min(WindowInfo.CornerRadius, 16))

                GroupboxTop = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxTop,
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    local GroupboxHeaderIcon = New("ImageLabel", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxTop,
                    })
                    Library:ApplyLucideIcon(GroupboxHeaderIcon, BoxIcon)
                end

                local RightInset = if Info.DisableCollapsing ~= true then 22 else 0
                local TextsFrame = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 24 or 0, 0),
                    Size = UDim2.new(1, -RightInset - (BoxIcon and 24 or 0), 0, 0),
                    Parent = GroupboxTop,
                })
                New("UIListLayout", {
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 3),
                    Parent = TextsFrame,
                })

                GroupboxLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Name,
                    TextSize = 14,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 1),
                    Parent = GroupboxLabel,
                })

                GroupboxDescription = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description or "",
                    TextSize = 12,
                    TextTransparency = 0.55,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = (Info.Description ~= nil),
                    Parent = TextsFrame,
                })

                GroupboxCollapseArrow = New("ImageButton", {
                    Visible = Info.DisableCollapsing ~= true,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    ImageColor3 = "WhiteColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromOffset(22, 22),
                    Parent = GroupboxTop,
                })
                if ArrowIcon then
                    Library:ApplyLucideIcon(GroupboxCollapseArrow, ArrowIcon, 180)
                end

                if not IsNested then
                    BoxHolder:SetAttribute("CRBox", true)

                    local EditBar = New("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, Info.DisableCollapsing ~= true and -26 or 0, 0.5, 0),
                        Size = UDim2.fromOffset(70, 22),
                        Visible = Library.LayoutEdit,
                        Parent = GroupboxTop,
                    })
                    New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = UDim.new(0, 2),
                        Parent = EditBar,
                    })
                    Library.EditBars[EditBar] = true

                    for _, Entry in { { "arrow-up", "up" }, { "arrow-down", "down" }, { "arrow-left-right", "side" } } do
                        local Button = New("ImageButton", {
                            BackgroundTransparency = 1,
                            ImageColor3 = "AccentColor",
                            Size = UDim2.fromOffset(22, 22),
                            Parent = EditBar,
                        })
                        local Icon = Library:GetIcon(Entry[1])
                        if Icon then
                            Library:ApplyLucideIcon(Button, Icon)
                        end
                        Button.MouseButton1Click:Connect(function()
                            Library:MoveGroupbox(BoxHolder, Entry[2], Owner.Columns or Tab.Columns)
                        end)
                    end
                end

                GroupboxLine = Library:MakeLine(GroupboxHolder, {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 1),
                })
                GroupboxLine.BackgroundTransparency = 1

                GroupboxContainer = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromScale(0, 0),
                    LayoutOrder = 2,
                    ScrollBarThickness = 0,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 12),
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox: any = {
                Type = "Groupbox",

                Name = Info.Name,
                Description = Info.Description,

                Connections = {},
                Destroyed = false,

                Visible = true,
                Collapsed = false,

                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,

                Tab = Tab,
                DependencyBoxes = {},
                Elements = {}
            }

            local ResizeTween
            local CollapseArrowTween

            function Groupbox:Resize()
                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                local TopSize = (GroupboxTop.AbsoluteSize.Y / Library.DPIScale)
                local ContainerSize = (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18
                if Groupbox.WarpHeight then
                    --// Warp: groupbox is at most WarpHeight tall (header included), body scrolls \\--
                    ContainerSize = math.min(ContainerSize, math.max(40, Groupbox.WarpHeight - TopSize - 1))
                end
                if Groupbox.PoppedOut then
                    ContainerSize = math.min(ContainerSize, GetPopOutBodyMaxHeight(Groupbox, TopSize + 1))
                end

                local TargetSize = UDim2.new(1, 0, 0, if Groupbox.Collapsed then TopSize else (TopSize + 1 + ContainerSize))
                GroupboxContainer.Size = UDim2.new(1, 0, 0, ContainerSize)
                GroupboxLine.Visible = not Groupbox.Collapsed

                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxHolder, TweenInfo, { Size = TargetSize })
                    ResizeTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if ResizeTween == Tween then
                            StopTween(ResizeTween, true)
                            ResizeTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxHolder.Size = TargetSize
                end
            end

            table.insert(Groupbox.Connections, GroupboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Groupbox.Visible == false or Groupbox.Destroyed then
                    return
                end

                Groupbox:Resize()
            end))

            function Groupbox:SetDescription(Description: string | nil)
                GroupboxDescription.Text = Description or ""
                GroupboxDescription.Visible = (Description ~= nil)

                Groupbox:Resize()
            end

            function Groupbox:SetCollapsed(Collapsed: boolean)
                if Info.DisableCollapsing == true then return end
                Groupbox.Collapsed = Collapsed

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                local TargetRotation = if Collapsed then 0 else 180

                GroupboxContainer.Visible = not Collapsed
                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxCollapseArrow, TweenInfo, { Rotation = TargetRotation })
                    CollapseArrowTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Connect(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if CollapseArrowTween == Tween then
                            StopTween(CollapseArrowTween, true)
                            CollapseArrowTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxCollapseArrow.Rotation = TargetRotation
                end

                Groupbox:Resize()
            end

            function Groupbox:ToggleCollapsed()
                if Info.DisableCollapsing == true then return end
                Groupbox:SetCollapsed(not Groupbox.Collapsed)
            end

            --// Warp: Groupbox:SetWarp(240) -> max height 240 and the body becomes a scroll frame, SetWarp(nil) -> normal \\--
            function Groupbox:SetWarp(Height: (number | boolean)?)
                if Height == true then
                    Height = 300
                end

                Groupbox.WarpHeight = typeof(Height) == "number" and math.max(80, Height) or nil

                local Registry = Library.Registry[GroupboxContainer] or {}
                Registry.ScrollBarImageColor3 = "AccentColor"
                Library.Registry[GroupboxContainer] = Registry

                GroupboxContainer.ScrollBarImageColor3 = Library.Scheme.AccentColor
                GroupboxContainer.ScrollBarImageTransparency = 0.4
                GroupboxContainer.ScrollBarThickness = Groupbox.WarpHeight and 3 or 0
                GroupboxContainer.ScrollingDirection = Enum.ScrollingDirection.Y

                if not Groupbox.WarpHeight then
                    GroupboxContainer.CanvasPosition = Vector2.zero
                end

                Groupbox:Resize()
            end

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = if IsNested then RawPopOut == true else Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = GroupboxTop,
                Children = function()
                    local Children = {}
                    for _, Child in BoxHolder:GetChildren() do
                        if Child:IsA("GuiObject") and Child ~= Groupbox.PopOutPlaceholder then
                            table.insert(Children, Child)
                        end
                    end
                    return Children
                end,

                Before = function()
                    GroupboxCollapseArrow.Visible = false
                end,
                After = function()
                    GroupboxCollapseArrow.Visible = Info.DisableCollapsing ~= true
                    Groupbox:Resize()
                end
            })

            function Groupbox:Destroy()
                if Groupbox.PoppedOut then
                    Groupbox:SetPoppedOut(false)
                end

                Groupbox.Destroyed = true

                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                if Groupbox.Connections then
                    for _, Connection in Groupbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Element in Groupbox.Elements do
                    if Element.Destroy then
                        Element:Destroy()
                    end
                end
                table.clear(Groupbox.Elements)

                for _, SubDepbox in Groupbox.DependencyBoxes do
                    if SubDepbox.Destroy then
                        SubDepbox:Destroy()
                    end
                end
                table.clear(Groupbox.DependencyBoxes)

                if GroupboxHolder then
                    GroupboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            function Groupbox:SetVisible(Visible: boolean)
                Groupbox.Visible = Visible
                BoxHolder.Visible = Visible
                SyncPopOutVisibility(Groupbox)

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                Groupbox:SetVisible(false)
            end

            if Info.DisableCollapsing ~= true then
                GroupboxCollapseArrow.MouseButton1Click:Connect(function()
                    Groupbox:ToggleCollapsed()
                end)
            end

            Groupbox.AddTabbox = AddTabbox
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()

            Groupbox.Owner = Owner

            local WarpValue = RawInfo.Warp
            if WarpValue == nil then
                WarpValue = RawInfo.Wrap
            end
            if WarpValue == true then
                WarpValue = RawInfo.WarpHeight or RawInfo.Height or 300
            end
            if WarpValue then
                Groupbox:SetWarp(WarpValue)
            end
            Groupbox.ParentBox = IsNested and Owner or nil
            Groupbox.Page = if Owner.Type == "Page" then Owner else Owner.Page

            local Key = Info.Name
            if Groupbox.Page then
                Groupbox.Page.Groupboxes[Info.Name] = Groupbox
                Key = Groupbox.Page.Name .. "/" .. Key
            end
            if IsNested then
                Owner.NestedGroupboxes = Owner.NestedGroupboxes or {}
                table.insert(Owner.NestedGroupboxes, Groupbox)
                Key = tostring(Owner.Name or "Nested") .. "/" .. Key
            end
            Tab.Groupboxes[Key] = Groupbox
            Tab:UpdateEmptyState()

            if Info.Visible == false then
                Groupbox:Hide()
            end

            if Info.DisableCollapsing ~= true and Info.Collapsed == true then
                Groupbox:SetCollapsed(true)
            end

            return Groupbox
        end

        Tab._BuildGroupbox = BuildGroupbox

        function Tab:AddGroupbox(Info)
            return BuildGroupbox(Tab.Pages[1] or Tab, Info)
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Pages: a tab can hold several pages, switched with the pill bar at the top \\--
        local PageBar
        function Tab:AddPage(...)
            local Name
            if select("#", ...) == 1 and typeof(...) == "table" then
                Name = (select(1, ...)).Name
            else
                Name = select(1, ...)
            end
            Name = tostring(Name or "Page")

            if not PageBar then
                PageBar = New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 4),
                    Size = UDim2.new(1, 0, 0, 36),
                    Parent = TabContainer,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 8),
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Parent = PageBar,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 2),
                    Parent = PageBar,
                })
                Tab.PageBar = PageBar

                --// Pages replace the tab's own columns \--
                TabLeft.Visible = false
                TabRight.Visible = false
                TabFull.Visible = false
            end

            local Frame = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = TabContainer,
            })

            local function MakeColumn(Properties)
                Properties.AutomaticCanvasSize = Enum.AutomaticSize.Y
                Properties.BackgroundTransparency = 1
                Properties.CanvasSize = UDim2.fromScale(0, 0)
                Properties.Name = "CloudyColumn"
                Properties.ScrollBarImageTransparency = 1
                Properties.ScrollBarThickness = 0
                Properties.Parent = Frame

                local Column = New("ScrollingFrame", Properties)
                New("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = Column,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingTop = UDim.new(0, 2),
                    Parent = Column,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = Column,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = Column,
                })

                Column:SetAttribute("PageSide", true)
                table.insert(Tab.Sides, Column)
                return Column
            end

            local Button = New("TextButton", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 32),
                Text = Name,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = PageBar,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Button,
            })
            Library.Registry[Button].BackgroundColor3 = function()
                return Library.Scheme.AccentColor:Lerp(Library.Scheme.MainColor, 0.86)
            end
            Button.BackgroundColor3 = Library.Registry[Button].BackgroundColor3()
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                Parent = Button,
            })

            local Page = {
                Type = "Page",
                Name = Name,
                Tab = Tab,
                Frame = Frame,
                Button = Button,
                Groupboxes = {},
                Tabboxes = {},
                Columns = {
                    Left = MakeColumn({ Size = UDim2.new(0.5, -3, 1, 0) }),
                    Right = MakeColumn({
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.fromScale(1, 0),
                        Size = UDim2.new(0.5, -3, 1, 0),
                    }),
                    Full = MakeColumn({ Size = UDim2.fromScale(1, 1), Visible = false }),
                },
            }

            function Page:Show()
                if Tab.ActivePage == Page then
                    return
                end

                if Tab.ActivePage then
                    Tab.ActivePage:Hide()
                end
                Tab.ActivePage = Page

                Frame.Visible = true
                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                    TextTransparency = 0,
                }):Play()
            end

            function Page:Hide()
                Frame.Visible = false
                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end

            function Page:AddGroupbox(Info)
                return BuildGroupbox(Page, Info)
            end

            function Page:AddLeftGroupbox(GroupName, IconName)
                return BuildGroupbox(Page, { Side = 1, Name = GroupName, IconName = IconName })
            end

            function Page:AddRightGroupbox(GroupName, IconName)
                return BuildGroupbox(Page, { Side = 2, Name = GroupName, IconName = IconName })
            end

            Page.AddTabbox = AddTabbox

            Button.MouseButton1Click:Connect(function()
                Page:Show()
            end)

            table.insert(Tab.Pages, Page)
            Tab:UpdateEmptyState()
            Tab:RefreshSides()

            if not Tab.ActivePage then
                Page:Show()
            end

            return Page
        end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            Library:SetTabButtonState(TabButton, true)
            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Library:PlayTabAnimation(Tab, true)
            Tab:RefreshSides()

            for _, Other in Library.Tabs do
                if typeof(Other) == "table" and Other.Glow then
                    TweenService:Create(Other.Glow, Library.TweenInfo, {
                        Transparency = 1,
                    }):Play()
                end
            end
            if Tab.Glow then
                TweenService:Create(Tab.Glow, Library.TweenInfo, {
                    Transparency = 0.6,
                }):Play()
            end

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            Library:SetTabButtonState(TabButton, false)

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            Tab.UserVisible = Visible
            if Tab.Group then
                Tab.Group:Refresh()
            else
                TabButton.Visible = Visible
            end

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            for _, Groupbox in Tab.Groupboxes do
                if Groupbox.Destroy then
                    Groupbox:Destroy()
                end
            end
            table.clear(Tab.Groupboxes)

            for _, Tabbox in Tab.Tabboxes do
                if Tabbox.Destroy then
                    Tabbox:Destroy()
                end
            end
            table.clear(Tab.Tabboxes)

            for _, DepGroupbox in Tab.DependencyGroupboxes do
                if DepGroupbox.Destroy then
                    DepGroupbox:Destroy()
                end
            end

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        TabButton.MouseButton2Click:Connect(function()
            Library:ShowTabMenu(Tab)
        end)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 44),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            --// Selected look: soft accent tinted pill + thin accent stroke + indicator bar \\--
            Library.Registry[TabButton].BackgroundColor3 = function()
                return Library.Scheme.AccentColor:Lerp(Library.Scheme.MainColor, 0.86)
            end
            TabButton.BackgroundColor3 = Library.Registry[TabButton].BackgroundColor3()
            New("UIStroke", {
                Color = function()
                    return Library.Scheme.AccentColor:Lerp(Library.Scheme.OutlineColor, 0.72)
                end,
                Transparency = 1,
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
                Library:ApplyLucideIcon(TabIcon, Icon)
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Description = Description,
            IsKeyTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Elements = {},

            Window = Window,
            Button = TabButton,
            Container = TabContainer
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            local BoxStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            Box.Focused:Connect(function()
                Library.Registry[BoxStroke].Color = "AccentColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end)

            Box.FocusLost:Connect(function()
                Library.Registry[BoxStroke].Color = "OutlineColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end)

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.4,
                }):Play()
            end)

            Button.InputBegan:Connect(function(Input)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:Destroy()
            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            Library:SetTabButtonState(TabButton, true)

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            Library:SetTabButtonState(TabButton, false)

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            Tab.UserVisible = Visible
            if Tab.Group then
                Tab.Group:Refresh()
            else
                TabButton.Visible = Visible
            end

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                local IconImg = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Info.TitleColor or "FontColor",
                    LayoutOrder = 1,
                    ZIndex = 2,
                    Parent = TitleRow,
                })
                Library:ApplyLucideIcon(IconImg, ParsedIcon)
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextColor3 = Info.TitleColor or "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = TitleRow,
        })

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Info.DescriptionColor or "FontColor",
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = HeaderContainer,
        })

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })

        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 2,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Destroyed = false,
            Elements = {},
            Container = DialogContainer,
            OutsideClickDismiss = Info.OutsideClickDismiss,
        }

        function Dialog:Resize()
            local MaxWidth = (MainFrame.AbsoluteSize.X / Library.DPIScale) * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            if Dialog.Destroyed then
                return
            end

            Dialog.Destroyed = true

            if Library.ActiveDialog == Dialog then
                Library.ActiveDialog = nil
            end

            for Index = #Dialog.Elements, 1, -1 do
                local Element = Dialog.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(Dialog.Elements)

            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()

            task.delay(Library.TweenInfo.Time, function()
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 2,
                Parent = ButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 2,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius),
                        Parent = ProgressBar
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()

                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()

        Library.ActiveDialog = Dialog
        return Dialog
    end

    local GuiProperties = { "BackgroundTransparency" }
    local ImageProperties = { "BackgroundTransparency", "ImageTransparency" }
    local TextProperties = { "BackgroundTransparency", "TextTransparency" }
    local StrokeProperties = { "Transparency" }

    local function FadeInstance(Desc, Properties)
        local Cache = TransparencyCache[Desc]
        if not Cache then
            Cache = {}
            TransparencyCache[Desc] = Cache
        end

        for _, Prop in Properties do
            if not Library.Toggled then
                Cache[Prop] = Desc[Prop]
            end

            if Cache[Prop] ~= nil and Cache[Prop] ~= 1 then
                TweenService:Create(Desc, Library.WindowAnimationInfo, {
                    [Prop] = Library.Toggled and Cache[Prop] or 1,
                }):Play()
            end
        end
    end

    function Window:Toggle(Value: boolean?)
        if Fading then
            return
        end

        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Animations and Library.Animations.ToggleWindow == true then
            local FadeTime = Library.WindowAnimationInfo.Time
            Fading = true

            if Library.Toggled then
                MainFrame.Visible = true
            end

            if Library.Toggled then
                FadeInstance(MainFrame, { "BackgroundTransparency" })
                task.wait(FadeTime / 2)
            else
                task.delay(FadeTime / 2, FadeInstance, MainFrame, { "BackgroundTransparency" })
            end

            for _, Instance in MainFrame:GetDescendants() do
                if Instance == TopBar then
                    continue
                end

                if Instance:IsA("GuiObject") then
                    local ClassName = Instance.ClassName
                    if ClassName == "ImageLabel" or ClassName == "ImageButton" then
                        FadeInstance(Instance, ImageProperties)
                    elseif ClassName == "TextLabel" or ClassName == "TextBox" or ClassName == "TextButton" then
                        FadeInstance(Instance, TextProperties)
                    else
                        FadeInstance(Instance, GuiProperties)
                    end
                elseif Instance.ClassName == "UIStroke" or Instance.ClassName == "UIShadow" then
                    FadeInstance(Instance, StrokeProperties)
                end
            end

            task.delay(FadeTime, function()
                MainFrame.Visible = Library.Toggled
                Fading = false
            end)
        else
            MainFrame.Visible = Library.Toggled
        end

        if Library.Toggled and Library.Orb then
            Library.Orb.Button.Visible = false
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if Library.Toggled and not Library.IsMobile then
            local ShowCursorBinding = Library.ShowCursorBinding
            Library.OriginalMouseIconEnabled = UserInputService.MouseIconEnabled

            pcall(function() RunService:UnbindFromRenderStep(ShowCursorBinding) end)
            RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                Cursor.Visible = Library.ShowCustomCursor

                if Library.Unloaded == true or not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    RestoreMouseIcon()
                end
            end)
        elseif not Library.Toggled then
            if Library.SearchPanel then
                Library.SearchPanel:Close()
            end

            RestoreMouseIcon()
            TooltipLabel.Visible = false

            for _, Option in Library.Options do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        end
    end

    function Library:Toggle(Value: boolean?)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end

    Window:SetAlwaysOnTop(WindowInfo.AlwaysOnTop)
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            Library:Toggle()
        end, true, true)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
            LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
        else
            ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

            LockButton.Button.AnchorPoint = Vector2.new(0, 0)
            LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
        end

        if WindowInfo.ShowMobileButtons == false then
            ToggleButton.Button.Visible = false
            LockButton.Button.Visible = false
        end
    end

    --// Execution \\--
    Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end))

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            if Library.SearchPanel and Library.SearchPanel.Active then
                Library.SearchPanel:Close()
                return
            end

            -- Releasing focus from a text input takes priority and never toggles the window --
            local FocusedBox = UserInputService:GetFocusedTextBox()
            if FocusedBox then
                FocusedBox:ReleaseFocus()
                return
            end

            -- Dismiss the topmost dialog before closing any open menu --
            if Library.ActiveDialog and Library.ActiveDialog.OutsideClickDismiss ~= false then
                Library.ActiveDialog:Dismiss()
                return
            end

            if CurrentMenu then
                CurrentMenu:Close()
                return
            end

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
    end))

    --// ------------------------------------------------------------ sidebar groups \\--
    function Window:AddTabGroup(Name: string, Info)
        Info = typeof(Info) == "table" and Info or {}

        for _, Existing in Library.SidebarGroups do
            if Existing.Name == Name then
                return Existing
            end
        end

        local Group = {
            Name = Name,
            Tabs = {},
            Collapsed = Info.Collapsed == true,
            Order = (#Tabs:GetChildren()) * 1000,
        }

        -- One real card owns BOTH the heading and its tab buttons.
        Group.Card = New("Frame", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.08,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = Group.Order,
            Parent = Tabs,
        })
        ShellSurface(Group.Card, 16)
        New("UIStroke", { Color = "OutlineColor", Transparency = 0.75, Parent = Group.Card })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
            Parent = Group.Card,
        })
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3), Parent = Group.Card })
        Group.Header = New("TextButton", {
            BackgroundTransparency = 1,
            LayoutOrder = -1,
            Size = UDim2.new(1, 0, 0, 32), Text = "",
            Visible = not IsCompact, Parent = Group.Card,
        })
        local GroupIcon = Library:GetCustomIcon(Info.Icon or "lucide:layers")
        if GroupIcon then
            local Image = New("ImageLabel", {
                BackgroundTransparency = 1, ImageColor3 = "FontColor",
                ImageTransparency = 0.25, Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, 8, 0.5, -8), Parent = Group.Header,
            })
            Library:ApplyLucideIcon(Image, GroupIcon)
        end
        local Chevron = New("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5), ImageColor3 = "FontColor",
            ImageTransparency = 0.5, Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(12, 12), Parent = Group.Header,
        })
        if ArrowIcon then Library:ApplyLucideIcon(Chevron, ArrowIcon) end
        New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(33, 0),
            Size = UDim2.new(1, -57, 1, 0), Text = Name, TextSize = 13,
            TextTransparency = 0.12, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Group.Header,
        })

        function Group:Refresh()
            if not Group.Card.Parent then return end
            Group.Header.Visible = not IsCompact
            Chevron.Rotation = Group.Collapsed and 90 or 180
            local VisibleCount = 0
            for Index = #Group.Tabs, 1, -1 do
                local Tab = Group.Tabs[Index]
                if Tab.Destroyed or not Tab.Button or not Tab.Button.Parent then
                    table.remove(Group.Tabs, Index)
                else
                    local Show = (not Group.Collapsed) or IsCompact or Library.ActiveTab == Tab
                    Tab.Button.Visible = Show and Tab.UserVisible ~= false
                    if Tab.Button.Visible then VisibleCount += 1 end
                end
            end
            Group.Card.Visible = not IsCompact or VisibleCount > 0
        end

        function Group:SetCollapsed(Collapsed: boolean)
            Group.Collapsed = Collapsed == true
            Group:Refresh()
        end

        function Group:Add(Tab)
            if Tab.Group == Group then
                return Tab
            end

            if Tab.Group then
                local Previous = Tab.Group
                local Index = table.find(Previous.Tabs, Tab)
                if Index then table.remove(Previous.Tabs, Index) end
                Previous:Refresh()
            end
            Tab.Group = Group
            table.insert(Group.Tabs, Tab)
            Tab.Button.Parent = Group.Card
            Tab.Button.LayoutOrder = #Group.Tabs
            Group:Refresh()
            return Tab
        end

        function Group:AddTab(TabInfo)
            return Group:Add(Window:AddTab(TabInfo))
        end

        Group.Header.MouseButton1Click:Connect(function()
            Group:SetCollapsed(not Group.Collapsed)
        end)

        table.insert(Library.SidebarGroups, Group)
        return Group
    end

    local BaseAddTab = Window.AddTab
    function Window:AddTab(...)
        local Tab = BaseAddTab(Window, ...)

        local First = ...
        if typeof(First) == "table" and First.Group ~= nil then
            local Group = First.Group
            if typeof(Group) == "string" then
                Group = Window:AddTabGroup(Group)
            end
            if typeof(Group) == "table" and Group.Add then
                Group:Add(Tab)
            end
        end

        return Tab
    end

    Library:AddTick(0.25, function()
        for _, Group in Library.SidebarGroups do
            Group:Refresh()
        end
    end)

    Window.MainFrame = MainFrame
    Library.Window = Window

    if Library.ApplyLibrarySettings then
        Library:ApplyLibrarySettings()
    end

    return Window
end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        AlwaysOnTop = LoadingInfo.AlwaysOnTop,

        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        task.defer(function()
            if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
                return
            end

            Library:RemoveFromRegistry(Instance)
        end)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))

    local MainScale = New("UIScale", {
        Scale = Library.IsMobile and 0.8 or 1,
        Parent = MainFrame
    })
    table.insert(Library.Scales, MainScale)
    Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)

    Library:AddOutline(SideBar)

    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        local Icon = Library:GetCustomIcon(LoadingInfo.Icon)
        local _WindowIcon = New("ImageLabel", {
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
        if Icon then
            Library:ApplyLucideIcon(_WindowIcon, Icon)
        end
    else
        local _WindowIcon = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local TitleX = Library:GetTextBounds(
        LoadingInfo.Title,
        Library.Scheme.Font,
        20,
        (TitleHolder.AbsoluteSize.X / Library.DPIScale) - (LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0) - 12
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, TitleX, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoaderIcon = Library:GetCustomIcon(LoadingInfo.LoadingIcon)
    local LoadingIcon = New("ImageLabel", {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })
    if LoaderIcon then
        Library:ApplyLucideIcon(LoadingIcon, LoaderIcon)
    end

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = "DarkColor",
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},

        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,

        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight

        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight =
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        Library:ApplyLucideIcon(LoadingIcon, IconData)
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        LoadingIcon.ImageColor3 = Color
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then
                button:Destroy()
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

--// ============================================================================================== \\--
--// Reactive logic, change tracking, modified dots, help panel, context actions
--// ============================================================================================== \\--
Library.ShowModifiedDots = true
Library.HelpPanelEnabled = false
Library.ChangeLog = {}
Library.OnChangeLog = nil

--// generic scheduler used by every background system (one loop, cheap) \\--
local Ticks = {}
function Library:AddTick(Interval: number, Func: () -> ())
    table.insert(Ticks, { Interval = Interval, Func = Func, Next = 0 })
end

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.1)

        local Now = os.clock()
        for _, Tick in Ticks do
            if Now >= Tick.Next then
                Tick.Next = Now + Tick.Interval
                pcall(Tick.Func)
            end
        end
    end
end)

--// stable stringify (sorted keys) so equal values always give equal text \\--
local function Stable(Value): string
    local Kind = typeof(Value)
    if Kind == "table" then
        local Keys = {}
        for Key in Value do
            table.insert(Keys, Key)
        end
        table.sort(Keys, function(A, B)
            return tostring(A) < tostring(B)
        end)

        local Parts = {}
        for _, Key in Keys do
            table.insert(Parts, tostring(Key) .. "=" .. Stable(Value[Key]))
        end
        return "{" .. table.concat(Parts, ",") .. "}"
    end

    return Kind .. ":" .. tostring(Value)
end
Library.Stable = Stable

--// ------------------------------------------------------------------ element <-> plain data \\--
function Library:SerializeElement(Element)
    local Type = Element.Type

    if Type == "Toggle" then
        return { Type = Type, Value = Element.Value }
    elseif Type == "Slider" or Type == "Input" then
        return { Type = Type, Value = Element.Value }
    elseif Type == "Dropdown" then
        if Element.SpecialType then
            return nil
        end
        return { Type = Type, Value = Element.Value }
    elseif Type == "RangeSlider" then
        return { Type = Type, Low = Element.Low, High = Element.High }
    elseif Type == "ReorderList" or Type == "TreeView" then
        return { Type = Type, Value = table.clone(Element.Value) }
    elseif Type == "ColorPicker" then
        return { Type = Type, Hex = Element.Value:ToHex(), Transparency = Element.Transparency }
    elseif Type == "KeyPicker" then
        return { Type = Type, Key = Element.Value, Mode = Element.Mode, Modifiers = table.clone(Element.Modifiers or {}) }
    end

    return nil
end

function Library:ApplySerialized(Element, Saved)
    if typeof(Saved) ~= "table" then
        return
    end

    local Type = Element.Type
    if Type == "Toggle" or Type == "Slider" or Type == "Input" or Type == "Dropdown" then
        pcall(Element.SetValue, Element, Saved.Value)
    elseif Type == "RangeSlider" then
        pcall(Element.SetValue, Element, Saved.Low, Saved.High)
    elseif Type == "ReorderList" or Type == "TreeView" then
        pcall(Element.SetValue, Element, Saved.Value)
    elseif Type == "ColorPicker" and typeof(Saved.Hex) == "string" then
        local Success, Color = pcall(Color3.fromHex, Saved.Hex)
        if Success then
            pcall(Element.SetValueRGB, Element, Color, Saved.Transparency)
        end
    elseif Type == "KeyPicker" then
        pcall(Element.SetValue, Element, { Saved.Key, Saved.Mode, Saved.Modifiers })
    end
end

--// ------------------------------------------------------------------ conditions (EnabledWhen / VisibleWhen) \\--
local function ResolveElement(Reference)
    if typeof(Reference) == "string" then
        return Library.Toggles[Reference] or Library.Options[Reference]
    end

    return Reference
end

local function ValueMatches(Element, Expected, Operator)
    local Value = Element.Value

    if Element.Type == "Dropdown" and typeof(Value) == "table" then
        local Has = Value[Expected] == true
        if Operator == "~=" then
            return not Has
        end
        return Has
    end

    if Expected == nil then
        return Value ~= nil and Value ~= false
    end

    if Operator == "~=" then
        return Value ~= Expected
    elseif Operator == ">" then
        return typeof(Value) == "number" and Value > Expected
    elseif Operator == "<" then
        return typeof(Value) == "number" and Value < Expected
    elseif Operator == ">=" then
        return typeof(Value) == "number" and Value >= Expected
    elseif Operator == "<=" then
        return typeof(Value) == "number" and Value <= Expected
    end

    return Value == Expected
end

--// Condition forms:
--//   true / false
--//   function() return bool end
--//   { Toggles.Aim, true }  /  { "OptionIdx", "Head" }  /  { Options.Speed, 50, ">=" }
--//   { cond1, cond2, ... }      -> all must be true
--//   { Any = { cond1, cond2 } } -> any can be true
local function Evaluate(Condition)
    local Kind = typeof(Condition)
    if Kind == "boolean" then
        return Condition
    elseif Kind == "function" then
        local Success, Result = pcall(Condition)
        return Success and Result ~= false and Result ~= nil
    elseif Kind ~= "table" then
        return true
    end

    if Condition.Any then
        for _, Sub in Condition.Any do
            if Evaluate(Sub) then
                return true
            end
        end
        return false
    end

    local Reference = ResolveElement(Condition[1])
    if typeof(Reference) == "table" and Reference.Type ~= nil then
        return ValueMatches(Reference, Condition[2], Condition[3])
    elseif typeof(Condition[1]) == "string" then
        return false -- element does not exist (yet)
    end

    for _, Sub in Condition do
        if not Evaluate(Sub) then
            return false
        end
    end
    return true
end
Library.Evaluate = Evaluate

local Rules = {}
local ComputedTexts = {}

local function ApplyRules()
    for Index = #Rules, 1, -1 do
        local Rule = Rules[Index]
        local Element = Rule.Element
        if Element.Destroyed then
            table.remove(Rules, Index)
            continue
        end

        if Rule.Enabled ~= nil then
            local Result = Evaluate(Rule.Enabled)
            if Rule.LastEnabled == nil and Result then
                Rule.LastEnabled = true
            elseif Result ~= Rule.LastEnabled then
                Rule.LastEnabled = Result
                if typeof(Element.SetDisabled) == "function" then
                    pcall(Element.SetDisabled, Element, not Result)
                end
            end
        end

        if Rule.Visible ~= nil then
            local Result = Evaluate(Rule.Visible)
            if Rule.LastVisible == nil and Result then
                Rule.LastVisible = true
            elseif Result ~= Rule.LastVisible then
                Rule.LastVisible = Result
                if typeof(Element.SetVisible) == "function" then
                    pcall(Element.SetVisible, Element, Result)
                end
            end
        end
    end

    for Index = #ComputedTexts, 1, -1 do
        local Entry = ComputedTexts[Index]
        if Entry.Element.Destroyed then
            table.remove(ComputedTexts, Index)
            continue
        end

        local Success, Text = pcall(Entry.Fn)
        if Success then
            Text = tostring(Text)
            if Text ~= Entry.Last then
                Entry.Last = Text
                local Element = Entry.Element
                if Entry.Key == "Title" and typeof(Element.SetTitle) == "function" then
                    Element:SetTitle(Text)
                elseif typeof(Element.SetText) == "function" then
                    Element:SetText(Text)
                end
            end
        end
    end
end

function Library:UpdateRules()
    ApplyRules()
end
Library:AddTick(0.15, ApplyRules)

--// ------------------------------------------------------------------ help panel \\--
local HelpCard
local HelpToken = 0

local TypeHints = {
    Toggle = "Click to toggle",
    Slider = "Drag, or right click to type a value",
    RangeSlider = "Drag either handle",
    Dropdown = "Click to choose",
    Input = "Click and type",
    Button = "Click to run",
    ReorderList = "Drag rows to reorder",
    TreeView = "Click a box to check, a row to expand",
    FeatureCard = "Click to open",
}

local function EnsureHelpCard()
    if HelpCard and HelpCard.Parent then
        return HelpCard
    end
    if not Library.Window then
        return nil
    end

    local Frame = New("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(1, -14, 1, -34),
        Size = UDim2.fromOffset(280, 0),
        Visible = false,
        ZIndex = 80,
        Parent = Library.Window.MainFrame,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = Frame }))
    Library:AddOutline(Frame, 20, 6, 0.4)
    New("UIListLayout", { Padding = UDim.new(0, 4), Parent = Frame })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 12),
        Parent = Frame,
    })

    local function MakeLabel(Name, Size, Transparency, Order)
        local Label = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = Order,
            Name = Name,
            Size = UDim2.fromScale(1, 0),
            Text = "",
            TextSize = Size,
            TextTransparency = Transparency,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Frame,
        })
        return Label
    end
    MakeLabel("Title", 15, 0, 1)
    MakeLabel("Body", 13, 0.3, 2)
    MakeLabel("Meta", 12, 0.6, 3)

    HelpCard = Frame
    return Frame
end

function Library:ShowHelp(Element)
    if not Library.HelpPanelEnabled or not Library.Toggled then
        return
    end

    local Body = Element.Help or Element.Description or Element.Tooltip
    if typeof(Body) ~= "string" or Body == "" then
        return
    end

    local Card = EnsureHelpCard()
    if not Card then
        return
    end

    local Meta = {}
    if TypeHints[Element.Type] then
        table.insert(Meta, TypeHints[Element.Type])
    end
    local Default = Element.Default
    if Default ~= nil and typeof(Default) ~= "table" and Element.Type ~= "ColorPicker" then
        table.insert(Meta, "Default: " .. tostring(Default))
    end

    Card.Title.Text = tostring(Element.Text or Element.Title or "")
    Card.Body.Text = Body
    Card.Meta.Text = table.concat(Meta, "  -  ")
    Card.Meta.Visible = #Meta > 0
    Card.Visible = true
end

function Library:HideHelp()
    if HelpCard then
        HelpCard.Visible = false
    end
end

--// ------------------------------------------------------------------ SetupReactive (called for every element) \\--
function Library:SetupReactive(Element, Info, Computed)
    if typeof(Element) ~= "table" or Element.ReactiveReady then
        return
    end
    Element.ReactiveReady = true
    Info = typeof(Info) == "table" and Info or {}

    if Info.EnabledWhen ~= nil or Info.VisibleWhen ~= nil then
        table.insert(Rules, { Element = Element, Enabled = Info.EnabledWhen, Visible = Info.VisibleWhen })
        pcall(ApplyRules)
    end

    if Computed then
        table.insert(ComputedTexts, {
            Element = Element,
            Key = Computed.Key,
            Fn = Computed.Fn,
            Last = (pcall(Computed.Fn)) and tostring(Computed.Fn()) or nil,
        })
    end

    if Element.Help == nil then
        Element.Help = Info.Help
    end

    --// Element:Bind(function(value) end) -> runs now and on every change \\--
    Element.BindList = {}
    function Element:Bind(Func)
        table.insert(Element.BindList, Func)
        Library:SafeCallback(Func, Element.Value)
        return Element
    end

    local OriginalRunChanged = Element.RunChanged
    if typeof(OriginalRunChanged) == "function" then
        Element.RunChanged = function(self, ...)
            OriginalRunChanged(self, ...)
            if not self.Disabled then
                for _, Func in self.BindList do
                    Library:SafeCallback(Func, self.Value)
                end
            end
        end
    end

    local Holder = Element.Holder
    if typeof(Holder) == "Instance" and Holder:IsA("GuiObject") then
        Holder.MouseEnter:Connect(function()
            HelpToken += 1
            local Token = HelpToken
            task.delay(0.35, function()
                if Token == HelpToken and not Element.Destroyed then
                    Library:ShowHelp(Element)
                end
            end)
        end)
        Holder.MouseLeave:Connect(function()
            HelpToken += 1
            Library:HideHelp()
        end)
    end
end

--// ------------------------------------------------------------------ context actions (right click menus) \\--
function Library:ShowContextActions(Anchor: GuiObject, Actions)
    local Menu
    Menu = Library:AddContextMenu(
        Anchor,
        UDim2.fromOffset(190, 0),
        function()
            return { Mouse.X - Anchor.AbsolutePosition.X, Mouse.Y - Anchor.AbsolutePosition.Y }
        end,
        1,
        function(Active: boolean)
            if not Active then
                task.defer(function()
                    Menu:Destroy()
                end)
            end
        end,
        false,
        nil,
        "none"
    )

    for _, Action in Actions do
        local Button = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            Text = Action.Text,
            TextSize = 14,
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Menu.Menu,
        })
        New("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = Button })

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, Library.TweenInfo, { BackgroundTransparency = 0.6, TextTransparency = 0 }):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, Library.TweenInfo, { BackgroundTransparency = 1, TextTransparency = 0.3 }):Play()
        end)
        Button.MouseButton1Click:Connect(function()
            Menu:Close()
            Library:SafeCallback(Action.Func)
        end)
    end

    Menu:Open()
end

--// ------------------------------------------------------------------ change log (last 15 changes + revert) \\--
local Snapshots = {}

local function IterateElements(Callback)
    for Idx, Element in Library.Toggles do
        Callback(Idx, Element)
    end
    for Idx, Element in Library.Options do
        Callback(Idx, Element)
    end
end

local function Tracked(Idx): boolean
    return tostring(Idx):sub(1, 3) ~= "CR_"
end

local function ScanChanges()
    local Seen = {}

    IterateElements(function(Idx, Element)
        if not Tracked(Idx) or Element.Destroyed then
            return
        end

        local Data = Library:SerializeElement(Element)
        if not Data then
            return
        end

        Seen[Idx] = true
        local Key = Stable(Data)
        local Snap = Snapshots[Idx]

        if not Snap then
            Snapshots[Idx] = { Key = Key, Data = Data }
        elseif Snap.Key ~= Key then
            if not Library._Reverting then
                table.insert(Library.ChangeLog, 1, {
                    Idx = Idx,
                    Text = tostring(Element.Text or Idx),
                    Type = Element.Type,
                    Old = Snap.Data,
                    New = Data,
                    Time = os.time(),
                })
                for Index = #Library.ChangeLog, 16, -1 do
                    table.remove(Library.ChangeLog, Index)
                end

                if Library.OnChangeLog then
                    pcall(Library.OnChangeLog)
                end
            end

            Snapshots[Idx] = { Key = Key, Data = Data }
        end
    end)

    for Idx in Snapshots do
        if not Seen[Idx] then
            Snapshots[Idx] = nil
        end
    end
end
Library:AddTick(0.3, ScanChanges)

--// call after loading a config so the load itself is not logged \\--
function Library:ResyncChangeLog()
    IterateElements(function(Idx, Element)
        if Tracked(Idx) then
            local Data = Library:SerializeElement(Element)
            if Data then
                Snapshots[Idx] = { Key = Stable(Data), Data = Data }
            end
        end
    end)
end

function Library:RevertChange(Entry): boolean
    local Element = Library.Toggles[Entry.Idx] or Library.Options[Entry.Idx]
    if not Element then
        return false
    end

    Library._Reverting = true
    Library:ApplySerialized(Element, Entry.Old)
    local Data = Library:SerializeElement(Element)
    if Data then
        Snapshots[Entry.Idx] = { Key = Stable(Data), Data = Data }
    end
    Library._Reverting = false

    local Position = table.find(Library.ChangeLog, Entry)
    if Position then
        table.remove(Library.ChangeLog, Position)
    end
    if Library.OnChangeLog then
        pcall(Library.OnChangeLog)
    end

    return true
end

function Library:DescribeValue(Data): string
    if typeof(Data) ~= "table" then
        return tostring(Data)
    end

    local Type = Data.Type
    if Type == "RangeSlider" then
        return string.format("%s - %s", tostring(Data.Low), tostring(Data.High))
    elseif Type == "ColorPicker" then
        return "#" .. tostring(Data.Hex)
    elseif Type == "KeyPicker" then
        return tostring(Data.Key)
    elseif Type == "ReorderList" or Type == "TreeView" then
        return string.format("%d items", #(Data.Value or {}))
    end

    local Value = Data.Value
    if typeof(Value) == "table" then
        local Names = {}
        for Key, Flag in Value do
            table.insert(Names, typeof(Key) == "string" and Flag == true and Key or tostring(Flag))
        end
        table.sort(Names)
        return #Names > 0 and table.concat(Names, ", ") or "none"
    end
    if Value == nil then
        return "none"
    end

    return tostring(Value)
end

--// ------------------------------------------------------------------ modified dots \\--
local function SameList(A, B): boolean
    A, B = A or {}, B or {}
    if #A ~= #B then
        return false
    end
    for Index = 1, #A do
        if A[Index] ~= B[Index] then
            return false
        end
    end
    return true
end

function Library:IsModified(Element): boolean
    local Type = Element.Type
    local Value, Default = Element.Value, Element.Default

    if Type == "Toggle" or Type == "Slider" or Type == "Input" then
        return Default ~= nil and Value ~= Default
    elseif Type == "Dropdown" then
        local Defaults = typeof(Default) == "table" and Default or {}
        if Element.Multi then
            local Set, Count = {}, 0
            for _, Name in Defaults do
                Set[Name] = true
                Count += 1
            end
            local Now = 0
            for Name, Flag in Value or {} do
                if Flag then
                    Now += 1
                    if not Set[Name] then
                        return true
                    end
                end
            end
            return Now ~= Count
        end
        return Value ~= Defaults[1]
    elseif Type == "ColorPicker" then
        return typeof(Default) == "Color3" and Value:ToHex() ~= Default:ToHex()
    elseif Type == "KeyPicker" then
        return Value ~= Default or not SameList(Element.Modifiers, Element.DefaultModifiers)
    elseif Type == "RangeSlider" then
        return typeof(Default) == "table" and (Element.Low ~= Default[1] or Element.High ~= Default[2])
    elseif Type == "ReorderList" or Type == "TreeView" then
        return typeof(Default) == "table" and not SameList(Value, Default)
    end

    return false
end

local Dots = setmetatable({}, { __mode = "k" })
local function UpdateDots()
    IterateElements(function(Idx, Element)
        if not Tracked(Idx) or Element.Destroyed then
            return
        end

        local Holder = Element.Holder
        if typeof(Holder) ~= "Instance" or not Holder:IsA("GuiObject") then
            return
        end

        local Modified = Library.ShowModifiedDots and Library:IsModified(Element)
        local Dot = Dots[Element]

        if Modified then
            if not Dot or not Dot.Parent then
                Dot = New("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = "AccentColor",
                    Position = UDim2.new(0, 4, 0.5, 0),
                    Size = UDim2.fromOffset(6, 6),
                    ZIndex = Holder.ZIndex + 3,
                    Parent = Holder,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Dot })
                Dots[Element] = Dot
            end
            Dot.Visible = true
        elseif Dot then
            Dot.Visible = false
        end
    end)
end
Library:AddTick(0.3, UpdateDots)

--// ------------------------------------------------------------------ keybind conflicts \\--
local ConflictNotified = {}
local function CheckConflicts()
    local Groups = {}
    for _, Option in Library.Options do
        if Option.Type == "KeyPicker" and not Option.Destroyed and Option.Mode ~= "Always" then
            local Value = Option.Value
            if Value and Value ~= "None" and Value ~= "Unknown" then
                local Mods = table.clone(Option.Modifiers or {})
                table.sort(Mods)
                local Key = table.concat(Mods, "+") .. "|" .. tostring(Value)
                Groups[Key] = Groups[Key] or {}
                table.insert(Groups[Key], Option)
            end
        end
    end

    for Key, List in Groups do
        local Conflict = #List > 1
        for _, Option in List do
            local Button = Option.PickerButton
            local Stroke = Button and Button:FindFirstChildOfClass("UIStroke")
            if Stroke and Library.Registry[Stroke] then
                Library.Registry[Stroke].Color = Conflict and "RedColor" or "OutlineColor"
                Stroke.Color = Conflict and Library.Scheme.RedColor or Library.Scheme.OutlineColor
            end
            Option.Conflict = Conflict
        end

        if Conflict and not ConflictNotified[Key] then
            ConflictNotified[Key] = true
            local Names = {}
            for _, Option in List do
                table.insert(Names, tostring(Option.Text or "keybind"))
            end
            Library:Notify({
                Title = "Keybind conflict",
                Description = table.concat(Names, " and ") .. " use the same key",
                Time = 6,
                Icon = "triangle-alert",
                IconColor = Library.Scheme.RedColor,
            })
        elseif not Conflict then
            ConflictNotified[Key] = nil
        end
    end

    --// keypickers that moved away from a shared key \\--
    for _, Option in Library.Options do
        if Option.Type == "KeyPicker" and Option.Conflict then
            local Still = false
            for _, List in Groups do
                if #List > 1 and table.find(List, Option) then
                    Still = true
                    break
                end
            end
            if not Still then
                Option.Conflict = false
                local Button = Option.PickerButton
                local Stroke = Button and Button:FindFirstChildOfClass("UIStroke")
                if Stroke and Library.Registry[Stroke] then
                    Library.Registry[Stroke].Color = "OutlineColor"
                    Stroke.Color = Library.Scheme.OutlineColor
                end
            end
        end
    end
end
Library:AddTick(0.5, CheckConflicts)

--// ============================================================================================== \\--
--// Window features: floating orb, detached tabs, split view, idle fade, drawer mode, layout editor
--// ============================================================================================== \\--
Library.IdleFade = 0
Library.DrawerMode = false
Library.DrawerSide = "Left"
Library.LayoutEdit = false
Library.SidebarGroups = {}
Library.EditBars = setmetatable({}, { __mode = "k" })

--// ------------------------------------------------------------------ floating orb (minimize) \\--
function Library:Minimize()
    local Window = Library.Window
    if not Window then
        return
    end

    if not Library.Orb then
        local Success, Orb = pcall(Library.AddDraggableImageButton, Library, {
            Icon = Library.WindowIcon or "cloud",
            IconSize = 28,
            ExcludeDragging = true,
            Callback = function()
                Library:Restore()
            end,
        })
        if not Success or not Orb then
            Orb = Library:AddDraggableButton({
                Text = "Menu",
                ExcludeDragging = true,
                Callback = function()
                    Library:Restore()
                end,
            })
        end
        Library.Orb = Orb

        local Button = Library.Orb.Button
        local Corner = Button:FindFirstChildOfClass("UICorner")
        if Corner then
            Corner.CornerRadius = UDim.new(1, 0)
            local Index = table.find(Library.Corners, Corner)
            if Index then
                table.remove(Library.Corners, Index) -- keep it a circle when the corner radius changes
            end
        end
        Library:AddShadow(Button, 16, 4, 0.5, "AccentColor")
    end

    local Main = Window.MainFrame
    local Button = Library.Orb.Button
    Button.Position = UDim2.fromOffset(Main.AbsolutePosition.X / Library.DPIScale, Main.AbsolutePosition.Y / Library.DPIScale)
    Button.Visible = true

    Library:Toggle(false)
    Button.Visible = true
end

function Library:Restore()
    if Library.Orb then
        Library.Orb.Button.Visible = false
    end

    Library:Toggle(true)
end

--// ------------------------------------------------------------------ detached tabs \\--
function Library:DetachTab(Tab)
    if typeof(Tab) ~= "table" or Tab.Detached or not Tab.Container or Tab.IsKeyTab or not Library.WindowContainer then
        return
    end

    local Container = Tab.Container
    local WasActive = Library.ActiveTab == Tab

    local Float = New("Frame", {
        Active = true,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(180, 120),
        Size = UDim2.fromOffset(520, 520),
        ZIndex = 1,
        Parent = Library.Floats,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Float }))
    table.insert(Library.Scales, New("UIScale", { Parent = Float }))
    Library:AddOutline(Float, 30, 10, 0.4)

    local TitleBar = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = Float,
    })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Text = tostring(Tab.Name),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar,
    })

    local DockButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "MainColor",
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(60, 24),
        Text = "Dock",
        TextSize = 13,
        TextTransparency = 0.3,
        Parent = TitleBar,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = DockButton })

    local Body = New("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(8, 40),
        Size = UDim2.new(1, -16, 1, -48),
        Parent = Float,
    })

    --// the tab content moves into the floating window \\--
    Container.Parent = Body
    Container.Visible = true
    Container.Position = UDim2.fromScale(0, 0)
    Container.Size = UDim2.fromScale(1, 1)

    local Grip = New("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -4, 1, -4),
        Size = UDim2.fromOffset(18, 18),
        Text = "",
        ZIndex = Float.ZIndex + 5,
        Parent = Float,
    })
    if ResizeIcon then
        local GripIcon = New("ImageLabel", {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            Parent = Grip,
        })
        Library:ApplyLucideIcon(GripIcon, ResizeIcon)
    end

    Library:MakeDraggable(Float, TitleBar, true)
    Library:MakeResizable(Float, Grip, function()
        Tab:Resize(true)
    end)
    table.insert(Library.DraggableElements, Float)

    --// placeholder in the main window \\--
    local Card = New("Frame", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.25,
        Position = UDim2.fromOffset(2, 4),
        Size = UDim2.new(1, -4, 0, 120),
        Visible = WasActive,
        Parent = Library.WindowContainer,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Card }))
    New("UIStroke", { Color = "OutlineColor", Transparency = 0.45, Parent = Card })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 24),
        Size = UDim2.new(1, 0, 0, 24),
        Text = string.format("%s is open in its own window", tostring(Tab.Name)),
        TextSize = 16,
        Parent = Card,
    })
    local Back = New("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(0.5, 0, 0, 64),
        Size = UDim2.fromOffset(120, 30),
        Text = "Dock back",
        TextSize = 14,
        Parent = Card,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = Back })

    Tab.Detached = true
    Tab.Float = Float
    Tab.DetachedCard = Card

    local function Dock()
        Library:DockTab(Tab)
    end
    DockButton.MouseButton1Click:Connect(Dock)
    Back.MouseButton1Click:Connect(Dock)

    Tab:Resize(true)
end

function Library:DockTab(Tab)
    if typeof(Tab) ~= "table" or not Tab.Detached then
        return
    end

    Tab.Detached = false

    if Tab.Container and Library.WindowContainer then
        Tab.Container.Parent = Library.WindowContainer
        Tab.Container.Position = UDim2.fromScale(0, 0)
        Tab.Container.Size = UDim2.fromScale(1, 1)
        Tab.Container.Visible = Library.ActiveTab == Tab
    end

    if Tab.Float then
        local Index = table.find(Library.DraggableElements, Tab.Float)
        if Index then
            table.remove(Library.DraggableElements, Index)
        end
        for ScaleIndex = #Library.Scales, 1, -1 do
            if Library.Scales[ScaleIndex].Parent == Tab.Float then
                table.remove(Library.Scales, ScaleIndex)
            end
        end
        Tab.Float:Destroy()
    end
    if Tab.DetachedCard then
        Tab.DetachedCard:Destroy()
    end

    Tab.Float, Tab.DetachedCard = nil, nil
    Tab:Resize(true)
end

--// floating tab windows only show while the main window is open \\--
Library:AddTick(0.2, function()
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and Tab.Detached and Tab.Float then
            Tab.Float.Visible = Library.Toggled == true
        end
    end
end)

--// ------------------------------------------------------------------ split view \\--
Library.SplitTab = nil

local function ClearSplitLayout()
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and Tab.Container and not Tab.Detached and Tab.SplitApplied then
            Tab.SplitApplied = nil
            Tab.Container.Size = UDim2.fromScale(1, 1)
            Tab.Container.Position = UDim2.fromScale(0, 0)
            Tab.Container.Visible = Library.ActiveTab == Tab
        end
    end
end

function Library:SetSplit(Tab)
    Library.SplitTab = (typeof(Tab) == "table" and not Tab.IsKeyTab) and Tab or nil
    if not Library.SplitTab then
        ClearSplitLayout()
    end
end

Library:AddTick(0.1, function()
    local Second = Library.SplitTab
    if not Second then
        return
    end

    local Primary = Library.ActiveTab
    if not Primary or Primary == Second or Primary.IsKeyTab or Second.Detached or Primary.Detached or Second.Destroyed then
        if Primary == Second then
            Library.SplitTab = nil
        end
        ClearSplitLayout()
        return
    end

    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and Tab.SplitApplied and Tab ~= Primary and Tab ~= Second then
            Tab.SplitApplied = nil
            Tab.Container.Size = UDim2.fromScale(1, 1)
        end
    end

    Primary.SplitApplied = true
    Primary.Container.Size = UDim2.new(0.5, -3, 1, 0)

    Second.SplitApplied = true
    Second.Container.Visible = true
    Second.Container.Size = UDim2.new(0.5, -3, 1, 0)
    Second.Container.Position = UDim2.new(0.5, 3, 0, 0)
end)

--// ------------------------------------------------------------------ tab right click menu \\--
function Library:ShowTabMenu(Tab)
    if typeof(Tab) ~= "table" or not Tab.Button then
        return
    end

    local Actions = {}

    if Tab.Detached then
        table.insert(Actions, { Text = "Dock tab", Func = function() Library:DockTab(Tab) end })
    else
        table.insert(Actions, { Text = "Open in its own window", Func = function() Library:DetachTab(Tab) end })
    end

    if Library.SplitTab == Tab then
        table.insert(Actions, { Text = "Close split view", Func = function() Library:SetSplit(nil) end })
    elseif Library.ActiveTab ~= Tab and not Tab.Detached then
        table.insert(Actions, { Text = "Show beside current tab", Func = function() Library:SetSplit(Tab) end })
    end

    if Tab.Group then
        table.insert(Actions, {
            Text = Tab.Group.Collapsed and "Expand group" or "Collapse group",
            Func = function() Tab.Group:SetCollapsed(not Tab.Group.Collapsed) end,
        })
    end

    Library:ShowContextActions(Tab.Button, Actions)
end

--// ------------------------------------------------------------------ idle fade \\--
local IdleCache = {}
local IdleFaded = false
local IdleBusy = false
local IdleOutsideSince = nil

local function FadeProps(Descendant)
    if Descendant:IsA("TextLabel") or Descendant:IsA("TextButton") or Descendant:IsA("TextBox") then
        return { "BackgroundTransparency", "TextTransparency" }
    elseif Descendant:IsA("ImageLabel") or Descendant:IsA("ImageButton") then
        return { "BackgroundTransparency", "ImageTransparency" }
    elseif Descendant:IsA("GuiObject") then
        return { "BackgroundTransparency" }
    elseif Descendant:IsA("UIStroke") or Descendant:IsA("UIShadow") then
        return { "Transparency" }
    end

    return nil
end

local function SetIdleFaded(State: boolean)
    if State == IdleFaded or IdleBusy or not Library.Window then
        return
    end

    IdleBusy = true
    IdleFaded = State
    local Main = Library.Window.MainFrame
    local Target = math.clamp(Library.IdleFade, 0, 0.85)

    task.spawn(function()
        if State then
            table.clear(IdleCache)
            for _, Descendant in Main:GetDescendants() do
                local Props = FadeProps(Descendant)
                if Props then
                    local Original = {}
                    for _, Prop in Props do
                        Original[Prop] = Descendant[Prop]
                    end
                    IdleCache[Descendant] = Original
                end
            end
            IdleCache[Main] = { BackgroundTransparency = Main.BackgroundTransparency }
        end

        local Steps = 10
        for Step = 1, Steps do
            local Alpha = State and (Step / Steps) or (1 - Step / Steps)
            for Descendant, Original in IdleCache do
                if Descendant.Parent then
                    for Prop, Value in Original do
                        Descendant[Prop] = Value + (1 - Value) * Target * Alpha
                    end
                end
            end
            RunService.RenderStepped:Wait()
        end

        if not State then
            for Descendant, Original in IdleCache do
                if Descendant.Parent then
                    for Prop, Value in Original do
                        Descendant[Prop] = Value
                    end
                end
            end
            table.clear(IdleCache)
        end

        IdleBusy = false
    end)
end

Library:AddTick(0.25, function()
    if not Library.Window then
        return
    end

    if Library.IdleFade <= 0 or not Library.Toggled then
        IdleOutsideSince = nil
        if IdleFaded then
            SetIdleFaded(false)
        end
        return
    end

    local Main = Library.Window.MainFrame
    local Point = Vector2.new(Mouse.X, Mouse.Y)
    local Inside = Library:MouseIsOverFrame(Main, Point)
        or Library.CantDragForced
        or Library.ActiveDialog ~= nil
        or Library.IsPicking
        or (Library.SearchPanel and Library.SearchPanel.Active)
        or UserInputService:GetFocusedTextBox() ~= nil

    if Inside then
        IdleOutsideSince = nil
        if IdleFaded then
            SetIdleFaded(false)
        end
    else
        IdleOutsideSince = IdleOutsideSince or os.clock()
        if not IdleFaded and os.clock() - IdleOutsideSince >= 1.2 then
            SetIdleFaded(true)
        end
    end
end)

--// ------------------------------------------------------------------ drawer mode \\--
local DrawerOpen = false
local DrawerLeftAt = nil
local DrawerWasLocked = false

function Library:SetDrawer(Enabled: boolean, Side: string?)
    Enabled = Enabled == true
    if Side then
        Library.DrawerSide = string.lower(Side) == "right" and "Right" or "Left"
    end
    if Enabled == Library.DrawerMode then
        return
    end

    Library.DrawerMode = Enabled
    local Window = Library.Window
    if not Window then
        return
    end

    local Main = Window.MainFrame
    if Enabled then
        DrawerWasLocked = Library.CantDragForced
        Library.CantDragForced = true
        DrawerOpen = false
    else
        Library.CantDragForced = DrawerWasLocked
        Main.Position = UDim2.new(0.5, -Main.Size.X.Offset / 2, 0.5, -Main.Size.Y.Offset / 2)
    end
end

Library:AddTick(0.05, function()
    if not Library.DrawerMode or not Library.Window or not Library.Toggled then
        return
    end

    local Main = Library.Window.MainFrame
    local Width, Height = Main.Size.X.Offset, Main.Size.Y.Offset
    local Viewport = workspace.CurrentCamera.ViewportSize
    local Right = Library.DrawerSide == "Right"

    local AtEdge = Right and Mouse.X >= Viewport.X - 6 or (not Right and Mouse.X <= 6)
    local Over = Library:MouseIsOverFrame(Main, Vector2.new(Mouse.X, Mouse.Y))
        or Library.ActiveDialog ~= nil
        or UserInputService:GetFocusedTextBox() ~= nil
        or CurrentMenu ~= nil

    local Want = DrawerOpen
    if AtEdge or Over then
        Want = true
        DrawerLeftAt = nil
    elseif DrawerOpen then
        DrawerLeftAt = DrawerLeftAt or os.clock()
        if os.clock() - DrawerLeftAt > 0.7 then
            Want = false
        end
    end

    local Open = Right and UDim2.new(1, -Width, 0.5, -Height / 2) or UDim2.new(0, 0, 0.5, -Height / 2)
    local Closed = Right and UDim2.new(1, -10, 0.5, -Height / 2) or UDim2.new(0, -Width + 10, 0.5, -Height / 2)

    if Want ~= DrawerOpen or Main.Position == UDim2.new(0.5, -Width / 2, 0.5, -Height / 2) then
        DrawerOpen = Want
        TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = DrawerOpen and Open or Closed,
        }):Play()
    end
end)

--// ------------------------------------------------------------------ layout editor \\--
local function ColumnOf(BoxHolder)
    local Parent = BoxHolder.Parent
    if Parent and Parent:IsA("ScrollingFrame") and Parent.Name == "CloudyColumn" then
        return Parent
    end

    return nil
end

local function OrderedBoxes(Column)
    local List = {}
    for _, Child in Column:GetChildren() do
        if Child:GetAttribute("CRBox") then
            table.insert(List, Child)
        end
    end

    table.sort(List, function(A, B)
        if A.LayoutOrder ~= B.LayoutOrder then
            return A.LayoutOrder < B.LayoutOrder
        end
        return A.AbsolutePosition.Y < B.AbsolutePosition.Y
    end)

    for Index, Box in List do
        Box.LayoutOrder = Index * 10
    end

    return List
end

function Library:MoveGroupbox(BoxHolder, Action: string, Columns)
    local Column = ColumnOf(BoxHolder)
    if not Column then
        return
    end

    local List = OrderedBoxes(Column)
    local Position = table.find(List, BoxHolder)
    if not Position then
        return
    end

    if Action == "up" and Position > 1 then
        List[Position].LayoutOrder, List[Position - 1].LayoutOrder = List[Position - 1].LayoutOrder, List[Position].LayoutOrder
    elseif Action == "down" and Position < #List then
        List[Position].LayoutOrder, List[Position + 1].LayoutOrder = List[Position + 1].LayoutOrder, List[Position].LayoutOrder
    elseif Action == "side" and Columns then
        local Other = Column == Columns.Left and Columns.Right or (Column == Columns.Right and Columns.Left or nil)
        if Other then
            BoxHolder.Parent = Other
            BoxHolder.LayoutOrder = 100000
            OrderedBoxes(Other)
        end
    end

    Library:SaveLayout()
end

function Library:CollectLayout()
    local Layout = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) ~= "table" or Tab.IsKeyTab then
            continue
        end

        for Key, Groupbox in Tab.Groupboxes do
            if Groupbox.ParentBox or not Groupbox.BoxHolder then
                continue
            end

            local Column = ColumnOf(Groupbox.BoxHolder)
            local Columns = (Groupbox.Page and Groupbox.Page.Columns) or Tab.Columns
            if Column and Columns then
                local Side = Column == Columns.Left and "Left" or (Column == Columns.Right and "Right" or "Full")
                Layout[tostring(Tab.Name) .. "/" .. tostring(Key)] = { Side = Side, Order = Groupbox.BoxHolder.LayoutOrder }
            end
        end
    end

    return Layout
end

function Library:SaveLayout()
    local Manager = Library.Manager
    if Manager then
        Manager.Saved.Layout = Library:CollectLayout()
        Library:SaveLibrarySettings()
    end
end

function Library:ApplyLayout()
    local Manager = Library.Manager
    local Saved = Manager and Manager.Saved.Layout
    if typeof(Saved) ~= "table" then
        return
    end

    for _, Tab in Library.Tabs do
        if typeof(Tab) ~= "table" or Tab.IsKeyTab then
            continue
        end

        for Key, Groupbox in Tab.Groupboxes do
            local Entry = Saved[tostring(Tab.Name) .. "/" .. tostring(Key)]
            if typeof(Entry) ~= "table" or Groupbox.ParentBox or not Groupbox.BoxHolder then
                continue
            end

            local Columns = (Groupbox.Page and Groupbox.Page.Columns) or Tab.Columns
            local Target = Columns and Columns[Entry.Side]
            if Target and Target.Parent and Groupbox.BoxHolder.Parent ~= Target and Entry.Side ~= "Full" then
                Groupbox.BoxHolder.Parent = Target
            end
            if typeof(Entry.Order) == "number" then
                Groupbox.BoxHolder.LayoutOrder = Entry.Order
            end
        end
    end
end

function Library:SetLayoutEdit(Enabled: boolean)
    Library.LayoutEdit = Enabled == true
    for Bar in Library.EditBars do
        Bar.Visible = Library.LayoutEdit
    end
end

--// ============================================================================================== \\--
--// Quality + accessibility + discovery: contrast, text scale, reduced motion, auto theme, tour
--// ============================================================================================== \\--
Library.TextScale = 1
Library.ReducedMotion = false
Library.AutoThemeEnabled = false
Library.AutoThemeDay = "Light"
Library.AutoThemeNight = "Cloudy"
Library.AutoThemeDayStart = 7
Library.AutoThemeNightStart = 19
Library.TourActive = false

--// ------------------------------------------------------------------ contrast (WCAG) \\--
local function Linear(Channel: number): number
    return Channel <= 0.03928 and Channel / 12.92 or ((Channel + 0.055) / 1.055) ^ 2.4
end

local function Luminance(Color: Color3): number
    return 0.2126 * Linear(Color.R) + 0.7152 * Linear(Color.G) + 0.0722 * Linear(Color.B)
end

function Library:GetContrast(A: Color3, B: Color3): number
    local L1, L2 = Luminance(A), Luminance(B)
    if L1 < L2 then
        L1, L2 = L2, L1
    end

    return (L1 + 0.05) / (L2 + 0.05)
end

function Library:GetReadableTextColor(Background: Color3): Color3
    local Light, Dark = Color3.fromRGB(245, 247, 250), Color3.fromRGB(16, 18, 22)
    return Library:GetContrast(Light, Background) >= Library:GetContrast(Dark, Background) and Light or Dark
end

function Library:DescribeContrast(Ratio: number): string
    if Ratio >= 7 then
        return "excellent"
    elseif Ratio >= 4.5 then
        return "good"
    elseif Ratio >= 3 then
        return "low"
    end

    return "poor"
end

--// ------------------------------------------------------------------ text scale \\--
Library.RowCards = Library.RowCards or setmetatable({}, { __mode = "k" })

function Library:SetTextScale(Scale: number)
    Scale = math.clamp(tonumber(Scale) or 1, 0.8, 1.3)
    Library.TextScale = Scale

    if not Library.ScreenGui then
        return
    end

    for _, Descendant in Library.ScreenGui:GetDescendants() do
        if
            (Descendant:IsA("TextLabel") or Descendant:IsA("TextButton") or Descendant:IsA("TextBox"))
            and not Descendant.TextScaled
        then
            local Base = Descendant:GetAttribute("CRBaseSize")
            if not Base then
                Base = Descendant.TextSize
                Descendant:SetAttribute("CRBaseSize", Base)
            end

            Descendant.TextSize = math.max(8, math.floor(Base * Scale + 0.5))
        end
    end

    --// wrapped descriptions need new heights \\--
    for Row in Library.RowCards do
        pcall(Row.Invalidate)
        pcall(Row.Relayout)
    end
end

--// ------------------------------------------------------------------ reduced motion \\--
local MotionKeys = { "ToggleWindow", "TabSwitch", "Groupbox", "Dropdown", "KeyPicker" }

function Library:SetReducedMotion(Enabled: boolean)
    Enabled = Enabled == true
    if Enabled == Library.ReducedMotion then
        return
    end
    Library.ReducedMotion = Enabled

    if Enabled then
        Library._Motion = {
            TweenInfo = Library.TweenInfo,
            Animations = table.clone(Library.Animations or {}),
            Ambient = Library.AmbientGlow,
            Glow = Library.ElementGlow,
        }

        Library.TweenInfo = TweenInfo.new(0)
        for _, Key in MotionKeys do
            Library.Animations[Key] = false
        end

        Library.AmbientGlow = false
        if Library.AmbientGlowFrame then
            Library.AmbientGlowFrame.Visible = false
        end

        Library.ElementGlow = false
        for Shadow in Library.ElementShadows do
            pcall(function()
                Shadow.Enabled = false
            end)
        end
    else
        local Backup = Library._Motion
        if Backup then
            Library.TweenInfo = Backup.TweenInfo
            for _, Key in MotionKeys do
                Library.Animations[Key] = Backup.Animations[Key] == true
            end

            Library.AmbientGlow = Backup.Ambient ~= false
            if Library.AmbientGlowFrame then
                Library.AmbientGlowFrame.Visible = Library.AmbientGlow
            end

            Library.ElementGlow = Backup.Glow ~= false
            for Shadow in Library.ElementShadows do
                pcall(function()
                    Shadow.Enabled = Library.ElementGlow
                end)
            end
        end
    end
end

--// ------------------------------------------------------------------ time based theme \\--
function Library:CheckAutoTheme(Force: boolean?)
    if not Library.AutoThemeEnabled or not Library.ApplyPreset then
        return
    end

    local Success, Hour = pcall(function()
        return tonumber(os.date("%H"))
    end)
    if not Success or not Hour then
        return
    end

    local DayStart, NightStart = Library.AutoThemeDayStart, Library.AutoThemeNightStart
    local IsDay
    if DayStart <= NightStart then
        IsDay = Hour >= DayStart and Hour < NightStart
    else
        IsDay = Hour >= DayStart or Hour < NightStart
    end

    local Mode = IsDay and "Day" or "Night"
    if Force or Mode ~= Library._AutoThemeMode then
        Library._AutoThemeMode = Mode
        Library:ApplyPreset(IsDay and Library.AutoThemeDay or Library.AutoThemeNight)
    end
end
Library:AddTick(30, function()
    Library:CheckAutoTheme(false)
end)

--// ------------------------------------------------------------------ first run tour \\--
function Library:StartTour(Steps)
    if Library.TourActive or not Library.Overlay or not Library.Window then
        return
    end

    if not Library.Toggled then
        Library:Toggle(true)
    end

    if not Steps then
        local KeyName = "the menu key"
        if typeof(Library.ToggleKeybind) == "EnumItem" then
            KeyName = Library.ToggleKeybind.Name
        elseif typeof(Library.ToggleKeybind) == "table" and Library.ToggleKeybind.Value then
            KeyName = tostring(Library.ToggleKeybind.Value)
        end

        Steps = {
            { Title = "Welcome", Text = "A quick look around. Press Next, or Skip any time." },
            { Title = "Sidebar", Text = "Switch tabs here. Right click a tab for split view, or to open it in its own window.", Target = Library.SidebarFrame },
            { Title = "Search", Text = "Find any tab, groupbox or setting. Use the Modified filter to see what you changed.", Target = Library.SearchButton },
        }
        if Library.SettingTab and Library.SettingTab.Button then
            table.insert(Steps, { Title = "Settings", Text = "Themes, configs and library options live here.", Target = Library.SettingTab.Button })
        end
        table.insert(Steps, { Title = "Menu key", Text = string.format("Press %s to hide or show the menu. Minimize turns it into a floating orb.", KeyName) })
    end

    Library.TourActive = true
    local Overlay = Library.Overlay

    local Root = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 500,
        Parent = Overlay,
    })

    local function Dim()
        return New("Frame", {
            Active = true,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            Parent = Root,
        })
    end
    local Top, Bottom, Left, Right = Dim(), Dim(), Dim(), Dim()

    local Outline = New("Frame", {
        BackgroundTransparency = 1,
        Visible = false,
        Parent = Root,
    })
    New("UIStroke", { Color = "AccentColor", Thickness = 2, Parent = Outline })
    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = Outline })

    local Card = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(320, 0),
        Parent = Root,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = Card }))
    Library:AddOutline(Card, 24, 8, 0.35)
    New("UIListLayout", { Padding = UDim.new(0, 6), Parent = Card })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 14),
        Parent = Card,
    })

    local TitleLabel = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Size = UDim2.fromScale(1, 0),
        Text = "",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card,
    })
    local BodyLabel = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Size = UDim2.fromScale(1, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.25,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card,
    })

    local Buttons = New("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = Card,
    })
    local Counter = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 1, 0),
        Text = "",
        TextSize = 12,
        TextTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Buttons,
    })

    local function MakeButton(Text: string, Offset: number, Accent: boolean)
        local Button = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Accent and "AccentColor" or "MainColor",
            Position = UDim2.new(1, Offset, 0.5, 0),
            Size = UDim2.fromOffset(70, 28),
            Text = Text,
            TextSize = 14,
            TextColor3 = Accent and "WhiteColor" or "FontColor",
            Parent = Buttons,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Button })
        return Button
    end
    local NextButton = MakeButton("Next", 0, true)
    local SkipButton = MakeButton("Skip", -78, false)

    local Index = 0
    local Finish
    local function Show()
        local Step = Steps[Index]
        TitleLabel.Text = Step.Title or ""
        BodyLabel.Text = Step.Text or ""
        Counter.Text = string.format("%d / %d", Index, #Steps)
        NextButton.Text = Index == #Steps and "Done" or "Next"

        local Size = Overlay.AbsoluteSize
        local Origin = Overlay.AbsolutePosition
        local Target = Step.Target

        if typeof(Target) == "Instance" and Target:IsA("GuiObject") and Target.AbsoluteSize.X > 0 then
            local Pad = 6
            local X = Target.AbsolutePosition.X - Origin.X - Pad
            local Y = Target.AbsolutePosition.Y - Origin.Y - Pad
            local W = Target.AbsoluteSize.X + Pad * 2
            local H = Target.AbsoluteSize.Y + Pad * 2

            Top.Position, Top.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(Size.X, math.max(Y, 0))
            Bottom.Position, Bottom.Size = UDim2.fromOffset(0, Y + H), UDim2.fromOffset(Size.X, math.max(Size.Y - (Y + H), 0))
            Left.Position, Left.Size = UDim2.fromOffset(0, Y), UDim2.fromOffset(math.max(X, 0), H)
            Right.Position, Right.Size = UDim2.fromOffset(X + W, Y), UDim2.fromOffset(math.max(Size.X - (X + W), 0), H)

            Outline.Position, Outline.Size = UDim2.fromOffset(X, Y), UDim2.fromOffset(W, H)
            Outline.Visible = true

            local CardX = math.clamp(X, 12, math.max(Size.X - 332, 12))
            local CardY = Y + H + 12
            if CardY + 170 > Size.Y then
                CardY = math.max(Y - 182, 12)
            end
            Card.Position = UDim2.fromOffset(CardX, CardY)
        else
            Top.Position, Top.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(Size.X, Size.Y)
            Bottom.Size, Left.Size, Right.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(0, 0), UDim2.fromOffset(0, 0)
            Outline.Visible = false
            Card.Position = UDim2.fromOffset(math.max((Size.X - 320) / 2, 12), math.max(Size.Y / 2 - 90, 12))
        end
    end

    Finish = function()
        Library.TourActive = false
        Root:Destroy()

        local Manager = Library.Manager
        if Manager and Manager.Folder then
            Manager.Saved.Library.TourDone = true
            Library:SaveLibrarySettings()
        end
    end

    NextButton.MouseButton1Click:Connect(function()
        if Index >= #Steps then
            Finish()
        else
            Index += 1
            Show()
        end
    end)
    SkipButton.MouseButton1Click:Connect(Finish)

    Index = 1
    Show()
end

--// ============================================================================================== \\--
--// Settings manager
--//   Library:SetFolder("MyHub")          -> HubName/Library/Config.json (library auto save), HubName/Configs/*.json
--//   Library:SetSettingTab(Tab)          -> builds the Config / Theme / Library pages inside a tab
--//   Library:SaveConfig / LoadConfig / DeleteConfig / SetAutoload / LoadAutoloadConfig / SetIgnoreIndexes
--// ============================================================================================== \\--
local HttpService: HttpService = cloneref(game:GetService("HttpService"))

local FS = {
    Supported = typeof(writefile) == "function"
        and typeof(readfile) == "function"
        and typeof(isfile) == "function"
        and typeof(isfolder) == "function"
        and typeof(makefolder) == "function",
    CanList = typeof(listfiles) == "function",
    CanDelete = typeof(delfile) == "function",
}

local Manager = {
    Folder = nil,
    Saved = { Library = {} },
    Ignore = {},

    Applying = false,
    Building = false,
    SaveToken = 0,

    CurrentConfig = nil,
    AutoSaveConfig = false,
    LastSerialized = nil,
}
Library.Manager = Manager

local ThemeKeys = { "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "RedColor" }
local ThemeLabels = {
    BackgroundColor = "Background",
    MainColor = "Main",
    AccentColor = "Accent",
    OutlineColor = "Outline",
    FontColor = "Text",
    RedColor = "Danger",
}

local ThemePresets = {
    Cloudy = { BackgroundColor = { 14, 15, 18 }, MainColor = { 26, 28, 33 }, AccentColor = { 33, 128, 230 }, OutlineColor = { 40, 43, 50 }, FontColor = { 240, 243, 248 }, RedColor = { 255, 50, 50 } },
    Midnight = { BackgroundColor = { 10, 10, 16 }, MainColor = { 20, 20, 32 }, AccentColor = { 124, 92, 255 }, OutlineColor = { 36, 36, 56 }, FontColor = { 235, 235, 250 }, RedColor = { 255, 60, 90 } },
    Ocean = { BackgroundColor = { 9, 16, 22 }, MainColor = { 17, 30, 40 }, AccentColor = { 0, 184, 217 }, OutlineColor = { 30, 50, 64 }, FontColor = { 230, 245, 250 }, RedColor = { 255, 70, 70 } },
    Emerald = { BackgroundColor = { 11, 17, 15 }, MainColor = { 20, 31, 27 }, AccentColor = { 52, 211, 153 }, OutlineColor = { 34, 52, 45 }, FontColor = { 232, 248, 240 }, RedColor = { 255, 70, 70 } },
    Rose = { BackgroundColor = { 18, 12, 14 }, MainColor = { 31, 21, 25 }, AccentColor = { 244, 63, 94 }, OutlineColor = { 54, 36, 42 }, FontColor = { 250, 235, 238 }, RedColor = { 255, 90, 90 } },
    Sunset = { BackgroundColor = { 18, 13, 10 }, MainColor = { 32, 23, 17 }, AccentColor = { 251, 146, 60 }, OutlineColor = { 56, 42, 32 }, FontColor = { 252, 240, 230 }, RedColor = { 255, 70, 70 } },
    Graphite = { BackgroundColor = { 18, 18, 18 }, MainColor = { 30, 30, 30 }, AccentColor = { 200, 200, 200 }, OutlineColor = { 48, 48, 48 }, FontColor = { 245, 245, 245 }, RedColor = { 255, 70, 70 } },
    Light = { Light = true, BackgroundColor = { 244, 245, 247 }, MainColor = { 255, 255, 255 }, AccentColor = { 37, 99, 235 }, OutlineColor = { 214, 217, 224 }, FontColor = { 24, 26, 32 }, RedColor = { 220, 38, 38 } },
}
ThemePresets.HighContrast = { BackgroundColor = { 0, 0, 0 }, MainColor = { 20, 20, 20 }, AccentColor = { 255, 214, 0 }, OutlineColor = { 255, 255, 255 }, FontColor = { 255, 255, 255 }, RedColor = { 255, 90, 90 } }
local ThemePresetOrder = { "Cloudy", "Midnight", "Ocean", "Emerald", "Rose", "Sunset", "Graphite", "Light", "HighContrast" }

local FontNames = { "Cloudy", "Gotham", "GothamMedium", "GothamBold", "BuilderSans", "BuilderSansMedium", "Roboto", "RobotoMono", "Ubuntu", "Arimo", "SourceSans", "Nunito", "Montserrat", "Inconsolata", "Code" }
Library.CurrentFontName = "Cloudy"

local function GetFontByName(Name: string)
    if Name == "Cloudy" then
        return Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    end

    local Success, Result = pcall(function()
        return Font.fromEnum(Enum.Font[Name])
    end)
    return Success and Result or nil
end

--// File helpers \\--
local function SafeName(Name): string
    local Clean = tostring(Name or ""):gsub("[<>:\"/\\|%?%*%c]", "")
    return Trim(Clean)
end

local function Path(...: string): string
    return table.concat({ Manager.Folder, ... }, "/")
end

local function EnsureFolders()
    if not FS.Supported or not Manager.Folder then
        return
    end

    for _, Folder in { Manager.Folder, Path("Library"), Path("Library", "Themes"), Path("Configs") } do
        if not isfolder(Folder) then
            pcall(makefolder, Folder)
        end
    end
end

local function ReadJson(FilePath: string)
    if not FS.Supported then
        return nil
    end

    local Success, Result = pcall(function()
        if isfile(FilePath) then
            return HttpService:JSONDecode(readfile(FilePath))
        end

        return nil
    end)

    return Success and Result or nil
end

local function WriteJson(FilePath: string, Data): (boolean, string?)
    if not FS.Supported then
        return false, "This executor has no file functions"
    end

    local Success, Err = pcall(function()
        writefile(FilePath, HttpService:JSONEncode(Data))
    end)
    return Success, if Success then nil else tostring(Err)
end

local function ListJson(Folder: string): { string }
    local List = {}
    if not FS.Supported or not FS.CanList or not Manager.Folder then
        return List
    end

    local Success, Files = pcall(listfiles, Folder)
    if Success and typeof(Files) == "table" then
        for _, File in Files do
            local Name = (tostring(File):gsub("\\", "/")):match("([^/]+)%.json$")
            if Name then
                table.insert(List, Name)
            end
        end
    end

    table.sort(List)
    return List
end

local function Toast(Title: string, Description: string, Icon: string?)
    Library:Notify({
        Title = Title,
        Description = Description,
        Time = 4,
        Icon = Icon or "check",
    })
end

--// Theme helpers \\--
local function ApplyThemeColors(Colors, Light: boolean?)
    for Key, Color in Colors do
        Library.Scheme[Key] = Color
    end
    if Light ~= nil then
        Library.IsLightTheme = Light == true
    end

    Library:UpdateColorsUsingRegistry()
end

local function ApplyFontByName(Name: string)
    local FontFace = GetFontByName(Name)
    if FontFace then
        Library.CurrentFontName = Name
        Library:SetFont(FontFace)
    end
end

local function ThemeToTable()
    local Theme = {
        Light = Library.IsLightTheme == true,
        Font = Library.CurrentFontName or "Cloudy",
    }
    for _, Key in ThemeKeys do
        local Color = Library.Scheme[Key]
        if typeof(Color) == "Color3" then
            Theme[Key] = Color:ToHex()
        end
    end

    return Theme
end

local function PresetToTheme(Name: string)
    local Preset = ThemePresets[Name]
    local Theme = { Light = Preset.Light == true }
    for _, Key in ThemeKeys do
        local RGB = Preset[Key]
        Theme[Key] = Color3.fromRGB(RGB[1], RGB[2], RGB[3]):ToHex()
    end

    return Theme
end

function Library:ApplyThemeTable(Theme)
    if typeof(Theme) ~= "table" then
        return
    end

    local Colors = {}
    for _, Key in ThemeKeys do
        if typeof(Theme[Key]) == "string" then
            local Success, Color = pcall(Color3.fromHex, Theme[Key])
            if Success and typeof(Color) == "Color3" then
                Colors[Key] = Color
            end
        end
    end

    local Was = Manager.Applying
    Manager.Applying = true

    ApplyThemeColors(Colors, Theme.Light)
    if typeof(Theme.Font) == "string" then
        ApplyFontByName(Theme.Font)

        local FontDropdown = Library.Options.CR_Font
        if FontDropdown then
            pcall(FontDropdown.SetValue, FontDropdown, Theme.Font)
        end
    end

    --// keep the colour pickers of the settings tab in sync \\--
    for Key, Color in Colors do
        local Picker = Library.Options["CR_Color_" .. Key]
        if Picker then
            pcall(Picker.SetValueRGB, Picker, Color)
        end
    end

    Manager.Applying = Was
end

--// Library settings (saved in HubName/Library/Config.json) \\--
function Library:ApplyPreset(Name: string)
    if ThemePresets[Name] then
        Library:ApplyThemeTable(PresetToTheme(Name))
    end
end

function Library:GetPresetNames(): { string }
    return table.clone(ThemePresetOrder)
end

local LibraryDefaults = {
    ElementGlow = true,
    AmbientGlow = true,
    ShowCustomCursor = false,
    NotifySide = "Right",
    NotifyOnError = false,
    ShowToggleFrameInKeybinds = true,
    ShowKeybindList = false,
    DPIScale = 100,
    Snapping = false,
    AlwaysOnTop = false,
    SidebarCompact = false,
    BackgroundImage = "",
    TabSwipeFrom = "bottom",
    TabTransitionTime = 0.22,
    Anim_ToggleWindow = false,
    Anim_TabSwitch = false,
    Anim_Groupbox = false,
    Anim_Dropdown = false,
    Anim_KeyPicker = false,
    ModifiedDots = true,
    HelpPanel = false,
    TextScale = 100,
    ReducedMotion = false,
    IdleFade = 0,
    DrawerMode = false,
    DrawerSide = "Left",
    AutoTheme = false,
    DayPreset = "Light",
    NightPreset = "Cloudy",
    DayStart = 7,
    NightStart = 19,
}

local Apply = {}
function Apply.ElementGlow(Value)
    Library.ElementGlow = Value == true
    for Shadow in Library.ElementShadows do
        pcall(function()
            Shadow.Enabled = Value == true
        end)
    end
end
function Apply.AmbientGlow(Value)
    Library.AmbientGlow = Value == true
    if Library.AmbientGlowFrame then
        Library.AmbientGlowFrame.Visible = Value == true
    end
end
function Apply.ShowCustomCursor(Value)
    Library.ShowCustomCursor = Value == true
end
function Apply.NotifySide(Value)
    Library:SetNotifySide(Value)
end
function Apply.NotifyOnError(Value)
    Library.NotifyOnError = Value == true
end
function Apply.ShowToggleFrameInKeybinds(Value)
    Library.ShowToggleFrameInKeybinds = Value == true
    for _, Option in Library.Options do
        if Option.Type == "KeyPicker" then
            pcall(Option.Update, Option)
        end
    end
end
function Apply.ShowKeybindList(Value)
    if Library.KeybindFrame then
        Library.KeybindFrame.Visible = Value == true
    end
end
function Apply.DPIScale(Value)
    local Number = typeof(Value) == "number" and Value or tonumber((tostring(Value):gsub("%%", "")))
    if Number then
        Library:SetDPIScale(Number)
    end
end
function Apply.Snapping(Value)
    if Library.Window then
        Library.Window:SetSnapping(Value == true)
    end
end
function Apply.AlwaysOnTop(Value)
    if Library.Window then
        Library.Window:SetAlwaysOnTop(Value == true)
    end
end
function Apply.SidebarCompact(Value)
    if Library.Window then
        Library.Window:SetCompact(Value == true)
    end
end
function Apply.BackgroundImage(Value)
    if Library.Window and (typeof(Value) == "string" or typeof(Value) == "number") then
        Library:SetBackgroundImage(Value)
    end
end
function Apply.TabSwipeFrom(Value)
    Library.TabSwipeFrom = string.lower(tostring(Value))
end
function Apply.TabTransitionTime(Value)
    Library.TabTransitionInfo = TweenInfo.new(math.max(0, tonumber(Value) or 0.22), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end
for _, Name in { "ToggleWindow", "TabSwitch", "Groupbox", "Dropdown", "KeyPicker" } do
    Apply["Anim_" .. Name] = function(Value)
        Library.Animations[Name] = Value == true
    end
end
function Apply.ModifiedDots(Value)
    Library.ShowModifiedDots = Value == true
end
function Apply.HelpPanel(Value)
    Library.HelpPanelEnabled = Value == true
    if not Value then
        Library:HideHelp()
    end
end
function Apply.TextScale(Value)
    Library:SetTextScale((tonumber(Value) or 100) / 100)
end
function Apply.ReducedMotion(Value)
    Library:SetReducedMotion(Value == true)
end
function Apply.IdleFade(Value)
    Library.IdleFade = math.clamp((tonumber(Value) or 0) / 100, 0, 0.85)
end
function Apply.DrawerMode(Value)
    Library:SetDrawer(Value == true)
end
function Apply.DrawerSide(Value)
    Library.DrawerSide = Value == "Right" and "Right" or "Left"
    if Library.DrawerMode then
        Library:SetDrawer(false)
        Library:SetDrawer(true)
    end
end
function Apply.AutoTheme(Value)
    Library.AutoThemeEnabled = Value == true
    Library:CheckAutoTheme(true)
end
function Apply.DayPreset(Value)
    Library.AutoThemeDay = tostring(Value)
    Library:CheckAutoTheme(true)
end
function Apply.NightPreset(Value)
    Library.AutoThemeNight = tostring(Value)
    Library:CheckAutoTheme(true)
end
function Apply.DayStart(Value)
    Library.AutoThemeDayStart = tonumber(Value) or 7
    Library:CheckAutoTheme(true)
end
function Apply.NightStart(Value)
    Library.AutoThemeNightStart = tonumber(Value) or 19
    Library:CheckAutoTheme(true)
end
function Apply.ToggleKey(Value)
    if typeof(Value) ~= "table" or typeof(Value.Key) ~= "string" then
        return
    end

    local Picker = Library.Options.CR_MenuKeybind
    if Picker then
        pcall(Picker.SetValue, Picker, { Value.Key, "Press", Value.Modifiers })
    elseif typeof(Library.ToggleKeybind) ~= "table" then
        local Success, Key = pcall(function()
            return Enum.KeyCode[Value.Key]
        end)
        if Success then
            Library.ToggleKeybind = Key
        end
    end
end

local function Snapshot()
    return {
        Version = 1,
        Theme = ThemeToTable(),
        CornerRadius = Library.CornerRadius,
        Library = Manager.Saved.Library,
        Layout = Manager.Saved.Layout,
    }
end

function Library:SaveLibrarySettings(Now: boolean?)
    if not Manager.Folder or Manager.Building then
        return
    end

    local function Write()
        EnsureFolders()
        WriteJson(Path("Library", "Config.json"), Snapshot())
    end

    if Now then
        Write()
        return
    end

    Manager.SaveToken += 1
    local Token = Manager.SaveToken
    task.delay(0.6, function()
        if Token == Manager.SaveToken and not Library.Unloaded then
            Write()
        end
    end)
end

function Library:ApplyLibrarySettings()
    if not Manager.Folder then
        return
    end

    local Saved = Manager.Saved
    local Was = Manager.Applying
    Manager.Applying = true

    if typeof(Saved.Theme) == "table" then
        Library:ApplyThemeTable(Saved.Theme)
    end
    if typeof(Saved.CornerRadius) == "number" and Library.Window then
        pcall(Library.Window.SetCornerRadius, Library.Window, Saved.CornerRadius)
    end
    for Key, Value in Saved.Library do
        local Function = Apply[Key]
        if Function then
            pcall(Function, Value)
        end
    end
    pcall(Library.CheckAutoTheme, Library, true)

    Manager.Applying = Was
end

function Library:SetFolder(Name: string)
    assert(typeof(Name) == "string" and Trim(Name) ~= "", "SetFolder expects the hub name")

    Manager.Folder = SafeName(Name)
    if Manager.Folder == "" then
        Manager.Folder = "CloudyHub"
    end
    EnsureFolders()

    local Data = ReadJson(Path("Library", "Config.json"))
    if typeof(Data) == "table" then
        Manager.Saved = {
            Theme = Data.Theme,
            CornerRadius = Data.CornerRadius,
            Library = typeof(Data.Library) == "table" and Data.Library or {},
            Layout = typeof(Data.Layout) == "table" and Data.Layout or nil,
        }
    else
        Manager.Saved = { Library = {} }
    end

    Library:ApplyLibrarySettings()
    if typeof(Data) ~= "table" then
        Library:SaveLibrarySettings(true)
    end

    if not FS.Supported then
        warn("[CloudyRevolution] This executor has no file functions, settings will not be saved.")
    end

    return Library
end

--// Hub configs (toggles / options) \\--
function Library:SetIgnoreIndexes(List: { string })
    for _, Idx in List do
        Manager.Ignore[Idx] = true
    end
end

local function IsIgnored(Idx): boolean
    return Manager.Ignore[Idx] == true or tostring(Idx):sub(1, 3) == "CR_"
end

local function SerializeConfig()
    local Data = { Toggles = {}, Options = {} }

    for Idx, Toggle in Library.Toggles do
        if not IsIgnored(Idx) then
            Data.Toggles[tostring(Idx)] = Toggle.Value
        end
    end

    for Idx, Option in Library.Options do
        if IsIgnored(Idx) then
            continue
        end

        local Serialized = Library:SerializeElement(Option)
        if Serialized then
            Data.Options[tostring(Idx)] = Serialized
        end
    end

    return Data
end

local function ApplyConfig(Data)
    for Idx, Value in Data.Toggles or {} do
        local Toggle = Library.Toggles[Idx]
        if Toggle and not IsIgnored(Idx) then
            pcall(Toggle.SetValue, Toggle, Value)
        end
    end

    for Idx, Saved in Data.Options or {} do
        local Option = Library.Options[Idx]
        if not Option or IsIgnored(Idx) or typeof(Saved) ~= "table" then
            continue
        end

        Library:ApplySerialized(Option, Saved)
    end
end

function Library:GetConfigList(): { string }
    return ListJson(Path("Configs"))
end

function Library:SaveConfig(Name: string): (boolean, string?)
    if not Manager.Folder then
        return false, "Call Library:SetFolder(\"HubName\") first"
    end

    Name = SafeName(Name)
    if Name == "" then
        return false, "Config name is empty"
    end

    EnsureFolders()
    local Data = SerializeConfig()
    local Success, Err = WriteJson(Path("Configs", Name .. ".json"), Data)
    if Success then
        Manager.CurrentConfig = Name
        Manager.LastSerialized = HttpService:JSONEncode(Data)
        if Manager.RefreshUI then
            Manager.RefreshUI()
        end
    end

    return Success, Err
end

function Library:LoadConfig(Name: string): (boolean, string?)
    if not Manager.Folder then
        return false, "Call Library:SetFolder(\"HubName\") first"
    end

    Name = SafeName(Name)
    local Data = ReadJson(Path("Configs", Name .. ".json"))
    if typeof(Data) ~= "table" then
        return false, "Config not found"
    end

    ApplyConfig(Data)
    Library:ResyncChangeLog()
    Manager.CurrentConfig = Name
    Manager.LastSerialized = HttpService:JSONEncode(SerializeConfig())
    if Manager.RefreshUI then
        Manager.RefreshUI()
    end

    return true
end

function Library:DeleteConfig(Name: string): (boolean, string?)
    if not Manager.Folder or not FS.CanDelete then
        return false, "Deleting files is not supported"
    end

    Name = SafeName(Name)
    local FilePath = Path("Configs", Name .. ".json")
    if not isfile(FilePath) then
        return false, "Config not found"
    end

    local Success, Err = pcall(delfile, FilePath)
    if Manager.CurrentConfig == Name then
        Manager.CurrentConfig = nil
    end
    if Manager.RefreshUI then
        Manager.RefreshUI()
    end

    return Success, if Success then nil else tostring(Err)
end

function Library:GetAutoload(): string?
    if not Manager.Folder or not FS.Supported then
        return nil
    end

    local FilePath = Path("Configs", "autoload.txt")
    local Success, Result = pcall(function()
        return isfile(FilePath) and readfile(FilePath) or nil
    end)
    if Success and typeof(Result) == "string" and Trim(Result) ~= "" then
        return Trim(Result)
    end

    return nil
end

function Library:SetAutoload(Name: string?): (boolean, string?)
    if not Manager.Folder or not FS.Supported then
        return false, "Call Library:SetFolder(\"HubName\") first"
    end

    local FilePath = Path("Configs", "autoload.txt")
    if Name == nil then
        if FS.CanDelete and isfile(FilePath) then
            pcall(delfile, FilePath)
        end
    else
        EnsureFolders()
        local Success, Err = pcall(writefile, FilePath, SafeName(Name))
        if not Success then
            return false, tostring(Err)
        end
    end

    if Manager.RefreshUI then
        Manager.RefreshUI()
    end
    return true
end

--// Call this at the end of your script, after every element exists \\--
function Library:LoadAutoloadConfig(): boolean
    pcall(Library.ApplyLayout, Library)

    local Name = Library:GetAutoload()
    if not Name then
        return false
    end

    local Success, Err = Library:LoadConfig(Name)
    if Success then
        Toast("Config", string.format("Autoloaded \"%s\"", Name))
    else
        Toast("Config", tostring(Err), "x")
    end

    return Success
end

--// Auto save of the loaded config (toggle in Settings > Config) \\--
task.spawn(function()
    while not Library.Unloaded do
        task.wait(5)
        if Manager.AutoSaveConfig and Manager.CurrentConfig and Manager.Folder then
            local Success, Encoded = pcall(function()
                return HttpService:JSONEncode(SerializeConfig())
            end)
            if Success and Encoded ~= Manager.LastSerialized then
                Library:SaveConfig(Manager.CurrentConfig)
            end
        end
    end
end)

--// Custom themes \\--
function Library:GetThemeList(): { string }
    return ListJson(Path("Library", "Themes"))
end

function Library:SaveTheme(Name: string): (boolean, string?)
    if not Manager.Folder then
        return false, "Call Library:SetFolder(\"HubName\") first"
    end

    Name = SafeName(Name)
    if Name == "" then
        return false, "Theme name is empty"
    end

    EnsureFolders()
    return WriteJson(Path("Library", "Themes", Name .. ".json"), ThemeToTable())
end

function Library:LoadTheme(Name: string): (boolean, string?)
    if not Manager.Folder then
        return false, "Call Library:SetFolder(\"HubName\") first"
    end

    local Data = ReadJson(Path("Library", "Themes", SafeName(Name) .. ".json"))
    if typeof(Data) ~= "table" then
        return false, "Theme not found"
    end

    Library:ApplyThemeTable(Data)
    Library:SaveLibrarySettings()
    return true
end

function Library:DeleteTheme(Name: string): (boolean, string?)
    if not Manager.Folder or not FS.CanDelete then
        return false, "Deleting files is not supported"
    end

    local FilePath = Path("Library", "Themes", SafeName(Name) .. ".json")
    if not isfile(FilePath) then
        return false, "Theme not found"
    end

    local Success, Err = pcall(delfile, FilePath)
    return Success, if Success then nil else tostring(Err)
end

--// ============================== Settings tab ============================== \\--
function Library:SetSettingTab(Tab)
    assert(typeof(Tab) == "table" and typeof(Tab.AddPage) == "function", "SetSettingTab expects a tab created with Window:AddTab")

    Library.SettingTab = Tab
    Manager.Building = true

    local Options, Toggles = Library.Options, Library.Toggles
    local Saved = Manager.Saved

    local function Current(Key: string, Fallback)
        local Value = Saved.Library[Key]
        if Value == nil then
            return Fallback
        end

        return Value
    end

    local function Commit(Key: string, Value)
        if Manager.Applying or Manager.Building then
            return
        end

        Saved.Library[Key] = Value
        local Function = Apply[Key]
        if Function then
            pcall(Function, Value)
        end
        Library:SaveLibrarySettings()
    end

    local function SavedNote(Box)
        if not Manager.Folder then
            Box:AddLabel("Settings are not saved yet. Call Library:SetFolder(\"HubName\") before SetSettingTab.", true)
        end
    end

    --// small builders \\--
    local function Switch(Box, Key: string, Text: string, Description: string?, Fallback: boolean)
        Box:AddToggle("CR_" .. Key, {
            Text = Text,
            Description = Description,
            Default = Current(Key, Fallback),
            Callback = function(Value)
                Commit(Key, Value)
            end,
        })
    end

    local function Choice(Box, Key: string, Text: string, Description: string?, Values, Fallback)
        Box:AddDropdown("CR_" .. Key, {
            Text = Text,
            Description = Description,
            Values = Values,
            Default = Current(Key, Fallback),
            Callback = function(Value)
                Commit(Key, Value)
            end,
        })
    end

    local function Slide(Box, Key: string, Text: string, Description: string?, Min: number, Max: number, Suffix: string?, Fallback: number)
        Box:AddSlider("CR_" .. Key, {
            Text = Text,
            Description = Description,
            Min = Min,
            Max = Max,
            Rounding = 0,
            Suffix = Suffix or "",
            Default = Current(Key, Fallback),
            Callback = function(Value)
                Commit(Key, Value)
            end,
        })
    end

    local ConfigPage = Tab:AddPage("Config")
    local ThemePage = Tab:AddPage("Theme")
    local LibraryPage = Tab:AddPage("Library")
    local ChangesPage = Tab:AddPage("Changes")

    --// ------------------------------------------------------------ CONFIG \\--
    do
        local Left = ConfigPage:AddGroupbox({ Name = "Configs", Side = "Left" })
        local Right = ConfigPage:AddGroupbox({ Name = "Autoload", Side = "Right" })

        local AutoloadLabel = Right:AddLabel("Autoload: none", true)
        local LoadedLabel = Right:AddLabel("Loaded config: none", true)
        local FolderLabel = Right:AddLabel(Manager.Folder and ("Folder: " .. Path("Configs")) or "Folder: not set (Library:SetFolder)", true)

        local function RefreshList()
            local Dropdown = Options.CR_ConfigList
            if Dropdown then
                Dropdown:SetValues(Library:GetConfigList())
            end
        end

        Manager.RefreshUI = function()
            AutoloadLabel:SetText("Autoload: " .. (Library:GetAutoload() or "none"))
            LoadedLabel:SetText("Loaded config: " .. (Manager.CurrentConfig or "none"))
            RefreshList()
        end

        local function Selected(): string?
            local Value = Options.CR_ConfigList.Value
            if typeof(Value) == "string" and Value ~= "" then
                return Value
            end

            Toast("Config", "Select a config from the list first", "x")
            return nil
        end

        Left:AddInput("CR_ConfigName", { Text = "Config name", Placeholder = "my config" })
        Left:AddDropdown("CR_ConfigList", {
            Text = "Config list",
            Values = Library:GetConfigList(),
            AllowNull = true,
            Searchable = true,
        })

        local Create = Left:AddButton({
            Text = "Create config",
            Func = function()
                local Name = Options.CR_ConfigName.Value
                local Success, Err = Library:SaveConfig(Name)
                if Success then
                    Toast("Config", string.format("Created \"%s\"", SafeName(Name)))
                    RefreshList()
                    Options.CR_ConfigList:SetValue(SafeName(Name))
                else
                    Toast("Config", tostring(Err), "x")
                end
            end,
        })
        Create:AddButton({ Text = "Refresh", Func = RefreshList })

        local LoadButton = Left:AddButton({
            Text = "Load config",
            Func = function()
                local Name = Selected()
                if not Name then
                    return
                end

                local Success, Err = Library:LoadConfig(Name)
                Toast("Config", Success and string.format("Loaded \"%s\"", Name) or tostring(Err), Success and "check" or "x")
            end,
        })
        LoadButton:AddButton({
            Text = "Overwrite",
            DoubleClick = true,
            Func = function()
                local Name = Selected()
                if not Name then
                    return
                end

                local Success, Err = Library:SaveConfig(Name)
                Toast("Config", Success and string.format("Overwrote \"%s\"", Name) or tostring(Err), Success and "check" or "x")
            end,
        })

        Left:AddButton({
            Text = "Delete config",
            Risky = true,
            DoubleClick = true,
            Func = function()
                local Name = Selected()
                if not Name then
                    return
                end

                local Success, Err = Library:DeleteConfig(Name)
                Toast("Config", Success and string.format("Deleted \"%s\"", Name) or tostring(Err), Success and "check" or "x")
                Options.CR_ConfigList:SetValue(nil)
            end,
        })

        local Auto = Right:AddButton({
            Text = "Set as autoload",
            Func = function()
                local Name = Selected()
                if not Name then
                    return
                end

                local Success, Err = Library:SetAutoload(Name)
                Toast("Config", Success and string.format("\"%s\" will load on start", Name) or tostring(Err), Success and "check" or "x")
            end,
        })
        Auto:AddButton({
            Text = "Reset",
            Func = function()
                Library:SetAutoload(nil)
                Toast("Config", "Autoload cleared")
            end,
        })

        Right:AddToggle("CR_AutoSaveConfig", {
            Text = "Auto save loaded config",
            Description = "Saves the loaded config every few seconds when something changed",
            Default = false,
            Callback = function(Value)
                Manager.AutoSaveConfig = Value
            end,
        })

        if typeof(setclipboard) == "function" then
            Right:AddButton({
                Text = "Copy config JSON",
                Func = function()
                    setclipboard(HttpService:JSONEncode(SerializeConfig()))
                    Toast("Config", "Copied to clipboard")
                end,
            })
        end

        SavedNote(Right)
        Manager.RefreshUI()
        local _ = FolderLabel
    end

    --// ------------------------------------------------------------ THEME \\--
    do
        local Presets = ThemePage:AddGroupbox({ Name = "Presets", Side = "Left" })
        local Custom = ThemePage:AddGroupbox({ Name = "Custom themes", Side = "Left" })
        local Colors = ThemePage:AddGroupbox({ Name = "Colors", Side = "Right" })

        local function CommitTheme()
            if Manager.Applying or Manager.Building then
                return
            end

            Library:SaveLibrarySettings()
        end

        Presets:AddDropdown("CR_ThemePreset", {
            Text = "Preset",
            Description = "Applies all colors at once",
            Values = ThemePresetOrder,
            AllowNull = true,
            Callback = function(Value)
                if Manager.Applying or Manager.Building or not ThemePresets[Value] then
                    return
                end

                Library:ApplyThemeTable(PresetToTheme(Value))
                CommitTheme()
            end,
        })

        Presets:AddDropdown("CR_Font", {
            Text = "Font",
            Description = "Applies to every text in the UI",
            Values = FontNames,
            Default = Library.CurrentFontName or "Cloudy",
            Searchable = true,
            Callback = function(Value)
                if Manager.Applying or Manager.Building then
                    return
                end

                ApplyFontByName(Value)
                CommitTheme()
            end,
        })

        Presets:AddSlider("CR_CornerRadius", {
            Text = "Corner radius",
            Description = "Roundness of windows, groupboxes and cards",
            Min = 0,
            Max = 36,
            Default = Library.CornerRadius,
            Rounding = 0,
            Callback = function(Value)
                if Manager.Applying or Manager.Building or not Library.Window then
                    return
                end

                Library.Window:SetCornerRadius(Value)
                CommitTheme()
            end,
        })

        for _, Key in ThemeKeys do
            Colors:AddLabel(ThemeLabels[Key]):AddColorPicker("CR_Color_" .. Key, {
                Default = Library.Scheme[Key],
                Callback = function(Color)
                    if Manager.Applying or Manager.Building then
                        return
                    end

                    Library.Scheme[Key] = Color
                    Library:UpdateColorsUsingRegistry()
                    CommitTheme()
                end,
            })
        end

        Colors:AddButton({
            Text = "Reset to Cloudy",
            DoubleClick = true,
            Func = function()
                Library:ApplyThemeTable(PresetToTheme("Cloudy"))
                ApplyFontByName("Cloudy")
                if Options.CR_Font then
                    Options.CR_Font:SetValue("Cloudy")
                end
                CommitTheme()
            end,
        })

        --// contrast checker + time based theme \\--
        local Schedule = ThemePage:AddGroupbox({ Name = "Contrast & schedule", Side = "Right" })

        local ContrastLabel = Schedule:AddLabel("", true)
        local AccentLabel = Schedule:AddLabel("", true)
        local LastContrast = ""
        local function RefreshContrast()
            local Text = Library:GetContrast(Library.Scheme.FontColor, Library.Scheme.BackgroundColor)
            local Accent = Library:GetContrast(Library.Scheme.AccentColor, Library.Scheme.BackgroundColor)
            local Joined = string.format(
                "Text on background: %.1f : 1 (%s)\nAccent on background: %.1f : 1 (%s)",
                Text, Library:DescribeContrast(Text), Accent, Library:DescribeContrast(Accent)
            )
            if Joined ~= LastContrast then
                LastContrast = Joined
                local First, Second = Joined:match("^(.-)\n(.*)$")
                ContrastLabel:SetText(First)
                AccentLabel:SetText(Second)
            end
        end
        RefreshContrast()
        Library:AddTick(0.6, RefreshContrast)

        Schedule:AddButton({
            Text = "Fix text color",
            Func = function()
                local Color = Library:GetReadableTextColor(Library.Scheme.BackgroundColor)
                Library.Scheme.FontColor = Color
                Library:UpdateColorsUsingRegistry()

                local Picker = Options.CR_Color_FontColor
                if Picker then
                    local Was = Manager.Applying
                    Manager.Applying = true
                    pcall(Picker.SetValueRGB, Picker, Color)
                    Manager.Applying = Was
                end
                CommitTheme()
                RefreshContrast()
            end,
        })

        Switch(Schedule, "AutoTheme", "Change theme by time", "Day and night presets switch automatically by your local time", LibraryDefaults.AutoTheme)
        Choice(Schedule, "DayPreset", "Day preset", nil, ThemePresetOrder, LibraryDefaults.DayPreset)
        Choice(Schedule, "NightPreset", "Night preset", nil, ThemePresetOrder, LibraryDefaults.NightPreset)
        Slide(Schedule, "DayStart", "Day starts", nil, 0, 23, ":00", LibraryDefaults.DayStart)
        Slide(Schedule, "NightStart", "Night starts", nil, 0, 23, ":00", LibraryDefaults.NightStart)

        --// custom themes \\--
        local function RefreshThemes()
            local Dropdown = Options.CR_ThemeList
            if Dropdown then
                Dropdown:SetValues(Library:GetThemeList())
            end
        end

        local function SelectedTheme(): string?
            local Value = Options.CR_ThemeList.Value
            if typeof(Value) == "string" and Value ~= "" then
                return Value
            end

            Toast("Theme", "Select a theme from the list first", "x")
            return nil
        end

        Custom:AddInput("CR_ThemeName", { Text = "Theme name", Placeholder = "my theme" })
        Custom:AddDropdown("CR_ThemeList", {
            Text = "Saved themes",
            Values = Library:GetThemeList(),
            AllowNull = true,
            Searchable = true,
        })

        local SaveTheme = Custom:AddButton({
            Text = "Save theme",
            Func = function()
                local Name = Options.CR_ThemeName.Value
                local Success, Err = Library:SaveTheme(Name)
                Toast("Theme", Success and string.format("Saved \"%s\"", SafeName(Name)) or tostring(Err), Success and "check" or "x")
                if Success then
                    RefreshThemes()
                    Options.CR_ThemeList:SetValue(SafeName(Name))
                end
            end,
        })
        SaveTheme:AddButton({ Text = "Refresh", Func = RefreshThemes })

        local LoadTheme = Custom:AddButton({
            Text = "Load theme",
            Func = function()
                local Name = SelectedTheme()
                if not Name then
                    return
                end

                local Success, Err = Library:LoadTheme(Name)
                Toast("Theme", Success and string.format("Loaded \"%s\"", Name) or tostring(Err), Success and "check" or "x")
            end,
        })
        LoadTheme:AddButton({
            Text = "Delete",
            Risky = true,
            DoubleClick = true,
            Func = function()
                local Name = SelectedTheme()
                if not Name then
                    return
                end

                local Success, Err = Library:DeleteTheme(Name)
                Toast("Theme", Success and string.format("Deleted \"%s\"", Name) or tostring(Err), Success and "check" or "x")
                RefreshThemes()
                Options.CR_ThemeList:SetValue(nil)
            end,
        })

        if typeof(setclipboard) == "function" then
            Custom:AddButton({
                Text = "Copy theme JSON",
                Func = function()
                    setclipboard(HttpService:JSONEncode(ThemeToTable()))
                    Toast("Theme", "Copied to clipboard")
                end,
            })
        end

        Custom:AddInput("CR_ThemeImport", {
            Text = "Import theme JSON",
            Description = "Paste a theme and press enter",
            Finished = true,
            Callback = function(Value)
                if Manager.Applying or Manager.Building or Trim(Value) == "" or Value == "---" then
                    return
                end

                local Success, Data = pcall(function()
                    return HttpService:JSONDecode(Value)
                end)
                if Success and typeof(Data) == "table" then
                    Library:ApplyThemeTable(Data)
                    CommitTheme()
                    Toast("Theme", "Imported theme")
                else
                    Toast("Theme", "That is not valid theme JSON", "x")
                end
            end,
        })

        SavedNote(Custom)
    end

    --// ------------------------------------------------------------ LIBRARY \\--
    do
        local Window = LibraryPage:AddGroupbox({ Name = "Window", Side = "Left" })
        local Notifications = LibraryPage:AddGroupbox({ Name = "Notifications", Side = "Left" })
        local Interface = LibraryPage:AddGroupbox({ Name = "Interface", Side = "Right" })
        local Animations = LibraryPage:AddGroupbox({ Name = "Animations", Side = "Right" })
        local About = LibraryPage:AddGroupbox({ Name = "Library", Side = "Right" })

        --// menu keybind \\--
        local DefaultKey = "RightControl"
        if typeof(Library.ToggleKeybind) == "EnumItem" then
            DefaultKey = Library.ToggleKeybind.Name
        end
        local SavedKey = Saved.Library.ToggleKey
        if typeof(SavedKey) == "table" and typeof(SavedKey.Key) == "string" then
            DefaultKey = SavedKey.Key
        end

        Window:AddLabel("Menu keybind"):AddKeyPicker("CR_MenuKeybind", {
            Default = DefaultKey,
            DefaultModifiers = typeof(SavedKey) == "table" and SavedKey.Modifiers or {},
            Mode = "Press",
            NoUI = true,
            Text = "Menu keybind",
            ChangedCallback = function()
                local Picker = Options.CR_MenuKeybind
                if Picker then
                    Commit("ToggleKey", { Key = Picker.Value, Modifiers = Picker.Modifiers })
                end
            end,
        })
        Library.ToggleKeybind = Options.CR_MenuKeybind

        Choice(Window, "DPIScale", "UI scale", "Scales the whole interface", { "50%", "75%", "90%", "100%", "110%", "125%", "150%", "175%", "200%" }, tostring(tonumber((tostring(Current("DPIScale", 100)):gsub("%%", ""))) or 100) .. "%")
        Switch(Window, "Snapping", "Window snapping", "Snaps the window to screen edges while dragging", LibraryDefaults.Snapping)
        Switch(Window, "AlwaysOnTop", "Always on top", "Draw above other core UI", LibraryDefaults.AlwaysOnTop)
        Switch(Window, "SidebarCompact", "Compact sidebar", "Icons only", LibraryDefaults.SidebarCompact)
        Window:AddInput("CR_BackgroundImage", {
            Text = "Background image",
            Description = "Asset id, rbxassetid:// or image url",
            Default = tostring(Current("BackgroundImage", "")),
            Finished = true,
            Callback = function(Value)
                if Value == "---" then
                    Value = ""
                end
                Commit("BackgroundImage", Value)
            end,
        })

        Choice(Notifications, "NotifySide", "Notification side", nil, { "Left", "Right" }, Library.NotifySide or "Right")
        Switch(Notifications, "NotifyOnError", "Notify on error", "Show script errors from callbacks as notifications", LibraryDefaults.NotifyOnError)
        Notifications:AddButton({
            Text = "Test notification",
            Func = function()
                Library:Notify({ Title = "Cloudy Revolution", Description = "This is a test notification", Time = 4, Icon = "bell" })
            end,
        })

        Switch(Interface, "ElementGlow", "Element glow", "Soft shadow behind element cards", LibraryDefaults.ElementGlow)
        Switch(Interface, "AmbientGlow", "Ambient light", "Faint accent glow at the top of the window", LibraryDefaults.AmbientGlow)
        Switch(Interface, "ShowCustomCursor", "Custom cursor", "Draw a crosshair instead of the system cursor", LibraryDefaults.ShowCustomCursor)
        Switch(Interface, "ShowKeybindList", "Keybind list", "Floating list of active keybinds", LibraryDefaults.ShowKeybindList)
        Switch(Interface, "ShowToggleFrameInKeybinds", "Keybind checkboxes", "Show toggle checkboxes in the keybind list", LibraryDefaults.ShowToggleFrameInKeybinds)

        Switch(Animations, "Anim_ToggleWindow", "Window fade", "Fade when opening and closing", LibraryDefaults.Anim_ToggleWindow)
        Switch(Animations, "Anim_TabSwitch", "Tab transition", "Slide when switching tabs", LibraryDefaults.Anim_TabSwitch)
        Switch(Animations, "Anim_Groupbox", "Groupbox animation", "Animate collapsing and resizing", LibraryDefaults.Anim_Groupbox)
        Switch(Animations, "Anim_Dropdown", "Dropdown animation", nil, LibraryDefaults.Anim_Dropdown)
        Switch(Animations, "Anim_KeyPicker", "Keypicker animation", nil, LibraryDefaults.Anim_KeyPicker)
        Choice(Animations, "TabSwipeFrom", "Tab swipe from", nil, { "bottom", "top", "left", "right", "auto" }, string.lower(Library.TabSwipeFrom or "bottom"))
        Animations:AddSlider("CR_TabTransitionTime", {
            Text = "Tab transition time",
            Min = 0.05,
            Max = 1,
            Rounding = 2,
            Suffix = "s",
            Default = Current("TabTransitionTime", LibraryDefaults.TabTransitionTime),
            Callback = function(Value)
                Commit("TabTransitionTime", Value)
            end,
        })

        local Access = LibraryPage:AddGroupbox({ Name = "Accessibility & help", Side = "Left" })
        local Modes = LibraryPage:AddGroupbox({ Name = "Window modes", Side = "Left" })

        Slide(Access, "TextScale", "Text size", "Scales all text (80 - 130%)", 80, 130, "%", LibraryDefaults.TextScale)
        Switch(Access, "ReducedMotion", "Reduced motion", "Turns off tweens, glows and gradients", LibraryDefaults.ReducedMotion)
        Switch(Access, "ModifiedDots", "Modified dots", "A small dot marks settings that differ from their default", LibraryDefaults.ModifiedDots)
        Switch(Access, "HelpPanel", "Help panel", "Hover a setting to see its longer description and hints", LibraryDefaults.HelpPanel)
        Access:AddButton({
            Text = "Replay tour",
            Func = function()
                Library:StartTour()
            end,
        })

        Switch(Modes, "DrawerMode", "Drawer mode", "Dock the window to a screen edge, it slides out when you touch the edge", LibraryDefaults.DrawerMode)
        Choice(Modes, "DrawerSide", "Drawer side", nil, { "Left", "Right" }, LibraryDefaults.DrawerSide)
        Slide(Modes, "IdleFade", "Idle fade", "Fade the window when the mouse is away (0 = off)", 0, 80, "%", LibraryDefaults.IdleFade)
        Modes:AddToggle("CR_LayoutEdit", {
            Text = "Edit layout",
            Description = "Shows arrows on groupboxes so you can move them. The layout is saved.",
            Default = false,
            Callback = function(Value)
                Library:SetLayoutEdit(Value)
            end,
        })
        local ModeButtons = Modes:AddButton({
            Text = "Minimize to orb",
            Func = function()
                Library:Minimize()
            end,
        })
        ModeButtons:AddButton({
            Text = "Close split view",
            Func = function()
                Library:SetSplit(nil)
            end,
        })
        Modes:AddButton({
            Text = "Reset layout",
            DoubleClick = true,
            Func = function()
                Manager.Saved.Layout = nil
                Library:SaveLibrarySettings(true)
                Toast("Layout", "Saved layout cleared. Reload the script to see the default layout.")
            end,
        })

        About:AddLabel(string.format("%s %s", Library.Name or "Cloudy Revolution", Library.Version or ""), true)
        About:AddButton({
            Text = "Save settings now",
            Func = function()
                Library:SaveLibrarySettings(true)
                Toast("Library", Manager.Folder and "Saved library settings" or "Set a folder first (Library:SetFolder)", Manager.Folder and "check" or "x")
            end,
        })
        About:AddButton({
            Text = "Reset library settings",
            Risky = true,
            DoubleClick = true,
            Func = function()
                Manager.Applying = true
                table.clear(Saved.Library)
                for Key, Value in LibraryDefaults do
                    local Function = Apply[Key]
                    if Function then
                        pcall(Function, Value)
                    end

                    local Id = "CR_" .. Key
                    if Toggles[Id] then
                        Toggles[Id]:SetValue(Value)
                    elseif Options[Id] then
                        Options[Id]:SetValue(Key == "DPIScale" and (tostring(Value) .. "%") or Value)
                    end
                end
                Manager.Applying = false

                Library:SaveLibrarySettings(true)
                Toast("Library", "Library settings were reset")
            end,
        })
        About:AddButton({
            Text = "Unload",
            Risky = true,
            DoubleClick = true,
            Func = function()
                Library:Unload()
            end,
        })
    end

    --// ------------------------------------------------------------ CHANGES \\--
    do
        local Box = ChangesPage:AddGroupbox({ Name = "Recent changes", Side = "Full" })
        local Items = {}

        local function Refresh()
            for _, Item in Items do
                pcall(Item.Destroy, Item)
            end
            table.clear(Items)

            if #Library.ChangeLog == 0 then
                table.insert(Items, Box:AddLabel("Nothing changed yet. The last 15 changes you make show up here.", true))
                return
            end

            for _, Entry in Library.ChangeLog do
                local Text = string.format("%s: %s  >  %s", Entry.Text, Library:DescribeValue(Entry.Old), Library:DescribeValue(Entry.New))
                if #Text > 64 then
                    Text = string.sub(Text, 1, 61) .. "..."
                end

                local Button = Box:AddButton({ Text = Text, Func = function() end })
                Button:AddButton({
                    Text = "Revert",
                    Func = function()
                        if Library:RevertChange(Entry) then
                            Toast("Reverted", Entry.Text)
                        end
                    end,
                })
                table.insert(Items, Button)
            end
        end

        Box:AddButton({
            Text = "Clear list",
            Func = function()
                table.clear(Library.ChangeLog)
                Refresh()
            end,
        })

        Library.OnChangeLog = function()
            task.defer(Refresh)
        end
        Refresh()
    end

    Manager.Building = false

    Library:ApplyLibrarySettings()
    if Manager.Folder then
        Library:SaveLibrarySettings()
    end

    task.delay(1, function()
        if not Library.Unloaded then
            pcall(Library.ApplyLayout, Library)
        end
    end)

    --// first run tour \--
    if Manager.Folder and Library.AutoTour ~= false and not Saved.Library.TourDone then
        task.delay(1.5, function()
            if not Library.Unloaded and not Library.TourActive then
                Library:StartTour()
            end
        end)
    end

    return Tab
end

function Library:Unload()
    if Library.Manager and Library.Manager.Folder then
        pcall(Library.SaveLibrarySettings, Library, true)
        if Library.Manager.AutoSaveConfig and Library.Manager.CurrentConfig then
            pcall(Library.SaveConfig, Library, Library.Manager.CurrentConfig)
        end
    end

    Library.Unloaded = true

    --// Disconnect connections
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)

        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    --// Run Unload Callbacks
    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)

        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    --// Destroy elements
    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)

        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)

        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    --// Clear tables
    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.ContextMenus)

    table.clear(Library.Notifications)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)

    table.clear(TransparencyCache)
    table.clear(ActiveTabTweens)

    Library.Toggle = function(...) end
    Library.ScreenGui = nil
    Library.Floats = nil
    Library.Overlay = nil
    Library.WindowContainer = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil

    getgenv().Library = nil
    getgenv().CloudyRevolution = nil
end

getgenv().Library = Library
getgenv().CloudyRevolution = Library
return Library
