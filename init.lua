--- === MenuBarApps ===
---
--- Control applications from the macOS Menu Bar 
---
--- Download: https://github.com/adammillerio/Spoons/raw/main/Spoons/MenuBarApps.spoon.zip
--- 
--- README with Example Usage: [README.md](https://github.com/adammillerio/MenuBarApps.spoon/blob/main/README.md)
local MenuBarApps = {}

MenuBarApps.__index = MenuBarApps

-- Metadata
MenuBarApps.name = "MenuBarApps"
MenuBarApps.version = "0.0.2"
MenuBarApps.author = "Adam Miller <adam@adammiller.io>"
MenuBarApps.homepage = "https://github.com/adammillerio/MenuBarApps.spoon"
MenuBarApps.license = "MIT - https://opensource.org/licenses/MIT"

-- Dependency Spoons
-- WindowCache is used for quick retrieval of windows when showing/hiding.
WindowCache = spoon.WindowCache

--- MenuBarApps.action.move
--- Constant
--- Move the window to appear under the menu bar item as if it were a menu.

--- MenuBarApps.action.maximize
--- Constant
--- Maximize the application on the current space if it is not maximized already.

local actions = {move = "move", maximize = "maximize"}

for k in pairs(actions) do MenuBarApps[k] = k end -- expose actions

--- MenuBarApps.apps
--- Variable
--- Table containing each application's name and it's desired configuration. The
--- key of each entry is the name of the App as it appears in the title bar, and
--- the value is a configuration table with the following entries:
---     * title - String with title text to display in the menu bar icon itself
---     * action - String with action to take on window when showing. See constants.
MenuBarApps.apps = nil

--- MenuBarApps.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log 
--- level for the messages coming from the Spoon.
MenuBarApps.logger = nil

--- MenuBarApps.logLevel
--- Variable
--- MenuBarApps specific log level override, see hs.logger.setLogLevel for options.
MenuBarApps.logLevel = nil

--- MenuBarApps.menuBars
--- Variable
--- Table containing references to all of the created menu bars.
MenuBarApps.menuBars = nil

--- MenuBarApps:init()
--- Method
--- Spoon initializer method for MenuBarApps.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function MenuBarApps:init() self.menuBars = {} end

-- Utility method for having instance specific callbacks.
-- Inputs are the callback fn and any arguments to be applied after the instance
-- reference.
function MenuBarApps:_instanceCallback(callback, ...)
    return hs.fnutils.partial(callback, self, ...)
end

-- Handler for a menu bar click.
-- Inputs are the hs.menubar clicked and the configured appName and config.
function MenuBarApps:_menuBarClicked(menuBar, appName, config)
    -- Get app hs.window
    appWindow = WindowCache:findWindowByApp(appName)
    if not appWindow then
        self.logger.ef("%s is not open or hidden", appName)
        return
    end

    -- Get app's application
    app = appWindow:application()

    -- If this window is not the frontmost window, then we need to act on it
    if hs.window.frontmostWindow():id() ~= appWindow:id() then
        -- Move the window to the currently focused space.
        hs.spaces.moveWindowToSpace(appWindow, hs.spaces.focusedSpace())

        -- move mode - This moves the application under the menu bar item so that it
        -- appears like a menu
        if config.action == actions.move then
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
        elseif config.action == actions.maximize then
            if appWindow:isMaximizable() then appWindow:maximize() end
        else
            self.logger.ef("Unknown action %s", config.action)
        end

        app:activate()
    else
        app:hide()
    end
end

-- Generate a sub menu for a menu bar.
-- Input is the menuConfig.
function MenuBarApps:_createMenu(menuConfig)
    self.logger.vf("Creating menu with config: %s", hs.inspect(menuConfig))
    local menu = {}

    for _, config in ipairs(menuConfig) do
        self.logger.vf("Creating menuItem config: %s", hs.inspect(config))
        local menuItem = {}

        if config.action ~= "menu" then
            self.logger
                .vf("Setting menu item to config: %s", hs.inspect(config))
            menuItem.fn = self:_instanceCallback(self._menuBarClicked, menuBar,
                                                 config.app, config)
        else
            self.logger.vf("Creating new child menu with config: %s",
                           hs.inspect(config.menu))
            menuItem.menu = self:_createMenu(config.menu)
        end

        menuItem.title = config.title

        self.logger.vf("Adding menu item: %s", hs.inspect(menuItem))
        table.insert(menu, menuItem)
    end

    self.logger.vf("Generated menu: %s", hs.inspect(menu))
    return menu
end

-- Utility method for creating a new menu bar and adding it to the table.
-- Input is the menu config.
function MenuBarApps:_createMenuBar(config)
    self.logger.vf("Creating MenuBar with config: %s", hs.inspect(config))

    menuBar = hs.menubar.new()

    if config.action ~= "menu" then
        self.logger.vf("(%s) Not Menu: Setting item click callback",
                       config.title)
        menuBar:setClickCallback(self:_instanceCallback(self._menuBarClicked,
                                                        menuBar, config.app,
                                                        config))
    else
        self.logger.vf("(%s) Menu: Generating main menu", config.title)
        menuBar:setMenu(self:_createMenu(config.menu))
    end

    menuBar:setTitle(config.title)

    table.insert(self.menuBars, menuBar)
end

--- MenuBarApps:start()
--- Method
--- Spoon start method for MenuBarApps. Creates all configured menu bars.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function MenuBarApps:start()
    -- Start logger, this has to be done in start because it relies on config.
    self.logger = hs.logger.new("MenuBarApps")

    if self.logLevel ~= nil then self.logger.setLogLevel(self.logLevel) end

    self.logger.v("Starting MenuBarApps")

    for _, config in ipairs(self.apps) do self:_createMenuBar(config) end
end

--- MenuBarApps:stop()
--- Method
--- Spoon stop method for MenuBarApps. Deletes all configured menu bars.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function MenuBarApps:stop()
    self.logger.v("Stopping MenuBarApps")

    for i, menuBar in ipairs(self.menuBars) do menuBar:delete() end
end

return MenuBarApps
