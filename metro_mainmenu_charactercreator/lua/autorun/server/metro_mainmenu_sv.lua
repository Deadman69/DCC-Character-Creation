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
			CharacterAngle		VARHCAR(255),					-- Character Angle (json table)

			PRIMARY KEY(CharacterOwner, CharacterID)
		)
	]])
end



--[[ Custom Functions ]]
function MMNotification(players, message, notifType, time, sound)
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


function MetroWhitelistActive()
	if MConf.WhitelistVersion then
		return true
	else
		return false
	end
end




local function updateData(isPrivate, plyPrivate)
	sql.Begin() -- In case if there is a lot of players

	if not isPrivate then
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

			local angle = tostring(v:GetPos())
			angle = string.Explode(" ", angle) -- Table
			angle = util.TableToJSON(angle) -- Json table
			sql.Query("UPDATE MetroCharacters SET CharacterAngle = '"..angle.."' WHERE CharacterOwner = '"..v:SteamID64().."' AND CharacterID = '"..charID.."'")
		end
	else
		local charID = plyPrivate:GetNWInt("Metro::CharacterID")
		sql.Query("UPDATE MetroCharacters SET CharacterMoney = '"..plyPrivate:getDarkRPVar("money").."' WHERE CharacterOwner = '"..plyPrivate:SteamID64().."' AND CharacterID = '"..charID.."'")
		sql.Query("UPDATE MetroCharacters SET CharacterHealth = '"..plyPrivate:Health().."' WHERE CharacterOwner = '"..plyPrivate:SteamID64().."' AND CharacterID = '"..charID.."'")
		sql.Query("UPDATE MetroCharacters SET CharacterArmor = '"..plyPrivate:Armor().."' WHERE CharacterOwner = '"..plyPrivate:SteamID64().."' AND CharacterID = '"..charID.."'")
		sql.Query("UPDATE MetroCharacters SET CharacterFood = '"..plyPrivate:getDarkRPVar("Energy").."' WHERE CharacterOwner = '"..plyPrivate:SteamID64().."' AND CharacterID = '"..charID.."'")

		local plySweps = {}
		for _, swep in pairs(plyPrivate:GetWeapons()) do
	 		local actualSwepString = string.Explode("[", tostring(swep))[3] -- keep only "weapon_crossbow]"
	 		actualSwepString = string.Replace(actualSwepString, "]", "" ) -- remoplyPrivateing the "]"
	 		table.insert(plySweps, actualSwepString)
		end
		plySweps = util.TableToJSON(plySweps)
		sql.Query("UPDATE MetroCharacters SET CharacterWeapons = '"..plySweps.."' WHERE CharacterOwner = '"..plyPrivate:SteamID64().."' AND CharacterID = '"..charID.."'")

		local pos = tostring(plyPrivate:GetPos())
		pos = string.Explode(" ", pos) -- Table
		pos = util.TableToJSON(pos) -- Json table
		sql.Query("UPDATE MetroCharacters SET CharacterPosition = '"..pos.."' WHERE CharacterOwner = '"..plyPrivate:SteamID64().."' AND CharacterID = '"..charID.."'")
		
		local angle = tostring(plyPrivate:EyeAngles())
		angle = string.Explode(" ", angle) -- Table
		angle = util.TableToJSON(angle) -- Json table
		sql.Query("UPDATE MetroCharacters SET CharacterAngle = '"..angle.."' WHERE CharacterOwner = '"..plyPrivate:SteamID64().."' AND CharacterID = '"..charID.."'")
	end

	sql.Commit() -- Same as sql.Begin()
end
timer.Create("Metro::updateData", MConf.AutosaveTime, 0, function()
	updateData(false)
end)


local function PlyDefineChar(charChoosed, ply)
	updateData(true, ply) -- update data for the current char before switching

	ply:SetNWInt("Metro::CharacterID", charChoosed)

	ply:Spawn()
	file.Write("metro/"..ply:SteamID64()..".txt", tostring(charChoosed))

	ply:setDarkRPVar("money", tonumber(sql.Query("SELECT CharacterMoney FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterMoney"]) )
	ply:SetModel(sql.Query("SELECT CharacterSkin FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterSkin"])
	ply:SetBodyGroups(sql.Query("SELECT CharacterBodygroup FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterBodygroup"])
	ply:setRPName(sql.Query("SELECT CharacterName FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterName"], false)

	if MConf.SaveHealth && not MConf.SaveHealthBlacklistedTeams[team.GetName(ply:Team())] then
		local health = tonumber(sql.Query("SELECT CharacterHealth FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterHealth"])
		if isnumber(health) then
			ply:SetHealth(health)
		end
	end
	if MConf.SaveArmor && not MConf.SaveArmorBlacklistedTeams[team.GetName(ply:Team())] then
		local armor = tonumber(sql.Query("SELECT CharacterArmor FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterArmor"])
		if isnumber(armor) then
			ply:SetArmor(armor)
		end
	end
	if MConf.SaveFood && not MConf.SaveFoodBlacklistedTeams[team.GetName(ply:Team())] then
		local food = tonumber(sql.Query("SELECT CharacterFood FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterFood"])
		if isnumber(food) then
			ply:setDarkRPVar("Energy", food)
		end
	end
	if MConf.SaveWeapons && not MConf.SaveWeaponsBlacklistedTeams[team.GetName(ply:Team())] then
		local swepList = sql.Query("SELECT CharacterWeapons FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterWeapons"]
		if not swepList == "NULL" then
			for _, swep in pairs(util.JSONToTable(swepList)) do
				ply:Give(swep)
			end
		end
	end
	if MConf.SavePosition && not MConf.SavePositionBlacklistedTeams[team.GetName(ply:Team())] then
		local pos = sql.Query("SELECT CharacterPosition FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterPosition"] 
		pos = util.JSONToTable(pos) -- to Table
		if pos ~= nil then
			if pos[1] and pos[2] and pos[3] then
				if istable(pos) then
					ply:SetPos(Vector(pos[1], pos[2], pos[3]))
				end
			end
		end

		if MConf.SaveAngle then
			local angle = sql.Query("SELECT CharacterAngle FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")[1]["CharacterAngle"] 
			angle = util.JSONToTable(angle) -- to Table
			if angle ~= nil then
				if angle[1] and angle[2] and angle[3] then
					if istable(angle) then
						-- L'angle déconne à cause de la troisième personne
						ply:SetEyeAngles(Angle(angle[1], angle[2], angle[3]))
					end
				end
			end
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
		--MMNotification(requester, "We haven't find any players for the argument you supplied: '"..tostring(search).."'", 1, 3)
		GNLib.AutoTranslate( MConf.LanguageType, "We haven't find any players for the argument you supplied !", function(callback) MMNotification(ply, callback, 1, 3) end )
	else
		sql.Query("DELETE FROM MetroCharacters WHERE CharacterOwner = '"..playerFindedEnt:SteamID64().."' AND CharacterID = '"..charIDToDelete.."'")

		if charIDToDelete == playerFindedEnt:GetNWInt("Metro::CharacterID") then -- If admin deleted the current player character
			playerFindedEnt:Kick("Please reconnect to apply changes (Character deleted by an admin)")
			file.Write("metro/"..playerFindedEnt:SteamID64()..".txt", "")
		end
		--MMNotification(requester, "The character have been deleted and the player has been kicked !", 0, 3)
		GNLib.AutoTranslate( MConf.LanguageType, "The character have been deleted and the player has been kicked !", function(callback) MMNotification(ply, callback, 0, 3) end )
	end
end

local function RenameCharAdmin(requester, search, charIDToRename, newName)
	local playerFindedEnt = findingPlayer(search)
	if not playerFindedEnt then -- If we haven't find the player in the connected players
		--MMNotification(requester, "We haven't find any players for the argument you supplied: '"..tostring(search).."'", 1, 3)
		GNLib.AutoTranslate( MConf.LanguageType, "We haven't find any players for the argument you supplied !", function(callback) MMNotification(ply, callback, 1, 3) end )
	else
		local request = sql.Query("SELECT CharacterName FROM MetroCharacters WHERE CharacterName = '"..tostring(newName).."'") -- nil if name is not already existing
		if request == nil then
			sql.Query("UPDATE MetroCharacters SET CharacterName = '"..tostring(newName).."' WHERE CharacterOwner = '"..playerFindedEnt:SteamID64().."' AND CharacterID = '"..charIDToRename.."'")
			playerFindedEnt:Kick("Please reconnect to apply changes (Character renamed by an admin)")
			--MMNotification(requester, "The character have been renamed !", 0, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "The character have been renamed !", function(callback) MMNotification(ply, callback, 0, 3) end )
		else
			--MMNotification(requester, "This name is already used !", 1, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "This name is already used !", function(callback) MMNotification(ply, callback, 1, 3) end )
		end
	end
end


--[[ Hooks ]]
hook.Add( "PlayerInitialSpawn", "Metro::MainHook::PlayerInitialSpawn", function(ply)
	if not file.Exists("metro/"..ply:SteamID64()..".txt", "DATA") then
		file.Write("metro/"..ply:SteamID64()..".txt", "")
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
		if MConf.CommandDeleteCharAllowedRanks[ply:GetUserGroup()] then
			if playerInput[2] then
				if playerInput[3] then
					DeleteCharAdmin(ply, playerInput[2], playerInput[3])
				else
					--MMNotification(ply, "You have to specify the character to delete !", 1, 3)
					GNLib.AutoTranslate( MConf.LanguageType, "You have to specify the character to delete !", function(callback) MMNotification(ply, callback, 1, 3) end )
				end
			else
				--MMNotification(ply, "You have to specify the SteamID64 / Player Name / SteamID", 1, 3)
				GNLib.AutoTranslate( MConf.LanguageType, "You have to specify the SteamID64 / Player name / SteamID", function(callback) MMNotification(ply, callback, 1, 3) end )
			end
		else
			GNLib.AutoTranslate( MConf.LanguageType, "You have not access to this command !", function(callback) MMNotification(ply, callback, 1, 3) end )
		end
	elseif playerInput[1] == MConf.CommandRenameChar then
		if MConf.CommandDeleteCharAllowedRanks[ply:GetUserGroup()] then
			if playerInput[2] then
				if playerInput[3] then
					if playerInput[4] then
						RenameCharAdmin(ply, playerInput[2], playerInput[3], table.concat(playerInput, " ", 4) )
					else
						--MMNotification(ply, "You have to provide a new name !", 1, 3)
						GNLib.AutoTranslate( MConf.LanguageType, "You have to provide a new name !", function(callback) MMNotification(ply, callback, 1, 3) end )
					end
				else
					--MMNotification(ply, "You have to specify the character to rename !", 1, 3)
					GNLib.AutoTranslate( MConf.LanguageType, "You have to specify the character to rename !", function(callback) MMNotification(ply, callback, 1, 3) end )
				end
			else
				--MMNotification(ply, "You have to specify the SteamID64 / Player Name / SteamID", 1, 3)
				GNLib.AutoTranslate( MConf.LanguageType, "You have to specify the SteamID64 / Player name / SteamID", function(callback) MMNotification(ply, callback, 1, 3) end )
			end
		else
			GNLib.AutoTranslate( MConf.LanguageType, "You have not access to this command !", function(callback) MMNotification(ply, callback, 1, 3) end )
		end
	elseif playerInput[1] == MConf.CommandDeleteAllData then
		if ply:IsSuperAdmin() then
			if not MetroWhitelistActive() then -- if whitelist is not installed
				sql.Query("DROP TABLE MetroCharacters") -- Delete database
			else -- if whitelist is installed
				if sql.TableExists( "MetroWhitelistJob" ) then
					sql.Query([[
						PRAGMA foreign_keys = OFF; 				-- Disable foreign keys constraint
						DROP TABLE MetroWhitelistJob;			-- Drop table
						PRAGMA foreign_keys = ON;				-- Enable foreign keys
					]])
				end

				if sql.TableExists( "MetroWhitelistCharacters" ) then
					sql.Query([[
						PRAGMA foreign_keys = OFF; 				-- Disable foreign keys constraint
						DROP TABLE MetroWhitelistCharacters;	-- Drop table
						PRAGMA foreign_keys = ON;				-- Enable foreign keys
					]])
				end

				if sql.TableExists( "MetroCharacters" ) then
					sql.Query([[
						PRAGMA foreign_keys = OFF; 				-- Disable foreign keys constraint
						DROP TABLE MetroCharacters;	-- Drop table
						PRAGMA foreign_keys = ON;				-- Enable foreign keys
					]])
				end
			end

			local filesToDelete = file.Find("metro/*", "DATA")
			for _, v in pairs(filesToDelete) do
				file.Delete("metro/"..v)
			end

			GNLib.AutoTranslate( MConf.LanguageType, "Every data from players have been deleted. Server restarting in 5 seconds...", function(callback) MMNotification(ply, callback, 2, 3) end )
			
			timer.Simple(5, function()
				game.ConsoleCommand("changelevel "..game.GetMap().."\n")
			end)
		else
			GNLib.AutoTranslate( MConf.LanguageType, "You have not access to this command !", function(callback) MMNotification(ply, callback, 1, 3) end )
		end
	elseif playerInput[1] == MConf.CommandUnlockData then
		if MConf.CommandUnlockDataAllowedRanks[ply:GetUserGroup()] then
			if playerInput[2] then
				local ent = ply:GetEyeTrace().Entity
				if ent:IsPlayer() then
					if playerInput[2] == "money" then
						sql.Query("UPDATE MetroCharacters SET CharacterMoney = 0 WHERE CharacterOwner = '"..ent:SteamID64().."' AND CharacterID = '"..ent:GetNWInt("Metro::CharacterID").."'")
					elseif playerInput[2] == "health" then
						sql.Query("UPDATE MetroCharacters SET CharacterHealth = NULL WHERE CharacterOwner = '"..ent:SteamID64().."' AND CharacterID = '"..ent:GetNWInt("Metro::CharacterID").."'")
					elseif  playerInput[2] == "armor" then
						sql.Query("UPDATE MetroCharacters SET CharacterArmor = NULL WHERE CharacterOwner = '"..ent:SteamID64().."' AND CharacterID = '"..ent:GetNWInt("Metro::CharacterID").."'")
					elseif  playerInput[2] == "food" then
						sql.Query("UPDATE MetroCharacters SET CharacterFood = NULL WHERE CharacterOwner = '"..ent:SteamID64().."' AND CharacterID = '"..ent:GetNWInt("Metro::CharacterID").."'")
					elseif  playerInput[2] == "weapons" then
						sql.Query("UPDATE MetroCharacters SET CharacterWeapons = NULL WHERE CharacterOwner = '"..ent:SteamID64().."' AND CharacterID = '"..ent:GetNWInt("Metro::CharacterID").."'")
					elseif  playerInput[2] == "pos" then
						sql.Query("UPDATE MetroCharacters SET CharacterPosition = NULL WHERE CharacterOwner = '"..ent:SteamID64().."' AND CharacterID = '"..ent:GetNWInt("Metro::CharacterID").."'")
					elseif  playerInput[2] == "angle" then
						sql.Query("UPDATE MetroCharacters SET CharacterAngle = NULL WHERE CharacterOwner = '"..ent:SteamID64().."' AND CharacterID = '"..ent:GetNWInt("Metro::CharacterID").."'")
					end

					GNLib.AutoTranslate( MConf.LanguageType, "You have reset the value for this player !", function(callback) MMNotification(ply, callback, 0, 3) end )
				else
					GNLib.AutoTranslate( MConf.LanguageType, "You have to look at a player !", function(callback) MMNotification(ply, callback, 1, 3) end )
				end
			else
				GNLib.AutoTranslate( MConf.LanguageType, "You have to specify an argument !", function(callback) MMNotification(ply, callback.." (position, angle, weapons, health, armor, food, money)", 1, 3) end )
			end
		else
			GNLib.AutoTranslate( MConf.LanguageType, "You have not access to this command !", function(callback) MMNotification(ply, callback, 1, 3) end )
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

hook.Add( "PlayerDisconnected", "Metro::MainHook::PlayerDisconnected", function(ply)
	if not MConf.BlacklistTeams[team.GetName(ply:Team())] then
		local actualCharacter = ply:GetNWInt("Metro::CharacterID")
		if not actualCharacter == 0 then
			updateData(true, ply) -- update before player leave
		end
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
		local charChoosed = tonumber(file.Read("metro/"..ply:SteamID64()..".txt", "DATA"))
		if charChoosed then
			PlyDefineChar(charChoosed, ply)
		else
			--MMNotification(ply, "Error, you already playing this character !", 1, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "Error, you already playing this character !", function(callback) MMNotification(ply, callback, 1, 3) end )

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
		else
			--MMNotification(ply, "Error, you already playing this character !", 1, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "Error, you already playing this character !", function(callback) MMNotification(ply, callback, 1, 3) end )

			-- Reopening menu or player will be stucked
			net.Start("Metro::OrderToPlayer")
				net.WriteString("openSpecificMenu")
				net.WriteString("character")
			net.Send(ply)
		end
	elseif request == "deleteChar" then
		local charChoosed = net.ReadInt(4)
		if ply:GetNWInt("Metro::CharacterID") == charChoosed then
			--MMNotification(ply, "Error, you can't delete this character while you're playing !", 1, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "Error, you can't delete this character while you're playing !", function(callback) MMNotification(ply, callback, 1, 3) end )
		else
			sql.Query("DELETE FROM MetroCharacters WHERE CharacterOwner = '"..ply:SteamID64().."' AND CharacterID = '"..charChoosed.."'")
			--MMNotification(ply, "Character deleted !", 0, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "Character deleted !", function(callback) MMNotification(ply, callback, 0, 3) end )
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
			sql.Query("INSERT INTO MetroCharacters(CharacterOwner,CharacterID,CharacterName,CharacterSkin,CharacterBodygroup,CharacterMoney) VALUES('"..ply:SteamID64().."', '"..charChoosed.."', '"..charName.."', '"..charSkin.."', '"..charBodygroup.."', 0)") -- SQL

			--MMNotification(ply, "Character created !", 0, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "Character created !", function(callback) MMNotification(ply, callback, 0, 3) end )
		else
			--MMNotification(ply, "This skin is not allowed for you !", 1, 3)
			GNLib.AutoTranslate( MConf.LanguageType, "This skin is not allowed for you !", function(callback) MMNotification(ply, callback, 1, 3) end )
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