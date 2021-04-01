AddonVersion = "1.2.5"
--soundfiles
local LibCopyPaste = LibStub("LibCopyPaste-1.0")
SelectedSound = ""
local AceGUI = LibStub("AceGUI-3.0")


matchSounds = {}

--configs
init = false;
globalBasePath = "Interface\\AddOns\\Jarbeatbox\\CustomSounds"
globalCurrentTable = sounds["Interface"]["AddOns"]["Jarbeatbox"]["CustomSounds"]
SLASH_JARBEATBOXMENU1, SLASH_JARBEATBOXMENU2, SLASH_JARBEATBOXMENU3 = "/jbm","/jbb","/jarbeatbox";
playerName = UnitName('player')
guildUsers = {}
guildUsersCount = 0;
soundEventPrefix = "jarbeatbox"
messageType_Message = "MESSAGE"
messageType_Login = "LOGIN"
messageType_Logout = "LOGOUT"
messageType_LoginSync = "LOGINSYNC"

function Split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

--init
local f = CreateFrame("Frame")

f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("PLAYER_LOGOUT");
C_ChatInfo.RegisterAddonMessagePrefix(soundEventPrefix);

--ui
local UIMenu = CreateFrame("Frame", "Jarbeatbox_Sound_Menu", UIParent, "BasicFrameTemplateWithInset");
tinsert(UISpecialFrames, UIMenu:GetName())

UIMenu:SetMovable(true);
UIMenu:EnableMouse(true);
UIMenu:RegisterForDrag("LeftButton");
UIMenu:SetScript("OnDragStart", UIMenu.StartMoving);
UIMenu:SetScript("OnDragStop", UIMenu.StopMovingOrSizing);
UIMenu:SetSize(400,480);
UIMenu:SetPoint("CENTER");





UIMenu.SearchBox = CreateFrame("EditBox", "Jarbeatbox_SearchBox", UIMenu, "InputBoxTemplate");

UIMenu.SearchBox:SetAutoFocus(false)

UIMenu.SearchBox:SetScript("OnEscapePressed", function(self)
    if self:GetText() == "" then
        self:ClearFocus();
    else
        self:SetText("");
    end
end)
UIMenu.SearchBox:SetScript("OnTextChanged", function()
    SearchSounds();
end)
UIMenu.SearchBox:SetPoint("Left", UIMenu.TitleBg, "Left", 4, 0);
UIMenu.SearchBox:SetSize(100,20)

function sortedKeys(query, sortFunction)
    local keys, len = {}, 0
    for k,_ in pairs(query) do
        len = len + 1
        keys[len] = k
    end
    table.sort(keys, sortFunction)
    return keys
end

function setSubMenu(table, pullout, basepath)
    for _, k in pairs(sortedKeys(table)) do
        v = table[k]
        if type(v) == "table" and k ~= "hasNestedTables" then 

            if v["hasNestedTables"] == true then   
                local menuItem = AceGUI:Create("Dropdown-Item-Menu")
                if v.size then
                    menuItem:SetText(k.." ("..v.size..")")
                else
                    menuItem:SetText(k)
                end

                local submenu = AceGUI:Create("Dropdown-Pullout")                
                
                local menuBasePath

                if basepath == "" or basepath == nil then                    
                    menuBasePath = k
                else
                    menuBasePath = basepath.."\\"..k
                end                

                menuItem.frame.basepath = menuBasePath

                if v.size then
                    menuItem.frame.table = v

                    menuItem.frame:SetScript("OnClick", function(self)
                        globalBasePath = self.basepath
                        UIMenu.dropDownMenu:SetText(globalBasePath)
                        if self.table ~= nil then
                            globalCurrentTable = self.table
                            SearchSounds()
                        end
                        UIMenu.dropDownMenu.open = nil
                        UIMenu.dropDownMenu.pullout:Close()
                    end)
                end

                setSubMenu(v, submenu, menuBasePath)
                menuItem:SetMenu(submenu)      

                pullout:AddItem(menuItem)
            else
                local subBtn = AceGUI:Create("Dropdown-Item-Execute")
                if v.size then
                    subBtn:SetText(k.." ("..v.size..")")
                else
                    subBtn:SetText(k)
                end

                local btnBasePath

                if basepath == "" or basepath == nil then                    
                    btnBasePath = k
                else
                    btnBasePath = basepath.."\\"..k
                end              

                subBtn.frame.basepath = btnBasePath

                if type(v) == "table" then
                    subBtn.frame.table = v
                end

                subBtn.frame:SetScript("OnClick", function(self)
                    globalBasePath = self.basepath
                    UIMenu.dropDownMenu:SetText(globalBasePath)

                    globalCurrentTable = self.table
                    SearchSounds()
                    UIMenu.dropDownMenu.open = nil
                    UIMenu.dropDownMenu.pullout:Close()
                end)
                pullout:AddItem(subBtn)
            end
        end

    end
end

pullout = AceGUI:Create("Dropdown-Pullout")
setSubMenu(sounds, pullout, "")

UIMenu.dropDownMenu = AceGUI:Create("Dropdown");
UIMenu.dropDownMenu:SetText(globalBasePath)
local Path, Size, Flags = UIMenu.dropDownMenu.text:GetFont()
UIMenu.dropDownMenu.text:SetFont(Path,16,Flags);
UIMenu.dropDownMenu.text:SetJustifyH("CENTER")			
UIMenu.dropDownMenu.text:SetTextColor(0.05,0.63,0.85)

UIMenu.dropDownMenu.pullout = pullout;
UIMenu.dropDownMenu.frame:SetFrameStrata("TOOLTIP")
UIMenu.dropDownMenu:SetPoint("TOPLEFT", UIMenu.Bg, "TOPLEFT", 8, -6)
UIMenu.dropDownMenu:SetPoint("BOTTOMRIGHT", UIMenu.Bg, "TOPRIGHT", -5, -32)



UIMenu.ScrollFrame = AceGUI:Create("ScrollFrame")
_G["Jarbeatbox_ScrollFrame"] = UIMenu.ScrollFrame.frame
tinsert(UISpecialFrames, "Jarbeatbox_ScrollFrame")
UIMenu:SetScript("OnHide", function(widget) 
    UIMenu.ScrollFrame.frame:Hide()
    UIMenu.dropDownMenu.frame:Hide()
    UIMenu.dropDownMenu.open = nil
 end)
 UIMenu:SetScript("OnShow", function(widget) 
    UIMenu.ScrollFrame.frame:Show()
    UIMenu.dropDownMenu.frame:Show()
 end)

UIMenu.ScrollFrame:SetParent(UIMenu.Bg);
UIMenu.ScrollFrame:SetPoint("TOPLEFT", UIMenu.Bg, "TOPLEFT", 5, -30)
UIMenu.ScrollFrame:SetPoint("BOTTOMRIGHT", UIMenu.Bg, "RIGHT", -7, 2)
--selected sound frames
UIMenu.Options = CreateFrame("Frame", "Jarbeatbox_Options_Menu_Parent", UIMenu);
UIMenu.Options:SetPoint("TOPLEFT", UIMenu.Bg, "LEFT")
UIMenu.Options:SetPoint("BOTTOMRIGHT", UIMenu.Bg, "BOTTOMRIGHT")
UIMenu.Options.SelectedSoundFrame = CreateFrame("Frame", "Jarbeatbox_Options_Menu_SelectedSound", UIMenu.Options);
UIMenu.Options.SelectedSoundFrame:SetPoint("TOPLEFT", UIMenu.Options, "TOPLEFT")
UIMenu.Options.SelectedSoundFrame:SetPoint("BOTTOMRIGHT", UIMenu.Options, "RIGHT", 0, 50)
UIMenu.Options.SelectedSoundText = UIMenu.Options.SelectedSoundFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
UIMenu.Options.SelectedSoundText:SetPoint("CENTER", UIMenu.Options.SelectedSoundFrame, "CENTER")
UIMenu.Options.SelectedSoundText:SetFont(Path, 16)

--firing buttons
UIMenu.Options.Buttons = CreateFrame("Frame", "Jarbeatbox_Options_Menu_Buttons", UIMenu.Options);
UIMenu.Options.Buttons:SetPoint("TOPLEFT", UIMenu.Options.SelectedSoundFrame, "BOTTOMLEFT")
UIMenu.Options.Buttons:SetPoint("BOTTOMRIGHT", UIMenu.Options, "BOTTOMRIGHT")

UIMenu.Options.Buttons.SelfButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Self", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.SelfButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", -100, 45);
UIMenu.Options.Buttons.SelfButton:SetSize(100,30);
UIMenu.Options.Buttons.SelfButton:SetText("Self");
UIMenu.Options.Buttons.SelfButton:SetNormalFontObject("GameFontNormalLarge");

UIMenu.Options.Buttons.SelfButton:SetScript("OnClick", function(self)
    SendSound(SelectedSound)
end)

UIMenu.Options.Buttons.SayButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Say", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.SayButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", -100, 0);
UIMenu.Options.Buttons.SayButton:SetSize(100,30);
UIMenu.Options.Buttons.SayButton:SetText("Say");
UIMenu.Options.Buttons.SayButton:SetNormalFontObject("GameFontNormalLarge");

UIMenu.Options.Buttons.SayButton:SetScript("OnClick", function(self)
    SendSound("-s|"..SelectedSound)
end)

UIMenu.Options.Buttons.PartyButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Party", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.PartyButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", -100, -45);
UIMenu.Options.Buttons.PartyButton:SetSize(100,30);
UIMenu.Options.Buttons.PartyButton:SetText("Party");
UIMenu.Options.Buttons.PartyButton:SetNormalFontObject("GameFontNormalLarge");

UIMenu.Options.Buttons.PartyButton:SetScript("OnClick", function(self)
    SendSound("-p|"..SelectedSound)
end)

UIMenu.Options.Buttons.GuildButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Guild", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.GuildButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", 100, 45);
UIMenu.Options.Buttons.GuildButton:SetSize(100,30);
UIMenu.Options.Buttons.GuildButton:SetText("Guild");

UIMenu.Options.Buttons.GuildButton:SetNormalFontObject("GameFontNormalLarge");

UIMenu.Options.Buttons.GuildButton:SetScript("OnClick", function(self)  
    SendSound("-g|"..SelectedSound)
end)
UIMenu.Options.Buttons.GuildButton:SetScript("OnEnter", function(self)
    GameTooltip_SetDefaultAnchor( GameTooltip, UIMenu.Options.Buttons.GuildButton )
    local t = { }
    for k,v in pairs(guildUsers)
    do
        t[#t+1] = tostring(k)..":".." "..tostring(v)
    end
    GameTooltip:SetText(table.concat(t,"\n"))
    GameTooltip:Show()
end)
UIMenu.Options.Buttons.GuildButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)


UIMenu.Options.Buttons.RaidButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Raid", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.RaidButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", 100, 0);
UIMenu.Options.Buttons.RaidButton:SetSize(100,30);
UIMenu.Options.Buttons.RaidButton:SetText("Raid");
UIMenu.Options.Buttons.RaidButton:SetNormalFontObject("GameFontNormalLarge");

UIMenu.Options.Buttons.RaidButton:SetScript("OnClick", function(self)
    SendSound("-r|"..SelectedSound)
end)


UIMenu.Options.Buttons.WhisperEditBox = CreateFrame("EditBox", "Jarbeatbox_Sound_Menu_Button_Whisper_EditBox", UIMenu.Options.Buttons, "InputBoxTemplate");
UIMenu.Options.Buttons.WhisperEditBox:SetAutoFocus(false)
UIMenu.Options.Buttons.WhisperEditBox:SetScript("OnEscapePressed", function(self)
    if self:GetText() == "" then
        self:ClearFocus();
    else
        self:SetText("");
    end
end)
UIMenu.Options.Buttons.WhisperEditBox:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", 102, -35);
UIMenu.Options.Buttons.WhisperEditBox:SetSize(90,30)


UIMenu.Options.Buttons.WhisperButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Whisper", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.WhisperButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", 100, -55);
UIMenu.Options.Buttons.WhisperButton:SetSize(100,30);
UIMenu.Options.Buttons.WhisperButton:SetText("Whisper");
UIMenu.Options.Buttons.WhisperButton:SetNormalFontObject("GameFontNormalLarge");

UIMenu.Options.Buttons.WhisperButton:SetScript("OnClick", function(self)
    local text = UIMenu.Options.Buttons.WhisperEditBox:GetText();
    if text == nil or text == "" then
        print("You must Input a player name!")
        return;
    end
    SendSound("-w|"..UIMenu.Options.Buttons.WhisperEditBox:GetText().."|"..SelectedSound)
end)


local line = UIMenu:CreateTexture()
line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
line:SetColorTexture(.6 ,.6, .6, .6)
line:SetSize(UIMenu.Bg:GetWidth()-12, 2)
line:SetPoint("CENTER", UIMenu.Bg, "CENTER", -1, -3)

line = UIMenu:CreateTexture()
line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
line:SetColorTexture(.6 ,.6, .6, .6)
line:SetSize(UIMenu.Bg:GetWidth()-12, 2)
line:SetPoint("CENTER", UIMenu.Options.Buttons, "TOP", -1, -3)

line = UIMenu:CreateTexture()
line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
line:SetColorTexture(.6 ,.6, .6, .6)
line:SetSize(UIMenu.Bg:GetWidth()-12, 2)
line:SetPoint("TOP", UIMenu.dropDownMenu.frame, "BOTTOM", -1, -3)

--child:SetSize(395, 400);
UIMenu.ScrollFrame:SetLayout("List")
function SelectSoundOnClick(self, button, down, four, five)
    SelectedSound = self.filePath;
    UIMenu.Options.SelectedSoundText:SetText(self.readableText);
end

function InitUiMenu(matchSoundsLocal)
    UIMenu.ScrollFrame:ReleaseChildren();
    for k, key in pairs(sortedKeys(matchSoundsLocal)) do
        value = matchSoundsLocal[key]
        if key ~= "hasNestedTables" and value == true then
            local childWidget = AceGUI:Create("Button");

            local Path, Size, Flags = childWidget.frame.Text:GetFont()
            childWidget.frame.Text:SetFont(Path,12,Flags);
            childWidget.readableText = key--string.match(value, "[^\\]*$");
            childWidget.filePath = globalBasePath.."\\"..key;
            childWidget:SetCallback("OnClick", SelectSoundOnClick);
            childWidget:SetFullWidth(true);
            childWidget:SetHeight(18);
            childWidget:SetText(childWidget.readableText);
            --childWidget:SetNormalFontObject("GameFontNormalLarge");
            --childWidget:SetHighlightFontObject("GameFontHighlightLarge");
            UIMenu.ScrollFrame:AddChild(childWidget);
        end
    end
end

function SearchSounds()
    local localText = UIMenu.SearchBox:GetText()
    if localText == "" then
        matchSounds = globalCurrentTable;
        for k, v in pairs(globalCurrentTable) do
        end
    else
        for index, value in pairs(globalCurrentTable) do
            if(string.find(index, localText)) then
                matchSounds[index] = value; 
            end
        end
    end
    InitUiMenu(matchSounds)
    matchSounds = {}
end

--register events
f:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, payload = select(1, ...);
        if prefix == soundEventPrefix then
            local type, msg;
            local params = Split(payload, "|");
            type = params[1]
            msg = params[2]
            if type == messageType_Message then
                if(currentHandle ~= nil) then
                    StopSound(currentHandle)
                end
                _, currentHandle = PlaySoundFile(msg, "Master");
            elseif type == messageType_Login or type == messageType_LoginSync then

                if type == messageType_Login then
                    C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGINSYNC|"..playerName, "GUILD")
                end

                if guildUsers[msg] ~= nil then
                    return;
                else
                    guildUsers[msg] = AddonVersion;
                    guildUsersCount = guildUsersCount + 1;
                    UIMenu.Options.Buttons.GuildButton:SetText("Guild".." ("..guildUsersCount..")");
                end
            elseif type == messageType_Logout then
                if guildUsers[msg] ~= nil then
                    guildUsers[msg] = nil;
                    guildUsersCount = guildUsersCount - 1;
                    UIMenu.Options.Buttons.GuildButton:SetText("Guild".." ("..guildUsersCount..")");
                else
                    return;
                end   
            end       
        end
    end

    if event == "PLAYER_LOGIN" then
        C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGIN|"..playerName, "GUILD")
    end
    
    if event == "PLAYER_LOGOUT" then
        C_ChatInfo.SendAddonMessage(userLoginStatePrefix, "LOGOUT|"..playerName, "GUILD")
    end
end)

--register slashcommand handlers
function SlashCmdList.JARBEATBOXMENU(message, editbox)
    if UIMenu:IsShown() then
        UIMenu:Hide();
    else
        UIMenu:Show();
    end
end

function SendSound(message)
    if(message == nil or message == '') then
        print("USAGE: /jbb or /jarbeatbox {options} {soundfile}");
        print("All sounds play on the Dialog channel, check your sound settings if you ")
        print("No option specified plays the sound for only you.")
        print("Available options:")
        print("-g | Anyone in guild can hear.")
        print("-s | Anyone in say can hear.")
        print("-p | Anyone in party can hear.")
        print("-r | Anyone in raid can hear.")
        print("-w {playerName} | Only specified player hears.")
        return;
    end

    if(message == "stop")
    then
        if(currentHandle ~= nil) then
            StopSound(currentHandle)
        end
        return;
    end

    option = ""
    channel = "SELF"
    target = playerName
    setOptions = false;
    messageToSend = ""
    
    for token in string.gmatch(message, "[^|]+") do

        if string.sub(token, 0, 1) == '-' then
            option = string.sub(token, 0, 2);
            setOptions = true;
        elseif setOptions == true then
            if(option == "-w" or option == "-W")
            then
                if((channel == "WHISPER" or channel == "SELF") and target == playerName) then
                    target = token
                else
                    channel = "WHISPER"
                end
                setOptions = false;
            end
            
            if(option == "-s" or option == "-S")
            then
                channel = "SAY"
            end
            
            if(option == "-g" or option == "-G")
            then
                channel = "GUILD"
            end
            
            if(option == "-p" or option == "-P")
            then
                channel = "PARTY"
            end
            
            if(option == "-r" or option == "-R")
            then
                channel = "RAID"
            end
        end
        messageToSend = token;
    end

    if(channel == "SELF" or channel == "WHISPER") then
        C_ChatInfo.SendAddonMessage(soundEventPrefix, messageType_Message.."|"..messageToSend, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage(soundEventPrefix, messageType_Message.."|"..messageToSend, channel)
    end
end

UIMenu:Hide();