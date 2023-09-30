-- Get references to game objects and GUI elements
local Gui = game:GetService("StarterGui") 
local MusicFrame = script.Parent.Parent:WaitForChild("MusicFrame") 

-- Initialize variables
local frameVisible = false  -- Variable to track whether the MusicFrame is currently visible
local finalPosition = UDim2.new(0.124, 0, 0.101, 0)  -- The final position where the MusicFrame should be displayed

-- Set the initial position and visibility of the MusicFrame
MusicFrame.Position = UDim2.new(-0.5, 0, 0.101, 0)  -- Start the frame off-screen to the left
MusicFrame.Visible = false  -- Initially, make the MusicFrame invisible

-- Function to animate the MusicFrame using tweening
local function tweenFrame()
	-- Define the properties of the tween animation
	local tweenInfo = TweenInfo.new(
		0.2,  -- Duration of the animation (in seconds)
		Enum.EasingStyle.Quad,  -- Type of easing (quadratic)
		Enum.EasingDirection.Out,  -- Direction of easing (out)
		0,  -- Repeat count (0 means don't repeat)
		false,  -- Backward playback (not enabled)
		0  -- Delay before starting the tween (0 seconds)
	)

	local goal = {}
	if frameVisible then
		-- If the frame is currently hidden, show it at the final position
		goal.Position = finalPosition
		goal.Visible = true
	else
		-- If the frame is currently visible, hide it by moving it off-screen to the left
		goal.Position = UDim2.new(-0.5, 0, 0.101, 0)
		goal.Visible = false
	end

	-- Create a tween to animate the MusicFrame using TweenService
	local tween = game:GetService("TweenService"):Create(MusicFrame, tweenInfo, goal)
	tween:Play()  -- Play the tween animation
end

-- Event handler for when the button is clicked
script.Parent.MouseButton1Click:Connect(function()
	-- Toggle the visibility state of the MusicFrame
	frameVisible = not frameVisible

	-- Animate the MusicFrame to its new visibility state
	tweenFrame()
end)