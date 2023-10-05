--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (shapes)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- row patterns
SOLID = 1       -- all colors the same in this row
ALTERNATE = 2   -- alternating colors
SKIP = 3        -- skip every other block
NONE = 4        -- no blocks at all in this row

LevelMaker = Class{} 

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1, 5)

    -- randomly choose the number of columns, but ensure the number is odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    local highestColor = math.min(3, math.floor(level / 5))
    local highestTier = math.min(5, level % 5 + 3)

    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        -- determine whether or not to skip the current row
        local skipPattern = math.random(1, 2) == 1 and true or false 

        -- determine whether to use alternate patterns in this row
        local alternatePattern = math.random(1, 2) == 1 and true or false 

        -- choose the alternating colors
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        -- used only for skipping a block in the skip pattern
        local skipFlag = math.random(2) == 1 and true or false
        
        -- used only for alternating a block in the alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false 

        -- solid color to use if not alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            -- if skipping is turned on and we're on a skip iteration
            if skipPattern and skipFlag then 
                -- turn off skipping for next iteration
                skipFlag = not skipFlag 

                goto continue
            else 
                -- flip the flag back
                skipFlag = not skipFlag
            end

            b = Brick(
                -- x-coordinate
                (x-1)                   -- decrement x by 1 because tables are 1-indexed, coords are 0
                * 32                    -- multiply by 32, the brick width
                + 8                     -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixels total
                + (13 - numCols) * 16,  -- left-side padding for when there are fewer than 13 columns
                
                -- y-coordinate
                y * 16                  -- just use y * 16, since we need top padding anyway
            ) 

            -- if in alternating pattern, figure out which one we are on
            if alternatePattern and alternateFlag then 
                b.color = alternateColor1 
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else 
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag 
            end

            -- if not in alternating pattern, use the solid color and tier
            if not alternatePattern then 
                b.color = solidColor 
                b.tier = solidTier 
            end

            table.insert(bricks, b)

            :: continue ::
        end
    end 

    if #bricks == 0 then 
        return self.createMap(level)
    else
        return bricks
    end
end