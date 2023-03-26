require 'Dependencies'

tilesheet = love.graphics.newImage('LPC_overworld_assembly.png')
frames = GenerateQuads(tilesheet, TILE_SIZE, TILE_SIZE)
font = love.graphics.newFont('font.ttf', 8)

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(font)

    --open up the window with our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
    {fullscreen = false,
    resizable = true,   
    vsync = true})
    
    cells = {}
    tiles = {}
    affectedCells = {}
    generateMap()


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

    -- love.graphics.setLineWidth(1)
    -- for i = 0, VIRTUAL_HEIGHT, TILE_SIZE do
    --     love.graphics.setColor(1, 1, 1, 1)
    --     love.graphics.line(0, i, VIRTUAL_WIDTH, i)
    -- end

    -- for i = 0, VIRTUAL_WIDTH, TILE_SIZE do
    --     love.graphics.setColor(1, 1, 1, 1)
    --     love.graphics.line(i, 0, i, VIRTUAL_HEIGHT)
    -- end

    -- for y, row in pairs(cells) do
    --     for x, cell in pairs(row) do
    --         love.graphics.print(#cell.options, (cell.x - 1) * TILE_SIZE + TILE_SIZE / 2,
    --         (cell.y - 1) * TILE_SIZE + TILE_SIZE / 3)
    
    --     end
    -- end
    push:apply('end')
end

function generateMap()
    for y = 1, WORLD_HEIGHT do
        cells[y] = {}
        tiles[y] = {}
        for x = 1, WORLD_WIDTH do
            --every cell starts with every possibility
            cells[y][x] = {x = x, y = y, collapsed = false, 
            options = {WATER, 53, 54, 55,
                                79, 80, 81,
                                105, 106, 107}}
            

            
        end
    end
    
    while not isSolved() do
        local minEntropyCells = getMinEntropyCells(cells)

            

        --pick a random cell from the minimum cells and collapse it, ie set its domain to exactly one tile
        --choosing one tile at random from the possibilities
        local choice = table.randomChoice(minEntropyCells)
        collapseCell(cells, choice.x, choice.y)

    end

    

end

function isSolved() 
    for y = 1, WORLD_HEIGHT do
        if not tiles[y] then
            return false
        else

            for x = 1, WORLD_WIDTH do
                if not tiles[y][x] then
                    return false
                end
            end
        end
    end

    return true
   
end

function getMinEntropyCells(cells)
    --find the cells with the least entropy (possibilities), here represented by #cells[y][x]
    --put their x and y in a table
    local minEntropyCells = {}

    --baseline will be the first cell's entropy
    local minEntropy = #cells[1][1]
    for y, row in pairs(cells) do
        for x, cell in pairs(row) do
            if #cell < minEntropy then
                minEntropyCells = {}
                table.insert{minEntropyCells, {['x'] = x, ['y'] = y}}

            elseif #cell == minEntropy then
                table.insert(minEntropyCells, {['x'] = x, ['y'] = y})

                               
            
            end
        end
    end

    return minEntropyCells
end

function collapseCell(cells, x, y)
    cells[y][x].collapsed = true
    cells[y][x].options = {table.randomChoice(cells[y][x].options)}
    
    

    local t = Tile{x = x, y = y, texture = tilesheet, frame = cells[y][x].options[1]}
    tiles[y][x] = t
    --print(x, y, tiles[y][x].frame)
    if cells[y-1] then
        removeInvalidTiles(cells[y][x], cells[y - 1][x]) --north
        --print_r(cells[y-1][x])
    end

    if cells[y][x+1] then
        removeInvalidTiles(cells[y][x], cells[y][x + 1]) -- east
        --print_r(cells[y][x+1])
    end
    if cells[y+1] then
        removeInvalidTiles(cells[y][x], cells[y+1][x]) -- south
        --print_r(cells[y+1][x])
    end

    if cells[y][x-1] then
        removeInvalidTiles(cells[y][x], cells[y][x-1])--west
        --print_r(cells[y][x-1])
    end
    
    propogate(cells, x, y)
end

function propogate(cells, startingX, startingY) 
    table.insert(affectedCells, {x = startingX,  y = startingY})

    while #affectedCells > 0 do

        local currentCell = cells[affectedCells[1].y][affectedCells[1].x]
        --print(currentCell.x, currentCell.y)
        if cells[currentCell.y - 1] then
            removeInvalidTiles(currentCell, cells[currentCell.y-1][currentCell.x])
        end

        if cells[currentCell.y][currentCell.x + 1] then
            removeInvalidTiles(currentCell, cells[currentCell.y][currentCell.x+1])
        end

        if cells[currentCell.y+1] then
            removeInvalidTiles(currentCell, cells[currentCell.y+1][currentCell.x])
        end

        if cells[currentCell.y][currentCell.x-1] then
            removeInvalidTiles(currentCell, cells[currentCell.y][currentCell.x-1])
        end
        table.remove(affectedCells, 1)
    end

   
    
    
end

function isValid(option1, option2, direction) --direction is the direction from option 1 to option 2
   
    if direction == 'north' then
        return SOCKETS[option1]['north'] == SOCKETS[option2]['south']
        
    elseif direction == 'east' then
        return SOCKETS[option1]['east'] == SOCKETS[option2]['west']
        
    elseif direction == 'south' then
        return SOCKETS[option1]['south'] == SOCKETS[option2]['north']

    elseif direction == 'west' then

        return SOCKETS[option1]['west'] == SOCKETS[option2]['east']
        
    
    end


end

function removeInvalidTiles(originCell, checkCell)
    local toRemove = {}
    local direction = ''

    if checkCell.y < originCell.y then
        direction = 'north'

    elseif checkCell.x > originCell.x then
        direction = 'east'
        
    elseif checkCell.y > originCell.y then
        direction = 'south'
        
    elseif checkCell.x < originCell.x then
        direction = 'west'
    
    end

    for i = 1, #checkCell.options do
        local matchFound = false
        for j = 1, #originCell.options do
            if isValid(originCell.options[j], checkCell.options[i], direction) then
                matchFound = true
            end
        end

        if not matchFound then
            table.insert(toRemove, checkCell.options[i])
        end
        matchFound = false
    end

    if #toRemove > 0 then
        table.insert(affectedCells, {x = checkCell.x, y = checkCell.y})
    end

    --remove cells
    while #toRemove > 0 do
        table.remove(checkCell.options, table.find(checkCell.options, toRemove[1]))
        table.remove(toRemove, 1)
    end
end