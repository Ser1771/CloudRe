local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {
    Version = "1.0.0",
    Name = "Cloudy Revolution",
    Unloaded = false,
    Signals = {},
    Elements = {},
    Scheme = {
        Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        FontBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        BG = Color3.fromRGB(10, 10, 12),
        Side = Color3.fromRGB(18, 18, 20),
        Card = Color3.fromRGB(20, 20, 23),
        Nested = Color3.fromRGB(24, 24, 28),
        Control = Color3.fromRGB(30, 30, 35),
        ControlHover = Color3.fromRGB(40, 40, 47),
        Hover = Color3.fromRGB(27, 27, 31),
        Active = Color3.fromRGB(31, 31, 36),
        Track = Color3.fromRGB(35, 35, 41),
        Popup = Color3.fromRGB(22, 22, 25),
        Outline = Color3.fromRGB(40, 40, 46),
        Text = Color3.fromRGB(244, 244, 246),
        SubText = Color3.fromRGB(138, 138, 146),
        Accent = Color3.fromRGB(78, 140, 255),
        AccentText = Color3.fromRGB(255, 255, 255),
        Red = Color3.fromRGB(255, 90, 82),
    },
    TweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    PopTween = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

local IconsRegistry = (function()
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
	local BASE_PATH = "molto-icons"

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
local PROVIDERS = {lucide={Hash="11d446c12405c3dcce9fcea63ca304378f0d002569c5be7431c2e946a896dd2c",FontSources={"3023058e0624db67b242be8259ad1c8bfd0baa25d2bc265496ab3f6e0cf6cbb2","d24060429c26965c0563eef73818ee939817e32cea5a8d60a3ce7f909b0f2572"},Font=true,Name="Lucide",SourceHash="0673c282baccf4ddd27b6aa413923e9004db064b696b5afb0a7e3952dbd22431",Sheets=2,License="ISC",Count=2095,FontParts=2},tabler={Hash="de0041ef23f9edba3c95e9f20f46d1a3c839d6f610a83bdcf44abd7229542e98",FontSources={"8195e5c93fd7bbd4d9d15fe17e9b26efe44cf0a33ea7eea07694dbd8037c7a0b","23456f6370d7fc077370c06c85d802c4768f21bfe70bb5b91f6a4dfea07aa8be","83da31ec40d824567641f78f70d30a1ad17c7bbb166139fc3a765ffcd2d09ef5","4c99944f07a6b2ecb43bbbda5b13550e0361a7ea38383135cc30893f9d27b0e8","8ce861237f45de04305a899db3cd95e292e6b097a4f7fa1d1fd7849701d30776"},Font=true,Name="Tabler",SourceHash="5b51978591ea66f6688a93bd24e3da217e722fc4b467d2027d0ed6ebcefca7ac",Sheets=4,License="MIT",Count=6305,FontParts=5},heroicons={Hash="da3ef30e5bda1a0cf6586a6de9789a12537d550aec9598eccc85b4326be76615",FontSources={"da02a3a8e3f2b01840e735d0025f9c898a597fa3f22802b8cf61fba7ca4dd065","1a0ce866418752177d2393a48aede97f27ba5c52239eab5e3b7a9b0de15e6c44"},Font=true,Count=1288,SourceHash="6439652a852d969b2916cffd09efb0ab9a6f2127b7b7692b7b0e48315b4b8029",Sheets=1,License="MIT",Name="Heroicons",FontParts=2},solar={Hash="01d27f4a6f5ef2740f7080fb66f89fdaca0682cff34776dd71342aed31c4788b",FontSources={"0fbc79d272ced0ecc7e9b4357c8d89c5fc58681d491c9af67cb7c16aa98db15d","c60573fba17a7a8493d8385cd2f63f5c6c2509b780a93ae358d42fdc4d724c42","9b645fa22ab9a6f9ff56f7bba9fcde3d6a9b85d09ccbd71a95e31914c636a51d","95f3976e92db9a2478efcc5629b8aec2693e33b17276ce8aa068055a1f33a08b","e12f62e3ef20c62d3a7735e915199dbc3baffbdb958c09ab24bfb1d04177ec2d","414dd9aa75fbfc2005138857544df5febe4a55e5b670d2303f2034f27e701426"},Font=true,Count=8859,SourceHash="bc5184a9d553589aad59d3375558bd13e4af5bb176dea7c89a164eabf9ee28c7",Sheets=6,License="CC BY 4.0",Name="Solar",FontParts=6},material={Hash="993be4ca36fcb877522411e30786f8fe60cfeef65173a101598a645d16767af7",FontSources={"4425cbbe00b48122e9526f66347f67b5b12e6d7f8ff320165e3f324f4c194866","c7f31caaeda57199e15b94e6a03f5b7cfc365c0fe7bd4b594d4318331df15979","874ea19f7ff611beac8077cc98bbadda90a52b374b7d3c3dc12017687cf94555","e8d6e6babc6a12e7a0d703e5df813b1f3a965359af60e3a8b3673b3289b08f77","7e80c00e76d77336e4ea67d5332d4c1e21c3e79cd48771373c04a877e2a47c79","e2bb326dab6eae516f3491c16ac606c97a50b91e40797cf24c83bc9289a0d490","8ea19612bbf24de04ee358b146c3af61ede6f1db11fd25536d73022a602631ca","472eb72acf8b80a5ee2998c01afa09d8ac5b4ad7cb8f82efd6a00aa4660d35e1","86792e6a3acd6c5aa294e30fe9f90665fa0d137d85b96091fee8ea2c1490214b","6e3b6507c9895272fe2dd1f073135bcc838e603a7afaeb2ec8332841e6a581ff","087bb1f361a113f7e3ec3118ce6f29d20b9ac5545b708c185469550fa64ac0b5","ed40ff0d0763f205a17f95fa83bec8d0a1f92aef4119f992b95a94d9050a8b26","ec71dd27d9ea3a6fd4ff488a80396328adf2c2d8f396413ce1139160defb4dfc","41e3b748421a606578891a7ecb98317777e35f7b6853e6c5e1fc7fa2fa86ed8b","c754424a1b589b740315af67f52d6f6aa1b348de97a98c8e5ccb28734b747db2","4bc3e346d9d5b1c458c5af99ba7788bbad15f15b81d551b4eba94bcb290861a7","02bf85a05bab64c5be4cf63f8ae414677027f1328fa1d74ae97ebb21163195a3"},Font=true,Name="Material Symbols",SourceHash="23bd4f231d978101790ad3bcd3e3b2eb9718b214f012b30fe1639dab1043d2b9",Sheets=11,License="Apache 2.0",Count=16475,FontParts=17},fluent={Hash="1d72f6702e4bbbf7d7b728f29f2b1d3f7f462b9aeebc112e07d1114ec7e28c9c",FontSources={"21e91032f8e038d016f28f07777f63d6acfb3cfd9a211a058a4473a24bdd060a","1d599093d1ce85121c282c4454290c7e863931e6673a33619a40d916f76ff8b0","8ae582404698799f654cf5a8aea1e609cd37a7600ca0e50519ed97254e02118d","954a0c5bd84593dbda577b5923d7fe86d21c25e41dd91e484c67bcc947fa1640","65a2b5ebc82089e9fc844bd54b03eb41a0c29b004c11900b4642f203ee0bd375","d3a65ae7af734d04cd01551bdaa66330df361b2999098072e9b4ff89c7c1a21d","425c8e47320bbc9b5916c1a645161bd982bfe1802d75d0b4c5a513c817194ef4","0b3b52b1e78ee3abbbf56bf8008b6247759e06a2b4aa843e00706bbc72b9b6d0","72f047c4e16688c5e167bb2fadf6dd95e6243fdb42017a6f65befef455987e4e","459b54e519f643aac8b4febc20ebce816f51299ea8b59ed881efdda46f97b8cf","e7c714f383b1811cb98ca9a4bfbe56587b66a01a34f16ebe31de50df891193d8","2ddf3f8f91a16e12931ade6fb05cc8e43a94866b11c6a9e18d0f65ea588ecd51","30361480085c950d0527fdebb2aa5e1aa90fe2f7343cbeeefd6047276a7b3ab0","8e0dd7a0d33cea2f1be2cbd59c69ed448edadc73e51dc939f50b0f6c84e7851f","e9b9536d31780948ef6e23cc12dea33c0f8b9dcecbaa5eb7239be46e7d7ed80e","fb65b8f1a477e93dceac67dd94cf4c0913b7f7971e91dcfd1ad739cb5a1cfcfc","bf3a54cc315d9dc1d7ddfec645176b01f3db35ddfdf3235d14a6ca7412e44e95","aa3975d48720a3e94e6e538465043f25fd5d54beeeb185a0712a1b1bd87806dc","22137120ac5aca616b37183abdc5a79664b22bb643b4be04a84f0a61e3c8653c","8a933e73735d254c8c86da88197db4ec8424ff32831b3c54a62bd21c8b7dc549","7755a8ed4934ec2d3897eb3457c3b751693ac111ca0d2a0d05474dd361ad7865","d87e8a1715675f01ad8046be1a87ea872c3f2f2bbe913cbaa64924cbee90e46d","f708be381ac72be1f5264588bfe45c1eb15cb167d5d0c9a3af64a42a1ae4bb6c","e1cbf6386abf84c7e3fe3506b5453d92792d31511578b91680bcef6ef772bb57","ba930236f8c2e606bee57ece25e83cbe1e9a49136e9e1fad0871c22d2ca60c47"},Font=true,Name="Fluent UI",SourceHash="aefd29a983af7e178aa22261a9dc424bd5dbfa19680d2dc163a46f34997796de",Sheets=13,License="MIT",Count=20334,FontParts=25},phosphor={Hash="3a5e9b8ed33e68efb30de3f96814cb55320b7d7579fa375e29cf2f9fcea4d371",FontSources={"e8c24227843917e3fc9290d8bf203705de7f4a59485d07f9401cea9d4fc3d1c9","616bc7cf12efd96cffe2ea91298d2a928e6e0a508a233ec887c97cbc9c4395bb","53f51b226944327ba01306717fe829cec5d638f4d1179b4f121af355330399d7","a4d996e7818c0514d1d1f5f068b33de5667c7c735b88414276686b29128cc829","a2c1f74720b1a04cb699b54cb3938fc81643bb7d036147753ea130ea70019bb4","32b4ec07d36dee3d04585246dbb3c82f3c178a1229cc6179827ca15fe3922776","e5c39571e65797199d631dd71df13f9ac935c784eb7f3c2abd8f3d0f58c2ff75"},Font=true,Count=9161,SourceHash="841b552595d27509a630dadd2bc5a04fc0b30e724e3b42f6f2807ef7628fd415",Sheets=6,License="MIT",Name="Phosphor",FontParts=7}}

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
					return data:sub(1, 8) == "\137PNG\r\n\26\n"
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

local function FontPartOf(name: string, parts: number): number
	local hash = 7
	for index = 1, #name do
		hash = (hash * 131 + string.byte(name, index)) % 2147483629
	end
	return hash % parts + 1
end

local function LigatureOf(name: string): string
	return if name:match("^%d") then `x-{name}` else name
end

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
				return data:sub(1, 4) == "\0\1\0\0"
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

--// API \--
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
end)()

local Templ = {
    Frame = { BorderSizePixel = 0 },
    TextLabel = { BorderSizePixel = 0, BackgroundTransparency = 1, FontFace = "Font", RichText = true, TextColor3 = "Text", TextSize = 13 },
    TextButton = { AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1, FontFace = "Font", RichText = true, TextColor3 = "Text", TextSize = 13, Text = "" },
    TextBox = { BorderSizePixel = 0, FontFace = "Font", RichText = false, TextColor3 = "Text", TextSize = 13, ClearTextOnFocus = false },
    ImageLabel = { BorderSizePixel = 0, BackgroundTransparency = 1, BackgroundColor3 = Color3.new(0, 0, 0) },
    ScrollingFrame = { BorderSizePixel = 0, BackgroundTransparency = 1, ScrollBarThickness = 0 },
}

local function Resolve(Prop, Value)
    if typeof(Value) == "string" and (Prop == "FontFace" or Prop:find("Color")) and Library.Scheme[Value] ~= nil then
        return Library.Scheme[Value], true
    elseif typeof(Value) == "function" then
        return Value(), true
    end
    return Value, false
end

local function Fill(Inst, Props)
    for K, V in Props do
        if K ~= "Parent" then
            Inst[K] = (Resolve(K, V))
        end
    end
end

local function New(Class, Props)
    local Inst = Instance.new(Class)
    if Templ[Class] then Fill(Inst, Templ[Class]) end
    Fill(Inst, Props)
    if Props and Props.Parent then Inst.Parent = Props.Parent end
    return Inst
end

local function Tween(Object, Props, Info)
    local P = {}
    for K, V in Props do P[K] = (Resolve(K, V)) end
    local T = TweenService:Create(Object, Info or Library.TweenInfo, P)
    T:Play()
    return T
end

local function Anim(Object, Props, Instant)
    if Instant then
        for K, V in Props do
            Object[K] = (Resolve(K, V))
        end
    else
        Tween(Object, Props)
    end
end

local function Corner(Parent, R)
    return New("UICorner", { CornerRadius = UDim.new(0, R), Parent = Parent })
end

local function Stroke(Parent, Color, Thickness, Transparency)
    return New("UIStroke", {
        Color = Color or "Outline", Thickness = Thickness or 1, Transparency = Transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Parent,
    })
end

local function Pad(Parent, T, R, B, L)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, T or 0), PaddingRight = UDim.new(0, R or 0),
        PaddingBottom = UDim.new(0, B or 0), PaddingLeft = UDim.new(0, L or 0), Parent = Parent,
    })
end

local function List(Parent, Padding, Dir, HA, VA)
    return New("UIListLayout", {
        Padding = UDim.new(0, Padding or 0), FillDirection = Dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = HA or Enum.HorizontalAlignment.Left, VerticalAlignment = VA or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = Parent,
    })
end

local function IsPress(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch
end

local function IsOver(Inst, P)
    if not Inst or not Inst.Parent then return false end
    local Ap, As = Inst.AbsolutePosition, Inst.AbsoluteSize
    return P.X >= Ap.X and P.X <= Ap.X + As.X and P.Y >= Ap.Y and P.Y <= Ap.Y + As.Y
end

local function MousePos()
    return UserInputService:GetMouseLocation()
end

local function SafeCallback(Fn, ...)
    if typeof(Fn) ~= "function" then return end
    local Ok, Err = pcall(Fn, ...)
    if not Ok then warn("[Cloudy] callback error: " .. tostring(Err)) end
end

function Library:GiveSignal(Connection)
    table.insert(Library.Signals, Connection)
    return Connection
end

Library.DefaultIcon = "circle"
Library.FallbackIcon = "circle"
Library.IconProvider = IconsRegistry.GetProvider()
Library.Icons = IconsRegistry

function Library:GetIcon(Name, Provider)
    if typeof(Name) ~= "string" or Name == "" then Name = Library.DefaultIcon end
    local Asset = IconsRegistry.GetAsset(Name, Provider)
    if not Asset and Library.FallbackIcon and Library.FallbackIcon ~= Name then
        Asset = IconsRegistry.GetAsset(Library.FallbackIcon, Provider)
    end
    return Asset
end

function Library:SetDefaultIcon(Name)
    Library.DefaultIcon = Name
end

function Library:SetFallbackIcon(Name)
    Library.FallbackIcon = Name
end

function Library:SetIconProvider(Id)
    IconsRegistry.SetProvider(Id)
    Library.IconProvider = IconsRegistry.GetProvider()
    return Library.IconProvider
end

function Library:GetProvider()
    return IconsRegistry.GetProvider()
end

function Library:GetIcons(Provider)
    return IconsRegistry.GetIcons(Provider)
end

function Library:HasIcon(Name, Provider)
    return IconsRegistry.HasIcon(Name, Provider)
end

function Library:PreloadIcons(Names, Provider)
    return IconsRegistry.PreloadAsync(Names, Provider)
end

function Library:GetIconInfo(Id)
    return IconsRegistry.GetProviderInfo(Id)
end

function Library:SetIcon(Inst, Name, Provider)
    if typeof(Inst) ~= "Instance" then return false end
    local Asset = Library:GetIcon(Name, Provider)
    if not Asset then return false end
    if Inst:IsA("TextLabel") then
        if not Asset.FontFace then return false end
        Inst.RichText = false
        Inst.FontFace = Asset.FontFace
        Inst.Text = Asset.Text
    elseif Inst:IsA("ImageLabel") then
        Inst.Image = Asset.Url
        Inst.ImageRectSize = Asset.ImageRectSize
        Inst.ImageRectOffset = Asset.ImageRectOffset
    else
        return false
    end
    return true
end

function Library:ApplyIcon(Img, Asset)
    if not Img or not Asset then return end
    Img.Image = Asset.Url or ""
    Img.ImageRectOffset = Asset.ImageRectOffset or Vector2.zero
    Img.ImageRectSize = Asset.ImageRectSize or Vector2.zero
end

local function Glyph(Parent, IconName, Fallback, Props)
    Props = Props or {}
    local Asset = Library:GetIcon(IconName)
    if Asset and Asset.FontFace then
        local P = {}
        for K, V in Props do
            if K ~= "Parent" and K ~= "ImageColor3" and K ~= "Image" and K ~= "ImageRectOffset" and K ~= "ImageRectSize" and K ~= "FontFace" and K ~= "Text" then
                P[K] = V
            end
        end
        if P.TextColor3 == nil then P.TextColor3 = Props.TextColor3 or Props.ImageColor3 or "Text" end
        if P.TextSize == nil then
            local S = Props.Size
            P.TextSize = (typeof(S) == "UDim2" and S.Y.Offset > 0) and S.Y.Offset or 14
        end
        P.FontFace = Asset.FontFace
        P.Text = Asset.Text
        P.RichText = false
        P.TextXAlignment = P.TextXAlignment or Enum.TextXAlignment.Center
        P.TextYAlignment = P.TextYAlignment or Enum.TextYAlignment.Center
        local Lbl = New("TextLabel", { BackgroundTransparency = 1, Parent = Parent })
        Fill(Lbl, P)
        return Lbl
    end
    if Asset then
        local P = {}
        for K, V in Props do
            if K ~= "Parent" and K ~= "TextColor3" and K ~= "Text" and K ~= "TextSize" and K ~= "TextWrapped" and K ~= "RichText" and K ~= "FontFace" then
                P[K] = V
            end
        end
        if P.ImageColor3 == nil then P.ImageColor3 = Props.ImageColor3 or Props.TextColor3 or "Text" end
        P.Image = Asset.Url
        P.ImageRectSize = Asset.ImageRectSize
        P.ImageRectOffset = Asset.ImageRectOffset
        local Img = New("ImageLabel", { BackgroundTransparency = 1, Parent = Parent })
        Fill(Img, P)
        return Img
    end
    local P = {}
    for K, V in Props do
        if K ~= "Parent" and K ~= "ImageColor3" and K ~= "Image" and K ~= "ImageRectOffset" and K ~= "ImageRectSize" then
            P[K] = V
        end
    end
    if P.TextColor3 == nil then P.TextColor3 = Props.TextColor3 or Props.ImageColor3 or "Text" end
    P.RichText = false
    local Lbl = New("TextLabel", { BackgroundTransparency = 1, Text = Fallback or "●", Parent = Parent })
    Fill(Lbl, P)
    return Lbl
end

function Library:MakeDraggable(Target, Handle)
    local Dragging, StartPos, StartFrame = false, nil, nil
    Handle.InputBegan:Connect(function(Input)
        if not IsPress(Input) then return end
        Dragging, StartPos, StartFrame = true, Input.Position, Target.Position
        local C
        C = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End or Input.UserInputState == Enum.UserInputState.Cancel then
                Dragging = false
                C:Disconnect()
            end
        end)
    end)
    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
        if not Dragging then return end
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            local D = Input.Position - StartPos
            Target.Position = UDim2.new(StartFrame.X.Scale, StartFrame.X.Offset + D.X, StartFrame.Y.Scale, StartFrame.Y.Offset + D.Y)
        end
    end))
end

function Library:CreatePopup(Anchor, Opt)
    Opt = Opt or {}
    local Popup = { Active = false, Anchor = Anchor, Destroyed = false, Connections = {} }

    local Frame = New("Frame", {
        BackgroundColor3 = "Popup", Visible = false, ClipsDescendants = true,
        Size = UDim2.fromOffset(Opt.Width or 150, Opt.Height or 100), Parent = Opt.Parent or Library.Overlay,
    })
    if Opt.AutoY then
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        Frame.Size = UDim2.fromOffset(Opt.Width or 150, 0)
    end
    Corner(Frame, 10)
    Stroke(Frame, "Outline", 1, 0.35)
    local Scale = New("UIScale", { Scale = 1, Parent = Frame })
    Popup.Frame = Frame

    function Popup:UpdatePosition()
        if not Anchor.Parent then return end
        local AP, AS, FS = Anchor.AbsolutePosition, Anchor.AbsoluteSize, Frame.AbsoluteSize
        local View = ScreenGui.AbsoluteSize
        local X = AP.X + (Opt.AlignRight and (AS.X - FS.X) or 0)
        local Y = AP.Y + AS.Y + 6
        if Y + FS.Y > View.Y - 8 then Y = AP.Y - FS.Y - 6 end
        X = math.clamp(X, 8, math.max(8, View.X - FS.X - 8))
        Frame.Position = UDim2.fromOffset(math.floor(X), math.floor(Y))
    end

    function Popup:Open()
        if Popup.Active or Popup.Destroyed then return end
        if Library.CurrentPopup then Library.CurrentPopup:Close() end
        Library.CurrentPopup = Popup
        Popup.Active = true
        Frame.Visible = true
        Scale.Scale = 0.96
        Tween(Scale, { Scale = 1 }, Library.PopTween)
        Popup:UpdatePosition()
        Popup.Connections = {
            Anchor:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() Popup:UpdatePosition() end),
            Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Popup:UpdatePosition() end),
        }
        if Opt.OnToggle then SafeCallback(Opt.OnToggle, true) end
    end

    function Popup:Close()
        if not Popup.Active then return end
        Popup.Active = false
        if Library.CurrentPopup == Popup then Library.CurrentPopup = nil end
        for _, C in Popup.Connections do C:Disconnect() end
        Popup.Connections = {}
        Frame.Visible = false
        if Opt.OnToggle then SafeCallback(Opt.OnToggle, false) end
    end

    function Popup:Toggle()
        if Popup.Active then Popup:Close() else Popup:Open() end
    end

    function Popup:Destroy()
        Popup:Close()
        Popup.Destroyed = true
        Frame:Destroy()
    end

    return Popup
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input)
    if Library.Unloaded then return end
    local Type = Input.UserInputType
    if Type == Enum.UserInputType.MouseButton1 or Type == Enum.UserInputType.MouseButton2 or Type == Enum.UserInputType.Touch then
        local P = Library.CurrentPopup
        if P then
            local M = MousePos()
            if not IsOver(P.Frame, M) and not IsOver(P.Anchor, M) then P:Close() end
        end
    elseif Input.KeyCode == Enum.KeyCode.Escape then
        if UserInputService:GetFocusedTextBox() then return end
        if Library.CurrentPopup then Library.CurrentPopup:Close() end
    end
end))

local ScreenGui = New("ScreenGui", {
    Name = "CloudyRevolution", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 10, IgnoreGuiInset = true, Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
})
Library.Gui = ScreenGui
Library.Overlay = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 40, Parent = ScreenGui })

local function NextOrder(Group)
    Group._Order = (Group._Order or 0) + 1
    return Group._Order
end

local function MakeRow(Group, CtrlW, CtrlH, Hoverable)
    local Props = {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(Group), Parent = Group.Container,
    }
    if Hoverable then
        Props.Active = true
        Props.AutoButtonColor = false
    end
    local Row = New(Hoverable and "TextButton" or "Frame", Props)
    Corner(Row, 10)
    List(Row, 10, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center)
    Pad(Row, 9, 12, 9, 12)
    local TextCol = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, CtrlW > 0 and -(CtrlW + 12) or 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Row })
    List(TextCol, 3)
    local CtrlHolder
    if CtrlW > 0 then
        CtrlHolder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(CtrlW, CtrlH or 26), LayoutOrder = 2, Parent = Row })
    end
    if Hoverable then
        Row.MouseEnter:Connect(function()
            Tween(Row, { BackgroundColor3 = "Hover", BackgroundTransparency = 0 })
        end)
        Row.MouseLeave:Connect(function()
            Tween(Row, { BackgroundTransparency = 1 })
        end)
    end
    return Row, TextCol, CtrlHolder
end

local function MakeTitle(TextCol, Text, Size)
    return New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = Text,
        TextSize = Size or 15, TextColor3 = "Text", TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, Parent = TextCol,
    })
end

local function MakeDesc(TextCol, Text)
    if not Text or Text == "" then return nil end
    return New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = Text,
        TextSize = 11, TextColor3 = "SubText", TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, Parent = TextCol,
    })
end

local Finalize

function Library:CreateWindow(Info)
    Info = Info or {}
    if Library.Window then return Library.Window end
    local Title = Info.Title or "Cloudy Revolution"
    local Subtitle = Info.Subtitle or "Exploit client"
    local Size = Info.Size or UDim2.fromOffset(1160, 740)

    local Camera = workspace.CurrentCamera
    local View = Camera and Camera.ViewportSize or Vector2.new(1280, 800)
    Size = UDim2.fromOffset(
        math.clamp(Size.X.Offset, 640, math.max(640, View.X - 40)),
        math.clamp(Size.Y.Offset, 440, math.max(440, View.Y - 40))
    )

    local Root = New("Frame", {
        BackgroundColor3 = "BG", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = Size, ClipsDescendants = true, Parent = ScreenGui,
    })
    Corner(Root, 18)
    Stroke(Root, "Outline", 1, 0.55)

    local Sidebar = New("Frame", { BackgroundColor3 = "Side", Position = UDim2.fromOffset(10, 10), Size = UDim2.new(0, 216, 1, -20), Parent = Root })
    Corner(Sidebar, 16)

    local Logo = New("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 62), Parent = Sidebar })
    local CloudIcon = Glyph(Logo, "cloud", "☁", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(16, 31), Size = UDim2.fromOffset(24, 24), ImageColor3 = "Accent", TextSize = 20, TextColor3 = "Accent" })
    New("TextLabel", { Position = UDim2.fromOffset(50, 14), Size = UDim2.new(1, -56, 0, 16), Text = Title, FontFace = "FontBold", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Logo })
    New("TextLabel", { Position = UDim2.fromOffset(50, 31), Size = UDim2.new(1, -56, 0, 13), Text = Subtitle, TextSize = 10.5, TextColor3 = "SubText", TextXAlignment = Enum.TextXAlignment.Left, Parent = Logo })

    local NavList = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 68), Size = UDim2.new(1, -16, 1, -76), Parent = Sidebar })
    List(NavList, 4)

    local Content = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(238, 10), Size = UDim2.new(1, -248, 1, -20), Parent = Root })
    local Header = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = Content })
    local Body = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 1, -44), Parent = Content })
    local PageHost = New("ScrollingFrame", {
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = "Track",
        ScrollBarImageTransparency = 0.4, Parent = Body,
    })
    List(PageHost, 10)
    Pad(PageHost, 0, 6, 10, 0)

    local HeaderRight = New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(70, 30), Parent = Header })
    List(HeaderRight, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

    local Window = { Root = Root, Sidebar = Sidebar, Header = Header, Pages = {}, Tabs = {}, TabOrder = {}, ActiveTab = nil, Info = Info }

    local function HeaderBtn(IconName, Fallback, Fn)
        local B = New("TextButton", { BackgroundColor3 = "Control", Size = UDim2.fromOffset(30, 30), Parent = HeaderRight })
        Corner(B, 9)
        Glyph(B, IconName, Fallback, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(15, 15), TextColor3 = "SubText" })
        B.MouseEnter:Connect(function() Tween(B, { BackgroundColor3 = "ControlHover" }) end)
        B.MouseLeave:Connect(function() Tween(B, { BackgroundColor3 = "Control" }) end)
        B.MouseButton1Click:Connect(Fn)
        return B
    end

    local Maximized, OldSize, OldPos = false, nil, nil
    HeaderBtn("maximize-2", "⛶", function()
        if Maximized then
            Root.Size = OldSize
            Root.Position = OldPos
            Maximized = false
        else
            OldSize, OldPos = Root.Size, Root.Position
            Root.Size = UDim2.fromOffset(math.max(640, View.X - 40), math.max(440, View.Y - 40))
            Maximized = true
        end
    end)
    HeaderBtn("x", "✕", function()
        if Info.OnClose then SafeCallback(Info.OnClose) end
        Library:Unload()
    end)

    function Window:AddHeaderButton(Opt)
        Opt = Opt or {}
        local B = New("TextButton", { BackgroundColor3 = "Control", Size = UDim2.fromOffset(30, 30), LayoutOrder = 0, Parent = Header })
        Corner(B, 9)
        Glyph(B, Opt.Icon or Library.DefaultIcon, "⚙", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(15, 15), TextColor3 = "SubText" })
        B.MouseEnter:Connect(function() Tween(B, { BackgroundColor3 = "ControlHover" }) end)
        B.MouseLeave:Connect(function() Tween(B, { BackgroundColor3 = "Control" }) end)
        if Opt.Func then B.MouseButton1Click:Connect(function() SafeCallback(Opt.Func) end) end
        return B
    end

    function Window:ShowTab(Tab)
        if Window.ActiveTab == Tab then return end
        Window.ActiveTab = Tab
        for _, T in Window.Tabs do
            local On = T == Tab
            T.Button.BackgroundColor3 = On and Library.Scheme.Active or Color3.new(0, 0, 0)
            T.Button.BackgroundTransparency = On and 0 or 1
            if T.Icon:IsA("ImageLabel") then
                T.Icon.ImageColor3 = On and Library.Scheme.Text or Library.Scheme.SubText
            else
                T.Icon.TextColor3 = On and Library.Scheme.Text or Library.Scheme.SubText
            end
            T.Label.TextColor3 = On and Library.Scheme.Text or Library.Scheme.SubText
            T.Content.Visible = On
        end
        if Tab.DefaultPage then Tab.DefaultPage:Refresh() end
    end

    function Window:AddTab(Opt)
        if typeof(Opt) == "string" then Opt = { Name = Opt } end
        Opt = Opt or {}
        local Name = Opt.Name or "Tab"
        local Tab = { Name = Name, Pages = {}, Window = Window }

        local Btn = New("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = NavList })
        Corner(Btn, 10)
        local Icon = Glyph(Btn, Opt.Icon or Library.DefaultIcon, "●", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(14, 0.5), Size = UDim2.fromOffset(16, 16), TextSize = 12, ImageColor3 = "SubText", TextColor3 = "SubText" })
        local Lbl = New("TextLabel", { Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -48, 1, 0), Text = Name, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = "SubText", Parent = Btn })
        Tab.Button, Tab.Icon, Tab.Label = Btn, Icon, Lbl

        Btn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then Tween(Lbl, { TextColor3 = "Text" }) end
        end)
        Btn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then Tween(Lbl, { TextColor3 = "SubText" }) end
        end)
        Btn.MouseButton1Click:Connect(function() Window:ShowTab(Tab) end)

        Tab.Content = New("Frame", { BackgroundTransparency = 1, Visible = false, Size = UDim2.fromScale(1, 1), Parent = PageHost })
        List(Tab.Content, 10)
        table.insert(Window.Tabs, Tab)

        function Tab:AddPage(P)
            if typeof(P) == "string" then P = { Name = P } end
            P = P or {}
            local Page = { Name = P.Name, Description = P.Description, Tab = Tab, Elements = {}, Groupboxes = {}, SideCount = 0 }
            Page.Host = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Tab.Content })
            List(Page.Host, 10)
            if P.Name then
                local Head = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Page.Host })
                List(Head, 2)
                New("TextLabel", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = P.Name, FontFace = "FontBold", TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left, Parent = Head })
                if P.Description then
                    New("TextLabel", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = P.Description, TextSize = 11.5, TextColor3 = "SubText", TextXAlignment = Enum.TextXAlignment.Left, Parent = Head })
                end
            end
            Page.Full = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Page.Host })
            List(Page.Full, 10)
            Page.Cols = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Page.Host })
            List(Page.Cols, 12, Enum.FillDirection.Horizontal)
            Page.Col1 = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Page.Cols })
            List(Page.Col1, 10)
            Page.Col2 = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Page.Cols })
            List(Page.Col2, 10)

            function Page:Refresh() end

            function Page:AddGroupbox(G)
                return Funcs.AddGroupbox(Page, G)
            end

            Page.Refresh = Page.Refresh
            table.insert(Tab.Pages, Page)
            if not Tab.DefaultPage then
                Tab.DefaultPage = Page
                Page.Host.Visible = true
            else
                Page.Host.Visible = false
            end
            function Page:Show()
                for _, P in Tab.Pages do
                    P.Host.Visible = P == Page
                end
            end
            return Page
        end

        function Tab:AddGroupbox(G)
            if not Tab.DefaultPage then Tab:AddPage() end
            return Tab.DefaultPage:AddGroupbox(G)
        end

        if not Window.ActiveTab then Window:ShowTab(Tab) end
        return Tab
    end

    function Window:AddPage(P)
        if not Window.ActiveTab then Window:AddTab({ Name = "Home" }) end
        return Window.ActiveTab:AddPage(P)
    end

    Library:MakeDraggable(Root, Logo)
    Library:MakeDraggable(Root, Header)
    Library.Window = Window
    return Window
end

Funcs = {}

function Funcs:AddGroupbox(Info)
    if typeof(Info) == "string" then Info = { Name = Info } end
    Info = Info or {}
    local Side = Info.Side or "Single"
    local Page = self
    local ParentCol
    if Side == 1 then
        ParentCol = Page.Col1
    elseif Side == 2 then
        ParentCol = Page.Col2
    else
        ParentCol = Page.Full
    end

    local Card = New("Frame", { BackgroundColor3 = "Card", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = ParentCol })
    Corner(Card, 14)
    List(Card, 8)
    Pad(Card, 12, 12, 12, 12)

    local Group = {
        Type = "Groupbox", Name = Info.Name, Side = Side, Holder = Card, Container = Card,
        Elements = {}, NestedRows = {}, SidePending = nil, SideFill = 0, Connections = {},
    }

    if Info.Name then
        local Head = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = -1, Parent = Card })
        List(Head, 2)
        New("TextLabel", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = Info.Name, FontFace = "FontBold", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = Head })
        if Info.Description then
            New("TextLabel", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = Info.Description, TextSize = 11, TextColor3 = "SubText", TextXAlignment = Enum.TextXAlignment.Left, Parent = Head })
        end
    end

    function Group:SetVisible(V)
        V = V ~= false
        Card.Visible = V
    end

    function Group:Destroy()
        Card:Destroy()
    end

    table.insert(Page.Groupboxes, Group)
    return Group
end

function Funcs:AddNestedGroupbox(Info)
    if typeof(Info) == "string" then Info = { Name = Info } end
    Info = Info or {}
    local Parent = self
    local Side = Info.Side
    if Side and Side ~= "Single" and Parent.Side ~= "Single" then
        warn("[Cloudy] nested Side requires a Single groupbox — rendering Single instead")
        Side = nil
    end

    local Holder
    if Side == 1 or Side == 2 then
        local P = Parent.SidePending
        local function NewRow()
            local R = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = NextOrder(Parent), Parent = Parent.Container })
            List(R, 10, Enum.FillDirection.Horizontal)
            return { Frame = R, Left = false, Right = false }
        end
        if Side == 1 then
            if not P or P.Left then
                P = NewRow()
                Parent.SidePending = P
            end
            P.Left = true
            Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = P.Frame })
        else
            if not P or (P.Left and P.Right) then
                P = NewRow()
                Parent.SidePending = P
            end
            if not P.Left then
                P.Left = true
                New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 0, 0), Parent = P.Frame })
            end
            P.Right = true
            Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = P.Frame })
        end
    else
        Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = NextOrder(Parent), Parent = Parent.Container })
    end

    local Card = New("Frame", { BackgroundColor3 = "Nested", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Holder })
    Corner(Card, 12)
    List(Card, 8)
    Pad(Card, 10, 10, 10, 10)

    local Head = New("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Parent = Card })
    New("TextLabel", { Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -26, 1, 0), Text = Info.Name or "Section", FontFace = "FontBold", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Head })
    local Chevron = Glyph(Head, "chevron-down", "▾", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -2, 0.5, 0), Size = UDim2.fromOffset(14, 14), TextColor3 = "SubText" })

    local BodyWrap = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Card })
    local Body = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = BodyWrap })
    List(Body, 6)

    local Nested = {
        Type = "NestedGroupbox", Name = Info.Name, Side = "Single", Holder = Card, Container = Body,
        Elements = {}, NestedRows = {}, SidePending = nil, Connections = {}, Collapsed = Info.Collapsed == true,
    }

    function Nested:SetCollapsed(C)
        Nested.Collapsed = C == true
        BodyWrap.Visible = not Nested.Collapsed
        Tween(Chevron, { Rotation = Nested.Collapsed and -90 or 0 }, Library.PopTween)
    end

    function Nested:ToggleCollapsed() Nested:SetCollapsed(not Nested.Collapsed) end

    function Nested:SetVisible(V)
        V = V ~= false
        Holder.Visible = V
    end

    function Nested:Destroy()
        Holder:Destroy()
    end

    Head.MouseButton1Click:Connect(function() Nested:ToggleCollapsed() end)
    if Nested.Collapsed then
        BodyWrap.Visible = false
        Chevron.Rotation = -90
    end
    return Nested
end

Finalize = function(Group, Element, Holder, CtrlW)
    Element.Holder = Holder
    Element.Group = Group
    Element.Connections = Element.Connections or {}
    if Element.Visible == nil then Element.Visible = true end
    table.insert(Group.Elements, Element)
    table.insert(Library.Elements, Element)

    function Element:SetVisible(V)
        Element.Visible = V ~= false
        Holder.Visible = Element.Visible
    end

    function Element:Destroy()
        if Element.Destroyed then return end
        Element.Destroyed = true
        for _, C in Element.Connections do C:Disconnect() end
        Holder:Destroy()
        local I = table.find(Group.Elements, Element)
        if I then table.remove(Group.Elements, I) end
        local J = table.find(Library.Elements, Element)
        if J then table.remove(Library.Elements, J) end
    end

    function Element:SetText(T)
        if Element.TextObj then Element.TextObj.Text = T end
        Element.Text = T
    end

    return Element
end

function Funcs:AddLabel(Info)
    if typeof(Info) == "string" then Info = { Text = Info } end
    Info = Info or {}
    local Group = self
    local Row, TextCol = MakeRow(Group, 0, 0, false)
    local Lbl = MakeTitle(TextCol, Info.Text or "", Info.Size or 15)
    Lbl.TextColor3 = (typeof(Info.Color) == "string" and Library.Scheme[Info.Color]) or (Info.Color or Library.Scheme.Text)
    local El = { Type = "Label", Text = Info.Text, Visible = Info.Visible, TextObj = Lbl }
    return Finalize(Group, El, Row)
end

function Funcs:AddButton(Info)
    if typeof(Info) == "string" then Info = { Text = Info } end
    Info = Info or {}
    local Group = self
    local Standalone = Info.Title == nil
    local Btn
    local Holder

    if Standalone then
        Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = NextOrder(Group), Parent = Group.Container })
        local BS = UDim2.new(1, 0, 0, 28)
        if Info.Width then
            if Info.Width <= 1 then
                BS = UDim2.new(Info.Width, 0, 0, 28)
            else
                BS = UDim2.new(0, Info.Width, 0, 28)
            end
        end
        Btn = New("TextButton", { BackgroundColor3 = Info.Primary and "Accent" or "Control", Size = BS, Parent = Holder })
        Corner(Btn, 9)
        New("TextLabel", { Size = UDim2.fromScale(1, 1), Text = Info.Text or "Button", TextSize = 12.5, FontFace = "FontBold", TextColor3 = Info.Primary and "AccentText" or "Text", Parent = Btn })
    else
        local W = Info.Width or (math.max(48, #(Info.Text or "Button") * 7 + 26))
        local Row, TextCol, Ctrl = MakeRow(Group, W, 26, true)
        Holder = Row
        MakeTitle(TextCol, Info.Title, 15)
        MakeDesc(TextCol, Info.Description)
        Btn = New("TextButton", { BackgroundColor3 = Info.Primary and "Accent" or "Control", Size = UDim2.fromScale(1, 1), Parent = Ctrl })
        Corner(Btn, 8)
        New("TextLabel", { Size = UDim2.fromScale(1, 1), Text = Info.Text or "Run", TextSize = 12, FontFace = "FontBold", TextColor3 = Info.Primary and "AccentText" or "Text", Parent = Btn })
    end

    Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Info.Primary and "Accent" or "ControlHover" }) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Info.Primary and "Accent" or "Control" }) end)
    if Info.Func then Btn.MouseButton1Click:Connect(function() SafeCallback(Info.Func) end) end

    local El = { Type = "Button", Text = Info.Text, Visible = Info.Visible, Control = Btn }
    return Finalize(Group, El, Holder)
end

function Funcs:AddToggle(Idx, Info)
    if typeof(Idx) == "table" and Info == nil then Info, Idx = Idx, nil end
    Info = Info or {}
    local Group = self
    local Row, TextCol, Ctrl = MakeRow(Group, 38, 21, true)
    local TitleLbl = MakeTitle(TextCol, Info.Text or "Toggle", Info.Size or 15)
    local DescLbl = MakeDesc(TextCol, Info.Description)

    local Track = New("Frame", { BackgroundColor3 = "Track", Size = UDim2.fromOffset(38, 21), Parent = Ctrl })
    Corner(Track, 99)
    local Knob = New("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(17, 17), Parent = Track })
    Corner(Knob, 99)

    local Toggle = { Type = "Toggle", Text = Info.Text, Value = Info.Default == true, Callback = Info.Callback, Changed = Info.Changed, Disabled = Info.Disabled, Visible = Info.Visible }

    function Toggle:Display(Instant)
        local Dim = Toggle.Disabled and 0.55 or 0
        Anim(Track, { BackgroundColor3 = Toggle.Value and "Accent" or "Track", BackgroundTransparency = Dim }, Instant)
        Anim(Knob, { Position = Toggle.Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), BackgroundTransparency = Dim }, Instant)
        if TitleLbl then Anim(TitleLbl, { TextTransparency = Dim }, Instant) end
        if DescLbl then Anim(DescLbl, { TextTransparency = Dim }, Instant) end
    end

    function Toggle:SetValue(V)
        V = V == true
        if V == Toggle.Value then return end
        Toggle.Value = V
        Toggle:Display()
        if not Toggle.Disabled then
            SafeCallback(Toggle.Callback, Toggle.Value)
            SafeCallback(Toggle.Changed, Toggle.Value)
        end
    end

    function Toggle:SetDisabled(D)
        Toggle.Disabled = D == true
        Toggle:Display(true)
    end

    Row.InputBegan:Connect(function(Input)
        if IsPress(Input) and not Toggle.Disabled then Toggle:SetValue(not Toggle.Value) end
    end)

    Toggle:Display(true)
    return Finalize(Group, Toggle, Row)
end

function Funcs:AddCheckbox(Idx, Info)
    if typeof(Idx) == "table" and Info == nil then Info, Idx = Idx, nil end
    Info = Info or {}
    Info.Checkbox = true
    return Funcs.AddToggle(self, Idx, Info)
end

function Funcs:AddSlider(Idx, Info)
    if typeof(Idx) == "table" and Info == nil then Info, Idx = Idx, nil end
    Info = Info or {}
    local Group = self
    local Min = tonumber(Info.Min) or 0
    local Max = tonumber(Info.Max) or 100
    if Min > Max then Min, Max = Max, Min end
    local Rounding = tonumber(Info.Rounding) or 0
    local Suffix = Info.Suffix or ""
    local Row, TextCol, Ctrl = MakeRow(Group, 150, 18, true)
    MakeTitle(TextCol, Info.Text or "Slider", Info.Size or 15)
    MakeDesc(TextCol, Info.Description)

    local Track = New("Frame", { BackgroundColor3 = "Track", Size = UDim2.fromScale(1, 1), Active = true, Parent = Ctrl })
    Corner(Track, 99)
    local FillBar = New("Frame", { BackgroundColor3 = "Accent", Size = UDim2.new(0.3, 0, 1, 0), Parent = Track })
    Corner(FillBar, 99)
    local Badge = New("Frame", { BackgroundColor3 = "Accent", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -1, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), Parent = Track })
    Corner(Badge, 99)
    Pad(Badge, 0, 8, 0, 8)
    local BadgeText = New("TextLabel", { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, Text = "", TextSize = 10.5, FontFace = "FontBold", TextColor3 = "AccentText", Parent = Badge })

    local Slider = { Type = "Slider", Text = Info.Text, Min = Min, Max = Max, Rounding = Rounding, Suffix = Suffix, Callback = Info.Callback, Changed = Info.Changed, Disabled = Info.Disabled, Visible = Info.Visible }
    Slider.Value = math.clamp(tonumber(Info.Default) or Min, Min, Max)

    function Slider:Display(Instant)
        local Pct = (Max > Min) and ((Slider.Value - Min) / (Max - Min)) or 0
        local Dim = Slider.Disabled and 0.55 or 0
        Anim(FillBar, { Size = UDim2.new(math.max(Pct, 0.02), 0, 1, 0), BackgroundTransparency = Dim }, Instant)
        Anim(Badge, { BackgroundTransparency = Dim }, Instant)
        BadgeText.TextTransparency = Dim
        local Shown = Slider.Value
        if Rounding > 0 then
            Shown = math.floor(Shown + 0.5)
        else
            Shown = math.floor(Shown * 10 + 0.5) / 10
        end
        BadgeText.Text = tostring(Shown) .. Suffix
    end

    function Slider:SetValue(V, Silent)
        V = tonumber(V) or Min
        V = math.clamp(V, Min, Max)
        if Rounding > 0 then V = math.floor(V / Rounding + 0.5) * Rounding end
        if V == Slider.Value and not Silent then return end
        Slider.Value = V
        Slider:Display()
        if not Silent and not Slider.Disabled then
            SafeCallback(Slider.Callback, Slider.Value)
            SafeCallback(Slider.Changed, Slider.Value)
        end
    end

    function Slider:SetDisabled(D)
        Slider.Disabled = D == true
        Slider:Display(true)
    end

    local Dragging = false
    local function FromX(X)
        local Rel = math.clamp((X - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1), 0, 1)
        Slider:SetValue(Min + (Max - Min) * Rel, true)
    end
    Track.InputBegan:Connect(function(Input)
        if IsPress(Input) and not Slider.Disabled then
            Dragging = true
            FromX(Input.Position.X)
        end
    end)
    table.insert(Slider.Connections, UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            FromX(Input.Position.X)
        end
    end))
    table.insert(Slider.Connections, UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Dragging then
                Dragging = false
                if not Slider.Disabled then
                    SafeCallback(Slider.Callback, Slider.Value)
                    SafeCallback(Slider.Changed, Slider.Value)
                end
            end
        end
    end))

    Slider:Display(true)
    return Finalize(Group, Slider, Row)
end

function Funcs:AddDropdown(Idx, Info)
    if typeof(Idx) == "table" and Info == nil then Info, Idx = Idx, nil end
    Info = Info or {}
    local Group = self
    local W = Info.Width or 132
    local Row, TextCol, Ctrl = MakeRow(Group, W, 26, true)
    MakeTitle(TextCol, Info.Text or "Dropdown", Info.Size or 15)
    MakeDesc(TextCol, Info.Description)

    local Btn = New("TextButton", { BackgroundColor3 = "Control", Size = UDim2.fromScale(1, 1), Parent = Ctrl })
    Corner(Btn, 8)
    local Display = New("TextLabel", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -30, 1, 0), Text = "---", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Btn })
    local Chevron = Glyph(Btn, "chevron-down", "▾", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(13, 13), TextColor3 = "SubText" })

    local Items = {}
    for _, V in Info.Values or {} do
        if typeof(V) == "table" then
            table.insert(Items, { Label = tostring(V.Name or V.Value or V), Value = V.Value ~= nil and V.Value or V.Name })
        else
            table.insert(Items, { Label = tostring(V), Value = V })
        end
    end

    local Dropdown = { Type = "Dropdown", Text = Info.Text, Value = Info.Default, Items = Items, Callback = Info.Callback, Changed = Info.Changed, Disabled = Info.Disabled, Visible = Info.Visible }
    local Popup

    local function FindItem(V)
        for _, It in Items do
            if It.Value == V or It.Label == V then return It end
        end
        return nil
    end

    function Dropdown:Display()
        local It = FindItem(Dropdown.Value)
        Display.Text = It and It.Label or "---"
    end

    function Dropdown:SetValue(V)
        local It = FindItem(V)
        if not It then return end
        Dropdown.Value = It.Value
        Dropdown:Display()
        SafeCallback(Dropdown.Callback, Dropdown.Value)
        SafeCallback(Dropdown.Changed, Dropdown.Value)
    end

    function Dropdown:SetDisabled(D)
        Dropdown.Disabled = D == true
        Btn.BackgroundTransparency = Dropdown.Disabled and 0.5 or 0
        Display.TextTransparency = Dropdown.Disabled and 0.55 or 0
    end

    Popup = Library:CreatePopup(Btn, { Width = W, AutoY = true })
    local ListFrame = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = Popup.Frame })
    List(ListFrame, 2)
    Pad(ListFrame, 4, 4, 4, 4)

    local ItemRefs = {}
    for _, It in Items do
        local Item = New("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 27), Parent = ListFrame })
        Corner(Item, 7)
        New("TextLabel", { Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -26, 1, 0), Text = It.Label, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = Item })
        local Dot = New("Frame", { BackgroundColor3 = "Accent", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(6, 6), Visible = Dropdown.Value == It.Value, Parent = Item })
        Corner(Dot, 99)
        table.insert(ItemRefs, { It = It, Dot = Dot })
        Item.MouseEnter:Connect(function() Tween(Item, { BackgroundColor3 = "Hover", BackgroundTransparency = 0 }) end)
        Item.MouseLeave:Connect(function() Tween(Item, { BackgroundTransparency = 1 }) end)
        Item.MouseButton1Click:Connect(function()
            Dropdown:SetValue(It.Value)
            for _, R in ItemRefs do
                R.Dot.Visible = R.It.Value == Dropdown.Value
            end
            Popup:Close()
        end)
    end

    Btn.MouseEnter:Connect(function() if not Dropdown.Disabled then Tween(Btn, { BackgroundColor3 = "ControlHover" }) end end)
    Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = "Control" }) end)
    Btn.MouseButton1Click:Connect(function()
        if Dropdown.Disabled then return end
        Popup:Toggle()
    end)

    Dropdown:Display()
    Dropdown:SetDisabled(Dropdown.Disabled or false)
    local El = Finalize(Group, Dropdown, Row)
    El.Popup = Popup
    return El
end

function Funcs:AddInput(Idx, Info)
    if typeof(Idx) == "table" and Info == nil then Info, Idx = Idx, nil end
    Info = Info or {}
    local Group = self
    local Compact = Info.Text ~= nil
    local Row, TextCol, Ctrl
    if Compact then
        Row, TextCol, Ctrl = MakeRow(Group, Info.Width or 110, 26, true)
        MakeTitle(TextCol, Info.Text, Info.Size or 15)
        MakeDesc(TextCol, Info.Description)
    else
        local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = NextOrder(Group), Parent = Group.Container })
        List(Holder, 5)
        Row = Holder
        if Info.Label then
            New("TextLabel", { Size = UDim2.new(1, 0, 0, 14), Text = Info.Label, TextSize = 12.5, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = "SubText", Parent = Holder })
        end
        Ctrl = Holder
    end

    local Box = New("TextBox", {
        BackgroundColor3 = "Control", Size = Compact and UDim2.fromScale(1, 1) or UDim2.new(1, 0, 0, 28),
        Text = Info.Default or "", PlaceholderText = Info.Placeholder or "",
        TextXAlignment = Compact and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = Ctrl,
    })
    Corner(Box, 8)
    Pad(Box, 0, 10, 0, 10)
    local BoxStroke = Stroke(Box, "Outline", 1, 0.6)

    local Input = { Type = "Input", Text = Info.Text, Value = Info.Default or "", Numeric = Info.Numeric, Callback = Info.Callback, Changed = Info.Changed, Disabled = Info.Disabled, Visible = Info.Visible }
    Box.PlaceholderColor3 = Library.Scheme.SubText

    function Input:SetDisabled(D)
        Input.Disabled = D == true
        Box.TextEditable = not Input.Disabled
        Box.TextTransparency = Input.Disabled and 0.55 or 0
    end

    Box.Focused:Connect(function()
        if Input.Disabled then Box:ReleaseFocus() return end
        Tween(Box, { BackgroundColor3 = "ControlHover" })
        BoxStroke.Transparency = 0.15
    end)

    Box.FocusLost:Connect(function()
        Tween(Box, { BackgroundColor3 = "Control" })
        BoxStroke.Transparency = 0.6
        local V = Box.Text
        if Input.Numeric then
            V = tonumber(V)
            if V == nil then
                Box.Text = tostring(Input.Value)
                return
            end
        end
        if V == Input.Value then return end
        Input.Value = V
        Box.Text = tostring(V)
        SafeCallback(Input.Callback, Input.Value)
        SafeCallback(Input.Changed, Input.Value)
    end)

    function Input:SetValue(V)
        Input.Value = V
        Box.Text = tostring(V)
    end

    Input:SetDisabled(Input.Disabled or false)
    return Finalize(Group, Input, Row)
end

function Funcs:AddSeparator()
    local Group = self
    local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 9), LayoutOrder = NextOrder(Group), Parent = Group.Container })
    New("Frame", { BackgroundColor3 = "Outline", BackgroundTransparency = 0.5, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1), Parent = Holder })
    return Finalize(Group, { Type = "Separator", Visible = true }, Holder)
end

function Library:Unload()
    if Library.Unloaded then return end
    Library.Unloaded = true
    for _, S in Library.Signals do
        pcall(function() S:Disconnect() end)
    end
    if Library.CurrentPopup then Library.CurrentPopup:Close() end
    pcall(function() ScreenGui:Destroy() end)
end

return Library
