# melon.docgen
Documentation generator for melonlib, handles this right here!

# Functions
## melon.docgen.Compile(str: string) 
Compiles the given string into a table of all the documentation in the file.
1. str: string - String to compile

## melon.docgen.CompileTo() 
Compiles the given docs into the target format, outputs to data/melon/docs/{target}/

## melon.docgen.Generate(str: string) 
Compiles everything from a folder recursively
1. str: string - Folder to recursively navigate and compile

## melon.docgen.GenerateMany(all: table) 
Compiles everything in all given folders and files into one table
1. all: table - Table of folders and files to compile together

## melon.docgen.HandleDocBlock() @ internal
Handles a docblock at the given location in code

## melon.docgen.HandleParam() @ internal
Handles a parameter definition after ---@

## melon.docgen.NormalizeUsage() @ internal
Normalizes code example strings to have consistent everything

```lua
local usage = melon.docgen.NormalizeUsage(tbl)

if not usage then
    print("No usage for the given code")
end
```

## melon.docgen.QualifyModule() @ internal
Qualifies the module name in the module table and returns a ref to the given module

