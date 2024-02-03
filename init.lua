--- === MenuBarApps ===
---
--- Control applications from the macOS Menu Bar 
---
--- Download: [https://github.com/adammillerio/MenuBarApps.spoon/archive/refs/heads/main.zip](https://github.com/adammillerio/MenuBarApps.spoon/archive/refs/heads/main.zip)
local obj = {}
obj.__index = obj

WindowCache = spoon.WindowCache

-- MenuBarApps.logger
-- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = nil

obj.menuBars = nil

function obj:init()
    obj.logger = hs.logger.new('MenuBarApps')

    obj.menuBars = {}
end

local function menuBarClicked(menuBar, appName, config)
    -- Get app hs.window
    appWindow = WindowCache:findWindowByApp(appName)
    if not appWindow then
        obj.logger.ef("%s is not open or hidden", appName)
        return
    end

    -- Get app's application
    app = appWindow:application()

    -- If this window is not the frontmost window, then we need to act on it
    if hs.window.frontmostWindow():id() ~= appWindow:id() then
        hs.spaces.moveWindowToSpace(appWindow, hs.spaces.focusedSpace())

        -- move mode - This moves the application under the menu bar item so that it
        -- appears like a menu
        if config.action == "move" then
            -- Get rect representing the frame of the app window
            appWindowFrame = appWindow:frame()
            -- Get rect representing the frame of the menubar item
            appMenuBarFrame = menuBar:frame()

            -- move() only moves in absolute coordinates if a rect is provided, so we
            -- just update the appWindowFrame rect's x coordinate to be such that it is
            -- under the menubar item, aligned to the right.
            appWindowFrame.x = appMenuBarFrame.x -
                                   (appWindowFrame.w - appMenuBarFrame.w)
            -- Do a similar transformation for y
            appWindowFrame.y = appMenuBarFrame.y + appMenuBarFrame.h

            -- Move the window to the desired location
            appWindow:move(appWindowFrame)
            -- maximize mode - This just maxmizes the app if it isn't already
        elseif config.action == "maximize" then
            if appWindow:isMaximizable() then appWindow:maximize() end
        else
            obj.logger.ef("Unknown action %s", config.action)
        end

        app:activate()
    else
        app:hide()
    end
end

local function createMenuBar(appName, config)
    menuBar = hs.menubar.new()

    menuBar:setClickCallback(function()
        menuBarClicked(menuBar, appName, config)
    end)
    menuBar:setTitle(config.title)

    table.insert(obj.menuBars, menuBar)
end

function obj:start()
    for appName, config in pairs(obj.apps) do createMenuBar(appName, config) end
end

function obj:stop()
    for i, menuBar in ipairs(obj.menuBars) do menuBar:delete() end
end

return obj
