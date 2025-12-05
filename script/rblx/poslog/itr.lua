--[[ this script is nt finished yet so that means it likely wont work,
finished script will be keyless

 ___      _________    ________           ___       __       _________    ________ 
|\  \    |\___   ___\ |\   __  \         |\  \     |\  \    |\___   ___\ |\  _____\
\ \  \   \|___ \  \_| \ \  \|\  \        \ \  \    \ \  \   \|___ \  \_| \ \  \__/ 
 \ \  \       \ \  \   \ \   _  _\        \ \  \  __\ \  \       \ \  \   \ \   __\
  \ \  \       \ \  \   \ \  \\  \|  ___   \ \  \|\__\_\  \       \ \  \   \ \  \_|
   \ \__\       \ \__\   \ \__\\ _\ |\__\   \ \____________\       \ \__\   \ \__\ 
    \|__|        \|__|    \|__|\|__|\|__|    \|____________|        \|__|    \|__| 












]]--
local rf = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local win = rf:CreateWindow({
    Name = "Torso Fling",
    LoadingTitle = "Fling Script",
    LoadingSubtitle = "by Script",
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

local bv
local bg

local function startfling()
    if flinging then return end
    flinging = true
    
    hideparts()
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, 0, 0)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = torso
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e9
    bg.D = 500
    bg.Parent = torso
    
    local t = 0
    game:GetService("RunService").Heartbeat:Connect(function()
        if not flinging then return end
        
        t = t + speed / 100
        
        local rx = math.sin(t * 3) * math.pi * 2
        local ry = math.cos(t * 2) * math.pi * 2
        local rz = math.sin(t * 4) * math.pi * 2
        
        bg.CFrame = CFrame.Angles(rx, ry, rz)
        
        torso.Velocity = Vector3.new(
            math.sin(t) * power,
            math.cos(t * 2) * power,
            math.cos(t) * power
        )
    end)
end

local function stopfling()
    if not flinging then return end
    flinging = false
    
    if bv then
        bv:Destroy()
        bv = nil
    end
    
    if bg then
        bg:Destroy()
        bg = nil
    end
    
    torso.Velocity = Vector3.new(0, 0, 0)
    torso.RotVelocity = Vector3.new(0, 0, 0)
    
    showparts()
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
    Content = "Body Mass makes your character extremely heavy so you can push and fling things easier. Enable it for better fling results!"
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

tab2:CreateParagraph({
    Title = "About",
    Content = "Torso rotate fling script. Your torso spins rapidly in all directions while your body parts are invisible. Use Body Mass for extra power!"
})

rf:Notify({
    Title = "Torso Fling Loaded",
    Content = "Toggle fling to start spinning!",
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
    
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end)
