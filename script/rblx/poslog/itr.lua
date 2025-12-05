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

local tcs = game:GetService("TextChatService")
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
                Content = "Message copied to clipboard from " .. pname,
                Duration = 2,
                Image = 4483362458
            })
        end
    })
end

local function newchat()
    local ok, err = pcall(function()
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            for _, ch in pairs(tcs:GetChildren()) do
                if ch:IsA("TextChannel") then
                    ch.MessageReceived:Connect(function(m)
                        local pn = "Unknown"
                        local mt = m.Text
                        
                        if m.TextSource then
                            pn = m.TextSource.Name
                        end
                        
                        local ft = string.format("[%s] %s: %s", 
                            os.date("%H:%M:%S"), 
                            pn, 
                            mt
                        )
                        
                        addlog(pn, mt, ft)
                    end)
                end
            end
            
            tcs.ChildAdded:Connect(function(c)
                if c:IsA("TextChannel") then
                    c.MessageReceived:Connect(function(m)
                        local pn = "Unknown"
                        local mt = m.Text
                        
                        if m.TextSource then
                            pn = m.TextSource.Name
                        end
                        
                        local ft = string.format("[%s] %s: %s", 
                            os.date("%H:%M:%S"), 
                            pn, 
                            mt
                        )
                        
                        addlog(pn, mt, ft)
                    end)
                end
            end)
            
            return true
        end
        return false
    end)
    
    return ok and not err
end

local function oldchat()
    local ok, err = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local ce = rs:WaitForChild("DefaultChatSystemChatEvents", 5)
        
        if ce then
            local omdf = ce:WaitForChild("OnMessageDoneFiltering", 5)
            
            if omdf then
                omdf.OnClientEvent:Connect(function(md)
                    if md then
                        local pn = md.FromSpeaker or "Unknown"
                        local m = md.Message or ""
                        
                        local ft = string.format("[%s] %s: %s", 
                            os.date("%H:%M:%S"), 
                            pn, 
                            m
                        )
                        
                        addlog(pn, m, ft)
                    end
                end)
                return true
            end
        end
        return false
    end)
    
    return ok and not err
end

local setup = false

if newchat() then
    setup = true
    print("Chat Logger: Using TextChatService")
elseif oldchat() then
    setup = true
    print("Chat Logger: Using Legacy Chat")
else
    task.wait(2)
    if newchat() then
        setup = true
        print("Chat Logger: Using TextChatService (delayed)")
    else
        task.wait(2)
        if oldchat() then
            setup = true
            print("Chat Logger: Using Legacy Chat (delayed)")
        end
    end
end

if not setup then
    rf:Notify({
        Title = "Warning",
        Content = "Could not detect chat system. Some messages may not be logged.",
        Duration = 5,
        Image = 4483362458
    })
end

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

print("Possessor Chat Logger loaded successfully!")
