-- A Löve2d game including a platform and a mustache

tileset = require("lib.tileset")
thePlayer = require("lib.player")
theWorld = require("lib.world")

tilesize = 50

-- Keeping track of the controls
isJumping = 0

function love.load()    
    -- Set the window size
    love.window.setMode(tilesize * 10, tilesize * 10)
    
    -- Just init an 2d array acting as our playing field
    table = tileset:init(10,10)
    
    -- Set one row to 1 (for solid blocks)
    for x = 1, 10 do
        table[x][10] = 1
    end
    
    table[10][2] = 1
    table[10][3] = 1
    table[1][2] = 1
    table[1][3] = 1
    table[6][9] = 1
    table[6][8] = 1
    table[4][9] = 1
    table[6][6] = 1
    table[2][8] = 1
    table[2][7] = 1
    table[3][5] = 1
    table[4][5] = 1
    table[5][5] = 1
    -- Position the player
    thePlayer.x = 230
    thePlayer.y = 100
end
 
function love.update(dt)
    -- Set player speed based on keyboard input
    if love.keyboard.isDown('d') then
        if math.abs(thePlayer.xSpeed) < thePlayer.runSpeed then
            thePlayer.xSpeed = thePlayer.xSpeed + thePlayer.acceleration * dt
        end
        if thePlayer.xSpeed > thePlayer.runSpeed then
            thePlayer.xSpeed = thePlayer.runSpeed
        end
    end
    if love.keyboard.isDown('a') then
        if math.abs(thePlayer.xSpeed) < thePlayer.runSpeed then
            thePlayer.xSpeed = thePlayer.xSpeed - thePlayer.acceleration * dt
        end
        if -thePlayer.xSpeed > thePlayer.runSpeed then
            thePlayer.xSpeed = -thePlayer.runSpeed
        end
    end
    if love.keyboard.isDown('w') and thePlayer.airborne == 0 then
        print(thePlayer.xSpeed)
        if thePlayer.lastJumpTime == 0 then
                thePlayer.lastJumpTime = love.timer.getTime()
        end
        if love.timer.getTime() - thePlayer.lastJumpTime >= thePlayer.allowJumpAfter then        
            thePlayer.ySpeed = thePlayer.jumpHeight
            thePlayer.airborne = 1
            --print(love.timer.getTime() - thePlayer.lastJumpTime.." allow to Jump after "..thePlayer.allowJumpAfter)
            thePlayer.lastJumpTime = love.timer.getTime()
        else
            --print(love.timer.getTime() - thePlayer.lastJumpTime.." allow to Jump after "..thePlayer.allowJumpAfter)
        end
    end
    if not love.keyboard.isDown('w') then
       thePlayer.jastJumpTime = love.timer.getTime()
       -- Nothing
    end
    if not love.keyboard.isDown('d') and not love.keyboard.isDown('a') then
        -- Apply drag to the player
        if thePlayer.xSpeed > 0 then
            thePlayer.xSpeed = thePlayer.xSpeed - theWorld.drag * dt
            if thePlayer.xSpeed < 0 then
                thePlayer.xSpeed = 0
            end
            print("Above zero - Setting speed to "..thePlayer.xSpeed)
        end
    end
    if not love.keyboard.isDown('a') and not love.keyboard.isDown('w') then
        if thePlayer.xSpeed < 0 then
            thePlayer.xSpeed = thePlayer.xSpeed + theWorld.drag * dt
            if thePlayer.xSpeed > 0 then
                thePlayer.xSpeed = 0
            end
            print("Less than 0 - Setting speed to "..thePlayer.xSpeed)
        end
    end
    if love.keyboard.isDown('g') then
        thePlayer.x = 200
        thePlayer.y = -100
        thePlayer.ySpeed = 0
        thePlayer.xSpeed = 0
    end
    
    -- Apply force to the player
    if thePlayer.airborne == 1 then
        thePlayer.ySpeed = thePlayer.ySpeed - theWorld.gravity
    end

    
    -- Apply gravity to the player
    nextY = math.floor(thePlayer.y + thePlayer.ySpeed * dt)
    nextX = math.floor(thePlayer.x + thePlayer.xSpeed * dt)
    
    -- Check for collisions in the tiles around the player
    tileX = math.floor(nextX / tilesize) + 1
    tileY = math.floor(nextY / tilesize) + 1
    
    -- Always set the player to airborne and explicitly determine whether it should be set to 0
    thePlayer.airborne = 1
    
    px = nextX - thePlayer.width / 2
    py = nextY - thePlayer.height / 2
    pw = px + thePlayer.width
    ph = py + thePlayer.height    
    
    -- Check all the tiles surrounding the player
    for ctX = tileX - 1, tileX + 1 do
        for ctY = tileY - 1, tileY + 1 do
            if ctX > 0 and ctX <= 10 and ctY > 0 and ctY <= 10 and table[ctX][ctY] == 1 then
                x = (ctX - 1) * tilesize
                y = (ctY - 1) * tilesize
                w = tilesize + x
                h = tilesize + y
                
                --[[if (pw > x and pw < w and ph > y and ph <= h + 1) or
                   (px < w and px > x and ph > y and ph <= h + 1) or 
                   (px > x and pw < w and ph > y and ph <= h + 1) or
                   (px > x and pw < w and py > y and ph <= h + 1) then --]]
                
                if (pw > x and pw < w and py > y and py < h) or
                   (pw > x and pw < w and ph > y and ph < h) or
                   (pw > x and pw < w and py > y and py < h) or
                   (px > x and pw < w and ph > y and ph < h) or
                   (px > x and pw < w and py > y and ph < h) or
                   (px > x and pw < w and py > y and py < h) or
                   (px > x and px < w and ph > y and ph < h) or
                   (px > x and px < w and py > y and ph < h) or
                   (px > x and px < w and py > y and py < h) then
                    
                    -- Collision?

                    -- Figure out which side that collided
                    if ctX < tileX and ctY < tileY then
                        -- Upper left. Cancel any ySpeed and reset the player
                        print("Upper left")
                        if thePlayer.xSpeed < 0 then
                            thePlayer.xSpeed = 0
                            nextX = w + thePlayer.width / 2
                        end
                        --thePlayer.ySpeed = 0
                        --thePlayer.airborne = 0
                        --nextY = h - thePlayer.height / 2
                    end
                    if ctX == tileX and ctY < tileY then
                        -- Upper middle. Cancel any ySpeed and reset the player
                        print("Upper middle")
                        if thePlayer.ySpeed < 0 then
                            thePlayer.ySpeed = 0
                            nextY = h + thePlayer.height / 2    
                        end
                        --thePlayer.airborne = 0

                    end
                    if ctX > tileX and ctY < tileY then
                        -- Upper right. Cancel any negative ySpeed (player jumping) and reset the player
                        print("Upper right")
                        if thePlayer.xSpeed > 0 then
                            thePlayer.xSpeed = 0
                            nextX = x - thePlayer.width / 2
                        end
                        --thePlayer.ySpeed = 0
                        --thePlayer.airborne = 0
                        --nextY = h - thePlayer.height / 2
                    end
                    if ctX < tileX and ctY == tileY then
                        -- Middle left. Cancel any xSpeed and reset the player
                        print("Middle left")
                        if thePlayer.xSpeed < 0 then
                            thePlayer.ySpeed = thePlayer.ySpeed / 1.5
                        end
                        thePlayer.xSpeed = 0
                        nextX = w + thePlayer.width / 2        
                    end
                    if ctX == tileX and ctY == tileY then
                        print("Middle")
                        -- Middle. This is a tricky situation. Clipping through
                        if thePlayer.ySpeed > 0 then
                            thePlayer.ySpeed = 0
                            nextY = y - thePlayer.height / 2
                        end
                        if thePlayer.ySpeed < 0 then
                            thePlayer.ySpeed = 0
                            nextY = h - thePlayer.height / 2
                        end
                        if thePlayer.xSpeed > 0 then
                            thePlayer.xSpeed = 0
                            nextX = x - thePlayer.width / 2
                        end
                        if thePlayer.xSpeed < 0 then
                            thePlayer.xSpeed = 0
                            nextX = w + thePlayer.width / 2
                        end
                    end
                    if ctX > tileX and ctY == tileY then
                        -- Middle right. Cancel any xSpeed and reset the player
                        print("Middle right")
                        if thePlayer.xSpeed > 0 then
                            thePlayer.ySpeed = thePlayer.ySpeed / 1.5
                        end
                        thePlayer.xSpeed = 0
                        nextX = x - thePlayer.width / 2
                    end
                    if ctX < tileX and ctY > tileY then
                        -- Lower left. Cancel any ySpeed and reset the player
                        -- But only if the lower middle is not there
                        print("Lower left")
                        if table[ctX+1][ctY] == 1 then
                            print("Solid below")
                            thePlayer.ySpeed = 0
                            thePlayer.airborne = 0
                            nextY = y - thePlayer.height / 2
                        end
                    end
                    if ctX == tileX and ctY > tileY then
                        -- Lower middle. Cancel any ySpeed and reset the player
                        print("Lower middle")
                        thePlayer.ySpeed = 0
                        thePlayer.airborne = 0
                        nextY = y - thePlayer.height / 2
                    end
                    if ctX > tileX and ctY > tileY then
                        -- Lower right. Cancel any ySpeed and reset the player
                        -- But only if the lower middle is not there
                        print("Lower right")
                        if table[ctX-1][ctY] == 1 then
                            thePlayer.ySpeed = 0
                            thePlayer.airborne = 0
                            nextY = y - thePlayer.height / 2
                        end
                    end
                end
            end
        end
    end
    
    
    --[[
    tileXCheck = tileX
    tileYCheck = tileY
    
    -- Check for collision based on xSpeed and ySpeed
    if thePlayer.ySpeed > 0 then
        tileYCheck = tileYCheck + 1
    end
    if thePlayer.ySpeed < 0 then
        tileYCheck = tileYCheck - 1 
    end
    if thePlayer.xSpeed < 0 then
        tileXCheck = tileXCheck - 1
    end
    if thePlayer.xSpeed > 0 then
        tileXCheck = tileXCheck + 1
    end
    
    px = nextX - thePlayer.width / 2
    py = nextY - thePlayer.height / 2
    pw = px + thePlayer.width
    ph = py + thePlayer.height    
    
    -- Vertical check
    if tileXCheck > 0 and tileXCheck <= 10 then
        -- Check the three left/right tiles
        for ctY = tileY - 1, tileY + 1 do
            if ctY > 0 and ctY <= 10 and table[tileXCheck][tileY] == 1 then
                x = (tileXCheck - 1) * tilesize
                y = (tileY - 1) * tilesize
                w = tilesize + x
                h = tilesize + y

                print(ctY)
                print(pw.." > "..x.." and "..pw.." < "..w.." and "..ph.." > "..y.." and "..ph.." < "..h)
                print(px.." > "..w.." and "..px.." < "..x.." and "..ph.." > "..y.." and "..ph.." < "..h)
                print(px.." > "..x.." and "..pw.." < "..w.." and "..ph.." > "..y.." and "..ph.." < "..h)
                print(px.." > "..x.." and "..pw.." < "..w.." and "..py.." > "..y.." and "..ph.." < "..h.."\n")

                if (pw > x and pw < w and ph > y and ph <= h + 1) or
                   (px < w and px > x and ph > y and ph <= h + 1) or 
                   (px > x and pw < w and ph > y and ph <= h + 1) or
                   (px > x and pw < w and py > y and ph <= h + 1) then
                    -- Collision?

                    if thePlayer.xSpeed > 0 then
                        nextX = x - thePlayer.width / 2
                    elseif thePlayer.xSpeed < 0 then
                        nextX = w + thePlayer.width / 2
                    else
                        nextX = thePlayer.x
                    end

                    thePlayer.xSpeed = 0
                end
            end
        end
    end
    
    -- Horizontal check
    if tileYCheck > 0 and tileYCheck <= 10 then
        -- Check the three bottom/upper tiles
        for ctX = tileX - 1, tileX + 1 do
            if ctX > 0 and ctX <= 10 and table[ctX][tileYCheck] == 1 then
                x = (ctX - 1) * tilesize
                y = (tileYCheck - 1) * tilesize
                w = tilesize + x
                h = tilesize + y

                --print(pw.." > "..x.." and "..pw.." < "..w.." and "..ph.." > "..y.." and "..ph.." < "..h)
                --print(px.." > "..w.." and "..px.." < "..x.." and "..ph.." > "..y.." and "..ph.." < "..h)
                --print(px.." > "..x.." and "..pw.." < "..w.." and "..ph.." > "..y.." and "..ph.." < "..h)
                --print(px.." > "..x.." and "..pw.." < "..w.." and "..py.." > "..y.." and "..ph.." < "..h)

                if (pw > x and pw < w and ph > y and ph < h) or
                   (px < w and px > x and ph > y and ph < h) or 
                   (px > x and pw < w and ph > y and ph < h) or
                   (px > x and pw < w and py > y and ph < h) then
                    -- Collision?
                    if thePlayer.ySpeed > 0 then
                        nextY = y - thePlayer.height / 2
                    else
                        nextY = h + thePlayer.height / 2
                    end

                    thePlayer.ySpeed = 0
                    thePlayer.airborne = 0
                    nextY = y - thePlayer.height / 2
                end
            end
        end
    end
    --]]
    
    thePlayer.x = nextX
    thePlayer.y = nextY
end
 
function love.draw()
    -- Draw the whole grid
    for i = 1, 10 do
        for j = 1, 10 do
            if table[i][j] == 1 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (i - 1) * tilesize, (j - 1) * tilesize, tilesize, tilesize)
            end
        end
    end
    
    -- Draw the player
    love.graphics.setColor(200 / 255, 100 / 255, 100 / 255)
    love.graphics.rectangle("fill", thePlayer.x - thePlayer.width / 2, thePlayer.y - thePlayer.height / 2, thePlayer.width, thePlayer.height)
    
    -- Which tile is the player currently in?
    tileX = math.floor(thePlayer.x / tilesize)
    tileY = math.floor(thePlayer.y / tilesize)
    
    love.graphics.setColor(1, 1, 1, 0.5)
    
    -- Draw the collision tiles around the player
    for i = -1, 1 do
        for j = -1, 1 do
            love.graphics.rectangle("line", (tileX + i) * tilesize, (tileY + j) * tilesize, tilesize, tilesize)
        end
    end   
end