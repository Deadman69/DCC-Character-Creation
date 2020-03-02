include("metro_config/metro_config_main.lua")
AddCSLuaFile("metro_config/metro_config_main.lua")


-- util.AddNetworkString("Metro::MainMenuOpen")
util.AddNetworkString("Metro::UserFinishMenu")
util.AddNetworkString("Metro::PlyRequest")
util.AddNetworkString("Metro::OrderToPlayer")




--[[ Files creating ]]
if not file.Exists("metro", "DATA") then -- FILE
	file.CreateDir("metro") -- FILE
end -- FILE

if not sql.TableExists("MetroCharacters") then
	sql.Query([[
		CREATE TABLE MetroCharacters
		(
			CharacterOwner      VARCHAR(20)   	NOT NULL, 		-- SteamID64 from Owner
			CharacterID			INTEGER			NOT NULL, 		-- Character ID
			CharacterName		VARCHAR(60)		NOT NULL, 		-- Character Name
			CharacterSkin		VARCHAR(255)	NOT NULL, 		-- Character Skin
			CharacterBodygroup 	VARCHAR(20)		NOT NULL, 		-- Character Bodygroups
			CharacterMoney		INTEGER,						-- Character Money
			CharacterHealth		INTEGER,				  		-- Character Health
			CharacterArmor		INTEGER,				  		-- Character Armor
			CharacterFood		INTEGER,				  		-- Character Food
			CharacterWeapons    TEXT,					  		-- Character Weapons (json table)
			CharacterPosition   VARCHAR(255),			  		-- Character Position (json table)

			PRIMARY KEY(CharacterOwner, CharacterID)
		)
	]])
end



--[[ Custom Functions ]]
local function MMNotification(players, message, notifType, time, sound)
	net.Start("Metro::OrderToPlayer")
		net.WriteString("notification")
		net.WriteString(message)
		net.WriteInt(notifType, 4)
		net.WriteInt(time, 4)
		if sound then
			net.WriteString(sound)
		else
			net.WriteString("")
		end
	net.Send(players)
end

local function PlyDefineChar(charChoosed, ply)
	ply:Spawn()
	print(charChoosed)
	file.Write("metro/"..ply:SteamID64().."/lastplayed.txt", tostring(charChoosed))

	ply:setDarkRPVar("money", tonumber(sql.Query("SELECT CharacterMoney FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterMoney"]) )
	ply:SetModel(sql.Query("SELECT CharacterSkin FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterSkin"])
	ply:SetBodyGroups(sql.Query("SELECT CharacterBodygroup FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterBodygroup"])
	ply:setRPName(sql.Query("SELECT CharacterName FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterName"], false)

	if MConf.SaveHealth && MConf.SaveHealthBlacklistedTeams[team.GetName(ply:Team())] then
		local health = tonumber(sql.Query("SELECT CharacterHealth FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterHealth"])
		if isnumber(health) then
			ply:SetHealth(health)
		end
	end
	if MConf.SaveArmor && MConf.SaveArmorBlacklistedTeams[team.GetName(ply:Team())] then
		local armor = tonumber(sql.Query("SELECT CharacterArmor FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterArmor"])
		if isnumber(armor) then
			ply:SetArmor(armor)
		end
	end
	if MConf.SaveFood && MConf.SaveFoodBlacklistedTeams[team.GetName(ply:Team())] then
		local food = tonumber(sql.Query("SELECT CharacterFood FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterFood"])
		if isnumber(food) then
			ply:setDarkRPVar("Energy", food)
		end
	end
	if MConf.SaveWeapons && MConf.SaveWeaponsBlacklistedTeams[team.GetName(ply:Team())] then
		local swepList = sql.Query("SELECT CharacterWeapons FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterWeapons"]
		for _, swep in pairs(util.JSONToTable(swepList)) do
			ply:Give(swep)
		end
	end
	if MConf.SavePosition && MConf.SavePositionBlacklistedTeams[team.GetName(ply:Team())] then
		local pos = sql.Query("SELECT CharacterPosition FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterPosition"] 
		pos = util.JSONToTable(pos) -- Table
		if istable(pos) then
			ply:SetPos(Vector(pos[1], pos[2], pos[3]))
		end
	end

	ply:Freeze(false)
	ply:AllowFlashlight(true)
end

local function getAllChars(ply)
	-- récupèrer les infos des personnages du joueur
	local query = sql.Query([[
		SELECT
		  CharacterID,
		  CharacterName,
		  CharacterMoney,
		  CharacterSkin,
		  CharacterBodygroup
		FROM
		  MetroCharacters
		WHERE
		  CharacterOwner = ]]..ply:SteamID64()..[[
		  AND CharacterID IN (1, 2, 3)
	]])

	local characters = {}
	if ( query and istable( query ) ) then
	  	for i = 1, #query do
		    local character = query[ i ]
		    characters[ #characters + 1 ] = {
		      	name = character.CharacterName or '',
		      	money = character.CharacterMoney or '',
				skin = character.CharacterSkin or '',
				bodygroup = character.CharacterBodygroup or '',
		    }
	  	end
	end
	net.Start("Metro::OrderToPlayer")
		net.WriteString("receiveAllCharacters")
		net.WriteTable( characters )
	net.Send(ply)
end


local function updateData()
	sql.Begin() -- In case if there is a lot of players

	for _, v in pairs(player.GetAll()) do
		local charID = v:GetNWInt("Metro::CharacterID")
		sql.Query("UPDATE MetroCharacters SET CharacterMoney = '"..v:getDarkRPVar("money").."' WHERE CharacterOwner = '"..v:SteamID64().."' AND CharacterID = '"..charID.."'")
		sql.Query("UPDATE MetroCharacters SET CharacterHealth = '"..v:Health().."' WHERE CharacterOwner = '"..v:SteamID64().."' AND CharacterID = '"..charID.."'")
		sql.Query("UPDATE MetroCharacters SET CharacterArmor = '"..v:Armor().."' WHERE CharacterOwner = '"..v:SteamID64().."' AND CharacterID = '"..charID.."'")
		sql.Query("UPDATE MetroCharacters SET CharacterFood = '"..v:getDarkRPVar("Energy").."' WHERE CharacterOwner = '"..v:SteamID64().."' AND CharacterID = '"..charID.."'")

		local plySweps = {}
		for _, swep in pairs(v:GetWeapons()) do
	 		local actualSwepString = string.Explode("[", tostring(swep))[3] -- keep only "weapon_crossbow]"
	 		actualSwepString = string.Replace(actualSwepString, "]", "" ) -- removing the "]"
	 		table.insert(plySweps, actualSwepString)
		end
		plySweps = util.TableToJSON(plySweps)
		sql.Query("UPDATE MetroCharacters SET CharacterWeapons = '"..plySweps.."' WHERE CharacterOwner = '"..v:SteamID64().."' AND CharacterID = '"..charID.."'")

		local pos = tostring(v:GetPos())
		pos = string.Explode(" ", pos) -- Table
		pos = util.TableToJSON(pos) -- Json table
		sql.Query("UPDATE MetroCharacters SET CharacterPosition = '"..pos.."' WHERE CharacterOwner = '"..v:SteamID64().."' AND CharacterID = '"..charID.."'")
	end

	sql.Commit() -- Same as sql.Begin()
end
timer.Create("Metro::updateData", MConf.AutosaveTime, 0, updateData)

local function findingPlayer(search)
	local playerFindedEnt = nil
	for _, ply in pairs(player.GetAll()) do -- Searching for connected players
		if ply:SteamID() == search or ply:SteamID64() == search or string.StartWith(ply:Nick(), search) then
			playerFindedEnt = ply
		end
	end

	return playerFindedEnt
end

local function DeleteCharAdmin(requester, search, charIDToDelete) -- search = SteamID or SteamID64 or Name
	local playerFindedEnt = findingPlayer(search)
	if not playerFindedEnt then -- If we haven't find the player in the connected players
		MMNotification(requester, "We haven't find any players for the argument you supplied: '"..tostring(search).."'", 1, 3)
	else
		sql.Query("DELETE FROM MetroCharacters WHERE CharacterOwner = '"..playerFindedEnt:SteamID64().."' AND CharacterID = '"..charIDToDelete.."'")

		if charIDToDelete == playerFindedEnt:GetNWInt("Metro::CharacterID") then -- If admin deleted the current player character
			playerFindedEnt:Kick("Please reconnect to apply changes (Character deleted by an admin)")
			file.Write("metro/"..playerFindedEnt:SteamID64().."/lastplayed.txt", "")
		end
		MMNotification(requester, "The character have been deleted and the player has been kicked !", 0, 3)
	end
end

local function RenameCharAdmin(requester, search, charIDToRename, newName)
	local playerFindedEnt = findingPlayer(search)
	if not playerFindedEnt then -- If we haven't find the player in the connected players
		MMNotification(requester, "We haven't find any players for the argument you supplied: '"..tostring(search).."'", 1, 3)
	else
		local request = sql.Query("SELECT CharacterName FROM MetroCharacters WHERE CharacterName = '"..tostring(newName).."'") -- nil if name is not already existing
		if request == nil then
			sql.Query("UPDATE MetroCharacters SET CharacterName = '"..tostring(newName).."' WHERE CharacterOwner = '"..playerFindedEnt:SteamID64().."' AND CharacterID = '"..charIDToRename.."'")
			playerFindedEnt:Kick("Please reconnect to apply changes (Character renamed by an admin)")
			MMNotification(requester, "The character have been renamed !", 0, 3)
		else
			MMNotification(requester, "This name is already used !", 1, 3)
		end
	end
end


--[[ Hooks ]]
hook.Add( "PlayerInitialSpawn", "Metro::MainHook::PlayerInitialSpawn", function(ply)
	if not file.Exists("metro/"..ply:SteamID64(), "DATA") then
		file.CreateDir("metro/"..ply:SteamID64())
		file.Write("metro/"..ply:SteamID64().."/lastplayed.txt", "")
	end

	net.Start("Metro::OrderToPlayer")
		net.WriteString("openMainMenu")
	net.Send(ply)

	ply:Freeze(true)
	ply:AllowFlashlight(false) -- lock flashlight if player press "f" while in main menu

	timer.Simple(1, function() -- Timer otherwise, skin don't change
		ply:SetModel(MConf.DefaultSkin)
	end)
end)

hook.Add( "PlayerSay", "Metro::MainHook::PlayerSay", function( ply, text )
	local playerInput = string.Explode( " ", text )

	if playerInput[1] == MConf.CommandOpenMenu then
		net.Start("Metro::OrderToPlayer")
			net.WriteString("openMainMenu")
		net.Send(ply)

		ply:Freeze(true)
		ply:AllowFlashlight(false)
	elseif playerInput[1] == MConf.CommandDeleteChar then
		local rankAllowed = false
		for rank, _ in pairs(MConf.CommandDeleteCharAllowedRanks) do
			if ply:GetUserGroup() == rank then
				rankAllowed = true
			end
		end

		if rankAllowed then
			if playerInput[2] then
				if playerInput[3] then
					DeleteCharAdmin(ply, playerInput[2], playerInput[3])
				else
					MMNotification(ply, "You have to specify the character to delete !", 1, 3)
				end
			else
				MMNotification(ply, "You have to specify the SteamID64 / Player Name / SteamID", 1, 3)
			end
		else
			MMNotification(ply, "You have not access to this command !", 1, 3)
		end
	elseif playerInput[1] == MConf.CommandRenameChar then
		local rankAllowed = false
		for rank, _ in pairs(MConf.CommandDeleteCharAllowedRanks) do
			if ply:GetUserGroup() == rank then
				rankAllowed = true
			end
		end

		if rankAllowed then
			if playerInput[2] then
				if playerInput[3] then
					if playerInput[4] then
						RenameCharAdmin(ply, playerInput[2], playerInput[3], table.concat(playerInput, " ", 4) )
					else
						MMNotification(ply, "You have to provide a new name !", 1, 3)
					end
				else
					MMNotification(ply, "You have to specify the character to rename !", 1, 3)
				end
			else
				MMNotification(ply, "You have to specify the SteamID64 / Player Name / SteamID", 1, 3)
			end
		else
			MMNotification(ply, "You have not access to this command !", 1, 3)
		end
	elseif playerInput[1] == MConf.CommandDeleteAllData then
		if ply:IsSuperAdmin() then
			sql.Query("DELETE FROM MetroCharacters") -- Delete database

			MMNotification(ply, "Every data from players have been deleted. Server restarting in 3 seconds...", 0, 3)
			timer.Simple(3, function()
				game.ConsoleCommand("changelevel "..game.GetMap().."\n")
			end)
		else
			MMNotification(ply, "You have not access to this command !", 1, 3)
		end
	end

end)


hook.Add( "PlayerSpawn", "Metro::MainHook::PlayerSpawn", function(ply)
	if not MConf.BlacklistTeams[team.GetName(ply:Team())] then
		timer.Simple(0.1, function()
			local actualCharacter = ply:GetNWInt("Metro::CharacterID")
			if actualCharacter ~= 0 then
				ply:SetModel(sql.Query("SELECT CharacterSkin FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..actualCharacter.."'")[1]["CharacterSkin"])
				ply:SetBodyGroups(sql.Query("SELECT CharacterBodygroup FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..actualCharacter.."'")[1]["CharacterBodygroup"])
			end
		end)
	end
end)


--[[ Net messages ]]

net.Receive("Metro::UserFinishMenu", function(len, ply)
	if ply:GetNWInt("Metro::CharacterID") then -- If player have already choosen a character
		ply:Freeze(false)
		ply:AllowFlashlight(true)
	else
		-- Reopening menu or player will be stucked
		net.Start("Metro::OrderToPlayer")
			net.WriteString("openSpecificMenu")
			net.WriteString("character")
		net.Send(ply)
	end
end)

net.Receive("Metro::PlyRequest", function(len, ply)
	local request = net.ReadString()

	if request == "getAllChars" then
		getAllChars(ply)
	elseif request == "playLastChar" then
		local charChoosed = tonumber(file.Read("metro/"..ply:SteamID64().."/lastplayed.txt", "DATA"))
		if charChoosed then
			PlyDefineChar(charChoosed, ply)
			ply:SetNWInt("Metro::CharacterID", charChoosed)
		else
			MMNotification(ply, "Error, you already playing this character !", 1, 3)

			-- Reopening menu or player will be stucked
			net.Start("Metro::OrderToPlayer")
				net.WriteString("openSpecificMenu")
				net.WriteString("main")
			net.Send(ply)
		end
	elseif request == "chooseChar" then
		local charChoosed = net.ReadInt(4)
		if ply:GetNWInt("Metro::CharacterID") ~= charChoosed then
			PlyDefineChar(charChoosed, ply)
			ply:SetNWInt("Metro::CharacterID", charChoosed)
		else
			MMNotification(ply, "Error, you already playing this character !", 1, 3)

			-- Reopening menu or player will be stucked
			net.Start("Metro::OrderToPlayer")
				net.WriteString("openSpecificMenu")
				net.WriteString("character")
			net.Send(ply)
		end
	elseif request == "deleteChar" then
		local charChoosed = net.ReadInt(4)
		if ply:GetNWInt("Metro::CharacterID") == charChoosed then
			MMNotification(ply, "Error, you can't delete this character while you're playing !", 1, 3)
		else
			sql.Query("DELETE FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")
			MMNotification(ply, "Character deleted !", 0, 3)
		end
	elseif request == "createCharacter" then
		local charChoosed = net.ReadInt(4)
		local charName = net.ReadString()
		local charBodygroup = net.ReadString()
		local charSkin = net.ReadString()

		-- Skin permission checking
		local skinAllowed = false
		local fullSkinsTable = {}
		table.Add(fullSkinsTable, MConf.BaseSkinsFemale)
		table.Add(fullSkinsTable, MConf.BaseSkinsMale)
		for _, tableValue in pairs(fullSkinsTable) do
			for rankAllowedID, _ in pairs(tableValue.RankAllowed) do
				if rankAllowedID == ply:GetUserGroup() then
					skinAllowed = true
				end
			end
		end

		if skinAllowed then
			sql.Query("INSERT INTO MetroCharacters(CharacterOwner,CharacterID,CharacterName,CharacterSkin,CharacterBodygroup,CharacterPosition,CharacterMoney) VALUES('"..ply:SteamID64().."', '"..charChoosed.."', '"..charName.."', '"..charSkin.."', '"..charBodygroup.."', '"..string.Replace( "Vector("..tostring(ply:GetPos()), " ", ", " )..")".."', 0)") -- SQL

			MMNotification(ply, "Character created !", 0, 3)
		else
			MMNotification(ply, "This skin is not allowed for you !", 1, 3)
		end
		getAllChars(ply) -- Reloading player menu
	elseif request == "checkName" then
		local nameToCheck = net.ReadString()
		local charChoosed = net.ReadInt(4)

		local nameAvailable = true
		local request = sql.Query("SELECT CharacterName FROM MetroCharacters WHERE CharacterName = '"..tostring(newName).."'") -- nil if name is not already existing
		if not request == nil then -- if name is already used
			nameAvailable = false
		end

		net.Start("Metro::OrderToPlayer")
			net.WriteString("nameAvailable")
			net.WriteBool(nameAvailable)
			net.WriteInt(charChoosed, 4)
			net.WriteString(nameToCheck)
		net.Send(ply)
	end

end)