local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ser1771/CloudRe/refs/heads/main/Library.lua"))()

local Toggles, Options = Library.Toggles, Library.Options

local Window = Library:CreateWindow({
    Title = "Cloudy 1.4",
    Subtitle = "Exploit client",
    Icon = "cloud",
    Footer = "Cloudy Revolution",
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowCustomCursor = false, -- default is already false
    Animations = { ToggleWindow = true, TabSwitch = true, Groupbox = true, Dropdown = true, KeyPicker = true },
})

local Tabs = {
    Aimbot   = Window:AddTab({ Name = "Aimbot",   Icon = "target" }),
    Visual   = Window:AddTab({ Name = "Visual",   Icon = "eye" }),
    Players  = Window:AddTab({ Name = "Players", Icon = "user", Description = "Character movement & physics" }),
    Settings = Window:AddTab({ Name = "Settings", Icon = "settings" }),
}

--// AIMBOT: normal two-column layout
local Main = Tabs.Aimbot:AddGroupbox({ Name = "Aimbot", Side = "Left" })

Main:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Description = "Aimbot without looking suspicious. Long descriptions now wrap and the card grows with them, so nothing stacks.",
    Highlight = true,
    Default = true,
})

-- Dropdown = a card with the dropdown frame inside it (menu opens under the pill)
Main:AddDropdown("TargetPart", {
    Text = "Target Part",
    Description = "Which body part to aim at",
    Values = { "Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm" },
    Default = "Head",
    Searchable = true,
})

Main:AddDropdown("Checks", {
    Text = "Checks",
    Description = "Skip targets that match",
    Values = { "Team", "Wall", "Dead", "Friend" },
    Default = { "Team", "Dead" },
    Multi = true,
})

Main:AddSlider("MinDamage", { Text = "Minimum Damage", Description = "Least amount of damage to deal", Min = 0, Max = 100, Default = 38 })
Main:AddInput("FOV", { Text = "Field Of View", Description = "How much of the world is visible", Default = "180", Numeric = true, Finished = true })

--// Nested groupboxes inside a groupbox (stacked)
-- Collapsible = true -> shows the collapse arrow. Without it the groupbox only shows its title.
local Advanced = Tabs.Aimbot:AddGroupbox({ Name = "Advanced", Side = "Right", Collapsible = true })
Advanced:AddToggle("Bhop", { Text = "Bhop", Default = true })

local Inner = Advanced:AddGroupbox({ Name = "Prediction" }) -- no Side = stacked full width
Inner:AddSlider("PredX", { Text = "Prediction X", Min = 0, Max = 10, Default = 2 })
Inner:AddSlider("PredY", { Text = "Prediction Y", Min = 0, Max = 10, Default = 2 })

--// WARP: groupbox that is at most 220px tall; extra elements scroll inside it
local Targets = Tabs.Aimbot:AddGroupbox({
    Name = "Target List",
    Side = "Right",
    Warp = 220, -- (alias: Wrap) max height in pixels, header included
})
for Index = 1, 12 do
    Targets:AddToggle("Target" .. Index, { Text = "Target " .. Index, Description = "Priority target slot " .. Index })
end
-- Targets:SetWarp(nil)  -- back to a normal, auto-height groupbox
-- Targets:SetWarp(300)  -- change the height later

--// VISUAL: PAGES 
local General = Tabs.Visual:AddPage("General")
local Colors  = Tabs.Visual:AddPage("Colors")

local ESP = General:AddGroupbox({ Name = "ESP", Side = "Full" })
ESP:AddToggle("ESPEnabled", { Text = "Enabled", Description = "Draw boxes around players", Default = true })

local Boxes = ESP:AddGroupbox({ Name = "Boxes", Side = "Left" })
Boxes:AddToggle("Box2D", { Text = "2D Box", Default = true })
Boxes:AddToggle("Corner", { Text = "Corner Box" })

local Names = ESP:AddGroupbox({ Name = "Names", Side = "Right" })
Names:AddToggle("ShowName", { Text = "Show name", Default = true })
Names:AddSlider("NameSize", { Text = "Text size", Min = 8, Max = 24, Default = 14 })

local Theme = Colors:AddGroupbox({ Name = "Accent", Side = "Left" })
Theme:AddLabel("Accent color"):AddColorPicker("AccentPick", { Default = Library.Scheme.AccentColor })
Options.AccentPick:OnChanged(function(Color)
    Library.Scheme.AccentColor = Color
    Library:UpdateColorsUsingRegistry()
end)

--// SETTINGS
local UI = Tabs.Settings:AddGroupbox({ Name = "Interface", Side = "Full" })
UI:AddToggle("Glow", {
    Text = "Element glow",
    Description = "Soft UIShadow behind new element cards",
    Default = true,
    Callback = function(Value) Library.ElementGlow = Value end,
})
UI:AddButton({ Text = "Unload", Risky = true, DoubleClick = true, Func = function() Library:Unload() end })


Library:Notify({ Title = "Cloudy Revolution", Description = "Press the search button to find anything", Time = 5, Icon = "search" })
