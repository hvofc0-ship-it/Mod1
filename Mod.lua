-- SCRIPT COMPLETO ATUALIZADO

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "KeySystemGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local function criarBotaoFechar(parent)
    local close = Instance.new("TextButton", parent)
    close.Size = UDim2.new(0, 25, 0, 25)
    close.Position = UDim2.new(1, -30, 0, 5)
    close.Text = "X"
    close.TextSize = 16
    close.Font = Enum.Font.SourceSansBold
    close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.AutoButtonColor = true
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
end

local function criarFrame(tamanho, pos, cor)
    local frame = Instance.new("Frame")
    frame.Size = tamanho
    frame.Position = pos
    frame.BackgroundColor3 = cor
    frame.BorderSizePixel = 0
    frame.Parent = gui
    return frame
end

-- Menu de Key
local frame = criarFrame(UDim2.new(0, 300, 0, 150), UDim2.new(0.5, -150, 0.5, -75), Color3.fromRGB(40,40,40))
criarBotaoFechar(frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Key System"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(1, -20, 0, 30)
input.Position = UDim2.new(0, 10, 0, 50)
input.PlaceholderText = "Digite a key aqui..."
input.Text = ""
input.TextSize = 18
input.Font = Enum.Font.SourceSans
input.BackgroundColor3 = Color3.fromRGB(70,70,70)
input.TextColor3 = Color3.new(1,1,1)

local botao = Instance.new("TextButton", frame)
botao.Size = UDim2.new(1, -20, 0, 30)
botao.Position = UDim2.new(0, 10, 0, 90)
botao.Text = "Verificar"
botao.TextSize = 18
botao.Font = Enum.Font.SourceSansBold
botao.BackgroundColor3 = Color3.fromRGB(0,170,0)
botao.TextColor3 = Color3.new(1,1,1)

local flyActive = false
local flyConnection

local function startFly()
    if flyActive then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    flyActive = true

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0,1,0)
        end

        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir.Unit * 50
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function stopFly()
    flyActive = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local bv = hrp:FindFirstChildOfClass("BodyVelocity")
        if bv then bv:Destroy() end
    end
end

local noclipActive = false
local noclipConnection

local function noclipToggle(state)
    noclipActive = state ~= nil and state or not noclipActive
    if noclipActive and not noclipConnection then
        noclipConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif not noclipActive and noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    return noclipActive
end

local function fling(targetHRP)
    -- ativa noclip no player local pra não travar
    noclipToggle(true)

    -- ativa body angular velocity no alvo
    local bav = Instance.new("BodyAngularVelocity")
    bav.AngularVelocity = Vector3.new(0,99999,0)
    bav.MaxTorque = Vector3.new(0,math.huge,0)
    bav.P = math.huge
    bav.Name = "FlingForce"
    bav.Parent = targetHRP
    return bav
end

local menuPrincipal

local function abrirMenuCheats()
    local cheatsMenu = criarFrame(UDim2.new(0,300,0,220), UDim2.new(0.5, -150, 0.5, 60), Color3.fromRGB(35,35,35))
    criarBotaoFechar(cheatsMenu)

    local titulo = Instance.new("TextLabel", cheatsMenu)
    titulo.Size = UDim2.new(1,0,0,30)
    titulo.Text = "Cheats"
    titulo.TextColor3 = Color3.new(1,1,1)
    titulo.BackgroundTransparency = 1
    titulo.Font = Enum.Font.SourceSansBold
    titulo.TextSize = 24

    local botaoFly = Instance.new("TextButton", cheatsMenu)
    botaoFly.Size = UDim2.new(0,120,0,30)
    botaoFly.Position = UDim2.new(0,10,0,40)
    botaoFly.Text = "Fly"
    botaoFly.Font = Enum.Font.SourceSansBold
    botaoFly.TextSize = 18
    botaoFly.BackgroundColor3 = Color3.fromRGB(0,170,0)
    botaoFly.TextColor3 = Color3.new(1,1,1)

    local botaoNoclip = Instance.new("TextButton", cheatsMenu)
    botaoNoclip.Size = UDim2.new(0,120,0,30)
    botaoNoclip.Position = UDim2.new(0,160,0,40)
    botaoNoclip.Text = "Noclip"
    botaoNoclip.Font = Enum.Font.SourceSansBold
    botaoNoclip.TextSize = 18
    botaoNoclip.BackgroundColor3 = Color3.fromRGB(0,170,0)
    botaoNoclip.TextColor3 = Color3.new(1,1,1)

    local botaoFling = Instance.new("TextButton", cheatsMenu)
    botaoFling.Size = UDim2.new(0,120,0,30)
    botaoFling.Position = UDim2.new(0,10,0,80)
    botaoFling.Text = "Fling"
    botaoFling.Font = Enum.Font.SourceSansBold
    botaoFling.TextSize = 18
    botaoFling.BackgroundColor3 = Color3.fromRGB(0,170,0)
    botaoFling.TextColor3 = Color3.new(1,1,1)

    local botaoFlingAll = Instance.new("TextButton", cheatsMenu)
    botaoFlingAll.Size = UDim2.new(0,120,0,30)
    botaoFlingAll.Position = UDim2.new(0,160,0,80)
    botaoFlingAll.Text = "Fling All"
    botaoFlingAll.Font = Enum.Font.SourceSansBold
    botaoFlingAll.TextSize = 18
    botaoFlingAll.BackgroundColor3 = Color3.fromRGB(0,170,0)
    botaoFlingAll.TextColor3 = Color3.new(1,1,1)

    botaoFly.MouseButton1Click:Connect(function()
        if flyActive then
            stopFly()
            botaoFly.Text = "Fly"
            botaoFly.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            startFly()
            botaoFly.Text = "Fly: ON"
            botaoFly.BackgroundColor3 = Color3.fromRGB(0,255,0)
        end
    end)

    botaoNoclip.MouseButton1Click:Connect(function()
        local ativo = noclipToggle()
        if ativo then
            botaoNoclip.Text = "Noclip: ON"
            botaoNoclip.BackgroundColor3 = Color3.fromRGB(0,255,0)
        else
            botaoNoclip.Text = "Noclip"
            botaoNoclip.BackgroundColor3 = Color3.fromRGB(0,170,0)
        end
    end)

    botaoFling.MouseButton1Click:Connect(function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            fling(character.HumanoidRootPart)
        end
    end)

    botaoFlingAll.MouseButton1Click:Connect(function()
        local myChar = player.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

        local playersList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(playersList, plr)
            end
        end

        local function shuffle(tbl)
            for i = #tbl, 2, -1 do
                local j = math.random(i)
                tbl[i], tbl[j] = tbl[j], tbl[i]
            end
        end

        shuffle(playersList)

        spawn(function()
            noclipToggle(true)

            for _, targetPlayer in ipairs(playersList) do
                local targetChar = targetPlayer.Character
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = targetChar.HumanoidRootPart
                    local myHRP = myChar.HumanoidRootPart

                    myChar:SetPrimaryPartCFrame(targetHRP.CFrame * CFrame.new(0,3,0))

                    local bav = Instance.new("BodyAngularVelocity")
                    bav.AngularVelocity = Vector3.new(0,99999,0)
                    bav.MaxTorque = Vector3.new(0,math.huge,0)
                    bav.P = math.huge
                    bav.Name = "FlingForce"
                    bav.Parent = targetHRP

                    wait(3)

                    bav:Destroy()
                end
            end

            noclipToggle(false)
        end)
    end)
end

local function abrirMenuPrincipal()
    menuPrincipal = criarFrame(UDim2.new(0,300,0,100), UDim2.new(0.5, -150, 0.5, -50), Color3.fromRGB(25,25,25))
    criarBotaoFechar(menuPrincipal)

    local texto = Instance.new("TextLabel", menuPrincipal)
    texto.Size = UDim2.new(1,0,1,0)
    texto.BackgroundTransparency = 1
    texto.TextColor3 = Color3.new(1,1,1)
    texto.TextSize = 22
    texto.Font = Enum.Font.SourceSansBold
    texto.Text = "Bem-vindo ao script!"

    spawn(function()
        wait(5)
        if menuPrincipal and menuPrincipal.Parent then
            menuPrincipal:Destroy()
        end
        abrirMenuCheats()
    end)
end

botao.MouseButton1Click:Connect(function()
    if input.Text:lower() == "pizza" then
        frame:Destroy()
        abrirMenuPrincipal()
    else
        botao.Text = "Key incorreta!"
        botao.BackgroundColor3 = Color3.fromRGB(170,0,0)
        wait(2)
        botao.Text = "Verificar"
        botao.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)
