-- Load Fluent and Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Required Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

-- Create Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Sealient's 3008 UI",
    SubTitle = "Made By Sealient.",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Define Tabs
local Tabs = {
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    World = Window:AddTab({ Title = "World", Icon = "cloud" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "axe" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Helpers
local function getHumanoid()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
end

-- Player Tab: WalkSpeed
Tabs.Player:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0,
    Callback = function(val)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = val end
    end
})

-- Player Tab: JumpPower
Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Height",
    Min = 50,
    Max = 300,
    Default = 50,
    Rounding = 0,
    Callback = function(val)
        local hum = getHumanoid()
        if hum then hum.JumpPower = val end
    end
})

-- Player Tab: Third-Person Unlocker
Tabs.Visual:AddToggle("ThirdPerson", {
    Title = "Third-Person Unlocker",
    Description = "Unlocks zoom and disables shift lock restrictions",
    Default = false,
    Callback = function(enabled)
        if enabled then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 1000
        else
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end
})

local NoclipEnabled = false
local NoclipConnection

local function SetNoclip(enabled)
    if NoclipConnection then NoclipConnection:Disconnect() end
    if enabled then
        NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local noclipToggle = Tabs.Player:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Default = false
})
noclipToggle:OnChanged(function(state)
    NoclipEnabled = state
    SetNoclip(state)
end)

-- Infinite Jump Toggle
local InfiniteJumpEnabled = false
local jumpConn

local function EnableInfiniteJump(enabled)
    if jumpConn then jumpConn:Disconnect() end
    if enabled then
        jumpConn = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

local infiniteJumpToggle = Tabs.Player:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Default = false
})
infiniteJumpToggle:OnChanged(function(enabled)
    InfiniteJumpEnabled = enabled
    EnableInfiniteJump(enabled)
end)

-- FOV Slider
local defaultFOV = workspace.CurrentCamera.FieldOfView
local fovSlider = Tabs.Visual:AddSlider("FOVSlider", {
    Title = "FOV Changer",
    Description = "Adjust camera FOV",
    Default = defaultFOV,
    Min = 40,
    Max = 120,
    Rounding = 0,
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})



local infoGui = Instance.new("ScreenGui")
infoGui.Name = "SealientUI_Info"
infoGui.ResetOnSpawn = false
infoGui.IgnoreGuiInset = true
infoGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 60)
frame.Position = UDim2.new(1, -230, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Parent = infoGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 25)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextStrokeTransparency = 0.7
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Sealient's 3008 UI"
title.Parent = frame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -10, 0, 20)
fpsLabel.Position = UDim2.new(0, 5, 0, 25)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextStrokeTransparency = 0.7
fpsLabel.Font = Enum.Font.SourceSansItalic
fpsLabel.TextSize = 14
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = frame

local CurrentVersion = "1.2.0" -- your current version

-- FPS Calculation
local lastTime = tick()
local frames = 0
RunService.RenderStepped:Connect(function()
	frames += 1
	local currentTime = tick()
	if currentTime - lastTime >= 1 then
		fpsLabel.Text = string.format("FPS: %d   Version: %s", frames, tostring(CurrentVersion or "Unknown"))
		frames = 0
		lastTime = currentTime
	end
end)

local function cleanupOldUI()
    -- Disconnect ESP connections
    for item, conn in pairs(itemRenderConnections or {}) do
        if conn.Disconnect then conn:Disconnect() end
    end
    itemRenderConnections = {}
    
    -- Destroy ESP GUI instances
    for item, gui in pairs(itemESPInstances or {}) do
        if gui and gui.Destroy then gui:Destroy() end
    end
    itemESPInstances = {}

    -- Destroy coordinate display
    local coordGui = game:GetService("CoreGui"):FindFirstChild("CoordDisplay")
    if coordGui then coordGui:Destroy() end

    -- Destroy FPS counter UI
    local fpsGui = game:GetService("CoreGui"):FindFirstChild("SealientFPSDisplay")
    if fpsGui then fpsGui:Destroy() end

    -- Destroy Fluent UI Window
    if Window and Window.Close then
        Window:Close()
    end

    -- Optionally reset references
    Window = nil
end


Tabs.Settings:AddButton({
    Title = "Check Version",
    Description = "Check for updates and apply them.",
    Callback = function()
        task.spawn(function()
            local versionUrl = "https://raw.githubusercontent.com/Sealient/Sealients-Roblox-Scripts/refs/heads/main/Sealient%27s%203008%20UI%20Version.lua"
            local scriptUrl = "https://raw.githubusercontent.com/Sealient/Sealients-Roblox-Scripts/refs/heads/main/Sealient%27s%203008%20UI.lua"

            local success, result = pcall(function()
                return game:HttpGet(versionUrl)
            end)

            if success then
                local remoteVersion = result:match("[^\r\n]+")
                if remoteVersion and remoteVersion ~= CurrentVersion then
                    cleanupOldUI() -- cleanup before update

                    local _, scriptSource = pcall(function()
                        return game:HttpGet(scriptUrl)
                    end)

                    if scriptSource then
                        loadstring(scriptSource)()
                    else
                        warn("Failed to load updated script.")
                    end
                else
                    Window:Dialog({
                        Title = "No Update",
                        Content = "You are on the latest version.",
                        Buttons = {{ Title = "OK" }}
                    })
                end
            else
                warn("Failed to check version:", result)
            end
        end)
    end
})



-- Coordinate UI (on-screen display)
local coordGui = Instance.new("ScreenGui")
coordGui.Name = "CoordDisplay"
coordGui.ResetOnSpawn = false
coordGui.Parent = game:GetService("CoreGui")

local coordFrame = Instance.new("Frame")
coordFrame.Size = UDim2.new(0, 160, 0, 50)
coordFrame.Position = UDim2.new(0, 10, 1, -70)
coordFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
coordFrame.BackgroundTransparency = 0.5
coordFrame.BorderSizePixel = 1
coordFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
coordFrame.Parent = coordGui

local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(1, -10, 0, 25)
coordLabel.Position = UDim2.new(0, 5, 0, 0)
coordLabel.BackgroundTransparency = 1
coordLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
coordLabel.TextStrokeTransparency = 0.7
coordLabel.Font = Enum.Font.SourceSansBold
coordLabel.TextSize = 18
coordLabel.TextXAlignment = Enum.TextXAlignment.Left
coordLabel.Text = "Coordinates"
coordLabel.Parent = coordFrame

local coordValueLabel = Instance.new("TextLabel")
coordValueLabel.Size = UDim2.new(1, -10, 0, 20)
coordValueLabel.Position = UDim2.new(0, 5, 0, 25)
coordValueLabel.BackgroundTransparency = 1
coordValueLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
coordValueLabel.TextStrokeTransparency = 0.7
coordValueLabel.Font = Enum.Font.SourceSansItalic
coordValueLabel.TextSize = 14
coordValueLabel.TextXAlignment = Enum.TextXAlignment.Left
coordValueLabel.Text = ""
coordValueLabel.Parent = coordFrame

RunService.RenderStepped:Connect(function()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local pos = root.Position
		coordValueLabel.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
	else
		coordValueLabel.Text = "X: --  Y: --  Z: --"
	end
end)

-- Utility Tab: Time of Day
Tabs.World:AddSlider("TimeOverride", {
    Title = "Time of Day Override",
    Description = "Only changes how the world looks to you.",
    Min = 0,
    Max = 24,
    Rounding = 1,
    Default = 14,
    Callback = function(val)
        Lighting.ClockTime = val
    end
})

-- Utility Tab: Reset Visuals
Tabs.World:AddButton({
    Title = "Reset Visual Settings",
    Description = "Resets FOV and lighting to default.",
    Callback = function()
        Camera.FieldOfView = 70
        Lighting.ClockTime = 14
        Fluent:Notify({
            Title = "Visuals Reset",
            Content = "FOV and ClockTime reset.",
            Duration = 5
        })
    end
})

local Lighting = game:GetService("Lighting")

local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalFogColor = Lighting.FogColor

Tabs.World:AddToggle("NoFog", {
    Title = "No Fog",
    Description = "Disables all fog for better visibility.",
    Default = false,
    Callback = function(enabled)
        if enabled then
            -- Disable fog by pushing it far away
            Lighting.FogStart = 1e9
            Lighting.FogEnd = 1e10
        else
            -- Restore original fog settings
            Lighting.FogStart = originalFogStart
            Lighting.FogEnd = originalFogEnd
            Lighting.FogColor = originalFogColor
        end
    end
})
-- Services
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local floorFolder = workspace:WaitForChild("GameObjects"):WaitForChild("Physical"):WaitForChild("Map"):WaitForChild("Floor")

-- Config
local searchRadius = 50
local validItemNames = {
	["2 litre Dr. Bob"] = true, ["Apple"] = true, ["Banana"] = true, ["Beans"] = true,
	["Bloxy Soda"] = true, ["Burger"] = true, ["Meatballs"] = true, ["Chips"] = true,
	["Hotdog"] = true, ["Lemon"] = true, ["Pizza"] = true, ["Striped Donut"] = true,
	["Water"] = true, ["Medkit"] = true, ["Dr. Bob Soda"] = true, ["Ice Cream"] = true,
	["Cookie"] = true, ["Lemon Slice"] = true, ["Fish Crackers"] = true
}

-- State
local itemMap = {} -- [DisplayName] = Instance
local originalPosition = nil
local itemDropdown = nil

-- Helpers
local function getRoot()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function findNearbyItems()
	itemMap = {}
	local root = getRoot()
	if not root then return end

	for _, model in floorFolder:GetChildren() do
		if model:IsA("Model") then
			local itemsFolder = model:FindFirstChild("Items")
			if itemsFolder then
				for _, item in itemsFolder:GetChildren() do
					if validItemNames[item.Name] then
						local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
						if part then
							local dist = (part.Position - root.Position).Magnitude
							if dist <= searchRadius then
								local name = string.format("%s (%.0f studs)", item.Name, dist)
								itemMap[name] = item
							end
						end
					end
				end
			end
		end
	end
end

local function teleportTo(item)
	local root = getRoot()
	if not root then return end

	if not originalPosition then
		originalPosition = root.CFrame
	end

	local pos
	if item:IsA("BasePart") then
		pos = item.Position
	elseif item:IsA("Model") then
		local pp = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
		if pp then
			pos = pp.Position
		else
			local cf = item:GetBoundingBox()
			pos = cf.Position
		end
	end

	if pos then
		root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
	else
		warn("[Teleport] Could not determine item position.")
	end
end

local function refreshItemDropdown()
	findNearbyItems()
	local entries = {}
	for name in pairs(itemMap) do
		table.insert(entries, name)
	end
	table.sort(entries)

	if itemDropdown then
		itemDropdown:SetValues(entries)
	else
		itemDropdown = Tabs.Utility:AddDropdown("ItemTPDropdown", {
			Title = "Teleport to Item",
			Description = "Select a nearby item to teleport to.",
			Values = entries,
			Multi = false,
			Callback = function(selected)
				local item = itemMap[selected]
				if item then teleportTo(item) end
			end
		})
	end
end

-- UI Controls
Tabs.Utility:AddSlider("ItemSearchRadius", {
	Title = "Item Search Radius",
	Description = "Max distance to find valid items",
	Default = 50,
	Min = 10,
	Max = 200,
	Rounding = 0,
	Callback = function(val)
		searchRadius = val
	end
})

Tabs.Utility:AddButton({
	Name = "RefreshNearbyItems", -- optional internal name, if supported
	Title = "🔄 Refresh Nearby Items",
	Description = "Scan for items within range",
	Callback = refreshItemDropdown
})


Tabs.Utility:AddButton({
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



----------------------------
-- Employee ESP Functions --
----------------------------
local EMPLOYEE_FOLDER = Workspace:WaitForChild("GameObjects"):WaitForChild("Physical"):WaitForChild("Employees")

local maxDistance = 1000
local ESP_NAME = "EmployeeESP"
local employeeESPInstances = {}
local employeeRenderConnections = {}

local enabled = false

-- Cleanup for a single ESP
local function clearESP(model)
	if employeeRenderConnections[model] then
		employeeRenderConnections[model]:Disconnect()
		employeeRenderConnections[model] = nil
	end
	if employeeESPInstances[model] then
		employeeESPInstances[model]:Destroy()
		employeeESPInstances[model] = nil
	end
end

-- Cleanup all ESPs
local function clearAllESP()
	for model in pairs(employeeESPInstances) do
		clearESP(model)
	end
end

-- Create ESP for an employee
local function createEmployeeESP(model)
	if employeeESPInstances[model] then return end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local adornee = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
	if not humanoid or not adornee then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = ESP_NAME
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

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	nameLabel.TextStrokeTransparency = 0.7
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 18
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = model.Name
	nameLabel.Parent = frame

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

	gui.Parent = model
	employeeESPInstances[model] = gui

	employeeRenderConnections[model] = RunService.RenderStepped:Connect(function()
		if not adornee:IsDescendantOf(Workspace) or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			clearESP(model)
			return
		end
		local dist = (adornee.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		if dist > maxDistance or not enabled then
			gui.Enabled = false
		else
			gui.Enabled = true
			distLabel.Text = string.format("Distance: %.1f studs", dist)
		end
	end)
end

-- Initialize ESP for all employees
local function initEmployeeESP()
	clearAllESP()
	for _, model in ipairs(EMPLOYEE_FOLDER:GetChildren()) do
		if model:FindFirstChildOfClass("Humanoid") then
			createEmployeeESP(model)
		end
	end
end

-- Monitor new employees added
local employeeAddedConn
local function connectEmployeeAdded()
	if employeeAddedConn then employeeAddedConn:Disconnect() end
	employeeAddedConn = EMPLOYEE_FOLDER.ChildAdded:Connect(function(model)
		task.delay(0.2, function()
			if model:FindFirstChildOfClass("Humanoid") then
				createEmployeeESP(model)
			end
		end)
	end)
end

-- Fluent UI Visual Tab Integration
Tabs.Visual:AddToggle("ESP_Employees", {
	Title = "👷 Employee ESP",
	Description = "Show ESP for employees within range",
	Default = false,
	Callback = function(state)
		enabled = state
		if state then
			initEmployeeESP()
			connectEmployeeAdded()
		else
			clearAllESP()
			if employeeAddedConn then
				employeeAddedConn:Disconnect()
				employeeAddedConn = nil
			end
		end
	end
})

Tabs.Visual:AddSlider("ESP_EmployeeRange", {
	Title = "👁️ Employee ESP Max Range",
	Description = "Max distance to show employee ESP",
	Default = maxDistance,
	Min = 50,
	Max = 2000,
	Rounding = 0,
	Callback = function(val)
		maxDistance = val
	end
})

------------------------
-- Item ESP Functions --
------------------------

-- Reference to game folders
local floorFolder = Workspace:WaitForChild("GameObjects"):WaitForChild("Physical"):WaitForChild("Map"):WaitForChild("Floor")

-- Set of item names we care about
local validItemNames = {
	["2 litre Dr. Bob"] = true, ["Apple"] = true, ["Banana"] = true, ["Beans"] = true,
	["Bloxy Soda"] = true, ["Burger"] = true, ["Meatballs"] = true, ["Chips"] = true,
	["Hotdog"] = true, ["Lemon"] = true, ["Pizza"] = true, ["Striped Donut"] = true,
	["Water"] = true, ["Medkit"] = true, ["Dr. Bob Soda"] = true, ["Ice Cream"] = true,
	["Cookie"] = true, ["Lemon Slice"] = true, ["Fish Crackers"] = true
}

-- State
local itemESPInstances = {}
local itemRenderConnections = {}
local maxDistance = 250
local itemConn

-- Clean up ESP
local function clearESP(item)
	if itemESPInstances[item] then
		itemESPInstances[item]:Destroy()
		itemESPInstances[item] = nil
	end
	if itemRenderConnections[item] then
		itemRenderConnections[item]:Disconnect()
		itemRenderConnections[item] = nil
	end
end

-- Create ESP for item
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

	gui.Parent = item
	itemESPInstances[item] = gui

	itemRenderConnections[item] = RunService.RenderStepped:Connect(function()
		if not adornee:IsDescendantOf(Workspace) or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			clearESP(item)
			return
		end
		local dist = (adornee.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		if dist > maxDistance then
			gui.Enabled = false
		else
			gui.Enabled = true
			distLabel.Text = string.format("Distance: %.1f studs", dist)
		end
	end)
end

-- Scan all items on map
local function scanItems()
	for _, model in pairs(floorFolder:GetChildren()) do
		local itemsFolder = model:FindFirstChild("Items")
		if itemsFolder then
			for _, item in pairs(itemsFolder:GetChildren()) do
				if validItemNames[item.Name] then
					clearESP(item)
					createItemESP(item)
				end
			end
			itemsFolder.ChildAdded:Connect(function(item)
				if validItemNames[item.Name] then
					clearESP(item)
					createItemESP(item)
				end
			end)
		end
	end
end

-- Cleanup
local function removeItemESP()
	if itemConn then itemConn:Disconnect() end
	for item in pairs(itemESPInstances) do
		clearESP(item)
	end
	itemESPInstances = {}
	itemRenderConnections = {}
end

-- Enable full system
local function enableItemESP()
	removeItemESP()
	scanItems()

	itemConn = floorFolder.ChildAdded:Connect(function(newModel)
		if newModel:IsA("Model") then
			local itemsFolder = newModel:WaitForChild("Items", 5)
			if itemsFolder then
				for _, item in pairs(itemsFolder:GetChildren()) do
					if validItemNames[item.Name] then
						clearESP(item)
						createItemESP(item)
					end
				end
				itemsFolder.ChildAdded:Connect(function(item)
					if validItemNames[item.Name] then
						clearESP(item)
						createItemESP(item)
					end
				end)
			end
		end
	end)
end

-- 📦 UI Toggles and Range Slider
Tabs.Visual:AddToggle("ESP_Items", {
	Title = "📦 Item ESP",
	Description = "Shows ESP only on valid nearby items",
	Default = false,
	Callback = function(state)
		if state then enableItemESP() else removeItemESP() end
	end
})

Tabs.Visual:AddSlider("ESP_ItemRange", {
	Title = "📏 Item ESP Max Range",
	Description = "Max distance to show item ESP",
	Default = maxDistance,
	Min = 50,
	Max = 500,
	Rounding = 0,
	Callback = function(val)
		maxDistance = val
	end
})





-- Save Manager Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/Game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Sealient's 3008 UI",
    Content = "Loaded successfully, Please Enjoy.",
    Duration = 6
})

Fluent:Notify({
    Title = "Discord",
    Content = "S6c5we5D4J",
    Duration = 3
})

SaveManager:LoadAutoloadConfig()
