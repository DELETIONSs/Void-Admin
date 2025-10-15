-- // src/init.lua
-- CLIENT-SIDE ADMIN SCRIPT (for executors like Xeno/Solara)
-- Theme: Dark
-- GitHub-style modular loader

local Services = setmetatable({}, {
	__index = function(_, service)
		return cloneref(game:GetService(service))
	end
})

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local CoreGui = Services.CoreGui
local UserInputService = Services.UserInputService

-- // Protect GUI
local AdminUI = Instance.new("ScreenGui")
AdminUI.Name = "DarkAdminUI"
if syn and syn.protect_gui then
	syn.protect_gui(AdminUI)
	AdminUI.Parent = CoreGui
else
	AdminUI.Parent = gethui and gethui() or CoreGui
end

-- // UI Setup
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 60)
Frame.Position = UDim2.new(0.5, -200, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = AdminUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Box = Instance.new("TextBox")
Box.Size = UDim2.new(1, -20, 1, -20)
Box.Position = UDim2.new(0, 10, 0, 10)
Box.PlaceholderText = "Enter command..."
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.BackgroundTransparency = 1
Box.ClearTextOnFocus = false
Box.TextSize = 18
Box.Font = Enum.Font.Code
Box.Parent = Frame

-- // Toggle visibility with ;
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Semicolon then
		Frame.Visible = not Frame.Visible
		if Frame.Visible then
			task.wait()
			Box:CaptureFocus()
		else
			Box:ReleaseFocus()
		end
	end
end)

-- // Command Handler
local function GetCommandModules()
	local success, result = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/DELETIONSs/Void-Admin/refs/heads/main/commands/index.json")
	end)
	if not success then return {} end
	local ok, data = pcall(function() return game.HttpService:JSONDecode(result) end)
	return ok and data or {}
end

local Commands = {}
for _, cmdName in ipairs(GetCommandModules()) do
	local url = string.format("https://raw.githubusercontent.com/DELETIONSs/Void-Admin/refs/heads/main/commands/%s.lua", cmdName)
	local func, err = loadstring(game:HttpGet(url))
	if func then
		local module = func()
		if type(module) == "table" and module.Run then
			Commands[module.Name:lower()] = module.Run
		end
	end
end

-- // Execute when Enter is pressed
Box.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	local input = Box.Text
	local split = input:split(" ")
	local commandName = split[1]:lower()
	table.remove(split, 1)
	if Commands[commandName] then
		pcall(function() Commands[commandName](unpack(split)) end)
	else
		warn("[DarkAdmin] Unknown command:", commandName)
	end
	Box.Text = ""
end)
