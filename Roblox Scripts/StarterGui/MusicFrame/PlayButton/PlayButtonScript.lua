-- Get a reference to the ReplicatedStorage service, which is used to share data between server and client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SubmitMusicIDEvent = ReplicatedStorage:WaitForChild("SubmitMusicIDEvent")

-- Get references to various objects in the game's hierarchy.
local PlayButton = script.Parent
local MusicIdTextBox = script.Parent.Parent:FindFirstChild("MusicId")
local MusicFrame = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Gui"):WaitForChild("MusicFrame")
local CheckMark = MusicFrame:FindFirstChild("CheckMark")
local CountdownLabel = MusicFrame:FindFirstChild("CountdownLabel")
local ErrorSubmitText = MusicFrame:FindFirstChild("ErrorSubmitText")

-- Set up variables for managing cooldowns.
local cooldown = false
local cooldownDuration = 60 -- Cooldown duration for submiting a new song in seconds
local checkmarkCooldownDuration = 5 -- Duration for showing the checkmark in seconds

-- Function to check if a music ID is valid.
local function isValidId(id)
	if id:match("^[0-9]+$") then
		-- The ID consists only of digits.
		local numericId = tonumber(id)
		if numericId >= 1000000 and numericId <= 9999999999 then
			-- The ID falls within a valid range.
			return true -- The ID is valid.
		end
	end
	return false -- The ID is not valid.
end

-- Function to show the checkmark and start the countdown.
local function showCheckMarkAndStartCountdown()
	if not (CheckMark and CountdownLabel) then
		-- Check if CheckMark and CountdownLabel objects are available.
		warn("CheckMark or CountdownLabel not found.")
		return
	end

	local musicId = MusicIdTextBox.Text -- Get the text from the MusicIdTextBox.

	if isValidId(musicId) then
		-- If the music ID is valid:
		CheckMark.Visible = true -- Show the checkmark.

		local startTime = tick() -- Get the current time.
		local checkmarkHidden = false

		while tick() - startTime <= cooldownDuration do
			-- While the time since starting is less than or equal to the cooldown duration:
			local remainingTime = math.ceil(cooldownDuration - (tick() - startTime))
			-- Calculate the remaining cooldown time.
			CountdownLabel.Text = "Cooldown: " .. remainingTime .. "s"
			-- Update the label to show the remaining time.

			if not checkmarkHidden and tick() - startTime >= checkmarkCooldownDuration then
				-- If the checkmark hasn't been hidden and it's time to hide it:
				checkmarkHidden = true
				CheckMark.Visible = false -- Hide the checkmark.
			end

			wait(0.1) -- Wait for a short time (0.1 seconds).
		end

		CountdownLabel.Text = "" -- Clear the countdown label when the cooldown is over.
	else
		warn("Invalid Music ID: " .. musicId)

		if ErrorSubmitText then
			ErrorSubmitText.Visible = true -- Show an error message.
			wait(3) -- Wait for 3 seconds.
			ErrorSubmitText.Visible = false -- Hide the error message.
		end
	end
end

-- Function to handle button clicks.
local function handleClick()
	if not cooldown then
		cooldown = true -- Set the cooldown flag to true.
		local musicId = MusicIdTextBox.Text -- Get the text from the MusicIdTextBox.
		if musicId and musicId ~= "" then
			SubmitMusicIDEvent:FireServer(musicId) -- Send the music ID to the server.
			showCheckMarkAndStartCountdown() -- Call the function to show the checkmark and start the countdown.
			cooldown = false -- Reset the cooldown flag to false.
		end
	end
end

-- Connect the handleClick function to the MouseButton1Click event of the PlayButton.
PlayButton.MouseButton1Click:Connect(handleClick)