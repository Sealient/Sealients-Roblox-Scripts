-- Rodus UI Library
local Rodus = {}


function Rodus:CreateMain(title)
	local player = game.Players.LocalPlayer
	local parent = player:WaitForChild("PlayerGui")

	-- Destroy existing UI with same name
	local destroyIfExist = parent:GetChildren()
	for _, gui in pairs(destroyIfExist) do
		if gui.Name == title then
			print("Destroyed "..tostring(title)..": Already existed")
			gui:Destroy()
		end
	end

	-- Main UI Instances
	local Rodus = Instance.new("ScreenGui")
	local Top = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local Container = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")
	local Minimize = Instance.new("TextButton")

	-- ScreenGui Setup
	Rodus.Name = tostring(title)
	Rodus.Parent = parent
	Rodus.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Top Frame
	Top.Name = "Top"
	Top.Parent = Rodus
	Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Top.BackgroundTransparency = 0.500
	Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Top.BorderSizePixel = 4
	Top.Position = UDim2.new(0, 15, 0, 15)
	Top.Size = UDim2.new(0, 193, 0, 27)

	-- Title
	Title.Name = "Title"
	Title.Parent = Top
	Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Title.BackgroundTransparency = 0.350
	Title.BorderSizePixel = 0
	Title.Size = UDim2.new(0, 193, 0, 27)
	Title.Font = Enum.Font.JosefinSans
	Title.Text = " "..title
	Title.TextColor3 = Color3.fromRGB(0, 255, 0)
	Title.TextSize = 14.000
	Title.TextXAlignment = Enum.TextXAlignment.Left

	-- Container
	Container.Name = "Container"
	Container.Parent = Top
	Container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Container.BackgroundTransparency = 0.500
	Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Container.BorderSizePixel = 4
	Container.Position = UDim2.new(0, 0, 1.29629624, 0)
	Container.Size = UDim2.new(0, 193, 0, 24)

	UIListLayout.Parent = Container
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Minimize Button
	Minimize.Name = "Minimize"
	Minimize.Parent = Top
	Minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Minimize.BackgroundTransparency = 1.000
	Minimize.Position = UDim2.new(0.906735778, 0, 0.185185179, 0)
	Minimize.Size = UDim2.new(0, 18, 0, 17)
	Minimize.Font = Enum.Font.SourceSans
	Minimize.Text = "-"
	Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
	Minimize.TextSize = 14.000

	-- Minimize functionality
	local tog_gled = false
	Minimize.MouseButton1Down:Connect(function()
		tog_gled = not tog_gled
		if tog_gled then 
			Minimize.Text = "+" 
			Container.Visible = false 
		else 
			Minimize.Text = "-" 
			Container.Visible = true 
		end
	end)

	-- Toggle visibility with RightControl
	local function onKeyPress(inputObject, gameProcessedEvent)
		if inputObject.KeyCode == Enum.KeyCode.RightControl then
			Top.Visible = not Top.Visible
		end
	end
	game:GetService("UserInputService").InputBegan:Connect(onKeyPress)

	-- Store UI customization settings
	local UISettings = {
		BackgroundTransparency = 0.5,
		TextColor = Color3.fromRGB(0, 255, 0),
		BackgroundColor = Color3.fromRGB(0, 0, 0),
		TextSize = 14,
		Enabled = true
	}

	-- Function to apply UI settings
	local function applyUISettings()
		Top.BackgroundTransparency = UISettings.BackgroundTransparency
		Container.BackgroundTransparency = UISettings.BackgroundTransparency
		Title.TextColor3 = UISettings.TextColor
		Title.TextSize = UISettings.TextSize

		-- Apply to all tabs and elements
		for _, child in pairs(Container:GetChildren()) do
			if child:IsA("TextButton") then
				child.TextSize = UISettings.TextSize
				if child:FindFirstChild("Arrow") then
					child.Arrow.TextSize = UISettings.TextSize
				end
			end
		end
	end

	-- UI Functions
	local uiFunctions = {}
	local customTabs = {} -- Store custom tabs to maintain order
	
	-- Custom Cursor System
	local cursorEnabled = false
	local originalMouseBehavior
	local CustomCursor = Instance.new("Frame")
	local CursorDot = Instance.new("Frame")
	local CursorRing = Instance.new("Frame")

	-- Create custom cursor
	CustomCursor.Name = "CustomCursor"
	CustomCursor.Parent = Rodus
	CustomCursor.BackgroundTransparency = 1
	CustomCursor.Size = UDim2.new(1, 0, 1, 0)
	CustomCursor.Visible = false
	CustomCursor.ZIndex = 1000

	-- Cursor ring
	CursorRing.Name = "CursorRing"
	CursorRing.Parent = CustomCursor
	CursorRing.BackgroundColor3 = UISettings.TextColor
	CursorRing.BackgroundTransparency = 0.3
	CursorRing.BorderSizePixel = 0
	CursorRing.Size = UDim2.new(0, 0, 0, 0)
	CursorRing.Position = UDim2.new(0, -10, 0, -10)
	CursorRing.ZIndex = 1001

	-- Cursor dot
	CursorDot.Name = "CursorDot"
	CursorDot.Parent = CustomCursor
	CursorDot.BackgroundColor3 = UISettings.TextColor
	CursorDot.BorderSizePixel = 0
	CursorDot.Size = UDim2.new(0, 4, 0, 4)
	CursorDot.Position = UDim2.new(0, -2, 0, -2)
	CursorDot.ZIndex = 1002

	-- Make cursor circular
	local ringCorner = Instance.new("UICorner")
	ringCorner.CornerRadius = UDim.new(1, 0)
	ringCorner.Parent = CursorRing

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = CursorDot

	-- Function to toggle cursor
	local function toggleCustomCursor()
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")

		if not cursorEnabled then
			-- Enable custom cursor
			cursorEnabled = true

			-- Store original mouse behavior
			originalMouseBehavior = UserInputService.MouseBehavior

			-- Unlock mouse and keep it unlocked
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default

			-- Show custom cursor
			CustomCursor.Visible = true

			-- Hide original mouse icon
			UserInputService.MouseIconEnabled = false

			-- Continuously prevent mouse from re-locking
			local preventRelockConnection
			preventRelockConnection = RunService.Heartbeat:Connect(function()
				if cursorEnabled and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
			end)

			-- Store the connection so we can disconnect later
			game:GetService("Players").LocalPlayer:SetAttribute("PreventRelockConnection", preventRelockConnection)

			print("Custom cursor enabled - Mouse unlocked")

		else
			-- Disable custom cursor
			cursorEnabled = false

			-- Stop preventing re-lock
			local preventRelockConnection = game:GetService("Players").LocalPlayer:GetAttribute("PreventRelockConnection")
			if preventRelockConnection then
				preventRelockConnection:Disconnect()
				game:GetService("Players").LocalPlayer:SetAttribute("PreventRelockConnection", nil)
			end

			-- Restore original mouse behavior
			if originalMouseBehavior then
				UserInputService.MouseBehavior = originalMouseBehavior
			else
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			end

			-- Hide custom cursor
			CustomCursor.Visible = false

			-- Show original mouse icon
			UserInputService.MouseIconEnabled = true

			print("Custom cursor disabled - Mouse restored")
		end
	end
	
	-- Prevent mouse re-locking on click
	local clickConnection
	clickConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if not cursorEnabled then return end

		-- If it's a mouse click and cursor is enabled, prevent re-locking
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.MouseButton2 or
			input.UserInputType == Enum.UserInputType.MouseButton3 then

			-- Small delay to ensure Roblox doesn't re-lock the mouse
			spawn(function()
				wait(0.01)
				if cursorEnabled then
					game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
				end
			end)
		end
	end)

	-- Update cursor position
	local function updateCursorPosition()
		if not cursorEnabled then return end

		local UserInputService = game:GetService("UserInputService")
		local mouse = game:GetService("Players").LocalPlayer:GetMouse()

		CustomCursor.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	end

	-- Connect mouse movement
	game:GetService("RunService").RenderStepped:Connect(updateCursorPosition)

	-- Add toggle keybind (Insert key by default)
	local cursorKeybind = Enum.KeyCode.Insert
	local keybindConnection

	local function connectCursorKeybind()
		if keybindConnection then
			keybindConnection:Disconnect()
		end

		keybindConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end

			if input.KeyCode == cursorKeybind then
				toggleCustomCursor()
			end
		end)
	end

	-- Connect the keybind initially
	connectCursorKeybind()

	-- Function to change cursor toggle key
	local function setCursorKeybind(newKey)
		cursorKeybind = newKey
		connectCursorKeybind()
		print("Cursor toggle key set to:", newKey.Name)
	end

	function uiFunctions:CreateTab(text)
		local Tab = Instance.new("TextButton")
		local Arrow = Instance.new("TextLabel")

		Tab.Name = text
		Tab.Parent = Container
		Tab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Tab.BackgroundTransparency = 1.000
		Tab.Size = UDim2.new(0, 193, 0, 24)
		Tab.Font = Enum.Font.JosefinSans
		Tab.Text = " "..text
		Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
		Tab.TextSize = UISettings.TextSize
		Tab.TextXAlignment = Enum.TextXAlignment.Left

		Arrow.Name = "Arrow"
		Arrow.Parent = Tab
		Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Arrow.BackgroundTransparency = 1.000
		Arrow.Position = UDim2.new(0.907, 0, 0, 0)
		Arrow.Size = UDim2.new(0, 18, 0, 21)
		Arrow.Font = Enum.Font.SourceSans
		Arrow.Text = ">>"
		Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
		Arrow.TextScaled = true
		Arrow.TextSize = UISettings.TextSize
		Arrow.TextWrapped = true

		-- Update container size
		Container.Size = UDim2.new(0, 193, 0, UIListLayout.AbsoluteContentSize.Y)

		-- Tab Container
		local TabContainer = Instance.new("Frame")
		TabContainer.Name = "TabContainer"
		TabContainer.Parent = Tab
		TabContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		TabContainer.BackgroundTransparency = UISettings.BackgroundTransparency
		TabContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabContainer.BorderSizePixel = 4
		TabContainer.Position = UDim2.new(1.0569948, 0, 0, 0)
		TabContainer.Visible = false

		local UIListLayout2 = Instance.new("UIListLayout")
		UIListLayout2.Parent = TabContainer
		UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder

		-- Tab click functionality
		Tab.MouseButton1Down:Connect(function()
			-- Check if this tab is currently open
			local wasOpen = TabContainer.Visible

			-- First, reset EVERY tab to white and close their containers
			for _, child in pairs(Container:GetChildren()) do
				if child:IsA("TextButton") then
					-- Reset text color to white
					child.TextColor3 = Color3.new(255, 255, 255)

					-- Reset arrow color to white if it exists
					local arrow = child:FindFirstChild("Arrow")
					if arrow then
						arrow.TextColor3 = Color3.new(255, 255, 255)
					end

					-- Close the tab container
					local tabContainer = child:FindFirstChild("TabContainer")
					if tabContainer then
						tabContainer.Visible = false
					end
				end
			end

			-- If this tab wasn't open before, open it and set to green
			if not wasOpen then
				TabContainer.Visible = true
				Tab.TextColor3 = UISettings.TextColor
				if Tab.Arrow then
					Tab.Arrow.TextColor3 = UISettings.TextColor
				end
			end
		end)

		-- Tab-specific functions
		local tabFunctions = {}

		function tabFunctions:CreateSlider(buttonText, minValue, maxValue, defaultValue, callback)
			local Slider = Instance.new("TextButton")
			local Arrow = Instance.new("TextButton")
			local ValueLabel = Instance.new("TextLabel")
			local SliderContainer = Instance.new("Frame")
			local Hover = Instance.new("Frame")

			-- Default values
			minValue = minValue or 0
			maxValue = maxValue or 100
			defaultValue = defaultValue or minValue

			-- Main button
			Slider.Name = buttonText
			Slider.Parent = TabContainer
			Slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Slider.BackgroundTransparency = 1.000
			Slider.Size = UDim2.new(0, 193, 0, 24)
			Slider.Font = Enum.Font.JosefinSans
			Slider.Text = " "..buttonText
			Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
			Slider.TextSize = UISettings.TextSize
			Slider.TextXAlignment = Enum.TextXAlignment.Left

			-- Arrow
			Arrow.Name = "Arrow"
			Arrow.Parent = Slider
			Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.BackgroundTransparency = 1.000
			Arrow.Position = UDim2.new(0.906735778, 0, 0, 0)
			Arrow.Size = UDim2.new(0, 18, 0, 21)
			Arrow.Font = Enum.Font.SourceSans
			Arrow.Text = ">>"
			Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.TextScaled = true
			Arrow.TextSize = UISettings.TextSize
			Arrow.TextWrapped = true

			-- Value display
			ValueLabel.Name = "ValueLabel"
			ValueLabel.Parent = Slider
			ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ValueLabel.BackgroundTransparency = 1.000
			ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
			ValueLabel.Size = UDim2.new(0, 40, 0, 24)
			ValueLabel.Font = Enum.Font.JosefinSans
			ValueLabel.Text = tostring(defaultValue)
			ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			ValueLabel.TextSize = UISettings.TextSize
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

			-- Slider container
			SliderContainer.Name = "SliderContainer"
			SliderContainer.Parent = Slider
			SliderContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			SliderContainer.BackgroundTransparency = UISettings.BackgroundTransparency
			SliderContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderContainer.BorderSizePixel = 4
			SliderContainer.Position = UDim2.new(1.08290148, 0, 0, 0)
			SliderContainer.Size = UDim2.new(0, 193, 0, 40)
			SliderContainer.Visible = false

			-- Hover area
			Hover.Name = "Hover"
			Hover.Parent = Slider
			Hover.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Hover.BackgroundTransparency = 1.000
			Hover.Size = UDim2.new(0, 209, 0, 32)

			-- Slider elements
			local Track = Instance.new("Frame")
			local Fill = Instance.new("Frame")
			local Thumb = Instance.new("Frame")
			local MinLabel = Instance.new("TextLabel")
			local MaxLabel = Instance.new("TextLabel")
			local ValueInput = Instance.new("TextBox")

			-- Track
			Track.Name = "Track"
			Track.Parent = SliderContainer
			Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			Track.BorderSizePixel = 0
			Track.Position = UDim2.new(0.05, 0, 0.4, 0)
			Track.Size = UDim2.new(0, 150, 0, 6)

			-- Fill
			Fill.Name = "Fill"
			Fill.Parent = Track
			Fill.BackgroundColor3 = UISettings.TextColor
			Fill.BorderSizePixel = 0
			Fill.Size = UDim2.new(0.5, 0, 1, 0)

			-- Thumb
			Thumb.Name = "Thumb"
			Thumb.Parent = Track
			Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Thumb.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Thumb.BorderSizePixel = 2
			Thumb.Position = UDim2.new(0.5, -8, -0.5, 0)
			Thumb.Size = UDim2.new(0, 16, 0, 16)
			Thumb.ZIndex = 2

			-- Min label
			MinLabel.Name = "MinLabel"
			MinLabel.Parent = SliderContainer
			MinLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			MinLabel.BackgroundTransparency = 1.000
			MinLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
			MinLabel.Size = UDim2.new(0, 30, 0, 15)
			MinLabel.Font = Enum.Font.JosefinSans
			MinLabel.Text = tostring(minValue)
			MinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			MinLabel.TextSize = 12
			MinLabel.TextXAlignment = Enum.TextXAlignment.Left

			-- Max label
			MaxLabel.Name = "MaxLabel"
			MaxLabel.Parent = SliderContainer
			MaxLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			MaxLabel.BackgroundTransparency = 1.000
			MaxLabel.Position = UDim2.new(0.8, 0, 0.7, 0)
			MaxLabel.Size = UDim2.new(0, 30, 0, 15)
			MaxLabel.Font = Enum.Font.JosefinSans
			MaxLabel.Text = tostring(maxValue)
			MaxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			MaxLabel.TextSize = 12
			MaxLabel.TextXAlignment = Enum.TextXAlignment.Right

			-- Value input
			ValueInput.Name = "ValueInput"
			ValueInput.Parent = SliderContainer
			ValueInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			ValueInput.BorderSizePixel = 1
			ValueInput.Position = UDim2.new(0.65, 0, 0.1, 0)
			ValueInput.Size = UDim2.new(0, 40, 0, 15)
			ValueInput.Font = Enum.Font.JosefinSans
			ValueInput.Text = tostring(defaultValue)
			ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
			ValueInput.TextSize = 12
			ValueInput.ClearTextOnFocus = false

			-- Current value state
			local currentValue = defaultValue

			-- Function to update slider appearance
			local function updateSlider(value)
				currentValue = math.clamp(value, minValue, maxValue)

				-- Calculate fill percentage
				local percentage = (currentValue - minValue) / (maxValue - minValue)
				Fill.Size = UDim2.new(percentage, 0, 1, 0)
				Thumb.Position = UDim2.new(percentage, -8, -0.5, 0)

				-- Update displays
				ValueLabel.Text = tostring(math.floor(currentValue))
				ValueInput.Text = tostring(math.floor(currentValue))

				-- Update fill color to match UI theme
				Fill.BackgroundColor3 = UISettings.TextColor

				-- Call callback
				if callback then
					pcall(callback, currentValue)
				end
			end

			-- Initialize
			updateSlider(defaultValue)

			-- Click to open/close functionality
			local isSliderOpen = false

			Slider.MouseButton1Down:Connect(function()
				if not isSliderOpen then
					-- Close other dropdowns first
					local allContainers = TabContainer:GetDescendants()
					for _, element in pairs(allContainers) do
						if element.Name == "SliderContainer" and element ~= SliderContainer then
							element.Visible = false
						end
						if element.Name == "PickerContainer" then
							element.Visible = false
						end
						if element.Name == "DropContainer" then
							element.Visible = false
							if element.Parent:FindFirstChild("TextColor3") then
								element.Parent.TextColor3 = Color3.new(255, 255, 255)
							end
							if element.Parent:FindFirstChild("Arrow") then
								element.Parent.Arrow.TextColor3 = Color3.new(255, 255, 255)
							end
						end
					end

					-- Open this one
					SliderContainer.Visible = true
					isSliderOpen = true
					Slider.TextColor3 = UISettings.TextColor
					Arrow.TextColor3 = UISettings.TextColor
				else
					-- Close this one
					SliderContainer.Visible = false
					isSliderOpen = false
					Slider.TextColor3 = Color3.new(255, 255, 255)
					Arrow.TextColor3 = Color3.new(255, 255, 255)
				end
			end)

			-- Close slider when clicking elsewhere
			local function closeSlider()
				if isSliderOpen then
					SliderContainer.Visible = false
					isSliderOpen = false
					Slider.TextColor3 = Color3.new(255, 255, 255)
					Arrow.TextColor3 = Color3.new(255, 255, 255)
				end
			end

			-- Close when clicking on other tabs
			for _, child in pairs(Container:GetChildren()) do
				if child:IsA("TextButton") and child ~= Slider then
					child.MouseButton1Down:Connect(closeSlider)
				end
			end

			-- Slider track interaction
			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local connection
					connection = game:GetService("UserInputService").InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
							local xPos = math.clamp((moveInput.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
							local value = minValue + (xPos * (maxValue - minValue))
							updateSlider(value)
						end
					end)

					game:GetService("UserInputService").InputEnded:Connect(function(endInput)
						if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
							connection:Disconnect()
						end
					end)
				end
			end)

			-- Thumb interaction
			Thumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local startPos = input.Position.X
					local startValue = currentValue

					local connection
					connection = game:GetService("UserInputService").InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
							local deltaX = moveInput.Position.X - startPos
							local deltaValue = (deltaX / Track.AbsoluteSize.X) * (maxValue - minValue)
							local newValue = startValue + deltaValue
							updateSlider(newValue)
						end
					end)

					game:GetService("UserInputService").InputEnded:Connect(function(endInput)
						if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
							connection:Disconnect()
						end
					end)
				end
			end)

			-- Value input handler
			ValueInput.FocusLost:Connect(function()
				local num = tonumber(ValueInput.Text)
				if num then
					updateSlider(num)
				else
					ValueInput.Text = tostring(math.floor(currentValue))
				end
			end)

			-- Hover functionality
			Hover.MouseEnter:Connect(function()
				if not isSliderOpen then
					SliderContainer.Visible = true
				end
			end)

			Hover.MouseLeave:Connect(function()
				if not isSliderOpen then
					SliderContainer.Visible = false
				end
			end)

			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)

			return {
				GetValue = function() return currentValue end,
				SetValue = function(value)
					updateSlider(value)
				end,
				SetRange = function(newMin, newMax)
					minValue = newMin or minValue
					maxValue = newMax or maxValue
					MinLabel.Text = tostring(minValue)
					MaxLabel.Text = tostring(maxValue)
					updateSlider(math.clamp(currentValue, minValue, maxValue))
				end
			}
		end
		
		function tabFunctions:CreateKeybind(buttonText, defaultKey, callback)
			local Keybind = Instance.new("TextButton")
			local KeyLabel = Instance.new("TextLabel")
			local ListeningLabel = Instance.new("TextLabel")

			-- Default key
			defaultKey = defaultKey or Enum.KeyCode.RightControl
			local currentKey = defaultKey
			local isListening = false

			-- Main button
			Keybind.Name = buttonText
			Keybind.Parent = TabContainer
			Keybind.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Keybind.BackgroundTransparency = 1.000
			Keybind.Size = UDim2.new(0, 193, 0, 24)
			Keybind.Font = Enum.Font.JosefinSans
			Keybind.Text = " "..buttonText
			Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
			Keybind.TextSize = UISettings.TextSize
			Keybind.TextXAlignment = Enum.TextXAlignment.Left

			-- Key display label
			KeyLabel.Name = "KeyLabel"
			KeyLabel.Parent = Keybind
			KeyLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			KeyLabel.BackgroundTransparency = 1.000
			KeyLabel.Position = UDim2.new(0.7, 0, 0, 0)
			KeyLabel.Size = UDim2.new(0, 60, 0, 24)
			KeyLabel.Font = Enum.Font.JosefinSans
			KeyLabel.Text = tostring(defaultKey.Name):gsub("^%l", string.upper)
			KeyLabel.TextColor3 = UISettings.TextColor
			KeyLabel.TextSize = UISettings.TextSize
			KeyLabel.TextXAlignment = Enum.TextXAlignment.Right

			-- Listening indicator (hidden by default)
			ListeningLabel.Name = "ListeningLabel"
			ListeningLabel.Parent = Keybind
			ListeningLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ListeningLabel.BackgroundTransparency = 1.000
			ListeningLabel.Position = UDim2.new(0.7, 0, 0, 0)
			ListeningLabel.Size = UDim2.new(0, 60, 0, 24)
			ListeningLabel.Font = Enum.Font.JosefinSans
			ListeningLabel.Text = "Listening..."
			ListeningLabel.TextColor3 = Color3.fromRGB(255, 255, 0)  -- Yellow
			ListeningLabel.TextSize = UISettings.TextSize
			ListeningLabel.TextXAlignment = Enum.TextXAlignment.Right
			ListeningLabel.Visible = false

			-- Function to update key display
			local function updateKeyDisplay()
				KeyLabel.Text = tostring(currentKey.Name):gsub("^%l", string.upper)
				ListeningLabel.Visible = false
				KeyLabel.Visible = true
			end

			-- Initialize
			updateKeyDisplay()

			-- Keybind connection
			local keybindConnection
			local function connectKeybind()
				if keybindConnection then
					keybindConnection:Disconnect()
				end

				keybindConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end

					if input.KeyCode == currentKey then
						if callback then
							pcall(callback, true)
						end
					end
				end)
			end

			-- Connect the keybind initially
			connectKeybind()

			-- Button click to change keybind
			Keybind.MouseButton1Down:Connect(function()
				if not isListening then
					-- Start listening for new key
					isListening = true
					KeyLabel.Visible = false
					ListeningLabel.Visible = true
					Keybind.TextColor3 = UISettings.TextColor

					-- Temporary connection to listen for new key
					local tempConnection
					tempConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
						if gameProcessed then return end

						-- Ignore mouse clicks for keybinds
						if input.UserInputType == Enum.UserInputType.MouseButton1 or
							input.UserInputType == Enum.UserInputType.MouseButton2 or
							input.UserInputType == Enum.UserInputType.MouseButton3 then
							return
						end

						-- Set new key
						currentKey = input.KeyCode
						isListening = false
						updateKeyDisplay()
						Keybind.TextColor3 = Color3.new(255, 255, 255)

						-- Reconnect with new key
						connectKeybind()

						-- Disconnect temporary listener
						if tempConnection then
							tempConnection:Disconnect()
						end

						print("Keybind set to:", currentKey.Name)
					end)

					-- Cancel listening if clicked elsewhere or after 5 seconds
					local cancelConnection
					cancelConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
						if input.UserInputType == Enum.UserInputType.MouseButton1 and isListening then
							-- Check if click was outside this keybind
							local mouse = game:GetService("Players").LocalPlayer:GetMouse()
							local keybindAbsolutePos = Keybind.AbsolutePosition
							local keybindAbsoluteSize = Keybind.AbsoluteSize

							if mouse.X < keybindAbsolutePos.X or 
								mouse.X > keybindAbsolutePos.X + keybindAbsoluteSize.X or
								mouse.Y < keybindAbsolutePos.Y or 
								mouse.Y > keybindAbsolutePos.Y + keybindAbsoluteSize.Y then

								isListening = false
								updateKeyDisplay()
								Keybind.TextColor3 = Color3.new(255, 255, 255)

								if tempConnection then
									tempConnection:Disconnect()
								end
								if cancelConnection then
									cancelConnection:Disconnect()
								end
							end
						end
					end)

					-- Auto-cancel after 5 seconds
					delay(5, function()
						if isListening then
							isListening = false
							updateKeyDisplay()
							Keybind.TextColor3 = Color3.new(255, 255, 255)

							if tempConnection then
								tempConnection:Disconnect()
							end
							if cancelConnection then
								cancelConnection:Disconnect()
							end
						end
					end)
				end
			end)

			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)

			return {
				GetKey = function() return currentKey end,
				SetKey = function(newKey)
					currentKey = newKey
					updateKeyDisplay()
					connectKeybind()
				end,
				GetKeyName = function() return tostring(currentKey.Name):gsub("^%l", string.upper) end
			}
		end

		function tabFunctions:CreateColorPicker(buttonText, defaultColor, callback)
			local ColorPicker = Instance.new("TextButton")
			local Arrow = Instance.new("TextButton")
			local ColorPreview = Instance.new("Frame")
			local PickerContainer = Instance.new("Frame")

			-- Default color
			defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)

			-- Main button
			ColorPicker.Name = buttonText
			ColorPicker.Parent = TabContainer
			ColorPicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			ColorPicker.BackgroundTransparency = 1.000
			ColorPicker.Size = UDim2.new(0, 193, 0, 24)
			ColorPicker.Font = Enum.Font.JosefinSans
			ColorPicker.Text = " "..buttonText
			ColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
			ColorPicker.TextSize = UISettings.TextSize
			ColorPicker.TextXAlignment = Enum.TextXAlignment.Left

			-- Arrow
			Arrow.Name = "Arrow"
			Arrow.Parent = ColorPicker
			Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.BackgroundTransparency = 1.000
			Arrow.Position = UDim2.new(0.906735778, 0, 0, 0)
			Arrow.Size = UDim2.new(0, 18, 0, 21)
			Arrow.Font = Enum.Font.SourceSans
			Arrow.Text = ">>"
			Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.TextScaled = true
			Arrow.TextSize = UISettings.TextSize
			Arrow.TextWrapped = true

			-- Color preview
			ColorPreview.Name = "ColorPreview"
			ColorPreview.Parent = ColorPicker
			ColorPreview.BackgroundColor3 = defaultColor
			ColorPreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
			ColorPreview.BorderSizePixel = 1
			ColorPreview.Position = UDim2.new(0.8, 0, 0.2, 0)
			ColorPreview.Size = UDim2.new(0, 12, 0, 12)

			-- Picker container
			PickerContainer.Name = "PickerContainer"
			PickerContainer.Parent = ColorPicker
			PickerContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			PickerContainer.BackgroundTransparency = UISettings.BackgroundTransparency
			PickerContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
			PickerContainer.BorderSizePixel = 4
			PickerContainer.Position = UDim2.new(1.08290148, 0, 0, 0)
			PickerContainer.Size = UDim2.new(0, 193, 0, 80)
			PickerContainer.Visible = false

			-- Color picker elements
			local HueSlider = Instance.new("Frame")
			local HueBar = Instance.new("Frame")
			local HueSelector = Instance.new("Frame")
			local SaturationBrightness = Instance.new("Frame")
			local SaturationBrightnessSelector = Instance.new("Frame")
			local CurrentColor = Instance.new("Frame")
			local HexInput = Instance.new("TextBox")

			-- Hue slider (vertical)
			HueSlider.Name = "HueSlider"
			HueSlider.Parent = PickerContainer
			HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			HueSlider.BorderSizePixel = 1
			HueSlider.Position = UDim2.new(0.8, 0, 0.1, 0)
			HueSlider.Size = UDim2.new(0, 15, 0, 60)

			-- Hue gradient
			HueBar.Name = "HueBar"
			HueBar.Parent = HueSlider
			HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			HueBar.Size = UDim2.new(1, 0, 1, 0)

			local hueUIGradient = Instance.new("UIGradient")
			hueUIGradient.Parent = HueBar
			hueUIGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
			}

			-- Hue selector
			HueSelector.Name = "HueSelector"
			HueSelector.Parent = HueSlider
			HueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			HueSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
			HueSelector.BorderSizePixel = 2
			HueSelector.Size = UDim2.new(1.2, 0, 0, 3)
			HueSelector.Position = UDim2.new(-0.1, 0, 0, 0)

			-- Saturation/Brightness area
			SaturationBrightness.Name = "SaturationBrightness"
			SaturationBrightness.Parent = PickerContainer
			SaturationBrightness.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			SaturationBrightness.BorderSizePixel = 1
			SaturationBrightness.Position = UDim2.new(0.05, 0, 0.1, 0)
			SaturationBrightness.Size = UDim2.new(0, 60, 0, 60)

			local satBrightUIGradient1 = Instance.new("UIGradient")
			satBrightUIGradient1.Parent = SaturationBrightness
			satBrightUIGradient1.Rotation = 90
			satBrightUIGradient1.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			}

			local satBrightUIGradient2 = Instance.new("UIGradient")
			satBrightUIGradient2.Parent = SaturationBrightness
			satBrightUIGradient2.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
			}

			-- Saturation/Brightness selector
			SaturationBrightnessSelector.Name = "SaturationBrightnessSelector"
			SaturationBrightnessSelector.Parent = SaturationBrightness
			SaturationBrightnessSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SaturationBrightnessSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SaturationBrightnessSelector.BorderSizePixel = 1
			SaturationBrightnessSelector.Size = UDim2.new(0, 6, 0, 6)
			SaturationBrightnessSelector.Position = UDim2.new(0.5, -3, 0.5, -3)

			-- Current color display
			CurrentColor.Name = "CurrentColor"
			CurrentColor.Parent = PickerContainer
			CurrentColor.BackgroundColor3 = defaultColor
			CurrentColor.BorderSizePixel = 1
			CurrentColor.Position = UDim2.new(0.7, 0, 0.75, 0)
			CurrentColor.Size = UDim2.new(0, 40, 0, 15)

			-- Hex input
			HexInput.Name = "HexInput"
			HexInput.Parent = PickerContainer
			HexInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			HexInput.BorderSizePixel = 1
			HexInput.Position = UDim2.new(0.05, 0, 0.75, 0)
			HexInput.Size = UDim2.new(0, 50, 0, 15)
			HexInput.Font = Enum.Font.JosefinSans
			HexInput.Text = "#FFFFFF"
			HexInput.TextColor3 = Color3.fromRGB(255, 255, 255)
			HexInput.TextSize = 12
			HexInput.PlaceholderText = "#FFFFFF"

			-- Function to convert Color3 to Hex
			local function RGBToHex(color)
				local r = math.floor(color.R * 255)
				local g = math.floor(color.G * 255)
				local b = math.floor(color.B * 255)
				return string.format("#%02X%02X%02X", r, g, b)
			end

			-- Function to convert Hex to Color3
			local function HexToRGB(hex)
				hex = hex:gsub("#","")
				if #hex == 3 then
					hex = hex:gsub("(.)", "%1%1")
				end
				local r = tonumber("0x"..hex:sub(1,2)) or 255
				local g = tonumber("0x"..hex:sub(3,4)) or 255
				local b = tonumber("0x"..hex:sub(5,6)) or 255
				return Color3.fromRGB(r, g, b)
			end

			-- Current color state
			local currentHue = 0
			local currentSaturation = 1
			local currentBrightness = 1
			local currentColor = defaultColor

			-- Update color function
			local function updateColor(hue, sat, bright)
				currentHue = hue or currentHue
				currentSaturation = sat or currentSaturation
				currentBrightness = bright or currentBrightness

				-- Create color from HSV
				currentColor = Color3.fromHSV(currentHue, currentSaturation, currentBrightness)

				-- Update displays
				ColorPreview.BackgroundColor3 = currentColor
				CurrentColor.BackgroundColor3 = currentColor
				SaturationBrightness.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
				HexInput.Text = RGBToHex(currentColor)

				-- Call callback
				if callback then
					pcall(callback, currentColor)
				end
			end

			-- Initialize
			local h, s, v = defaultColor:ToHSV()
			updateColor(h, s, v)
			HueSelector.Position = UDim2.new(-0.1, 0, 1 - h, 0)
			SaturationBrightnessSelector.Position = UDim2.new(s, -3, 1 - v, -3)

			-- Click to open/close functionality (like other dropdowns)
			local isColorPickerOpen = false

			ColorPicker.MouseButton1Down:Connect(function()
				if not isColorPickerOpen then
					-- Close other dropdowns first
					local allContainers = TabContainer:GetDescendants()
					for _, element in pairs(allContainers) do
						if element.Name == "PickerContainer" and element ~= PickerContainer then
							element.Visible = false
						end
						if element.Name == "DropContainer" then
							element.Visible = false
							if element.Parent:FindFirstChild("TextColor3") then
								element.Parent.TextColor3 = Color3.new(255, 255, 255)
							end
							if element.Parent:FindFirstChild("Arrow") then
								element.Parent.Arrow.TextColor3 = Color3.new(255, 255, 255)
							end
						end
					end

					-- Open this one
					PickerContainer.Visible = true
					isColorPickerOpen = true
					ColorPicker.TextColor3 = UISettings.TextColor
					Arrow.TextColor3 = UISettings.TextColor
				else
					-- Close this one
					PickerContainer.Visible = false
					isColorPickerOpen = false
					ColorPicker.TextColor3 = Color3.new(255, 255, 255)
					Arrow.TextColor3 = Color3.new(255, 255, 255)
				end
			end)

			-- Close color picker when clicking elsewhere
			local function closeColorPicker()
				if isColorPickerOpen then
					PickerContainer.Visible = false
					isColorPickerOpen = false
					ColorPicker.TextColor3 = Color3.new(255, 255, 255)
					Arrow.TextColor3 = Color3.new(255, 255, 255)
				end
			end

			-- Close when clicking on other tabs
			for _, child in pairs(Container:GetChildren()) do
				if child:IsA("TextButton") and child ~= ColorPicker then
					child.MouseButton1Down:Connect(closeColorPicker)
				end
			end

			-- Hue slider interaction
			HueSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local connection
					connection = game:GetService("UserInputService").InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
							local yPos = math.clamp((moveInput.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
							HueSelector.Position = UDim2.new(-0.1, 0, yPos, 0)
							currentHue = 1 - yPos
							updateColor()
						end
					end)

					game:GetService("UserInputService").InputEnded:Connect(function(endInput)
						if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
							connection:Disconnect()
						end
					end)
				end
			end)

			-- Saturation/Brightness interaction
			SaturationBrightness.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local connection
					connection = game:GetService("UserInputService").InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
							local xPos = math.clamp((moveInput.Position.X - SaturationBrightness.AbsolutePosition.X) / SaturationBrightness.AbsoluteSize.X, 0, 1)
							local yPos = math.clamp((moveInput.Position.Y - SaturationBrightness.AbsolutePosition.Y) / SaturationBrightness.AbsoluteSize.Y, 0, 1)

							SaturationBrightnessSelector.Position = UDim2.new(xPos, -3, yPos, -3)
							currentSaturation = xPos
							currentBrightness = 1 - yPos
							updateColor()
						end
					end)

					game:GetService("UserInputService").InputEnded:Connect(function(endInput)
						if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
							connection:Disconnect()
						end
					end)
				end
			end)

			-- Hex input handler
			HexInput.FocusLost:Connect(function()
				local hex = HexInput.Text
				local success, color = pcall(function()
					return HexToRGB(hex)
				end)
				if success then
					local h, s, v = color:ToHSV()
					updateColor(h, s, v)
					HueSelector.Position = UDim2.new(-0.1, 0, 1 - h, 0)
					SaturationBrightnessSelector.Position = UDim2.new(s, -3, 1 - v, -3)
				else
					HexInput.Text = RGBToHex(currentColor)
				end
			end)

			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)

			return {
				GetColor = function() return currentColor end,
				SetColor = function(color)
					local h, s, v = color:ToHSV()
					updateColor(h, s, v)
					HueSelector.Position = UDim2.new(-0.1, 0, 1 - h, 0)
					SaturationBrightnessSelector.Position = UDim2.new(s, -3, 1 - v, -3)
				end
			}
		end

		function tabFunctions:CreateButton(buttonText, note, callback)
			local Button = Instance.new("TextButton")
			local Note = Instance.new("TextLabel")

			Button.Name = buttonText
			Button.Parent = TabContainer
			Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Button.BackgroundTransparency = 1.000
			Button.Size = UDim2.new(0, 193, 0, 24)
			Button.Font = Enum.Font.JosefinSans
			Button.Text = " "..buttonText
			Button.TextColor3 = Color3.fromRGB(255, 255, 255)
			Button.TextSize = UISettings.TextSize
			Button.TextXAlignment = Enum.TextXAlignment.Left

			Button.MouseButton1Down:Connect(function()
				Button.TextColor3 = UISettings.TextColor
				task.wait(0.05)
				Button.TextColor3 = Color3.new(255, 255, 255)
				if callback then
					pcall(callback)
				end
			end)

			Note.Name = "Note"
			Note.Parent = Button
			Note.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Note.BackgroundTransparency = 1.000
			Note.Position = UDim2.new(1.04145074, 0, 0, 0)
			Note.Size = UDim2.new(0, 193, 0, 24)
			Note.Font = Enum.Font.JosefinSans
			Note.Text = note or ""
			Note.TextColor3 = UISettings.TextColor
			Note.TextSize = UISettings.TextSize
			Note.TextXAlignment = Enum.TextXAlignment.Left
			Note.Visible = false

			Button.MouseEnter:Connect(function()
				Note.Visible = true
			end)

			Button.MouseLeave:Connect(function()
				Note.Visible = false
			end)

			-- Update sizes
			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)
		end

		function tabFunctions:CreateLabel(labelText, color3)
			local Label = Instance.new("TextLabel")

			Label.Name = labelText
			Label.Parent = TabContainer
			Label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Label.BackgroundTransparency = 1.000
			Label.Size = UDim2.new(0, 193, 0, 24)
			Label.Font = Enum.Font.JosefinSans
			Label.Text = " "..labelText
			Label.TextColor3 = color3 or Color3.fromRGB(255, 255, 255)
			Label.TextSize = UISettings.TextSize
			Label.TextXAlignment = Enum.TextXAlignment.Left

			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)
		end

		function tabFunctions:CreateToggle(buttonText, note, callback)
			local Button = Instance.new("TextButton")
			local Note = Instance.new("TextLabel")
			local Toggle = Instance.new("BoolValue")

			Button.Name = buttonText
			Button.Parent = TabContainer
			Toggle.Parent = Button
			Toggle.Name = "Toggled"
			Toggle.Value = false

			Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Button.BackgroundTransparency = 1.000
			Button.Size = UDim2.new(0, 193, 0, 24)
			Button.Font = Enum.Font.JosefinSans
			Button.Text = " "..buttonText
			Button.TextColor3 = Color3.fromRGB(255, 255, 255)
			Button.TextSize = UISettings.TextSize
			Button.TextXAlignment = Enum.TextXAlignment.Left

			Button.MouseEnter:Connect(function()
				if Note then
					Note.Visible = true
				end
			end)

			Button.MouseLeave:Connect(function()
				if Note then
					Note.Visible = false
				end
			end)

			Button.MouseButton1Down:Connect(function()
				Toggle.Value = not Toggle.Value
				if Toggle.Value then
					Button.TextColor3 = UISettings.TextColor
				else
					Button.TextColor3 = Color3.new(255, 255, 255)
				end
				if callback then
					pcall(callback, Toggle.Value)
				end
			end)

			Note.Name = "Note"
			Note.Parent = Button
			Note.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Note.BackgroundTransparency = 1.000
			Note.Position = UDim2.new(1.04145074, 0, 0, 0)
			Note.Size = UDim2.new(0, 193, 0, 24)
			Note.Font = Enum.Font.JosefinSans
			Note.Text = note or ""
			Note.TextColor3 = UISettings.TextColor
			Note.TextSize = UISettings.TextSize
			Note.TextXAlignment = Enum.TextXAlignment.Left
			Note.Visible = false

			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)

			return Toggle
		end

		function tabFunctions:CreateSideDropButton(dropText, list, callback)
			local SideDrop = Instance.new("TextButton")
			local Arrow = Instance.new("TextButton")
			local DropContainer = Instance.new("Frame")
			local DropUIListLayout = Instance.new("UIListLayout")

			SideDrop.Name = dropText
			SideDrop.Parent = TabContainer
			SideDrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			SideDrop.BackgroundTransparency = 1.000
			SideDrop.Size = UDim2.new(0, 193, 0, 24)
			SideDrop.Font = Enum.Font.JosefinSans
			SideDrop.Text = " "..dropText
			SideDrop.TextColor3 = Color3.fromRGB(255, 255, 255)
			SideDrop.TextSize = UISettings.TextSize
			SideDrop.TextXAlignment = Enum.TextXAlignment.Left

			Arrow.Name = "Arrow"
			Arrow.Parent = SideDrop
			Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.BackgroundTransparency = 1.000
			Arrow.Position = UDim2.new(0.906735778, 0, 0, 0)
			Arrow.Size = UDim2.new(0, 18, 0, 21)
			Arrow.Font = Enum.Font.SourceSans
			Arrow.Text = ">>"
			Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.TextScaled = true
			Arrow.TextSize = UISettings.TextSize
			Arrow.TextWrapped = true

			DropContainer.Name = "DropContainer"
			DropContainer.Parent = SideDrop
			DropContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			DropContainer.BackgroundTransparency = UISettings.BackgroundTransparency
			DropContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
			DropContainer.BorderSizePixel = 4
			DropContainer.Position = UDim2.new(1.08290148, 0, 0, 0)
			DropContainer.Size = UDim2.new(0, 193, 0, 0)
			DropContainer.Visible = false

			DropUIListLayout.Parent = DropContainer
			DropUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			-- Dropdown toggle
			SideDrop.MouseButton1Down:Connect(function()
				local allDropContainers = TabContainer:GetDescendants()
				for _, element in pairs(allDropContainers) do
					if element.Name == "DropContainer" and element ~= DropContainer then
						element.Visible = false
						if element.Parent:FindFirstChild("TextColor3") then
							element.Parent.TextColor3 = Color3.new(255, 255, 255)
						end
						if element.Parent:FindFirstChild("Arrow") then
							element.Parent.Arrow.TextColor3 = Color3.new(255, 255, 255)
						end
					end
				end

				DropContainer.Visible = not DropContainer.Visible
				if DropContainer.Visible then
					SideDrop.TextColor3 = UISettings.TextColor
					Arrow.TextColor3 = UISettings.TextColor
				else
					SideDrop.TextColor3 = Color3.new(255, 255, 255)
					Arrow.TextColor3 = Color3.new(255, 255, 255)
				end
			end)

			-- Create dropdown items
			for _, option in pairs(list or {}) do
				local Button = Instance.new("TextButton")
				Button.Name = option
				Button.Parent = DropContainer
				Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				Button.BackgroundTransparency = 1.000
				Button.Size = UDim2.new(0, 193, 0, 24)
				Button.Font = Enum.Font.JosefinSans
				Button.Text = " "..option
				Button.TextColor3 = Color3.fromRGB(255, 255, 255)
				Button.TextSize = UISettings.TextSize
				Button.TextXAlignment = Enum.TextXAlignment.Left

				Button.MouseButton1Down:Connect(function()
					Button.TextColor3 = UISettings.TextColor
					task.wait(0.05)
					Button.TextColor3 = Color3.new(255, 255, 255)
					if callback then
						pcall(callback, option)
					end
				end)
			end

			-- Update sizes
			DropContainer.Size = UDim2.new(0, 193, 0, DropUIListLayout.AbsoluteContentSize.Y)
			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)
		end

		function tabFunctions:CreateTextBox(buttonText, placeholderText, callback)
			local TextBoxBtn = Instance.new("TextButton")
			local Arrow = Instance.new("TextButton")
			local Side = Instance.new("Frame")
			local Box = Instance.new("TextBox")
			local Hover = Instance.new("Frame")

			TextBoxBtn.Name = buttonText
			TextBoxBtn.Parent = TabContainer
			TextBoxBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			TextBoxBtn.BackgroundTransparency = 1.000
			TextBoxBtn.Size = UDim2.new(0, 193, 0, 24)
			TextBoxBtn.Font = Enum.Font.JosefinSans
			TextBoxBtn.Text = " "..buttonText
			TextBoxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextBoxBtn.TextSize = UISettings.TextSize
			TextBoxBtn.TextXAlignment = Enum.TextXAlignment.Left

			Arrow.Name = "Arrow"
			Arrow.Parent = TextBoxBtn
			Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.BackgroundTransparency = 1.000
			Arrow.Position = UDim2.new(0.906735778, 0, 0, 0)
			Arrow.Size = UDim2.new(0, 18, 0, 21)
			Arrow.Font = Enum.Font.SourceSans
			Arrow.Text = ">>"
			Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.TextScaled = true
			Arrow.TextSize = UISettings.TextSize
			Arrow.TextWrapped = true

			Side.Name = "Side"
			Side.Parent = TextBoxBtn
			Side.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Side.BackgroundTransparency = UISettings.BackgroundTransparency
			Side.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Side.BorderSizePixel = 4
			Side.Position = UDim2.new(1.08290148, 0, 0, 0)
			Side.Size = UDim2.new(0, 193, 0, 24)
			Side.Visible = false

			Box.Name = "Box"
			Box.Parent = Side
			Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Box.BackgroundTransparency = 1.000
			Box.Size = UDim2.new(0, 193, 0, 24)
			Box.Font = Enum.Font.JosefinSans
			Box.Text = ""
			Box.TextColor3 = Color3.fromRGB(255, 255, 255)
			Box.TextSize = UISettings.TextSize
			Box.TextWrapped = true
			Box.PlaceholderText = placeholderText or "Enter text..."

			Hover.Name = "Hover"
			Hover.Parent = TextBoxBtn
			Hover.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Hover.BackgroundTransparency = 1.000
			Hover.Size = UDim2.new(0, 209, 0, 32)

			-- Hover functionality
			Hover.MouseEnter:Connect(function()
				Side.Visible = true
			end)

			Hover.MouseLeave:Connect(function()
				Side.Visible = false
			end)

			-- Submit on button click
			TextBoxBtn.MouseButton1Down:Connect(function()
				TextBoxBtn.TextColor3 = UISettings.TextColor
				task.wait(0.05)
				TextBoxBtn.TextColor3 = Color3.new(255, 255, 255)
				if callback then
					pcall(callback, Box.Text)
				end
			end)

			-- Submit on Enter key
			Box.FocusLost:Connect(function(enterPressed)
				if enterPressed and callback then
					pcall(callback, Box.Text)
				end
			end)

			TabContainer.Size = UDim2.new(0, 193, 0, UIListLayout2.AbsoluteContentSize.Y)
		end

		-- Store custom tabs for ordering
		table.insert(customTabs, {Tab = Tab, Functions = tabFunctions})

		return tabFunctions
	end

	-- Create mandatory Info/Credits tab (second to last)
	local function createInfoTab()
		local InfoTab = Instance.new("TextButton")
		local Arrow = Instance.new("TextLabel")

		InfoTab.Name = "Info"
		InfoTab.Parent = Container
		InfoTab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		InfoTab.BackgroundTransparency = 1.000
		InfoTab.Size = UDim2.new(0, 193, 0, 24)
		InfoTab.Font = Enum.Font.JosefinSans
		InfoTab.Text = " Info"
		InfoTab.TextColor3 = Color3.fromRGB(255, 255, 255)
		InfoTab.TextSize = UISettings.TextSize
		InfoTab.TextXAlignment = Enum.TextXAlignment.Left

		Arrow.Name = "Arrow"
		Arrow.Parent = InfoTab
		Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Arrow.BackgroundTransparency = 1.000
		Arrow.Position = UDim2.new(0.907, 0, 0, 0)
		Arrow.Size = UDim2.new(0, 18, 0, 21)
		Arrow.Font = Enum.Font.SourceSans
		Arrow.Text = ">>"
		Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
		Arrow.TextScaled = true
		Arrow.TextSize = UISettings.TextSize
		Arrow.TextWrapped = true

		-- Info Tab Container
		local InfoContainer = Instance.new("Frame")
		InfoContainer.Name = "TabContainer"
		InfoContainer.Parent = InfoTab
		InfoContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		InfoContainer.BackgroundTransparency = UISettings.BackgroundTransparency
		InfoContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		InfoContainer.BorderSizePixel = 4
		InfoContainer.Position = UDim2.new(1.0569948, 0, 0, 0)
		InfoContainer.Visible = false

		local InfoUIListLayout = Instance.new("UIListLayout")
		InfoUIListLayout.Parent = InfoContainer
		InfoUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- Info Tab click functionality
		InfoTab.MouseButton1Down:Connect(function()
			local wasOpen = InfoContainer.Visible

			-- Close ALL tabs
			for _, child in pairs(Container:GetChildren()) do
				if child:IsA("TextButton") then
					child.TextColor3 = Color3.new(255, 255, 255)
					local arrow = child:FindFirstChild("Arrow")
					if arrow then
						arrow.TextColor3 = Color3.new(255, 255, 255)
					end
					local tabContainer = child:FindFirstChild("TabContainer")
					if tabContainer then
						tabContainer.Visible = false
					end
				end
			end

			if not wasOpen then
				InfoContainer.Visible = true
				InfoTab.TextColor3 = UISettings.TextColor
				InfoTab.Arrow.TextColor3 = UISettings.TextColor
			end
		end)

		-- Credits and Information
		
		-- Cursor info
		local cursorInfo = Instance.new("TextLabel")
		cursorInfo.Name = "CursorInfo"
		cursorInfo.Parent = InfoContainer
		cursorInfo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cursorInfo.BackgroundTransparency = 1.000
		cursorInfo.Size = UDim2.new(0, 193, 0, 24)
		cursorInfo.Font = Enum.Font.JosefinSans
		cursorInfo.Text = " Cursor System"
		cursorInfo.TextColor3 = Color3.fromRGB(128, 0, 128)  -- Purple
		cursorInfo.TextSize = UISettings.TextSize
		cursorInfo.TextXAlignment = Enum.TextXAlignment.Left

		local cursorKeyInfo = Instance.new("TextLabel")
		cursorKeyInfo.Name = "CursorKeyInfo"
		cursorKeyInfo.Parent = InfoContainer
		cursorKeyInfo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cursorKeyInfo.BackgroundTransparency = 1.000
		cursorKeyInfo.Size = UDim2.new(0, 193, 0, 20)
		cursorKeyInfo.Font = Enum.Font.JosefinSans
		cursorKeyInfo.Text = " Insert: Toggle Cursor"
		cursorKeyInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
		cursorKeyInfo.TextSize = 12
		cursorKeyInfo.TextXAlignment = Enum.TextXAlignment.Left

		local cursorDesc = Instance.new("TextLabel")
		cursorDesc.Name = "CursorDesc"
		cursorDesc.Parent = InfoContainer
		cursorDesc.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cursorDesc.BackgroundTransparency = 1.000
		cursorDesc.Size = UDim2.new(0, 193, 0, 40)
		cursorDesc.Font = Enum.Font.JosefinSans
		cursorDesc.Text = " Unlocks mouse in first-person games. Press key again to relock."
		cursorDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
		cursorDesc.TextSize = 10
		cursorDesc.TextWrapped = true
		cursorDesc.TextXAlignment = Enum.TextXAlignment.Left

		-- Title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Parent = InfoContainer
		titleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		titleLabel.BackgroundTransparency = 1.000
		titleLabel.Size = UDim2.new(0, 193, 0, 24)
		titleLabel.Font = Enum.Font.JosefinSans
		titleLabel.Text = " "..title
		titleLabel.TextColor3 = Color3.fromRGB(128, 0, 128)  -- Purple
		titleLabel.TextSize = 16
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Creator (in purple)
		local creatorLabel = Instance.new("TextLabel")
		creatorLabel.Name = "Creator"
		creatorLabel.Parent = InfoContainer
		creatorLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		creatorLabel.BackgroundTransparency = 1.000
		creatorLabel.Size = UDim2.new(0, 193, 0, 24)
		creatorLabel.Font = Enum.Font.JosefinSans
		creatorLabel.Text = " Created by: Sealient"
		creatorLabel.TextColor3 = Color3.fromRGB(128, 0, 128)  -- Purple
		creatorLabel.TextSize = UISettings.TextSize
		creatorLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Version
		local versionLabel = Instance.new("TextLabel")
		versionLabel.Name = "Version"
		versionLabel.Parent = InfoContainer
		versionLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		versionLabel.BackgroundTransparency = 1.000
		versionLabel.Size = UDim2.new(0, 193, 0, 24)
		versionLabel.Font = Enum.Font.JosefinSans
		versionLabel.Text = " Version: 1.0.0"
		versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		versionLabel.TextSize = UISettings.TextSize
		versionLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Library
		local libraryLabel = Instance.new("TextLabel")
		libraryLabel.Name = "Library"
		libraryLabel.Parent = InfoContainer
		libraryLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		libraryLabel.BackgroundTransparency = 1.000
		libraryLabel.Size = UDim2.new(0, 193, 0, 24)
		libraryLabel.Font = Enum.Font.JosefinSans
		libraryLabel.Text = " Library: ReduxV1"
		libraryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		libraryLabel.TextSize = UISettings.TextSize
		libraryLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Controls
		local controlsLabel = Instance.new("TextLabel")
		controlsLabel.Name = "Controls"
		controlsLabel.Parent = InfoContainer
		controlsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		controlsLabel.BackgroundTransparency = 1.000
		controlsLabel.Size = UDim2.new(0, 193, 0, 24)
		controlsLabel.Font = Enum.Font.JosefinSans
		controlsLabel.Text = " Controls"
		controlsLabel.TextColor3 = Color3.fromRGB(128, 0, 128)  -- Purple
		controlsLabel.TextSize = UISettings.TextSize
		controlsLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Control items
		local control1 = Instance.new("TextLabel")
		control1.Name = "Control1"
		control1.Parent = InfoContainer
		control1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		control1.BackgroundTransparency = 1.000
		control1.Size = UDim2.new(0, 193, 0, 20)
		control1.Font = Enum.Font.JosefinSans
		control1.Text = " Right Ctrl: Hide/Show"
		control1.TextColor3 = Color3.fromRGB(255, 255, 255)
		control1.TextSize = 12
		control1.TextXAlignment = Enum.TextXAlignment.Left

		-- Discord/Contact (in purple)
		local discordLabel = Instance.new("TextLabel")
		discordLabel.Name = "Discord"
		discordLabel.Parent = InfoContainer
		discordLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		discordLabel.BackgroundTransparency = 1.000
		discordLabel.Size = UDim2.new(0, 193, 0, 24)
		discordLabel.Font = Enum.Font.JosefinSans
		discordLabel.Text = " Discord: sealrl_"
		discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Purple
		discordLabel.TextSize = 12
		discordLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- GitHub/Contact (in purple)
		local githubLabel = Instance.new("TextLabel")
		githubLabel.Name = "GitHub"
		githubLabel.Parent = InfoContainer
		githubLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		githubLabel.BackgroundTransparency = 1.000
		githubLabel.Size = UDim2.new(0, 193, 0, 24)
		githubLabel.Font = Enum.Font.JosefinSans
		githubLabel.Text = " GitHub: Sealient"
		githubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Purple
		githubLabel.TextSize = 12
		githubLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Inspo/Contact (in purple)
		local InspoLabel = Instance.new("TextLabel")
		InspoLabel.Name = "Inspo"
		InspoLabel.Parent = InfoContainer
		InspoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		InspoLabel.BackgroundTransparency = 1.000
		InspoLabel.Size = UDim2.new(0, 193, 0, 24)
		InspoLabel.Font = Enum.Font.JosefinSans
		InspoLabel.Text = " Inspo by: Rodus UI"
		InspoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Purple
		InspoLabel.TextSize = 12
		InspoLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Update container size
		InfoContainer.Size = UDim2.new(0, 193, 0, InfoUIListLayout.AbsoluteContentSize.Y)
		Container.Size = UDim2.new(0, 193, 0, UIListLayout.AbsoluteContentSize.Y)
	end

	-- Create info tab immediately (before settings)
	createInfoTab()

	-- Create mandatory Settings tab (always last)
	local function createSettingsTab()
		local SettingsTab = Instance.new("TextButton")
		local Arrow = Instance.new("TextLabel")

		SettingsTab.Name = "Settings"
		SettingsTab.Parent = Container
		SettingsTab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		SettingsTab.BackgroundTransparency = 1.000
		SettingsTab.Size = UDim2.new(0, 193, 0, 24)
		SettingsTab.Font = Enum.Font.JosefinSans
		SettingsTab.Text = " Settings"
		SettingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
		SettingsTab.TextSize = UISettings.TextSize
		SettingsTab.TextXAlignment = Enum.TextXAlignment.Left

		Arrow.Name = "Arrow"
		Arrow.Parent = SettingsTab
		Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Arrow.BackgroundTransparency = 1.000
		Arrow.Position = UDim2.new(0.907, 0, 0, 0)
		Arrow.Size = UDim2.new(0, 18, 0, 21)
		Arrow.Font = Enum.Font.SourceSans
		Arrow.Text = ">>"
		Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
		Arrow.TextScaled = true
		Arrow.TextSize = UISettings.TextSize
		Arrow.TextWrapped = true

		-- Settings Tab Container
		local SettingsContainer = Instance.new("Frame")
		SettingsContainer.Name = "TabContainer"
		SettingsContainer.Parent = SettingsTab
		SettingsContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		SettingsContainer.BackgroundTransparency = UISettings.BackgroundTransparency
		SettingsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SettingsContainer.BorderSizePixel = 4
		SettingsContainer.Position = UDim2.new(1.0569948, 0, 0, 0)
		SettingsContainer.Visible = false

		local SettingsUIListLayout = Instance.new("UIListLayout")
		SettingsUIListLayout.Parent = SettingsContainer
		SettingsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- Settings Tab click functionality
		SettingsTab.MouseButton1Down:Connect(function()
			local wasOpen = SettingsContainer.Visible

			-- Close ALL tabs
			for _, child in pairs(Container:GetChildren()) do
				if child:IsA("TextButton") then
					child.TextColor3 = Color3.new(255, 255, 255)
					local arrow = child:FindFirstChild("Arrow")
					if arrow then
						arrow.TextColor3 = Color3.new(255, 255, 255)
					end
					local tabContainer = child:FindFirstChild("TabContainer")
					if tabContainer then
						tabContainer.Visible = false
					end
				end
			end

			if not wasOpen then
				SettingsContainer.Visible = true
				SettingsTab.TextColor3 = UISettings.TextColor
				SettingsTab.Arrow.TextColor3 = UISettings.TextColor
			end
		end)

		-- UI Customization Settings
		-- Cursor Toggle Keybind
		local cursorKeyButton = Instance.new("TextButton")
		cursorKeyButton.Name = "Cursor Key"
		cursorKeyButton.Parent = SettingsContainer
		cursorKeyButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cursorKeyButton.BackgroundTransparency = 1.000
		cursorKeyButton.Size = UDim2.new(0, 193, 0, 24)
		cursorKeyButton.Font = Enum.Font.JosefinSans
		cursorKeyButton.Text = " Cursor Key: Insert"
		cursorKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		cursorKeyButton.TextSize = UISettings.TextSize
		cursorKeyButton.TextXAlignment = Enum.TextXAlignment.Left

		local isSettingCursorKey = false
		cursorKeyButton.MouseButton1Down:Connect(function()
			if not isSettingCursorKey then
				isSettingCursorKey = true
				cursorKeyButton.Text = " Press any key..."
				cursorKeyButton.TextColor3 = Color3.fromRGB(255, 255, 0)

				local tempConnection
				tempConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end

					-- Ignore mouse clicks for keybinds
					if input.UserInputType == Enum.UserInputType.MouseButton1 or
						input.UserInputType == Enum.UserInputType.MouseButton2 or
						input.UserInputType == Enum.UserInputType.MouseButton3 then
						return
					end

					setCursorKeybind(input.KeyCode)
					cursorKeyButton.Text = " Cursor Key: " .. input.KeyCode.Name
					cursorKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					isSettingCursorKey = false

					if tempConnection then
						tempConnection:Disconnect()
					end
				end)

				-- Auto-cancel after 5 seconds
				delay(5, function()
					if isSettingCursorKey then
						isSettingCursorKey = false
						cursorKeyButton.Text = " Cursor Key: " .. cursorKeybind.Name
						cursorKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)

						if tempConnection then
							tempConnection:Disconnect()
						end
					end
				end)
			end
		end)

		-- Cursor Color
		local cursorColorOptions = {"Green", "Blue", "Red", "Yellow", "White", "Purple"}
		local cursorColorMap = {
			Green = Color3.fromRGB(0, 255, 0),
			Blue = Color3.fromRGB(0, 150, 255),
			Red = Color3.fromRGB(255, 50, 50),
			Yellow = Color3.fromRGB(255, 255, 0),
			White = Color3.fromRGB(255, 255, 255),
			Purple = Color3.fromRGB(128, 0, 128)
		}

		local currentCursorColor = "Green"
		local cursorColorButton = Instance.new("TextButton")
		cursorColorButton.Name = "Cursor Color"
		cursorColorButton.Parent = SettingsContainer
		cursorColorButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		cursorColorButton.BackgroundTransparency = 1.000
		cursorColorButton.Size = UDim2.new(0, 193, 0, 24)
		cursorColorButton.Font = Enum.Font.JosefinSans
		cursorColorButton.Text = " Cursor Color: " .. currentCursorColor
		cursorColorButton.TextColor3 = cursorColorMap[currentCursorColor]
		cursorColorButton.TextSize = UISettings.TextSize
		cursorColorButton.TextXAlignment = Enum.TextXAlignment.Left

		cursorColorButton.MouseButton1Down:Connect(function()
			local currentIndex = table.find(cursorColorOptions, currentCursorColor) or 1
			local nextIndex = (currentIndex % #cursorColorOptions) + 1
			currentCursorColor = cursorColorOptions[nextIndex]

			cursorColorButton.Text = " Cursor Color: " .. currentCursorColor
			cursorColorButton.TextColor3 = cursorColorMap[currentCursorColor]

			-- Update cursor colors
			CursorRing.BackgroundColor3 = cursorColorMap[currentCursorColor]
			CursorDot.BackgroundColor3 = cursorColorMap[currentCursorColor]
		end)

		-- Test Cursor Button
		local testCursorButton = Instance.new("TextButton")
		testCursorButton.Name = "Test Cursor"
		testCursorButton.Parent = SettingsContainer
		testCursorButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		testCursorButton.BackgroundTransparency = 1.000
		testCursorButton.Size = UDim2.new(0, 193, 0, 24)
		testCursorButton.Font = Enum.Font.JosefinSans
		testCursorButton.Text = " Test Cursor Toggle"
		testCursorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		testCursorButton.TextSize = UISettings.TextSize
		testCursorButton.TextXAlignment = Enum.TextXAlignment.Left

		testCursorButton.MouseButton1Down:Connect(function()
			toggleCustomCursor()
		end)

		-- Background Transparency
		local transparencyToggle = SettingsContainer:FindFirstChild("Transparency") or Instance.new("TextButton")
		transparencyToggle.Name = "Transparency"
		transparencyToggle.Parent = SettingsContainer
		transparencyToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		transparencyToggle.BackgroundTransparency = 1.000
		transparencyToggle.Size = UDim2.new(0, 193, 0, 24)
		transparencyToggle.Font = Enum.Font.JosefinSans
		transparencyToggle.Text = " Transparency: "..UISettings.BackgroundTransparency
		transparencyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		transparencyToggle.TextSize = UISettings.TextSize
		transparencyToggle.TextXAlignment = Enum.TextXAlignment.Left

		transparencyToggle.MouseButton1Down:Connect(function()
			UISettings.BackgroundTransparency = UISettings.BackgroundTransparency == 0.5 and 0.2 or 0.5
			transparencyToggle.Text = " Transparency: "..UISettings.BackgroundTransparency
			applyUISettings()
		end)

		-- Text Color
		local colorOptions = {"Green", "Blue", "Red", "Yellow", "White"}
		local colorMap = {
			Green = Color3.fromRGB(0, 255, 0),
			Blue = Color3.fromRGB(0, 150, 255),
			Red = Color3.fromRGB(255, 50, 50),
			Yellow = Color3.fromRGB(255, 255, 0),
			White = Color3.fromRGB(255, 255, 255)
		}

		local currentColor = "Green"
		local colorToggle = SettingsContainer:FindFirstChild("Text Color") or Instance.new("TextButton")
		colorToggle.Name = "Text Color"
		colorToggle.Parent = SettingsContainer
		colorToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		colorToggle.BackgroundTransparency = 1.000
		colorToggle.Size = UDim2.new(0, 193, 0, 24)
		colorToggle.Font = Enum.Font.JosefinSans
		colorToggle.Text = " Text Color: "..currentColor
		colorToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorToggle.TextSize = UISettings.TextSize
		colorToggle.TextXAlignment = Enum.TextXAlignment.Left

		colorToggle.MouseButton1Down:Connect(function()
			local currentIndex = table.find(colorOptions, currentColor) or 1
			local nextIndex = (currentIndex % #colorOptions) + 1
			currentColor = colorOptions[nextIndex]
			UISettings.TextColor = colorMap[currentColor]
			colorToggle.Text = " Text Color: "..currentColor
			colorToggle.TextColor3 = UISettings.TextColor
			applyUISettings()
		end)

		-- Text Size
		local sizeToggle = SettingsContainer:FindFirstChild("Text Size") or Instance.new("TextButton")
		sizeToggle.Name = "Text Size"
		sizeToggle.Parent = SettingsContainer
		sizeToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		sizeToggle.BackgroundTransparency = 1.000
		sizeToggle.Size = UDim2.new(0, 193, 0, 24)
		sizeToggle.Font = Enum.Font.JosefinSans
		sizeToggle.Text = " Text Size: "..UISettings.TextSize
		sizeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		sizeToggle.TextSize = UISettings.TextSize
		sizeToggle.TextXAlignment = Enum.TextXAlignment.Left

		sizeToggle.MouseButton1Down:Connect(function()
			UISettings.TextSize = UISettings.TextSize == 14 and 16 or 14
			sizeToggle.Text = " Text Size: "..UISettings.TextSize
			sizeToggle.TextSize = UISettings.TextSize
			applyUISettings()
		end)

		-- Reset to Default
		local resetBtn = SettingsContainer:FindFirstChild("Reset Defaults") or Instance.new("TextButton")
		resetBtn.Name = "Reset Defaults"
		resetBtn.Parent = SettingsContainer
		resetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		resetBtn.BackgroundTransparency = 1.000
		resetBtn.Size = UDim2.new(0, 193, 0, 24)
		resetBtn.Font = Enum.Font.JosefinSans
		resetBtn.Text = " Reset to Defaults"
		resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		resetBtn.TextSize = UISettings.TextSize
		resetBtn.TextXAlignment = Enum.TextXAlignment.Left

		resetBtn.MouseButton1Down:Connect(function()
			UISettings.BackgroundTransparency = 0.5
			UISettings.TextColor = Color3.fromRGB(0, 255, 0)
			UISettings.TextSize = 14
			currentColor = "Green"

			transparencyToggle.Text = " Transparency: "..UISettings.BackgroundTransparency
			colorToggle.Text = " Text Color: "..currentColor
			colorToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			sizeToggle.Text = " Text Size: "..UISettings.TextSize
			sizeToggle.TextSize = UISettings.TextSize

			applyUISettings()
		end)

		-- Destroy UI Button
		local destroyBtn = SettingsContainer:FindFirstChild("Destroy UI") or Instance.new("TextButton")
		destroyBtn.Name = "Destroy UI"
		destroyBtn.Parent = SettingsContainer
		destroyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		destroyBtn.BackgroundTransparency = 1.000
		destroyBtn.Size = UDim2.new(0, 193, 0, 24)
		destroyBtn.Font = Enum.Font.JosefinSans
		destroyBtn.Text = " DESTROY UI"
		destroyBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
		destroyBtn.TextSize = UISettings.TextSize
		destroyBtn.TextXAlignment = Enum.TextXAlignment.Left

		destroyBtn.MouseButton1Down:Connect(function()
			Rodus:Destroy()
		end)

		-- Update container size
		SettingsContainer.Size = UDim2.new(0, 193, 0, SettingsUIListLayout.AbsoluteContentSize.Y)
		Container.Size = UDim2.new(0, 193, 0, UIListLayout.AbsoluteContentSize.Y)
	end

	-- Create settings tab immediately
	createSettingsTab()
	
	-- Make sure to clean up when UI is destroyed
	Rodus.Destroying:Connect(function()
		if cursorEnabled then
			-- Stop preventing re-lock
			local preventRelockConnection = game:GetService("Players").LocalPlayer:GetAttribute("PreventRelockConnection")
			if preventRelockConnection then
				preventRelockConnection:Disconnect()
			end

			-- Disconnect click handler
			if clickConnection then
				clickConnection:Disconnect()
			end

			-- Restore mouse behavior
			if originalMouseBehavior then
				game:GetService("UserInputService").MouseBehavior = originalMouseBehavior
			end
		end
	end)

	return uiFunctions
end

return Rodus