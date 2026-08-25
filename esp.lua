-- =============================================
-- GENERIC ESP HUB v2 (Mejorado)
-- =============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local gui = Instance.new("ScreenGui")
gui.Name = "GenericESPHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 440, 0, 560)
mainFrame.Position = UDim2.new(0.5, -220, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Título + botones
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.Text = "🔍 Generic ESP Hub v2"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -50, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextScaled = true
minimizeBtn.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -95, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextScaled = true
closeBtn.Parent = mainFrame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -55)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Path input
local pathBox = Instance.new("TextBox")
pathBox.Size = UDim2.new(1, -90, 0, 36)
pathBox.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
pathBox.PlaceholderText = "workspace.Items  |  o usa el botón 👁"
pathBox.Text = ""
pathBox.TextColor3 = Color3.new(1, 1, 1)
pathBox.TextScaled = true
pathBox.Font = Enum.Font.Gotham
pathBox.Parent = content

local pickBtn = Instance.new("TextButton")
pickBtn.Size = UDim2.new(0, 80, 0, 36)
pickBtn.Position = UDim2.new(1, -80, 0, 0)
pickBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
pickBtn.Text = "👁 Pick"
pickBtn.TextColor3 = Color3.new(1, 1, 1)
pickBtn.TextScaled = true
pickBtn.Parent = content

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, 0, 0, 34)
addBtn.Position = UDim2.new(0, 0, 0, 42)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
addBtn.Text = "➕ Agregar ESP"
addBtn.TextColor3 = Color3.new(1, 1, 1)
addBtn.TextScaled = true
addBtn.Font = Enum.Font.GothamBold
addBtn.Parent = content

-- Opciones globales
local optionsFrame = Instance.new("Frame")
optionsFrame.Size = UDim2.new(1, 0, 0, 30)
optionsFrame.Position = UDim2.new(0, 0, 0, 82)
optionsFrame.BackgroundTransparency = 1
optionsFrame.Parent = content

local function makeToggle(text, posX, default)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 0, 26)
	btn.Position = UDim2.new(0, posX, 0, 0)
	btn.BackgroundColor3 = default and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Parent = optionsFrame
	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.BackgroundColor3 = state and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(60, 60, 60)
	end)
	return function() return state end
end

local getHighlight = makeToggle("Highlight", 0, true)
local getLine = makeToggle("Línea", 110, true)
local getDist = makeToggle("Distancia", 220, true)

local maxDistBox = Instance.new("TextBox")
maxDistBox.Size = UDim2.new(0, 90, 0, 26)
maxDistBox.Position = UDim2.new(0, 330, 0, 0)
maxDistBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
maxDistBox.Text = "500"
maxDistBox.PlaceholderText = "MaxDist"
maxDistBox.TextColor3 = Color3.new(1, 1, 1)
maxDistBox.TextScaled = true
maxDistBox.Parent = optionsFrame

-- Lista
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -120)
scroll.Position = UDim2.new(0, 0, 0, 118)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.Parent = content

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scroll

-- ================== LÓGICA ==================
local activeESPs = {}

local function getFullPath(obj)
	if not obj then return "nil" end
	local parts = {}
	local current = obj
	while current and current ~= game do
		table.insert(parts, 1, current.Name)
		current = current.Parent
	end
	return table.concat(parts, ".")
end

local function getObjectFromPath(pathStr)
	if not pathStr or pathStr == "" then return nil end

	local success, result = pcall(function()
		return loadstring("return " .. pathStr)()
	end)
	if success and result then return result end

	local obj = game
	for part in string.gmatch(pathStr, "[^%.]+") do
		if part:lower() == "workspace" then
			obj = workspace
		elseif part:lower() == "game" then
			obj = game
		else
			obj = obj:FindFirstChild(part)
			if not obj then return nil end
		end
	end
	return obj
end

local function clearESPData(data)
	for _, h in pairs(data.highlights or {}) do
		if h and h.Parent then h:Destroy() end
	end
	for _, l in pairs(data.lines or {}) do
		if l then l:Remove() end
	end
	for _, t in pairs(data.texts or {}) do
		if t then t:Remove() end
	end
	data.highlights = {}
	data.lines = {}
	data.texts = {}
end

local function createIndividualEntry(parentScroll, obj, parentGroup)
	local path = getFullPath(obj)
	local displayName = obj.Name

	local espData = {
		object = obj,
		path = path,
		enabled = true,
		highlights = {},
		lines = {},
		texts = {},
		isIndividual = true,
		parentGroup = parentGroup
	}

	local entry = Instance.new("Frame")
	entry.Size = UDim2.new(1, -10, 0, 42)
	entry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	entry.Parent = parentScroll
	Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -130, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "    └ " .. displayName
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.Parent = entry

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 50, 0, 26)
	toggleBtn.Position = UDim2.new(1, -115, 0.5, -13)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	toggleBtn.Text = "ON"
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
	toggleBtn.TextScaled = true
	toggleBtn.Parent = entry

	local removeBtn = Instance.new("TextButton")
	removeBtn.Size = UDim2.new(0, 50, 0, 26)
	removeBtn.Position = UDim2.new(1, -60, 0.5, -13)
	removeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	removeBtn.Text = "Del"
	removeBtn.TextColor3 = Color3.new(1, 1, 1)
	removeBtn.TextScaled = true
	removeBtn.Parent = entry

	toggleBtn.MouseButton1Click:Connect(function()
		espData.enabled = not espData.enabled
		toggleBtn.Text = espData.enabled and "ON" or "OFF"
		toggleBtn.BackgroundColor3 = espData.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(70, 70, 70)
		if not espData.enabled then
			clearESPData(espData)
		end
	end)

	removeBtn.MouseButton1Click:Connect(function()
		clearESPData(espData)
		entry:Destroy()
		activeESPs[path] = nil
	end)

	activeESPs[path] = espData
	return espData
end

-- ========== CREAR GRUPO (Carpeta / Modelo) ==========
local function createGroupEntry(pathStr, target)
	local displayName = target.Name
	local isContainer = target:IsA("Folder") or target:IsA("Model") or target:IsA("Configuration")

	-- Entry del grupo
	local groupFrame = Instance.new("Frame")
	groupFrame.Size = UDim2.new(1, 0, 0, 52)
	groupFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	groupFrame.Parent = scroll
	Instance.new("UICorner", groupFrame).CornerRadius = UDim.new(0, 8)

	local groupLabel = Instance.new("TextLabel")
	groupLabel.Size = UDim2.new(1, -160, 1, 0)
	groupLabel.Position = UDim2.new(0, 10, 0, 0)
	groupLabel.BackgroundTransparency = 1
	groupLabel.Text = (isContainer and "📦 " or "🔹 ") .. displayName
	groupLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
	groupLabel.TextXAlignment = Enum.TextXAlignment.Left
	groupLabel.TextScaled = true
	groupLabel.Font = Enum.Font.GothamBold
	groupLabel.Parent = groupFrame

	local expandBtn = Instance.new("TextButton")
	expandBtn.Size = UDim2.new(0, 60, 0, 28)
	expandBtn.Position = UDim2.new(1, -140, 0.5, -14)
	expandBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
	expandBtn.Text = "Abrir"
	expandBtn.TextColor3 = Color3.new(1, 1, 1)
	expandBtn.TextScaled = true
	expandBtn.Parent = groupFrame

	local removeGroupBtn = Instance.new("TextButton")
	removeGroupBtn.Size = UDim2.new(0, 60, 0, 28)
	removeGroupBtn.Position = UDim2.new(1, -70, 0.5, -14)
	removeGroupBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	removeGroupBtn.Text = "Del"
	removeGroupBtn.TextColor3 = Color3.new(1, 1, 1)
	removeGroupBtn.TextScaled = true
	removeGroupBtn.Parent = groupFrame

	-- Contenedor de hijos (oculto por defecto)
	local childrenFrame = Instance.new("Frame")
	childrenFrame.Size = UDim2.new(1, 0, 0, 0)
	childrenFrame.BackgroundTransparency = 1
	childrenFrame.Visible = false
	childrenFrame.Parent = scroll

	local childrenLayout = Instance.new("UIListLayout")
	childrenLayout.Padding = UDim.new(0, 3)
	childrenLayout.Parent = childrenFrame

	local expanded = false
	local childEntries = {}

	expandBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		childrenFrame.Visible = expanded
		expandBtn.Text = expanded and "Cerrar" or "Abrir"

		if expanded and #childEntries == 0 then
			-- Crear los hijos solo la primera vez que se abre
			for _, child in ipairs(target:GetDescendants()) do
				if child:IsA("BasePart") then
					local data = createIndividualEntry(childrenFrame, child, pathStr)
					table.insert(childEntries, data)
				end
			end
		end

		-- Actualizar tamaño del canvas
		task.wait()
		scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
	end)

	removeGroupBtn.MouseButton1Click:Connect(function()
		for _, data in pairs(childEntries) do
			clearESPData(data)
			activeESPs[data.path] = nil
		end
		groupFrame:Destroy()
		childrenFrame:Destroy()
	end)
end

-- Actualización (mucho más eficiente)
RunService.RenderStepped:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local maxDist = tonumber(maxDistBox.Text) or 500
	local showHL = getHighlight()
	local showLine = getLine()
	local showDist = getDist()

	for path, data in pairs(activeESPs) do
		-- Ahora usamos data.object (no data.target)
		if not data.enabled or not data.object or not data.object.Parent then
			clearESPData(data)
			continue
		end

		local obj = data.object
		if not obj:IsA("BasePart") then
			clearESPData(data)
			continue
		end

		local dist = (obj.Position - root.Position).Magnitude
		if dist > maxDist then
			clearESPData(data)
			continue
		end

		-- Limpiar dibujos anteriores
		clearESPData(data)

		-- Highlight
		if showHL then
			local hl = Instance.new("Highlight")
			hl.Adornee = obj
			hl.FillColor = Color3.fromRGB(0, 255, 120)
			hl.OutlineColor = Color3.fromRGB(255, 255, 0)
			hl.FillTransparency = 0.65
			hl.OutlineTransparency = 0
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = obj
			table.insert(data.highlights, hl)
		end

		local screenPos, onScreen = camera:WorldToViewportPoint(obj.Position)
		if onScreen then
			local playerScreen = camera:WorldToViewportPoint(root.Position)

			if showLine then
				local line = Drawing.new("Line")
				line.From = Vector2.new(playerScreen.X, playerScreen.Y)
				line.To = Vector2.new(screenPos.X, screenPos.Y)
				line.Color = Color3.fromRGB(0, 255, 120)
				line.Thickness = 1.5
				line.Transparency = 0.7
				line.Visible = true
				table.insert(data.lines, line)
			end

			if showDist then
				local text = Drawing.new("Text")
				text.Text = string.format("%.0f", dist)
				text.Position = Vector2.new(screenPos.X + 8, screenPos.Y - 12)
				text.Size = 15
				text.Color = Color3.new(1, 1, 1)
				text.Outline = true
				text.Visible = true
				table.insert(data.texts, text)
			end
		end
	end
end)

-- ========== FUNCIÓN PRINCIPAL DE AGREGAR ==========
local function createESP(pathStr)
	local target = getObjectFromPath(pathStr)
	if not target then
		warn("❌ Path no encontrado:", pathStr)
		return
	end

	local isContainer = target:IsA("Folder") or target:IsA("Model") or #target:GetChildren() > 3

	if isContainer then
		createGroupEntry(pathStr, target)
		print("✅ Grupo agregado:", target.Name)
	else
		-- Objeto individual
		createIndividualEntry(scroll, target, nil)
		print("✅ Objeto agregado:", target.Name)
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end

-- Botón Agregar (actualizado)
addBtn.MouseButton1Click:Connect(function()
	local path = pathBox.Text:match("^%s*(.-)%s*$")
	if path == "" then return end
	createESP(path)
	pathBox.Text = ""
end)

pickBtn.MouseButton1Click:Connect(function()
	local target = mouse.Target
	if target then
		pathBox.Text = getFullPath(target)
	end
end)

minimizeBtn.MouseButton1Click:Connect(function()
	content.Visible = not content.Visible
	mainFrame.Size = content.Visible and UDim2.new(0, 440, 0, 560) or UDim2.new(0, 440, 0, 50)
	minimizeBtn.Text = content.Visible and "─" or "＋"
end)

closeBtn.MouseButton1Click:Connect(function()
	for _, data in pairs(activeESPs) do
		clearESPData(data)
	end
	gui:Destroy()
end)

print("✅ Generic ESP Hub v2 cargado")
