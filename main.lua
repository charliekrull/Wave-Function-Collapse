require 'Dependencies'

tilesheet = love.graphics.newImage('LPC_overworld_assembly.png')
frames = GenerateQuads(tilesheet, TILE_SIZE, TILE_SIZE)
font = love.graphics.newFont('font.ttf', 8)

function love.load()
    math.randomseed(os.time())
    love.window.setTitle('Wave Function Collapse')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(font)

    --open up the window with our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
    {fullscreen = false,
    resizable = true,   
    vsync = true})

    inputMap = sti('inputMap.lua')

    snapshots = takeSnapshots(inputMap, 3, 3)
    

    cells = {}
    tiles = {}
    affectedCells = {}
    toCollapse = {}
    

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

    if love.keyboard.wasPressed('space') then
        
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
                                105, 106, 107, 2, 3, 28, 29
                                }}
            

            
        end
    end

    
    supportTable = calculateSupport()

    while not isSolved() do
        for k, tbl in pairs(toCollapse) do
            collapseCell(cells, tbl.x, tbl.y)

        end
        toCollapse = {}
    
        local minEntropyCells = getMinEntropyCells(cells)



        --pick a random cell from the minimum entropy cells and collapse it, ie set its domain to exactly one tile
        --choosing one tile at random from the possibilities, accounting for their weight
        local choice = table.randomChoice(minEntropyCells)
        if choice ~= nil then
            collapseCell(cells, choice['x'], choice['y'])
        else
            --print('choice is nil')
            --break
            
            
        end
    

       
        

    

    end


    

end

function isSolved() 
    for y = 1, WORLD_HEIGHT do
        for x = 1, WORLD_WIDTH do
            if not tiles[y][x] then
                return false
            end
            
        end
    end

    return true
   
end

function getMinEntropyCells(cells)
    --find the cells with the least entropy, which requires some math when using weights
    --put their x and y in a table
    local minEntropyCells = {}

    --baseline will be a high number so it is broken by the first cell
    local minEntropy = 999999
    for y, row in pairs(cells) do
        for x, cell in pairs(row) do
            local entropy = 0
            for k, opt in pairs(cell.options) do
                entropy = entropy + (WEIGHTS[opt] * math.log(WEIGHTS[opt]))
            end
            entropy = -entropy
            if entropy < minEntropy and #cells[y][x].options > 1 then
                minEntropyCells = {}
                table.insert(minEntropyCells, {['x'] = x, ['y'] = y})
                minEntropy = entropy

            elseif entropy == minEntropy and #cells[y][x].options > 1 then
                table.insert(minEntropyCells, {['x'] = x, ['y'] = y})
            
        
            
            end
        end
    end
    
    return minEntropyCells
end



function collapseCell(cells, x, y)
    cells[y][x].collapsed = true
    local removedOptions = {}

    local choice = getWeightedRandomTile(cells[y][x].options)
    for i = 1, #cells[y][x].options do
        local option = cells[y][x].options[i]
        if option ~= choice then
            updateSupport(x, y, option)
            table.insert(removedOptions, option)
        end
    
    end

    for k, opt in pairs(removedOptions) do
        table.remove(cells[y][x].options, table.find(cells[y][x].options, opt))
    end


    

    local t = Tile{x = x, y = y, texture = tilesheet, frame = choice}
    tiles[y][x] = t
    
    
    propogate(cells, x, y)
end

function propogate(cells, startingX, startingY) 
    table.insert(affectedCells, {x = startingX,  y = startingY})

    while #affectedCells > 0 do

        local currentCell = cells[affectedCells[1].y][affectedCells[1].x]
        

        for k, opt in pairs(getInvalidTiles(currentCell.x, currentCell.y)) do
            updateSupport(currentCell.x, currentCell.y, opt)
            table.remove(cells[currentCell.y][currentCell.x].options, table.find(cells[currentCell.y][currentCell.x].options, opt))
        end

        if cells[currentCell.y - 1] then
            
        
            for k, opt in pairs(getInvalidTiles(currentCell.x, currentCell.y-1)) do
                updateSupport(currentCell.x, currentCell.y-1, opt)
                table.remove(cells[currentCell.y-1][currentCell.x].options, table.find(cells[currentCell.y-1][currentCell.x].options, opt))
            end

        end

        if cells[currentCell.y][currentCell.x+1] then
            for k, opt in pairs(getInvalidTiles(currentCell.x+1, currentCell.y)) do
                updateSupport(currentCell.x+1, currentCell.y, opt)
                table.remove(cells[currentCell.y][currentCell.x+1].options, table.find(cells[currentCell.y][currentCell.x+1].options, opt))
            end
        end

        if cells[currentCell.y+1] then
            
        
            for k, opt in pairs(getInvalidTiles(currentCell.x, currentCell.y+1)) do
                updateSupport(currentCell.x, currentCell.y+1, opt)
                table.remove(cells[currentCell.y+1][currentCell.x].options, table.find(cells[currentCell.y+1][currentCell.x].options, opt))
            end
        end

        if cells[currentCell.y][currentCell.x-1] then
            for k, opt in pairs(getInvalidTiles(currentCell.x-1, currentCell.y)) do
                updateSupport(currentCell.x-1, currentCell.y, opt)
                table.remove(cells[currentCell.y][currentCell.x-1].options, table.find(cells[currentCell.y][currentCell.x-1].options, opt))
            end
        end

        if #cells[currentCell.y][currentCell.x].options == 1 then
            if not cells[currentCell.y][currentCell.x].collapsed then
                table.insert(toCollapse, {x = currentCell.x, y = currentCell.y})
            end
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


function getInvalidTiles(x, y) 
    local toRemove = {}
    
    for k, opt in pairs(cells[y][x].options) do
        if supportTable[y][x][opt]['north'] == 0 or supportTable[y][x][opt]['east'] == 0 or
            supportTable[y][x][opt]['south'] == 0 or supportTable[y][x][opt]['west'] == 0 then
                
            table.insert(toRemove, opt)
        end
    end
    

    
    if #toRemove > 0 then
        table.insert(affectedCells, {x = x, y = y})
    end

    --return invalid options in a table
    return toRemove
    
end

function updateSupport(x, y, optionRemoved) 
    --look north for a cell, if there is one, loop through its options
    --check if each one matches the tile just removed, if so update the OPPOSITE
    --direction in the supportTable entry for the neighboring cell'
    if cells[y-1] then
        for k, opt in pairs(cells[y-1][x].options) do
            if isValid(optionRemoved, opt, 'north') then
                supportTable[y-1][x][opt]['south'] = supportTable[y-1][x][opt]['south'] - 1
            end
        end
    end

    --east
    if cells[y][x+1] then
        for k, opt in pairs(cells[y][x + 1].options) do
            if isValid(optionRemoved, opt, 'east') then
                supportTable[y][x+1][opt]['west'] = supportTable[y][x+1][opt]['west'] - 1
            end
        end
    end

    --south
    if cells[y+1] then
        for k, opt in pairs(cells[y+1][x].options) do
            if isValid(optionRemoved, opt, 'south') then
                supportTable[y+1][x][opt]['north'] = supportTable[y+1][x][opt]['north'] - 1
            end
        end
    end

    --west
    if cells[y][x-1] then
        for k, opt in pairs(cells[y][x-1].options) do
            if isValid(optionRemoved, opt, 'west') then
                supportTable[y][x-1][opt]['east'] = supportTable[y][x-1][opt]['east'] - 1
            end
        end
    end
end


function calculateSupport()
    local returnedTable = {}
    for y, row in pairs(cells) do
        returnedTable[y] = {}
        for x, cell in pairs(row) do
            returnedTable[y][x] = {}
            
            for k, opt in pairs(cell.options) do
                returnedTable[y][x][opt] = {}

                --look north
                local supportCounter = 0
                if cells[cell.y-1] then
                    for l, opt2 in pairs(cells[cell.y - 1][cell.x].options) do
                        if isValid(opt, opt2, 'north') then
                            supportCounter = supportCounter + 1
                        end
                    end
                else
                    supportCounter = 1
                end

                
                returnedTable[y][x][opt]['north'] = supportCounter

                supportCounter = 0

                --look east
                if cells[cell.y][cell.x + 1] then
                    for l, opt3 in pairs(cells[cell.y][cell.x+1].options) do
                        if isValid(opt, opt3, 'east') then
                            supportCounter = supportCounter + 1
                            
                        end
                    end
                else
                    supportCounter = 1
                end

                returnedTable[y][x][opt]['east'] = supportCounter

                supportCounter = 0

                --look south
                if cells[cell.y+1] then
                    for l, opt4 in pairs(cells[cell.y + 1][cell.x].options) do
                        if isValid(opt, opt4, 'south') then
                            supportCounter = supportCounter + 1
                        end
                    end
                else
                    supportCounter = 1
                end
                
                returnedTable[y][x][opt]['south'] = supportCounter

                supportCounter = 0

                --look west
                if cells[cell.y][cell.x-1] then
                    for l, opt5 in pairs(cells[y][x-1].options) do
                        if isValid(opt, opt5, 'west') then
                            supportCounter = supportCounter + 1

                        end
                    end
                else
                    supportCounter = 1
                end
                
                returnedTable[y][x][opt]['west'] = supportCounter
                
            end


        end
    end
    return returnedTable
end

function sumOfWeights(options) -- used to determine our upper bound for the random number used to get a tile
    local sum = 0
    for k, opt in pairs(options) do
        sum = sum + WEIGHTS[opt]
    end

    return sum
end

function getWeightedRandomTile(options)
    local r = math.random(sumOfWeights(options))
    for k, opt in pairs(options) do
        r = r - WEIGHTS[opt]
        if r <= 0 then
            return opt
        end
    end
end


function takeSnapshots(tilemap, width, height)
    local snapshots = {}
    local returnedSnapshots = {}
    local data = tilemap.layers['Tile Layer 1'].data
    
    

    for y, row in pairs(data) do
        for x, tile in pairs(row) do
            local snapshot = {}
            for snapy = 0, height - 1 do
                for snapx = 0, width - 1 do
                    table.insert(snapshot, data[((y + snapy-1) % tilemap.height)+1][((x + snapx-1) % tilemap.width)+1].gid)
                end
            end
           
            
            table.insert(snapshots, snapshot)
        end
    end
    
    --count up the frequency of each snapshot
    for k, shot in pairs(snapshots) do
        
        if #returnedSnapshots == 0 then
            table.insert(returnedSnapshots, {contents = shot, frequency = 1})

        else
            local matchFound = false
            for l, comparisonShot in pairs(returnedSnapshots) do

                if tablesMatch(shot, comparisonShot.contents) then
                    comparisonShot.frequency = comparisonShot.frequency + 1
                    matchFound = true
                end
            end

            if not matchFound then
                table.insert(returnedSnapshots, {contents = shot, frequency = 1})
            end

            
        end
        
    end
    return returnedSnapshots
end