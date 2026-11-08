local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LoadingUI = {}

local Colors = {
	LOADING = Color3.fromRGB(255, 255, 255),
	READY = Color3.fromRGB(105, 255, 155),
	RETRYING = Color3.fromRGB(255, 215, 110),
	FAILED = Color3.fromRGB(255, 105, 105),
}

local function CreateText(Parent, Text, Height, Size)
	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.BorderSizePixel = 0
	Label.Size = UDim2.fromOffset(520, Height)
	Label.Font = Enum.Font.GothamMedium
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = Size
	Label.TextTransparency = 1
	Label.TextXAlignment = Enum.TextXAlignment.Center
	Label.Parent = Parent
	return Label
end

function LoadingUI.new()
	local Gui = Instance.new("ScreenGui")
	Gui.Name = "QwenzyLoading"
	Gui.ResetOnSpawn = false
	Gui.IgnoreGuiInset = true
	Gui.Parent = type(gethui) == "function" and gethui() or Players.LocalPlayer:WaitForChild("PlayerGui")

	local Status = CreateText(Gui, "Preparing hub", 24, 16)
	Status.AnchorPoint = Vector2.new(0.5, 0)
	Status.Position = UDim2.fromScale(0.5, 0.035)

	local Notifications = Instance.new("Frame")
	Notifications.AnchorPoint = Vector2.new(0.5, 0)
	Notifications.Position = UDim2.fromScale(0.5, 0.07)
	Notifications.Size = UDim2.fromOffset(520, 130)
	Notifications.BackgroundTransparency = 1
	Notifications.BorderSizePixel = 0
	Notifications.Parent = Gui

	local Layout = Instance.new("UIListLayout")
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0, 2)
	Layout.Parent = Notifications

	local StatusTween
	local self = {}

	function self:SetStatus(Message, State)
		Status.Text = Message
		Status.TextColor3 = Colors[State] or Colors.LOADING

		if StatusTween then
			StatusTween:Cancel()
		end
		Status.TextTransparency = 0.55
		StatusTween = TweenService:Create(Status, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
		})
		StatusTween:Play()
	end

	function self:Notify(Message, State)
		local Notice = CreateText(Notifications, Message, 18, 13)
		Notice.TextColor3 = Colors[State] or Colors.READY

		TweenService:Create(Notice, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
		}):Play()

		task.delay(1.1, function()
			local Fade = TweenService:Create(Notice, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
			})
			Fade:Play()
			Fade.Completed:Wait()
			Notice:Destroy()
		end)
	end

	function self:Destroy()
		Gui:Destroy()
	end

	return self
end

return LoadingUI
