local icons = require("icons")
local colors = require("colors")

sbar.exec("killall media_load >/dev/null; $CONFIG_DIR/helpers/mediaChange/bin/media_load playingEvent mediaEvent progressEvent 1.0")
sbar.add("event", "toggleMedia")

local mediaLeft = sbar.add("item", "mediaLeft", {
    icon = { 
        drawing = true,
        width = 17,
    },
    label = {
        drawing = true,
        max_chars = 13,
    },
    -- scroll_texts = true,
    y_offset = 4,
    position = "e",
    padding_left = 10,
})

local mediaRight = sbar.add("item", "mediaRight", {
    icon = {
        drawing = true,
        string = "-",
        padding_right = 10,
    },
    label = {
        drawing = "true",
        max_chars = 7,
    },
    -- scroll_texts = true,
    y_offset = 4,
    position = "e",
})

local progress = sbar.add("slider", "progressSlider", 100, {
    position = "e",
    padding_left = -105,
    y_offset = -6,
    drawing = true,
    label = { drawing = false },
    icon = { drawing = false },
    slider = {
        highlight_color = colors.magenta,
        background = {
            height = 2,
            corner_radius = 3,
            color = colors.bg2,
        },
        knob = {
            drawing = false,
        }
    }
})

local function playingUpdate(env) 
    if env.playing == "true" then
        mediaLeft:set({
            icon = icons.media.playing
        })
    elseif env.playing == "false" then
        mediaLeft:set({
            icon = icons.media.paused
        })
    end
end

local function mediaUpdate(env)
    mediaLeft:set({
        label = env.title
    })
    mediaRight:set({
        label = env.artist
    })
    sbar.exec("sketchybar --query mediaLeft", function(left)
        sbar.exec("sketchybar --query mediaRight", function(right)
            local total = left["bounding_rects"]["display-1"]["size"][1] + right["bounding_rects"]["display-1"]["size"][1]
            progress:set({ padding_left = -(total + 5), slider = { width = total }})
        end)
    end)
end

local function progressBarUpdate(env)
    progress:set({ slider = { percentage = env.percentage }})
end

local function stopMediaUpdates()
    sbar.exec("killall media_load > /dev/null")
    progress:set({ slider = { percentage = 100, highlight_color = colors.red }})
    mediaLeft:set({ icon = icons.media.none })
    mediaUpdate({ title = " ", artist = " " })
    -- currentColor = tonumber(progress:query().slider.highlight_color)
end

local function startMediaUpdates()
    progress:set({ slider = { percentage = 0, highlight_color = colors.magenta }})
    sbar.exec("$CONFIG_DIR/helpers/mediaChange/bin/media_load playingEvent mediaEvent progressEvent 1.0")
end

local function toggleUpdates(env)
    if env.VAR == "true" then
        startMediaUpdates()
    elseif env.VAR == "false" then
        stopMediaUpdates()
    else
        currentColor = tonumber(progress:query().slider.highlight_color)
        if currentColor == colors.magenta then
            stopMediaUpdates()
        else
            startMediaUpdates()
        end
    end
end

mediaLeft:subscribe("playingEvent", playingUpdate)
mediaLeft:subscribe("mediaEvent", mediaUpdate)
mediaLeft:subscribe("mouse.clicked", stopMediaUpdates)
mediaRight:subscribe("mouse.clicked", stopMediaUpdates)
progress:subscribe("progressEvent", progressBarUpdate)
progress:subscribe("toggleMedia", toggleUpdates)

local bracket = sbar.add("bracket", { progress.name, mediaLeft.name, mediaRight.name }, {
    background = { 
        color = colors.transparent, 
        border_color = colors.bg2,
        height = 30,
        x_offset = 7,
    }
})

bracket:subscribe("mouse.clicked", stopMediaUpdates)
