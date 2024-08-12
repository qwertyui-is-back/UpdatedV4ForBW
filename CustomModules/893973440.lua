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
local repstorage = game:GetService("ReplicatedStorage")
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

local function warningNotification(title, text, delay)
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

local store = {
    beast = nil,
    gamebeast = nil,
    map = "nil",
    computers = 0,
    status = "spawn",
    gamestatus = "GAME OVER",
    ingame = false,
    timer = 0,
    escaped = false,
    captured = false,
    progress = 0,
    cancrawl = true,
    caninteract = true
}

local run = runcode

task.spawn(function()
    local teams = game:GetService("Teams")
    if not teams:FindFirstChild("Survivors") then
        local Survivors = Instance.new("Team", teams)
        Survivors.Name = "Survivors"
        Survivors.TeamColor = BrickColor.new("Bright blue")
        Survivors.AutoAssignable = true
    end
    if not teams:FindFirstChild("Beast") then
        local Beast = Instance.new("Team", teams)
        Beast.Name = "Beast"
        Beast.TeamColor = BrickColor.new("Bright red")
        Beast.AutoAssignable = true
    end
    local survivor = teams.Survivors
    local beast = teams.Beast
    players.PlayerAdded:Connect(function(p)
        p.Team = survivor
    end)
    BindToStepped("Update",1,function()
        if not shared.VapeExecuted then
            UnbindFromStepped("Update")
        end
        local status = "spawn"
        if repstorage.GameTimer.Value == 0 or repstorage.GameStatus.Value:lower():find("game over") then
            status = "spawn"
        end
        if repstorage.GameStatus.Value:lower():find("computers") or repstorage.GameStatus.Value:lower() == "15 sec head start" or repstorage.IsGameActive.Value then
            status = "computers"
        end
        if repstorage.GameStatus.Value:lower():find("exit") then
            status = "exits"
        end
        store.gamebeast = lplr.TempPlayerStatsModule.IsBeast.Value
        store.map = repstorage.CurrentMap.Value
        store.computers = repstorage.ComputersLeft.Value
        store.status = status
        store.gamestatus = repstorage.GameStatus.Value
        store.ingame = repstorage.IsGameActive.Value
        store.timer = repstorage.GameTimer.Value
        store.escaped = lplr.TempPlayerStatsModule.Escaped.Value
        store.captured = lplr.TempPlayerStatsModule.Captured.Value
        store.progress = lplr.TempPlayerStatsModule.ActionProgress.Value * 100
        store.cancrawl = lplr.TempPlayerStatsModule.DisableCrawl.Value
        store.caninteract = lplr.TempPlayerStatsModule.DisableInteraction
        for i,v in players:GetPlayers() do
            if v.Character == nil then return end
            pcall(function()
                if store.timer > 0 then
                    if v.Character:FindFirstChild("BeastPowers") == nil then
                        v.Team = survivor
                    else
                        v.Team = beast
                        store.beast = v
                        if v.Name ~= lplr.Name then
                            if v.Character:FindFirstChild("WarningNotifDetector") == nil then
                                local p = Instance.new("Part", v.Character)
                                p.Name = "WarningNotifDetector"
                                warningNotification("Cat V5", v.Name.." is the beast!",10)
                            end
                        end
                    end
                else
                    v.Team = survivor
                    store.beast = nil
                end
            end)
        end
    end)
end)

run(function()
    local ZoomUnlocker = {Enabled = false}

    ZoomUnlocker = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
        Name = "ZoomUnlocker",
        Function = function(callback)
            if callback then
                BindToStepped("zu",1,function()
                    lplr.CameraMaxZoomDistance = 10
                end)
            else
                UnbindFromStepped("zu")
            end
        end
    })
end)

run(function()
    local AutoHack = {Enabled = false}

    AutoHack = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "AutoMinigame",
        HoverText = "Automatically completes the Hacking Minigame",
        Function = function(callback)
            if callback then
                BindToStepped("ah",1,function()
                    repstorage.RemoteEvent:FireServer("SetPlayerMinigameResult",true)
                end)
            else
                UnbindFromStepped("ah")
            end
        end,
        ExtraText = function() return "Remote" end
    })
end)

local AutoInteract = {Enabled = false}
run(function()

    AutoInteract = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "AutoInteract",
        HoverText = "Automatically interact with anything",
        Function = function(callback)
            if callback then
                BindToStepped("ai",1,function()
                    repstorage.RemoteEvent:FireServer("Input", "Action", true)
                end)
            else
                UnbindFromStepped("ai")
            end
        end
    })
end)

run(function()
    local NoSlowdown = {Enabled = false}

    NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "NoSlowdown",
        Function = function(callback)
            if callback then
                BindToStepped("nh",1,function()
                    pcall(function()
                        if lplr.Character.Humanoid.WalkSpeed < 16 then
                            lplr.Character.Humanoid.WalkSpeed = 16
                        end
                    end)
                end)
            else
                UnbindFromStepped("nh")
            end
        end,
        ExtraText = function() return "Spoof" end
    })
end)

run(function()
    local BeastNotifier = {Enabled = false}
    local Range = {Value = 25}
    local hasNotified = tick()
    notifiedUser = lplr.Name

    BeastNotifier = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "BeastNotifier",
        Function = function()
            if callback then
                BindToStepped("bn",1,function()
                    --pcall(function()
                        local mag = (store.beast.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                        if mag <= Range.Value then
                            if notifiedUser ~= store.beast.Name and store.status ~= "game over" then
                                warningNotification("Cat V5", "The beast is near you!", 10)
                                notifiedUser = store.beast.Name
                            end
                        else
                            notifiedUser = lplr.Name
                        end
                    --end)
                end)
            else
                UnbindFromStepped("bn")
            end
        end
    })
    Range = BeastNotifier.CreateSlider({
        Name = "Range",
        Min = 5,
        Max = 30,
        Default = "25",
        Function = function(val) end
    })
end)

run(function()
	local ChamsFolder = Instance.new("Folder")
	ChamsFolder.Name = "ChamsPCFolder"
	ChamsFolder.Parent = GuiLibrary.MainGui
	local chamstable = {}
	local ChamsColor = {Value = 0.44}
	local ChamsOutlineColor = {Value = 0.44}
	local ChamsTransparency = {Value = 1}
	local ChamsOutlineTransparency = {Value = 1}
	local ChamsOnTop = {Enabled = true}
	local ChamsTeammates = {Enabled = true}

	local function addfunc(ent)
		local hl = Instance.new("Highlight")
		hl.Parent = ent
		hl.FillColor = BrickColor.new("Bright green")
		hl.OutlineColor = Color3.fromRGB(255,255,255)
		h1.FullTransparency = 0.4
	end

	local function removefunc(ent)
		ent.Highlight:Destroy()
	end

	local Chams = {Enabled = false}
	Chams = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ComputerESP",
		Function = function(callback)
			if callback then
                BindToStepped("ce",1,function()
                    pcall(function()
                        for i,v in pairs(store.map:GetChildren()) do
                            if v.Name == "ComputerTable" then
                                if v:FindFirstChild("Highlight") == nil then
                                    addfunc(v)
                                end
                                v.Highlight.FillColor = v.Screen.Color
                            end
                        end
                    end)
                end)
			else
				UnbindFromStepped("ce")
			end
		end,
		HoverText = "Render computers through walls"
	})
end)

run(function()

	local function addfunc(ent)
		local hl = Instance.new("Highlight")
		hl.Parent = ent
		hl.FillColor = Color3.fromRGB(121,121,255)
		hl.OutlineColor = Color3.fromRGB(255,255,255)
		h1.FullTransparency = 0.4
	end

	local function removefunc(ent)
		ent.Highlight:Destroy()
	end

	local Chams = {Enabled = false}
	Chams = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "PodESP",
		Function = function(callback)
			if callback then
                BindToStepped("pe",1,function()
                    pcall(function()
                        for i,v in pairs(store.map:GetChildren()) do
                            if v.Name == "FreezePod" then
                                if v:FindFirstChild("Highlight") == nil then
                                    addfunc(v)
                                end
                            end
                        end
                    end)
                end)
			else
				UnbindFromStepped("pe")
			end
		end,
		HoverText = "Render Freeze pods through walls"
	})
end)

run(function()

	local function addfunc(ent)
		local hl = Instance.new("Highlight")
		hl.Parent = ent
		hl.FillColor = Color3.fromRGB(55, 222, 89)
		hl.OutlineColor = Color3.fromRGB(255,255,255)
		h1.FullTransparency = 0.4
	end

	local function removefunc(ent)
		ent.Highlight:Destroy()
	end

	local Chams = {Enabled = false}
	Chams = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ExitESP",
		Function = function(callback)
			if callback then
                BindToStepped("ee",1,function()
                    pcall(function()
                        for i,v in pairs(store.map:GetChildren()) do
                            if v.Name == "ExitDoor" then
                                if v:FindFirstChild("Highlight") == nil then
                                    addfunc(v)
                                end
                            end
                        end
                    end)
                end)
			else
				UnbindFromStepped("ee")
			end
		end,
		HoverText = "Render exits through walls"
	})
end)

run(function()
    local AutoWin = {Enabled = false}
    local SaveCaptured = {Enabled = false}
    local AutoRejoin = {Enabled = false}
    local AutoServerHop = {Enabled = false}
    local SpeedValue1 = {Value = 9}
    local SpeedValue2 = {Value = 11}
    local slot = "3"

    local function getComputer()
        for i,v in pairs(store.map:GetChildren()) do
            if v.Name == "ComputerTable" then
                if v.Screen.BrickColor ~= BrickColor.new("Dark green") then
                    local mag = (store.beast.Character.HumanoidRootPart.Position - v.ComputerTrigger3.Position).magnitude
                    if mag >= 30 then
                        local s = 3
                        for i2,v2 in pairs(players:GetChildren()) do
                            local mag2 = (v2.Character.HumanoidRootPart.Position - v["ComputerTrigger"..s].Position).magnitude
                            if mag2 < 1.15 and v2 ~= lplr then
                                s -= 1
                            end
                        end
                        if s > 0 then
                            local data = {
                                Object = v,
                                Index = i,
                                CFrame = v["ComputerTrigger"..s].CFrame,
                                Position = v["ComputerTrigger"..s].Position
                            }
                            return data
                        end
                    end
                end
            end
        end
        return nil
    end

    local function getExit()
        for i,v in pairs(store.map:GetChildren()) do
            if v.Name == "ExitDoor" then
                local mag = (store.beast.Character.HumanoidRootPart.Position - v.ExitDoorTrigger.Position).magnitude
                if mag >= 15 then
                    return v
                end
            end
        end
        return nil
    end

    local function getPod()
        for i,v in pairs(store.map:GetChildren()) do
            if v.Name == "FreezePod" then
                return v
            end
        end
        return nil
    end

    local function getEmptyPod()
        for i,v in pairs(store.map:GetChildren()) do
            if v.Name == "FreezePod" and v.CapturedTorso.Value == nil then
                return v
            end
        end
        return nil
    end

    local function isPlayerInPod(pod)
        local cap = pod.CapturedTorso
        if cap.Value ~= nil then
            return cap
        end
        return nil
    end

    local computer = nil
    local exit = nil
    local tweening = false
    local doInteract = false
    local function tweenCF(cf,time)
        if tweening and not store.status == "exits" then return end
        local comp = computer or {CFrame = 0, Position = 0}
        doInteract = false
        time = time or 0
        if cf == comp.CFrame then
            local mag = (comp.Position - lplr.Character.HumanoidRootPart.Position).magnitude
            if mag <= 7 then
                time = 0.5
            end
        end
        local tweenservice = game:GetService("TweenService")
        local info = TweenInfo.new(time,Enum.EasingStyle.Linear)
        local tween = tweenservice:Create(lplr.Character.HumanoidRootPart,info,{CFrame = cf})
        tween:Play()
        tweening = true
        tween.Completed:Connect(function()
            doInteract = true
            tweening = false
        end)
    end
    
    local jumpTick = 0

    AutoWin = GuiLibrary.ObjectsThatCanBeSaved.AFKWindow.Api.CreateOptionsButton({
        Name = "AutoWin",
        Function = function(callback)
            if callback then
                table.insert(AutoWin.Connections, game:GetService("GuiService").ErrorMessageChanged:Connect(function() -- credits to Infinite Yield
                    if not AutoRejoin.Enabled then return end
                    shared.Rejoin()
                end))
                BindToStepped("aw",1,function()
                    pcall(function()
                        if AutoInteract.Enabled then AutoInteract.ToggleButton(false) end
                        if not isAlive() then return end
                        if store.status == "spawn" then
                            lplr.Character.HumanoidRootPart.CFrame = CFrame.new(104,8,-417)
                            jumpTick = 0
                            computer = nil
                            exit = nil
                        end
                        lplr.Character.HumanoidRootPart.Velocity = Vector3.zero
                        local mag = (store.beast.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                        local plrs = players:GetPlayers()
                        if #plrs <= 2 and AutoServerHop.Enabled then
                            shared.ServerHop()
                        end
                        if store.gamebeast then
                            shared.Rejoin()
                        end
                        if store.beast ~= lplr then
                            if store.beast == lplr then mag = 5000 end
                            if mag <= 25 and not store.escaped then
                                if store.timer == 0 then return end
                                lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0,100,0)
                                jumpTick = 0
                            else
                                jumpTick = jumpTick + 1
                                if doInteract then
                                    repstorage.RemoteEvent:FireServer("Input", "Action", true)
                                else
                                    repstorage.RemoteEvent:FireServer("Input", "Action", false)
                                end
                                local pod = nil --getPod()
                                local cap = nil --isPlayerInPod(pod)
                                if cap ~= nil then
                                    lplr.Character.HumanoidRootPart.CFrame = cap.Value.CFrame
                                else
                                    if store.status == "computers" then
                                        local pos = lplr.Character.HumanoidRootPart.Position
                                        if computer == nil or computer.Object == nil or computer.Object.Screen.BrickColor == BrickColor.new("Dark green") or mag <= 30 then
                                            if mag <= 30 then
                                                warningNotification("Cat V5","The beast is near!",3)
                                            end
                                            if computer ~= nil then
                                                if computer.Object.Screen.BrickColor == BrickColor.new("Dark green") then
                                                    warningNotification("Cat V5","Computer successfully hacked!",3)
                                                end
                                            end
                                            warningNotification("Cat V5","Finding new computer..",1)
                                            computer = getComputer()
                                        end
                                        if not tweening then
                                            --local slot = "ComputerTrigger"..getAvailableSlot(computer)
                                            tweenCF(computer.CFrame, math.random(SpeedValue1.Value,SpeedValue2.Value), true)
                                            --warningNotification("Cat V5", "Teleporting to another computer..",5)
                                        end
                                        if jumpTick > 249 and jumpTick < 256 then
                                            lplr.Character.Humanoid.JumpPower = 40
                                            lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                        elseif jumpTick > 257 then
                                            jumpTick = 0
                                            lplr.Character.Humanoid.JumpPower = 36
                                        end
                                        -- lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0,computer.ComputerTrigger3.CFrame.Y,0)
                                    elseif store.status == "exits" then
                                        jumpTick = 0
                                        if store.timer == 0 then return end
                                        if store.escaped then return end
                                        if exit == nil or mag <= 15 then
                                            if mag <= 15 then
                                                warningNotification("Cat V5","The beast is near!",3)
                                            end
                                            exit = getExit()
                                        end
                                        local partTP = exit.ExitArea
                                        speed = 5
                                        if exit.Door.Hinge.Rotation.Y == 0 or exit.Door.Hinge.Rotation.Y == 90 or exit.Door.Hinge.Rotation.Y == 180 or exit.Door.Hinge.Rotation.Y == 270 then
                                            partTP = exit.ExitDoorTrigger
                                            speed = 0.65
                                        end
                                        if exit.Door.Hinge.Rotation.Y == -90 or exit.Door.Hinge.Rotation.Y == -180 or exit.Door.Hinge.Rotation.Y == -270 then
                                            partTP = exit.ExitDoorTrigger
                                            speed = 0.65
                                        end
                                        if mag >= 15 then
                                            if not tweening then
                                                tweenCF(partTP.CFrame, speed, false)
                                            end
                                        else
                                            exit = getExit()
                                        end
                                    end
                                end
                            end
                        else
                            if not AutoRejoin.Enabled then return end
                            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,lplr)
                        end
                    end)
                end)
            else
                UnbindFromStepped("aw")
            end
        end,
        HoverText = "Automatically win the game",
        ExtraText = function()
            return "Delay "..SpeedValue1.Value.."-"..SpeedValue2.Value
        end
    })
    AutoRejoin = AutoWin.CreateToggle({
        Name = "Auto Rejoin",
        Default = true,
        Function = function()
            AutoWin.ToggleButton(false)
            AutoWin.ToggleButton(false)
        end,
        HoverText = "Automatically rejoin if kicked"
    })
    AutoServerHop = AutoWin.CreateToggle({
        Name = "Auto ServerHop",
        Default = true,
        Function = function() end,
        HoverText = "Automatically server hop if you are the only player"
    })
    SpeedValue1 = AutoWin.CreateSlider({
        Name = "Speed 1",
        Min = 4,
        Max = 30,
        Default = 9,
        Function = function(val) end
    })
    SpeedValue2 = AutoWin.CreateSlider({
        Name = "Speed 2",
        Min = 4,
        Max = 30,
        Default = 11,
        Function = function(val) end
    })
end)

run(function()
	--[[GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		Function = function(callback)
			overlayenabled = callback
			Overlay.SetVisible(callback)
			if callback then
				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
						if #pinglist >= 10 then
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if store.matchState ~= matchstatechanged then
							if store.matchState == 1 then
								matchstatetick = tick() + 3
							end
							matchstatechanged = store.matchState
						end
						if not store.TPString then
							store.TPString = tick().."/"..store.statistics.kills.."/"..store.statistics.beds.."/"..(victorysaid and 1 or 0).."/"..(1).."/"..(0).."/"..(0).."/"..(0)
							origtpstring = store.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then
								local respawnflag = math.abs(lplr:GetAttribute("SpawnTime") - lplr:GetAttribute("LastTeleported")) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then
											store.statistics.lagbacks = store.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in pairs(entityLibrary.entityList) do
							if teleportconnections[v.Player.Name.."1"] then continue end
							teleportconnections[v.Player.Name.."1"] = v.Player:GetAttributeChangedSignal("LastTeleported"):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) > 3 and matchstatetick <= tick() then
									store.statistics.universalLagbacks = store.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name.."2"] = v.Player:GetAttributeChangedSignal("PlayerConnected"):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split("/")
						label.Text = "Session Info\nTime Played : "..os.date("!%X",math.floor(tick() - splitted[1])).."\nKills : "..(splitted[2] + store.statistics.kills).."\nBeds : "..(splitted[3] + store.statistics.beds).."\nWins : "..(splitted[4] + (victorysaid and 1 or 0)).."\nGames : "..splitted[5].."\nLagbacks : "..(splitted[6] + store.statistics.lagbacks).."\nUniversal Lagbacks : "..(splitted[7] + store.statistics.universalLagbacks).."\nReported : "..(splitted[8] + store.statistics.reported).."\nMap : "..mapname
						local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						store.TPString = splitted[1].."/"..(splitted[2] + store.statistics.kills).."/"..(splitted[3] + store.statistics.beds).."/"..(splitted[4] + (victorysaid and 1 or 0)).."/"..(splitted[5] + 1).."/"..(splitted[6] + store.statistics.lagbacks).."/"..(splitted[7] + store.statistics.universalLagbacks).."/"..(splitted[8] + store.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in pairs(overlayconnections) do
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end,
		Priority = 2
	})]]
end)