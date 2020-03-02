-- for a, b in pairs(file.Find("metro_config/metro*", "LUA")) do
    include("metro_config/metro_config_main.lua")
    AddCSLuaFile("metro_config/metro_config_main.lua")
-- end


--[[ defining all local func ]]
local function OptionsMenu() end -- "Options menu"
local function CreateCharacterMainMenu() end -- "Choose a character to create"
local function CreateCharacterFirstMenu() end -- "Choose a name and a sex for your character"
local function CreateCharacterSecondMenu() end -- "Choose a skin & bodygroup"
local function DeleteCharacterMenu() end -- "Confirmer vous de vouloir supprimer votre personnage ?"
local function SecondMenu() end -- main menu "Choose an option"
local function FirstMenu() end -- main menu "Press a key to continue"

local function MMNotification() end -- Receiving notifications from server

--[[ Initialize Vars ]]
local TextAlpha = 0
local backgroundButton = Material("deadman/metro/buttonBackground.png")
local updateCharactersMenu = false

-- Character Creating vars
local characterSex, characterName, characterSkin = nil, nil, MConf.DefaultSkin
local characterBodygroups = ""
local i = 0
while i < MConf.DefaultSkinBodygroups do
	characterBodygroups = characterBodygroups.."0"
	i = i + 1
end



-- [[ Utils func ]]


local function MMNotification(message, notifType, time, sound)
	notification.AddLegacy( message, notifType, time )
	if sound == "" then
		surface.PlaySound( "buttons/button15.wav" )
	elseif sound ~= "noSound" then -- if sound = noSound, no sound will be played
		surface.PlaySound( sound )
	end
end


--[[ Options Menu ]]
-- function OptionsMenu()
-- 	gui.EnableScreenClicker( true )  -- enable mouse

-- 	local mainPanel = vgui.Create( "DFrame" )
-- 	mainPanel:SetSize( ScrW(), ScrH() )
-- 	mainPanel:Center()
--  mainPanel:ShowCloseButton( false )
-- 	mainPanel:SetTitle( "" )

-- 	local background = vgui.Create( "DImage", mainPanel )
-- 	background:SetPos( 0, 0 )
-- 	background:SetSize( ScrW(), ScrH() )
-- 	background:SetImage( "deadman/metro/characterBackground.png" ) -- Set material relative to "garrysmod/materials/"

-- 	local goBack = vgui.Create( "DButton", mainPanel )
-- 	goBack:SetText( "Return to main menu" )
-- 	goBack:SetPos( ScrW()/32, ScrH()/21.6 )
-- 	goBack:SetSize( ScrW()/7.68, ScrH()/21.6 )
-- 	goBack:SetTextColor( Color(255,255,255,255) )
-- 	goBack.DoClick = function()
-- 		mainPanel:Remove()
-- 		gui.EnableScreenClicker( false )  -- disable mouse
-- 		SecondMenu()
-- 	end
-- 	goBack.Paint = function(w, h)
-- 		surface.SetDrawColor( 255, 255, 255, 255 )
-- 		surface.SetMaterial( backgroundButton	)
-- 		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
-- 	end
-- end


--[[ Character Creation menu ]]
function CreateCharacterMainMenu(firstCharTable, secondCharTable, thirdCharTable)

	gui.EnableScreenClicker( true )  -- enable mouse

	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetSize( ScrW(), ScrH() )
	mainPanel:Center()
	mainPanel:ShowCloseButton( false )
	mainPanel:SetTitle( "" )
	mainPanel.Think = function()
		if updateCharactersMenu then
			updateCharactersMenu = false
			mainPanel:Remove()

			net.Start("Metro::PlyRequest")
				net.WriteString("getAllChars")
			net.SendToServer()
		end
	end

	local background = vgui.Create( "DImage", mainPanel )
	background:SetPos( 0, 0 )
	background:SetSize( ScrW(), ScrH() )
	background:SetImage( "deadman/metro/characterBackground.png" ) -- Set material relative to "garrysmod/materials/"

	local goBack = vgui.Create( "DButton", mainPanel )
	goBack:SetText( "Return to main menu" )
	goBack:SetFont("MetroMainMenu_30")
	goBack:SetPos( ScrW()/32, ScrH()/21.6 )
	goBack:SetSize( ScrW()/7.68, ScrH()/21.6 )
	goBack:SetTextColor( Color(255,255,255,255) )
	goBack.DoClick = function()
		mainPanel:Remove()
		gui.EnableScreenClicker( false )  -- disable mouse
		SecondMenu()
	end
	goBack.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	--[[ Char 1 Panel ]]
	if firstCharTable then
		if firstCharTable.name ~= "" and firstCharTable.skin ~= "" then
			local char1Panel = vgui.Create( "DFrame", mainPanel)
			char1Panel:SetPos( ScrW()/7.68, ScrH()/4 )
			char1Panel:SetSize( ScrW()/7.68, ScrH()/2 )
			char1Panel:SetTitle( "" )
			char1Panel:ShowCloseButton(false)
			char1Panel:SetDraggable( false ) 
			function char1Panel:Paint(w, h)
				draw.SimpleText(firstCharTable.name, "MetroMainMenu_20", w/2, h/16, Color(255,255,255), TEXT_ALIGN_CENTER )
				draw.SimpleText("Money: "..tostring(firstCharTable.money).."$", "MetroMainMenu_20", w/2, h/8, Color(255,255,255), TEXT_ALIGN_CENTER )
			end
		
			local char1Skin = vgui.Create( "DModelPanel", char1Panel )
			char1Skin:SetSize( ScrW()/4.26666666667, ScrH()/2.4 )
			char1Skin:SetModel( firstCharTable.skin )
		    char1Skin:CenterHorizontal(0.5)
		    char1Skin:CenterVertical(0.53)
		    char1Skin:SetCamPos( Vector(60,0,50) ) -- recul, rotation, hauteur
		    char1Skin.Entity:SetBodyGroups( firstCharTable.bodygroup ) -- Ca marche !
			function char1Skin:LayoutEntity( Entity ) return end -- disables default rotation
		end
	end

	-- [[ Char 2 Panel ]]
	if secondCharTable then
		if secondCharTable.name ~= "" and secondCharTable.skin ~= "" then
			local char2Panel = vgui.Create( "DFrame", mainPanel)
			char2Panel:SetPos( ScrW()/2.2994011976, ScrH()/4 )
			char2Panel:SetSize( ScrW()/7.68, ScrH()/2 )
			char2Panel:SetTitle( "" )
			char2Panel:ShowCloseButton(false)
			char2Panel:SetDraggable( false ) 
			function char2Panel:Paint(w, h)
				draw.SimpleText(secondCharTable.name, "MetroMainMenu_20", w/2, h/16, Color(255,255,255), TEXT_ALIGN_CENTER )
				draw.SimpleText("Money: "..secondCharTable.money.."$", "MetroMainMenu_20", w/2, h/8, Color(255,255,255), TEXT_ALIGN_CENTER )

			end

			local char2Skin = vgui.Create( "DModelPanel", char2Panel )
			char2Skin:SetSize( ScrW()/4.26666666667, ScrH()/2.4 )
			char2Skin:SetModel( secondCharTable.skin )
		    char2Skin:CenterHorizontal(0.5)
		    char2Skin:CenterVertical(0.53)
		    char2Skin:SetCamPos( Vector(60,0,50) ) -- recul, rotation, hauteur
		    char2Skin.Entity:SetBodyGroups( secondCharTable.bodygroup ) 
			function char2Skin:LayoutEntity( Entity ) return end -- disables default rotation
		end
	end


	--[[ Char 3 Panel ]]
	if thirdCharTable then
		if thirdCharTable.name ~= "" and thirdCharTable.skin ~= "" then
			local char3Panel = vgui.Create( "DFrame", mainPanel)
			char3Panel:SetPos( ScrW()/1.35211267606, ScrH()/4 )
			char3Panel:SetSize( ScrW()/7.68, ScrH()/2 )
			char3Panel:SetTitle( "" )
			char3Panel:ShowCloseButton(false)
			char3Panel:SetDraggable( false ) 
			function char3Panel:Paint(w, h)
				draw.SimpleText(thirdCharTable.name, "MetroMainMenu_20", w/2, h/16, Color(255,255,255), TEXT_ALIGN_CENTER )
				draw.SimpleText("Money: "..thirdCharTable.money.."$", "MetroMainMenu_20", w/2, h/8, Color(255,255,255), TEXT_ALIGN_CENTER )
			end


			local char3Skin = vgui.Create( "DModelPanel", char3Panel )
			char3Skin:SetSize( ScrW()/4.26666666667, ScrH()/2.4 )
			char3Skin:SetModel( thirdCharTable.skin )
		    char3Skin:CenterHorizontal(0.5)
		    char3Skin:CenterVertical(0.53)
		    char3Skin:SetCamPos( Vector(60,0,50) ) -- recul, rotation, hauteur
		    char3Skin.Entity:SetBodyGroups( thirdCharTable.bodygroup ) 
			function char3Skin:LayoutEntity( Entity ) return end -- disables default rotation
		end
	end
	--[[ Create New ]]


	if not firstCharTable then
		local char1New = vgui.Create( "DButton", mainPanel )
		char1New:SetText( "Create character 1" )
		char1New:SetFont( "MetroMainMenu_20" )
		char1New:SetPos( ScrW()/7.68, ScrH()/1.15 )
		char1New:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char1New:SetTextColor( Color(255,255,255,255) )
		char1New.DoClick = function()
			mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse
			CreateCharacterFirstMenu(1)
		end
		char1New.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end
	else
		local char1delete = vgui.Create( "DButton", mainPanel )
		char1delete:SetText( "Delete character 1" )
		char1delete:SetFont( "MetroMainMenu_20" )
		char1delete:SetPos( ScrW()/7.68, ScrH()/1.1 )
		char1delete:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char1delete:SetTextColor( Color(255,255,255,255) )
		char1delete.DoClick = function()
			-- mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse
			DeleteCharacterMenu(1)
		end
		char1delete.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end

		local char1play = vgui.Create( "DButton", mainPanel )
		char1play:SetText( "Play character 1" )
		char1play:SetFont( "MetroMainMenu_20" )
		char1play:SetPos( ScrW()/7.68, ScrH()/1.2 )
		char1play:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char1play:SetTextColor( Color(255,255,255,255) )
		char1play.DoClick = function()
			mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse

			net.Start("Metro::PlyRequest")
				net.WriteString("chooseChar")
				net.WriteInt(1, 4)
			net.SendToServer()
		end
		char1play.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end
	end

	if not secondCharTable then
		local char2New = vgui.Create( "DButton", mainPanel )
		char2New:SetText( "Create character 2" )
		char2New:SetFont( "MetroMainMenu_20" )
		char2New:SetPos( ScrW()/2.2994011976 , ScrH()/1.15 )
		char2New:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char2New:SetTextColor( Color(255,255,255,255) )
		char2New.DoClick = function()
			mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse
			CreateCharacterFirstMenu(2)
		end
		char2New.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end
	else
		local char2delete = vgui.Create( "DButton", mainPanel )
		char2delete:SetText( "Delete character 2" )
		char2delete:SetFont( "MetroMainMenu_20" )
		char2delete:SetPos( ScrW()/2.2994011976 , ScrH()/1.1 )
		char2delete:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char2delete:SetTextColor( Color(255,255,255,255) )
		char2delete.DoClick = function()
			-- mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse
			DeleteCharacterMenu(2)
		end
		char2delete.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end

		local char2play = vgui.Create( "DButton", mainPanel )
		char2play:SetText( "Play character 2" )
		char2play:SetFont( "MetroMainMenu_20" )
		char2play:SetPos( ScrW()/2.2994011976 , ScrH()/1.2 )
		char2play:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char2play:SetTextColor( Color(255,255,255,255) )
		char2play.DoClick = function()
			mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse

			net.Start("Metro::PlyRequest")
				net.WriteString("chooseChar")
				net.WriteInt(2, 4)
			net.SendToServer()
		end
		char2play.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end
	end

	if not thirdCharTable then
		local char3New = vgui.Create( "DButton", mainPanel )
		char3New:SetText( "Create character 3" )
		char3New:SetFont( "MetroMainMenu_20" )
		char3New:SetPos( ScrW()/1.35211267606, ScrH()/1.15 )
		char3New:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char3New:SetTextColor( Color(255,255,255,255) )
		char3New.DoClick = function()
			mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse
			CreateCharacterFirstMenu(3)
		end
		char3New.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end
	else
		local char3delete = vgui.Create( "DButton", mainPanel )
		char3delete:SetText( "Delete character 3" )
		char3delete:SetFont( "MetroMainMenu_20" )
		char3delete:SetPos( ScrW()/1.35211267606, ScrH()/1.1 )
		char3delete:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char3delete:SetTextColor( Color(255,255,255,255) )
		char3delete.DoClick = function()
			-- mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse
			DeleteCharacterMenu(3)
		end
		char3delete.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end

		local char3play = vgui.Create( "DButton", mainPanel )
		char3play:SetText( "Play character 3" )
		char3play:SetFont( "MetroMainMenu_20" )
		char3play:SetPos( ScrW()/1.35211267606, ScrH()/1.2 )
		char3play:SetSize( ScrW()/7.68, ScrH()/21.6 )
		char3play:SetTextColor( Color(255,255,255,255) )
		char3play.DoClick = function()
			mainPanel:Remove()
			gui.EnableScreenClicker( false )  -- disable mouse

			net.Start("Metro::PlyRequest")
				net.WriteString("chooseChar")
				net.WriteInt(3, 4)
			net.SendToServer()
		end
		char3play.Paint = function(w, h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( backgroundButton	)
			surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
		end
	end
end

--[[ First step: Name choose ]]
function CreateCharacterFirstMenu(characterID)
	gui.EnableScreenClicker( true )  -- enable mouse

	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetSize( ScrW(), ScrH() )
	mainPanel:Center()
	mainPanel:ShowCloseButton( false )
	mainPanel:SetTitle( "" )

	local background = vgui.Create( "DImage", mainPanel )
	background:SetPos( 0, 0 )
	background:SetSize( ScrW(), ScrH() )
	background:SetImage( "deadman/metro/characterBackground.png" ) -- Set material relative to "garrysmod/materials/"

	local goBack = vgui.Create( "DButton", mainPanel )
	goBack:SetText( "Go back" )
	goBack:SetFont("MetroMainMenu_30")
	goBack:SetPos( ScrW()/32, ScrH()/21.6 )
	goBack:SetSize( ScrW()/7.68, ScrH()/21.6 )
	goBack:SetTextColor( Color(255,255,255,255) )
	goBack.DoClick = function()
		mainPanel:Remove()

		net.Start("Metro::PlyRequest")
			net.WriteString("getAllChars")
		net.SendToServer()
	end
	goBack.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local nameTextEntry = vgui.Create( "GNTextEntry", mainPanel ) -- create the form as a child of frame
	nameTextEntry:SetPos( 0, 0 )
	nameTextEntry:SetSize( 200, 50 )
	nameTextEntry:SetTitle( "Name for your character" )
	if characterName ~= nil then
		nameTextEntry:SetText( characterName )
	end
	nameTextEntry:CenterHorizontal(0.5)
	nameTextEntry:CenterVertical(0.5)
	nameTextEntry:MakePopup()
	nameTextEntry:SetDrawLanguageID( false ) 
	nameTextEntry:SetEditable( true )
	nameTextEntry:SetPlaceholderText( "Name for your character" )

	local femaleButton = vgui.Create( "DButton", mainPanel )
	femaleButton:SetText( "Female Character" )
	femaleButton:SetPos( ScrW()/1.4, ScrH()/1.5 )
	femaleButton:SetSize( ScrW()/7.68, ScrH()/21.6 )
	femaleButton:SetTextColor( Color(255,255,255,255) )
	femaleButton.DoClick = function()
		characterSex = "female"

		if nameTextEntry:GetValue() ~= "" and #nameTextEntry:GetValue() >= MConf.CharacterMinLength and #nameTextEntry:GetValue() <= MConf.CharacterMaxLength then
			mainPanel:Remove()
			characterName = nameTextEntry:GetValue()

			net.Start("Metro::PlyRequest")
				net.WriteString("checkName")
				net.WriteString(characterName)
				net.WriteInt(characterID, 4)
			net.SendToServer()
		else
			notification.AddLegacy( "Your name is not long enough !", NOTIFY_ERROR , 4 )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end
	femaleButton.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local maleButton = vgui.Create( "DButton", mainPanel )
	maleButton:SetText( "Male Character" )
	maleButton:SetPos( ScrW()/2.3, ScrH()/1.5 )
	maleButton:SetSize( ScrW()/7.68, ScrH()/21.6 )
	maleButton:SetTextColor( Color(255,255,255,255) )
	maleButton.DoClick = function()
		characterSex = "male"

		if nameTextEntry:GetValue() ~= "" and #nameTextEntry:GetValue() >= MConf.CharacterMinLength and #nameTextEntry:GetValue() <= MConf.CharacterMaxLength then
			mainPanel:Remove()
			characterName = nameTextEntry:GetValue()

			net.Start("Metro::PlyRequest")
				net.WriteString("checkName")
				net.WriteString(characterName)
				net.WriteInt(characterID, 4)
			net.SendToServer()
		else
			notification.AddLegacy( "Your name is not long enough !", NOTIFY_ERROR , 4 )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end
	maleButton.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local actualSkin = vgui.Create( "DModelPanel", mainPanel )
	actualSkin:SetSize( ScrW()/2.5, ScrH()/1.5 )
	actualSkin:SetModel( characterSkin )
    actualSkin:CenterHorizontal(0.2)
    actualSkin:CenterVertical(0.5)
    actualSkin:SetCamPos( Vector(75,0,50) ) -- recul, rotation, hauteur
	function actualSkin:LayoutEntity( Entity ) return end -- disables default rotation
end

function CreateCharacterSecondMenu(characterID, name)
	gui.EnableScreenClicker( true )  -- enable mouse

	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetSize( ScrW(), ScrH() )
	mainPanel:Center()
	mainPanel:ShowCloseButton( false )
	mainPanel:SetTitle( "" )

	local background = vgui.Create( "DImage", mainPanel )
	background:SetPos( 0, 0 )
	background:SetSize( ScrW(), ScrH() )
	background:SetImage( "deadman/metro/characterBackground.png" ) -- Set material relative to "garrysmod/materials/"

	local goBack = vgui.Create( "DButton", mainPanel )
	goBack:SetText( "Go back" )
	goBack:SetFont("MetroMainMenu_30")
	goBack:SetPos( ScrW()/32, ScrH()/21.6 )
	goBack:SetSize( ScrW()/7.68, ScrH()/21.6 )
	goBack:SetTextColor( Color(255,255,255,255) )
	goBack.DoClick = function()
		mainPanel:Remove()

		CreateCharacterFirstMenu(characterID)
	end
	goBack.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local actualSkin = vgui.Create( "DModelPanel", mainPanel )
	actualSkin:SetSize( ScrW()/2.5, ScrH()/1.5 )
	actualSkin:SetModel( characterSkin )
    actualSkin:CenterHorizontal(0.2)
    actualSkin:CenterVertical(0.5)
    actualSkin:SetCamPos( Vector(75,0,50) ) -- recul, rotation, hauteur
    actualSkin.Entity:SetBodyGroups( characterBodygroups ) 
	function actualSkin:LayoutEntity( Entity ) return end -- disables default rotation

	local skinList = vgui.Create( "GNComboBox", mainPanel )
	skinList:SetPos( 0, 0 )
	skinList:SetSize( 300, ScrH()/54 )
    skinList:CenterHorizontal(0.5)
    skinList:CenterVertical(0.1)
	skinList:SetValue( "Choose a skin" )
	if characterSex == "male" then
		for _, tableValue in pairs(MConf.BaseSkinsMale) do
			for rankAllowedID, _ in pairs(tableValue.RankAllowed) do
				if rankAllowedID == LocalPlayer():GetUserGroup() then
					skinList:AddChoice( tableValue.Model )
				end
			end
		end
	else
		for _, tableValue in pairs(MConf.BaseSkinsFemale) do
			for rankAllowedID, _ in pairs(tableValue.RankAllowed) do
				if tableValue.RankAllowed == LocalPlayer():GetUserGroup() then
					skinList:AddChoice( tableValue.Model )
				end
			end
		end
	end
	skinList.OnSelect = function( self, index, value )
		characterSkin = value
		mainPanel:Remove()
		CreateCharacterSecondMenu(characterID)
	end

	local pos = 0.5
	for id, _ in pairs(LocalPlayer():GetBodyGroups()) do
		local bodygroupList = vgui.Create( "GNComboBox", mainPanel )
		bodygroupList:SetPos( 0, 0 )
		bodygroupList:SetSize( 150, 20 )
	    bodygroupList:CenterHorizontal(0.5)
	    bodygroupList:CenterVertical(pos)
		bodygroupList:SetValue( LocalPlayer():GetBodygroupName( 0 ).." "..id  )
		for k, v in pairs(LocalPlayer():GetBodyGroups()[id].submodels ) do
			bodygroupList:AddChoice( k )
		end
		bodygroupList.OnSelect = function( self, index, value )
			local bodygroupsTable = string.ToTable( characterBodygroups )
			table.remove(bodygroupsTable, id)
			table.insert(bodygroupsTable, id, value) 

			characterBodygroups = table.concat( bodygroupsTable )

			mainPanel:Remove()
			CreateCharacterSecondMenu(characterID)
		end
		pos = pos - 0.05
	end

	local validateButton = vgui.Create( "DButton", mainPanel )
	validateButton:SetText( "Validate" )
	validateButton:SetPos( 0, 0 )
	validateButton:SetSize( ScrW()/7.68, ScrH()/21.6 )
    validateButton:CenterHorizontal(0.5)
    validateButton:CenterVertical(0.8)
	validateButton:SetTextColor( Color(255,255,255,255) )
	validateButton.DoClick = function()
		mainPanel:Remove()

		net.Start("Metro::PlyRequest")
			net.WriteString("createCharacter")
			net.WriteInt(characterID, 4)
			net.WriteString(characterName)
			net.WriteString(characterBodygroups)
			net.WriteString(characterSkin)
		net.SendToServer()

		characterSex, characterName, characterBodygroups, characterSkin = nil, nil, "00000", "models/half-dead/metroll/m1b1.mdl"
	end
	validateButton.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end
end

function DeleteCharacterMenu(characterID)
	gui.EnableScreenClicker( true )  -- enable mouse
	local deletePanelNoOutsideClick = vgui.Create( "DFrame" )
	deletePanelNoOutsideClick:SetSize( ScrW(), ScrH() )
	deletePanelNoOutsideClick:Center()
	deletePanelNoOutsideClick:SetTitle( "" )
	deletePanelNoOutsideClick:ShowCloseButton( false )
	deletePanelNoOutsideClick.Paint = function(w, h) end -- Disable the grey screen because the panel is 100% of the screen

	local mainDeletePanel = vgui.Create( "DFrame", deletePanelNoOutsideClick )
	mainDeletePanel:SetSize( ScrW()/4, ScrH()/4 )
	mainDeletePanel:Center()
	mainDeletePanel:SetTitle( "" )

	local background = vgui.Create( "DImage", mainDeletePanel )
	background:SetPos( 0, 0 )
	background:SetSize( ScrW(), ScrH() )
	background:SetImage( "deadman/metro/deleteBackground.png" ) -- Set material relative to "garrysmod/materials/"

	local cancel = vgui.Create( "DButton", mainDeletePanel )
	cancel:SetText( "Cancel suppression" )
	cancel:SetPos( 0, 0 )
	cancel:SetSize( ScrW()/8, ScrH()/21.6 )
	cancel:CenterHorizontal(0.5)
	cancel:CenterVertical(0.7)
	cancel:SetTextColor( Color(255,255,255,255) )
	cancel.DoClick = function()
		deletePanelNoOutsideClick:Remove()
		gui.EnableScreenClicker( true )  -- disable mouse
	end
	cancel.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local validateDelete = vgui.Create( "DButton", mainDeletePanel )
	validateDelete:SetText( "Validate suppresion" )
	validateDelete:SetPos( 0, 0 )
	validateDelete:SetSize( ScrW()/8, ScrH()/21.6 )
	validateDelete:CenterHorizontal(0.5)
	validateDelete:CenterVertical(0.3)
	validateDelete:SetTextColor( Color(255,255,255,255) )
	validateDelete.DoClick = function()
		deletePanelNoOutsideClick:Remove()
		gui.EnableScreenClicker( true )  -- disable mouse

		updateCharactersMenu = true

		net.Start("Metro::PlyRequest")
			net.WriteString("deleteChar")
			net.WriteInt(characterID, 4)
		net.SendToServer()
	end
	validateDelete.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end
end

--[[ Choose Option menu (play last character, settings...) ]]
function SecondMenu()
	gui.EnableScreenClicker( true )  -- enable mouse

	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetSize( ScrW(), ScrH() )
	mainPanel:Center()
	mainPanel:ShowCloseButton( false )
	mainPanel:SetTitle( "" )

	local background = vgui.Create( "DImage", mainPanel )
	background:SetPos( 0, 0 )
	background:SetSize( ScrW(), ScrH() )
	background:SetImage( "deadman/metro/mainBackground.png" ) -- Set material relative to "garrysmod/materials/"

	local exitMenu = vgui.Create( "DButton", mainPanel )
	exitMenu:SetText( "Exit menu" )
	exitMenu:SetFont("MetroMainMenu_30")
	exitMenu:SetPos( ScrW()/32, ScrH()/21.6 )
	exitMenu:SetSize( ScrW()/7.68, ScrH()/21.6 )
	exitMenu:SetTextColor( Color(255,255,255,255) )
	exitMenu.DoClick = function()
		if LocalPlayer():GetNWInt("Metro::CharacterID") ~= 0 then
			mainPanel:Remove()
			gui.EnableScreenClicker( false )

			net.Start("Metro::UserFinishMenu")
			net.SendToServer()
		else
			notification.AddLegacy( "You must have choosed a character first !", NOTIFY_ERROR , 4 )
			surface.PlaySound( "buttons/button15.wav" )
		end
	end
	exitMenu.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local lastCharacterButton = vgui.Create( "DButton", mainPanel )
	lastCharacterButton:SetText( "Play Last character" )
	lastCharacterButton:SetPos( ScrW()/7.68, ScrH()/1.2 )
	lastCharacterButton:SetSize( ScrW()/7.68, ScrH()/21.6 )
	lastCharacterButton:SetTextColor( Color(255,255,255,255) )
	lastCharacterButton.DoClick = function()
		mainPanel:Remove()
		gui.EnableScreenClicker( false )  -- disable mouse

		net.Start("Metro::PlyRequest")
			net.WriteString("playLastChar")
		net.SendToServer()
	end
	lastCharacterButton.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local newCharacterButton = vgui.Create( "DButton", mainPanel )
	newCharacterButton:SetText( "Character Creation" )
	newCharacterButton:SetPos( ScrW()/2.2994011976 , ScrH()/1.2 )
	newCharacterButton:SetSize( ScrW()/7.68, ScrH()/21.6 )
	newCharacterButton:SetTextColor( Color(255,255,255,255) )
	newCharacterButton.DoClick = function()
		gui.EnableScreenClicker( false )  -- disable mouse

		net.Start("Metro::PlyRequest")
			net.WriteString("getAllChars")
		net.SendToServer()

		-- Timer otherwise, we see the game for minus than 1 seconds
		timer.Simple(1, function()
			mainPanel:Remove()
		end)
	end
	newCharacterButton.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end

	local optionsMenu = vgui.Create( "DButton", mainPanel )
	optionsMenu:SetText( "Settings" )
	optionsMenu:SetPos( ScrW()/1.35211267606, ScrH()/1.2 )
	optionsMenu:SetSize( ScrW()/7.68, ScrH()/21.6 )
	optionsMenu:SetTextColor( Color(255,255,255,255) )
	optionsMenu.DoClick = function()
		mainPanel:Remove()
		gui.EnableScreenClicker( false )  -- disable mouse
		OptionsMenu()
	end
	optionsMenu.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( backgroundButton	)
		surface.DrawTexturedRect( 0, 0, 512, 512 ) -- The size don't matter since it will not be bigger than the button
	end
end


--[[ Press a key to continue menu ]]
function FirstMenu()
	gui.EnableScreenClicker( false ) -- disable mouse 

	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetSize( ScrW(), ScrH() )
	mainPanel:Center()
	mainPanel:SetTitle( "" )
	mainPanel:ShowCloseButton(false)
	mainPanel.Think = function(self)
		keyCount = 1
		while keyCount < 103 do
			if input.IsKeyDown(keyCount) then
				mainPanel:Remove()
				SecondMenu()
			end
			keyCount = keyCount + 1
		end

		if TextAlpha >= 254 then
			TextAlpha = 0
		end
		TextAlpha = TextAlpha + 1
	end

	local image = vgui.Create( "DImage", mainPanel )
	image:SetPos( 0, 0 )
	image:SetSize( ScrW(), ScrH() )
	image:SetImage( "deadman/metro/metro.png" ) -- Set material relative to "garrysmod/materials/"

	local label = vgui.Create( "DLabel", mainPanel )
	label:SizeToContentsX( ScrW()/3.2 )
	label:SizeToContentsY( ScrH()/54 )
	label:SetFont( "MetroMainMenu_30" )
	label:SetPos( ScrW()/1.5, ScrH()/1.1 )
	label:SetText( "APPUYEZ SUR UNE TOUCHE POUR CONTINUER" )
	label.Paint = function()
		label:SetTextColor( Color( 255, 255, 255, TextAlpha ) )
	end
end



--[[ Net receive ]]

net.Receive("Metro::OrderToPlayer", function()
	local order = net.ReadString()
	if order == "receiveAllCharacters" then
		local charTable = net.ReadTable()
		CreateCharacterMainMenu(charTable[1], charTable[2], charTable[3])
	elseif order == "nameAvailable" then
		local bool = net.ReadBool() -- if name is available
		local charID = net.ReadInt(4)
		local name = net.ReadString()
		CreateCharacterSecondMenu(charID, name)
	elseif order == "openMainMenu" then
		timer.Simple(0.1, function()
			FirstMenu()
		end)
	elseif order == "openSpecificMenu" then
		local menuToOpen = net.ReadString()
		if menuToOpen == "main" then
			SecondMenu()
		elseif menuToOpen == "character" then
			net.Start("Metro::PlyRequest")
				net.WriteString("getAllChars")
			net.SendToServer()
		end
	elseif order == "notification" then
		MMNotification(net.ReadString(), net.ReadInt(4), net.ReadInt(4), net.ReadString()) -- Msg, type, time, sound
	end
end)




--[[ Font part ]]
surface.CreateFont("MetroMainMenu_30", {
	font = "Arial",
	extended = false,
	size = 30,
})

surface.CreateFont("MetroMainMenu_20", {
	font = "Arial",
	extended = false,
	size = 20,
})