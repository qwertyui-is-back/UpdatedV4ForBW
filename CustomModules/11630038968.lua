-- Credits to Inf Yield & all the other scripts that helped me make bypasses
local GuiLibrary = shared.GuiLibrary

local function warningNotification(title, text, delay)
	pcall(function()
		local frame = GuiLibrary["CreateNotification"](title, text, delay, "assets/WarningNotification.png")
		frame.Frame.BackgroundColor3 = Color3.fromRGB(236, 129, 44)
		frame.Frame.Frame.BackgroundColor3 = Color3.fromRGB(236, 129, 44)
	end)
end

local missingfunc = false
local missrequire = false
local misshookmeta = false
local misshookfunc = false

local function checkForMissingFunctions()
    if not require then
        if not missingfunc then warningNotification("Cat "..catver, "Missing function detected, some features may not work properly.", 10) end
        missingfunc = true
        missrequire = true
    end
    if not hookmetamethod then
        if not missingfunc then warningNotification("Cat "..catver, "Missing function detected, some features may not work properly.", 10) end
        missingfunc = true
        misshookmeta = true
    end
    if not hookfunction then
        if not missingfunc then warningNotification("Cat "..catver, "Missing function detected, some features may not work properly.", 10) end
        missingfunc = true
        misshookfunc = true
    end
end

require = require or function() end
hookmetamethod = hookmetamethod or function() end
hookfunction = hookfunction or function() end

task.spawn(checkForMissingFunctions)

local catver = "V5"
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
local entityLibrary = shared.vapeentity

local networkownerswitch = tick()
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

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function EntityNearPosition(distance, checktab)
	checktab = checktab or {}
	if isAlive() then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do -- loop through playersService
			if not v.Targetable then continue end
            if isVulnerable(v) then -- checks
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if checktab.Prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then -- mag check
					table.insert(sortedentities, {entity = v, Magnitude = v.Target and -1 or mag})
                end
            end
        end
		table.sort(sortedentities, function(a, b) return a.Magnitude < b.Magnitude end)
		for i, v in pairs(sortedentities) do
			if checktab.WallCheck then
				if not raycastWallCheck(v.entity, checktab) then continue end
			end
			return v.entity
		end
	end
end

local knit = game:GetService("ReplicatedStorage").Packages.Knit
local services = knit:WaitForChild('Services')
local ToolService = services:WaitForChild('ToolService')
local CombatService = services:WaitForChild("CombatService")

local store = {
    AttackRemote = ToolService:WaitForChild("RF").AttackPlayerWithSword,
    BlockRemote = ToolService:WaitForChild("RF").ToggleBlockSword,
    isBlocking = function()
        return lplr:GetAttribute("Blocking")
    end,
    isEating = function()
        return lplr:GetAttribute("Eating")
    end,
    isSlow = function()
        return lplr.Character.Humanoid.WalkSpeed <= 15 and true or false
    end,
    viewmodel = nil,
    sword = nil,
    health = 100,
    ping = 0
}
run(function()
    store.update = function()
        task.spawn(function()
            for i,v in cam.Viewmodel:GetChildren() do
                if i == 10 and store.viewmodel ~= v then
                    store.viewmodel = v
                end		
            end
            local sword = "WoodenSword"
            if lplr.Character:FindFirstChild("WoodenSword") then
                sword = "WoodenSword"
            elseif lplr.Character:FindFirstChild("Sword") then
                sword = "Sword"
            end
            if store.sword ~= sword then
                store.sword = sword
            end
            local health = lplr.Character.Humanoid.Health
            if store.health ~= health then
                store.health = health
            end
            local ping = math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
            if store.ping ~= ping then
                store.ping = ping
            end
        end)
    end
    store.getViewmodel = function()
        return store.viewmodel
    end
    store.getSword = function()
        return store.sword
    end
end)
run(function()
    BindToRenderStep("Update", 1, function()
        store.update()
    end)
end)
GuiLibrary.RemoveObject("SpeedOptionsButton")
GuiLibrary.RemoveObject("KillauraOptionsButton")
GuiLibrary.RemoveObject("FlyOptionsButton")
GuiLibrary.RemoveObject("ReachOptionsButton")
GuiLibrary.RemoveObject("ClientKickDisablerOptionsButton")
GuiLibrary.RemoveObject("SilentAimOptionsButton")
GuiLibrary.RemoveObject("TargetStrafeOptionsButton")
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



run(function()
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
    local boostedSpeed = 9
    local boostDelay = 0

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
				local pulsetick = tick()
				task.spawn(function()
					repeat
						pulsetick = tick() + (SpeedPulseDuration.Value / 100)
						task.wait((SpeedDelay.Value / 10) + (SpeedPulseDuration.Value / 100))
					until (not Speed.Enabled)
				end)
				BindToRenderStep("Speed", 1, function(delta)
					if entityLibrary.isAlive and (typeof(entityLibrary.character.HumanoidRootPart) ~= "Instance" or isnetworkowner(entityLibrary.character.HumanoidRootPart)) then
                        boostDelay += 1
						local movevec = (SpeedMoveMethod.Value == "Manual" and calculateMoveVector(Vector3.new(a + d, 0, w + s)) or entityLibrary.character.Humanoid.MoveDirection).Unit
						movevec = movevec == movevec and Vector3.new(movevec.X, 0, movevec.Z) or Vector3.zero
						SpeedRaycast.FilterDescendantsInstances = {lplr.Character, cam}
                        if boostDelay >= 1 and boostDelay <= 3 then
                            boostedSpeed = 11
                            entityLibrary.character.Humanoid.WalkSpeed = 17
                        elseif boostDelay >= 3 and boostDelay <= 5 then
                            boostedSpeed = 8
                            entityLibrary.character.Humanoid.WalkSpeed = 16
                        elseif boostDelay >= 5 and boostDelay <= 9 then
                            boostedSpeed = 6
                        elseif boostDelay >= 9 and <= 12 then
                            boostedSpeed = 0
                            entityLibrary.character.Humanoid.WalkSpeed = 13
                        elseif boostDelay >= 12 then
                            entityLibrary.character.Humanoid.WalkSpeed = SpeedValue.Value
                        end
                        if SpeedAnimation.Enabled then
                            for i,v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
                                if v.Name == "WalkAnim" or v.Name == "RunAnim" then
                                    v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
                                end
                            end
                        end
                        local newvelo = movevec * (SpeedValue.Value + boostedSpeed)
                        entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, newvelo.Z)
						if SpeedJump.Enabled and (SpeedJumpAlways.Enabled or killauranear) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
                                boostedSpeed = 13.5
                                boostDelay = 0
                                entityLibrary.character.Humanoid.WalkSpeed = 18
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
				SpeedDelayTick = 0
                entityLibrary.character.Humanoid.WalkSpeed = 16.83
				UnbindFromRenderStep("Speed")
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
		List = {"Velocity", "Boost"},
		Function = function(val)
			if oldWalkSpeed then
				entityLibrary.character.Humanoid.WalkSpeed = oldWalkSpeed
				oldWalkSpeed = nil
			end
			SpeedDelay.Object.Visible = val == "TP" or val == "Pulse"
			SpeedWallCheck.Object.Visible = val == "CFrame" or val == "TP"
			SpeedPulseDuration.Object.Visible = val == "Pulse"
			SpeedAnimation.Object.Visible = val == "Velocity"
		end
	})
	SpeedMoveMethod = Speed.CreateDropdown({
		Name = "Movement",
		List = {"Manual", "MoveDirection"},
        Default = "MoveDirection",
		Function = function(val) end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 36,
        Default = 27,
		Function = function(val) end
	})
	SpeedDelay = Speed.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function(val)
			SpeedDelayTick = tick() + (val / 10)
		end,
		Default = 7,
		Double = 10
	})
	SpeedPulseDuration = Speed.CreateSlider({
		Name = "Pulse Duration",
		Min = 1,
		Max = 100,
		Function = function() end,
		Default = 50,
		Double = 100
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
	SpeedWallCheck = Speed.CreateToggle({
		Name = "Wall Check",
		Function = function() end,
		Default = true
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

run(function()
	local targetstrafe = {Enabled = false}
	local targetstraferange = {Value = 0}
	local oldmove
	local controlmodule
	targetstrafe = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "TargetStrafe",
		Function = function(callback)
			if callback then
				if not controlmodule then
					local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
					if not suc then controlmodule = {} end
				end
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam, ...)
					if isAlive() then
						local plr = EntityNearPosition(targetstraferange.Value, {
							WallCheck = false,
							AimPart = "RootPart"
						})
						if plr then
							facecam = true
							--code stolen from roblox since the way I tried to make it apparently sucks
							local c, s
							local plrCFrame = CFrame.lookAt(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(plr.RootPart.Position.X, 0, plr.RootPart.Position.Z))
							local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = plrCFrame:GetComponents()
							if R12 < 1 and R12 > -1 then
								c = R00
								s = -R01*math.sign(R12)
							else
								c = R22
								s = R02
							end
							local norm = 1--math.sqrt(c*c + s*s)
							local cameraRelativeMoveVector = controlmodule:GetMoveVector()
                            local divvalue = 3
							vec = Vector3.new(
								(c*(cameraRelativeMoveVector.X/divvalue) + s*(cameraRelativeMoveVector.Z/divvalue))/norm,
								0,
								(c*(cameraRelativeMoveVector.Z/divvalue) - s*(cameraRelativeMoveVector.X/divvalue))/norm
							)
						end
					end
					return oldmove(Self, vec, facecam, ...)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end
	})
	targetstraferange = targetstrafe.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 0,
		Max = 100,
		Default = 14
	})
end)

run(function()
    local NoSlowdown = {Enabled = false}
    local NoSlowMethod = {Value = "Spoof"}

    NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "NoSlowdown",
        Function = function(callback)
            if callback then
                BindToRenderStep("NoSlow",1,function()
                    if NoSlowMethod.Value == "Spoof" then
                        if store.isBlocking() or store.isEating() or store.isSlow() then
                            lplr.Character.Humanoid.WalkSpeed = 16.83
                        end
                    end
                end)
            else
                UnbindFromRenderStep("NoSlow")
            end
        end,
        ExtraText = function()
            return NoSlowMethod.Value
        end
    })
end)

run(function()
    local Velocity = {Enabled = false}
    local VelocityMode = {Value = "Replace"}

    local oldparent
    local velo
    Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
        Name = "Velocity",
        Function = function(callback)
            if callback then
                CombatService:WaitForChild("RE").KnockBackApplied:Destroy()
            else
                warningNotification("Cat "..catver, "Fixed next game", 5)
            end
        end,
        ExtraText = function()
            return VelocityMode.Value
        end
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

run(function()
    local SecurityFeatures = {Enabled = false}

    local old
    local oldwarn
    SecurityFeatures = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "SecurityFeatures",
        Function = function(callback)
            if callback then
                oldgame = hookmetamethod(game, '__namecall', function(self, ...) -- credits to SystemXVoid
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
                oldwarn = hookfunction(warn, function(message, ...)
                    if not checkcaller() then 
                        return 
                    end;
                    return oldwarn(message, ...)
                end) -- credits to SystemXVoid
            else
                oldgame = nil
                oldwarn = nil
            end
        end,
        HoverText = "Helps prevent detections",
        ExtraText = function()
            return "Hook"
        end
    })
end)
runcode(function()
	local transformed = false
	local OldBedwars = {["Enabled"] = false}
	local themeselected = {["Value"] = "OldBedwars"}

	local themefunctions = {
		Winter = function()
			task.spawn(function()
				for i,v in pairs(lighting:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.StarCount = 5000
				sky.SkyboxUp = "rbxassetid://8139676647"
				sky.SkyboxLf = "rbxassetid://8139676988"
				sky.SkyboxFt = "rbxassetid://8139677111"
				sky.SkyboxBk = "rbxassetid://8139677359"
				sky.SkyboxDn = "rbxassetid://8139677253"
				sky.SkyboxRt = "rbxassetid://8139676842"
				sky.SunTextureId = "rbxassetid://6196665106"
				sky.SunAngularSize = 11
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 30
				sky.Parent = lighting
				local sunray = Instance.new("SunRaysEffect")
				sunray.Intensity = 0.03
				sunray.Parent = lighting
				local bloom = Instance.new("BloomEffect")
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lighting
				local atmosphere = Instance.new("Atmosphere")
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lighting
			end)
			task.spawn(function()
				local snowpart = Instance.new("Part")
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = "SnowParticle"
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new("ParticleEmitter")
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = "rbxassetid://8158344433"
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new("ParticleEmitter")
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = "rbxassetid://8158344433"
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				for i = 1, 30 do
					for i2 = 1, 30 do
						local clone = snowpart:Clone()
						clone.Position = Vector3.new(240 * (i - 1), 400, 240 * (i2 - 1))
						clone.Parent = workspace
					end
				end
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in pairs(lighting:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				lighting.TimeOfDay = "00:00:00"
				pcall(function() workspace.Clouds:Destroy() end)
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lighting
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in pairs(lighting:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lighting
				pcall(function() workspace.Clouds:Destroy() end)
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lighting
			end)
		end
	}

	OldBedwars = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton({
		["Name"] = "GameTheme",
		["Function"] = function(callback)
			if callback then
                themefunctions[themeselected["Value"]]()
			end
		end,
		["ExtraText"] = function()
			return themeselected["Value"]
		end
	})
	themeselected = OldBedwars.CreateDropdown({
		["Name"] = "Theme",
		["Function"] = function() end,
		["List"] = {"Winter", "Halloween", "Valentines"}
	})
end)