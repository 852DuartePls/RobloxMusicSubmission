-- Get a reference to the ReplicatedStorage service, which is like a shared storage for the game.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a special communication channel for players to submit music IDs.
local SubmitMusicIDEvent = Instance.new("RemoteEvent")
SubmitMusicIDEvent.Name = "SubmitMusicIDEvent"
SubmitMusicIDEvent.Parent = ReplicatedStorage

-- Get a tool to check if music IDs are real and working.
local MarketplaceService = game:GetService("MarketplaceService")

-- Set up a playlist to store music that players want to listen to.
local MusicQueue = {}
local MaxQueueSize = 50 -- Queue Size of Maximum 50 songs
local isQueueEmpty = true

-- Track the time players must wait before submitting more music.
local CooldownTable = {}
local CooldownDuration = 60 --Duration in seconds

-- Find the in-game object, (in this case named JukeBox) with an SoundObject inside (in this case named MusicPlayer)
local JukeBox = game.Workspace:FindFirstChild("JukeBox")
local MusicPlayer = JukeBox and JukeBox:FindFirstChild("MusicPlayer")

-- Store info about the currently playing music to share with players.
local currentPlayingId = ""
local currentPlayingName = "No current music is playing"
local currentPlayingArtist = "Unknown"

-- Create a channel to tell players what's currently playing.
local CurrentlyPlayingEvent = Instance.new("RemoteEvent")
CurrentlyPlayingEvent.Name = "CurrentlyPlayingEvent"
CurrentlyPlayingEvent.Parent = ReplicatedStorage

-- Create a channel to tell clients how many songs are in the queue.
local UpdateQueueSizeEvent = Instance.new("RemoteEvent")
UpdateQueueSizeEvent.Name = "UpdateQueueSizeEvent"
UpdateQueueSizeEvent.Parent = ReplicatedStorage

-- Function to update the displayed number of songs in the queue for players.
local function updateQueueSizeLabel()
	local queueSize = #MusicQueue
	print("Server: Sending queue size update to clients:", queueSize) -- Print added to check if the function is working
	UpdateQueueSizeEvent:FireAllClients(queueSize)  -- Notify clients about the queue size.

	-- Find the "QueueSizeLabel" in ReplicatedStorage and update its text if it exists.
	local label = ReplicatedStorage:FindFirstChild("QueueSizeLabel") 

	if label then
		label.Text = "Queue Size: " .. queueSize
	end
end

-- Function to handle music ID submissions from players.
local function handleMusicIDSubmission(player, musicId)
	if CooldownTable[player.UserId] and (tick() - CooldownTable[player.UserId]) < CooldownDuration then
		-- Prevent players from submitting music too frequently.
		print(player.Name .. " is on cooldown.")
		return
	end

	local musicIdNumber = tonumber(musicId)

	if not musicIdNumber then
		-- Check if the submitted music ID is not a valid number.
		warn(player.Name .. " submitted an invalid music ID: " .. musicId)
		return
	end

	local productInfo = MarketplaceService:GetProductInfo(tostring(musicIdNumber), Enum.InfoType.Asset)

	if productInfo and productInfo.AssetTypeId == Enum.AssetType.Audio.Value then
		if musicIdNumber > 0 and #MusicQueue < MaxQueueSize then
			-- Check if the music ID is valid, the queue is not full, and it's an audio asset.
			table.insert(MusicQueue, musicIdNumber)
			print(player.Name .. " submitted music ID: " .. musicIdNumber)
			isQueueEmpty = false
			currentPlayingId = musicIdNumber
			currentPlayingName = productInfo.Name
			currentPlayingArtist = productInfo.Creator.Name

			-- Call the updateQueueSizeLabel function to refresh the queue size.
			updateQueueSizeLabel()

			-- Start the cooldown timer for the player.
			CooldownTable[player.UserId] = tick()
		else
			warn(player.Name .. " attempted to submit a music ID, but the queue is full or the ID is invalid.")
		end
	else
		warn(player.Name .. " submitted an invalid music ID: " .. musicId)
	end
end

-- Connect the handleMusicIDSubmission function to the server's SubmitMusicIDEvent.
SubmitMusicIDEvent.OnServerEvent:Connect(handleMusicIDSubmission)

-- Function to play music from the queue.
local function playMusicFromQueue()
	while true do
		if #MusicQueue > 0 then
			-- Check if there are songs in the queue to play.
			local musicId = table.remove(MusicQueue, 1)
			-- Get the first song from the queue and remove it from the list.

			if MusicPlayer then
				-- Check if a music player exists. (Line 22 and 23)
				MusicPlayer.SoundId = "rbxassetid://" .. musicId
				-- Set the SoundId of the MusicPlayer to the selected music.
				MusicPlayer.Volume = 5
				-- Set the volume for the MusicPlayer.

				local isLoaded = false  -- Track if the audio is loaded.
				local startTime = tick()  -- Record the current time.

				while not isLoaded and tick() - startTime < 10 do
					-- Wait for the audio to load or until 10 seconds have passed.
					isLoaded = MusicPlayer.IsLoaded
					wait(0.1)
				end

				if isLoaded then
					-- If the audio is loaded and ready to play:
					MusicPlayer:Play()
					-- Play the music.
					print("Now Playing: " .. musicId)
					-- Print a message to the server console.

					-- Notify all clients about the currently playing music.
					CurrentlyPlayingEvent:FireAllClients(currentPlayingId, currentPlayingName, currentPlayingArtist)

					-- Wait for the music to finish playing before moving to the next.
					MusicPlayer.Ended:Wait()
				else
					-- If the audio failed to load or was silent, skip it.
					warn("Skipped silent or unloaded audio with ID: " .. musicId)
					-- Print a warning message to the server console.
					CurrentlyPlayingEvent:FireAllClients("", "", "")
					-- Notify clients that no music is currently playing.
				end

				-- Update the displayed queue size after playing a song.
				updateQueueSizeLabel()
			end

		elseif not isQueueEmpty then
			-- If the queue is empty, wait for more music submissions.
			print("Music queue is empty. Waiting for submissions...")
			-- Print a message to the server console.
			isQueueEmpty = true
		end
		wait(1)  -- Wait for 1 second before checking the queue again.
	end
end

-- Start the function to play music from the queue.
playMusicFromQueue()