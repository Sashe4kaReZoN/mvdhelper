script_name("AutoUpdate")
script_author("Sashe4kaReZon")
script_description("inicfg")

require "lib.moonloader"
local dlstatus = require("moonloader").download_status
local inicfg = require "inicfg"
local keys = require "vkeys"
local imgui = require "imgui"
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8

update_state = false

local script_vers = 1
local script_vers_text = "1.00"
local script_path = thisScript().path
local script_url = ""
local update_path = getWorkingDirectory() .. "/update.ini"
local update_url = "https://raw.githubusercontent.com/Sashe4kaReZoN/mvdhelper/main/update.ini"

function main()
    if not isSampfuncsLoaded() or not isSampAvailable() then return end

    local playerNickname = nil
    
    sampRegisterChatCommand("update", cmd_update)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть Обновление! Версия: " .. updateIni.info.vers_text, 0x8B00FF)
                update_state = true
            end
        end
    end)

    while true do
        wait(0)

        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", 0x8B00FF)
                    sampAddChatMessage("Перезагружаю скрипт...", 0x8B00FF)
                    thisScript():reload()  -- Перезагрузка текущего скрипта
                end
            end)
            break
        end

        local playerId = sampGetPlayerIdByCharHandle(PLAYER_HANDLE)
        if playerId then
            playerNickname = sampGetPlayerNickname(playerId)
        end
    end
end

function cmd_update(arg)
    if update_state then
        sampShowDialog(1000, "Автообновление", "Ого, Автообновление в работе!", "Закрыть", "", 0)
    else
        sampShowDialog(1000, "Автообновление", "Нет доступных обновлений.", "Закрыть", "", 0)
    end
end
