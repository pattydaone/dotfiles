local icons = require("icons")

local wifi = sbar.add("item", "wifi", {
    position = "right",
    icon = {
        drawing = true,
        font = { size = 14 },
    },
    label = { drawing = false }
})

-- Source - https://stackoverflow.com/a/27028488
-- Posted by hookenz, modified by community. See post 'Timeline' for change history
-- Retrieved 2025-11-17, License - CC BY-SA 4.0

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


local function update(env) 
    sbar.exec("ipconfig getsummary en0", function(strPackage)
        local connected = string.find(strPackage, "LinkStatusActive")
        if connected ~= nil then
            wifi:set({
                icon = icons.wifi.connected
            })
        else
            wifi:set({
                icon = icons.wifi.disconnected
            })
        end
    end)
end

wifi:subscribe("wifi_change", update)
