Tile = Class{}

function Tile:init(def)
    self.x = def.x
    self.y = def.y

    self.texture = def.texture
    self.frame = def.frame
end

--probably only used in case of animated tiles
function Tile:update(dt)

end

function Tile:render()
    love.graphics.draw(self.texture, frames[self.frame], (self.x - 1) * TILE_SIZE, (self.y - 1) * TILE_SIZE)
end