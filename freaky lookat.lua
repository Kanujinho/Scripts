local Player = game.Players.LocalPlayer
local char = Player.Character or Player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
local uis = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local track = nil
local connection = nil
local enabled = false
local currentTimePos = 0.875
local tau = 0.2

local function update(dt)
	if not char.PrimaryPart or not track then return end
	local root = char.PrimaryPart
	local forward = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
	local cam = workspace.CurrentCamera
	if not cam then return end
	local camForward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
	if forward.Magnitude == 0 or camForward.Magnitude == 0 then return end
	local dot = forward:Dot(camForward)
	local crossY = forward:Cross(camForward).Y
	local angle = math.atan2(crossY, dot)
	local frac = math.clamp(math.abs(angle) / math.pi, 0, 1)
	local offset = frac * (angle >= 0 and 0.125 or -0.175)
	local targetTimePos = 0.875 + offset
	if dt then
		local alpha = 1 - math.exp(-dt / tau)
		currentTimePos = currentTimePos * (1 - alpha) + targetTimePos * alpha
	else
		currentTimePos = targetTimePos
	end
	track.TimePosition = currentTimePos
end

uis.InputBegan:Connect(function(input, gpe)
	if gpe or input.KeyCode ~= Enum.KeyCode.E then return end
	enabled = not enabled
	if enabled then
		if not track then
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://93079313117595"
			track = animator:LoadAnimation(anim)
			track.Priority = Enum.AnimationPriority.Core
		end
		track:Play(0.1, 1, 0)
		track:AdjustSpeed(0)
		currentTimePos = 0.875
		update()
		connection = RunService.RenderStepped:Connect(update)
	else
		if track then track:Stop(0.1) end
		if connection then connection:Disconnect() end
		connection = nil
	end
end)