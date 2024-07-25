-- Credits to Inf Yield & all the other scripts that helped me make bypasses
local oldgame; oldgame = hookmetamethod(game, '__namecall', function(self, ...) -- credits to SystemXVoid
    if checkcaller() then 
        return oldgame(self, ...)
    end;
    if getnamecallmethod():lower() == 'kick' then 
        return
    end;
    if typeof(self) == 'Instance' and self.ClassName:lower():find('remote') and (tostring(self):lower():find('tps') or tostring(self):lower():find('cps') or tostring(self):lower():find('head')) then 
        return
    end;
    return oldgame(self, ...)
end);
local oldwarn; oldwarn = hookfunction(warn, function(message, ...)
    if not checkcaller() then 
        return 
    end;
    return oldwarn(message, ...)
end) -- credits to SystemXVoid
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
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end

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
GuiLibrary.RemoveObject("KillauraOptionsButton")
GuiLibrary.RemoveObject("FlyOptionsButton")
GuiLibrary.RemoveObject("ReachOptionsButton")
GuiLibrary.RemoveObject("ClientKickDisablerOptionsButton")
GuiLibrary.RemoveObject("SilentAimOptionsButton")
GuiLibrary.RemoveObject("SpeedOptionsButton")
GuiLibrary.RemoveObject("AutoLeaveOptionsButton")
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
    local sword = "WoodenSword"
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
    Block = function(bool, item)
        bool = bool or true
        item = item or "WoodenSword"
        store.BlockRemote:InvokeServer(bool, item)
    end
}

local killauranear = false
run(function()
    local Killaura = {Enabled = false}
    local blockanim = {Value = "Test"}
    local Autoblock = {Enabled = false}
    local Criticals = {Enabled = false}
    local range = {Value = 20}
    local blocking = false
    local killauraplaying = false
    local oldNearPlayer = false
    local firstPlayerNear = false
    local function block()
        local shouldBlock = true
        functions.Block(shouldBlock, getSword())
        blocking = shouldBlock
    end
    local function unblock()
        local shouldBlock = false
        functions.Block(shouldBlock, getSword())
        blocking = shouldBlock
    end
	local anims = {
		Test = {
			{CFrame = CFrame.new(0,0,3) * CFrame.Angles(math.rad(115), math.rad(150), math.rad(350)), Time = 0.25},
			{CFrame = CFrame.new(0,0,3) * CFrame.Angles(math.rad(60), math.rad(100), math.rad(360)), Time = 0.25}
		},
        Smooth = {
            {CFrame = CFrame.new(0,-0.25,2.5) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(160)), Time = 0.15},
            {CFrame = CFrame.new(0, 0.65, 2.5) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(110)), Time = 0.1}
        },
        Leaked = {
            {CFrame = CFrame.new(0.4, 0.4, 2) * CFrame.Angles(math.rad(80), math.rad(60), math.rad(-20)), Time = 0},
            {CFrame = CFrame.new(0.4, 0.4, 2) * CFrame.Angles(math.rad(10), math.rad(90), math.rad(45)), Time = 0.156},
            {CFrame = CFrame.new(0.4, 0.4, 2) * CFrame.Angles(math.rad(80), math.rad(60), math.rad(-20)), Time = 0.075}
        }
    }
    Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "Killaura",
        Function = function(callback)
            if callback then
				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
                        if killauranear then
                            pcall(function()
                                if originalArmC0 == nil then
                                    originalArmC0 = cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0
                                end
                                if killauraplaying == false then
                                    killauraplaying = true
                                    for i,v in pairs(anims[blockanim.Value]) do
                                        if (not Killaura.Enabled) or (not killauranear) then break end
                                        if not oldNearPlayer then
                                            cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0 = originalArmC0 * v.CFrame
                                            continue
                                        end
                                        killauracurrentanim = game:GetService("TweenService"):Create(cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
                                        killauracurrentanim:Play()
                                        task.wait(v.Time - 0.01)
                                    end
                                    killauraplaying = false
                                end
                            end)
                        end
                        oldNearPlayer = killauranear
					until Killaura.Enabled == false
				end)
                table.insert(Killaura.Connections, lplr.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    task.spawn(function()
                        local oldNearPlayer
                        repeat
                            task.wait()
                            if killauranear then
                                pcall(function()
                                    if originalArmC0 == nil then
                                        originalArmC0 = cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0
                                    end
                                    if killauraplaying == false then
                                        killauraplaying = true
                                        for i,v in pairs(anims[blockanim.Value]) do
                                            if (not Killaura.Enabled) or (not killauranear) then break end
                                            if not oldNearPlayer then
                                                cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0 = originalArmC0 * v.CFrame
                                                continue
                                            end
                                            killauracurrentanim = game:GetService("TweenService"):Create(cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
                                            killauracurrentanim:Play()
                                            task.wait(v.Time - 0.01)
                                        end
                                        killauraplaying = false
                                    end
                                end)
                            end
                            oldNearPlayer = killauranear
                        until Killaura.Enabled == false
                    end)
                end))
                BindToRenderStep("aura",1,function()
                    killauranear = false
                    firstPlayerNear = false
                    pcall(function()
                        if isAlive() then
                            --print("alive")
                            local plr = GetAllTargets(range.Value)
                            local targettable = {}
                            local targetsize = 0
                            for i,v in next, plr do
                                targetsize += 1
                                if not firstPlayerNear then
                                    firstPlayerNear = true
                                end
                                killauranear = true
                                --print("there are players")
                                killauranear = true
                                functions.Attack(v.Player, entityLibrary.character.Humanoid.FloorMaterial == Enum.Material.Air and true or Criticals.Enabled and true or false, getSword())
                                if Autoblock.Enabled then
                                    block()
                                end
                                --print("attacked")
                            end
                            if targetsize == 0 and blocking and Autoblock.Enabled then
                                unblock()
                            end
                        end
                    end)
                    if not firstPlayerNear then
                        targetedPlayer = nil
                        killauranear = false
                        pcall(function()
                            if originalArmC0 == nil then
                                originalArmC0 = cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0
                            end
                            if cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0 ~= originalArmC0 then
                                pcall(function()
                                    killauracurrentanim:Cancel()
                                end)
                                killauracurrentanim = game:GetService("TweenService"):Create(cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart, TweenInfo.new(0.3), {C0 = originalArmC0})
                                killauracurrentanim:Play()
                            end
                        end)
                    end
                end)
            else
                UnbindFromRenderStep("aura")
                if originalArmC0 == nil then
                    originalArmC0 = cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0
                end
                if cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart.C0 ~= originalArmC0 then
                    pcall(function()
                        killauracurrentanim:Cancel()
                    end)
                    killauracurrentanim = game:GetService("TweenService"):Create(cam:WaitForChild("Viewmodel"):WaitForChild(getSword()).Handle.MainPart, TweenInfo.new(0.1), {C0 = originalArmC0})
                    killauracurrentanim:Play()
                end
                oldNearPlayer = false
                firstPlayerNear = false
                killauranear = false
            end
        end
    })
	local animmeth = {}
	for i,v in pairs(anims) do table.insert(animmeth, i) end
	blockanim = Killaura.CreateDropdown({
		Name = "Animation",
		List = animmeth,
		Function = function(val) end
	})
	range = Killaura.CreateSlider({
		["Name"] = "Attack range",
		["Min"] = 1,
		["Max"] = 25,
        ["Default"] = 25, 
		["Function"] = function(val) end
	})
    Criticals = Killaura.CreateToggle({
        Name = "Criticals",
        Default = true,
        Function = function() end
    })
    Autoblock = Killaura.CreateToggle({
        Name = "Autoblock",
        Default = true,
        Function = function() end
    })
end)

run(function()
	local Speed = {Enabled = false}
	local SpeedValue = {Value = 1}
	local SpeedMethod = {Value = "AntiCheat A"}
	local SpeedMoveMethod = {Value = "MoveDirection"}
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

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B", "AntiCheat C", "AntiCheat D"}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				BindToStepped("Speed", 1, function(delta)
					if isAlive() and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
						local movevec = (entityLibrary.character.Humanoid.MoveDirection).Unit
						movevec = movevec == movevec and Vector3.new(movevec.X, 0, movevec.Z) or Vector3.zero
						SpeedRaycast.FilterDescendantsInstances = {lplr.Character, cam}
                        if SpeedMethod.Value == "CFrame" then
							for i,v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(SpeedValue.Value / 15)
								end
							end
							local newpos = (movevec * (math.max(SpeedValue.Value - entityLibrary.character.Humanoid.WalkSpeed, 0) * delta))
                            local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, newpos, SpeedRaycast)
                            if ray then newpos = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + newpos
						end
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
			return SpeedMethod.Value
		end
	})
	SpeedMethod = Speed.CreateDropdown({
		Name = "Mode",
		List = {"CFrame", "Hypixel"},
		Function = function(val)
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 34,
        Default = 27,
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
    local SwordEditor = {Enabled = false}
    local X = {Value = 0}
    local Y = {Value = 0}
    local Z = {Value = 0}
    local item

    SwordEditor = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
        Name = "ViewmodelEditor",
        Function = function(callback)
            if callback then
                BindToStepped("ve",1,function()
                    pcall(function()
                        local viewmodel = cam:WaitForChild("Viewmodel")
                        for i,v in pairs(viewmodel:GetChildren()) do
                            if v.MainPart ~= nil then
                                item = v
                                v.MainPart.Mesh.Offset = Vector3.new(X.Value / 100, Y.Value / 100, Z.Value / 100)
                            end
                        end
                    end)
                end)
            else
                UnbindFromStepped("ve")
                item.MainPart.Mesh.Offset = Vector3.zero
            end
        end
    })
	X = SwordEditor.CreateSlider({
		["Name"] = "X Pos",
		["Min"] = 0,
		["Max"] = 30,
        ["Default"] = 0, 
		["Function"] = function(val) end
	})
	Y = SwordEditor.CreateSlider({
		["Name"] = "Y Pos",
		["Min"] = 0,
		["Max"] = 30,
        ["Default"] = 0, 
		["Function"] = function(val) end
	})
	Z = SwordEditor.CreateSlider({
		["Name"] = "Z Pos",
		["Min"] = 0,
		["Max"] = 30,
        ["Default"] = 0, 
		["Function"] = function(val) end
	})
end)

run(function()
    local Fly = {Enabled = false}
    local VerticalSpeed = {Value = 75}
    local YCFrame = 0
    local FlyUp = false
    local FlyDown = false

    Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "Fly",
        Function = function(callback)
            if callback then
				table.insert(Fly.Connections, uis.InputBegan:Connect(function(input1)
					if uis:GetFocusedTextBox() ~= nil then return end
                    if input1.KeyCode == Enum.KeyCode.Space then
                        FlyUp = true
                    elseif input1.KeyCode == Enum.KeyCode.LeftShift then
                        FlyDown = true
                    end
				end))
				table.insert(Fly.Connections, uis.InputEnded:Connect(function(input1)
                    if input1.KeyCode == Enum.KeyCode.Space then
						FlyUp = false
					elseif input1.KeyCode == Enum.KeyCode.LeftShift then
						FlyDown = false
					end
				end))
				if uis.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
                YCFrame = entityLibrary.character.HumanoidRootPart.CFrame.Y
                BindToStepped("fly",1,function()
                    if FlyUp then
                        YCFrame += VerticalSpeed.Value
                    elseif FlyDown then
                        YCFrame -= VerticalSpeed.Value
                    end
                    local cframe = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
                    cframe[2] = YCFrame
                    entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(cframe))
                    local velo = entityLibrary.character.HumanoidRootPart.Velocity
                    entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(velo.X, 0, velo.Z)
                end)
            else
				FlyUp = false
				FlyDown = false
                UnbindFromStepped("fly")
            end
        end
    })
	VerticalSpeed = Fly.CreateSlider({
		["Name"] = "Vertical speed",
		["Min"] = 1,
		["Max"] = 100,
        ["Default"] = 75, 
		["Function"] = function(val) end
	})
end)

--[[run(function()
    local AnticheatBypass = {Enabled = false}
    local ShowPart = {Enabled = false}
    local funnynumbers = {
        delay = 0.35,
        speed = 0.1
    }

    local DelayValue = {Value = funnynumbers.delay * 10}
    local SpeedVal = {Value = funnynumbers.speed}
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
        Name = "SpeedDisabler",
        HoverText = "Allows you to use 35+ speed",
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
                        if isAlive(lplr) and dt >= (math.ceil(DelayValue.Value * 10)) then
                            RealHRP.Velocity = Vector3.zero
                            local info = TweenInfo.new(SpeedVal.Value)
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
    DelayValue = AnticheatBypass.CreateSlider({
        Name = "Delay",
        Min = 1,
        Max = 100,
        Default = 35,
        Function = function(val)
            DelayValue.Value = val / 10
        end
    })
    SpeedVal = AnticheatBypass.CreateSlider({
        Name = "Send Speed",
        Min = 0,
        Max = 50,
        Default = 10,
        Function = function(val)
            SpeedVal.Value = val / 100
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
end)]]-- not the best tbh, especially with the fps issue bridge duels has