# melon
Main module table for the library

# Modules
- [net](melon.net.md)
- [panels](melon.panels.md)
- [Extensions](melon.Extensions.md)
- [docgen](melon.docgen.md)
- [colors](melon.colors.md)
- [http](melon.http.md)
- [math](melon.math.md)
- [string](melon.string.md)

# Functions
## melon.__file__() @ internal
If you dont understand the source for this, dont use it.

## melon.__file_contents__() @ internal
If you dont understand the source for this, dont use it.

## melon.__file_state__() @ internal
If you dont understand the source for this, dont use it.

## melon.__load() @ internal
Loads everything in the library

## melon.AccessorTable() @ deprecated
Dont use this

## melon.AddLoadHandler() @ internal
Adds a load handler for melonlib, sh_, cl_ and sv_ are all loadhandlers

## melon.clr() 
"Clears" the console by spamming newlines, only functions post gamemode loaded

## melon.Debug(fun: func, clr: bool) 
Executes a function only after the gamemodes loaded, used for hot refreshing and stuff
1. fun: func - Function to call on hot refresh
2. clr: bool - Clear the console before executing?

## melon.DebugPanel(name: string, fun: func) 
Creates a debug panel containing the given function, lay this out in fun()
1. name: string - Panel name registered with [vgui.Register]
2. fun: func - Function thats called with the panel as its only argument

## melon.DefineNewBehavior() @ internal, deprecated
Weird experiment thats not really used, dont use.

## melon.DeQuickSerialize(str: string) 
Deserialized a table serialized with [melon.QuickSerialize]
1. str: string - String to deserialize

## melon.DrawAvatar(stid: string, x: number, y: number, w: number, h: number) 
Draws a players avatar image reliably.
1. stid: string - SteamID64 of the player to draw the avatar of
2. x: number - X of the image to draw
3. y: number - Y of the image to draw
4. w: number - W of the image to draw
5. h: number - H of the image to draw

## melon.DrawBlur(panel: panel, localX: type, localY: type, w: type, h: type, passes: type) 
Draws blur!
1. panel: panel - Panel to draw the blur on
2. localX: type - X relative to 0 of the panel
3. localY: type - Y relative to 0 of the panel
4. w: type - W of the blur
5. h: type - H of the blur
6. passes: type - How many passes to run, basically the strength of the blur

## melon.DrawImage(url: string, x: number, y: number, w: number, h: number) 
Draw an image, handles loading and everything else for you, for use in a 2d rendering hook.
1. url: string - URL to the image you want to draw
2. x: number - X of the image to draw
3. y: number - Y of the image to draw
4. w: number - W of the image to draw
5. h: number - H of the image to draw

## melon.DrawImageRotated(url: string, x: number, y: number, w: number, h: number, rot: number) 
Identical to [melon.DrawImage] except draws it rotated
1. url: string - URL to the image you want to draw
2. x: number - X of the image to draw
3. y: number - Y of the image to draw
4. w: number - W of the image to draw
5. h: number - H of the image to draw
6. rot: number - Rotation of the image to draw

## melon.Font(size: number, font: string) 
For use in 2d rendering hooks, create a font if it doesnt exist with the given size/fontname.
1. size: number - Font size to be scaled
2. font: string - Optional, font to base the new font off of

## melon.FontGenerator(font: string) 
Creates a [melon.FontGeneratorObject], an object that allows you to use the font system to consistently create fonts of the same font without constant config indexing.
1. font: string - Font name for the generator to use

## melon.GetPlayerAvatar(stid64: string) @ internal
Gets a players avatar image from the cache if it exists and initiates downloading it if not, dont use.
1. stid64: string - SteamID64 of the players avatar youd like to get

## melon.Grid(w: number, h: number) 
Creates a [melon.GridObject]
1. w: number - Width to create the grid as
2. h: number - Height to create the grid as

## melon.HTTP(data: table) 
Queues an HTTP request to run whenever available
1. data: table - [HTTPRequest] data to execute with

## melon.Image(url: string) 
Remote image downloader and cache handler. Discord is unreliable, use imgur.
1. url: string - URL to the image to download

## melon.IsColor(color: table) 
Check if the given value is a color, use istable first.
1. color: table - Color to check

## melon.KV2VK(tbl: table) 
Inverts a tables keys and values ([k] = v) into ([v] = k) for every pair in the given table.
1. tbl: table - Table to convert

## melon.LoadDirectory() @ internal
Loads a directory recursively, for core use

## melon.LoadModule(folder: string) 
Loads a module from modules/ dynamically, reading __init__ and everything else.
1. folder: string - Module folder name to load

## melon.Map(tbl: table, fn: func) 
Maps a table to a new table, calling func with every key and value.
1. tbl: table - Table to map
2. fn: func - Function that takes k,v and returns a new k,v

## melon.Material(path: string, opts: string) 
Automatically caches and returns materials, helper function for rendering hooks, identical to [Material] except cached
1. path: string - Path to the image
2. opts: string - Optional, Options to give the material, identical to [Material]'s second arg

## melon.MODULE(name: string) @ deprecated
Get the [melon.ModuleObject] of the given name if it exists.
1. name: string - Module to get the object of

## melon.ParseVersion(text: string) 
Parses a string in the format major.minor.patch, 1.0.0, 45.56.67 into the version itself
1. text: string - A string of 3 parts separated by .

## melon.Profile() @ deprecated
Unsure how functional this actually is.

## melon.QuickSerialize(tbl: table) 
Serializes a table very simply, only allows string keys and values format is key::value;key2::value2;
1. tbl: table - Table to serialize

## melon.ReloadAll() 
Reloads melonlib, only functions post gamemode loaded

## melon.SanitizeURL(url: string) 
Sanitize a URL for use in filenames, literally only allows alpha characters
1. url: string - URL to sanitize

## melon.Scale(num: number) 
Scales a number based on [ScrH] / 1080
1. num: number - Number to scale

## melon.ScaleN(nums: ...number) @ deprecated
Scales multiple numbers, dont use, unpack is stupid.
1. nums: ...number - Vararg numbers to scale

## melon.SpecialFont(size: number, opts: table) 
Same as [melon.Font] except creates it with a [FontData] table instead of a font name. Dont use in rendering hooks as it is exponentially slower
1. size: number - Font size
2. opts: table - Options to give the font

## melon.StackOverflowProtection(id: any) 
Tracks a loop with the given id to prevent stack overflows, nothing fancy.
1. id: any - Identifier used for tracking

## melon.SubTable(tbl: table, from: number, to: number) 
Gets a subtable of the given table from the range of from to to, think string.sub()
1. tbl: table - Table to get the subtable of
2. from: number - Starting index
3. to: number - Ending index

## melon.ToColor(input: table) 
Converts the given table into a valid [Color] object
1. input: table - Table to convert to a Color

## melon.UnscaledFont(size: number, font: string) 
Same as [melon.Font] except the size is unscale.
1. size: number - Font size raw
2. font: string - Optional, font to base the new font off of

## melon.URLExtension(url: string) @ internal
Gets the extension of a url, relic of the ancient past, dont use.
1. url: string - URL to get the file extension of

