local icons = require("icons")
local colors = require("colors")

sbar.exec("killall change_load >/dev/null; $CONFIG_DIR/helpers/audioOutputChange/bin/change_load audioDeviceChange 1.0")

local audio = sbar.add("item", "audio", {
    background = { 
        color = colors.transparent, 
        height = 30,
    },
    position = "right",
    icon = {
        drawing = true,
        font = { size = 14 },
        padding_left = 5,
        width = 30
    },
    label = {
        width = 35,
        align = "right",
        font = {
            style = "Regular",
            size = 12.0,
        },
        padding_right = 5,
    },
})

audio:subscribe("audioDeviceChange", function(env)
    if env.device_name == "AirPods Pro" then
        audio:set({
            icon = icons.output.airpods
        })
    elseif env.device_name == "MacBook Air Speakers" then
        audio:set({
            icon = icons.output.speakers
        })
    end
end)

audio:subscribe("volume_change", function(env)
    local volumeNum = tonumber(env.INFO)
    audio:set({ label = volumeNum .. "%" })
end)
