require 'Dependencies'

--useful coonstants
VIRTUAL_WIDTH = 500
VIRTUAL_HEIGHT = 282
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
TILE_SIZE = 16
WORLD_WIDTH = 4 -- tiles
WORLD_HEIGHT = 4 -- tiles

WATER = 626

tilesheet = love.graphics.newImage('LPC_overworld_assembly.png')
frames = GenerateQuads(tilesheet, TILE_SIZE, TILE_SIZE)

function love.load()
    --open up the window with our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
    {fullscreen = false,
    resizable = true,   
    vsync = true})
    tiles = {}
    for y = 1, WORLD_HEIGHT do
        tiles[y] = {}
        for x = 1, WORLD_WIDTH do
            tiles[y][x] = Tile{x = x, y = y,
                texture = tilesheet, frame = WATER}
        
        end
    end


    love.keyboard.keysPressed = {}
    love.mouse.clicks = {}
end

function love.resize(w, h)
    push:resize(w, h)
end


function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mousepressed(x, y, button)
    table.insert(love.mouse.clicks, {x = x, y = y, button = button})
end

function love.mouse.wasClicked(button)
    for _, tbl in pairs(love.mouse.clicks) do
        if tbl.button == button then
            return true
        end
    end

    return false
end

function love.update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    



    love.keyboard.keysPressed = {}
    love.mouse.clicks = {}
end

function love.draw()
    --push is used to render at a virtual resolution
    push:apply('start')

    for y, row in pairs(tiles) do
        for x, tile in pairs(row) do
            tile:render()
        end
    end

    love.graphics.setLineWidth(1)
    for i = 0, VIRTUAL_HEIGHT, TILE_SIZE do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.line(0, i, VIRTUAL_WIDTH, i)
    end

    for i = 0, VIRTUAL_WIDTH, TILE_SIZE do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.line(i, 0, i, VIRTUAL_HEIGHT)
    end
    push:apply('end')
end