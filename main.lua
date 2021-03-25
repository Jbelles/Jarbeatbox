--configs
SLASH_JARBEATBOX1, SLASH_JARBEATBOX2 = "/jbb", "/jarbeatbox";
playerName = UnitName('player')
eventPrefix = "jarbeatbox"

--init
local f = CreateFrame("Frame")

f:RegisterEvent("CHAT_MSG_ADDON");
C_ChatInfo.RegisterAddonMessagePrefix(eventPrefix);


--register events
f:SetScript("OnEvent", function(self, event, ...)
    local prefix, msg = select(1, ...);
    if prefix == eventPrefix then
        if(currentHandle ~= nil) then
            StopSound(currentHandle)
        end
        _, currentHandle = PlaySoundFile(msg);
    end
end)

--register slashcommand handler
function SlashCmdList.JARBEATBOX(message, editbox)
    if(message == nil or message == '') then
        print("USAGE: /jbb or /jarbeatbox {options} {soundfile}");
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
