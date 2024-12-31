-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- KeyAuth Configuration
local APP_NAME = "Rustpro29's Application" -- Replace with your KeyAuth Application Name
local OWNER_ID = "FQ9KIiQtnA" -- Replace with your KeyAuth OwnerID
local APP_VERSION = "1.0"      -- Replace with your KeyAuth Application Version
local SESSION_ID = ""

-- KeyAuth Initialization
local function initializeKeyAuth()
    local response = game:HttpGet("https://keyauth.win/api/1.1/?name=" .. APP_NAME .. "&ownerid=" .. OWNER_ID .. "&type=init&ver=" .. APP_VERSION)
    local data = HttpService:JSONDecode(response)
    
    if not data.success then
        warn("KeyAuth Initialization Error: " .. data.message)
        return false
    end
    
    SESSION_ID = data.sessionid
    return true
end

-- Initialize KeyAuth
if not initializeKeyAuth() then
    error("Failed to initialize KeyAuth. Check your application details.")
end

-- Create main GUI
local function createLoginSystem()
    -- Background blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game.Lighting
    
    -- Animate blur
    TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZestHubLogin"
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Animated background with moving dots
    local Background = Instance.new("Frame")
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Background.BorderSizePixel = 0
    Background.ClipsDescendants = true
    Background.Parent = ScreenGui

    local function createMovingDot()
        local Dot = Instance.new("ImageLabel")
        Dot.Size = UDim2.fromOffset(10, 10)
        Dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        Dot.AnchorPoint = Vector2.new(0.5, 0.5)
        Dot.BackgroundTransparency = 1
        Dot.Image = "rbxassetid://7072718362" -- Replace with a circular dot asset
        Dot.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Dot.ImageTransparency = 0.5
        Dot.Parent = Background

        local startPos = Dot.Position
        local endPos = UDim2.new(math.random(), 0, math.random(), 0)

        local tween = TweenService:Create(
            Dot,
            TweenInfo.new(math.random(5, 10), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
            {Position = endPos}
        )
        tween:Play()
    end

    for _ = 1, 50 do
        createMovingDot()
    end

    -- Main login frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.fromOffset(400, 450)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Add smooth corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = MainFrame
    
    -- Title with animated typing effect
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0.1, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 28
    Title.Text = "ZEST HUB"
    Title.Parent = MainFrame
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0.2, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 16
    Subtitle.Text = "Enter Your Key To Continue"
    Subtitle.Parent = MainFrame
    
    -- Key input box
    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(0.8, 0, 0, 45)
    KeyBox.Position = UDim2.new(0.1, 0, 0.4, 0)
    KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    KeyBox.Text = ""
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.PlaceholderText = "Enter Key..."
    KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    KeyBox.TextSize = 16
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.Parent = MainFrame
    
    -- Submit button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(0.8, 0, 0, 45)
    SubmitButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 16
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = MainFrame
    
    -- Key Validation Function
    local function validateKey(key)
        local response = game:HttpGet("https://keyauth.win/api/1.1/?name=" .. APP_NAME .. "&ownerid=" .. OWNER_ID .. "&type=license&key=" .. key .. "&ver=" .. APP_VERSION .. "&sessionid=" .. SESSION_ID)
        local data = HttpService:JSONDecode(response)
        
        if data.success then
            -- Access granted
            Subtitle.Text = "Access Granted!"
            Subtitle.TextColor3 = Color3.fromRGB(45, 255, 120)
            wait(1)
            
            -- Clean up GUI and load main script
            ScreenGui:Destroy()
            blur:Destroy()
            loadstring(game:HttpGet('https://pastebin.com/raw/mn8csMFV'))()
        else
            -- Show error
            Subtitle.Text = "Invalid Key! Please try again."
            Subtitle.TextColor3 = Color3.fromRGB(255, 75, 75)
        end
    end
    
    -- Button functionality
    SubmitButton.MouseButton1Click:Connect(function()
        validateKey(KeyBox.Text)
    end)
    
    -- Allow Enter key to submit
    KeyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            validateKey(KeyBox.Text)
        end
    end)
end

-- Start the login system
createLoginSystem()
