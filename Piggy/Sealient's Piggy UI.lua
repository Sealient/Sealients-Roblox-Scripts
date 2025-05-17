local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent UI Script",
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}



--==Visuals Tab=--

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace

local VisualsEnabled = false
local ESPFolder -- container for ESP UI objects
local itemESPInstances = {}
local itemRenderConnections = {}
local itemHighlights = {}
local maxDistance = 10000 -- max draw distance

-- Utility to clear ESP and highlight for a given item
local function clearESP(item)
	if itemESPInstances[item] then
		itemESPInstances[item]:Destroy()
		itemESPInstances[item] = nil
	end
	if itemRenderConnections[item] then
		itemRenderConnections[item]:Disconnect()
		itemRenderConnections[item] = nil
	end
	if itemHighlights[item] then
		itemHighlights[item]:Destroy()
		itemHighlights[item] = nil
	end
end

-- Utility to find the dynamic items folder in workspace
local function getItemsFolder()
	if workspace:FindFirstChild("ItemFolder") then
		return workspace.ItemFolder
	end
	for _, child in pairs(workspace:GetChildren()) do
		if child:IsA("Folder") and tostring(child.Name):match("^%-?%d+$") then
			return child
		end
	end
	return nil
end

-- Create ESP and Highlight for item
local function createItemESP(item)
	local adornee = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
	if not adornee then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "ItemESP"
	gui.Adornee = adornee
	gui.AlwaysOnTop = true
	gui.Size = UDim2.new(0, 150, 0, 50)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.LightInfluence = 0
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 1
	frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
	frame.Parent = gui

	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(1, -10, 0, 25)
	name.Position = UDim2.new(0, 5, 0, 0)
	name.BackgroundTransparency = 1
	name.TextColor3 = Color3.fromRGB(0, 255, 0)
	name.TextStrokeTransparency = 0.7
	name.Font = Enum.Font.SourceSansBold
	name.TextSize = 18
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = item.Name
	name.Parent = frame

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, -10, 0, 20)
	distLabel.Position = UDim2.new(0, 5, 0, 25)
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	distLabel.TextStrokeTransparency = 0.7
	distLabel.Font = Enum.Font.SourceSansItalic
	distLabel.TextSize = 14
	distLabel.TextXAlignment = Enum.TextXAlignment.Left
	distLabel.Text = ""
	distLabel.Parent = frame

	gui.Parent = ESPFolder -- parent all ESP GUIs to a single folder in CoreGui for cleanliness
	itemESPInstances[item] = gui

	-- Create Highlight instance for the item
	local highlight = Instance.new("Highlight")
	highlight.Name = "ItemHighlight"
	highlight.Adornee = item
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = item
	itemHighlights[item] = highlight

	-- Connect to RenderStepped for smooth distance update and visibility toggle
	itemRenderConnections[item] = RunService.RenderStepped:Connect(function()
		if not adornee:IsDescendantOf(Workspace) or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			clearESP(item)
			return
		end
		local dist = (adornee.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		if dist > maxDistance then
			gui.Enabled = false
			highlight.Enabled = false
		else
			gui.Enabled = true
			highlight.Enabled = true
			distLabel.Text = string.format("Distance: %.1f studs", dist)
		end
	end)
end

-- Update ESPs each frame or on toggle
local function updateESP()
	if not VisualsEnabled then
		if ESPFolder then
			for item, _ in pairs(itemESPInstances) do
				clearESP(item)
			end
			ESPFolder:Destroy()
			ESPFolder = nil
		end
		return
	end

	local itemsFolder = getItemsFolder()
	if not itemsFolder then return end

	if not ESPFolder then
		ESPFolder = Instance.new("Folder")
		ESPFolder.Name = "ESPFolder"
		ESPFolder.Parent = game.CoreGui
	end

	-- Clear ESPs for deleted items
	for item, _ in pairs(itemESPInstances) do
		if not item or not item.Parent then
			clearESP(item)
		end
	end

	for _, item in pairs(itemsFolder:GetChildren()) do
		if (item:IsA("BasePart") or item:IsA("Model")) and not itemESPInstances[item] then
			createItemESP(item)
		end
	end
end


-- Update ESP periodically (every 0.5 seconds)
local updateTimer = 0
RunService.Heartbeat:Connect(function(dt)
	if VisualsEnabled then
		updateTimer = updateTimer + dt
		if updateTimer >= 0.5 then
			updateESP()
			updateTimer = 0
		end
	end
end)

local piggyESPInstances = {}
local piggyRenderConnections = {}
local piggyHighlights = {}
local piggyVisualsEnabled = false

-- Clears ESP and highlight for a given piggy
local function clearPiggyESP(piggy)
	if piggyESPInstances[piggy] then
		piggyESPInstances[piggy]:Destroy()
		piggyESPInstances[piggy] = nil
	end
	if piggyRenderConnections[piggy] then
		piggyRenderConnections[piggy]:Disconnect()
		piggyRenderConnections[piggy] = nil
	end
	if piggyHighlights[piggy] then
		piggyHighlights[piggy]:Destroy()
		piggyHighlights[piggy] = nil
	end
end

-- Create ESP for a piggy model
local function createPiggyESP(piggy)
	local adornee = piggy:FindFirstChildWhichIsA("BasePart")
	if not adornee then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "PiggyESP"
	gui.Adornee = adornee
	gui.AlwaysOnTop = true
	gui.Size = UDim2.new(0, 150, 0, 50)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.LightInfluence = 0
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 1
	frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
	frame.Parent = gui

	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(1, -10, 0, 25)
	name.Position = UDim2.new(0, 5, 0, 0)
	name.BackgroundTransparency = 1
	name.TextColor3 = Color3.fromRGB(255, 0, 0)
	name.TextStrokeTransparency = 0.7
	name.Font = Enum.Font.SourceSansBold
	name.TextSize = 18
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = piggy.Name
	name.Parent = frame

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, -10, 0, 20)
	distLabel.Position = UDim2.new(0, 5, 0, 25)
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	distLabel.TextStrokeTransparency = 0.7
	distLabel.Font = Enum.Font.SourceSansItalic
	distLabel.TextSize = 14
	distLabel.TextXAlignment = Enum.TextXAlignment.Left
	distLabel.Text = ""
	distLabel.Parent = frame

	gui.Parent = ESPFolder
	piggyESPInstances[piggy] = gui

	local highlight = Instance.new("Highlight")
	highlight.Name = "PiggyHighlight"
	highlight.Adornee = piggy
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = piggy
	piggyHighlights[piggy] = highlight

	piggyRenderConnections[piggy] = RunService.RenderStepped:Connect(function()
		if not adornee:IsDescendantOf(Workspace) or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			clearPiggyESP(piggy)
			return
		end
		local dist = (adornee.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		local show = dist <= maxDistance
		gui.Enabled = show
		highlight.Enabled = show
		distLabel.Text = string.format("Distance: %.1f studs", dist)
	end)
end

-- Update piggy ESPs
local function updatePiggyESP()
	if not piggyVisualsEnabled then
		for piggy in pairs(piggyESPInstances) do
			clearPiggyESP(piggy)
		end
		return
	end

	local piggyFolder = workspace:FindFirstChild("PiggyNPC")
	if not piggyFolder then return end

	for _, piggy in pairs(piggyFolder:GetChildren()) do
		if piggy:IsA("Model") and not piggyESPInstances[piggy] then
			createPiggyESP(piggy)
		end
	end

	-- Cleanup dead pigs
	for piggy in pairs(piggyESPInstances) do
		if not piggy or not piggy.Parent then
			clearPiggyESP(piggy)
		end
	end
end

-- Update periodically
local piggyUpdateTimer = 0
RunService.Heartbeat:Connect(function(dt)
	if piggyVisualsEnabled then
		piggyUpdateTimer += dt
		if piggyUpdateTimer >= 0.5 then
			updatePiggyESP()
			piggyUpdateTimer = 0
		end
	end
end)

local originalFOV = workspace.CurrentCamera.FieldOfView
local fovConnection = nil
local Lighting = game:GetService("Lighting")
local nightVisionEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local playerESPInstances = {}
local playerRenderConnections = {}

local function clearPlayerESP(player)
    if playerESPInstances[player] then
        playerESPInstances[player]:Destroy()
        playerESPInstances[player] = nil
    end
    if player.Character then
    local hl = player.Character:FindFirstChild("PlayerHighlight")
    if hl then
        hl:Destroy()
    end
end

    if playerRenderConnections[player] then
        playerRenderConnections[player]:Disconnect()
        playerRenderConnections[player] = nil
    end
end

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    local model = workspace:FindFirstChild(player.Name)
    if not model then return end
    local rootPart = model:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "PlayerESP"
    gui.Adornee = rootPart
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 150, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.LightInfluence = 0
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(255, 255, 0)
    frame.Parent = gui

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -10, 0, 25)
    name.Position = UDim2.new(0, 5, 0, 0)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.fromRGB(255, 255, 0)
    name.TextStrokeTransparency = 0.7
    name.Font = Enum.Font.SourceSansBold
    name.TextSize = 18
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Text = player.Name
    name.Parent = frame
    
    -- Add Highlight
local highlight = Instance.new("Highlight")
highlight.Name = "PlayerHighlight"
highlight.Adornee = model
highlight.FillColor = Color3.fromRGB(0, 255, 255) -- Cyan
highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
highlight.FillTransparency = 0.35
highlight.OutlineTransparency = 0.1
highlight.Parent = model


    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, -10, 0, 20)
    distLabel.Position = UDim2.new(0, 5, 0, 25)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distLabel.TextStrokeTransparency = 0.7
    distLabel.Font = Enum.Font.SourceSansItalic
    distLabel.TextSize = 14
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Text = ""
    distLabel.Parent = frame

    gui.Parent = game.CoreGui
    playerESPInstances[player] = gui

    playerRenderConnections[player] = RunService.RenderStepped:Connect(function()
        if not rootPart:IsDescendantOf(workspace) or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            clearPlayerESP(player)
            return
        end
        local dist = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if dist > maxDistance then
            gui.Enabled = false
        else
            gui.Enabled = true
            distLabel.Text = string.format("Distance: %.1f studs", dist)
        end
    end)
end

-- Toggle and update loop
local playerESPEnabled = false

RunService.Heartbeat:Connect(function()
    if playerESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not playerESPInstances[player] then
                createPlayerESP(player)
            end
        end
    end
end)

-- Toggle ESP on Visual tab (assuming Tabs.Visual already exists)
local VisualToggle = Tabs.Visual:AddToggle("ItemESP", {
	Title = "Item ESP",
	Default = false
})

VisualToggle:OnChanged(function(value)
	VisualsEnabled = value
	if not value then
		if ESPFolder then
			for item, _ in pairs(itemESPInstances) do
				clearESP(item)
			end
			ESPFolder:Destroy()
			ESPFolder = nil
		end
	end
end)


-- Fluent UI toggle
Tabs.Visual:AddToggle("PiggyESP", {
	Title = "Piggy ESP",
	Default = false
}):OnChanged(function(value)
	piggyVisualsEnabled = value
	if not value then
		for piggy in pairs(piggyESPInstances) do
			clearPiggyESP(piggy)
		end
	end
end)

Tabs.Visual:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Default = false
}):OnChanged(function(state)
    playerESPEnabled = state
    if not state then
        for player, _ in pairs(playerESPInstances) do
            clearPlayerESP(player)
        end
    end
end)

Tabs.Visual:AddToggle("NightVision", {
    Title = "Night Vision",
    Description = "Brightens dark areas for visibility",
    Default = false
}):OnChanged(function(state)
    nightVisionEnabled = state
    if state then
        Lighting.Brightness = 4
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoorAmbient
    end
end)

Tabs.Visual:AddSlider("FOVSlider", {
	Title = "Adjustable FOV",
	Description = "Set your camera Field of View",
	Default = originalFOV,
	Min = 40,
	Max = 120,
	Rounding = 0,
}):OnChanged(function(value)
	workspace.CurrentCamera.FieldOfView = value
end)

Tabs.Visual:AddSlider("ZoomSlider", {
	Title = "Max Zoom Distance",
	Description = "Set your max camera zoom",
	Default = 128,
	Min = 10,
	Max = 500,
	Rounding = 0,
}):OnChanged(function(value)
	LocalPlayer.CameraMaxZoomDistance = value
end)

--==Items Tab=--

local selectedItem = nil
local originalPosition = nil

local function getItemsFolder()
    if workspace:FindFirstChild("ItemFolder") then
        return workspace.ItemFolder
    end
    for _, child in pairs(workspace:GetChildren()) do
        if child:IsA("Folder") and tostring(child.Name):match("^%-?%d+$") then
            return child
        end
    end
    return nil
end

-- Helper to update dropdown values
local function refreshItemDropdown()
    local itemsFolder = getItemsFolder()
    if not itemsFolder then return end

    local itemNames = {}
    for _, item in pairs(itemsFolder:GetChildren()) do
        table.insert(itemNames, item.Name)
    end

    local dropdown = Options and Options.ItemTeleportDropdown
    if dropdown then
        dropdown:SetValues(itemNames)
    end
end

-- Dropdown to select an item
Tabs.Items:AddDropdown("ItemTeleportDropdown", {
    Title = "Item Teleport",
    Description = "Select an item to teleport to",
    Values = {},
    Callback = function(selected)
        selectedItem = selected
    end
})

-- Button to teleport to selected item
Tabs.Items:AddButton({
    Title = "📦 Teleport to Item",
    Description = "Teleports you to the selected item from the list.",
    Callback = function()
        if not selectedItem then return end

        local itemsFolder = getItemsFolder()
        if not itemsFolder then return end

        for _, item in pairs(itemsFolder:GetChildren()) do
            if item.Name == selectedItem then
                local root = getRoot()
                if root then
                    originalPosition = root.CFrame
                    local target = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                    if target then
                        root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                    end
                end
                break
            end
        end
    end
})

-- Return to original position
Tabs.Items:AddButton({
    Title = "↩ Return to Original Position",
    Description = "Teleport back to where you were before item teleport",
    Callback = function()
        local root = getRoot()
        if root and originalPosition then
            root.CFrame = originalPosition
            originalPosition = nil
        end
    end
})

-- Manual refresh button
Tabs.Items:AddButton({
    Title = "🔄 Refresh Item List",
    Description = "Manually refresh the list of items for teleportation.",
    Callback = function()
        refreshItemDropdown()
    end
})

-- Auto refresh after a short delay to ensure dropdown is initialized
task.delay(1, function()
    while true do
        if Options and Options.ItemTeleportDropdown then
            refreshItemDropdown()
        end
        task.wait(2)
    end
end)
























local Options = Fluent.Options

-- Set up SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The UI has loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()

