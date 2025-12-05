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

local rf = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local torso = char:WaitForChild("HumanoidRootPart")

local flinging = false
local power = 500
local speed = 50
local massEnabled = false
local originalMass = {}
local antifling = false
local noclipping = false
local flingAllRunning = false
local rainbowOutline = nil

local antiFallConnection

local function startAntiFall()
    if antiFallConnection then
        antiFallConnection:Disconnect()
    end
    
    antiFallConnection = humanoid.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

startAntiFall()

local tab1 = win:CreateTab("Fling", 4483362458)

local sec1 = tab1:CreateSection("Controls")

local function hideparts()
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
    
    if torso then
        torso.Transparency = 0.5
    end
end

local function showparts()
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
    
    if torso then
        torso.Transparency = 1
    end
end

local function setmass(enabled)
    if enabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if not originalMass[part] then
                    originalMass[part] = part:GetMass()
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
        originalMass = {}
    end
end

local bamV
local bamAV
local bamV2
local antiflingConnection
local noclipConnection
local rainbowConnection

local function createRainbowOutline()
    if rainbowOutline then
        rainbowOutline:Destroy()
    end
    
    rainbowOutline = Instance.new("SelectionBox")
    rainbowOutline.Name = "RainbowOutline"
    rainbowOutline.Adornee = torso
    rainbowOutline.LineThickness = 0.05
    rainbowOutline.Parent = torso
    
    local hue = 0
    rainbowConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flinging or not rainbowOutline then
            if rainbowConnection then
                rainbowConnection:Disconnect()
                rainbowConnection = nil
            end
            return
        end
        
        hue = (hue + 0.01) % 1
        rainbowOutline.Color3 = Color3.fromHSV(hue, 1, 1)
    end)
end

local function removeRainbowOutline()
    if rainbowOutline then
        rainbowOutline:Destroy()
        rainbowOutline = nil
    end
    
    if rainbowConnection then
        rainbowConnection:Disconnect()
        rainbowConnection = nil
    end
end

local function startnoclip()
    if noclipping then return end
    noclipping = true
    
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if not noclipping then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopnoclip()
    if not noclipping then return end
    noclipping = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
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

local function startfling()
    if flinging then return end
    flinging = true
    
    hideparts()
    startnoclip()
    createRainbowOutline()
    
    torso.CFrame = torso.CFrame
    
    bamV = Instance.new("BodyAngularVelocity")
    bamV.Name = "Spinning"
    bamV.Parent = torso
    bamV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bamV.P = 9e9
    
    bamAV = Instance.new("BodyAngularVelocity")
    bamAV.Name = "Spinningtoo"
    bamAV.Parent = torso
    bamAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bamAV.P = 9e9
    
    bamV2 = Instance.new("BodyAngularVelocity")
    bamV2.Name = "Spinning3"
    bamV2.Parent = torso
    bamV2.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bamV2.P = 9e9
    
    local t = 0
    game:GetService("RunService").Heartbeat:Connect(function()
        if not flinging then return end
        
        t = t + (speed * 5)
        
        bamV.AngularVelocity = Vector3.new(t, t, 0)
        bamAV.AngularVelocity = Vector3.new(0, t, t)
        bamV2.AngularVelocity = Vector3.new(t, 0, t)
    end)
end

local function stopfling()
    if not flinging then return end
    flinging = false
    
    if bamV then
        bamV:Destroy()
        bamV = nil
    end
    
    if bamAV then
        bamAV:Destroy()
        bamAV = nil
    end
    
    if bamV2 then
        bamV2:Destroy()
        bamV2 = nil
    end
    
    torso.RotVelocity = Vector3.new(0, 0, 0)
    
    stopnoclip()
    showparts()
    removeRainbowOutline()
end

local flingToggle = tab1:CreateToggle({
    Name = "Enable Fling",
    CurrentValue = false,
    Flag = "FlingToggle",
    Callback = function(val)
        if val then
            startfling()
        else
            stopfling()
        end
    end
})

humanoid.Died:Connect(function()
    task.wait(5)
    if plr.Character then
        char = plr.Character
        humanoid = char:WaitForChild("Humanoid")
        torso = char:WaitForChild("HumanoidRootPart")
        
        startAntiFall()
        
        if flingToggle.CurrentValue then
            task.wait(0.5)
            startfling()
        end
    end
end)

local powerSlider = tab1:CreateSlider({
    Name = "Fling Power",
    Range = {100, 2000},
    Increment = 50,
    CurrentValue = 500,
    Flag = "PowerSlider",
    Callback = function(val)
        power = val
    end
})

local speedSlider = tab1:CreateSlider({
    Name = "Rotation Speed",
    Range = {10, 200},
    Increment = 10,
    CurrentValue = 50,
    Flag = "SpeedSlider",
    Callback = function(val)
        speed = val
    end
})

local sec2 = tab1:CreateSection("Debug")

local massToggle = tab1:CreateToggle({
    Name = "Body Mass/Density",
    CurrentValue = false,
    Flag = "MassToggle",
    Callback = function(val)
        massEnabled = val
        setmass(val)
    end
})

tab1:CreateParagraph({
    Title = "Info",
    Content = "Body Mass makes your character extremely heavy so you can push and fling things easier. Anti-fall damage is always active!"
})

local antiflingToggle = tab1:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Flag = "AntiFlingToggle",
    Callback = function(val)
        antifling = val
        if val then
            if antiflingConnection then
                antiflingConnection:Disconnect()
            end
            antiflingConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if torso and humanoid.Health > 0 then
                    torso.Velocity = Vector3.new(0, 0, 0)
                    torso.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            if antiflingConnection then
                antiflingConnection:Disconnect()
                antiflingConnection = nil
            end
        end
    end
})

local tab3 = win:CreateTab("Rage", 4483362458)

local sec4 = tab3:CreateSection("Fling All")

tab3:CreateButton({
    Name = "Fling All Players",
    Callback = function()
        if flingAllRunning then
            rf:Notify({
                Title = "Already Running",
                Content = "Fling All is already active!",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        flingAllRunning = true
        local targets = {}
        
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(targets, p)
            end
        end
        
        if #targets == 0 then
            rf:Notify({
                Title = "No Players",
                Content = "No players found to fling!",
                Duration = 2,
                Image = 4483362458
            })
            flingAllRunning = false
            return
        end
        
        local originalPos = torso.CFrame
        local wasFlinging = flinging
        
        if not wasFlinging then
            startfling()
        end
        
        local flinged = {}
        
        spawn(function()
            for _, target in pairs(targets) do
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = target.Character.HumanoidRootPart
                    
                    torso.CFrame = targetRoot.CFrame
                    table.insert(flinged, target.Name)
                    
                    rf:Notify({
                        Title = "Flinging",
                        Content = "Flinging " .. target.Name,
                        Duration = 1,
                        Image = 4483362458
                    })
                    
                    task.wait(3)
                end
            end
            
            torso.CFrame = originalPos
            flingAllRunning = false
            
            if not wasFlinging then
                stopfling()
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
    Content = "Fling All teleports your spinning torso inside each player's body for 3 seconds. Each player is only targeted once. Perfect for clearing servers!"
})

local tab2 = win:CreateTab("Settings", 4483362458)

local sec3 = tab2:CreateSection("Options")

tab2:CreateButton({
    Name = "Reset Character",
    Callback = function()
        stopfling()
        setmass(false)
        humanoid.Health = 0
    end
})

tab2:CreateButton({
    Name = "Show Body Parts",
    Callback = function()
        showparts()
    end
})

tab2:CreateButton({
    Name = "Hide Body Parts",
    Callback = function()
        hideparts()
    end
})

tab2:CreateButton({
    Name = "Unload Script",
    Callback = function()
        stopfling()
        setmass(false)
        showparts()
        if antiflingConnection then
            antiflingConnection:Disconnect()
        end
        if antiFallConnection then
            antiFallConnection:Disconnect()
        end
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        if rainbowConnection then
            rainbowConnection:Disconnect()
        end
        
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name == "ChatGui" or obj.Name == "RainbowOutline" then
                obj:Destroy()
            end
        end
        
        game:GetService("CoreGui"):FindFirstChild("Rayfield"):Destroy()
        
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

plr.CharacterAdded:Connect(function(newchar)
    char = newchar
    humanoid = char:WaitForChild("Humanoid")
    torso = char:WaitForChild("HumanoidRootPart")
    flinging = false
    massEnabled = false
    originalMass = {}
    antifling = false
    noclipping = false
    
    startAntiFall()
    
    if bamV then bamV:Destroy() end
    if bamAV then bamAV:Destroy() end
    if bamV2 then bamV2:Destroy() end
    if antiflingConnection then antiflingConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    if rainbowConnection then rainbowConnection:Disconnect() end
end)
