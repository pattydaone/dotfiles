local icons = require("icons")

sbar.add("event", "inputChange", "AppleSelectedInputSourcesChangedNotification")

local us_actual = "U.S."
local jpn_actual = "com.apple.inputmethod.Japanese"

local inputMethod = sbar.add("item", "inputMethod", {
    position = "q",
    icon = {
        drawing = true,
        font = { size = 17 },
        string = icons.inputMethod.english
    }
})

inputMethod:subscribe("inputChange", function()
    sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources", function(output)
        if string.find(output, us_actual) then
            inputMethod:set({
                icon = icons.inputMethod.english
            })
        elseif string.find(output, jpn_actual) then
            inputMethod:set({
                icon = icons.inputMethod.japanese
            })
        else
            inputMethod:set({
                icon = "idk"
            })
        end
    end)
end)
