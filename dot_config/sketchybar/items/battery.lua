local icons = require("icons")
local colors = require("colors")

local battery = sbar.add("item", "battery", {
    background = { 
        color = colors.transparent, 
        -- border_color = colors.bg2,
        height = 30,
    },
    position = "right",
    icon = {
        font = {
            style = "Regular",
            size = 19.0,
        }
    },
    label = { drawing = true },
    update_freq = 120,
})

local function battery_update()
    sbar.exec("pmset -g batt", function(batt_info)
        local icon = "!"
        local found, _, charge = batt_info:find("(%d+)%%")

        if (string.find(batt_info, 'AC Power')) then
            icon = icons.battery.charging
        else
            if found then
                charge = tonumber(charge)
            end

            if found and charge > 80 then
                icon = icons.battery._100
            elseif found and charge > 60 then
                icon = icons.battery._75
            elseif found and charge > 40 then
                icon = icons.battery._50
            elseif found and charge > 20 then
                icon = icons.battery._25
            else
                icon = icons.battery._0
            end
        end


        battery:set({ icon = icon })
        battery:set({ label = charge .. "%"})
    end)
end


battery:subscribe({"routine", "power_source_change", "system_woke"}, battery_update)
