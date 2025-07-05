local API = require("api")

local bot_monitor = {
    config = {
        SERVER_URL = "http://localhost:5000/update",
        UPDATE_INTERVAL = 60,
        cb = { { 1466,0,-1,0 }, { 1466,9,-1,0 }, { 1466,12,-1,0 }, { 1466,12,1,0 } },
        sL = { { 1466,0,-1,0 }, { 1466,9,-1,0 }, { 1466,11,-1,0 }, { 1466,11,1,0 } },
        wl = { {566,0,-1,0}, {566,2,-1,0}, {566,22,-1,0}, { 566,40,-1,0 } },
        area = {x = 414, y = 674, z = 0, range = {10,10}}
    }
}

function bot_monitor.setConfig(customConfig)
    for key, value in pairs(customConfig) do
        bot_monitor.config[key] = value
    end
end

function bot_monitor.checkArea()
    if not bot_monitor.config.area then return true end
    return API.PInArea(bot_monitor.config.area.x, bot_monitor.config.area.range[1], 
                       bot_monitor.config.area.y, bot_monitor.config.area.range[2], 
                       bot_monitor.config.area.z)
end

function bot_monitor.getRegionData()
    local region = API.PlayerRegion()
    return {
        x = region.x or 0,
        y = region.y or 0,
        id = region.z or 0
    }
end

function bot_monitor.cleanWidgetText(text)
    if not text then return 0 end
    text = text:gsub("<[^>]+>", "")
    text = text:gsub(",", "")
    text = text:gsub("%$", "")
    return tonumber(text) or 0
end

function bot_monitor.httpPost(url, data)
    local temp_file = os.tmpname() .. ".txt"
    API.StoreTextString(temp_file, data, false)
    local command = string.format('curl -X POST -d "@%s" -H "Content-Type: application/x-www-form-urlencoded" "%s"', temp_file, url)
    os.execute(command)
    os.remove(temp_file)
end

function bot_monitor.sendBotData()
    if not API.PlayerLoggedIn() then return false end
    
    local account_name = API.GetLocalPlayerName()
    if not account_name or account_name == "" then return false end
    
    local region_data = bot_monitor.getRegionData()
    local wealth_val = bot_monitor.cleanWidgetText(API.ScanForInterfaceTest2Get(false, bot_monitor.config.wl)[1].textids) or 0
    
    local form_data = {
        account_name = account_name,
        wealth = wealth_val,
        runtime = API.ScriptRuntimeString(),
        status = "Online",
        health = tostring(API.GetHP_() or 0),
        max_health = tostring(API.GetHPMax_() or 0),
        prayer = tostring(API.GetPray_() or 0),
        skill_level = tostring(API.ScanForInterfaceTest2Get(false, bot_monitor.config.sL)[1].textids or 0),
        combat_level = tostring(API.ScanForInterfaceTest2Get(false, bot_monitor.config.cb)[1].textids or 0),
        is_dead = bot_monitor.checkArea() and "True" or "False",
        region_x = tostring(region_data.x),
        region_y = tostring(region_data.y),
        region_id = tostring(region_data.id),
    }
    
    local payload = ""
    for key, value in pairs(form_data) do
        payload = payload .. key .. "=" .. API.Filter(value, " ") .. "&"
    end
    payload = payload:sub(1, -2)
    
    bot_monitor.httpPost(bot_monitor.config.SERVER_URL, payload)
    return true
end

function bot_monitor.startMonitoring()
    API.Write_ScripCuRunning0("Sending bot stats...")
    while API.Read_LoopyLoop() do
        if not bot_monitor.sendBotData() then
            API.Log("Failed to send data: player not logged in", "warn")
        end
        API.Sleep_tick(bot_monitor.config.UPDATE_INTERVAL)
    end
end

return bot_monitor