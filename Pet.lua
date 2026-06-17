-- Gui to Lua
-- Version: 3.2

-- Instances:

local ScreenGui = Instance.new("ScreenGui")

--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Scripts:

local function YFTY_fake_script() -- ScreenGui.LocalScript 
	local script = Instance.new('LocalScript', ScreenGui)

	--[[
		CENTERED LOADING UI & PET VISUAL CLONER — Roblox Client
		-------------------------------------------------------------------
		Paste into a LocalScript inside StarterPlayer > StarterPlayerScripts.
		
		Features a procedural radial loading bar transition, followed by 
		an interactive client-side visual duplication interface.
	]]
	
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-------------------------------------------------
	-- THEME & CONFIGURATION
	-------------------------------------------------
	local THEME = {
		Card         = Color3.fromRGB(24, 24, 32),
		CardBorder   = Color3.fromRGB(45, 45, 58),
		Accent       = Color3.fromRGB(99, 179, 255),   -- soft cyan-blue
		Accent2      = Color3.fromRGB(168, 120, 255),  -- violet (gradient pair)
		TextPrimary  = Color3.fromRGB(235, 236, 240),
		TextSecond   = Color3.fromRGB(140, 142, 155),
		RingTrack    = Color3.fromRGB(42, 42, 56),
	}
	
	local MAX_VISUAL_DUPES = 6
	local DUPE_OFFSET = Vector3.new(4, 0, 2)
	local activeDupes = {}
	local refreshDupeUi = function() end
	
	-------------------------------------------------
	-- STAGE 1: PROCEDURAL LOADING SCREEN INTERFACE
	-------------------------------------------------
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LoadingUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1000
	screenGui.Parent = playerGui
	
	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	backdrop.BackgroundTransparency = 0.6
	backdrop.BorderSizePixel = 0
	backdrop.ZIndex = 1
	backdrop.Parent = screenGui
	
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.Size = UDim2.fromOffset(380, 240)
	container.BackgroundTransparency = 1
	container.ZIndex = 2
	container.Parent = screenGui
	
	local containerScale = Instance.new("UIScale")
	containerScale.Scale = 0.85
	containerScale.Parent = container
	
	local glow = Instance.new("Frame")
	glow.Name = "Glow"
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.fromScale(0.5, 0.5)
	glow.Size = UDim2.fromOffset(1, 1)
	glow.BackgroundTransparency = 1
	glow.ZIndex = 1
	glow.Parent = container
	
	local glowLayers = {}
	for i = 1, 3 do
		local layer = Instance.new("Frame")
		layer.AnchorPoint = Vector2.new(0.5, 0.5)
		layer.Position = UDim2.fromScale(0.5, 0.5)
		layer.Size = UDim2.fromOffset(300 + i * 70, 220 + i * 50)
		layer.BackgroundColor3 = (i % 2 == 0) and THEME.Accent or THEME.Accent2
		layer.BackgroundTransparency = 0.92 - (i * 0.015)
		layer.BorderSizePixel = 0
		layer.ZIndex = 1
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = layer
		layer.Parent = glow
		glowLayers[i] = layer
	end
	
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(360, 220)
	card.BackgroundColor3 = THEME.Card
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.ZIndex = 3
	card.Parent = container
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 20)
	cardCorner.Parent = card
	
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = THEME.CardBorder
	cardStroke.Thickness = 1.5
	cardStroke.Transparency = 1
	cardStroke.Parent = card
	
	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, THEME.Accent),
		ColorSequenceKeypoint.new(0.5, THEME.CardBorder),
		ColorSequenceKeypoint.new(1, THEME.Accent2),
	})
	strokeGradient.Parent = cardStroke
	
	local ringContainer = Instance.new("Frame")
	ringContainer.Name = "RingContainer"
	ringContainer.AnchorPoint = Vector2.new(0.5, 0)
	ringContainer.Position = UDim2.new(0.5, 0, 0, 26)
	ringContainer.Size = UDim2.fromOffset(92, 92)
	ringContainer.BackgroundTransparency = 1
	ringContainer.ZIndex = 4
	ringContainer.Parent = card
	
	local trackOuter = Instance.new("Frame")
	trackOuter.Size = UDim2.fromScale(1, 1)
	trackOuter.BackgroundColor3 = THEME.RingTrack
	trackOuter.BorderSizePixel = 0
	trackOuter.ZIndex = 4
	trackOuter.Parent = ringContainer
	local trackOuterCorner = Instance.new("UICorner")
	trackOuterCorner.CornerRadius = UDim.new(1, 0)
	trackOuterCorner.Parent = trackOuter
	
	local trackHole = Instance.new("Frame")
	trackHole.AnchorPoint = Vector2.new(0.5, 0.5)
	trackHole.Position = UDim2.fromScale(0.5, 0.5)
	trackHole.Size = UDim2.fromOffset(76, 76)
	trackHole.BackgroundColor3 = THEME.Card
	trackHole.BorderSizePixel = 0
	trackHole.ZIndex = 5
	trackHole.Parent = ringContainer
	local trackHoleCorner = Instance.new("UICorner")
	trackHoleCorner.CornerRadius = UDim.new(1, 0)
	trackHoleCorner.Parent = trackHole
	
	local function buildHalf(rotationOffset)
		local half = Instance.new("Frame")
		half.Size = UDim2.fromScale(1, 1)
		half.BackgroundTransparency = 1
		half.ClipsDescendants = true
		half.ZIndex = 6
		half.Parent = ringContainer
	
		local filler = Instance.new("Frame")
		filler.Size = UDim2.fromScale(1, 1)
		filler.BackgroundColor3 = THEME.Accent
		filler.BorderSizePixel = 0
		filler.ZIndex = 6
		filler.Parent = half
		local fillerCorner = Instance.new("UICorner")
		fillerCorner.CornerRadius = UDim.new(1, 0)
		fillerCorner.Parent = filler
	
		local fillerGradient = Instance.new("UIGradient")
		fillerGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.Accent), ColorSequenceKeypoint.new(1, THEME.Accent2)})
		fillerGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.5001, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		fillerGradient.Rotation = rotationOffset
		fillerGradient.Parent = filler
	
		local innerHole = Instance.new("Frame")
		innerHole.AnchorPoint = Vector2.new(0.5, 0.5)
		innerHole.Position = UDim2.fromScale(0.5, 0.5)
		innerHole.Size = UDim2.fromOffset(76, 76)
		innerHole.BackgroundColor3 = THEME.Card
		innerHole.BorderSizePixel = 0
		innerHole.ZIndex = 7
		innerHole.Parent = half
		local innerHoleCorner = Instance.new("UICorner")
		innerHoleCorner.CornerRadius = UDim.new(1, 0)
		innerHoleCorner.Parent = innerHole
	
		return half, fillerGradient
	end
	
	local rightHalf, rightGradient = buildHalf(0)
	local leftHalf, leftGradient = buildHalf(180)
	
	local percentLabel = Instance.new("TextLabel")
	percentLabel.Size = UDim2.fromScale(1, 1)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Text = "0%"
	percentLabel.Font = Enum.Font.GothamBold
	percentLabel.TextSize = 20
	percentLabel.TextColor3 = THEME.TextPrimary
	percentLabel.TextTransparency = 1
	percentLabel.ZIndex = 8
	percentLabel.Parent = ringContainer
	
	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 134)
	title.Size = UDim2.new(1, -40, 0, 26)
	title.BackgroundTransparency = 1
	title.Text = "Loading Dupe Script"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = THEME.TextPrimary
	title.TextTransparency = 1
	title.ZIndex = 4
	title.Parent = card
	
	local status = Instance.new("TextLabel")
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.Position = UDim2.new(0.5, 0, 0, 162)
	status.Size = UDim2.new(1, -40, 0, 20)
	status.BackgroundTransparency = 1
	status.Text = "Connecting Script..."
	status.Font = Enum.Font.Gotham
	status.TextSize = 13
	status.TextColor3 = THEME.TextSecond
	status.TextTransparency = 1
	status.ZIndex = 4
	status.Parent = card
	
	local barTrack = Instance.new("Frame")
	barTrack.AnchorPoint = Vector2.new(0.5, 1)
	barTrack.Position = UDim2.new(0.5, 0, 1, -24)
	barTrack.Size = UDim2.new(1, -56, 0, 6)
	barTrack.BackgroundColor3 = THEME.RingTrack
	barTrack.BackgroundTransparency = 1
	barTrack.BorderSizePixel = 0
	barTrack.ZIndex = 4
	barTrack.Parent = card
	
	local barTrackCorner = Instance.new("UICorner")
	barTrackCorner.CornerRadius = UDim.new(1, 0)
	barTrackCorner.Parent = barTrack
	
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.BackgroundColor3 = THEME.Accent
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 5
	barFill.Parent = barTrack
	
	local barFillCorner = Instance.new("UICorner")
	barFillCorner.CornerRadius = UDim.new(1, 0)
	barFillCorner.Parent = barFill
	
	local barGradient = Instance.new("UIGradient")
	barGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.Accent), ColorSequenceKeypoint.new(1, THEME.Accent2)})
	barGradient.Parent = barFill
	
	-- Intro Run
	TweenService:Create(containerScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	local introTargets = {
		{card, "BackgroundTransparency", 0},
		{cardStroke, "Transparency", 0.15},
		{title, "TextTransparency", 0},
		{status, "TextTransparency", 0},
		{percentLabel, "TextTransparency", 0},
		{barTrack, "BackgroundTransparency", 0},
	}
	for _, e in ipairs(introTargets) do
		TweenService:Create(e[1], TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[e[2]] = e[3]}):Play()
	end
	
	local running = true
	task.spawn(function()
		local t = 0
		while running do
			t += task.wait()
			container.Position = UDim2.new(0.5, 0, 0.5, math.sin(t * 1.4) * 4)
		end
	end)
	
	local LoadingUI = {}
	local currentProgress = 0
	
	function LoadingUI:SetStatus(text) status.Text = text end
	
	function LoadingUI:SetProgress(value)
		value = math.clamp(value, 0, 1)
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		currentProgress = value
		TweenService:Create(barFill, tweenInfo, {Size = UDim2.fromScale(value, 1)}):Play()
		local degrees = value * 360
		if degrees <= 180 then
			TweenService:Create(rightGradient, tweenInfo, {Rotation = degrees}):Play()
			leftGradient.Rotation = 180
		else
			rightGradient.Rotation = 180
			TweenService:Create(leftGradient, tweenInfo, {Rotation = degrees}):Play()
		end
		percentLabel.Text = math.floor(value * 100) .. "%"
	end
	
	function LoadingUI:Destroy()
		running = false
		TweenService:Create(containerScale, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.85}):Play()
		TweenService:Create(backdrop, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
		task.delay(0.4, function() screenGui:Destroy() end)
	end
	
	-------------------------------------------------
	-- STAGE 2: VISUAL DUPE MANAGEMENT CORE LOGIC
	-------------------------------------------------
	local function getCharacter() return player.Character or player.CharacterAdded:Wait() end
	
	local function getHeldPet()
		local char = getCharacter()
		return char and char:FindFirstChildOfClass("Tool")
	end
	
	local function prepareVisualClone(instance)
		for _, desc in ipairs(instance:GetDescendants()) do
			if desc:IsA("LuaSourceContainer") then
				desc:Destroy()
			elseif desc:IsA("BasePart") then
				desc.Anchored = true
				desc.CanCollide = false
				desc.CanTouch = false
				desc.CanQuery = false
				desc.Massless = true
			end
		end
	end
	
	local function getClonePrimaryPart(clone)
		if clone:IsA("Tool") then return clone:FindFirstChild("Handle") end
		if clone:IsA("Model") then return clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart") end
		return clone:FindFirstChildWhichIsA("BasePart", true) or clone
	end
	
	local function getVisualParts(instance)
		local parts = {}
		if instance:IsA("BasePart") then table.insert(parts, instance) end
		for _, desc in ipairs(instance:GetDescendants()) do
			if desc:IsA("BasePart") then table.insert(parts, desc) end
		end
		return parts
	end
	
	local function getPartOffsets(parts, pivotCFrame)
		local offsets = {}
		for _, part in ipairs(parts) do offsets[part] = pivotCFrame:ToObjectSpace(part.CFrame) end
		return offsets
	end
	
	local function destroyOldestDupe()
		local oldest = table.remove(activeDupes, 1)
		if oldest and oldest.clone then oldest.clone:Destroy() end
		refreshDupeUi()
	end
	
	local function clearVisualDupes()
		for i = #activeDupes, 1, -1 do
			activeDupes[i].clone:Destroy()
			table.remove(activeDupes, i)
		end
		refreshDupeUi()
	end
	
	local function dupeHeldPetVisualOnly()
		local heldPet = getHeldPet()
		if not heldPet then return false, "Hold the pet item first!" end
	
		local char = getCharacter()
		local root = char:FindFirstChild("HumanoidRootPart")
		local sourcePart = getClonePrimaryPart(heldPet)
		if not root or not sourcePart then return false, "Invalid object structure." end
	
		local clone = heldPet:Clone()
		clone.Name = heldPet.Name .. "Dupe Pets"
		prepareVisualClone(clone)
		clone.Parent = workspace
	
		local clonePivot = getClonePrimaryPart(clone)
		local parts = getVisualParts(clone)
	
		if #activeDupes >= MAX_VISUAL_DUPES then destroyOldestDupe() end
	
		-- Arrange array layout offset
		local placementOffset = DUPE_OFFSET + Vector3.new(#activeDupes * 2, math.sin(#activeDupes), 0)
	
		table.insert(activeDupes, {
			clone = clone,
			parts = parts,
			offsets = getPartOffsets(parts, clonePivot.CFrame),
			spacing = placementOffset
		})
	
		refreshDupeUi()
		return true
	end
	
	-- Runtime Follow Engine loop for Local Duplicates
	RunService.RenderStepped:Connect(function()
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end
	
		for _, dupe in ipairs(activeDupes) do
			if dupe.clone and dupe.clone.Parent then
				local targetCFrame = root.CFrame * CFrame.new(dupe.spacing)
				for _, part in ipairs(dupe.parts) do
					if part.Parent then
						part.CFrame = targetCFrame * dupe.offsets[part]
					end
				end
			end
		end
	end)
	
	-------------------------------------------------
	-- STAGE 3: INTERACTIVE MANAGER CONTROLS (GUI)
	-------------------------------------------------
	local function tween(inst, props, dur)
		TweenService:Create(inst, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end
	
	local function buildControlPanel()
		local mainGui = Instance.new("ScreenGui")
		mainGui.Name = "PetDuperSystem"
		mainGui.ResetOnSpawn = false
		mainGui.Parent = playerGui
	
		local openButton = Instance.new("TextButton")
		openButton.Name = "OpenButton"
		openButton.Position = UDim2.fromScale(0.85, 0.9)
		openButton.Size = UDim2.fromOffset(120, 40)
		openButton.BackgroundColor3 = Color3.fromRGB(37, 161, 96)
		openButton.Font = Enum.Font.GothamBold
		openButton.Text = "DUPE PETS"
		openButton.TextColor3 = Color3.new(1,1,1)
		openButton.TextSize = 13
		openButton.Visible = false
		openButton.Parent = mainGui
		Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 8)
	
		local panel = Instance.new("Frame")
		panel.Name = "Panel"
		panel.Position = UDim2.fromScale(0.4, 0.4)
		panel.Size = UDim2.fromOffset(320, 180)
		panel.BackgroundColor3 = Color3.fromRGB(20, 25, 32)
		panel.Parent = mainGui
		Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
	
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, 30)
		titleLabel.Position = UDim2.fromOffset(15, 10)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "Pet Duper"
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 18
		titleLabel.TextColor3 = Color3.new(1,1,1)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = panel
	
		local subLabel = Instance.new("TextLabel")
		subLabel.Size = UDim2.new(1, -30, 0, 20)
		subLabel.Position = UDim2.fromOffset(15, 35)
		subLabel.BackgroundTransparency = 1
		subLabel.Text = "Equip and hold your pet item to dupe"
		subLabel.Font = Enum.Font.Gotham
		subLabel.TextSize = 12
		subLabel.TextColor3 = Color3.fromRGB(150, 160, 170)
		subLabel.TextXAlignment = Enum.TextXAlignment.Left
		subLabel.Parent = panel
	
		local meterBack = Instance.new("Frame")
		meterBack.Position = UDim2.fromOffset(15, 70)
		meterBack.Size = UDim2.new(1, -30, 0, 8)
		meterBack.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
		meterBack.Parent = panel
		Instance.new("UICorner", meterBack)
	
		local meterFill = Instance.new("Frame")
		meterFill.Size = UDim2.fromScale(0, 1)
		meterFill.BackgroundColor3 = Color3.fromRGB(92, 255, 171)
		meterFill.Parent = meterBack
		Instance.new("UICorner", meterFill)
	
		local statusLabel = Instance.new("TextLabel")
		statusLabel.Position = UDim2.fromOffset(15, 85)
		statusLabel.Size = UDim2.new(1, -30, 0, 20)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Text = "System Status: Idle"
		statusLabel.Font = Enum.Font.GothamSemibold
		statusLabel.TextSize = 12
		statusLabel.TextColor3 = Color3.fromRGB(92, 255, 171)
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.Parent = panel
	
		local actionBtn = Instance.new("TextButton")
		actionBtn.Position = UDim2.fromOffset(15, 120)
		actionBtn.Size = UDim2.fromOffset(180, 45)
		actionBtn.BackgroundColor3 = Color3.fromRGB(37, 161, 96)
		actionBtn.Font = Enum.Font.GothamBold
		actionBtn.Text = "⚡ Duplicate Pets"
		actionBtn.TextColor3 = Color3.new(1,1,1)
		actionBtn.TextSize = 14
		actionBtn.Parent = panel
		Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)
	
		local clearBtn = Instance.new("TextButton")
		clearBtn.Position = UDim2.fromOffset(205, 120)
		clearBtn.Size = UDim2.fromOffset(100, 45)
		clearBtn.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
		clearBtn.Font = Enum.Font.GothamBold
		clearBtn.Text = "Clear"
		clearBtn.TextColor3 = Color3.new(1,1,1)
		clearBtn.TextSize = 14
		clearBtn.Parent = panel
		Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
	
		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.fromOffset(25, 25)
		closeBtn.Position = UDim2.new(1, -35, 0, 10)
		closeBtn.BackgroundColor3 = Color3.fromRGB(50,55,65)
		closeBtn.Text = "X"
		closeBtn.TextColor3 = Color3.new(1,1,1)
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 12
		closeBtn.Parent = panel
		Instance.new("UICorner", closeBtn)
	
		-- Drag functionality
		local dragging, dragStart, startPos
		panel.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = panel.Position
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	
		-- Interface Actions
		refreshDupeUi = function()
			local activeCount = #activeDupes
			statusLabel.Text = string.format("System Status: %d/%d visual copies active", activeCount, MAX_VISUAL_DUPES)
			tween(meterFill, {Size = UDim2.fromScale(activeCount / MAX_VISUAL_DUPES, 1)}, 0.2)
		end
	
		actionBtn.Activated:Connect(function()
			local success, err = dupeHeldPetVisualOnly()
			if success then
				statusLabel.TextColor3 = Color3.fromRGB(92, 255, 171)
				statusLabel.Text = "✔ Visual Clone Manifested"
			else
				statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
				statusLabel.Text = "❌ " .. err
			end
			task.delay(1.5, refreshDupeUi)
		end)
	
		clearBtn.Activated:Connect(function()
			clearVisualDupes()
			statusLabel.Text = "Cleared all local instances."
		end)
	
		closeBtn.Activated:Connect(function()
			panel.Visible = false
			openButton.Visible = true
		end)
	
		openButton.Activated:Connect(function()
			openButton.Visible = false
			panel.Visible = true
		end)
	end
	
	-------------------------------------------------
	-- RUN SEQUENCER
	-------------------------------------------------
	task.spawn(function()
		local stages = {"Loading Dupe Script...", "Loading Script...", "Almost there..."}
		for i = 1, 100 do
			LoadingUI:SetProgress(i / 100)
			if i % 33 == 0 then
				LoadingUI:SetStatus(stages[math.clamp(math.floor(i/33), 1, #stages)])
			end
			task.wait(0.02)
		end
		LoadingUI:SetStatus("Ready!")
		task.wait(0.5)
		LoadingUI:Destroy()
	
		-- Fire up control board panel 
		buildControlPanel()
	end)
end
coroutine.wrap(YFTY_fake_script)()
