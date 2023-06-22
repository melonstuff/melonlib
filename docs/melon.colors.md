# melon.colors
Handles color modification and other things

# Functions
## melon.colors.FromHex(hex: string) 
Converts a hex color of 3, 4, 6 or 8 characters into a [Color] object
1. hex: string - Hex color

## melon.colors.IsLight(col: color) 
Get if a color is dark or light, primarily for dynamic text colors
1. col: color - Color to check

## melon.colors.Lerp(amt: number, from: color, to: color) 
Returns a new [Color] thats interpolated by from/to
1. amt: number - Amount to interpolate by
2. from: color - From color
3. to: color - To color

## melon.colors.Rainbow() 
Generates a consistent rainbow color

