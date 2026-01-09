local icons = require("icons")
local colors = require("colors")

sbar.add("event", "dndEnabled", "_NSDoNotDisturbEnabledNotification")
sbar.add("event", "dndDisabled", "_NSDoNotDisturbDisabledNotification")

local dnd = sbar.add("item", {
    background = { 
        color = colors.transparent, 
        height = 30,
    },
    position = "q",
    icon = {
        drawing = false,
        font = { size = 17 },
        string = icons.doNotDisturb
    },
    label = {
        drawing = false
    },
})

local function eventFunct(enabled)
    dnd:set({ drawing = enabled })
    sbar:query().battery:set({ drawing = enabled })
    sbar:query().audio:set({ drawing = enabled })
    sbar:query().wifi:set({ drawing = enabled })
    sbar.trigger("toggleMedia", "VAR=" .. enabled)

    if enabled then
        sbar.exec("killall change_load >/dev/null")
    elseif not enabled then
        sbar.exec("$CONFIG_DIR/helpers/audioOutputChange/bin/change_load audioDeviceChange 1.0")
    else
        print("something has gone terribly wrong!!!")
    end
end

dnd:subscribe("dndEnabled", function(env) 
    eventFunct(false)
end)
dnd:subscribe("dndDisabled", function(env)
    eventFunct(true)
end)
