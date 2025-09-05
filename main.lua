function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    world = love.physics.newWorld(0, 0, true)
    
    _G.collisionData = ""
    onCollisionEnter = function (a, b) 
        local o1, o2 = a:getUserData(), b:getUserData()

        if o1 and o2 then
            _G.collisionData = o1.tag.."collide"..o2.tag
        end
    end
    onCollisionExit = function (a, b)
        _G.collisionData = ""
    end
    
    world:setCallbacks(onCollisionEnter, onCollisionExit)

    Audio = require('audio')
    Spaceship = require('spaceship')
    Asteroid = require('asteroids')

    Audio:init()

    game = {scale = 2, score = 0}

    spaceship = Spaceship.new(world)    
    
    Asteroids_startSpawn(4)
end 

function love.update(dt)
    world:update(dt)
    spaceship:update(dt)
    Asteroid:update(dt)
end

function love.draw()
    love.graphics.print(_G.collisionData, 10, 10)

    local font = love.graphics.newFont(35)
    love.graphics.print(game.score, font, 400, 10)
    spaceship:draw()
    Asteroid:draw()
end

function love.keypressed(k)
    if k == 'escape' then love.event.quit() end
    spaceship:checkKeypress(k)
end 