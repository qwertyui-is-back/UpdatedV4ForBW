-- Credits to Inf Yield & all the other scripts that helped me make bypasses
local GuiLibrary = shared.GuiLibrary
local players = game:GetService("Players")
local textservice = game:GetService("TextService")
local lplr = players.LocalPlayer
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera
local targetinfo = shared.VapeTargetInfo
local uis = game:GetService("UserInputService")
local localmouse = lplr:GetMouse()
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local getasset = getsynasset or getcustomasset

local RenderStepTable = {}
local StepTable = {}

local function BindToRenderStep(name, num, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStep(name)
	if RenderStepTable[name] then
		RenderStepTable[name]:Disconnect()
		RenderStepTable[name] = nil
	end
end

local function BindToStepped(name, num, func)
	if StepTable[name] == nil then
		StepTable[name] = game:GetService("RunService").Stepped:connect(func)
	end
end
local function UnbindFromStepped(name)
	if StepTable[name] then
		StepTable[name]:Disconnect()
		StepTable[name] = nil
	end
end

local function createwarning(title, text, delay)
	pcall(function()
		local frame = GuiLibrary["CreateNotification"](title, text, delay, "assets/WarningNotification.png")
		frame.Frame.BackgroundColor3 = Color3.fromRGB(236, 129, 44)
		frame.Frame.Frame.BackgroundColor3 = Color3.fromRGB(236, 129, 44)
	end)
end

local function friendCheck(plr, recolor)
	return (recolor and GuiLibrary["ObjectsThatCanBeSaved"]["Recolor visualsToggle"]["Api"]["Enabled"] or (not recolor)) and GuiLibrary["ObjectsThatCanBeSaved"]["Use FriendsToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectList"], plr.Name) and GuiLibrary["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectListEnabled"][table.find(GuiLibrary["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectList"], plr.Name)]
end

local function getPlayerColor(plr)
	return (friendCheck(plr, true) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Hue"], GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Sat"], GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"]) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color)
end

local function getcustomassetfunc(path)
	if not isfile(path) then
		spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary["MainGui"]
			repeat wait() until isfile(path)
			textlabel:Remove()
		end)
		local req = requestfunc({
			Url = "https://raw.githubusercontent.com/qwertyui-is-back/UpdatedV4ForBW/main/"..path:gsub("vape/assets", "assets"),
			Method = "GET"
		})
		writefile(path, req.Body)
	end
	return getasset(path) 
end

shared.vapeteamcheck = function(plr)
	return (GuiLibrary["ObjectsThatCanBeSaved"]["Teams by colorToggle"]["Api"]["Enabled"] and (plr.Team ~= lplr.Team or (lplr.Team == nil or #lplr.Team:GetPlayers() == #game:GetService("Players"):GetChildren())) or GuiLibrary["ObjectsThatCanBeSaved"]["Teams by colorToggle"]["Api"]["Enabled"] == false)
end

local function targetCheck(plr, check)
	return (check and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("ForceField") == nil or check == false)
end

local function isAlive(plr)
	if plr then
		return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
	end
	return lplr and lplr.Character and lplr.Character.Parent ~= nil and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character:FindFirstChild("Head") and lplr.Character:FindFirstChild("Humanoid")
end

local function isPlayerTargetable(plr, target, friend)
    return plr ~= lplr and plr and (friend and friendCheck(plr) == nil or (not friend)) and isAlive(plr) and targetCheck(plr, target) and shared.vapeteamcheck(plr)
end

local function vischeck(char, part)
	return not unpack(cam:GetPartsObscuringTarget({lplr.Character[part].Position, char[part].Position}, {lplr.Character, char}))
end

local function runcode(func)
	func()
end

local run = runcode

local function GetAllNearestHumanoidToPosition(player, distance, amount)
	local returnedplayer = {}
	local currentamount = 0
    if isAlive() then
        for i, v in pairs(players:GetChildren()) do
            if isPlayerTargetable((player and v or nil), true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and currentamount < amount then
                local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                if mag <= distance then
                    table.insert(returnedplayer, v)
					currentamount = currentamount + 1
                end
            end
        end
	end
	return returnedplayer
end

local function GetNearestHumanoidToPosition(player, distance)
	local closest, returnedplayer = distance, nil
    if isAlive() then
        for i, v in pairs(players:GetChildren()) do
            if isPlayerTargetable((player and v or nil), true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
                local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                if mag <= closest then
                    closest = mag
                    returnedplayer = v
                end
            end
        end
	end
	return returnedplayer
end

local function GetNearestHumanoidToMouse(player, distance, checkvis)
    local closest, returnedplayer = distance, nil
    if isAlive() then
        for i, v in pairs(players:GetChildren()) do
            if isPlayerTargetable((player and v or nil), true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and (checkvis == false or checkvis and (vischeck(v.Character, "Head") or vischeck(v.Character, "HumanoidRootPart"))) then
                local vec, vis = cam:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (uis:GetMouseLocation() - Vector2.new(vec.X, vec.Y)).magnitude
                    if mag <= closest then
                        closest = mag
                        returnedplayer = v
                    end
                end
            end
        end
    end
    return returnedplayer
end

local function CalculateObjectPosition(pos)
	local newpos = cam:WorldToViewportPoint(cam.CFrame:pointToWorldSpace(cam.CFrame:pointToObjectSpace(pos)))
	return Vector2.new(newpos.X, newpos.Y)
end

local function CalculateLine(startVector, endVector, obj)
	local Distance = (startVector - endVector).Magnitude
	obj.Size = UDim2.new(0, Distance, 0, 2)
	obj.Position = UDim2.new(0, (startVector.X + endVector.X) / 2, 0, ((startVector.Y + endVector.Y) / 2) - 36)
	obj.Rotation = math.atan2(endVector.Y - startVector.Y, endVector.X - startVector.X) * (180 / math.pi)
end

local function findTouchInterest(tool)
	for i,v in pairs(tool:GetDescendants()) do
		if v:IsA("TouchTransmitter") then
			return v
		end
	end
	return nil
end

local knit = game:GetService("ReplicatedStorage").Packages.Knit
local services = knit:WaitForChild('Services')
local ToolService = services:WaitForChild('ToolService')

local store = {
    AttackRemote = ToolService:WaitForChild("RF").AttackPlayerWithSword,
    BlockRemote = ToolService:WaitForChild("RF").ToggleBlockSword
}
local entityLibrary = shared.vapeentity
GuiLibrary["RemoveObject"]("KillauraOptionsButton")
GuiLibrary.RemoveObject("SpeedOptionsButton")
local GetAllTargets = function(distance, sort)
    local targets = {}
    for i,v in players:GetChildren() do 
        if v ~= lplr and isAlive(v) and isAlive(lplr) then 
            local playerdistance = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if playerdistance <= (distance or math.huge) then 
                table.insert(targets, {Human = true, RootPart = v.Character.PrimaryPart, Humanoid = v.Character.Humanoid, Player = v})
            end
        end
    end
    if sort then 
        table.sort(targets, sort)
    end
    return targets
end
local function getSword()
    local sword = ""
    if lplr.Character:FindFirstChild("WoodenSword") then
        sword = "WoodenSword"
    elseif lplr.Character:FindFirstChild("Sword") then
        sword = "Sword"
    end
    return sword
end
local functions = {
    Attack = function(ent, bool, item)
        store.AttackRemote:InvokeServer(ent.Character, bool, item)
    end,
    Block = function(bool)
        bool = bool or true
        store.BlockRemote:InvokeServer(bool)
    end
}
local killauranear = false
run(function()
    local Killaura = {Enabled = false}
    local Autoblock = {Enabled = false}
    local range = {Value = 20}
    local blocking = false
    local function block()
        local shouldBlock = not blocking
        functions.Block(shouldBlock, "WoodenSword")
        blocking = not blocking
    end
    Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "Killaura",
        Function = function(callback)
            if callback then
                BindToRenderStep("aura",1,function()
                    killauranear = false
                    pcall(function()
                        if isAlive() then
                            --print("alive")
                            local plr = GetAllTargets(range.Value)
                            local targettable = {}
                            local targetsize = 0
                            for i,v in next, plr do
                                killauranear = true
                                --print("there are players")
                                local localfacing = lplr.Character.HumanoidRootPart.CFrame.lookVector
                                local vec = (v.Player.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).unit
                                local angle = math.acos(localfacing:Dot(vec))
                                killauranear = true
                                lplr.Character:SetPrimaryPartCFrame(CFrame.new(lplr.Character.PrimaryPart.Position, Vector3.new(v.Player.Character:FindFirstChild("HumanoidRootPart").Position.X, lplr.Character.PrimaryPart.Position.Y, v.Player.Character:FindFirstChild("HumanoidRootPart").Position.Z)))
                                local targets = GetAllTargets(15)
                                functions.Attack(v.Player.Character, true, getSword())
                                if Autoblock.Enabled then
                                    block()
                                end
                                --print("attacked")
                            end
                        end
                    end)
                end)
            else
                UnbindFromRenderStep("aura")
            end
        end
    })
	range = Killaura.CreateSlider({
		["Name"] = "Attack range",
		["Min"] = 1,
		["Max"] = 25,
        ["Default"] = 25, 
		["Function"] = function(val) end
	})
    Autoblock = Killaura.CreateToggle({
        Name = "Autoblock",
        Default = true,
        Function = function() end
    })
end)

runcode(function()
	local Speed = {Enabled = false}
	local SpeedValue = {Value = 1}
	local SpeedMethod = {Value = "AntiCheat A"}
	local SpeedMoveMethod = {Value = "MoveDirection"}
	local SpeedDelay = {Value = 0.7}
	local SpeedPulseDuration = {Value = 100}
	local SpeedWallCheck = {Enabled = true}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local SpeedDelayTick = tick()
	local SpeedRaycast = RaycastParams.new()
	SpeedRaycast.FilterType = Enum.RaycastFilterType.Blacklist
	SpeedRaycast.RespectCanCollide = true
	local oldWalkSpeed
	local SpeedDown
	local SpeedUp
	local w = 0
	local s = 0
	local a = 0
	local d = 0

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B", "AntiCheat C", "AntiCheat D"}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				w = uis:IsKeyDown(Enum.KeyCode.W) and -1 or 0
				s = uis:IsKeyDown(Enum.KeyCode.S) and 1 or 0
				a = uis:IsKeyDown(Enum.KeyCode.A) and -1 or 0
				d = uis:IsKeyDown(Enum.KeyCode.D) and 1 or 0
				table.insert(Speed.Connections, uis.InputBegan:Connect(function(input1)
					if uis:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.W then
							w = -1
						end
						if input1.KeyCode == Enum.KeyCode.S then
							s = 1
						end
						if input1.KeyCode == Enum.KeyCode.A then
							a = -1
						end
						if input1.KeyCode == Enum.KeyCode.D then
							d = 1
						end
					end
				end))
				table.insert(Speed.Connections, uis.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.W then
						w = 0
					end
					if input1.KeyCode == Enum.KeyCode.S then
						s = 0
					end
					if input1.KeyCode == Enum.KeyCode.A then
						a = 0
					end
					if input1.KeyCode == Enum.KeyCode.D then
						d = 0
					end
				end))
				BindToStepped("Speed", 1, function(time, delta)
					if isAlive() then
						local speed = SpeedValue.Value * 20
						if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) then
							speed = speed * 1.65
						end
						local newvelo = (entityLibrary.character.Humanoid.MoveDirection * speed) * delta
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, newvelo.Z)
						if SpeedJump.Enabled and (SpeedJumpAlways.Enabled or killauranear) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpVanilla.Enabled then
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end
						end
					end
				end)
			else
				UnbindFromStepped("Speed")
			end
		end,
		ExtraText = function()
			if GuiLibrary.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"].Api.Enabled then
				return alternatelist[table.find(SpeedMethod.List, SpeedMethod.Value)]
			end
			return "Teleport"
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 150,
		Function = function(val) end
	})
	SpeedJump = Speed.CreateToggle({
		Name = "AutoJump",
		Function = function(callback)
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = "Always Jump",
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = "Real Jump",
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

run(function()
    local AnticheatBypass = {Enabled = false}
    local ShowPart = {Enabled = false}
    local funnynumbers = {
        delay = 0.35,
        speed = 0.1
    }

	local OldRoot
	local NewRoot
    local dt = 0
    
	local function CreateClonedCharacter()
		lplr.Character.Parent = game
        lplr.Character.HumanoidRootPart.Archivable = true
		OldRoot = lplr.Character.HumanoidRootPart 
		NewRoot = OldRoot:Clone()
		NewRoot.Parent = lplr.Character
		OldRoot.Parent = workspace
		lplr.Character.PrimaryPart = NewRoot
		lplr.Character.Parent = workspace
		OldRoot.Transparency = ShowPart.Enabled and 0.35 or 1
		entityLibrary.character.HumanoidRootPart = NewRoot
	end

	local function RemoveClonedCharacter()
		OldRoot.Transparency = 1
		lplr.Character.Parent = game
		OldRoot.Parent = lplr.Character
		NewRoot.Parent = workspace
		lplr.Character.PrimaryPart = OldRoot
		lplr.Character.Parent = workspace
		entityLibrary.character.HumanoidRootPart = OldRoot
		NewRoot:Remove()
		NewRoot = {} 
		OldRoot = {}
		OldRoot.CFrame = NewRoot.CFrame
	end

    AnticheatBypass = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "AnticheatBypass",
        HoverText = "spoofs anticheat lol",
        Function = function(callback)
            if callback then
				task.spawn(function()
                    dt = 0
                    CreateClonedCharacter()
                    table.insert(AnticheatBypass.Connections, lplr.CharacterAdded:Connect(function()
                        task.wait(0.5)
                        CreateClonedCharacter()
                    end))
                    print("began")
                    BindToRenderStep("acb",1,function()
                        dt += 1
                        OldRoot.Transparency = ShowPart.Enabled and 0.35 or 1
                        local RealHRP = OldRoot
                        local FakeChar = NewRoot
                        RealHRP.Velocity = Vector3.zero
                        if isAlive(lplr) and dt >= (math.ceil(funnynumbers.delay * 10)) then
                            RealHRP.Velocity = Vector3.zero
                            local info = TweenInfo.new(funnynumbers.speed)
                            local cf = FakeChar.CFrame
                            local data = {
                                CFrame = cf
                            }
                            game:GetService("TweenService"):Create(RealHRP, info, data):Play()
                            dt = 0
                        end
                    end)
                end)
            else
                UnbindFromRenderStep("acb")
                print("removed")
                RemoveClonedCharacter()
            end
        end
    })
	ShowPart = AnticheatBypass.CreateToggle({
		Name = "Show Part",
		Function = function(callback)
			if OldRoot then
				OldRoot.Transparency = callback and 0.35 or 1
			end
		end
	})
end)