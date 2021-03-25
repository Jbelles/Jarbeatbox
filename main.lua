--soundfiles
local LibCopyPaste = LibStub("LibCopyPaste-1.0")
SelectedSound = ""

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

--configs
init = false;
SLASH_JARBEATBOXMENU1, SLASH_JARBEATBOXMENU2, SLASH_JARBEATBOXMENU3 = "/jbm","/jbb","/jarbeatbox";

playerName = UnitName('player')
eventPrefix = "jarbeatbox"

--init
local f = CreateFrame("Frame")

f:RegisterEvent("CHAT_MSG_ADDON");
C_ChatInfo.RegisterAddonMessagePrefix(eventPrefix);

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
UIMenu.title:SetPoint("CENTER", UIMenu.TitleBg, "CENTER", 0, 0)
UIMenu.title:SetText("Jarbeatbox Custom Sounds Menu")
UIMenu:Hide();

UIMenu.ScrollFrame = CreateFrame("ScrollFrame", nil, UIMenu, "UIPanelScrollFrameTemplate")
UIMenu.ScrollFrame:SetPoint("TOPLEFT", UIMenu.Bg, "TOPLEFT", 0, -5)
UIMenu.ScrollFrame:SetPoint("BOTTOMRIGHT", UIMenu.Bg, "RIGHT")
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
    UIMenu:Hide();
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

child = CreateFrame("Frame", nil, UIMenu.ScrollFrame);
child:SetSize(395, 400);

UIMenu.ScrollFrame:SetScrollChild(child);

function SelectSoundOnClick(self, button, down)
    SelectedSound = "Interface\\AddOns\\Jarbeatbox\\CustomSounds\\"..self:GetText();
    UIMenu.Options.SelectedSoundText:SetText(self:GetText());
end

function InitUiMenu()
    for index, value in pairs(sounds) do
        child["Jarbeatbox_Sound_Menu_Option"..index] = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Option"..index, child, "GameMenuButtonTemplate");
        child["Jarbeatbox_Sound_Menu_Option"..index]:SetScript("OnClick", SelectSoundOnClick);
        child["Jarbeatbox_Sound_Menu_Option"..index]:SetSize(380,28);
        child["Jarbeatbox_Sound_Menu_Option"..index]:SetPoint("TOP", 0, (-30 * index) + 26);
        child["Jarbeatbox_Sound_Menu_Option"..index]:SetText(string.sub(value, 42));
        child["Jarbeatbox_Sound_Menu_Option"..index]:SetNormalFontObject("GameFontNormalLarge");
        child["Jarbeatbox_Sound_Menu_Option"..index]:SetHighlightFontObject("GameFontHighlightLarge");
    end
end


if init == false then
    InitUiMenu();
    init = true;
end

--register events

f:SetScript("OnEvent", function(self, event, ...)
    local prefix, msg = select(1, ...);
    if prefix == eventPrefix then
        if(currentHandle ~= nil) then
            StopSound(currentHandle)
        end
        _, currentHandle = PlaySoundFile(msg, "Master");
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
        C_ChatInfo.SendAddonMessage(eventPrefix, messageToSend, "WHISPER", target)
    else
        C_ChatInfo.SendAddonMessage(eventPrefix, messageToSend, channel)
    end
end
