require 'Dependencies'

--useful coonstants
VIRTUAL_WIDTH = 500
VIRTUAL_HEIGHT = 282
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
TILE_SIZE = 16
WORLD_WIDTH = 4 -- tiles
WORLD_HEIGHT = 4 -- tiles

tilesheet = love.graphics.newImage('LPC_overworld_assembly.png')

function love.load()
    --open up the window with our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
    {fullscreen = false,
    resizable = true,   
    vsync = true})

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

end

function love.draw()
    --push is used to render at a virtual resolution
    push:apply('start')

    push:apply('end')
end