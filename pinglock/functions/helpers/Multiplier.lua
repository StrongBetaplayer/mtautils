

local SCREEN, MULTIPLIER = Vector2(GuiElement.getScreenSize()), false

local function reMap(value, low1, high1, low2, high2) 

    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

local function setMultiplier()

    MULTIPLIER = reMap(SCREEN.x*0.8, 1024, 1920, 0.75, 1);

return true 
end

local function getMultiplier()
    
    if not MULTIPLIER then setMultiplier() end

return MULTIPLIER
end

local ceil = math.ceil

function fit(value)

return ceil(value * getMultiplier())
end