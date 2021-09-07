AddonVersion = "2.0.0"

--soundfiles
SelectedSound = ""
AceGUI = LibStub("AceGUI-3.0")


matchSounds = {}

--configs

lastSentMessageTimestamp = nil
currentHandle = nil
init = false;
globalBasePath = "Interface\\AddOns\\Jarbeatbox\\CustomSounds"
globalCurrentTable = sounds["Interface"]["AddOns"]["Jarbeatbox"]["CustomSounds"]
SLASH_JARBEATBOXMENU1, SLASH_JARBEATBOXMENU2, SLASH_JARBEATBOXMENU3 = "/jbm","/jbb","/jarbeatbox";
SLASH_JARBEATBOXCONSOLE1, SLASH_JARBEATBOXCONSOLE2, SLASH_JARBEATBOXCONSOLE2 = "/jbc","/jbbc", "/jarbeatboxconsole"
playerName = UnitName('player')
guildUsers = { [0] = {[playerName] = true}}
LogTable = nil
guildUsersCount = 1;
local favoritesMenuItemReference
quorumId = 0;
channels = {}
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
f:RegisterEvent("PLAYER_LOGOUT");
f:RegisterEvent("PLAYER_CAMPING");
f:RegisterEvent("PLAYER_QUITING");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");
f:RegisterEvent("LOGOUT_CANCEL");

hooksecurefunc("CancelLogout", function()
    _logoutThread:Cancel()
end)

C_ChatInfo.RegisterAddonMessagePrefix(soundEventPrefix);

function sortedKeys(query, sortFunction)
    local keys, len = {}, 0
    for k,_ in pairs(query) do
        len = len + 1
        keys[len] = k
    end
    table.sort(keys, sortFunction)
    return keys
end


local UIMenu;

local CurrTab;

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID());

    if CurrTab ~= self then
        CurrTab.content:Hide();
        CurrTab = self;
    end

    self.content:Show();
end

local function SetTabs(numTabs, ...)

    UIMenu.numTabs = numTabs;

    local frameName = UIMenu:GetName();

    for i = 1, numTabs do 
        local tab = CreateFrame("Button", frameName.."Tab"..i, UIMenu, "CharacterFrameTabButtonTemplate");

        tab:SetID(i);
        tab:SetText(select(i, ...));
        tab:SetScript("OnClick", Tab_OnClick);

        if i == 1 then
            tab.content = UIMenu.Tab1
        elseif i == 2 then
            tab.content = CreateFrame("Frame", "Jarbeatbox_Sound_Menu_Tab_"..i, UIMenu, nil);
            tab.content:SetSize(400,480); 
            tab.content.text = tab.content:CreateFontString(nil,"ARTWORK") 
            tab.content.text:SetJustifyH("LEFT")
            tab.content.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
            tab.content.text:SetPoint("TOPLEFT", UIMenu.Bg, "TOPLEFT", 5, -5)
            tab.content.text:SetText("No Logs Yet")
            tab.content:SetPoint("CENTER");
            tab.content:Hide();    
        elseif i == 3 then
            tab.content = CreateFrame("Frame", "Jarbeatbox_Sound_Menu_Tab_"..i, UIMenu, nil);
            tab.content:SetSize(400,480);

            tab.content.PlayerBlockBox = CreateFrame("EditBox", "Jarbeatbox_PlayerBlockBox", tab.content, "InputBoxTemplate");
            tab.content.PlayerBlockBox:SetPoint("TOPLEFT", UIMenu, "TOPLEFT", 15, -40);   
            tab.content.PlayerBlockBox:SetAutoFocus(false)
            tab.content.PlayerBlockBox:SetSize(100,36)

            tab.content.PlayerBlockBox.headerText = tab.content.PlayerBlockBox:CreateFontString(nil,"ARTWORK") 
            tab.content.PlayerBlockBox.headerText:SetJustifyH("LEFT")
            tab.content.PlayerBlockBox.headerText:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
            tab.content.PlayerBlockBox.headerText:SetPoint("TOPLEFT", UIMenu, "TOPLEFT", 15, -32)
            tab.content.PlayerBlockBox.headerText:SetTextColor(210, 38, 19, 1)
            tab.content.PlayerBlockBox.headerText:SetText("|cFFFFFF00Blocked Players")

            tab.content.AddPlayerBlockButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Add_Player_Block", tab.content, "GameMenuButtonTemplate");
            tab.content.AddPlayerBlockButton:SetPoint("LEFT", tab.content.PlayerBlockBox, "RIGHT", 0, 0);
            tab.content.AddPlayerBlockButton:SetSize(22,22);
            tab.content.AddPlayerBlockButton.Text:SetPoint("CENTER", tab.content.AddPlayerBlockButton, "CENTER", 0, -1)
            tab.content.AddPlayerBlockButton:SetText("+");
            tab.content.AddPlayerBlockButton:SetNormalFontObject("GameFontNormalLarge");
            --tab.content.RemovePlayerBlockButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Remove_Player_Block", tab.content, "GameMenuButtonTemplate");
            --tab.content.RemovePlayerBlockButton:SetPoint("CENTER", tab.content.AddPlayerBlockButton, "CENTER", 0, -18);
            --tab.content.RemovePlayerBlockButton:SetSize(18,18);
            --tab.content.RemovePlayerBlockButton.Text:SetPoint("CENTER", tab.content.RemovePlayerBlockButton, "CENTER", 1, 6)
            --tab.content.RemovePlayerBlockButton:SetText("_");
            --tab.content.RemovePlayerBlockButton:SetNormalFontObject("GameFontNormalLarge");

            tab.content.scrollframe = CreateFrame("ScrollFrame", "Jarbeatbox_PlayerBlock_ScrollFrame", tab.content, "UIPanelScrollFrameTemplate");
            tab.content.scrollframe:SetPoint("TOPLEFT", tab.content.PlayerBlockBox, "BOTTOMLEFT")
            tab.content.scrollframe:SetPoint("BOTTOMRIGHT", tab.content.PlayerBlockBox, "BOTTOMRIGHT", 36, -100)
            local child = CreateFrame("Frame", nil, tab.content.scrollframe); 
            child:SetPoint("TOPLEFT", tab.content.scrollframe, "TOPLEFT")
            child:SetSize(136, 500);

            child.elements = {}

            tab.content.scrollframe.ScrollBar:ClearAllPoints();
            tab.content.scrollframe.ScrollBar:SetPoint("TOPLEFT", tab.content.AddPlayerBlockButton, "BOTTOMLEFT", 3, -30)
            tab.content.scrollframe.ScrollBar:SetPoint("BOTTOM", tab.content.scrollframe, "BOTTOM", 0, 30)

            tab.content.scrollframe:SetScrollChild(child);
            tab.content.scrollframe:SetClipsChildren(true)

            if(Configs["BlockedPlayers"] ~= nil and Configs["BlockedPlayersReverseLookup"] ~= nil) then
                index = 0;
                for k, v in pairs(Configs["BlockedPlayersReverseLookup"]) do

                    if k ~= nil then
                        CreateBlockedPlayerFrame(child, v, 5, -5 + (-12 * index))
                        index = index + 1;
                    end
                end
            end

            
            tab.content.AddPlayerBlockButton:SetScript("OnClick", function(self)
                local blockPlayerName = tab.content.PlayerBlockBox:GetText():lower():gsub("^%l", string.sub(tab.content.PlayerBlockBox:GetText():upper(), 1, 1));
                if Configs["BlockedPlayers"] == nil then
                    CreateBlockedPlayerFrame(child, blockPlayerName, 5, -5 + (-12 * Configs["BlockedPlayersSize"]))
                    Configs["BlockedPlayersSize"] = Configs["BlockedPlayersSize"] + 1;
                    Configs["BlockedPlayers"] = {blockPlayerName = Configs["BlockedPlayersSize"]}
                    Configs["BlockedPlayersReverseLookup"][Configs["BlockedPlayersSize"]] = blockPlayerName
                elseif Configs["BlockedPlayers"][blockPlayerName] ~= nil then
                    --do nothing
                else
                    CreateBlockedPlayerFrame(child, blockPlayerName, 5, -5 + (-12 * Configs["BlockedPlayersSize"]))
                    Configs["BlockedPlayersSize"] = Configs["BlockedPlayersSize"] + 1;
                    Configs["BlockedPlayers"][blockPlayerName] = Configs["BlockedPlayersSize"]
                    Configs["BlockedPlayersReverseLookup"][Configs["BlockedPlayersSize"]] = blockPlayerName
                end
            end)

            tab.content:Hide();
        end

        if(i == 1) then
            tab:SetPoint("TOPLEFT", UIMenu, "BOTTOMLEFT", 5, 7);
            CurrTab = tab;
        else
            tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i-1)], "TOPRIGHT", -14, 0);
        end
        
    end
    Tab_OnClick(_G[frameName.."Tab1"])
end
function ReSortBlockPlayerFrames(i)
    if(Configs["BlockedPlayers"] ~= nil) then
        index = 0;
        for k, v in pairs(Configs["BlockedPlayers"]) do
            if v > i then
                local frame = _G["newPlayerFrame_"..k];
                local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)
                frame:SetPoint(point,relativeTo,relativePoint,xOfs,yOfs+12)
                point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(2)
                frame:SetPoint(point,relativeTo,relativePoint,xOfs,yOfs+12)
                point, relativeTo, relativePoint, xOfs, yOfs = frame.text:GetPoint()
                frame.text:SetPoint(point,relativeTo,relativePoint,xOfs,yOfs+12)
                frame.bg = frame:CreateTexture(nil, "BACKGROUND")
                frame.bg:SetAllPoints(true)
                Configs["BlockedPlayers"][k] = v-1;
                Configs["BlockedPlayersReverseLookup"][v-1] = k;
                index = index + 1;
            end
        end
    end
end

local lastSelectedBlockPlayerFrame
function CreateBlockedPlayerFrame(parentFrame, blockedPlayerName, x, y)
    local newPlayerFrame = CreateFrame("Frame", "newPlayerFrame_"..blockedPlayerName, parentFrame, nil);
    newPlayerFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, y)
    newPlayerFrame:SetPoint("BOTTOMRIGHT", parentFrame, "TOPLEFT", x+100, y-12)
    newPlayerFrame.text = newPlayerFrame:CreateFontString(nil,"ARTWORK") 
    newPlayerFrame.text:SetJustifyH("LEFT")
    newPlayerFrame.text:SetFont("Fonts\\ARIALN.ttf", 12, "OUTLINE")
    newPlayerFrame.text:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, y)
    newPlayerFrame.text:SetText(blockedPlayerName)
    newPlayerFrame.bg = newPlayerFrame:CreateTexture(nil, "BACKGROUND")
    newPlayerFrame.bg:SetAllPoints(true)
    newPlayerFrame:SetPropagateKeyboardInput(true)

    newPlayerFrame:SetScript('OnMouseDown', function()
        if lastSelectedBlockPlayerFrame and lastSelectedBlockPlayerFrame.bg then
            lastSelectedBlockPlayerFrame.bg:SetColorTexture(1,1,0,0)
        end
        lastSelectedBlockPlayerFrame = newPlayerFrame
        newPlayerFrame.bg:SetColorTexture(1,1,0,.3)
        _G[UIMenu:GetName().."Tab3"].content.PlayerBlockBox:ClearFocus();
        newPlayerFrame:EnableKeyboard(true)
     end)

    newPlayerFrame:SetScript('OnEnter', function() 

        if newPlayerFrame then
            newPlayerFrame.bg:SetColorTexture(1,1,0,.1)
        end
     end)

     newPlayerFrame:SetScript('OnKeyDown', function(arg1, key) 
        if newPlayerFrame ~= lastSelectedBlockPlayerFrame then
            newPlayerFrame:EnableKeyboard(false)
            return
        end    
        if key == 'DELETE' then
            ReSortBlockPlayerFrames(Configs["BlockedPlayers"][newPlayerFrame.text:GetText()])
            Configs["BlockedPlayers"][newPlayerFrame.text:GetText()] = nil   
            Configs["BlockedPlayersReverseLookup"][Configs["BlockedPlayersSize"]] = nil   
            newPlayerFrame:EnableKeyboard(false)
            newPlayerFrame:Hide()
            Configs["BlockedPlayersSize"] = Configs["BlockedPlayersSize"] - 1;
            return;
        end            
     end)

    newPlayerFrame:SetScript('OnLeave', function()     

        if lastSelectedBlockPlayerFrame and lastSelectedBlockPlayerFrame ~= newPlayerFrame then
            lastSelectedBlockPlayerFrame:EnableKeyboard(false) 

            if lastSelectedBlockPlayerFrame.bg then 
                lastSelectedBlockPlayerFrame.bg:SetColorTexture(1,1,0,0)
            end
        end

        if newPlayerFrame then
            newPlayerFrame.bg:SetColorTexture(1,1,0,0)
        end
    end)

    parentFrame.elements[blockedPlayerName] = newPlayerFrame;
end


function ShowAddon()
    --ui
    UIMenu = CreateFrame("Frame", "Jarbeatbox_Sound_Menu", UIParent, "BasicFrameTemplateWithInset");
    tinsert(UISpecialFrames, UIMenu:GetName())

    UIMenu:SetMovable(true);
    UIMenu:EnableMouse(true);
    UIMenu:RegisterForDrag("LeftButton");
    UIMenu:SetScript("OnDragStart", UIMenu.StartMoving);
    UIMenu:SetScript("OnDragStop", UIMenu.StopMovingOrSizing);
    UIMenu:SetSize(400,480);
    UIMenu:SetPoint("CENTER");



    UIMenu.Tab1 = CreateFrame("Frame", "Jarbeatbox_Sound_Menu_Tab_1", UIMenu, nil);
    UIMenu.Tab1.Bg = UIMenu.Bg

    UIMenu.Tab1.SearchBox = CreateFrame("EditBox", "Jarbeatbox_SearchBox", UIMenu.Tab1, "InputBoxTemplate");

    UIMenu.Tab1.SearchBox:SetAutoFocus(false)
    UIMenu.Tab1.SearchBox:SetScript("OnEscapePressed", function(self)
        if self:GetText() == "" then
            UIMenu:Hide()
        else
            self:SetText("");
        end
    end)
    UIMenu.Tab1.SearchBox:SetScript("OnTextChanged", function()
        SearchSounds();
    end)
    UIMenu.Tab1.SearchBox:SetPoint("Left", UIMenu.TitleBg, "Left", 4, 0);
    UIMenu.Tab1.SearchBox:SetSize(100,20)

    function removeSoundFromFavorites(sound)
        Configs["FavoriteSounds"][sound] = nil
        Configs["FavoriteSounds"]["size"] = Configs["FavoriteSounds"]["size"] - 1

        --if we are on the favorites page already
        if globalBasePath == nil then
            SearchSounds();
        end
    end

    function addSoundToFavorites(sound)
        Configs["FavoriteSounds"][sound] = true
        Configs["FavoriteSounds"]["size"] = Configs["FavoriteSounds"]["size"] + 1
    end

    function setFavoritesDropDownMenuItem(pullout) 

        favoritesMenuItemReference = AceGUI:Create("Dropdown-Item-Execute")
        favoritesMenuItemReference:SetText("Favorites")

        if Configs["FavoriteSounds"] ~= nil then

            if Configs["FavoriteSounds"]["size"] > 0 then
                globalCurrentTable = Configs["FavoriteSounds"]    
                globalBasePath = nil             
                UIMenu.Tab1.dropDownMenu:SetText("Favorites")
            end

            for k,v in pairs(Configs["FavoriteSounds"]) do
                favoritesMenuItemReference.frame:SetScript("OnClick", function(self)
                    globalBasePath = nil
                    UIMenu.Tab1.dropDownMenu:SetText("Favorites")

                    globalCurrentTable = Configs["FavoriteSounds"]
                    SearchSounds()
                    UIMenu.Tab1.dropDownMenu.open = nil
                    UIMenu.Tab1.dropDownMenu.pullout:Close()
                end)
            end
            pullout:AddItem(favoritesMenuItemReference)
        end
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
                    menuItem.frame.table = v
                    menuItem.frame.submenu = submenu

                    if v.size then
                        menuItem.frame:SetScript("OnClick", function(self)
                            globalBasePath = self.basepath
                            UIMenu.Tab1.dropDownMenu:SetText(globalBasePath)

                            if self.table ~= nil then
                                globalCurrentTable = self.table
                                SearchSounds()
                            end
                            UIMenu.Tab1.dropDownMenu.open = nil
                            UIMenu.Tab1.dropDownMenu.pullout:Close()
                        end)

                    end

                    menuItem:SetCallback("OnEnter", function(self)
                        if(self.frame.init == nil) then 
                            self.frame.init = true
                            setSubMenu(self.frame.table, self.frame.submenu, self.frame.basepath)
                        end
                        --setSubMenu(self.frame.table, self.pullout, self.frame.basepath)   
                    end)  

                    --setSubMenu(v, submenu, menuBasePath)
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
                        UIMenu.Tab1.dropDownMenu:SetText(globalBasePath)

                        globalCurrentTable = self.table
                        SearchSounds()
                        UIMenu.Tab1.dropDownMenu.open = nil
                        UIMenu.Tab1.dropDownMenu.pullout:Close()
                    end)
                    pullout:AddItem(subBtn)
                end
            end

        end
    end



    UIMenu.Tab1.dropDownMenu = AceGUI:Create("Dropdown");
    UIMenu.Tab1.dropDownMenu:SetText(globalBasePath)
    local Path, Size, Flags = UIMenu.Tab1.dropDownMenu.text:GetFont()
    UIMenu.Tab1.dropDownMenu.text:SetFont(Path,16,Flags);
    UIMenu.Tab1.dropDownMenu.text:SetJustifyH("CENTER")			
    UIMenu.Tab1.dropDownMenu.text:SetTextColor(0.05,0.63,0.85)

    pullout = AceGUI:Create("Dropdown-Pullout")
    setFavoritesDropDownMenuItem(pullout)
    setSubMenu(sounds, pullout, "")

    UIMenu.Tab1.dropDownMenu.pullout = pullout;
    UIMenu.Tab1.dropDownMenu.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    UIMenu.Tab1.dropDownMenu:SetPoint("TOPLEFT", UIMenu.Tab1.Bg, "TOPLEFT", 8, -6)
    UIMenu.Tab1.dropDownMenu:SetPoint("BOTTOMRIGHT", UIMenu.Tab1.Bg, "TOPRIGHT", -5, -32)


    function AddMuteBox(frame, point, relativePoint, x, y)
        frame.Mutebox = CreateFrame("CheckButton", nil , frame, "UICheckButtonTemplate");
        frame.Mutebox:SetPoint(point, frame, relativePoint, x, y-2);
        frame.Mutebox:SetSize(50,50);
        frame.Mutebox.tooltip = "Mute/Unmute";
        frame.Mutebox:SetCheckedTexture("Interface\\PLAYERFRAME\\whisper-only");
        frame.Mutebox:GetCheckedTexture():SetDesaturated(1);
        frame.Mutebox:SetNormalTexture("Interface\\PLAYERFRAME\\whisper-only")
        frame.Mutebox:SetPushedTexture("Interface\\PLAYERFRAME\\whisper-only")
    end

    UIMenu.Tab1.ScrollFrame = AceGUI:Create("ScrollFrame")
    UIMenu.Tab1.ScrollFrame:SetLayout("List")
    _G["Jarbeatbox_ScrollFrame"] = UIMenu.Tab1.ScrollFrame.frame
    tinsert(UISpecialFrames, "Jarbeatbox_ScrollFrame")
    UIMenu.Tab1:SetScript("OnHide", function(widget) 
        UIMenu.Tab1.ScrollFrame.frame:Hide()
        UIMenu.Tab1.dropDownMenu.frame:Hide()
        UIMenu.Tab1.dropDownMenu.open = nil
        UIMenu.Tab1.dropDownMenu.pullout:Close()
        UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.frame:Hide()
        UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.pullout:Close()
        UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.open = nil
    end)
    UIMenu.Tab1:SetScript("OnShow", function(widget) 
        UIMenu.Tab1.ScrollFrame.frame:Show()
        UIMenu.Tab1.dropDownMenu.frame:Show()
        UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.frame:Show()
    end)

    UIMenu.Tab1.ScrollFrame:SetParent(UIMenu.Tab1.Bg);
    UIMenu.Tab1.ScrollFrame:SetPoint("TOPLEFT", UIMenu.Tab1.Bg, "TOPLEFT", 5, -30)
    UIMenu.Tab1.ScrollFrame:SetPoint("BOTTOMRIGHT", UIMenu.Tab1.Bg, "RIGHT", -7, 2)
    --selected sound frames
    UIMenu.Tab1.Options = CreateFrame("Frame", "Jarbeatbox_Options_Menu_Parent", UIMenu.Tab1);
    UIMenu.Tab1.Options:SetPoint("TOPLEFT", UIMenu.Tab1.Bg, "LEFT")
    UIMenu.Tab1.Options:SetPoint("BOTTOMRIGHT", UIMenu.Tab1.Bg, "BOTTOMRIGHT")
    UIMenu.Tab1.Options.SelectedSoundFrame = CreateFrame("Frame", "Jarbeatbox_Options_Menu_SelectedSound", UIMenu.Tab1.Options);
    UIMenu.Tab1.Options.SelectedSoundFrame:SetPoint("TOPLEFT", UIMenu.Tab1.Options, "TOPLEFT")
    UIMenu.Tab1.Options.SelectedSoundFrame:SetPoint("BOTTOMRIGHT", UIMenu.Tab1.Options, "RIGHT", 0, 75)
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton = CreateFrame("CheckButton", nil , UIMenu.Tab1.Options.SelectedSoundFrame, "UICheckButtonTemplate");
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:SetPoint("RIGHT", UIMenu.Tab1.Options.SelectedSoundFrame, "RIGHT", -10, -40);
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:SetSize(25,25);
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton.tooltip = "Add/Remove from favorite sounds";
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton.text =  UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton.text:SetPoint("RIGHT", UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton, "LEFT")
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton.text:SetFont(Path, 12)
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton.text:SetText("Favorited?")
    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:Hide()

    UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:SetScript("OnClick", 
    function(frame)
        if frame:GetChecked() then
            addSoundToFavorites(SelectedSound)
        else
            removeSoundFromFavorites(SelectedSound)
            UIMenu.Tab1.Options.SelectedSoundText:SetText("");
        end
    end);

    UIMenu.Tab1.Options.SelectedSoundText = UIMenu.Tab1.Options.SelectedSoundFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    UIMenu.Tab1.Options.SelectedSoundText:SetPoint("CENTER", UIMenu.Tab1.Options.SelectedSoundFrame, "CENTER")
    UIMenu.Tab1.Options.SelectedSoundText:SetFont(Path, 16)

    --firing buttons
    UIMenu.Tab1.Options.Buttons = CreateFrame("Frame", "Jarbeatbox_Options_Menu_Buttons", UIMenu.Tab1.Options);
    UIMenu.Tab1.Options.Buttons:SetPoint("TOPLEFT", UIMenu.Tab1.Options.SelectedSoundFrame, "BOTTOMLEFT")
    UIMenu.Tab1.Options.Buttons:SetPoint("BOTTOMRIGHT", UIMenu.Tab1.Options, "BOTTOMRIGHT")

    UIMenu.Tab1.Options.Buttons.SelfButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Self", UIMenu.Tab1.Options.Buttons, "GameMenuButtonTemplate");
    UIMenu.Tab1.Options.Buttons.SelfButton:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "CENTER", -70, 66);
    UIMenu.Tab1.Options.Buttons.SelfButton:SetSize(100,30);
    UIMenu.Tab1.Options.Buttons.SelfButton:SetText("Self");
    UIMenu.Tab1.Options.Buttons.SelfButton:SetNormalFontObject("GameFontNormalLarge");

    UIMenu.Tab1.Options.Buttons.SelfButton:SetScript("OnClick", function(self)
        SendSound(SelectedSound, nil, nil)
    end)

    UIMenu.Tab1.Options.Buttons.YellButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Yell", UIMenu.Tab1.Options.Buttons, "GameMenuButtonTemplate");
    UIMenu.Tab1.Options.Buttons.YellButton:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "CENTER", -70, 33);
    UIMenu.Tab1.Options.Buttons.YellButton:SetSize(100,30);
    UIMenu.Tab1.Options.Buttons.YellButton:SetText("Yell");
    UIMenu.Tab1.Options.Buttons.YellButton:SetNormalFontObject("GameFontNormalLarge");

    UIMenu.Tab1.Options.Buttons.YellButton:SetScript("OnClick", function(self)
        SendSound(SelectedSound, "YELL")
    end)

    AddMuteBox(UIMenu.Tab1.Options.Buttons.YellButton, "RIGHT", "LEFT", 5, 0)
    UIMenu.Tab1.Options.Buttons.YellButton.Mutebox:SetScript("OnClick", 
    function(frame)
        Configs["MutedChannels"]["YELL"] = not Configs["MutedChannels"]["YELL"]
    end);

    UIMenu.Tab1.Options.Buttons.PartyButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Party", UIMenu.Tab1.Options.Buttons, "GameMenuButtonTemplate");
    UIMenu.Tab1.Options.Buttons.PartyButton:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "CENTER", -70, 0);
    UIMenu.Tab1.Options.Buttons.PartyButton:SetSize(100,30);
    UIMenu.Tab1.Options.Buttons.PartyButton:SetText("Party");
    UIMenu.Tab1.Options.Buttons.PartyButton:SetNormalFontObject("GameFontNormalLarge");

    UIMenu.Tab1.Options.Buttons.PartyButton:SetScript("OnClick", function(self)
        SendSound(SelectedSound, "PARTY")
    end)

    AddMuteBox(UIMenu.Tab1.Options.Buttons.PartyButton, "RIGHT", "LEFT", 5, 0)
    UIMenu.Tab1.Options.Buttons.PartyButton.Mutebox:SetScript("OnClick", 
    function(frame)
        Configs["MutedChannels"]["PARTY"] = not Configs["MutedChannels"]["PARTY"]
    end);


    UIMenu.Tab1.Options.Buttons.RaidButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Raid", UIMenu.Tab1.Options.Buttons, "GameMenuButtonTemplate");
    UIMenu.Tab1.Options.Buttons.RaidButton:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "CENTER", -70, -33);
    UIMenu.Tab1.Options.Buttons.RaidButton:SetSize(100,30);
    UIMenu.Tab1.Options.Buttons.RaidButton:SetText("Raid");
    UIMenu.Tab1.Options.Buttons.RaidButton:SetNormalFontObject("GameFontNormalLarge");

    UIMenu.Tab1.Options.Buttons.RaidButton:SetScript("OnClick", function(self)
        SendSound(SelectedSound, "RAID")
    end)

    AddMuteBox(UIMenu.Tab1.Options.Buttons.RaidButton, "RIGHT", "LEFT", 5, 0)
    UIMenu.Tab1.Options.Buttons.RaidButton.Mutebox:SetScript("OnClick", 
    function(frame)
        Configs["MutedChannels"]["RAID"] = not Configs["MutedChannels"]["RAID"]
    end);

    UIMenu.Tab1.Options.Buttons.GuildButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Guild", UIMenu.Tab1.Options.Buttons, "GameMenuButtonTemplate");
    UIMenu.Tab1.Options.Buttons.GuildButton:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "CENTER", -70, -66);
    UIMenu.Tab1.Options.Buttons.GuildButton:SetSize(100,30);
    if guildUsersCount ~= nil then
        UIMenu.Tab1.Options.Buttons.GuildButton:SetText("Guild ("..guildUsersCount..")");
    else
        UIMenu.Tab1.Options.Buttons.GuildButton:SetText("Guild");
    end

    UIMenu.Tab1.Options.Buttons.GuildButton:SetNormalFontObject("GameFontNormalLarge");

    UIMenu.Tab1.Options.Buttons.GuildButton:SetScript("OnClick", function(self)  
        SendSound(SelectedSound, "GUILD")
    end)
    UIMenu.Tab1.Options.Buttons.GuildButton:SetScript("OnEnter", function(self)
        GameTooltip_SetDefaultAnchor( GameTooltip, UIMenu.Tab1.Options.Buttons.GuildButton )
        local t = { }
        for k,v in pairs(guildUsers[quorumId])
        do
            t[#t+1] = tostring(k)
        end
        GameTooltip:SetText(table.concat(t,"\n"))
        GameTooltip:Show()
    end)
    UIMenu.Tab1.Options.Buttons.GuildButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    AddMuteBox(UIMenu.Tab1.Options.Buttons.GuildButton, "RIGHT", "LEFT", 5, 0)
    UIMenu.Tab1.Options.Buttons.GuildButton.Mutebox:SetScript("OnClick", 
    function(frame)
        Configs["MutedChannels"]["GUILD"] = not Configs["MutedChannels"]["GUILD"]
    end);

    UIMenu.Tab1.Options.Buttons.WhisperButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Whisper", UIMenu.Tab1.Options.Buttons, "GameMenuButtonTemplate");
    UIMenu.Tab1.Options.Buttons.WhisperButton:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "CENTER", 70, -52);
    UIMenu.Tab1.Options.Buttons.WhisperButton:SetSize(100,30);
    UIMenu.Tab1.Options.Buttons.WhisperButton:SetText("Whisper");
    UIMenu.Tab1.Options.Buttons.WhisperButton:SetNormalFontObject("GameFontNormalLarge");

    UIMenu.Tab1.Options.Buttons.WhisperButton:SetScript("OnClick", function(self)
        local text = UIMenu.Tab1.Options.Buttons.WhisperEditBox:GetText();
        if text == nil or text == "" then
            return;
        end
        SendSound(SelectedSound, "WHISPER", UIMenu.Tab1.Options.Buttons.WhisperEditBox:GetText())
    end)

    AddMuteBox(UIMenu.Tab1.Options.Buttons.WhisperButton, "LEFT", "RIGHT", -5, 0)
    UIMenu.Tab1.Options.Buttons.WhisperButton.Mutebox:SetScript("OnClick", 
    function(frame)
        Configs["MutedChannels"]["WHISPER"] = not Configs["MutedChannels"]["WHISPER"]
    end);

    UIMenu.Tab1.Options.Buttons.WhisperEditBox = CreateFrame("EditBox", "Jarbeatbox_Sound_Menu_Button_Whisper_EditBox", UIMenu.Tab1.Options.Buttons.WhisperButton, "InputBoxTemplate");
    UIMenu.Tab1.Options.Buttons.WhisperEditBox:SetAutoFocus(false)
    UIMenu.Tab1.Options.Buttons.WhisperEditBox:SetScript("OnEscapePressed", function(self)
        if self:GetText() == "" then
            UIMenu.Tab1:Hide()
        else
            self:SetText("");
        end
    end)
    UIMenu.Tab1.Options.Buttons.WhisperEditBox:SetPoint("BOTTOM", UIMenu.Tab1.Options.Buttons.WhisperButton, "TOP", 2, -5);
    UIMenu.Tab1.Options.Buttons.WhisperEditBox:SetSize(90,30)


    UIMenu.Tab1.Options.Buttons.CustomButton = CreateFrame("Button", "Jarbeatbox_Sound_Menu_Button_Whisper", UIMenu.Tab1.Options.Buttons, "GameMenuButtonTemplate");
    UIMenu.Tab1.Options.Buttons.CustomButton:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "CENTER", 70, 22);
    UIMenu.Tab1.Options.Buttons.CustomButton:SetSize(100,30);
    UIMenu.Tab1.Options.Buttons.CustomButton:SetText("Custom");
    UIMenu.Tab1.Options.Buttons.CustomButton:SetNormalFontObject("GameFontNormalLarge");

    UIMenu.Tab1.Options.Buttons.CustomButton:SetScript("OnClick", function(self)
        local text = Configs["CustomChannel"];

        if text == nil or text == "" then
            print("You must Input a custom channel!")
            return;
        elseif channels[text] == nil then
            print("You must be in the specified channel!")
            return;
        end
        SendSound(SelectedSound, "CUSTOM", text)
    end)

    AddMuteBox(UIMenu.Tab1.Options.Buttons.CustomButton, "LEFT", "RIGHT", -5, 0)
    UIMenu.Tab1.Options.Buttons.CustomButton.Mutebox:SetScript("OnClick", 
    function(frame)
        Configs["MutedChannels"]["CUSTOM"] = not Configs["MutedChannels"]["CUSTOM"]
    end);


    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown = AceGUI:Create("Dropdown");
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown:SetText("Channel Name")
    local Path, Size, Flags = UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.text:GetFont()
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.text:SetFont(Path,12,Flags);
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.text:SetJustifyH("CENTER")			
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.text:SetTextColor(0.05,0.63,0.85)
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown:SetPoint("BOTTOMLEFT", UIMenu.Tab1.Options.Buttons.CustomButton, "TOPLEFT", 2, 2)
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown:SetPoint("TOPRIGHT", UIMenu.Tab1.Options.Buttons.CustomButton, "TOPRIGHT", 2, 27)
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown:SetCallback("OnValueChanged", function(frame, event, key) Configs["CustomChannel"] = key end)
    UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown:SetList(channels)



    local line = UIMenu.Tab1:CreateTexture()
    line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
    line:SetColorTexture(.6 ,.6, .6, .6)
    line:SetSize(UIMenu.Tab1.Bg:GetWidth()-12, 2)
    line:SetPoint("CENTER", UIMenu.Tab1.Bg, "CENTER", -1, -3)

    line = UIMenu.Tab1:CreateTexture()
    line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
    line:SetColorTexture(.6 ,.6, .6, .6)
    line:SetSize(UIMenu.Tab1.Bg:GetWidth()-12, 2)
    line:SetPoint("CENTER", UIMenu.Tab1.Options.Buttons, "TOP", -1, -3)

    line = UIMenu.Tab1:CreateTexture()
    line:SetTexture("Interface/Tooltips/UI-Tooltip-Border")
    line:SetColorTexture(.6 ,.6, .6, .6)
    line:SetSize(UIMenu.Tab1.Bg:GetWidth()-12, 2)
    line:SetPoint("TOP", UIMenu.Tab1.dropDownMenu.frame, "BOTTOM", -1, -3)

    
    UIMenu.Tab1.Options.Buttons.PartyButton.Mutebox:SetChecked(Configs["MutedChannels"]["PARTY"]);
    UIMenu.Tab1.Options.Buttons.RaidButton.Mutebox:SetChecked(Configs["MutedChannels"]["RAID"]);
    UIMenu.Tab1.Options.Buttons.GuildButton.Mutebox:SetChecked(Configs["MutedChannels"]["GUILD"]);
    UIMenu.Tab1.Options.Buttons.WhisperButton.Mutebox:SetChecked(Configs["MutedChannels"]["WHISPER"]);
    UIMenu.Tab1.Options.Buttons.YellButton.Mutebox:SetChecked(Configs["MutedChannels"]["YELL"]);
    UIMenu.Tab1.Options.Buttons.CustomButton.Mutebox:SetChecked(Configs["MutedChannels"]["CUSTOM"]);
    
    if (Configs["CustomChannel"] ~= nil and Configs["CustomChannel"] ~= "") then
        UIMenu.Tab1.Options.Buttons.CustomButton.Dropdown:SetText(Configs["CustomChannel"]);
    end

    SetTabs(3, "Sounds", "Logs", "Config");

end


function SelectSoundOnClick(self)

    if not UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:IsShown() then
        UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:Show()
    end

    SelectedSound = self.filePath:gsub("\\_.*_\\", "\\");

    if Configs["FavoriteSounds"][SelectedSound] ~= nil then
        UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:SetChecked(true)
    else
        
        UIMenu.Tab1.Options.SelectedSoundFrame.FavoriteButton:SetChecked(false)
    end

    UIMenu.Tab1.Options.SelectedSoundText:SetText(self.readableText);
end

--main scrollframe list of sounds as buttons
function InitUiMenu(matchSoundsLocal)
    UIMenu.Tab1.ScrollFrame:ReleaseChildren();
    for k, key in pairs(sortedKeys(matchSoundsLocal)) do
        value = matchSoundsLocal[key]
        if key ~= "hasNestedTables" and key ~= "size" and type(value) ~= "table" then
            local childWidget = AceGUI:Create("Button");

            local Path, Size, Flags = childWidget.frame.Text:GetFont()
            childWidget.frame.Text:SetFont(Path,12,Flags);
            if globalBasePath == nil then
                childWidget.filePath = key;
                childWidget.readableText = string.match(key, "[^\\]*$");
            else
                childWidget.filePath = globalBasePath.."\\"..key;
                childWidget.readableText = key--string.match(value, "[^\\]*$");
            end
            childWidget:SetCallback("OnClick", SelectSoundOnClick);
            childWidget:SetFullWidth(true);
            childWidget:SetHeight(18);
            childWidget:SetText(childWidget.readableText);
            --childWidget:SetNormalFontObject("GameFontNormalLarge");
            --childWidget:SetHighlightFontObject("GameFontHighlightLarge");
            UIMenu.Tab1.ScrollFrame:AddChild(childWidget);
        end
    end
end

function case_insensitive_pattern(pattern)

    -- find an optional '%' (group 1) followed by any character (group 2)
    local p = pattern:gsub("(%%?)(.)", function(percent, letter)
  
      if percent ~= "" or not letter:match("%a") then
        -- if the '%' matched, or `letter` is not a letter, return "as is"
        return percent .. letter
      else
        -- else, return a case-insensitive character class of the matched letter
        return string.format("[%s%s]", letter:lower(), letter:upper())
      end
  
    end)
  
    return p
  end

--less baby search than before
function SearchSounds()
    local localText = UIMenu.Tab1.SearchBox:GetText()
    if localText == "" then
        matchSounds = globalCurrentTable;
    else
        local lessBabyPattern = case_insensitive_pattern(localText)
        for index, value in pairs(globalCurrentTable) do
            if string.match(index, lessBabyPattern) ~= nil then
                matchSounds[index] = value; 
            end
        end
    end
    InitUiMenu(matchSounds)
    matchSounds = {}
end

function LoadChannelList()
    channelList = {GetChannelList()}

    for i=1,#channelList,3 do
        --remove disabled channels
        if channelList[i+2] == false then
            channels[channelList[i+1]] = channelList[i+1]
        end
    end

end

--register slashcommand handler
function SlashCmdList.JARBEATBOXMENU(message, editbox)
    if UIMenu == nil then
        ShowAddon()
        return;
    end

    if UIMenu:IsShown() then
        UIMenu:Hide();
    else
        UIMenu:Show();
    end
end

function SlashCmdList.JARBEATBOXCONSOLE(message, editbox)
    local t = Split(message, "||")
    if t[3] ~= nil then
        SendSound(t[3], t[1], t[2])
    elseif t[2] ~= nil then 
        SendSound(t[2], t[1], nil)
    else
        SendSound(t[1], nil, nil)
    end
end

function LoadSavedVariables()
    if Configs == nil or Configs["FavoriteSounds"] == nil then
        Configs = {
        ["FavoriteSounds"]  = {["size"] = 0},
        ["MutedChannels"] = {
            ["GUILD"] =  false,
            ["PARTY"] =  false,
            ["RAID"] =  false,
            ["WHISPER"] =  false,
            ["YELL"] =  false,
            ["CUSTOM"] =  false
        },        
        ["BlockedSounds"] = {},
        ["BlockedSoundsSize"] = 0,
        ["BlockedPlayers"] = {},
        ["BlockedPlayersReverseLookup"] = {},
        ["BlockedPlayersSize"] = 0,
        ["CustomChannel"] = ""
    }
    end
end

function SendAddonMessageOverload(message, channel)
    SendAddonMessageOverload(message, channel, nil)
end

function SendAddonMessageOverload(message, channel, playername)
    if lastSentMessageTimestamp == nil or lastSentMessageTimestamp <  (GetTime() - 5) then
        lastSentMessageTimestamp = GetTime();
        --tracking down the pesky \n characters in sound file paths and just swapping to / instead
        message = message:gsub("\\", "/");
        C_ChatInfo.SendAddonMessage(soundEventPrefix, message, channel, playername)
    end
end

function SendSound(message, channel, customChannelOrWhisperTarget)
    if(message == nil or message == '') then
        print("USAGE: /jbb or /jarbeatbox {options} {soundfile}");
        return;
    end

    if(message == "stop")
    then
        if(currentHandle ~= nil) then
            StopSound(currentHandle)
        end
        return;
    end
    if channel == nil then
        if(currentHandle ~= nil) then
            StopSound(currentHandle)
        end
        _, currentHandle = PlaySoundFile(message, "Master");
    elseif channel == "WHISPER"
    then
        
        SendAddonMessageOverload(messageType_Message.."||"..message.."||"..playerName, "WHISPER", customChannelOrWhisperTarget)
    elseif channel == "CUSTOM" then
        SendAddonMessageOverload(messageType_Message.."||"..message.."||"..customChannelOrWhisperTarget.."||"..playerName, "GUILD")
    else
        SendAddonMessageOverload(messageType_Message.."||"..message.."||"..playerName, channel)
    end
end

local LogTableIndex = 1;
local LogTableSize = 30;
function LogSoundReceived (playerName, message, channel, customChannel, muted, blocked)
    if channel == "CUSTOM" then 
        channel = channel.."||"..customChannel
    end

    message = string.match(message, "[^/]*.$")
    if LogTable == nil then
        LogTable = {}
    end

    local concatTable = {}
    local concatTable2 = {}

    if(muted == true) then
        table.insert(concatTable, "(MUTED)")
    end

    if(blocked == true) then
        table.insert(concatTable, "(BLOCKED)")
    end

    table.insert(concatTable, date("%H:%M:%S"))
    table.insert(concatTable, message)
    table.insert(concatTable, playerName)
    table.insert(concatTable, channel)

    LogTable[LogTableIndex] = table.concat(concatTable, "||");
    LogTableIndex = (LogTableIndex + 1) % LogTableSize;
    if UIMenu then
        DisplayLogs(_G[UIMenu:GetName().."Tab2"].content)
    end
end

function DisplayLogs (frame) 
    if LogTable ~= nil then
        local logText = ""
        for i = LogTableIndex, LogTableIndex + (LogTableSize-1) do
            if LogTable[i % LogTableSize] ~= nil then
                logText = LogTable[i % LogTableSize].."\n"..logText
            end
        end
        frame.text:SetText(logText)
    end
end

--Main event handler
f:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, payload, channel = select(1, ...);
        if prefix == soundEventPrefix then
            local type, msg;
            local params = Split(payload, "||");
            type = params[1]
            if type == messageType_Message then
                file = params[2]
                customChannel = params[3]
                originPlayerName = nil;
                if customChannel ~= nil and channels[customChannel] ~= nil then
                    channel = "CUSTOM"
                    originPlayerName = params[4]
                elseif customChannel ~= nil then
                    originPlayerName = params[3]
                end

                if Configs["MutedChannels"][channel] == true then
                    LogSoundReceived(originPlayerName, file, channel, customChannel, true, false)
                    return;
                end

                if Configs["BlockedSounds"] ~= nil and Configs["BlockedSounds"][file] == true then
                    LogSoundReceived(originPlayerName, file, channel, customChannel, false, true)
                    return;
                end

                if Configs["BlockedPlayers"] ~= nil and Configs["BlockedPlayers"][originPlayerName] ~= nil then
                    LogSoundReceived(originPlayerName, file, channel, customChannel, false, true)
                    return;
                end

                if(currentHandle ~= nil) then
                    StopSound(currentHandle)
                end

                if(originPlayerName ~= nil) then
                    LogSoundReceived(originPlayerName, file, channel, customChannel, false, false)
                end
                _, currentHandle = PlaySoundFile(file, "Master");
                return;

            elseif type == messageType_Login or type == messageType_LoginSync then
                user = params[3]
                
                if type == messageType_Login then
                    C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGINSYNC||"..(quorumId).."||"..playerName, "GUILD")
                    guildUsers[quorumId] = nil
                    guildUsers[quorumId] = {[playerName] = true}
                    guildUsersCount = 0;
                end

                if guildUsers[quorumId][user] ~= nil then
                    return;
                else
                    if guildUsers[quorumId] == nil then
                        guildUsers[quorumId] = {[user] = true}
                        guildUsersCount = 1;
                    else
                        guildUsers[quorumId][user] = true;
                        guildUsersCount = guildUsersCount + 1
                    end
                    if UIMenu ~= nil and UIMenu.Tab1.Options ~= nil then
                        UIMenu.Tab1.Options.Buttons.GuildButton:SetText("Guild".." ("..guildUsersCount..")");
                    end
                end
                return;
            elseif type == messageType_Logout then
                user = params[3]
                if guildUsers[0][user] ~= nil then
                    guildUsers[0][user] = nil;
                    guildUsersCount = guildUsersCount - 1;
                    if UIMenu ~= nil then
                        UIMenu.Tab1.Options.Buttons.GuildButton:SetText("Guild".." ("..guildUsersCount..")");
                    end
                else
                    return;
                end   
            end       
        end
    end

    if event == "CHAT_MSG_CHANNEL_NOTICE" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" then
        LoadChannelList()
        return;
    end

    if event == "PLAYER_LOGIN" then
        LoadSavedVariables()
        LoadChannelList()
        C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGIN||"..quorumId.."||"..playerName, "GUILD")
        return;
    end

    if event == "PLAYER_LOGOUT" or event == "PLAYER_CAMPING" or event == "PLAYER_QUITTING" then
        _logoutThread = C_Timer.NewTimer(19.9, function()     
            C_ChatInfo.SendAddonMessage(soundEventPrefix, "LOGOUT||"..quorumId.."||"..playerName, "GUILD") 
        end )
        return;
    end
end)

