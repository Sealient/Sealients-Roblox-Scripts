local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local currentVersion = "1.0.0"  -- Your current script version
local updateUrl = "https://raw.githubusercontent.com/yourusername/yourrepo/main/yourScript.lua" -- Replace with your raw script URL
local versionUrl = "https://raw.githubusercontent.com/yourusername/yourrepo/main/version.txt" -- URL pointing to a small file containing just the version string
_G.PiggyUI_Version = "v1.0.0"
_G.PiggyUI_Version = _G.PiggyUI_Version or "Broken Version, Might Not Be The Creators Version."

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

-- Create the info GUI
local infoGui = Instance.new("ScreenGui")
infoGui.Name = "PiggyUI_Info"
infoGui.ResetOnSpawn = false
infoGui.IgnoreGuiInset = true
infoGui.Parent = CoreGui

-- Create the frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 60)
frame.Position = UDim2.new(1, -230, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Parent = infoGui

-- Title label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 25)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextStrokeTransparency = 0.7
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Sealient's Piggy UI"
title.Parent = frame

-- FPS + Version label
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -10, 0, 20)
fpsLabel.Position = UDim2.new(0, 5, 0, 25)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextStrokeTransparency = 0.7
fpsLabel.Font = Enum.Font.SourceSansItalic
fpsLabel.TextSize = 14
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Text = "FPS: ... | Version: " .. tostring(_G.PiggyUI_Version)
fpsLabel.Parent = frame

-- FPS updater coroutine
task.spawn(function()
    local lastTime = tick()
    local frameCount = 0
    while true do
        frameCount += 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. tostring(frameCount) .. " | Version: " .. tostring(_G.PiggyUI_Version)
            frameCount = 0
            lastTime = currentTime
        end
        RunService.RenderStepped:Wait()
    end
end)

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
local itemDropdown = nil -- store the dropdown reference here
local TweenService = game:GetService("TweenService")

local function playTeleportEffect(position)
    -- Create a purple sphere
    local effectPart = Instance.new("Part")
    effectPart.Size = Vector3.new(2, 2, 2)
    effectPart.Shape = Enum.PartType.Ball
    effectPart.Anchored = true
    effectPart.CanCollide = false
    effectPart.Material = Enum.Material.Neon
    effectPart.Color = Color3.fromRGB(170, 0, 255)
    effectPart.Position = position
    effectPart.Transparency = 0.5
    effectPart.Parent = workspace

    -- Tween it to grow and fade out
    local growTween = TweenService:Create(effectPart, TweenInfo.new(0.5), {
        Size = Vector3.new(6, 6, 6),
        Transparency = 1
    })
    growTween:Play()

    -- Cleanup after
    growTween.Completed:Connect(function()
        effectPart:Destroy()
    end)
end

local function getRoot()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character.HumanoidRootPart
    end
    return nil
end

-- Item folder getter
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

-- Refresh the dropdown values
local function refreshItemDropdown()
    local itemsFolder = getItemsFolder()
    if not itemsFolder then
        warn("No item folder found")
        return
    end

    local itemNames = {}
    for _, item in pairs(itemsFolder:GetChildren()) do
        table.insert(itemNames, item.Name)
    end

    if itemDropdown then
        itemDropdown:SetValues(itemNames)
    else
        warn("Dropdown not ready")
    end
end

-- Create dropdown and save the reference
itemDropdown = Tabs.Items:AddDropdown("ItemTeleportDropdown", {
    Title = "Item Teleport",
    Description = "Select an item to teleport to",
    Values = {},
    Callback = function(selected)
        selectedItem = selected
    end
})

-- Add teleport button
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
                    playTeleportEffect(root.Position)
                    local target = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                    if target then
                        root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                        playTeleportEffect(root.Position)
                    else
                        warn("No BasePart in selected item")
                    end
                end
                break
            end
        end
    end
})

-- Return button
Tabs.Items:AddButton({
    Title = "↩ Return to Original Position",
    Description = "Teleport back to where you were before item teleport",
    Callback = function()
        local root = getRoot()
        if root and originalPosition then
            playTeleportEffect(root.Position)
            root.CFrame = originalPosition
            playTeleportEffect(root.Position)
            originalPosition = nil
        end
    end
})

-- Manual refresh
Tabs.Items:AddButton({
    Title = "🔄 Refresh Item List",
    Description = "Manually refresh the list of items for teleportation.",
    Callback = function()
        refreshItemDropdown()
    end
})

-- Automatic periodic refresh
task.spawn(function()
    while true do
        if itemDropdown then
            refreshItemDropdown()
        end
        task.wait(3)
    end
end)

--==Players tab==--
local infiniteJumpEnabled = false
local noclip = false

local function getHumanoid()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
end

-- Player Tab: WalkSpeed
Tabs.Player:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Description = "Adjust your walking speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Height",
    Description = "Adjust your jump power.",
    Min = 50,
    Max = 200,
    Default = 50,
    Rounding = 0,
    Callback = function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = value
        end
    end
})

Tabs.Player:AddToggle("InfiniteJump", {
    Title = " Infinite Jump",
    Description = "Jump endlessly, even in mid-air.",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Tabs.Player:AddToggle("Noclip", {
    Title = "Noclip",
    Description = "Walk through walls and objects.",
    Default = false,
    Callback = function(value)
        noclip = value
    end
})

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

Tabs.Player:AddToggle("UnlockCamera", {
    Title = "Third-Person Camera",
    Description = "Unlocks full third-person camera freedom.",
    Default = false,
    Callback = function(value)
        if value then
            LocalPlayer.CameraMaxZoomDistance = 1000
        else
            LocalPlayer.CameraMaxZoomDistance = 10
        end
    end
})

--==Settings tab==--
-- Add Check for Updates button in Settings tab
Tabs.Settings:AddButton({
    Title = "🔄 Check for Updates",
    Description = "Check if a newer version of the script is available",
    Callback = function()
        local currentVersion = _G.PiggyUI_Version or "Unknown"
        local httpService = game:GetService("HttpService")

        local success, latestVersionRaw = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/Sealient/Sealients-Roblox-Scripts/refs/heads/main/PiggyUI_Version.txt")
        end)

        if not success or not latestVersionRaw then
            Window:Dialog({
                Title = "Error",
                Content = "Failed to check for updates. Please try again later.",
                Buttons = { { Title = "OK", Callback = function() end } }
            })
            return
        end

        local latestVersion = latestVersionRaw:match("^%s*(.-)%s*$") -- trim whitespace

        if latestVersion == currentVersion then
            Window:Dialog({
                Title = "Up to Date",
                Content = "You are running the latest version (" .. currentVersion .. ").",
                Buttons = { { Title = "OK", Callback = function() end } }
            })
            return
        end

        -- Prompt user for update
        Window:Dialog({
            Title = "Update Available",
            Content = ("Current: %s\nLatest: %s\nDo you want to update now?"):format(currentVersion, latestVersion),
            Buttons = {
                {
                    Title = "Update",
                    Callback = function()
                        -- Cleanup your UI and resources here if necessary
                        local coreGui = game:GetService("CoreGui")

                        -- Remove your info UI if exists
                        local infoUI = coreGui:FindFirstChild("PiggyUI_Info")
                        if infoUI then infoUI:Destroy() end

                        -- Destroy main window if needed
                        if Window and typeof(Window.Destroy) == "function" then
                            Window:Destroy()
                        end

                        -- Load updated script
                        local loadSuccess, loadErr = pcall(function()
                            loadstring(game:HttpGet("https://raw.githubusercontent.com/Sealient/Sealients-Roblox-Scripts/refs/heads/main/PiggyUI.lua"))()
                        end)

                        if not loadSuccess then
                            warn("Failed to load updated Piggy script:", loadErr)
                            Window:Dialog({
                                Title = "Update Failed",
                                Content = "Unable to load the new version. Please try again later.",
                                Buttons = { { Title = "OK", Callback = function() end } }
                            })
                        end
                    end,
                },
                {
                    Title = "Cancel",
                    Callback = function() end
                }
            }
        })
    end
})
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
