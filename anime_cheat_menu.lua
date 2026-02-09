--[[
    AWAKEN.EXE - ANIME CHEAT MENU v2.0
    Theme: Pink/Dark Anime Aesthetic
    Author: Antigravity (Updated: 2026-02-08)
    Status: ONLINE
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
-- // UI Container
local UI = Instance.new("ScreenGui")
UI.Name = "AWAKEN_UI"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.Parent = game:GetService("CoreGui")
-- // Clean up existing connections if re-executed
if getgenv().SakuraConnections then
    for _, v in pairs(getgenv().SakuraConnections) do
        if v then v:Disconnect() end
    end
end
getgenv().SakuraConnections = {}
-- // Settings (Global)
-- // Settings (Global)
getgenv().SakuraSettings = {
    Combat = {
        Aimbot = {
            Enabled = false,
            Key = Enum.UserInputType.MouseButton2,
            KeyName = "RightClick",
            Smoothing = 0.1,
        },
        SilentAim = {
            Enabled = false,
            FOV = 100,
        },
        TriggerBot = {
            Enabled = false,
            Delay = 0.1
        },
        FOV = 150,
        TargetPart = "Head",
        WallCheck = false,
        TeamCheck = false 
    },
    Visuals = {
        ESP = {
            Enabled = false,
            Boxes = false,
            Names = false,
            Tracers = false,
            Color = Color3.fromRGB(255, 105, 180),
            TeamColor = false,
            EnemyColor = Color3.fromRGB(255, 0, 0),
            AllyColor = Color3.fromRGB(0, 255, 0)
        },
        ForceThirdPerson = false 
    },
    Effects = {
        HitMarkers = false,
        DamageNumbers = false,
        TracerBullets = false,
        ImpactSparks = false,
        HeadshotEffect = false,
        FreezeFrame = false
    },
    Audio = {
        KillStreakSounds = false,
        HeadshotDing = false,
        UISounds = false,
        Volume = 1.0
    },
    Rage = {
        SpinBot = false,
        RapidFire = false,
        RapidFireCPS = 20,
        NoRecoil = false,
        FlyMode = false,
        FlySpeed = 50,
        Noclip = false
    },
    Misc = {
        KillSound = false,
        SoundID = "rbxassetid://4590657391",
        Freecam = false,
        FreecamSpeed = 1,
        Fullbright = false,
        RemoveFog = false,
        FOVChanger = 70,
        Watermark = true,
        FPSCounter = true,
        VelocityMeter = false,
        CoordinateDisplay = false,
        PanicKey = Enum.KeyCode.Delete
    },
    Stats = {
        Enabled = true,
        Kills = 0,
        Deaths = 0,
        Headshots = 0,
        TotalShots = 0,
        Hits = 0,
        SessionStart = 0,
        KillStreak = 0,
        BestStreak = 0
    },
    Cursor = {
        Enabled = false,
        ID = "rbxassetid://6065765799",
        Size = 64,
        SpinSpeed = 5
    },
    Movement = {
        Speed = 16,
        Jump = 50,
        Bhop = false
    },
    Theme = {
        Background = "", 
        Accent = Color3.fromRGB(255, 105, 180),
        MenuKey = Enum.KeyCode.Insert,
        MenuKeyName = "Insert"
    },
    MouseLock = false,
    
    -- [NEW MENU FEATURES]
    FocusSystem = {
        ZenFocus = false,
        InstinctLine = false,
        BreathControl = false,
        EyeOfResolve = false,
        CalmBeforeShot = false
    },
    Awareness = {
        SixthSense = false,
        ThreatIndicator = false,
        ShadowPresence = false,
        HeartbeatWarning = false,
        DirectionMark = false
    },
    WeaponSoul = {
        SpiritRecoil = false,
        ImpactBloom = false,
        BladeCrosshair = false,
        KillFlash = false,
        EnergyReload = false
    },
    Awakening = {
        LimitBreak = false,
        BloodOath = false,
        RageSync = false,
        FinalResolve = false,
        Overdrive = false
    },
    Illusions = {
        AfterimageTrail = false,
        MotionBlur = false,
        ScreenShake = false,
        MangaPanel = false,
        GhostStep = false,
        TrailDuration = 0.3
    },
    Sensory = {
        DirectionalEcho = false,
        FocusSilence = false,
        HeartbeatSync = false,
        WeaponResonance = false,
        AmbientBoost = false
    },
    Waifu = {
        VoiceLines = false,
        ExpressionSync = false,
        Name = "Sakura",
        IdleAnimation = false
    },
    Style = {
        ParticleEffects = true,
        ParticleDensity = 50,
        GlowIntensity = 0.7,
        UIScale = 1.0
    }
}
local Settings = getgenv().SakuraSettings
-- // Helper Functions for Checks
local function IsAlive(Plr)
    return Plr and Plr.Character and Plr.Character:FindFirstChild("Humanoid") and Plr.Character.Humanoid.Health > 0 and Plr.Character:FindFirstChild("HumanoidRootPart")
end
local function IsEnemy(Plr)
    if not Settings.Visuals.ESP.TeamColor and not Settings.Combat.TeamCheck then return true end
    if Plr.Team and LocalPlayer.Team and Plr.Team == LocalPlayer.Team then return false end
    return true
end
local function IsVisible(Plr)
    if not Settings.Combat.WallCheck then return true end
    if not IsAlive(Plr) or not IsAlive(LocalPlayer) then return false end
    
    local Origin = Camera.CFrame.Position
    local Destination = Plr.Character[Settings.Combat.TargetPart].Position
    local Direction = Destination - Origin
    
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {LocalPlayer.Character}
    Params.FilterType = Enum.RaycastFilterType.Exclude
    
    local Result = workspace:Raycast(Origin, Direction, Params)
    if Result then
        if Result.Instance:IsDescendantOf(Plr.Character) then
            return true
        else
            return false
        end
    end
    return true 
end
local function ParseID(Input)
    if not Input then return "" end
    Input = tostring(Input)
    if Input:match("^%d+$") then
        -- Use rbxthumb for raw IDs to support Decals/Images/Stickers all at once
        return "rbxthumb://type=Asset&id=" .. Input .. "&w=420&h=420"
    elseif Input:lower():find("http") then
        return Input -- Full URL
    elseif Input:lower():find("rbxassetid") then
        return Input -- Already formatted as asset
    else
        return "rbxthumb://type=Asset&id=" .. Input .. "&w=420&h=420"
    end
end
-- Safe Save/Load
local function SaveConfig()
    if not writefile then return end
    local json = HttpService:JSONEncode(Settings)
    writefile("SakuraConfig.json", json)
end
local function LoadConfig()
    if not readfile or not isfile or not isfile("SakuraConfig.json") then return end
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile("SakuraConfig.json")) end)
    if success and decoded then
        -- We manually merge to preserve structure if needed, or just overwrite
        -- For simplicity, overwrite specific known tables
        if decoded.Aimbot then 
             -- Convert key names back to Enums if needed, JSON stores strings/numbers
             -- For now, we will just use the loaded table and trust the Keybind element updates it.
             -- Re-parsing Enum from string is tricky without a map, so we'll rely on the KeyName matching in the binder.
        end
        -- Actually, a simple deep merge is better, but complex with Enums.
        -- Let's just load values we can easily serialize.
        -- Limitation: Enums don't serialize well. We will use the KeyName to restore binds if possible.
    end
end
-- // UI Library (Miniaturized for single file)
local Library = {}
local UI = Instance.new("ScreenGui")
UI.Name = "SakuraUI"
UI.ResetOnSpawn = false
UI.IgnoreGuiInset = true -- [FIX] Important for Cursor/ESP alignment
-- Safe Parenting
local function ParentUI()
    local Success, Err = pcall(function()
        if gethui and type(gethui) == "function" then
            UI.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(UI)
            UI.Parent = game:GetService("CoreGui")
        elseif game:GetService("CoreGui") then
            UI.Parent = game:GetService("CoreGui")
        else
            UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    if not Success then
        UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end
ParentUI()
-- [THEME SYSTEM]
Library.Themes = {
    Kawaii = {
        Name = "Kawaii Dreams",
        Main = Color3.fromRGB(255, 240, 250),
        Secondary = Color3.fromRGB(255, 228, 242),
        Accent = Color3.fromRGB(255, 105, 180),
        Text = Color3.fromRGB(80, 40, 60),
        Background = "rbxassetid://6687295781", -- Sakura petals
        ParticleTexture = "rbxassetid://6687295781"
    },
    BloodMoon = {
        Name = "Blood Moon",
        Main = Color3.fromRGB(20, 10, 10),
        Secondary = Color3.fromRGB(40, 15, 15),
        Accent = Color3.fromRGB(200, 20, 20),
        Text = Color3.fromRGB(240, 200, 200),
        Background = "",
        ParticleTexture = "rbxassetid://6687295781"
    },
    CyberOni = {
        Name = "Cyber Oni",
        Main = Color3.fromRGB(10, 10, 25),
        Secondary = Color3.fromRGB(15, 15, 35),
        Accent = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(200, 240, 255),
        Background = "",
        ParticleTexture = "rbxassetid://6687295781"
    },
    Void = {
        Name = "Void Embrace",
        Main = Color3.fromRGB(5, 5, 10),
        Secondary = Color3.fromRGB(15, 10, 20),
        Accent = Color3.fromRGB(138, 43, 226),
        Text = Color3.fromRGB(220, 200, 240),
        Background = "",
        ParticleTexture = "rbxassetid://6687295781"
    }
}
Library.CurrentThemeName = "Kawaii" -- Default theme
-- [VISUAL EFFECTS SYSTEM]
local function AddParticles(Parent)
    -- Creates a subtle particle emitter using ImageLabels
    task.spawn(function()
        while Parent and Parent.Parent do
            if not Library.Themes or not Library.CurrentThemeName or not Library.Themes[Library.CurrentThemeName] then break end
            local PInfo = Library.Themes[Library.CurrentThemeName].ParticleTexture or "rbxassetid://6687295781" -- Default Sakura
            
            local P = Instance.new("ImageLabel")
            P.Parent = Parent
            P.BackgroundTransparency = 1
            P.Image = PInfo
            P.ImageTransparency = 0.5
            P.Size = UDim2.new(0, math.random(10, 20), 0, math.random(10, 20))
            P.Position = UDim2.new(math.random(), 0, -0.1, 0)
            P.Rotation = math.random(0, 360)
            
            local EndPos = UDim2.new(math.random(), 0, 1.1, 0)
            local Duration = math.random(3, 8)
            
            TweenService:Create(P, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Position = EndPos, Rotation = P.Rotation + 180}):Play()
            TweenService:Create(P, TweenInfo.new(Duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {ImageTransparency = 1}):Play()
            
            game.Debris:AddItem(P, Duration)
            task.wait(math.random(0.5, 2))
        end
    end)
end
local function AddRipple(Btn)
    Btn.ClipsDescendants = true
    Btn.MouseButton1Click:Connect(function()
        local Mouse = game.Players.LocalPlayer:GetMouse()
        local Circle = Instance.new("ImageLabel")
        Circle.Name = "Ripple"
        Circle.Parent = Btn
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Circle.ImageTransparency = 0.8
        Circle.ZIndex = 10
        
        local X = Mouse.X - Btn.AbsolutePosition.X
        local Y = Mouse.Y - Btn.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, X, 0, Y)
        Circle.Size = UDim2.new(0, 0, 0, 0)
        
        local Size = math.max(Btn.AbsoluteSize.X, Btn.AbsoluteSize.Y) * 1.5
        TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, Size, 0, Size), Position = UDim2.new(0, X - Size/2, 0, Y - Size/2), ImageTransparency = 1}):Play()
        game.Debris:AddItem(Circle, 0.5)
    end)
end
-- [CORE LIBRARY IMPLEMENTATION]
function Library:CreateWindow(Name)
    local Window = {}
    
    local UI = Instance.new("ScreenGui")
    UI.Name = Name
    UI.Parent = game:GetService("CoreGui") -- ProtectGui logic assumed external or ignored for now
    
    -- Main Container
    local Main = Instance.new("ImageLabel")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = UI
    Main.Active = true
    
    -- Draggable
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local delta = input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if Dragging then Update(input) end
        end
    end)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Main
    
    -- Background Image/Texture
    local BG = Instance.new("ImageLabel")
    BG.Name = "Pattern"
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.BackgroundTransparency = 1
    BG.Image = Library.Themes[Library.CurrentThemeName].Background
    BG.ImageTransparency = 0.9
    BG.ScaleType = Enum.ScaleType.Tile
    BG.TileSize = UDim2.new(0, 100, 0, 100)
    BG.Parent = Main
    Instance.new("UICorner", BG).CornerRadius = UDim.new(0, 12)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Secondary
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = Name
    Title.Font = Enum.Font.FredokaOne
    Title.TextColor3 = Library.Themes[Library.CurrentThemeName].Accent
    Title.TextSize = 22
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Parent = Sidebar
    
    -- Particles
    AddParticles(Sidebar)
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -10, 1, -60)
    TabContainer.Position = UDim2.new(0, 5, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = TabContainer
    
    -- Content Area
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -160, 1, -10)
    Content.Position = UDim2.new(0, 160, 0, 5)
    Content.BackgroundTransparency = 1
    Content.Parent = Main
    
    local Folder = Instance.new("Folder")
    Folder.Name = "Pages"
    Folder.Parent = Content
    
    function Window:Tab(TabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabContainer
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main
        TabBtn.Text = TabName
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
        TabBtn.TextSize = 14
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        AddRipple(TabBtn)
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName
        Page.Parent = Folder
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        
        local PList = Instance.new("UIListLayout")
        PList.Padding = UDim.new(0, 6)
        PList.SortOrder = Enum.SortOrder.LayoutOrder
        PList.Parent = Page
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Folder:GetChildren()) do v.Visible = false end
            Page.Visible = true
            
            -- Reset Colors
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main, TextColor3 = Library.Themes[Library.CurrentThemeName].Text}):Play()
                end
            end
            
            -- Active Color
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Accent, TextColor3 = Library.Themes[Library.CurrentThemeName].Main}):Play()
        end)
        
        -- Auto Select First
        if #Folder:GetChildren() == 1 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Accent
            TabBtn.TextColor3 = Library.Themes[Library.CurrentThemeName].Main
        end
        
        local Elements = {}
        function Items:Toggle(Text, Callback)
             local TogFrame = Instance.new("Frame")
             TogFrame.Size = UDim2.new(1, -5, 0, 36)
             TogFrame.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Secondary
             TogFrame.Parent = Page
             Instance.new("UICorner", TogFrame).CornerRadius = UDim.new(0, 6)
             
             local Lab = Instance.new("TextLabel")
             Lab.Text = "  " .. Text
             Lab.Size = UDim2.new(0.7, 0, 1, 0)
             Lab.BackgroundTransparency = 1
             Lab.Font = Enum.Font.GothamSemibold
             Lab.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
             Lab.TextSize = 13
             Lab.TextXAlignment = Enum.TextXAlignment.Left
             Lab.Parent = TogFrame
             
             local Toggle = Instance.new("Frame")
             Toggle.Size = UDim2.new(0, 36, 0, 18)
             Toggle.Position = UDim2.new(1, -45, 0.5, -9)
             Toggle.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main
             Toggle.Parent = TogFrame
             Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
             
             local Circle = Instance.new("Frame")
             Circle.Size = UDim2.new(0, 14, 0, 14)
             Circle.Position = UDim2.new(0, 2, 0.5, -7)
             Circle.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Text
             Circle.Parent = Toggle
             Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
             
             local Btn = Instance.new("TextButton")
             Btn.Size = UDim2.new(1, 0, 1, 0)
             Btn.BackgroundTransparency = 1
             Btn.Text = ""
             Btn.Parent = TogFrame
             AddRipple(Btn)
             
             local Enabled = false
             Btn.MouseButton1Click:Connect(function()
                 Enabled = not Enabled
                 Callback(Enabled)
                 if Enabled then
                     TweenService:Create(Toggle, TweenInfo.new(0.3), {BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Accent}):Play()
                     TweenService:Create(Circle, TweenInfo.new(0.3), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main}):Play()
                 else
                     TweenService:Create(Toggle, TweenInfo.new(0.3), {BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main}):Play()
                     TweenService:Create(Circle, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Text}):Play()
                 end
             end)
        end
        function Items:Slider(Text, Min, Max, Start, Callback)
             local SFrame = Instance.new("Frame")
             SFrame.Size = UDim2.new(1, -5, 0, 45)
             SFrame.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Secondary
             SFrame.Parent = Page
             Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0, 6)
             
             local Lab = Instance.new("TextLabel")
             Lab.Text = "  " .. Text .. ": " .. Start
             Lab.Size = UDim2.new(1, 0, 0, 25)
             Lab.BackgroundTransparency = 1
             Lab.Font = Enum.Font.GothamSemibold
             Lab.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
             Lab.TextSize = 13
             Lab.TextXAlignment = Enum.TextXAlignment.Left
             Lab.Parent = SFrame
             
             local Bar = Instance.new("Frame")
             Bar.Size = UDim2.new(0.9, 0, 0, 4)
             Bar.Position = UDim2.new(0.05, 0, 0.75, 0)
             Bar.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main
             Bar.Parent = SFrame
             Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
             
             local Fill = Instance.new("Frame")
             Fill.Size = UDim2.new((Start - Min)/(Max - Min), 0, 1, 0)
             Fill.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Accent
             Fill.Parent = Bar
             Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
             
             local Trigger = Instance.new("TextButton")
             Trigger.Size = UDim2.new(1, 0, 1, 0)
             Trigger.BackgroundTransparency = 1
             Trigger.Text = ""
             Trigger.Parent = SFrame
             
             local function Update(Input)
                 local SizeScale = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                 local Val = math.floor(Min + ((Max - Min) * SizeScale))
                 Lab.Text = "  " .. Text .. ": " .. Val
                 TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeScale, 0, 1, 0)}):Play()
                 Callback(Val)
             end
             
             local Dragging = false
             Trigger.InputBegan:Connect(function(input)
                 if input.UserInputType == Enum.UserInputType.MouseButton1 then
                     Dragging = true
                     Update(input)
                 end
             end)
             UserInputService.InputEnded:Connect(function(input)
                 if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
             end)
             UserInputService.InputChanged:Connect(function(input)
                 if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                     Update(input)
                 end
             end)
        end
        function Items:TextBox(Text, Default, Callback)
            local BoxFrame = Instance.new("Frame")
            local BCorner = Instance.new("UICorner")
            local Label = Instance.new("TextLabel")
            local TextBox = Instance.new("TextBox")
            local TBCorner = Instance.new("UICorner")
            BoxFrame.Name = Text
            BoxFrame.Parent = TabContent
            BoxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            BoxFrame.Size = UDim2.new(1, -10, 0, 40)
            BCorner.CornerRadius = UDim.new(0, 6)
            BCorner.Parent = BoxFrame
            Label.Parent = BoxFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(0, 150, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = Text
            Label.TextColor3 = Theme.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
        function Items:TextBox(Text, Default, Callback)
             local BoxFrame = Instance.new("Frame")
             BoxFrame.Size = UDim2.new(1, -5, 0, 45)
             BoxFrame.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Secondary
             BoxFrame.Parent = Page
             Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
             
             local Lab = Instance.new("TextLabel")
             Lab.Text = "  " .. Text
             Lab.Size = UDim2.new(1, 0, 0, 20)
             Lab.BackgroundTransparency = 1
             Lab.Font = Enum.Font.GothamSemibold
             Lab.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
             Lab.TextSize = 13
             Lab.TextXAlignment = Enum.TextXAlignment.Left
             Lab.Parent = BoxFrame
             
             local Box = Instance.new("TextBox")
             Box.Size = UDim2.new(0.9, 0, 0, 20)
             Box.Position = UDim2.new(0.05, 0, 0.5, 0)
             Box.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main
             Box.Text = Default or ""
             Box.Font = Enum.Font.Gotham
             Box.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
             Box.TextSize = 13
             Box.Parent = BoxFrame
             Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
             
             Box.FocusLost:Connect(function()
                 Callback(Box.Text)
             end)
        end
        function Items:Keybind(Text, DefaultKey, DefaultName, Callback)
             local KFrame = Instance.new("Frame")
             KFrame.Size = UDim2.new(1, -5, 0, 36)
             KFrame.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Secondary
             KFrame.Parent = Page
             Instance.new("UICorner", KFrame).CornerRadius = UDim.new(0, 6)
             
             local Lab = Instance.new("TextLabel")
             Lab.Text = "  " .. Text
             Lab.Size = UDim2.new(0.7, 0, 1, 0)
             Lab.BackgroundTransparency = 1
             Lab.Font = Enum.Font.GothamSemibold
             Lab.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
             Lab.TextSize = 13
             Lab.TextXAlignment = Enum.TextXAlignment.Left
             Lab.Parent = KFrame
             
             local BindBtn = Instance.new("TextButton")
             BindBtn.Size = UDim2.new(0, 80, 0, 24)
             BindBtn.Position = UDim2.new(1, -90, 0.5, -12)
             BindBtn.BackgroundColor3 = Library.Themes[Library.CurrentThemeName].Main
             BindBtn.Text = DefaultName or "None"
             BindBtn.Font = Enum.Font.Gotham
             BindBtn.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
             BindBtn.TextSize = 12
             BindBtn.Parent = KFrame
             Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
             
             local Binding = false
             BindBtn.MouseButton1Click:Connect(function()
                 Binding = true
                 BindBtn.Text = "..."
                 BindBtn.TextColor3 = Library.Themes[Library.CurrentThemeName].Accent
             end)
             
             UserInputService.InputBegan:Connect(function(input)
                 if Binding then
                     if input.UserInputType == Enum.UserInputType.Keyboard then
                         Binding = false
                         Callback(input.KeyCode, input.KeyCode.Name)
                         BindBtn.Text = input.KeyCode.Name
                         BindBtn.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
                     elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                         Binding = false
                         Callback(input.UserInputType, input.UserInputType.Name)
                         BindBtn.Text = input.UserInputType.Name
                         BindBtn.TextColor3 = Library.Themes[Library.CurrentThemeName].Text
                     end
                 end
             end)
        end
        return Items
    end
    return Window
end
-- [MENU INITIALIZATION]
local Window = Library:CreateWindow("AWAKEN.EXE")
-- [TAB: COMBAT] 
local CombatTab = Window:Tab("🎯 Combat")
CombatTab:Toggle("Aimbot", function(v) 
    Settings.Combat.Aimbot.Enabled = v 
    print("[Combat] Aimbot:", v)
end)
CombatTab:Slider("Smoothing", 0, 100, 10, function(v)
    Settings.Combat.Aimbot.Smoothing = v / 100
    print("[Combat] Smoothing:", v / 100)
end)
CombatTab:Slider("FOV", 50, 500, 150, function(v)
    Settings.Combat.FOV = v
    print("[Combat] FOV:", v)
end)
CombatTab:Toggle("Wall Check", function(v) 
    Settings.Combat.WallCheck = v 
    print("[Combat] Wall Check:", v)
end)
CombatTab:Toggle("Team Check", function(v) 
    Settings.Combat.TeamCheck = v 
    print("[Combat] Team Check:", v)
end)
CombatTab:Toggle("Silent Aim", function(v) 
    Settings.Combat.SilentAim.Enabled = v 
    print("[Combat] Silent Aim:", v)
end)
CombatTab:Toggle("Trigger Bot", function(v) 
    Settings.Combat.TriggerBot.Enabled = v 
    print("[Combat] Trigger Bot:", v)
end)
CombatTab:Slider("Trigger Delay", 0, 100, 10, function(v)
    Settings.Combat.TriggerBot.Delay = v / 100
    print("[Combat] Trigger Delay:", v / 100)
end)
CombatTab:Toggle("Humanize Trigger", function(v) 
    Settings.Combat.TriggerBot.Humanize = v 
    print("[Combat] Humanize:", v)
end)
CombatTab:Keybind("Aimbot Key", Enum.UserInputType.MouseButton2, "RightClick", function(key, name)
    Settings.Combat.Aimbot.Key = key
    Settings.Combat.Aimbot.KeyName = name
    print("[Combat] Aimbot Key:", name)
end)
CombatTab:Toggle("Prediction", function(v) 
    Settings.Combat.Aimbot.Prediction = v 
    print("[Combat] Prediction:", v)
end)
CombatTab:Slider("Prediction Strength", 0, 100, 50, function(v)
    Settings.Combat.Aimbot.PredictionStrength = v / 100
    print("[Combat] Prediction Strength:", v / 100)
end)
CombatTab:Toggle("Sticky Lock", function(v) 
    Settings.Combat.Aimbot.StickyLock = v 
    print("[Combat] Sticky Lock:", v)
end)
CombatTab:Slider("Sticky Duration", 1, 10, 2, function(v)
    Settings.Combat.Aimbot.StickyDuration = v
    print("[Combat] Sticky Duration:", v, "s")
end)
-- [TAB: VISUALS]
local VisualsTab = Window:Tab("👁️ Visuals")
VisualsTab:Toggle("ESP Enabled", function(v) 
    Settings.Visuals.ESP.Enabled = v 
    print("[Visuals] ESP:", v)
end)
VisualsTab:Toggle("ESP Boxes", function(v) 
    Settings.Visuals.ESP.Boxes = v 
    print("[Visuals] ESP Boxes:", v)
end)
VisualsTab:Toggle("ESP Names", function(v) 
    Settings.Visuals.ESP.Names = v 
    print("[Visuals] ESP Names:", v)
end)
VisualsTab:Toggle("ESP Tracers", function(v) 
    Settings.Visuals.ESP.Tracers = v 
    print("[Visuals] ESP Tracers:", v)
end)
VisualsTab:Toggle("Chams", function(v) 
    Settings.Visuals.Chams = v 
    print("[Visuals] Chams:", v)
end)
VisualsTab:Toggle("Force Third Person", function(v) 
    Settings.Visuals.ForceThirdPerson = v 
    print("[Visuals] Force Third Person:", v)
end)
VisualsTab:Toggle("Custom Cursor", function(v) 
    Settings.Cursor.Enabled = v 
    print("[Visuals] Custom Cursor:", v)
end)
VisualsTab:Slider("Cursor Size", 32, 128, 64, function(v)
    Settings.Cursor.Size = v
    print("[Visuals] Cursor Size:", v)
end)
-- [TAB: MOVEMENT]
local MovementTab = Window:Tab("🏃 Movement")
MovementTab:Slider("Speed", 16, 200, 16, function(v)
    Settings.Movement.Speed = v
    print("[Movement] Speed:", v)
end)
MovementTab:Slider("Jump Power", 50, 200, 50, function(v)
    Settings.Movement.Jump = v
    print("[Movement] Jump Power:", v)
end)
MovementTab:Toggle("Auto Bhop", function(v) 
    Settings.Movement.Bhop = v 
    print("[Movement] Auto Bhop:", v)
end)
-- [TAB: RAGE]
local RageTab = Window:Tab("😈 Rage")
RageTab:Toggle("SpinBot", function(v) 
    Settings.Rage.SpinBot = v 
    print("[Rage] SpinBot:", v)
end)
RageTab:Toggle("Rapid Fire", function(v) 
    Settings.Rage.RapidFire = v 
    print("[Rage] Rapid Fire:", v)
end)
RageTab:Slider("Rapid Fire CPS", 10, 50, 20, function(v)
    Settings.Rage.RapidFireCPS = v
    print("[Rage] CPS:", v)
end)
RageTab:Toggle("Fly Mode", function(v) 
    Settings.Rage.FlyMode = v 
    print("[Rage] Fly Mode:", v)
end)
RageTab:Slider("Fly Speed", 10, 100, 50, function(v)
    Settings.Rage.FlySpeed = v
    print("[Rage] Fly Speed:", v)
end)
RageTab:Toggle("Noclip", function(v) 
    Settings.Rage.Noclip = v 
    print("[Rage] Noclip:", v)
end)
-- [TAB: MISC]
local MiscTab = Window:Tab("🔧 Misc")
MiscTab:Toggle("Fullbright", function(v) 
    Settings.Misc.Fullbright = v 
    print("[Misc] Fullbright:", v)
end)
MiscTab:Toggle("Remove Fog", function(v) 
    Settings.Misc.RemoveFog = v 
    print("[Misc] Remove Fog:", v)
end)
MiscTab:Slider("FOV", 70, 120, 70, function(v)
    Settings.Misc.FOVChanger = v
    print("[Misc] FOV:", v)
end)
MiscTab:Toggle("Watermark", function(v) 
    Settings.Misc.Watermark = v 
    print("[Misc] Watermark:", v)
end)
MiscTab:Toggle("FPS Counter", function(v) 
    Settings.Misc.FPSCounter = v 
    print("[Misc] FPS Counter:", v)
end)
MiscTab:Toggle("Velocity Meter", function(v) 
    Settings.Misc.VelocityMeter = v 
    print("[Misc] Velocity Meter:", v)
end)
MiscTab:Toggle("Coordinates", function(v) 
    Settings.Misc.CoordinateDisplay = v 
    print("[Misc] Coordinates:", v)
end)
-- [TAB: FOCUS SYSTEM]
local FocusTab = Window:Tab("🎯 Focus")
FocusTab:Toggle("Zen Focus", function(v) 
    Settings.FocusSystem.ZenFocus = v 
    print("[Focus] Zen Focus:", v)
end)
FocusTab:Toggle("Instinct Line", function(v) 
    Settings.FocusSystem.InstinctLine = v 
    print("[Focus] Instinct Line:", v)
end)
FocusTab:Toggle("Breath Control", function(v) 
    Settings.FocusSystem.BreathControl = v 
    print("[Focus] Breath Control:", v)
end)
FocusTab:Toggle("Eye of Resolve", function(v) 
    Settings.FocusSystem.EyeOfResolve = v 
    print("[Focus] Eye of Resolve:", v)
end)
FocusTab:Toggle("Calm Before Shot", function(v) 
    Settings.FocusSystem.CalmBeforeShot = v 
    print("[Focus] Calm Before Shot:", v)
end)
-- [TAB: AWARENESS]
local AwarenessTab = Window:Tab("👁️ Awareness")
AwarenessTab:Toggle("Sixth Sense Pulse", function(v) 
    Settings.Awareness.SixthSense = v 
    print("[Awareness] Sixth Sense Pulse:", v)
end)
AwarenessTab:Toggle("Threat Indicator", function(v) 
    Settings.Awareness.ThreatIndicator = v 
    print("[Awareness] Threat Indicator:", v)
end)
AwarenessTab:Toggle("Shadow Presence", function(v) 
    Settings.Awareness.ShadowPresence = v 
    print("[Awareness] Shadow Presence:", v)
end)
AwarenessTab:Toggle("Heartbeat Warning", function(v) 
    Settings.Awareness.HeartbeatWarning = v 
    print("[Awareness] Heartbeat Warning:", v)
end)
AwarenessTab:Toggle("Direction Mark", function(v) 
    Settings.Awareness.DirectionMark = v 
    print("[Awareness] Direction Mark:", v)
end)
-- [TAB: WEAPON SOUL]
local WeaponTab = Window:Tab("⚔️ Weapon")
WeaponTab:Toggle("Spirit Recoil FX", function(v) 
    Settings.WeaponSoul.SpiritRecoil = v 
    print("[Weapon] Spirit Recoil FX:", v)
end)
WeaponTab:Toggle("Impact Bloom", function(v) 
    Settings.WeaponSoul.ImpactBloom = v 
    print("[Weapon] Impact Bloom (Particles):", v)
end)
WeaponTab:Toggle("Blade Crosshair", function(v) 
    Settings.WeaponSoul.BladeCrosshair = v 
    print("[Weapon] Blade Crosshair:", v)
end)
WeaponTab:Toggle("Kill Flash", function(v) 
    Settings.WeaponSoul.KillFlash = v 
    print("[Weapon] Kill Flash:", v)
end)
WeaponTab:Toggle("Energy Reload", function(v) 
    Settings.WeaponSoul.EnergyReload = v 
    print("[Weapon] Energy Reload:", v)
end)
WeaponTab:Toggle("Kill Sound", function(v) 
    Settings.Misc.KillSound = v 
    print("[Weapon] Kill Sound:", v)
end)
WeaponTab:TextBox("Sound ID", "4590657391", function(v)
    Settings.Misc.SoundID = "rbxassetid://" .. v
    print("[Weapon] Sound ID set to:", v)
end)
-- [TAB: AWAKENING]
local AwakeningTab = Window:Tab("⚡ Awakening") 
AwakeningTab:Toggle("Limit Break Visual", function(v) 
    Settings.Awakening.LimitBreak = v 
    print("[Awakening] Limit Break:", v)
end)
AwakeningTab:Toggle("Blood Oath Mode", function(v) 
    Settings.Awakening.BloodOath = v 
    print("[Awakening] Blood Oath:", v)
end)
AwakeningTab:Toggle("Rage Sync", function(v) 
    Settings.Awakening.RageSync = v 
    print("[Awakening] Rage Sync:", v)
end)
AwakeningTab:Toggle("Final Resolve", function(v) 
    Settings.Awakening.FinalResolve = v 
    print("[Awakening] Final Resolve:", v)
end)
AwakeningTab:Toggle("Overdrive FX", function(v) 
    Settings.Awakening.Overdrive = v 
    print("[Awakening] Overdrive:", v)
end)
-- [TAB: ILLUSIONS]
local IllusionsTab = Window:Tab("🌀 Illusions")
IllusionsTab:Toggle("Afterimage Trail", function(v) 
    Settings.Illusions.AfterimageTrail = v 
    print("[Illusions] Afterimage Trail:", v)
end)
IllusionsTab:Toggle("Motion Blur Anime", function(v) 
    Settings.Illusions.MotionBlur = v 
    print("[Illusions] Motion Blur:", v)
end)
IllusionsTab:Toggle("Screen Shake Impact", function(v) 
    Settings.Illusions.ScreenShake = v 
    print("[Illusions] Screen Shake:", v)
end)
IllusionsTab:Toggle("Manga Kill Panel", function(v) 
    Settings.Illusions.MangaPanel = v 
    print("[Illusions] Manga Kill Panel:", v)
end)
IllusionsTab:Toggle("Ghost Step FX", function(v) 
    Settings.Illusions.GhostStep = v 
    print("[Illusions] Ghost Step:", v)
end)
IllusionsTab:Slider("Afterimage Duration", 0, 100, 30, function(v)
    Settings.Illusions.TrailDuration = v / 100
    print("[Illusions] Trail Duration:", v / 100)
end)
IllusionsTab:Toggle("🧪 TEST Kill Effects", function(v)
    if v then
        print("[TEST] Triggering Kill Effects Demo...")
        TriggerKillEffects()
        task.wait(0.1)
        -- Auto-disable after test
        v = false
    end
end)
-- [TAB: SENSORY]
local SensoryTab = Window:Tab("🎧 Sensory")
SensoryTab:Toggle("Directional Echo", function(v) 
    Settings.Sensory.DirectionalEcho = v 
    print("[Sensory] Directional Echo:", v)
end)
SensoryTab:Toggle("Focus Silence", function(v) 
    Settings.Sensory.FocusSilence = v 
    print("[Sensory] Focus Silence:", v)
end)
SensoryTab:Toggle("Heartbeat Sync", function(v) 
    Settings.Sensory.HeartbeatSync = v 
    print("[Sensory] Heartbeat Sync:", v)
end)
SensoryTab:Toggle("Weapon Resonance", function(v) 
    Settings.Sensory.WeaponResonance = v 
    print("[Sensory] Weapon Resonance:", v)
end)
SensoryTab:Toggle("Ambient Boost", function(v) 
    Settings.Sensory.AmbientBoost = v 
    print("[Sensory] Ambient Boost:", v)
end)
-- [TAB: WAIFU INTERFACE]
local WaifuTab = Window:Tab("💗 Waifu")
WaifuTab:Toggle("Voice Lines HUD", function(v) 
    Settings.Waifu.VoiceLines = v 
    print("[Waifu] Voice Lines:", v)
end)
WaifuTab:Toggle("Expression Sync", function(v) 
    Settings.Waifu.ExpressionSync = v 
    print("[Waifu] Expression Sync:", v)
end)
WaifuTab:TextBox("Waifu Name", "Sakura", function(v)
    Settings.Waifu.Name = v
    print("[Waifu] Name set to:", v)
end)
WaifuTab:Toggle("Idle Animation", function(v) 
    Settings.Waifu.IdleAnimation = v 
    print("[Waifu] Idle Animation:", v)
end)
-- [TAB: STYLE]
local StyleTab = Window:Tab("🎨 Style")
StyleTab:Toggle("Particle Effects", function(v) 
    Settings.Style.ParticleEffects = v 
    print("[Style] Particle Effects:", v)
end)
StyleTab:Slider("Particle Density", 0, 100, 50, function(v)
    Settings.Style.ParticleDensity = v
    print("[Style] Particle Density:", v)
end)
StyleTab:Slider("Glow Intensity", 0, 100, 70, function(v)
    Settings.Style.GlowIntensity = v / 100
    print("[Style] Glow Intensity:", v)
end)
StyleTab:Slider("UI Scale", 50, 150, 100, function(v)
    Settings.Style.UIScale = v / 100
    print("[Style] UI Scale:", v)
end)
StyleTab:Keybind("Menu Toggle", Enum.KeyCode.Insert, "Insert", function(key, name)
    Settings.Theme.MenuKey = key
    print("[Style] Menu Key set to:", name)
end)
-- [ANTI-BUG HELPER FUNCTION]
-- Ensures all visual elements are non-physical
function MakeVisualOnly(part)
    if part:IsA("BasePart") then
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.Massless = true
        part.CastShadow = false
    end
end
    
    -- Sync Button Visibility with Menu (Optional, keep button always or hide when menu open)
    -- Making button always visible for easy access
    
    function Window:Destroy()
        UI:Destroy()
        for _, v in pairs(getgenv().SakuraConnections) do
            if v then v:Disconnect() end
        end
        getgenv().SakuraConnections = {}
        
        -- Clean up Cursor
        UserInputService.MouseIconEnabled = true
        
        -- Clean up ESP
        for _, v in pairs(ESP_Holders) do
            if v.Box then v.Box:Remove() end
            if v.Name then v.Name:Remove() end
        end
    end
    return Window
end
-- Helper to Parse Asset IDs (Updated for Decals/Stickers)
local function ParseID(Input)
    if not Input then return "" end
    Input = tostring(Input)
    if Input:match("^%d+$") then
        return "rbxthumb://type=Asset&id=" .. Input .. "&w=420&h=420"
    elseif Input:lower():find("http") then
        return Input
    elseif Input:lower():find("rbxassetid") then
        return Input
    else
        return "rbxthumb://type=Asset&id=" .. Input .. "&w=420&h=420"
    end
end
-- // Feature Logic
-- [ADVANCED TARGET SELECTOR]
local LastStickyTarget = nil
local StickyLockTime = 0
local PreviousPositions = {} -- For velocity calculation
local function GetBonePart(Character, BoneSelection)
    -- Returns the correct body part based on selection
    if BoneSelection == "Head" then
        return Character:FindFirstChild("Head")
    elseif BoneSelection == "Torso" then
        return Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
    elseif BoneSelection == "ClosestPart" then
        -- Find closest visible part
        local ClosestPart = nil
        local ClosestDist = math.huge
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local Pos = Camera:WorldToViewportPoint(part.Position)
                local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    ClosestPart = part
                end
            end
        end
        return ClosestPart
    else
        return Character:FindFirstChild("Head")
    end
end
local function GetClosestPlayer()
    local ClosestDist = Settings.Combat.FOV
    if Settings.Combat.Aimbot.Mode360 then
        ClosestDist = 99999
    end
    
    local Target = nil
    local TargetPlayer = nil
    
    -- Sticky Lock: Keep same target if still valid
    if Settings.Combat.Aimbot.StickyLock and LastStickyTarget then
        if tick() - StickyLockTime < Settings.Combat.Aimbot.StickyDuration then
            local StickyChar = LastStickyTarget.Character
            if StickyChar and IsAlive(LastStickyTarget) and IsEnemy(LastStickyTarget) then
                local Part = GetBonePart(StickyChar, Settings.Combat.Aimbot.BoneSelection)
                if Part then
                    -- Check if still in FOV
                    local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                    if Dist < Settings.Combat.FOV * 1.5 then -- 1.5x FOV for sticky
                        return Part, LastStickyTarget
                    end
                end
            end
        end
        -- Sticky expired or invalid
        LastStickyTarget = nil
    end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and IsAlive(v) and IsEnemy(v) then
            local Character = v.Character
            local Part = GetBonePart(Character, Settings.Combat.Aimbot.BoneSelection)
            
            if not Part then
                Part = Character:FindFirstChild("HumanoidRootPart")
            end
            
            if Part then
                -- Visible Check
                if Settings.Combat.Aimbot.VisibleCheck then
                    local Ray = Ray.new(Camera.CFrame.Position, (Part.Position - Camera.CFrame.Position).Unit * 1000)
                    local Hit, Pos = workspace:FindPartOnRayWithIgnoreList(Ray, {LocalPlayer.Character, Camera})
                    
                    if Hit and Hit.Parent ~= Character then
                        -- Target part blocked, try alternative
                        if Settings.Combat.Aimbot.BoneSelection == "Head" then
                            -- Try torso instead
                            local AltPart = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
                            if AltPart then
                                local AltRay = Ray.new(Camera.CFrame.Position, (AltPart.Position - Camera.CFrame.Position).Unit * 1000)
                                local AltHit = workspace:FindPartOnRayWithIgnoreList(AltRay, {LocalPlayer.Character, Camera})
                                if AltHit and AltHit.Parent == Character then
                                    Part = AltPart
                                else
                                    continue -- Skip this player
                                end
                            else
                                continue
                            end
                        else
                            continue -- Skip if not visible
                        end
                    end
                end
                
                -- Wall Check
                if Settings.Combat.WallCheck and not IsVisible(v) then
                    continue
                end
                
                local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                
                if Settings.Combat.Aimbot.Mode360 or OnScreen then
                    local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                    
                    if Settings.Combat.Aimbot.Mode360 then
                        Dist = (LocalPlayer.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                    end
                    
                    if Dist < ClosestDist then
                        ClosestDist = Dist
                        Target = Part
                        TargetPlayer = v
                    end
                end
            end
        end
    end
    
    -- Update sticky lock
    if Target and Settings.Combat.Aimbot.StickyLock then
        LastStickyTarget = TargetPlayer
        StickyLockTime = tick()
    end
    
    return Target, TargetPlayer
end
-- Aimbot Loop (High Priority)
local AimbotActive = false
local CurrentTargetPlr = nil
-- Visual Debugging (FOV Circle + Line)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = Settings.Combat.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1
local SnapLine = Drawing.new("Line")
SnapLine.Thickness = 1
SnapLine.Color = Color3.fromRGB(255, 0, 0)
SnapLine.Visible = false
-- Toggle Input Handler
table.insert(getgenv().SakuraConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local Key = Settings.Combat.Aimbot.Key
    local IsInput = false
    if Key.EnumType == Enum.UserInputType and input.UserInputType == Key then IsInput = true end
    if Key.EnumType == Enum.KeyCode and input.KeyCode == Key then IsInput = true end
    
    if IsInput then
        if Settings.Combat.Aimbot.InputMode == "Toggle" then
            AimbotActive = not AimbotActive
        end
    end
end))
-- Aimbot Loop (High Priority + Fixes)
-- Priority: Run after Camera (Classic is around 200). We use 2000 to be safe? 
-- Actually Camera.Value is fine, but let's go late to override others.
RunService:BindToRenderStep("SakuraAimbot", Enum.RenderPriority.Last.Value, function()
    -- Update FOV Circle
    if Settings.Combat.Aimbot.Enabled then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.Combat.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end
    local ShouldAim = false
    
    if Settings.Combat.Aimbot.InputMode == "Always On" then
         ShouldAim = true
    elseif Settings.Combat.Aimbot.InputMode == "Toggle" then
         ShouldAim = AimbotActive
    else
        -- Hold Mode
        local Key = Settings.Combat.Aimbot.Key
        if Key.EnumType == Enum.UserInputType then
            if UserInputService:IsMouseButtonPressed(Key) then ShouldAim = true end
        else
            if UserInputService:IsKeyDown(Key) then ShouldAim = true end
        end
    end
    if Settings.Combat.Aimbot.Enabled and ShouldAim then
        local Target, TargetPlayer = GetClosestPlayer() -- NEW: Get player for prediction
        if Target and Target.Parent then
            -- [PREDICTION AIMBOT]
            local AimPosition = Target.Position
            
            if Settings.Combat.Aimbot.Prediction and TargetPlayer then
                local CurrentPos = Target.Position
                local PlayerKey = TargetPlayer.UserId
                
                if PreviousPositions[PlayerKey] then
                    local PrevData = PreviousPositions[PlayerKey]
                    local TimeDelta = tick() - PrevData.Time
                    if TimeDelta > 0 and TimeDelta < 0.5 then -- Sanity check
                        local Velocity = (CurrentPos - PrevData.Position) / TimeDelta
                        
                        -- Calculate predicted position
                        local Distance = (Camera.CFrame.Position - CurrentPos).Magnitude
                        local BulletSpeed = 1000 -- Universal estimate
                        local TravelTime = Distance / BulletSpeed
                        
                        local PredictionAmount = Settings.Combat.Aimbot.PredictionStrength
                        local PredictedOffset = Velocity * TravelTime * PredictionAmount
                        AimPosition = CurrentPos + PredictedOffset
                    end
                end
                
                PreviousPositions[PlayerKey] = {Position = CurrentPos, Time = tick()}
            end
            
            -- Smoothing logic
            local Alpha = Settings.Combat.Aimbot.Smoothing
            if Alpha == 0 then
                Alpha = 1 -- Instant
            end
            
            local MainCF = Camera.CFrame
            local TargetCF = CFrame.lookAt(MainCF.Position, AimPosition)
            
            if Alpha >= 1 then
                 Camera.CFrame = TargetCF
            else
                 Camera.CFrame = MainCF:Lerp(TargetCF, Alpha)
            end
            
            CurrentTargetPlr = TargetPlayer
            
            -- Draw Snap Line
            local Pos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
            if OnScreen then
                 SnapLine.Visible = true
                 SnapLine.From = UserInputService:GetMouseLocation()
                 SnapLine.To = Vector2.new(Pos.X, Pos.Y)
            else
                 SnapLine.Visible = false
            end
        else
             CurrentTargetPlr = nil
             SnapLine.Visible = false
        end
    else
         CurrentTargetPlr = nil
         SnapLine.Visible = false
    end
end)
table.insert(getgenv().SakuraConnections, {Disconnect = function() 
    RunService:UnbindFromRenderStep("SakuraAimbot") 
    FOVCircle:Remove()
    SnapLine:Remove()
end})
-- [TRIGGER BOT - AUTO SHOOT]
local LastTriggerShot = 0
RunService:BindToRenderStep("SakuraTriggerBot", Enum.RenderPriority.Last.Value + 1, function()
    if not Settings.Combat.TriggerBot.Enabled then return end
    if not LocalPlayer.Character then return end
    
    -- Raycast from center of screen
    local ViewportSize = Camera.ViewportSize
    local CenterX, CenterY = ViewportSize.X / 2, ViewportSize.Y / 2
    
    -- Get ray from camera through center of screen
    local Ray = Camera:ViewportPointToRay(CenterX, CenterY)
    
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParams.IgnoreWater = true
    
    local Result = workspace:Raycast(Ray.Origin, Ray.Direction * 1000, RaycastParams)
    
    if Result and Result.Instance then
        local Hit = Result.Instance
        local Character = Hit.Parent
        
        -- Check if hit a player's character
        if Character and Character:FindFirstChild("Humanoid") then
            local Player = Players:GetPlayerFromCharacter(Character)
            
            if Player and Player ~= LocalPlayer then
                -- Team check
                if Settings.Combat.TeamCheck then
                    if Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
                        return
                    end
                end
                
                -- Check if alive
                if Character.Humanoid.Health > 0 then
                    -- [ANTI-CHEAT] Humanized delay
                    local BaseDelay = Settings.Combat.TriggerBot.Delay
                    local ActualDelay = BaseDelay
                    
                    if Settings.Combat.TriggerBot.Humanize then
                        -- Add random variation (±30%)
                        local Variation = (math.random() * 0.6 - 0.3) * BaseDelay
                        ActualDelay = BaseDelay + Variation
                    end
                    
                    local CurrentTime = tick()
                    if CurrentTime - LastTriggerShot >= ActualDelay then
                        LastTriggerShot = CurrentTime
                        
                        -- Simulate mouse click
                        mouse1click()
                    end
                end
            end
        end
    end
end)
table.insert(getgenv().SakuraConnections, {Disconnect = function() 
    RunService:UnbindFromRenderStep("SakuraTriggerBot") 
end})
-- Kill Switch [FIXED]
local function MonitorDeath(Plr)
    if Plr == LocalPlayer then return end
    local function CharAdded(Char)
        local Hum = Char:WaitForChild("Humanoid", 10)
        if Hum then
            -- Use HealthChanged for faster/reliable detection
            Hum.HealthChanged:Connect(function(Health)
                if Health <= 0 then
                     local IsTarget = (CurrentTargetPlr == Plr)
                     local IsClose = false
                     
                     if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Char:FindFirstChild("HumanoidRootPart") then
                          local Dist = (LocalPlayer.Character.HumanoidRootPart.Position - Char.HumanoidRootPart.Position).Magnitude
                          if Dist < 250 then IsClose = true end
                     end
                     
                     if IsTarget or IsClose then
                          -- Play Sound
                          if Settings.Misc.KillSound then
                               local Sound = Instance.new("Sound", workspace)
                               Sound.SoundId = Settings.Misc.SoundID
                               Sound.Volume = 2
                               Sound:Play()
                               game.Debris:AddItem(Sound, 2)
                          end
                          TriggerKillEffects()
                     end
                end
            end)
        end
    end
    if Plr.Character then CharAdded(Plr.Character) end
    Plr.CharacterAdded:Connect(CharAdded)
end
-- ESP
local ESP_Holders = {}
local function DrawESP(Plr)
    if Plr == LocalPlayer then return end
    
    if not Drawing then return end -- Guard against missing Drawing lib
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Settings.Visuals.ESP.Color
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    
    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Settings.Visuals.ESP.Color
    Name.Size = 14
    Name.Center = true
    Name.Outline = true
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Settings.Visuals.ESP.Color
    Tracer.Thickness = 1
    Tracer.Transparency = 1
    ESP_Holders[Plr] = {Box = Box, Name = Name, Tracer = Tracer}
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if not Plr.Parent or not ESP_Holders[Plr] then
            Box:Remove()
            Name:Remove()
            Tracer:Remove()
            Connection:Disconnect()
            return
        end
        -- Checks
        if Settings.Visuals.ESP.Enabled and IsAlive(Plr) then
            local HRP = Plr.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
            
            -- Determine Color
            local UseColor = Settings.Visuals.ESP.Color
            if Settings.Visuals.ESP.TeamColor then
                if IsEnemy(Plr) then
                    UseColor = Settings.Visuals.ESP.EnemyColor
                else
                    UseColor = Settings.Visuals.ESP.AllyColor
                end
            end
            if OnScreen then
                -- ... Box Math ...
                local Size = Vector3.new(2, 3, 0) * (Camera.CFrame.Position - HRP.Position).Magnitude
                local PartSize = Plr.Character:GetExtentsSize()
                local SizeY = 2500 / Pos.Z
                local SizeX = SizeY / 2
                local TopLeft = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                local BottomRight = Vector2.new(Pos.X + SizeX / 2, Pos.Y + SizeY / 2)
                if Settings.Visuals.ESP.Boxes then
                    Box.Visible = true
                    Box.Size = Vector2.new(SizeX, SizeY)
                    Box.Position = TopLeft
                    Box.Color = UseColor
                else
                    Box.Visible = false
                end
                if Settings.Visuals.ESP.Names then
                    Name.Visible = true
                    Name.Text = Plr.Name
                    Name.Position = Vector2.new(Pos.X, Pos.Y - SizeY / 2 - 15)
                    Name.Color = UseColor
                else
                    Name.Visible = false
                end
                
                if Settings.Visuals.ESP.Tracers then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y)
                    Tracer.Color = UseColor
                else
                    Tracer.Visible = false
                end
                -- [NEW] Sixth Sense (Radar Pulse)
                if Settings.Visuals.SixthSense and IsEnemy(Plr) then
                     local Dist = (LocalPlayer.Character.HumanoidRootPart.Position - HRP.Position).Magnitude
                     if Dist < 100 then
                         -- Draw a warning circle or text?
                         -- Re-using Name drawing for "DETECTED" if close?
                         -- Let's just create a Highlight if not exists for "Wallhack" feel or change Tracer color
                         Tracer.Color = Color3.fromRGB(255, 0, 0) -- Force Red Tracer if close
                         Tracer.Thickness = 3
                     end
                end
                
            else
                Box.Visible = false
                Name.Visible = false
                Tracer.Visible = false
            end
            
            -- [NEW] Danger Lines (Offscreen protection too)
            if Settings.Visuals.DangerLines and IsEnemy(Plr) then
                 -- Check if looking at us
                 local Look = HRP.CFrame.LookVector
                 local Dir = (LocalPlayer.Character.HumanoidRootPart.Position - HRP.Position).Unit
                 local Dot = Look:Dot(Dir)
                 
                 if Dot > 0.8 then -- They are looking roughly at us
                      -- Draw Line from them to us
                      -- We need a World Line? Drawing API is 2D.
                      -- We can use Part or Beam?
                      -- Or just 2D Line if on screen.
                      -- Let's use a Beam instance for cool anime effect "Killing Intent"
                      if not Plr.Character:FindFirstChild("DangerBeam") then
                          local Att0 = Instance.new("Attachment", HRP)
                          local Att1 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
                          Att1.Name = "DangerAtt"
                          local Beam = Instance.new("Beam", HRP)
                          Beam.Name = "DangerBeam"
                          Beam.Attachment0 = Att0
                          Beam.Attachment1 = Att1
                          Beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                          Beam.FaceCamera = true
                          Beam.Width0 = 0.5
                          Beam.Width1 = 0.5
                          Beam.Texture = "rbxassetid://446111271" -- Laser beam texture
                          Beam.TextureSpeed = 2
                      end
                 else
                      if Plr.Character:FindFirstChild("DangerBeam") then
                          Plr.Character.DangerBeam:Destroy()
                      end
                 end
            end
            
            -- [NEW] Player Chams (Box Adornment) [FIX]
            if Settings.Visuals.Chams then
                -- Apply BoxHandleAdornment (AlwaysOnTop)
                -- We iterate parts to attach adornments
                for _, part in pairs(Plr.Character:GetChildren()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                         if not part:FindFirstChild("SakuraChamBox") then
                             local Cham = Instance.new("BoxHandleAdornment")
                             Cham.Name = "SakuraChamBox"
                             Cham.Parent = part
                             Cham.Adornee = part
                             Cham.AlwaysOnTop = true
                             Cham.ZIndex = 5
                             Cham.Size = part.Size
                             Cham.Color3 = UseColor
                             Cham.Transparency = 0.5
                         else
                             -- Update Color
                             part.SakuraChamBox.Color3 = UseColor
                         end
                    end
                end
            else
                 -- Remove Adornments
                 for _, part in pairs(Plr.Character:GetChildren()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        if part:FindFirstChild("SakuraChamBox") then
                            part.SakuraChamBox:Destroy()
                        end
                        -- Reset Material just in case from previous version
                        if part.Material == Enum.Material.ForceField then
                             part.Material = Enum.Material.Plastic
                        end
                    end
                end
            end
            
        else
            Box.Visible = false
            Name.Visible = false
            Tracer.Visible = false
        end
    end)
    table.insert(getgenv().SakuraConnections, Connection)
end
for _, v in pairs(Players:GetPlayers()) do DrawESP(v) end
table.insert(getgenv().SakuraConnections, Players.PlayerAdded:Connect(DrawESP))
-- Movement
table.insert(getgenv().SakuraConnections, RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if Humanoid then
        -- WalkSpeed
        if Settings.Movement.Speed ~= 16 then
            Humanoid.WalkSpeed = Settings.Movement.Speed
        end
        if Settings.Movement.Jump ~= 50 then
            Humanoid.JumpPower = Settings.Movement.Jump
        end
        
        -- Auto Bhop (Updated Logic)
        if Settings.Movement.Bhop then
            if Humanoid.FloorMaterial == Enum.Material.Air then
                -- In air, nothing
            else
                -- On ground, if moving, jump
                if Humanoid.MoveDirection.Magnitude > 0 then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end))
-- Removed separate JumpRequest listener as forcing state in RenderStepped is stronger for Bhop
-- SpinBot
table.insert(getgenv().SakuraConnections, RunService.RenderStepped:Connect(function()
    if Settings.Rage.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end
    
    -- Force Third Person (Aggressive)
    if Settings.Visuals.ForceThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = 100
        LocalPlayer.CameraMinZoomDistance = 10 -- Force camera out
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
    else
        -- Optional: Reset to default if disabled? 
        -- Hard to know game defaults, so we leave it unless explicitly disabled.
        -- But to fix "stuck" controls, maybe reset MinZoom?
        -- LocalPlayer.CameraMinZoomDistance = 0.5 
    end
    -- Mouse Lock (Force Camera Movement)
    if Settings.MouseLock then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end))
-- // Anime FX Logic
local Blur = Instance.new("BlurEffect")
Blur.Parent = game:GetService("Lighting")
Blur.Size = 0
Blur.Enabled = false
local function CreateAfterimage()
    local Char = LocalPlayer.Character
    if not Char then return end
    
    Char.Archivable = true
    local Clone = Char:Clone()
    if not Clone then return end
    
    Clone.Parent = workspace
    Clone.Name = "Afterimage"
    for _, part in pairs(Clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = true
            part.Material = Enum.Material.ForceField
            part.Color = Settings.Visuals.ESP.TeamColor and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 100, 255) -- Red/Blue based on context? Or just Accent
            part.Transparency = 0.5
            game:GetService("TweenService"):Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
        elseif part:IsA("Script") or part:IsA("LocalScript") or part:IsA("Sound") then
            part:Destroy()
        end
    end
    -- Remove Head/Face features for cleaner look?
    game.Debris:AddItem(Clone, 0.5)
end
local LastImage = 0
table.insert(getgenv().SakuraConnections, RunService.RenderStepped:Connect(function()
    -- Motion Blur Anime
    if Settings.Illusions.MotionBlur then
        Blur.Enabled = true
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local Vel = LocalPlayer.Character.HumanoidRootPart.Velocity.Magnitude
            Blur.Size = math.clamp(Vel / 5, 0, 20)
        end
    else
        Blur.Enabled = false
    end
    
    -- Afterimage Trail
    if Settings.Illusions.AfterimageTrail then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
             if LocalPlayer.Character.HumanoidRootPart.Velocity.Magnitude > 20 and tick() - LastImage > (Settings.Illusions.TrailDuration or 0.1) then
                 CreateAfterimage()
                 LastImage = tick()
             end
        end
    end
    
    -- Zen Focus (Zoom + Vignette)
    if Settings.FocusSystem.ZenFocus then
        Camera.FieldOfView = 60 -- Slight zoom
    else
        if not Settings.Awakening.FinalResolve then -- Don't interfere with kill effects
            Camera.FieldOfView = 70 -- Default
        end
    end
end))
-- [BLADE  CROSSHAIR]
local BladeCrosshair = nil
if not BladeCrosshair then
    BladeCrosshair = Drawing.new("Triangle")
    BladeCrosshair.Visible = false
    BladeCrosshair.Thickness = 2
    BladeCrosshair.Filled = false
end
local BladeCrosshair2 = Drawing.new("Triangle")
BladeCrosshair2.Visible = false
BladeCrosshair2.Thickness = 2
BladeCrosshair2.Filled = false
local CrosshairRotation = 0
table.insert(getgenv().SakuraConnections, RunService.RenderStepped:Connect(function()
    if Settings.WeaponSoul.BladeCrosshair then
        local Center = UserInputService:GetMouseLocation()
        local Size = 15
        CrosshairRotation = CrosshairRotation + 2
        
        -- Triangle 1
        local Angle1 = math.rad(CrosshairRotation)
        local Angle2 = math.rad(CrosshairRotation + 120)
        local Angle3 = math.rad(CrosshairRotation + 240)
        
        BladeCrosshair.PointA = Center + Vector2.new(math.cos(Angle1) * Size, math.sin(Angle1) * Size)
        BladeCrosshair.PointB = Center + Vector2.new(math.cos(Angle2) * Size, math.sin(Angle2) * Size)
        BladeCrosshair.PointC = Center + Vector2.new(math.cos(Angle3) * Size, math.sin(Angle3) * Size)
        BladeCrosshair.Color = Library.Themes[Library.CurrentThemeName].Accent
        BladeCrosshair.Visible = true
        
        -- Triangle 2 (Inverted)
        BladeCrosshair2.PointA = Center + Vector2.new(math.cos(Angle1 + math.rad(180)) * Size * 0.6, math.sin(Angle1 + math.rad(180)) * Size * 0.6)
        BladeCrosshair2.PointB = Center + Vector2.new(math.cos(Angle2 + math.rad(180)) * Size * 0.6, math.sin(Angle2 + math.rad(180)) * Size * 0.6)
        BladeCrosshair2.PointC = Center + Vector2.new(math.cos(Angle3 + math.rad(180)) * Size * 0.6, math.sin(Angle3 + math.rad(180)) * Size * 0.6)
        BladeCrosshair2.Color = Library.Themes[Library.CurrentThemeName].Accent
        BladeCrosshair2.Visible = true
        
        UserInputService.MouseIconEnabled = false
    else
        BladeCrosshair.Visible = false
        BladeCrosshair2.Visible = false
        if not Settings.Cursor.Enabled then
            UserInputService.MouseIconEnabled = true
        end
    end
end))
-- [INSTINCT LINE]
local InstinctLine = Drawing.new("Line")
InstinctLine.Thickness = 1
InstinctLine.Transparency = 0.5
table.insert(getgenv().SakuraConnections, RunService.RenderStepped:Connect(function()
    if Settings.FocusSystem.InstinctLine then
        local ViewportSize = Camera.ViewportSize
        local CenterX = ViewportSize.X / 2
        
        InstinctLine.From = Vector2.new(CenterX, 0)
        InstinctLine.To = Vector2.new(CenterX, ViewportSize.Y)
        InstinctLine.Color = Library.Themes[Library.CurrentThemeName].Accent
        InstinctLine.Visible = true
    else
        InstinctLine.Visible = false
    end
end))
    
    -- Recoil Spirit / Weapon Chams / Streamer / Invisible
    if Settings.Visuals.WeaponChams or Settings.Visuals.RecoilSpirit then
        for _, v in pairs(workspace.CurrentCamera:GetDescendants()) do 
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                 -- 1. Weapon Chams (Wireframe/Adornment) [FIX]
                 if Settings.Visuals.WeaponChams then
                      if not v:FindFirstChild("WeaponCham") then
                          local Cham = Instance.new("BoxHandleAdornment")
                          Cham.Name = "WeaponCham"
                          Cham.Parent = v
                          Cham.Adornee = v
                          Cham.AlwaysOnTop = true
                          Cham.ZIndex = 5
                          Cham.Size = v.Size
                          Cham.Color3 = Color3.fromRGB(255, 105, 180)
                          Cham.Transparency = 0.5
                      end
                 else
                      if v:FindFirstChild("WeaponCham") then
                          v.WeaponCham:Destroy()
                      end
                 end
                 
                 -- 2. Recoil Spirit (Trail)
                 if Settings.Visuals.RecoilSpirit and not v:FindFirstChild("SpiritTrail") then
                      local Att0 = Instance.new("Attachment", v)
                      Att0.Position = Vector3.new(0, 0.5, 0)
                      local Att1 = Instance.new("Attachment", v)
                      Att1.Position = Vector3.new(0, -0.5, 0)
                      local T = Instance.new("Trail", v)
                      T.Name = "SpiritTrail"
                      T.Attachment0 = Att0
                      T.Attachment1 = Att1
                      T.Color = ColorSequence.new(Color3.fromRGB(200, 100, 255))
                      T.Lifetime = 0.3
                      T.Transparency = NumberSequence.new(0.5, 1)
                 end
            end
        end
    end
    -- Streamer Mode (Hide Nick/UI) & Invisible Mode
    if LocalPlayer.Character then
        -- Streamer Mode
        if Settings.Visuals.StreamerMode then
            local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if Hum then Hum.DisplayName = "YOU" end
            -- Hide Overhead GUI
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BillboardGui") or v:IsA("SurfaceGui") or v:IsA("TextLabel") then
                    v.Visible = false
                end
            end
        end
        
        -- Invisible Mode (Hide Body completely)
        if Settings.Visuals.Invisible then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
        end
        
        -- Kill Effects Check (Alternative Logic)
        -- Monitor Health Drop for Impact?
        -- For now, rely on MonitorDeath loop below.
    end
end))
-- Helper for Silent Aim Hook
local function GetSilentTarget()
    if not Settings.Combat.SilentAim.Enabled then return nil end
    return GetClosestPlayer()
end
-- Hook Mouse.Hit / Mouse.Target for True Silent Aim
-- This requires executor support (hookmetamethod). We wrap in pcall.
pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, k)
        if (k == "Hit" or k == "Target") and self == Mouse then
            local Target = GetSilentTarget()
            if Target then
                if k == "Hit" then
                    return Target.CFrame
                elseif k == "Target" then
                    return Target
                end
            end
        end
        return oldIndex(self, k)
    end)
    
    setreadonly(mt, true)
end)
-- Kill Sound Listener
-- This is heuristic: if a death logic triggers nearby or if we can track kills.
-- Simply playing a sound when requested for now, or on key press, or when `LocalPlayer` kills someone (requires game specific Leaderstats usually)
-- For generic script:
Players.PlayerRemoving:Connect(function(plr)
    -- This fires when someone leaves, not dies. 
end)
-- Kill Effects Logic (COMPREHENSIVE)
local KillPanelFrame = nil
local function TriggerKillEffects()
    -- ALL EFFECTS ARE PURELY VISUAL - NO PHYSICS
    
    -- 1. Kill Flash (Screen Flash)
    if Settings.WeaponSoul.KillFlash then
        local Flash = Instance.new("Frame")
        Flash.Name = "KillFlash"
        Flash.Parent = UI
        Flash.Size = UDim2.new(1, 0, 1, 0)
        Flash.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Pink flash
        Flash.BorderSizePixel = 0
        Flash.ZIndex = 10
        Flash.BackgroundTransparency = 0.3
        
        TweenService:Create(Flash, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        game.Debris:AddItem(Flash, 0.3)
    end
    
    -- 2. Screen Shake Impact
    if Settings.Illusions.ScreenShake then
        local ShakeIntensity = 0.5
        local ShakeDuration = 0.15
        local Start = tick()
        task.spawn(function()
            local OriginalCF = Camera.CFrame
            while tick() - Start < ShakeDuration do
                local Offset = Vector3.new(
                    math.random(-100, 100) / 100,
                    math.random(-100, 100) / 100,
                    math.random(-100, 100) / 100
                ) * ShakeIntensity
                Camera.CFrame = Camera.CFrame * CFrame.new(Offset * 0.05)
                RunService.RenderStepped:Wait()
            end
        end)
    end
    
    -- 3. Manga Kill Panel
    if Settings.Illusions.MangaPanel then
        if not KillPanelFrame then
             KillPanelFrame = Instance.new("Frame")
             KillPanelFrame.Name = "MangaPanel"
             KillPanelFrame.Parent = UI
             KillPanelFrame.Size = UDim2.new(1, 0, 0.35, 0)
             KillPanelFrame.Position = UDim2.new(0, 0, 0.325, 0)
             KillPanelFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
             KillPanelFrame.BorderSizePixel = 0
             KillPanelFrame.BackgroundTransparency = 1
             KillPanelFrame.ZIndex = 9
             
             local TopBar = Instance.new("Frame", KillPanelFrame)
             TopBar.Size = UDim2.new(1, 0, 0, 4)
             TopBar.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
             TopBar.BorderSizePixel = 0
             
             local BottomBar = Instance.new("Frame", KillPanelFrame)
             BottomBar.Size = UDim2.new(1, 0, 0, 4)
             BottomBar.Position = UDim2.new(0, 0, 1, -4)
             BottomBar.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
             BottomBar.BorderSizePixel = 0
             
             local Text = Instance.new("TextLabel", KillPanelFrame)
             Text.Size = UDim2.new(1, 0, 1, 0)
             Text.BackgroundTransparency = 1
             Text.Text = "ELIMINATED"
             Text.Font = Enum.Font.FredokaOne
             Text.TextSize = 70
             Text.TextColor3 = Color3.fromRGB(255, 255, 255)
             Text.TextStrokeTransparency = 0
             Text.TextStrokeColor3 = Color3.fromRGB(255, 105, 180)
        end
        
        KillPanelFrame.Visible = true
        KillPanelFrame.BackgroundTransparency = 0.1
        TweenService:Create(KillPanelFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        task.delay(0.6, function() 
            if KillPanelFrame then
                KillPanelFrame.Visible = false 
            end
        end)
    end
    
    -- 4. Particle Explosion at Kill Location
    if Settings.WeaponSoul.ImpactBloom and CurrentTargetPlr and CurrentTargetPlr.Character then
        local HRP = CurrentTargetPlr.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            -- Particle effects (purely visual)
            for i = 1, 20 do
                local Part = Instance.new("Part")
                Part.Size = Vector3.new(0.2, 0.2, 0.2)
                Part.Position = HRP.Position + Vector3.new(
                    math.random(-3, 3),
                    math.random(0, 3),
                    math.random(-3, 3)
                )
                Part.Color = Color3.fromRGB(255, 105, 180)
                Part.Material = Enum.Material.Neon
                Part.Anchored = true
                Part.CanCollide = false
                Part.CanQuery = false
                Part.CanTouch = false
                Part.Massless = true
                Part.CastShadow = false
                Part.Parent = workspace
                
                local Velocity = Vector3.new(
                    math.random(-10, 10),
                    math.random(5, 15),
                    math.random(-10, 10)
                )
                
                task.spawn(function()
                    for _ = 1, 30 do
                        Part.Position = Part.Position + (Velocity * 0.05)
                        Velocity = Velocity - Vector3.new(0, 0.5, 0) -- Gravity
                        Part.Transparency = Part.Transparency + 0.033
                        RunService.Heartbeat:Wait()
                    end
                    Part:Destroy()
                end)
            end
        end
    end
    
    -- 5. Hitmarker Sound
    if Settings.Misc.KillSound then
        local Sound = Instance.new("Sound")
        Sound.SoundId = Settings.Misc.SoundID
        Sound.Volume = 1.5
        Sound.Parent = workspace
        Sound:Play()
        game.Debris:AddItem(Sound, 2)
    end
    
    -- 6. Slow-Mo Effect (Visual only - affects camera FOV)
    if Settings.Awakening.FinalResolve then
        local OriginalFOV = Camera.FieldOfView
        TweenService:Create(Camera, TweenInfo.new(0.1), {FieldOfView = OriginalFOV - 10}):Play()
        task.delay(0.2, function()
            TweenService:Create(Camera, TweenInfo.new(0.3), {FieldOfView = OriginalFOV}):Play()
        end)
    end
    
    -- 7. Blood Oath Mode (Red Screen Pulse)
    if Settings.Awakening.BloodOath then
        local RedPulse = Instance.new("Frame")
        RedPulse.Name = "BloodPulse"
        RedPulse.Parent = UI
        RedPulse.Size = UDim2.new(1, 0, 1, 0)
        RedPulse.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        RedPulse.BorderSizePixel = 0
        RedPulse.ZIndex = 8
        RedPulse.BackgroundTransparency = 0.7
        
        TweenService:Create(RedPulse, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        game.Debris:AddItem(RedPulse, 0.4)
    end
end
-- Kill Switch
local function MonitorDeath(Plr)
    if Plr == LocalPlayer then return end
    local function CharAdded(Char)
        local Hum = Char:WaitForChild("Humanoid", 10)
        if Hum then
            Hum.Died:Connect(function()
                 local IsTarget = (CurrentTargetPlr == Plr)
                 local IsClose = false
                 
                 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Char:FindFirstChild("HumanoidRootPart") then
                      local Dist = (LocalPlayer.Character.HumanoidRootPart.Position - Char.HumanoidRootPart.Position).Magnitude
                      if Dist < 250 then IsClose = true end
                 end
                 
                 if IsTarget or IsClose then
                      if Settings.Misc.KillSound then
                           local Sound = Instance.new("Sound", workspace)
                           Sound.SoundId = Settings.Misc.SoundID
                           Sound.Volume = 2
                           Sound:Play()
                           game.Debris:AddItem(Sound, 2)
                      end
                      TriggerKillEffects()
                 end
            end)
        end
    end
    if Plr.Character then CharAdded(Plr.Character) end
    Plr.CharacterAdded:Connect(CharAdded)
end
-- Impact FX (Sakura/Explosion on Click)
table.insert(getgenv().SakuraConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.Visuals.ImpactFX then
        local Mouse = LocalPlayer:GetMouse()
        if Mouse.Target then
            local Part = Instance.new("Part", workspace)
            Part.Anchored = true
            Part.CanCollide = false
            Part.Transparency = 1
            Part.Position = Mouse.Hit.Position
            Part.Size = Vector3.new(1,1,1)
            
            -- Sakura Particle
            local P = Instance.new("ParticleEmitter", Part)
            P.Texture = "rbxassetid://6065765799" 
            P.Color = ColorSequence.new(Color3.fromRGB(255, 105, 180))
            P.Size = NumberSequence.new(0.5, 0)
            P.Lifetime = NumberSequence.new(0.5, 1)
            P.Speed = NumberRange.new(5, 10)
            P.SpreadAngle = Vector2.new(360, 360)
            P.Rate = 0
            P:Emit(20)
            
            game.Debris:AddItem(Part, 2)
        end
    end
end))
for _, v in pairs(Players:GetPlayers()) do MonitorDeath(v) end
table.insert(getgenv().SakuraConnections, Players.PlayerAdded:Connect(MonitorDeath))
-- Custom Cursor Logic
local CustomCursor = Instance.new("ImageLabel")
CustomCursor.Name = "CustomCursor"
CustomCursor.Parent = UI
CustomCursor.BackgroundTransparency = 1
CustomCursor.Size = UDim2.new(0, 64, 0, 64)
CustomCursor.Image = Settings.Cursor.ID
CustomCursor.Visible = false
CustomCursor.AnchorPoint = Vector2.new(0.5, 0.5)
CustomCursor.ZIndex = 100 -- Topmost
CustomCursor.Active = false
table.insert(getgenv().SakuraConnections, RunService.RenderStepped:Connect(function()
    if Settings.Cursor.Enabled then
        CustomCursor.Visible = true
        UserInputService.MouseIconEnabled = false -- Hide default mouse
        
        -- Smart Position Logic
        local AimbotTarget = nil
        -- Check if Aimbot is actively locking (Key Held + Enabled)
        local KeyPressed = false
        if Settings.Combat.Aimbot.Key.EnumType == Enum.UserInputType then
            if UserInputService:IsMouseButtonPressed(Settings.Combat.Aimbot.Key) then KeyPressed = true end
        else
            if UserInputService:IsKeyDown(Settings.Combat.Aimbot.Key) then KeyPressed = true end
        end
        
        if Settings.Combat.SilentAim.Enabled then
             local Target = GetClosestPlayer()
             if Target then
                -- Visual Lock logic 
                local Pos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                if OnScreen then
                    CustomCursor.Position = UDim2.new(0, Pos.X, 0, Pos.Y)
                end
             else
                -- Fallback to Mouse
                if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                    CustomCursor.Position = UDim2.new(0.5, 0, 0.5, 0)
                else
                     local MousePos = UserInputService:GetMouseLocation()
                     local Inset = game:GetService("GuiService"):GetGuiInset()
                     CustomCursor.Position = UDim2.new(0, MousePos.X, 0, MousePos.Y - Inset.Y)
                end
             end
        elseif UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            -- Initial Center Position (Crosshair Mode)
            CustomCursor.Position = UDim2.new(0.5, 0, 0.5, 0)
        else
            -- Follow Mouse (Menu/UI Mode)
            local MousePos = UserInputService:GetMouseLocation()
            local Inset = game:GetService("GuiService"):GetGuiInset()
            CustomCursor.Position = UDim2.new(0, MousePos.X, 0, MousePos.Y - Inset.Y)
        end
        
        -- Rotate
        CustomCursor.Rotation = (tick() * Settings.Cursor.SpinSpeed * 50) % 360
        
        -- Resize dynamically if needed
        CustomCursor.Size = UDim2.new(0, Settings.Cursor.Size, 0, Settings.Cursor.Size)
    else
        CustomCursor.Visible = false
        UserInputService.MouseIconEnabled = true
    end
end))
-- // Initialize UI
local Win = Library:CreateWindow("AWAKEN.EXE")
-- [Combat Tab]
local CombatTab = Win:Tab("Combat")
CombatTab:Toggle("Legit Aimbot", function(v) Settings.Combat.Aimbot.Enabled = v end)
CombatTab:Keybind("Aimbot Key", Settings.Combat.Aimbot.Key, Settings.Combat.Aimbot.KeyName, function(key, name)
    Settings.Combat.Aimbot.Key = key
    Settings.Combat.Aimbot.KeyName = name
end)
-- New Modes
Settings.Combat.Aimbot.InputMode = "Hold"
Settings.Combat.Aimbot.Mode360 = false
CombatTab:Toggle("Use Toggle Mode", function(v) 
    if v then Settings.Combat.Aimbot.InputMode = "Toggle" else Settings.Combat.Aimbot.InputMode = "Hold" end 
end)
-- [NEW] Target Part Selector (Simple Toggle for now)
CombatTab:Toggle("Aim at HEAD (Off = Torso)", function(v)
    if v then
        Settings.Combat.TargetPart = "Head"
    else
        Settings.Combat.TargetPart = "HumanoidRootPart"
    end
end)
-- Force "Head" default visual state? 
-- The UI toggle doesn't support setting default visual state in this simple lib easily without triggering callback.
-- We'll assume user will click it. Or we set default in Settings to "Head" (it is) and user can toggle off.
CombatTab:Toggle("360 Mode (Ignore FOV)", function(v) Settings.Combat.Aimbot.Mode360 = v end)
CombatTab:Slider("Smoothness", 0, 1, 0.1, function(v) Settings.Combat.Aimbot.Smoothing = v end)
CombatTab:Slider("FOV Radius", 50, 500, 150, function(v) Settings.Combat.FOV = v end)
CombatTab:Toggle("Silent Aim (Visual)", function(v) Settings.Combat.SilentAim.Enabled = v end)
CombatTab:Toggle("Trigger Bot", function(v) Settings.Combat.TriggerBot.Enabled = v end)
CombatTab:Slider("Trigger Delay", 0, 1, 0.1, function(v) Settings.Combat.TriggerBot.Delay = v end)
CombatTab:Toggle("Wall Check", function(v) Settings.Combat.WallCheck = v end)
CombatTab:Toggle("Team Check", function(v) Settings.Combat.TeamCheck = v end)
-- [Rage Tab]
local RageTab = Win:Tab("Rage")
RageTab:Toggle("Spin Bot", function(v) Settings.Rage.SpinBot = v end)
-- [Visuals Tab]
local VisualsTab = Win:Tab("Visuals")
VisualsTab:Toggle("Enable ESP", function(v) Settings.Visuals.ESP.Enabled = v end)
VisualsTab:Toggle("Draw Boxes", function(v) Settings.Visuals.ESP.Boxes = v end)
VisualsTab:Toggle("Draw Names", function(v) Settings.Visuals.ESP.Names = v end)
VisualsTab:Toggle("Draw Tracers", function(v) Settings.Visuals.ESP.Tracers = v end)
VisualsTab:Toggle("Use Team Colors", function(v) Settings.Visuals.ESP.TeamColor = v end)
-- [NEW] Streamer / Identity
VisualsTab:Toggle("Streamer Mode (Hide Nick)", function(v) 
    Settings.Visuals.StreamerMode = v 
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.DisplayName = "YOU"
    end
end)
VisualsTab:Toggle("Invisible (Hide Body/Arms)", function(v) Settings.Visuals.Invisible = v end)
VisualsTab:Toggle("Force 3rd Person", function(v) Settings.Visuals.ForceThirdPerson = v end)
VisualsTab:Toggle("Player Chams (Glow)", function(v) Settings.Visuals.Chams = v end)
VisualsTab:Toggle("Weapon Chams", function(v) Settings.Visuals.WeaponChams = v end)
-- [Anime FX Tab] (New!)
local AnimeTab = Win:Tab("Anime FX")
AnimeTab:Toggle("Afterimage", function(v) Settings.Visuals.Afterimage = v end)
AnimeTab:Toggle("Motion Blur", function(v) Settings.Visuals.MotionBlur = v end)
AnimeTab:Toggle("Screen Shake (Kill)", function(v) Settings.Visuals.ScreenShake = v end)
AnimeTab:Toggle("Manga Kill Panel", function(v) Settings.Visuals.KillPanel = v end)
AnimeTab:Toggle("Sixth Sense (Radar)", function(v) Settings.Visuals.SixthSense = v end)
AnimeTab:Toggle("Danger Lines", function(v) Settings.Visuals.DangerLines = v end)
AnimeTab:Toggle("Recoil Spirit", function(v) Settings.Visuals.RecoilSpirit = v end)
AnimeTab:Toggle("Impact FX (Sakura)", function(v) Settings.Visuals.ImpactFX = v end)
-- [Movement Tab]
local MovementTab = Win:Tab("Movement")
MovementTab:Toggle("Auto Bhop", function(v) Settings.Movement.Bhop = v end)
MovementTab:Slider("Walk Speed", 16, 200, 16, function(v) Settings.Movement.Speed = v end)
MovementTab:Slider("Jump Power", 50, 200, 50, function(v) Settings.Movement.Jump = v end)
-- [Misc Tab]
local MiscTab = Win:Tab("Misc")
MiscTab:Toggle("Force Mouse Lock", function(v) 
    Settings.MouseLock = v 
    if not v then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)
MiscTab:Toggle("Kill Sound", function(v) Settings.Misc.KillSound = v end)
MiscTab:TextBox("Sound ID", "4590657391", function(v) Settings.Misc.SoundID = ParseID(v) end)
MiscTab:Toggle("Rainbow Skin", function(v)
    getgenv().RainbowEnabled = v
    if v then
        spawn(function()
            while getgenv().RainbowEnabled do
                if LocalPlayer.Character then
                     for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)
-- [Cursor Tab]
local CursorTab = Win:Tab("Cursor")
CursorTab:Toggle("Custom Cursor", function(v) Settings.Cursor.Enabled = v end)
CursorTab:Slider("Size", 16, 128, 64, function(v) Settings.Cursor.Size = v end)
CursorTab:Slider("Spin Speed", 0, 10, 5, function(v) Settings.Cursor.SpinSpeed = v end)
CursorTab:TextBox("Image ID", "6065765799", function(v) 
    local CleanID = ParseID(v)
    Settings.Cursor.ID = CleanID
    CustomCursor.Image = CleanID
end)
-- Save/Load Config
local function SaveConfig()
    if not writefile then return end
    local json = HttpService:JSONEncode(Settings)
    writefile("SakuraConfig.json", json)
end
local function LoadConfig()
    if not isfile or not isfile("SakuraConfig.json") then return end
    local Success, Loaded = pcall(function()
        return HttpService:JSONDecode(readfile("SakuraConfig.json"))
    end)
    if not Success or not Loaded then return end
    -- Migration Logic (Old -> New)
    if Loaded.Aimbot and not Loaded.Combat then
        -- Migrating Old Config
        if Settings.Combat and Settings.Combat.Aimbot then
             Settings.Combat.Aimbot.Enabled = Loaded.Aimbot.Enabled
             Settings.Combat.Aimbot.Key = Loaded.Aimbot.Key
             Settings.Combat.Aimbot.KeyName = Loaded.Aimbot.KeyName
             Settings.Combat.Aimbot.Smoothing = Loaded.Aimbot.Smoothing
             Settings.Combat.Aimbot.FOV = Loaded.Aimbot.FOV
             Settings.Combat.Aimbot.TargetPart = Loaded.Aimbot.TargetPart
        end
        if Loaded.ESP and Settings.Visuals and Settings.Visuals.ESP then
             Settings.Visuals.ESP.Enabled = Loaded.ESP.Enabled
             Settings.Visuals.ESP.Boxes = Loaded.ESP.Boxes
             Settings.Visuals.ESP.Names = Loaded.ESP.Names
             Settings.Visuals.ESP.Color = Loaded.ESP.Color
        end
    else
        -- Modern Config: Recursive Merge
        local function MergeTable(Target, Source)
            for k, v in pairs(Source) do
                if type(v) == "table" and type(Target[k]) == "table" then
                    MergeTable(Target[k], v)
                else
                    Target[k] = v
                end
            end
        end
        MergeTable(Settings, Loaded)
    end
    
    -- Apply Theme Extras
    if Settings.Theme.Background ~= "" then
        Win:SetBackground(Settings.Theme.Background)
    else
        Win:SetBackground(nil)
    end
    if Settings.Cursor.ID and CustomCursor then
        CustomCursor.Image = Settings.Cursor.ID
    end
    if Settings.MouseLock ~= nil then 
        -- Handled by Loop 
    end
end
-- [Settings Tab]
local SettingsTab = Win:Tab("Settings")
SettingsTab:Keybind("Menu Toggle Key", Settings.Theme.MenuKey, Settings.Theme.MenuKeyName, function(key, name)
    Settings.Theme.MenuKey = key
    Settings.Theme.MenuKeyName = name
end)
SettingsTab:TextBox("Background Image ID", "", function(v)
    if v == "" then
        Win:SetBackground(nil)
        Settings.Theme.Background = ""
    else
        local CleanID = ParseID(v)
        Win:SetBackground(CleanID)
        Settings.Theme.Background = CleanID
    end
end)
SettingsTab:Toggle("Unload Script", function(v)
    if v then
        Win:Destroy()
    end
end)
SettingsTab:Toggle("Save Config (Click)", function(v)
    if v then
        SaveConfig()
    end
end)
SettingsTab:Toggle("Load Config (Click)", function(v)
    if v then
        LoadConfig()
    end
end)
-- ========================================
-- RAGE FEATURES
-- ========================================
-- Rapid Fire
local LastRapidClick = 0
local RapidFireConn = RunService.Heartbeat:Connect(function()
    if not Settings.Rage.RapidFire then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    
    local Now = tick()
    local Interval = 1 / Settings.Rage.RapidFireCPS
    
    if Now - LastRapidClick >= Interval then
        LastRapidClick = Now
        mouse1click()
    end
end)
table.insert(getgenv().SakuraConnections, {Disconnect = function() RapidFireConn:Disconnect() end})
-- Fly Mode
local Flying = false
local FlyConn = nil
local function StartFlying()
    if Flying then return end
    Flying = true
    
    local BV = Instance.new("BodyVelocity")
    BV.Parent = LocalPlayer.Character.HumanoidRootPart
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    FlyConn = RunService.Heartbeat:Connect(function()
        if not Settings.Rage.FlyMode or not LocalPlayer.Character then
            if BV then BV:Destroy() end
            Flying = false
            if FlyConn then FlyConn:Disconnect() end
            return
        end
        
        local Speed = Settings.Rage.FlySpeed
        local Velocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            Velocity = Velocity + Camera.CFrame.LookVector * Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            Velocity = Velocity - Camera.CFrame.LookVector * Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            Velocity = Velocity + Camera.CFrame.RightVector * Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            Velocity = Velocity - Camera.CFrame.RightVector * Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Velocity = Velocity + Vector3.new(0, Speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            Velocity = Velocity - Vector3.new(0, Speed, 0)
        end
        
        BV.Velocity = Velocity
    end)
end
task.spawn(function()
    while task.wait(0.5) do
        if Settings.Rage.FlyMode and not Flying and LocalPlayer.Character then
            pcall(StartFlying)
        end
    end
end)
-- Noclip
local NoclipConn = RunService.Stepped:Connect(function()
    if not Settings.Rage.Noclip then return end
    if not LocalPlayer.Character then return end
    
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)
table.insert(getgenv().SakuraConnections, {Disconnect = function() NoclipConn:Disconnect() end})
-- ========================================
-- UTILITIES
-- ========================================
-- Fullbright & Remove Fog
local OriginalBrightness = game.Lighting.Brightness
local OriginalFogEnd = game.Lighting.FogEnd
local LightingConn = RunService.Heartbeat:Connect(function()
    if Settings.Misc.Fullbright then
        game.Lighting.Brightness = 5
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
    
    if Settings.Misc.RemoveFog then
        game.Lighting.FogEnd = 9e9
    end
end)
table.insert(getgenv().SakuraConnections, {Disconnect = function() 
    LightingConn:Disconnect()
    game.Lighting.Brightness = OriginalBrightness
    game.Lighting.FogEnd = OriginalFogEnd
end})
-- FOV Changer
local OriginalFOV = Camera.FieldOfView
local FOVConn = RunService.RenderStepped:Connect(function()
    if Settings.Misc.FOVChanger ~= 70 then
        Camera.FieldOfView = Settings.Misc.FOVChanger
    end
end)
table.insert(getgenv().SakuraConnections, {Disconnect = function() 
    FOVConn:Disconnect()
    Camera.FieldOfView = OriginalFOV
end})
-- Watermark & FPS Counter
local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Parent = UI
WatermarkLabel.Size = UDim2.new(0, 350, 0, 30)
WatermarkLabel.Position = UDim2.new(0, 10, 0, 10)
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.TextSize = 16
WatermarkLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
WatermarkLabel.TextStrokeTransparency = 0
WatermarkLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WatermarkLabel.ZIndex = 999
local LastFrameTime = tick()
local CurrentFPS = 60
task.spawn(function()
    while task.wait(0.5) do
        local Now = tick()
        CurrentFPS = math.floor(1 / (Now - LastFrameTime + 0.001))
        LastFrameTime = Now
        
        if Settings.Misc.Watermark then
            local text = "✦ AWAKEN.EXE"
            if Settings.Misc.FPSCounter then
                text = text .. " | FPS: " .. tostring(CurrentFPS)
            end
            if Settings.Misc.VelocityMeter and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local Vel = LocalPlayer.Character.HumanoidRootPart.Velocity.Magnitude
                text = text .. " | " .. tostring(math.floor(Vel)) .. " studs/s"
            end
            WatermarkLabel.Text = text
            WatermarkLabel.Visible = true
        else
            WatermarkLabel.Visible = false
        end
    end
end)
-- Coordinate Display
local CoordLabel = Instance.new("TextLabel")
CoordLabel.Parent = UI
CoordLabel.Size = UDim2.new(0, 200, 0, 20)
CoordLabel.Position = UDim2.new(1, -210, 0, 10)
CoordLabel.BackgroundTransparency = 1
CoordLabel.Font = Enum.Font.Code
CoordLabel.TextSize = 14
CoordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CoordLabel.TextStrokeTransparency = 0
CoordLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
CoordLabel.TextXAlignment = Enum.TextXAlignment.Right
CoordLabel.ZIndex = 999
task.spawn(function()
    while task.wait(0.1) do
        if Settings.Misc.CoordinateDisplay and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local Pos = LocalPlayer.Character.HumanoidRootPart.Position
            CoordLabel.Text = string.format("X: %d Y: %d Z: %d", math.floor(Pos.X), math.floor(Pos.Y), math.floor(Pos.Z))
            CoordLabel.Visible = true
        else
            CoordLabel.Visible = false
        end
    end
end)
-- ========================================
-- STATS SYSTEM
-- ========================================
Settings.Stats.SessionStart = tick()
-- Death detection
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.Stats.Enabled then
        Settings.Stats.Deaths = Settings.Stats.Deaths + 1
        Settings.Stats.KillStreak = 0
    end
end)
-- ========================================
-- PANIC MODE
-- ========================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.Misc.PanicKey then
        print("[AWAKEN] PANIC MODE ACTIVATED!")
        
        -- Disable everything critical
        Settings.Combat.Aimbot.Enabled = false
        Settings.Combat.TriggerBot.Enabled = false
        Settings.Visuals.ESP.Enabled = false
        Settings.Visuals.Chams = false
        Settings.Rage.SpinBot = false
        Settings.Rage.RapidFire = false
        Settings.Rage.FlyMode = false
        Settings.Rage.Noclip = false
        Settings.Misc.Watermark = false
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "AWAKEN.EXE",
            Text = "🚨 PANIC MODE - All features disabled",
            Duration = 3
        })
    end
end)
-- ========================================
-- SCREENSHOT CLEANER (ANTI-DETECTION)
-- ========================================
local ScreenshotCleaning = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Detect screenshot keys (varies by platform/executor)
    local IsScreenshotKey = (
        input.KeyCode == Enum.KeyCode.Print or 
        input.KeyCode == Enum.KeyCode.F12 or
        (input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift))
    )
    
    if IsScreenshotKey and not ScreenshotCleaning then
        ScreenshotCleaning = true
        print("[AWAKEN] Screenshot detected - hiding visuals...")
        
        -- Store current states
        local TempStates = {
            ESPEnabled = Settings.Visuals.ESP.Enabled,
            ChamsEnabled = Settings.Visuals.Chams,
            WatermarkEnabled = Settings.Misc.Watermark,
            FOVCircleVisible = FOVCircle.Visible,
            SnapLineVisible = SnapLine.Visible
        }
        
        -- Hide everything
        Settings.Visuals.ESP.Enabled = false
        Settings.Visuals.Chams = false
        Settings.Misc.Watermark = false
        FOVCircle.Visible = false
        SnapLine.Visible = false
        
        -- Hide all ESP elements
        for _, holder in pairs(ESP_Holders) do
            if holder.Box then holder.Box.Visible = false end
            if holder.Name then holder.Name.Visible = false end
            if holder.Tracer then holder.Tracer.Visible = false end
        end
        
        -- Restore after 1 second
        task.delay(1, function()
            Settings.Visuals.ESP.Enabled = TempStates.ESPEnabled
            Settings.Visuals.Chams = TempStates.ChamsEnabled
            Settings.Misc.Watermark = TempStates.WatermarkEnabled
            ScreenshotCleaning = false
            print("[AWAKEN] Visuals restored")
        end)
    end
end)
-- ========================================
-- SAFE VALUE LIMITS (ANTI-DETECTION)
-- ========================================
-- Monitor and cap suspicious values
task.spawn(function()
    while task.wait(1) do
        -- Cap speed to reasonable values
        if Settings.Movement.Speed > 100 then
            warn("[AWAKEN] Speed capped at 100 for safety")
            Settings.Movement.Speed = 100
        end
        
        -- Cap jump to reasonable values
        if Settings.Movement.Jump > 150 then
            warn("[AWAKEN] Jump capped at 150 for safety")
            Settings.Movement.Jump = 150
        end
        
        -- Cap FOV to reasonable values
        if Settings.Misc.FOVChanger > 120 then
            Settings.Misc.FOVChanger = 120
        end
        
        -- Disable fly if too fast
        if Settings.Rage.FlySpeed > 100 then
            Settings.Rage.FlySpeed = 100
        end
    end
end)
print("✅ AWAKEN.EXE v2.1 Loaded Successfully!")
print("🛡️ Anti-Detection: Humanization, Screenshot Cleaner, Safe Limits")
print("🚨 Panic Key: DELETE")
print("📋 Menu Key: INSERT")
