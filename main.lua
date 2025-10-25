-- safe_place_check.lua  (harmless demo ONLY)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- <-- replace with your real raw.githubusercontent.com link -->
local rawUrl = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/game_ids.json"

local function fetchPlaceData()
    local ok, res = pcall(function() return HttpService:GetAsync(rawUrl, true) end)
    if not ok then
        warn("Failed to fetch game_ids.json:", res)
        return nil
    end
    local success, data = pcall(function() return HttpService:JSONDecode(res) end)
    if not success then
        warn("Invalid JSON:", data)
        return nil
    end
    return data
end

local function placeIsListed(list, id)
    for _, p in ipairs(list or {}) do
        -- handle numeric IDs stored as numbers or strings
        if tonumber(p.id) and tonumber(p.id) == id then
            return true, p.name or tostring(p.id)
        end
    end
    return false
end

-- MAIN: fetch and check
local data = fetchPlaceData()
if not data or not data.places then
    warn("No place list found.")
    return
end

local currentId = game.PlaceId
local matched, name = placeIsListed(data.places, currentId)

if matched then
    print("Safe demo: matched place:", name, currentId)
    -- harmless visual indicator
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "SafeDemoGui"
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(0, 350, 0, 40)
    label.Position = UDim2.new(0.5, -175, 0.05, 0)
    label.Text = "SAFE DEMO: matched place → "..tostring(name)
    label.BackgroundTransparency = 0.4
    label.TextScaled = true
else
    print("Place not listed. ID:", currentId)
end






getgenv().LPH_NO_VIRTUALIZE = function(f) return f end

if game.PlaceId == 84924278299650 or game.PlaceId == 105028250868995 or game.PlaceId == 94901423480147 then
    local getinfo = getinfo or debug.getinfo
    local DEBUG = false
    local Hooked = {}
    local Detected, Kill

    for _, v in pairs(getgc(true)) do
        if typeof(v) == "table" then
            local DetectFunc = rawget(v, "Detected")
            local KillFunc   = rawget(v, "Kill")
            
            if typeof(DetectFunc) == "function" and not Detected then
                Detected = DetectFunc
                local OldDetect
                OldDetect = hookfunction(Detected, function(Action, Info, NoCrash)
                    if Action ~= "_" then
                        if DEBUG then
                            warn(string.format("Adonis AntiCheat flagged\nMethod: %s\nInfo: %s", Action, Info))
                        end
                    end
                    return true
                end)
                table.insert(Hooked, Detected)
            end

            if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
                Kill = KillFunc
                local OldKill
                OldKill = hookfunction(Kill, function(Info)
                    if DEBUG then
                        warn(string.format("Adonis AntiCheat tried to kill (fallback): %s", Info))
                    end
                end)
                table.insert(Hooked, Kill)
            end
        end
    end
    local OldInfo
    OldInfo = hookfunction(getrenv().debug.info, newcclosure(function(...)
        local LevelOrFunc, Info = ...
        if Detected and LevelOrFunc == Detected then
            if DEBUG then
                warn("Adonis AntiCheat sanity check detected and broken")
            end
            return coroutine.yield(coroutine.running())
        end
        return OldInfo(...)
    end))
end

local player = game.Players.LocalPlayer
local playerModel = player.Character or player.CharacterAdded:Wait()
if game.PlaceId == 123 then
    local fullyLoadedChar = playerModel:WaitForChild("FULLY_LOADED_CHAR")
    if fullyLoadedChar then 
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local acFolder = replicatedStorage:WaitForChild("AC", 5)
        if not acFolder then
            warn("AC folder not found in ReplicatedStorage.")
            return
        end


        local function printReceivedData(name, data)
            if type(data) == "table" then
                for i, value in pairs(data) do
                end
            else
            end
        end

        local function logData(object, data)
            if object:IsA("RemoteEvent") then
                object.OnClientEvent:Connect(LPH_NO_VIRTUALIZE(function(...)
                    printReceivedData(object.Name, {...})
                end))
            elseif object:IsA("RemoteFunction") then
                object.OnClientInvoke = LPH_NO_VIRTUALIZE(function(...)
                    printReceivedData(object.Name, {...})
                    return true
                end)
            end
        end

        for _, object in ipairs(acFolder:GetChildren()) do
            logData(object, object)
        end

        acFolder.ChildAdded:Connect(function(child)
            logData(child, child)
        end)

        wait(5)
    end
end



local spreadToggleActive = true
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local triggerBotActive = false
local triggerHold = false
local boxAdornment = nil
local hitbox = nil
local targetPlayer = nil
local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local silentAimActive = false
local originalIndex = nil
local mouse = localPlayer:GetMouse()
local lastClosestPart = nil
local lastRootPartVelocity = Vector3.new(0, 0, 0)
local camLockActive = false
local camLockTarget = nil
local camLockPart = nil
local fovCircle = nil
local rightClickHeld = false
local clickPending = false


local indicatorsVisible = shared.Saved.Misc.Indicators.Enabled
local indicatorsGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
indicatorsGui.Name = "IndicatorsGui"
indicatorsGui.ResetOnSpawn = false

local indicatorLabel = Instance.new("TextLabel", indicatorsGui)
indicatorLabel.Name = "StatusLabel"
indicatorLabel.Position = UDim2.new(0.01, 0, 0.6, 0)  -- Adjusted to 0.6 to move it lower
indicatorLabel.Size = UDim2.new(0, 200, 0, 50)
indicatorLabel.BackgroundTransparency = 1
indicatorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
indicatorLabel.TextStrokeTransparency = 0.5
indicatorLabel.TextXAlignment = Enum.TextXAlignment.Left
indicatorLabel.TextYAlignment = Enum.TextYAlignment.Top
indicatorLabel.Font = Enum.Font.SourceSansBold
indicatorLabel.TextSize = 18
indicatorLabel.Visible = indicatorsVisible
indicatorLabel.Text = ""

local ShotgunNames = { ["Double-Barrel SG"]=true, ["TacticalShotgun"]=true, ["Shotgun"]=true, ["DrumShotgun"]=true }
local PistolNames  = { ["Revolver"]=true, ["Silencer"]=true, ["Glock"]=true }

local function readSilentAimFOV()
    local fovCfg = shared.Saved.Silent.FOV
    local root   = (fovCfg.FOV and fovCfg.FOV) or fovCfg
    if not root.Enabled then
        return Vector3.new(1e4, 1e4, 1e4)
    end
    local size = root.Size
    local wc   = root["Weapon Configuration"]
    if not wc or not wc.Enabled then
        return Vector3.new(size.X, size.Y, size.Z)
    end

    local tool    = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local rawName = tool and tool.Name or ""
    local name    = rawName:gsub("[%[%]]", "")

    local cfg = wc.Others
    if ShotgunNames[name] then
        cfg = wc.Shotguns
    elseif PistolNames[name] then
        cfg = wc.Pistols
    end

    return Vector3.new(cfg.X, cfg.Y, cfg.Z)
end


local function getCurrentWeaponFOV()
    return readSilentAimFOV()
end

local function getDetectionFOV()
    return readSilentAimFOV()
end


local function isVisible(origin, targetPart)
    if not targetPart or not targetPart:IsA("BasePart") then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {localPlayer.Character, targetPart.Parent}
    rayParams.IgnoreWater = true

    local result = Workspace:Raycast(origin, (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude, rayParams)
    return result == nil 
end

local function mouse1click(x, y)
    clickPending = true

    task.defer(function()
        if not clickPending then return end

        local char = localPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool.Name == "[Knife]" then
                return
            end
        end

        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)

        clickPending = false
    end)
end

    
    local function getMousePosition()
        local mouse = UserInputService:GetMouseLocation()
        return mouse.X, mouse.Y
    end

local PhysicsService = game:GetService("PhysicsService")

pcall(function()
    local exists = false
    for _, group in ipairs(PhysicsService:GetRegisteredCollisionGroups()) do
        if group.name == "NoTrigger" then
            exists = true
            break
        end
    end

    if not exists then
        PhysicsService:RegisterCollisionGroup("NoTrigger")
        PhysicsService:CollisionGroupSetCollidable("Default", "NoTrigger", false)
    end
end)



local ShotgunNames = { ["Double-Barrel SG"]=true, ["TacticalShotgun"]=true, ["Shotgun"]=true, ["DrumShotgun"]=true }
local PistolNames  = { ["Revolver"]=true, ["Silencer"]=true, ["Glock"]=true }

local function getTriggerbotFOV()
    local fovRoot = shared.Saved.Triggerbot.FOV
    if not fovRoot or not fovRoot.FOV then
        return Vector3.new(5, 5, 5)
    end

    local fovData = fovRoot.FOV
    local baseSize = fovData.Size or {X = 5, Y = 5, Z = 5}
    local config = fovData["Weapon Configuration"]

    if not config or not config.Enabled then
        return Vector3.new(baseSize.X, baseSize.Y, baseSize.Z)
    end

    local tool = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local name = tool and tool.Name:match("%[(.-)%]") or ""

    local ShotgunNames = { ["Double-Barrel SG"]=true, ["TacticalShotgun"]=true, ["Shotgun"]=true, ["DrumShotgun"]=true }
    local PistolNames  = { ["Revolver"]=true, ["Silencer"]=true, ["Glock"]=true }

    local selectedFOV
    if ShotgunNames[name] then
        selectedFOV = config.Shotguns
    elseif PistolNames[name] then
        selectedFOV = config.Pistols
    else
        selectedFOV = config.Others
    end

    return Vector3.new(
        selectedFOV.X or baseSize.X,
        selectedFOV.Y or baseSize.Y,
        selectedFOV.Z or baseSize.Z
    )
end

local function isMouseOverTarget()
    if not targetPlayer or not targetPlayer.Character then return false end

    local mouseTarget = mouse.Target
    if not mouseTarget then return false end

    return mouseTarget:IsDescendantOf(targetPlayer.Character)
end


local function getKeyEnum(keyName)
    return Enum.KeyCode[keyName]
end


local getAngleBetweenVectors = LPH_NO_VIRTUALIZE(function(v1, v2)
    local dot = v1:Dot(v2)
    local magnitudeProduct = v1.Magnitude * v2.Magnitude
    if magnitudeProduct == 0 then return 180 end
    local cosTheta = math.clamp(dot / magnitudeProduct, -1, 1)
    return math.deg(math.acos(cosTheta))
end)



local function isKnifeEquipped()
    local char = Players.LocalPlayer.Character
    if not char then return false end
    return char:FindFirstChild("[Knife]") ~= nil
end


local function getVisualFOV()
    return getCurrentWeaponFOV()
end

local function getMouseTargetIgnoringFakeParts()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {
        localPlayer.Character,
        workspace:FindFirstChild("ESP_Hitbox"),
        workspace:FindFirstChild("Triggerbot_Hitbox")
    }
    rayParams.IgnoreWater = true

    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
    return result and result.Instance or nil
end





local createHitbox = LPH_NO_VIRTUALIZE(function(character)
    if hitbox then hitbox:Destroy() end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    hitbox = Instance.new("Part")
    hitbox.Name = "ESP_Hitbox"
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Transparency = 1
    hitbox.Size = getCurrentWeaponFOV()
    local pred = shared.Saved.Silent.Prediction
local boxPrediction = Vector3.new(
    pred.X or 0, 
    pred.Y or 0, 
    pred.Z or 0
) * shared.Saved["Silent"].PredictionPower
    local predictedPosition = rootPart.Position + Vector3.new(
    rootPart.Velocity.X * boxPrediction.X,
    rootPart.Velocity.Y * boxPrediction.Y,
    rootPart.Velocity.Z * boxPrediction.Z
)
    hitbox.CFrame = CFrame.new(predictedPosition)
    hitbox.CollisionGroupId = 1
    hitbox.CanQuery = false
    hitbox.CanTouch = false
    hitbox.Parent = workspace
    hitbox.CollisionGroup = "NoTrigger"

end)


local function createVisualBox(character)
    if boxAdornment then boxAdornment:Destroy() end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    boxAdornment = Instance.new("BoxHandleAdornment")
    boxAdornment.Name = "PlayerBoxESP"
    boxAdornment.Adornee = rootPart
    boxAdornment.AlwaysOnTop = true
    boxAdornment.ZIndex = 10
    boxAdornment.Size = getCurrentWeaponFOV()
    boxAdornment.Color3 = Color3.fromRGB(255, 0, 0)
    boxAdornment.Transparency = shared.Saved.Silent.Showfov and 0.7 or 1
    boxAdornment.Parent = rootPart
   local pred = shared.Saved.Silent.Prediction
local boxPrediction = Vector3.new(
    pred.X or 0, 
    pred.Y or 0, 
    pred.Z or 0
) * shared.Saved["Silent"].PredictionPower

    local predictedOffset = Vector3.new(
    rootPart.Velocity.X * boxPrediction.X,
    rootPart.Velocity.Y * boxPrediction.Y,
    rootPart.Velocity.Z * boxPrediction.Z
)

    boxAdornment.CFrame = CFrame.new(predictedOffset.X, 0, predictedOffset.Z)
end

local function createFOVCircle()
    if fovCircle then fovCircle:Destroy() end
    if not shared.Saved.Camlock.ShowFov or not targetPlayer then return end
    fovCircle = Instance.new("BillboardGui")
    fovCircle.Name = "TargetFOVCircle"
    fovCircle.Adornee = targetPlayer.Character.HumanoidRootPart
    fovCircle.Size = UDim2.new(0, shared.Saved.Camlock.Radius*2, 0, shared.Saved.Camlock.Radius*2)
    fovCircle.AlwaysOnTop = true
    fovCircle.LightInfluence = 0
    fovCircle.Parent = targetPlayer.Character.HumanoidRootPart
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = fovCircle
    local circle = Instance.new("ImageLabel")
    circle.Name = "Circle"
    circle.Image = "rbxassetid://3570695787"
    circle.ImageColor3 = Color3.fromRGB(0, 255, 255)
    circle.BackgroundTransparency = 1
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.ImageTransparency = 0.5
    circle.Parent = frame
end

local isMouseInBoxFOV = LPH_NO_VIRTUALIZE(function()
    if not hitbox or not targetPlayer or not targetPlayer.Character then return false end
    local mouseX, mouseY = getMousePosition()
    local ray = camera:ViewportPointToRay(mouseX, mouseY)
    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction * 1000

    local localRayOrigin = hitbox.CFrame:PointToObjectSpace(rayOrigin)
    local localRayDirection = hitbox.CFrame:VectorToObjectSpace(rayDirection).Unit
    local size = hitbox.Size * 0.5
    local minBounds = -size
    local maxBounds = size

    local function checkAxis(origin, direction, minB, maxB)
        local t1 = (minB - origin) / direction
        local t2 = (maxB - origin) / direction
        return math.min(t1, t2), math.max(t1, t2)
    end

    local txMin, txMax = checkAxis(localRayOrigin.X, localRayDirection.X, minBounds.X, maxBounds.X)
    local tyMin, tyMax = checkAxis(localRayOrigin.Y, localRayDirection.Y, minBounds.Y, maxBounds.Y)
    local tzMin, tzMax = checkAxis(localRayOrigin.Z, localRayDirection.Z, minBounds.Z, maxBounds.Z)

    local tMin = math.max(math.max(txMin, tyMin), tzMin)
    local tMax = math.min(math.min(txMax, tyMax), tzMax)
    return tMax >= math.max(tMin, 0)
end)




local getClosestPoint = LPH_NO_VIRTUALIZE(function(character)
    if not character then return nil end

    local closestPart, closestPoint
    local shortestDistance = math.huge
    local mouseX, mouseY = getMousePosition()
    local mousePos = Vector2.new(mouseX, mouseY)

    local ray = camera:ViewportPointToRay(mouseX, mouseY)
    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction * 500

    local bodyPartsToCheck = {
        "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
        "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm",
        "LeftUpperArm", "RightUpperArm", "LeftFoot", "RightFoot",
        "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg"
    }

    for _, partName in ipairs(bodyPartsToCheck) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") and isVisible(rayOrigin, part) then
            local toPart = part.Position - rayOrigin
            local projection = rayDirection.Unit:Dot(toPart)
            local closestPointOnRay = rayOrigin + rayDirection.Unit * projection
            local localPoint = part.CFrame:PointToObjectSpace(closestPointOnRay)
            local halfSize = part.Size * 0.5
local scale = 1
if shared.Saved.ClosestPoint and shared.Saved.ClosestPoint.Mode == "Advanced" then
    local configured = shared.Saved.ClosestPoint.PointScale or 0
    scale = 1 - math.clamp(configured, 0, 1)
end

local clamped = Vector3.new(
    math.clamp(localPoint.X, -halfSize.X * scale, halfSize.X * scale),
    math.clamp(localPoint.Y, -halfSize.Y * scale, halfSize.Y * scale),
    math.clamp(localPoint.Z, -halfSize.Z * scale, halfSize.Z * scale)
)



            local surfacePoint = part.CFrame:PointToWorldSpace(clamped)
            local screenPoint, onScreen = camera:WorldToViewportPoint(surfacePoint)
            if onScreen and screenPoint.Z > 0 then
                local dist = (mousePos - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPart = part
                    closestPoint = surfacePoint
                end
            end
        end
    end

    if closestPart and closestPoint then
        return { Part = closestPart, Position = closestPoint }
    else
        local fallback = character:FindFirstChild("HumanoidRootPart")
        return fallback and { Part = fallback, Position = fallback.Position } or nil
    end
end)

local getClosestBodyPart = LPH_NO_VIRTUALIZE(function(character)
    if not character then return nil end
    local mouseX, mouseY = getMousePosition()
    local mousePos = Vector2.new(mouseX, mouseY)

    if shared.Saved.Silent.HitPart == "ClosestPoint" then
        local data = getClosestPoint(character)
        return data and data.Part or nil

    elseif shared.Saved.Silent.HitPart == "ClosestBodyPart" then
        local closestPart, closestDistance = nil, math.huge

        for _, partName in ipairs({
            "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
            "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm",
            "LeftUpperArm", "RightUpperArm", "LeftFoot", "RightFoot",
            "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg"
        }) do
            local part = character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestPart = part
                    end
                end
            end
        end

        return closestPart
    end


    local closestPart, closestDistance = nil, math.huge
    for _, partName in ipairs(shared.Saved.Camlock.Hitparts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local screenX, screenY, screenZ = camera:WorldToViewportPoint(part.Position)
            if screenZ > 0 then
                local part2D = Vector2.new(screenX, screenY)
                local dist = (mousePos - part2D).Magnitude
                if dist < closestDistance then
                    closestDistance = dist
                    closestPart = part
                end
            end
        end
    end

    return closestPart
end)



local getBestTarget = LPH_NO_VIRTUALIZE(function()
    local closestPlayer, closestDist = nil, math.huge
    local mouseX, mouseY = getMousePosition()
    local mousePos = Vector2.new(mouseX, mouseY)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local bodyEffects = player.Character:FindFirstChild("BodyEffects")
            local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
            if rootPart and (not ko or not ko.Value) then
                local screenPos = camera:WorldToViewportPoint(rootPart.Position)
                if screenPos.Z > 0 and isVisible(camera.CFrame.Position, rootPart) then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end)


local function toggleCamLock()
    if not shared.Saved.Camlock.Enabled then return end
    if shared.Saved.Camlock['Camlock Settings'].Sync and targetPlayer then
        camLockTarget = targetPlayer
        if camLockTarget and camLockTarget.Character then
    local bodyEffects = camLockTarget.Character:FindFirstChild("BodyEffects")
    local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
    if ko and ko.Value then return end
            camLockPart = getClosestBodyPart(camLockTarget.Character)
            if shared.Saved.Camlock.ShowFov then
                createFOVCircle()
            end
        end
    else
        camLockActive = not camLockActive
        if camLockActive then
            camLockTarget = getBestTarget()
            if camLockTarget and camLockTarget.Character then
                camLockPart = getClosestBodyPart(camLockTarget.Character)
                if shared.Saved.Camlock.ShowFov then
                    createFOVCircle()
                end
            end
        else
            camLockTarget = nil
            camLockPart = nil
            if fovCircle then
                fovCircle:Destroy()
                fovCircle = nil
            end
        end
    end
end

local function hookMouse()
    originalIndex = hookmetamethod(game, "__index", LPH_NO_VIRTUALIZE(function(t, k)
        if shared.Saved.Silent.Enabled and t == mouse and (k == "Hit" or k == "Target") and targetPlayer and targetPlayer.Character then
            local hitPart = getClosestBodyPart(targetPlayer.Character)
            if hitPart
                and isMouseInBoxFOV()
                and math.random(1, 100) <= shared.Saved.Silent.Hitchance
                and isVisible(camera.CFrame.Position, hitPart)
            then
                local antiCurve = shared.Saved["Anti Curve"]
                if antiCurve and antiCurve.Enabled and antiCurve.Mode == "3DAngles" then
                    local cameraDir = camera.CFrame.LookVector
                    local toTarget = (hitPart.Position - camera.CFrame.Position).Unit
                    local angle = getAngleBetweenVectors(cameraDir, toTarget)

                    if angle > (antiCurve.Angle) then
                        return originalIndex(t, k)
                    end
                end

                silentAimActive = true

                if k == "Hit" then
                    local data = getClosestPoint(targetPlayer.Character)
                    local pred = shared.Saved.Silent.Prediction
                    local velocityOffset = Vector3.new(
                        data.Part.Velocity.X * (pred.X or 0),
                        data.Part.Velocity.Y * (pred.Y or 0),
                        data.Part.Velocity.Z * (pred.Z or 0)
                    )
                    local predicted = data.Position + velocityOffset
                    return CFrame.new(predicted)

                elseif k == "Target" then
                    return hitPart
                end
            end
        end

        silentAimActive = false
        return originalIndex(t, k)
    end))
end

local function hookHumanoidWalkSpeed(humanoid)
    local config = shared.Saved["Speed Modifications"]
    if not config then return end

    local baseSpeed = config.Walking.BaseSpeed
    local increment = config.Walking.Increment

    local function setWalkSpeed(speed)
        humanoid.WalkSpeed = speed
    end

    if config.Enabled then
        setWalkSpeed(baseSpeed)
    else
        setWalkSpeed(16)  -- Reset to normal Roblox walk speed
    end

    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not config.Enabled then return end
        setWalkSpeed(baseSpeed)
    end)
end

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        hookHumanoidWalkSpeed(humanoid)
    else
    end
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)
if localPlayer.Character then
    onCharacterAdded(localPlayer.Character)
end


UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightClickHeld = true
    end

    local bindKeys = {
        shared.Saved["Binds"].Toggle,
        shared.Saved["Binds"]["Camlock Toggle"],
        shared.Saved["Binds"].Triggerbot,
        shared.Saved["Binds"].Visuals,
        shared.Saved["Binds"]["SpeedModToggle"],
        shared.Saved["Binds"]["SpeedIncrease"],
        shared.Saved["Binds"]["SpeedDecrease"]
    }

    for _, key in ipairs(bindKeys) do
        if not key then
        end
    end

    if input.KeyCode == getKeyEnum(shared.Saved["Binds"].Toggle) and shared.Saved.Silent.Mode == "Target" then
        if targetPlayer then
            if hitbox then hitbox:Destroy() end
            if boxAdornment then boxAdornment:Destroy() end
            if fovCircle then fovCircle:Destroy() end
            targetPlayer = nil
            lastClosestPart = nil
            if shared.Saved.Camlock['Camlock Settings'].Sync then
                camLockActive = false
                camLockTarget = nil
                camLockPart = nil
            end
        else
            targetPlayer = getBestTarget()
            if targetPlayer and targetPlayer.Character then
                createHitbox(targetPlayer.Character)
                createVisualBox(targetPlayer.Character)
                if shared.Saved.Camlock['Camlock Settings'].Sync then
                    camLockTarget = targetPlayer
                    camLockPart = getClosestBodyPart(camLockTarget.Character)
                    if shared.Saved.Camlock.ShowFov then
                        createFOVCircle()
                    end
                end
            end
        end

    elseif input.KeyCode == getKeyEnum(shared.Saved["Binds"]["Camlock Toggle"]) then
        toggleCamLock()

    elseif input.KeyCode == getKeyEnum(shared.Saved["Binds"].Triggerbot) then
        if shared.Saved.Triggerbot["User Settings"].Mode == "Toggle" then
            triggerBotActive = not triggerBotActive
        elseif shared.Saved.Triggerbot["User Settings"].Mode == "Hold" then
            triggerHold = true
        end

    elseif input.KeyCode == getKeyEnum(shared.Saved["Binds"].Visuals) then
        if shared.Saved.Misc.Indicators.Enabled then
            indicatorsVisible = not indicatorsVisible
            indicatorLabel.Visible = indicatorsVisible
        end

    elseif input.KeyCode == getKeyEnum(shared.Saved["Binds"]["SpeedModToggle"]) then
        shared.Saved["Speed Modifications"].Enabled = not shared.Saved["Speed Modifications"].Enabled
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            hookHumanoidWalkSpeed(humanoid)
        else
        end

    elseif input.KeyCode == getKeyEnum(shared.Saved["Binds"]["SpeedIncrease"]) then
        shared.Saved["Speed Modifications"].Walking.BaseSpeed = shared.Saved["Speed Modifications"].Walking.BaseSpeed + shared.Saved["Speed Modifications"].Walking.Increment
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            hookHumanoidWalkSpeed(humanoid)
        else
        end

    elseif input.KeyCode == getKeyEnum(shared.Saved["Binds"]["SpeedDecrease"]) then
        shared.Saved["Speed Modifications"].Walking.BaseSpeed = shared.Saved["Speed Modifications"].Walking.BaseSpeed - shared.Saved["Speed Modifications"].Walking.Increment
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            hookHumanoidWalkSpeed(humanoid)
        else
        end

    else
    end
end))



UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightClickHeld = false
    end
if input.KeyCode == getKeyEnum(shared.Saved["Binds"].Triggerbot) then
    if shared.Saved.Triggerbot["User Settings"].Mode == "Hold" then
        triggerHold = false
    end
end


end)




local triggerbox = nil

local function getTriggerbotFOV()
    local fovRoot = shared.Saved.Triggerbot.FOV
    if not fovRoot or not fovRoot.FOV then
        return Vector3.new(5, 5, 5)
    end

    local fovData = fovRoot.FOV
    local baseSize = fovData.Size or {X = 5, Y = 5, Z = 5}
    local config = fovData["Weapon Configuration"]

    if not config or not config.Enabled then
        return Vector3.new(baseSize.X, baseSize.Y, baseSize.Z)
    end

    local tool = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local name = tool and tool.Name:match("%[(.-)%]") or ""

    local ShotgunNames = { ["Double-Barrel SG"]=true, ["TacticalShotgun"]=true, ["Shotgun"]=true, ["DrumShotgun"]=true }
    local PistolNames  = { ["Revolver"]=true, ["Silencer"]=true, ["Glock"]=true }

    local selectedFOV
    if ShotgunNames[name] then
        selectedFOV = config.Shotguns
    elseif PistolNames[name] then
        selectedFOV = config.Pistols
    else
        selectedFOV = config.Others
    end

    return Vector3.new(
        selectedFOV.X or baseSize.X,
        selectedFOV.Y or baseSize.Y,
        selectedFOV.Z or baseSize.Z
    )
end


local updateTriggerbotFOVBox = LPH_NO_VIRTUALIZE(function(character)
    if triggerbox then triggerbox:Destroy() end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    triggerbox = Instance.new("Part")
    triggerbox.Name = "Triggerbot_Hitbox"
    triggerbox.Anchored = true
    triggerbox.CanCollide = false
    triggerbox.Transparency = 1
    triggerbox.Size = getTriggerbotFOV()
    local pred = shared.Saved.Triggerbot.Prediction
    local px = pred.X or 0
    local py = pred.Y or 0
    local pz = pred.Z or 0
    local vel = rootPart.Velocity
    local offset = Vector3.new(vel.X * px, vel.Y * py, vel.Z * pz)
    local predictedPos = rootPart.Position + offset

    triggerbox.CFrame = CFrame.new(predictedPos)
    triggerbox.CollisionGroupId = 1
    triggerbox.CanQuery = false
    triggerbox.CanTouch = false
    triggerbox.Parent = workspace

    if shared.Saved.Triggerbot.ShowFov then
        local viz = Instance.new("BoxHandleAdornment")
        viz.Name = "TriggerbotFOV_Visual"
        viz.Adornee = triggerbox
        viz.AlwaysOnTop = true
        viz.ZIndex = 10
        viz.Size = triggerbox.Size
        viz.Color3 = Color3.fromRGB(255, 255, 0)
        viz.Transparency = 0.5
        viz.Parent = triggerbox
    end
end)

RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
if shared.Saved.Silent.Enabled and shared.Saved.Silent.Mode == "Auto" then
    local autoTarget = getBestTarget()
    if autoTarget ~= targetPlayer then
        targetPlayer = autoTarget

        if hitbox then hitbox:Destroy() end
        if boxAdornment then boxAdornment:Destroy() end
        if fovCircle then fovCircle:Destroy() end

        if targetPlayer and targetPlayer.Character then
            createHitbox(targetPlayer.Character)
            createVisualBox(targetPlayer.Character)

            if shared.Saved.Camlock['Camlock Settings'].Sync then
                camLockTarget = targetPlayer
                camLockPart = getClosestBodyPart(camLockTarget.Character)
                if shared.Saved.Camlock.ShowFov then
                    createFOVCircle()
                end
            end
        end
    end
end

if indicatorsVisible then
    local triggerStatus = (shared.Saved.Triggerbot.Enabled and ((shared.Saved.Triggerbot["User Settings"].Mode == "Toggle" and triggerBotActive) or (shared.Saved.Triggerbot["User Settings"].Mode == "Hold" and triggerHold))) and "On" or "Off"

    local triggerText = ""
    if triggerStatus == "On" then
        triggerText = "T"
    end

    -- Set the text and ensure rich text is enabled
    indicatorLabel.Text = triggerText
    indicatorLabel.TextSize = 64 -- Set a base text size
end



    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local bodyEffects = targetPlayer.Character:FindFirstChild("BodyEffects")
        local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")

        if ko and ko.Value then
            if hitbox then hitbox:Destroy() end
            if boxAdornment then boxAdornment:Destroy() end
            if fovCircle then fovCircle:Destroy() end
            if triggerbox then triggerbox:Destroy() end
            targetPlayer = nil
            lastClosestPart = nil
            if shared.Saved.Camlock['Camlock Settings'].Sync then
                camLockActive = false
                camLockTarget = nil
                camLockPart = nil
            end
            return
        end


        

        if shared.Saved.Triggerbot.Enabled then
    updateTriggerbotFOVBox(targetPlayer.Character)

    if isKnifeEquipped() then
        return
    end

    local isHolding = shared.Saved.Triggerbot["User Settings"].Mode == "Hold" and triggerHold
    local isToggled = shared.Saved.Triggerbot["User Settings"].Mode == "Toggle" and triggerBotActive
    local triggerAllowed = isHolding or isToggled

    if triggerAllowed then
        local camlockReady = shared.Saved.Camlock.Enabled and camLockTarget == targetPlayer
        local triggerActive = false
        local shouldFire = false

        if shared.Saved.Triggerbot['User Settings'].Type == "FOV" then
            if triggerbox then
                local mouseX, mouseY = getMousePosition()
                local ray = camera:ViewportPointToRay(mouseX, mouseY)
                local localOrigin = triggerbox.CFrame:PointToObjectSpace(ray.Origin)
                local localDirection = triggerbox.CFrame:VectorToObjectSpace(ray.Direction).Unit
                local size = triggerbox.Size * 0.5

                local function checkAxis(origin, direction, minB, maxB)
                    local t1 = (minB - origin) / direction
                    local t2 = (maxB - origin) / direction
                    return math.min(t1, t2), math.max(t1, t2)
                end

                local txMin, txMax = checkAxis(localOrigin.X, localDirection.X, -size.X, size.X)
                local tyMin, tyMax = checkAxis(localOrigin.Y, localDirection.Y, -size.Y, size.Y)
                local tzMin, tzMax = checkAxis(localOrigin.Z, localDirection.Z, -size.Z, size.Z)

                local tMin = math.max(math.max(txMin, tyMin), tzMin)
                local tMax = math.min(math.min(txMax, tyMax), tzMax)
                triggerActive = tMax >= math.max(tMin, 0)
            end

            shouldFire = (camlockReady or triggerActive) and triggerActive

        elseif shared.Saved.Triggerbot['User Settings'].Type == "Hitbox" then
            local target = getMouseTargetIgnoringFakeParts()
            if target and targetPlayer and targetPlayer.Character and target:IsDescendantOf(targetPlayer.Character) then
                local excludedParts = {
                    ESP_Hitbox = true,
                    Triggerbot_Hitbox = true,
                    PlayerBoxESP = true,
                    TargetFOVCircle = true
                }

                if not excludedParts[target.Name] and target:IsA("BasePart") then
                    shouldFire = true
                end
            end
        end

        local currentTime = tick()
        _G.lastTriggerTime = _G.lastTriggerTime or 0
        local delayToggle = shared.Saved.Triggerbot["Delay Settings"]["Delay Toggle"]
        local useDelay = delayToggle == nil or delayToggle
        local delayBetweenShots = shared.Saved.Triggerbot["Delay Settings"].Delay or 0

        if shouldFire then
    local char = localPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool.Name == "[Knife]" then
            return
        end
    end

    if useDelay then
        if (currentTime - _G.lastTriggerTime) >= delayBetweenShots then
            _G.lastTriggerTime = currentTime
            local mouseX, mouseY = getMousePosition()
            mouse1click(mouseX, mouseY)
        end
    else
        local mouseX, mouseY = getMousePosition()
        mouse1click(mouseX, mouseY)
    end
end

    end
end



        local rootPart = targetPlayer.Character.HumanoidRootPart
        if hitbox then
            local currentFOV = getCurrentWeaponFOV()
            hitbox.Size = currentFOV
            local pred = shared.Saved.Silent.Prediction
local boxPrediction = Vector3.new(
    pred.X or 0, 
    pred.Y or 0, 
    pred.Z or 0
) * shared.Saved["Silent"].PredictionPower

            local predictedPosition = rootPart.Position + Vector3.new(
    rootPart.Velocity.X * boxPrediction.X,
    rootPart.Velocity.Y * boxPrediction.Y,
    rootPart.Velocity.Z * boxPrediction.Z
)
            hitbox.CFrame = CFrame.new(predictedPosition)
        end

        if boxAdornment then
            boxAdornment.Size = getCurrentWeaponFOV()
           local pred = shared.Saved.Silent.Prediction
local boxPrediction = Vector3.new(
    pred.X or 0, 
    pred.Y or 0, 
    pred.Z or 0
) * shared.Saved["Silent"].PredictionPower

            local predictedOffset = Vector3.new(
    rootPart.Velocity.X * boxPrediction.X,
    rootPart.Velocity.Y * boxPrediction.Y,
    rootPart.Velocity.Z * boxPrediction.Z
)

            boxAdornment.CFrame = CFrame.new(predictedOffset.X, 0, predictedOffset.Z)
            boxAdornment.Transparency = shared.Saved.Silent.Showfov and 0.7 or 1
            boxAdornment.Color3 = isMouseInBoxFOV() and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end

        if isMouseInBoxFOV() then
            lastClosestPart = getClosestBodyPart(targetPlayer.Character)
        else
            lastClosestPart = nil
        end

    else
        if hitbox then hitbox:Destroy() end
        if boxAdornment then boxAdornment:Destroy() end
        if fovCircle then fovCircle:Destroy() end
        if triggerbox then triggerbox:Destroy() end
        targetPlayer = nil
        lastClosestPart = nil
        if shared.Saved.Camlock['Camlock Settings'].Sync then
            camLockActive = false
            camLockTarget = nil
            camLockPart = nil
        end
    end

    if shared.Saved.Camlock.Enabled and camLockTarget and camLockTarget.Character then
    local root = camLockTarget.Character:FindFirstChild("HumanoidRootPart")
    if root and isVisible(camera.CFrame.Position, root) then
        if shared.Saved.Camlock.ShowFov and not fovCircle then
            createFOVCircle()
        end

        local zoomDistance = (camera.CFrame.Position - camera.Focus.Position).Magnitude
        local isFirstPerson = zoomDistance < 1
        local isThirdPerson = zoomDistance >= 1
        local firstPersonOk = shared.Saved.Camlock["Camlock Settings"].FirstPerson and isFirstPerson
        local thirdPersonOk = shared.Saved.Camlock['Camlock Settings'].ThirdPerson and isThirdPerson
        local rightClickOk = not shared.Saved.Camlock["Camlock Settings"].RightClick or rightClickHeld

        local camlockAllowed = (firstPersonOk or thirdPersonOk) and rightClickOk
        local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
        if camlockAllowed and onScreen then
            local mouseX, mouseY = getMousePosition()
            local mousePos = Vector2.new(mouseX, mouseY)
            local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)

        
            local radius = shared.Saved.Camlock.Radius
            local mouseInFOV = (mousePos - targetScreenPos).Magnitude <= radius

            if mouseInFOV then
                camLockPart = getClosestBodyPart(camLockTarget.Character)
                if camLockPart then
                    local pred = shared.Saved.Camlock.Prediction
local vel = camLockPart.Velocity
local predicted = camLockPart.Position + Vector3.new(
    vel.X * pred.X,
    vel.Y * pred.Y,
    vel.Z * pred.Z
)

                    local direction = (predicted - camera.CFrame.Position).Unit
                    local look = camera.CFrame.LookVector
                    local smooth = math.clamp(shared.Saved.Camlock.Smoothness * 0.1, 0.01, 0.5)
                    local newLook = look:Lerp(direction, smooth)
                    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + newLook)
                end
            end
        end
    end
end


end))



local player = game.Players.LocalPlayer
local patchedThisSession = {}

local function cleanToolName(name)
    return name:gsub("%[", ""):gsub("%]", ""):gsub("^%s*(.-)%s*$", "%1")
end

local function getSpreadMultiplier(toolName)
    local settings = shared.Saved and shared.Saved["Spread Modifiers"]
    if not settings or not settings.Enabled or not spreadToggleActive then
        return nil
    end

    local cleanedName = cleanToolName(toolName)

    for name, data in pairs(settings) do
        if name ~= "Enabled" and name ~= "Spread Toggle" and cleanedName == name then
            return data.Multiplier
        end
    end

    return nil
end


local function patchSpreadConstants(gunScript, multiplier)
    LPH_NO_VIRTUALIZE(function()
        local patchedCount = 0
        for _, func in ipairs(getgc(true)) do
            if typeof(func) == "function" and islclosure(func) then
                local env = getfenv(func)
                if env and env.script == gunScript then
                    local success, constants = pcall(getconstants, func)
                    if success then
                        for i, v in ipairs(constants) do
                            if typeof(v) == "number" and (v == 0.05 or v == 0.1) then
                                setconstant(func, i, v * multiplier)
                                patchedCount += 1
                            end
                        end
                    end
                end
            end
        end

        if patchedCount > 0 then
        end
    end)()
end

local function tryPatchGun(tool)
    if patchedThisSession[tool] then return end

    local multiplier = getSpreadMultiplier(tool.Name)
    if not multiplier then return end

    local gunScript = tool:FindFirstChild("GunClientShotgun")
    if gunScript then
        patchSpreadConstants(gunScript, multiplier)
        patchedThisSession[tool] = true
    end
end

local function monitorCharacter()
    repeat task.wait() until player.Character
    local char = player.Character

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            tryPatchGun(tool)
        end
    end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            tryPatchGun(child)
        end
    end)
end

player.CharacterAdded:Connect(function()
    table.clear(patchedThisSession)
    monitorCharacter()
end)

monitorCharacter()

local function watchToolSwitchForKnife()
    local char = localPlayer.Character
    if not char then return end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "[Knife]" then
            clickPending = false
        end
    end)

    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child.Name == "[Knife]" then
            clickPending = false
        end
    end)
end

if localPlayer.Character then
    watchToolSwitchForKnife()
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    watchToolSwitchForKnife()
end)


game:GetService('RunService').RenderStepped:Connect(function()
    local config = shared.Saved.Hitbox
    if not config or not config.Enabled then return end

    local localPlayer = game:GetService('Players').LocalPlayer
    if not localPlayer or not localPlayer.Character then return end

    local character = localPlayer.Character
    local currentWeapon = character:FindFirstChildOfClass("Tool")
    if not currentWeapon then return end

    local gunConfig = config.Guns[currentWeapon.Name]
    if not gunConfig then return end

    for _, player in ipairs(game:GetService('Players'):GetPlayers()) do
        if player ~= localPlayer then
            local targetChar = player.Character
            local hrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if hrp then
                if player == targetPlayer then
                    local height = gunConfig.H or 1
                    local width = gunConfig.W or 1

                    hrp.Size = Vector3.new(width * 2, height * 2, width * 2)
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.CanCollide = false
                end
            end
        end
    end
end)


local DeepFakePosition = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nosssa/NossLock/main/GetRealMousePosition"))() 
task.wait()


local China = setmetatable({}, {
    __index = LPH_NO_VIRTUALIZE(function(Company, Price)
        return game:GetService(Price)
    end)
})
   
local ChinaWorld = China.Workspace
local Society = China.Players
local ChineseDeporation = China.ReplicatedStorage
local ChinaInputService = China.UserInputService


local ChingChong = Society.LocalPlayer
local Cat =  "meow!!" and ChingChong:GetMouse()

local ChineseEvent = ChineseDeporation:FindFirstChild("MainEvent") or nil
local Payment = "Hello Da Hoodian!" and nil

local RandomChinese = function(RandomCredit)
   return type(RandomCredit) == "number" and math.random(-RandomCredit, RandomCredit) or 0
end

local ChinaAlive = function(ChinesePlayer)
   return ChinesePlayer and ChinesePlayer.Character and ChinesePlayer.Character:FindFirstChild("Humanoid") and ChinesePlayer.Character:FindFirstChild("Head") or false
end

local GameArgs = {
    [2788229376] = "UpdateMousePosI2",  -- Da Hood
    [122235233087414] = "UpdateMousePosI",  -- Hood Z
    [75159825516372] = "MousePos",  -- Track Aim Trainer
    [133331500532271] = "UpdateMousePosI2",  
    [987654321] = "CustomUpdateKeyA",    
    [555555555] = "AnotherMouseUpdate",  
    [123456789] = "UpdateMousePosI2",  
    [654654] = "CustomUpdateKeyA",    
    [545321] = "AnotherMouseUpdate",  

}

local DEFAULT_ARG = "UpdateMousePosI2"

local ChinaHook
ChinaHook = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
    local ChinaArgs       = {...}
    local DeportationMethod = getnamecallmethod()

    -- pick the right expected first-arg for *this* PlaceId
    local targetArg = GameArgs[game.PlaceId] or DEFAULT_ARG

    if not checkcaller()
    and DeportationMethod == "FireServer"
    and self.Name == "MainEvent"
    and ChinaArgs[1] == targetArg then

        ChinaArgs[2] = _G.FetchPosition()
        return self.FireServer(self, unpack(ChinaArgs))
    end

    return ChinaHook(self, ...)
end))

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer





hookMouse()  
