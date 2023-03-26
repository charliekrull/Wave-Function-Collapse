--useful coonstants

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
TILE_SIZE = 16
WORLD_WIDTH = 10 -- tiles
WORLD_HEIGHT = 10 -- tiles
VIRTUAL_WIDTH = TILE_SIZE * WORLD_WIDTH
VIRTUAL_HEIGHT = TILE_SIZE * WORLD_HEIGHT

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
            ['west'] = 2}
}