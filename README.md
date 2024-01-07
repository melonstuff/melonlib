![logo](https://i.imgur.com/4tO48eh.png)

MelonLib is a multipurpose Garry's Mod development library that includes a plethora of different utilities.

> Documentation can be found above the function declarations, formal documentation is coming soon:tm:

# Includes
- Tons of development utilities
  - Panel Debugger
  - Meta-File Interfacing
  - Function Attribute System
  - Message Logger
- Advanced String Formatting with Filters
- Font System
- Color Manipulation Functions
- Image/Material Caching and Downloading Handler
- Complete Module Loading System
- Many third-party libraries
  - [Material Avatar](https://github.com/WilliamVenner/glua-material-avatar)
  - [Circles!](https://github.com/SneakySquid/Circles)
  - [UI3d2d](https://github.com/TomDotBat/ui3d2d)
- And lots more little utilities!

# Examples

String Formatting System:
```lua
melon.string.print("Did you know that {name | capitalize()} are {adjective}?", {
    name = "you",
    adjective = "bald"
})
-- Did you know that You are bald?

melon.string.print("you are {1}, {2} and {3.1}", 
"fat", 
"weird", 
{
    "smelly"
})
-- you are fat, weird and smelly

melon.string.print("Blah blah blah {1:Nick|call($1)}", LocalPlayer())
-- Blah blah blah Melon
```

Font System:
```lua
draw.Text({
    text = "Some Text",
    pos = {},

    -- Creates and returns a 25px font
    font = melon.Font(25)
})
```

Image/Material System:
```lua
surface.SetMaterial(
    -- Caches material automatically
    melon.Material("icon16/user.png", "smooth") 
)

surface.SetMaterial(
    -- Downloads and returns inline
    melon.Image("https://i.imgur.com/xYWFeyG.jpg")
)
```

