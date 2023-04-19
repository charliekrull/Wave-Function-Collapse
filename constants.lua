--useful coonstants

WINDOW_WIDTH = 768
WINDOW_HEIGHT = 768
TILE_SIZE = 16
WORLD_WIDTH = 30 -- tiles
WORLD_HEIGHT = 30 -- tiles
VIRTUAL_WIDTH = WORLD_WIDTH * TILE_SIZE
VIRTUAL_HEIGHT = WORLD_HEIGHT * TILE_SIZE

WATER = 626

SOCKETS = {[WATER] = {['north'] = 0, --2 bits, first bit is left or top half, second is right or bottom half
                    ['east'] = 0,    --0 is water, 1 is land, so 3 is all land, 2 is land on the left or in the top, depending on which side we're checking
                    ['south'] = 0,
                    ['west'] = 0
                    },
    [53] = {['north']= 0,
            ['east'] = 1,
            ['south'] = 1,
            ['west'] = 0},

    [54] = {['north'] = 0,
            ['east'] = 1,
            ['south'] = 3,
            ['west'] = 1},

    [55] = {['north'] = 0,
            ['east'] = 0,
            ['south'] = 2,
            ['west'] = 1},

    [79] = {['north'] = 1,
            ['east'] = 3,
            ['south'] = 1,
            ['west'] = 0},
            
    [80] = {['north'] = 3,
            ['east'] = 3,
            ['south'] = 3,
            ['west'] = 3},

    [81] = {['north'] = 2,
            ['east'] = 0,
            ['south'] = 2,
            ['west'] = 3},

    [105] = {['north'] = 1,
            ['east'] = 2,
            ['south'] = 0,
            ['west'] = 0},

    [106] = {['north'] = 3,
            ['east'] = 2,
            ['south'] = 0,
            ['west'] = 2},

    [107] = {['north'] = 2,
            ['east'] = 0,
            ['south'] = 0,
            ['west'] = 2},

    --inside corners
    [2] = {['north'] = 3,
        ['east'] = 2,
        ['south'] = 2,
        ['west'] = 3},
        
    [3] = {['north'] = 3,
        ['east'] = 3,
        ['south'] = 1,
        ['west'] = 2},

    [28] = {['north'] = 2,
        ['east'] = 1,
        ['south'] = 3,
        ['west'] = 3},

    [29] = {['north'] = 1,
        ['east'] = 3,
        ['south'] = 3,
        ['west'] = 1}
}


--how likely a tile is to be chosen, higher weights are more likely
WEIGHTS = {  [WATER] = 30, 
        [53] = 1,
        [54] = 1, 
        [55] = 1,
        [79] = 1,
        [80] = 10,
        [81] = 1,
        [105] = 1,
        [106] = 1,
        [107] = 1,
        [2] = 1,
        [3] = 1,
        [28] = 1,
        [29] = 1


}