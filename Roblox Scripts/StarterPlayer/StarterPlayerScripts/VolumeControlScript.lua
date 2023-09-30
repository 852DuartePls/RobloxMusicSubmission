-- References to game objects and GUI elements
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local musicFrame = player:WaitForChild("PlayerGui"):WaitForChild("Gui"):WaitForChild("MusicFrame")
local musicIdName = musicFrame:FindFirstChild("MusicIdName")
local nowPlayingLabel = musicFrame:FindFirstChild("NowPlayingLabel")
local QueueSizeLabel = musicFrame:FindFirstChild("QueueSizeLabel")

-- Function to update the Currently Playing Music display Info
local function updateCurrentlyPlayingMusicInfo(musicId, musicName, artistName)
	-- Check if MusicIdName GUI element exists
	if not musicIdName then
		warn("MusicIdName not found.")
		return
	end

	-- Update the MusicIdName GUI element with the music ID
	if musicId ~= "" then
		musicIdName.Text = "ID: " .. musicId
		print("ID: " .. musicId) -- Log the music ID
	else
		musicIdName.Text = ""
	end

	-- Check if NowPlayingLabel GUI element exists
	if not nowPlayingLabel then
		warn("NowPlayingLabel not found.")
		return
	end

	-- Update the NowPlayingLabel GUI element with music information
	if musicId == "INVALID MUSIC ID" then
		nowPlayingLabel.Text = "INVALID MUSIC ID"
	else
		local labelText = "NOW PLAYING:\n" .. musicName .. " by " .. artistName
		nowPlayingLabel.Text = labelText
		nowPlayingLabel.TextWrapped = true
		nowPlayingLabel.TextScaled = true
		nowPlayingLabel.TextYAlignment = Enum.TextYAlignment.Center
	end
end

-- Connect to the CurrentlyPlayingEvent
local CurrentlyPlayingEvent = ReplicatedStorage:WaitForChild("CurrentlyPlayingEvent")
if CurrentlyPlayingEvent then
	CurrentlyPlayingEvent.OnClientEvent:Connect(updateCurrentlyPlayingMusicInfo)
else
	warn("CurrentlyPlayingEvent not found.")
end

-- Function to update the Queue Size Label
local function updateLabel(queueSize)
	-- Check if QueueSizeLabel GUI element exists
	if not QueueSizeLabel then
		warn("QueueSizeLabel not found.")
		return
	end

	-- Update the QueueSizeLabel GUI element with the queue size
	QueueSizeLabel.Text = "Songs currently in queue: " .. queueSize
	print("Updated QueueSizeLabel to: " .. QueueSizeLabel.Text) -- Log the updated queue size
end

-- Connect to the UpdateQueueSizeEvent
local UpdateQueueSizeEvent = ReplicatedStorage:WaitForChild("UpdateQueueSizeEvent")
if UpdateQueueSizeEvent then
	UpdateQueueSizeEvent.OnClientEvent:Connect(updateLabel)
	print("Connected to UpdateQueueSizeEvent.")
else
	warn("UpdateQueueSizeEvent not found.")
end

-- Initialize Queue Size Label
local initialQueueSize = 0
updateLabel(initialQueueSize)