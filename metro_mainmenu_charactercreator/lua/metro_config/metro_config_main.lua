MConf = MConf or {}
MConf.MainVersion = 1.5 -- Don't touch it !

--[[ Skins ]]
MConf.DefaultSkin = "models/half-dead/metroll/m1b1.mdl" -- default skin
MConf.DefaultSkinBodygroups = 5 -- How much bodygroups category is available in the default skin ? (Don't touch it if you don't know what is it !)

MConf.BaseSkinsMale = { -- Male skins
	{
		["Model"] = "models/half-dead/metroll/m1b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m2b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m3b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m4b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m5b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m6b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m7b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m8b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/m9b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/a1b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/a2b1.mdl", 
		["RankAllowed"] = {
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/a3b1.mdl", 
		["RankAllowed"] = {
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/a4b1.mdl", 
		["RankAllowed"] = {
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/a5b1.mdl", 
		["RankAllowed"] = {
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/a6b1.mdl", 
		["RankAllowed"] = {
			["mod"] = true,
			["superadmin"] = true,
		}
	}
}

MConf.BaseSkinsFemale = { -- Female skins
	{
		["Model"] = "models/half-dead/metroll/f1b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/f2b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/f3b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/f4b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/f6b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	},
	{
		["Model"] = "models/half-dead/metroll/f7b1.mdl", 
		["RankAllowed"] = {
			["user"] = true,
			["vip"] = true,
			["mod"] = true,
			["superadmin"] = true,
		}
	}
}

--[[ Blacklist team (the skin won't be applied to these teams) ]]
MConf.BlacklistTeams = {
	["Staff"] = true,
	["Dictator"] = true,
	["Random Cop"] = true,
}


--[[ Characters creating part ]]
MConf.CharacterMinLength = 5 -- Min caracters in character name
MConf.CharacterMaxLength = 40 -- Max caracters in character name



--[[ Autosave part ]]
MConf.AutosaveTime = 30 -- every 30 seconds we gonna update the data for each connected players (money, name....)
MConf.SaveHealth = true -- Should we save and apply character Health ?
	MConf.SaveHealthBlacklistedTeams = { -- Theses teams won't be affected by the save for the Health
		["Staff"] = true,
		["Survivor from VDNKH"] = true,
	}
MConf.SaveArmor = true -- Should we save and apply character Armor ?
	MConf.SaveArmorBlacklistedTeams = { -- Theses teams won't be affected by the save for the Armor
		["Staff"] = true,
		["Cops"] = true,
	}
MConf.SaveFood = true -- Should we save and apply character Food ?
	MConf.SaveFoodBlacklistedTeams = { -- Theses teams won't be affected by the save for the Food
		["Staff"] = true,
		["Cook"] = true,
	}
MConf.SaveWeapons = true -- Should we save and apply character Weapons ?
	MConf.SaveWeaponsBlacklistedTeams = { -- Theses teams won't be affected by the save for the Weapons
		["Staff"] = true,
		["Cops"] = true,
		["Robbber"] = true,
	}
MConf.SavePosition = true -- Should we save and apply character Position ?
	MConf.SavePositionBlacklistedTeams = { -- Theses teams won't be affected by the save for the Position
		["Staff"] = true,
		["Fix Team"] = true,
	}
	MConf.SaveAngle = false -- Should we save and apply character Angle ? ACTIVE ONLY IF POSITION IS ENABLED
							-- if you have a third person addon, desactive it



--[[ Commands part ]]
MConf.CommandOpenMenu = "!char" -- Command to open the menu
MConf.CommandDeleteChar = "!charDelete" -- format: "!characterDelete <SteamID64 | SteamID | Name> <characterID>"
MConf.CommandRenameChar = "!charRename" -- format: "!characterRename <SteamID64 | SteamID | Name> <characterID> <newName>"
	MConf.CommandDeleteCharAllowedRanks = { -- Ranks wich have access to the delete Command AND rename command
		["superadmin"] = true,
		["admin"] = true,
	}
MConf.CommandUnlockData = "!charUnlock" -- formatl: "!charUnlock <pos | angle | weapons | health | armor | food | money>" while looking at a player
	MConf.CommandUnlockDataAllowedRanks = { -- Ranks wich could access to the unlock command
		["superadmin"] = true,
		["admin"] = true,
		["mod"] = true,
	}

MConf.CommandDeleteAllData = "!characterDeleteAll" 	-- BE CAREFULL, THIS WILL DELETE ALL THE CHARACTERS TABLE (Will restart server). Only allowed to superadmins
													-- If you have the whitelist addon, every whitelist will be removed too