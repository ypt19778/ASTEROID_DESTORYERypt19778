function setBorder()
    
    local w, h = love.graphics.getDimensions()
    border = {}
    border.tag = 'BORDER'
    border.physics = {bodies = {}, shapes = {}, fixtures = {}}
    border.physics.map = {
        --top
        {0, 0, w, 1},
        --bottom
        {0, h, w, 1},
        --left
        {0, 0, 1, h},
        --right
        {w, 0, 1, h}
    }
    for i = 1, #border.physics.map do
        local x, y, width, height = unpack(border.physics.map[i])
        love.graphics.rectangle('line', x, y, width, height)
        border.physics.bodies[i] = love.physics.newBody(world, x, y, 'static')
        border.physics.shapes[i] = love.physics.newRectangleShape(width / 2, height / 2, width, height)
        border.physics.fixtures[i] = love.physics.newFixture(border.physics.bodies[i], border.physics.shapes[i])
        border.physics.fixtures[i]:setRestitution(15)
        border.physics.fixtures[i]:setUserData(border)
    end
end

function love.load()
    window_width, window_height = love.graphics.getDimensions()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    world = love.physics.newWorld(0, 0, true)
    
    --_G.collisionTable = {}
    _G.collisionData = ""
    onCollisionEnter = function (a, b) 
        local o1, o2 = a:getUserData(), b:getUserData()

        if o1 and o2 then
            _G.collisionData = o1.tag.."collide"..o2.tag
            --table.insert(_G.collisionTable, {o1, o2})
        end
    end
    onCollisionExit = function (a, b)
        _G.collisionData = ""
        
        --terates through the collision table
        --[[
        for i = 1, #_G.collisionTable do
            if _G.collisionTable[i] == {a, b} or _G.collisionTable[i] == {b, a} then
                table.remove(_G.collisionData, i)
            end
        end
        ]]
    end
    
    world:setCallbacks(onCollisionEnter, onCollisionExit)

    Audio = require('audio')
    Spaceship = require('spaceship')
    Asteroid = require('asteroids')

    Audio:init()

    game = {scale = 2, score = 0, font = love.graphics.newFont('graphics/fonts/PressStart2P-Regular.ttf')}

    spaceship = Spaceship.new(world)    
    
    Asteroids_startSpawn(4)

    love.graphics.print('loading...', 400, 300, nil, 3)
end 

function love.update(dt)
    world:update(dt)
    spaceship:update(dt)
    Asteroid:update(dt)
end

function love.draw()
    --setBorder()
    love.graphics.print(_G.collisionData, 10, 10)
    love.graphics.print(game.score, game.font, 400, 10)
    spaceship:draw()
    Asteroid:draw()
end

function love.keypressed(k)
    if k == 'escape' then love.event.quit() end
    spaceship:checkKeypress(k)
end 