AddonVersion = "1.2.0"
--soundfiles
local LibCopyPaste = LibStub("LibCopyPaste-1.0")
SelectedSound = ""
local AceGUI = LibStub("AceGUI-3.0")

sounds = {"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\alert_bot_loop.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\ass_whip.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\bloodrage_psycho.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\cool_guy.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\darker_secret.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\dwarf5.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\dynamite.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\gachi_scream_extreme.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\gachi_scream.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\geo_fart.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\im_going_to_kill_you.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\Immolate.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\its_cool_guy.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\last_stand_extreme.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\layonhands_low_chest.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\letsrock.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\long_no.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\not_stealth.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\pirates_extreme.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\poe_hillock_ratherbedead.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\poe_sirus_diebeam.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\rise_resurrection.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\ritual.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\slide_flute.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\stealth.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\taunt.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\terrorists_win.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\tonyhawk_trick.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\TrenchGun.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\tygore_ough_1.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\tygore_theyreallcomingagain.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\tyrone_niceandsmooth.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\whatisthat.ogg",
"Interface\\AddOns\\Jarbeatbox\\CustomSounds\\wow_main_theme.ogg"}

matchSounds = {}

--configs
init = false;
SLASH_JARBEATBOXMENU1, SLASH_JARBEATBOXMENU2, SLASH_JARBEATBOXMENU3 = "/jbm","/jbb","/jarbeatbox";
playerName = UnitName('player')
guildUsers = {}
guildUsersCount = 0;
soundEventPrefix = "jarbeatbox"
messageType_Message = "MESSAGE"
messageType_Login = "LOGIN"
messageType_Logout = "LOGOUT"
messageType_LoginSync = "LOGINSYNC"
messageType_LogoutSync = "LOGOUTSYNC"


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
UIMenu.title = UIMenu:CreateFontString(nil, "OVERLAY")
UIMenu.title:SetFontObject("GameFontHighlight")
UIMenu.title:SetPoint("CENTER", UIMenu.TitleBg, "CENTER", 100, 0)
UIMenu.title:SetText("Jarbeatbox Custom Sounds Menu")

UIMenu:Hide();

UIMenu.SearchBox = CreateFrame("EditBox", "Jarbeatbox_SearchBox", UIMenu, "InputBoxTemplate");
UIMenu.SearchBox:SetAutoFocus(false)

UIMenu.SearchBox:SetScript("OnEscapePressed", function(self)
    if self:GetText() == "" then
        UIMenu:Hide();
    else
        self:SetText("");
    end
end)
UIMenu.SearchBox:SetScript("OnTextChanged", function()
    SearchSounds();
end)
UIMenu.SearchBox:SetPoint("Left", UIMenu.TitleBg, "Left", 4, 0);
UIMenu.SearchBox:SetSize(100,20)

UIMenu.ScrollFrame = AceGUI:Create("ScrollFrame", "Jarbeatbox_ScrollFrame", UIMenu, "UIPanelScrollFrameTemplate")
_G["Jarbeatbox_ScrollFrame"] = UIMenu.ScrollFrame.frame
tinsert(UISpecialFrames, "Jarbeatbox_ScrollFrame")
UIMenu:SetScript("OnHide", function(widget) UIMenu.ScrollFrame.frame:Hide() end)

UIMenu.ScrollFrame:SetParent(UIMenu);
UIMenu.ScrollFrame:SetPoint("TOPLEFT", UIMenu.Bg, "TOPLEFT", 5, -5)
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
UIMenu.Options.SelectedSoundText:SetFont("Fonts\\FRIZQT__.TTF", 16)

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
    SendSound("-s "..SelectedSound)
end)

UIMenu.Options.Buttons.PartyButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Party", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.PartyButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", -100, -45);
UIMenu.Options.Buttons.PartyButton:SetSize(100,30);
UIMenu.Options.Buttons.PartyButton:SetText("Party");
UIMenu.Options.Buttons.PartyButton:SetNormalFontObject("GameFontNormalLarge");
UIMenu.Options.Buttons.PartyButton:SetScript("OnClick", function(self)
    SendSound("-p "..SelectedSound)
end)

UIMenu.Options.Buttons.GuildButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Guild", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.GuildButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", 100, 45);
UIMenu.Options.Buttons.GuildButton:SetSize(100,30);
UIMenu.Options.Buttons.GuildButton:SetText("Guild");

UIMenu.Options.Buttons.GuildButton:SetNormalFontObject("GameFontNormalLarge");
UIMenu.Options.Buttons.GuildButton:SetScript("OnClick", function(self)
    SendSound("-g "..SelectedSound)
end)

UIMenu.Options.Buttons.RaidButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Raid", UIMenu.Options.Buttons, "GameMenuButtonTemplate");
UIMenu.Options.Buttons.RaidButton:SetPoint("CENTER", UIMenu.Options.Buttons, "CENTER", 100, 0);
UIMenu.Options.Buttons.RaidButton:SetSize(100,30);
UIMenu.Options.Buttons.RaidButton:SetText("Raid");
UIMenu.Options.Buttons.RaidButton:SetNormalFontObject("GameFontNormalLarge");
UIMenu.Options.Buttons.RaidButton:SetScript("OnClick", function(self)
    SendSound("-r "..SelectedSound)
end)


UIMenu.Options.Buttons.WhisperEditBox = CreateFrame("EditBox", "Jarbeatbox_Sound_Menu_Button_Whisper_EditBox", UIMenu.Options.Buttons, "InputBoxTemplate");
UIMenu.Options.Buttons.WhisperEditBox:SetAutoFocus(false)
UIMenu.Options.Buttons.WhisperEditBox:SetScript("OnEscapePressed", function(self)
    if self:GetText() == "" then
        UIMenu:Hide();
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
    SendSound("-w "..UIMenu.Options.Buttons.WhisperEditBox:GetText().." "..SelectedSound)
end)


local line = UIMenu:CreateTexture()
line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
line:SetColorTexture(.6 ,.6, .6, .6)
line:SetSize(UIMenu.Bg:GetWidth()-12, 2)
line:SetPoint("CENTER", UIMenu.Bg, "CENTER", -1, -3)

local line = UIMenu:CreateTexture()
line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
line:SetColorTexture(.6 ,.6, .6, .6)
line:SetSize(UIMenu.Bg:GetWidth()-12, 2)
line:SetPoint("CENTER", UIMenu.Options.Buttons, "TOP", -1, -3)

child = AceGUI:Create("Frame", nil, UIMenu.ScrollFrame);
--child:SetSize(395, 400);

UIMenu.ScrollFrame:AddChild(child);

function SelectSoundOnClick(self, button, down, four, five)
    SelectedSound = "Interface\\AddOns\\Jarbeatbox\\CustomSounds\\"..self.readableText;
    UIMenu.Options.SelectedSoundText:SetText(self.readableText);
end

function InitUiMenu(matchSounds)
    UIMenu.ScrollFrame:ReleaseChildren();
    for index, value in pairs(matchSounds) do
        local childWidget = AceGUI:Create("Button", value, child, "GameMenuButtonTemplate");
        childWidget.readableText = string.sub(value, 42);
        childWidget:SetCallback("OnClick", SelectSoundOnClick);
        childWidget:SetFullWidth(true);
        --childWidget:SetSize(380,28);
        childWidget:SetText(childWidget.readableText);
        --childWidget:SetNormalFontObject("GameFontNormalLarge");
        --childWidget:SetHighlightFontObject("GameFontHighlightLarge");
        UIMenu.ScrollFrame:AddChild(childWidget);
    end
end

function SearchSounds()
    local localText = UIMenu.SearchBox:GetText()
    if localText == "" then
        matchSounds = sounds;
    else
        for index, value in pairs(sounds) do
            if(string.find(value, localText)) then
                tinsert(matchSounds, value); 
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
            local params = Split(payload);
            type = params[1]
            msg = params[2]
            if type == messageType_Message then
                if(currentHandle ~= nil) then
                    StopSound(currentHandle)
                end
                _, currentHandle = PlaySoundFile(msg, "Master");
            elseif type == messageType_Login or type == messageType_LoginSync then

                if guildUsers[msg] then
                    return;
                else
                    guildUsers[msg] = AddonVersion;
                    guildUsersCount = guildUsersCount + 1;
                    UIMenu.Options.Buttons.GuildButton:SetText("Guild".." ("..guildUsersCount..")");
                end

                if type == messageType_Login then
                    C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGINSYNC "..playerName, "GUILD")
                end
            elseif type == messageType_Logout or type == messageType_LogoutSync then
                if guildUsers[msg] then
                    guildUsers[msg] = nil;
                    guildUsersCount = guildUsersCount - 1;
                    UIMenu.Options.Buttons.GuildButton:SetText("Guild".." ("..guildUsersCount..")");
                else
                    return;
                end               

                if type == messageType_Logout then
                    C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGOUTSYNC "..playerName, "GUILD")
                end     
            end       
        end
    end

    if event == "PLAYER_LOGIN" then
        C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGIN "..playerName, "GUILD")
    end
    
    if event == "PLAYER_LOGOUT" then
        C_ChatInfo.SendAddonMessage(userLoginStatePrefix, "LOGOUT "..playerName, "GUILD")
    end
end)

--register slashcommand handlers
function SlashCmdList.JARBEATBOXMENU(message, editbox)
    if UIMenu:IsShown() then
        UIMenu:Hide();
        UIMenu.ScrollFrame.frame:Hide();
    else
        UIMenu:Show();
        UIMenu.ScrollFrame.frame:Show();
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
    
    for token in string.gmatch(message, "[^%s]+") do

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
        C_ChatInfo.SendAddonMessage(soundEventPrefix, messageType_Message.." "..messageToSend, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage(soundEventPrefix, messageType_Message.." "..messageToSend, channel)
    end
end
