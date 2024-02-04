# MenuBarApps.spoon
MenuBarApps is a plugin for Hammerspoon which allows you to make macOS applications behave like Menu Bar items.

As an example, this configuration creates a Menu Bar item with the letter "P" which will automatically hide and show the "Plexamp" application when clicked:

![Screenshot](docs/images/menu.png)

The application will be automatically moved to the focused space in Mission Control. It can either be clicked out of like normal or hidden by clicking the Menu Bar icon again.

# Known Issues

* Currently does not handle applications that are not open or are minimzed
* In "move" mode it does not end up exactly under the Menu Bar item, particularly when there are several defined

# Installation

This Spoon depends on another Spoon being installed and loaded, [WindowCache](https://github.com/adammillerio/WindowCache.spoon).

## Automated

MenuBarApps can be automatically installed from my [Spoon Repository](https://github.com/adammillerio/Spoons) via [SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html). See the repository README or the SpoonInstall docs for more information.

Example `init.lua` configuration which configures `SpoonInstall` and uses it to install and start WindowCache and MenuBarApps:

```lua
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.adammillerio = {
    url = "https://github.com/adammillerio/Spoons",
    desc = "adammillerio Personal Spoon repository",
    branch = "main"
}

spoon.SpoonInstall:andUse("WindowCache", {repo = "adammillerio", start = true})

spoon.SpoonInstall:andUse("MenuBarApps", {
    config = {
        apps = {
            ["Plexamp"] = {title = "P", action = "move"},
            ["Discord"] = {title = "D", action = "maximize"}
        }
    },
    start = true
})
```

This will create two menu bar items:

* Menu Bar with icon "P" which opens the "Plexamp" application and moves it to be under the Menu Bar in the current Space
* Menu Bar with icon "D" which opens the "Discord" application and maximizes it in the current Space

These can then be moved around like any other menu bar items.

## Manual

Download the latest WindowCache release from [here.](https://github.com/adammillerio/Spoons/raw/main/Spoons/MenuBarApps.spoon.zip)

Download the latest MenuBarApps release from [here.](https://github.com/adammillerio/Spoons/raw/main/Spoons/MenuBarApps.spoon.zip)

Unzip both and either double click to load the Spoons or place the contents manually in `~/.hammerspoon/Spoons`

Then load the Spoons in `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("WindowCache")

hs.spoons.use("WindowCache", {start = true})

hs.loadSpoon("MenuBarApps")

hs.spoons.use("MenuBarApps", {
    config = {
        apps = {
            ["Plexamp"] = {title = "P", action = "move"},
            ["Discord"] = {title = "D", action = "maximize"}
        },
        start = true
    }
})
```

