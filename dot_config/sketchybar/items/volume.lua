local colors = require("colors")
local icons = require("icons")

local volume = sbar.add("item", {
    position = "right",
    label = {
        width = 35,
        align = "right",
        font = {
            style = "Regular",
            size = 12.0,
        },
    },
})

volume:subscribe("volume_change", function(env)
    local volumeNum = tonumber(env.INFO)
    volume:set({ label = volumeNum .. "%" })
end)
