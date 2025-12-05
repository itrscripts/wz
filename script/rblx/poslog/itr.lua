local rf = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local win = rf:CreateWindow({
    Name = "Possessor Chat Logger",
    LoadingTitle = "Chat Logger",
    LoadingSubtitle = "by Script",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local logs = {}
local max = 100

local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer

local tab1 = win:CreateTab("Chat Logger", 4483362458)

local sec1 = tab1:CreateSection("Chat Monitor")

local info = tab1:CreateParagraph({
    Title = "How to Use",
    Content = "All chat messages will be logged below. Click on any message button to copy it to your clipboard. Useful for finding codes people type in different languages!"
})

local status = tab1:CreateLabel("Status: Active - Monitoring chat...")

local logsec = tab1:CreateSection("Recent Messages")

local function addlog(pname, msg, full)
    if string.find(msg, "#") then
        return
    end
    
    table.insert(logs, 1, {
        player = pname,
        message = msg,
        full = full,
        time = os.date("%H:%M:%S")
    })
    
    if #logs > max then
        table.remove(logs, #logs)
    end
    
    local txt = string.sub(full, 1, 50)
    if #full > 50 then
        txt = txt .. "..."
    end
    
    tab1:CreateButton({
        Name = txt,
        Callback = function()
            setclipboard(msg)
            rf:Notify({
                Title = "Copied!",
                Content = "Message copied from " .. pname,
                Duration = 2,
                Image = 4483362458
            })
        end
    })
end

for i, v in pairs(plrs:GetChildren()) do
    if v:IsA("Player") then
        v.Chatted:Connect(function(msg)
            local ft = string.format("[%s] %s: %s", 
                os.date("%H:%M:%S"), 
                v.Name, 
                msg
            )
            addlog(v.Name, msg, ft)
        end)
    end
end

plrs.ChildAdded:Connect(function(plr)
    if plr:IsA("Player") then
        plr.Chatted:Connect(function(msg)
            local ft = string.format("[%s] %s: %s", 
                os.date("%H:%M:%S"), 
                plr.Name, 
                msg
            )
            addlog(plr.Name, msg, ft)
        end)
    end
end)

local tab2 = win:CreateTab("Settings", 4483362458)

local sec2 = tab2:CreateSection("Options")

tab2:CreateButton({
    Name = "Clear All Logs",
    Callback = function()
        logs = {}
        rf:Notify({
            Title = "Cleared",
            Content = "All chat logs have been cleared.",
            Duration = 2,
            Image = 4483362458
        })
    end
})

tab2:CreateButton({
    Name = "Copy All Logs",
    Callback = function()
        local all = ""
        for i, l in ipairs(logs) do
            all = all .. l.full .. "\n"
        end
        
        if all ~= "" then
            setclipboard(all)
            rf:Notify({
                Title = "Exported",
                Content = "All logs copied to clipboard!",
                Duration = 2,
                Image = 4483362458
            })
        else
            rf:Notify({
                Title = "Empty",
                Content = "No logs to export.",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

tab2:CreateParagraph({
    Title = "About",
    Content = "This chat logger helps you find codes and messages in different languages. Perfect for Possessor game where people try to hide their communication!"
})

rf:Notify({
    Title = "Chat Logger Active",
    Content = "Now monitoring all chat messages. Click any message to copy!",
    Duration = 3,
    Image = 4483362458
})

print("Chat Logger loaded successfully!")
