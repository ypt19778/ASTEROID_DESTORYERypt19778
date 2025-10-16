math.randomseed(os.clock())
love.graphics.setDefaultFilter('nearest', 'nearest')
game = {scale = 2, state = 'menu', score = 0, font = love.graphics.newFont('graphics/fonts/3270-Regular.ttf')}
window_width, window_height = love.graphics.getDimensions()

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

-- global functions
checkOverlap = function(a, b)
    return a.x < b.x + b.width and
    b.x < a.x + a.width and 
    a.y < b.y + b.height and
    b.y < a.y + a.height
end

-- requires & inits
Audio = require('audio')
Audio:init()
Menu = require('menus')
require('levels')    
menu = Menu.new()
Spaceship = require('spaceship')
Asteroid = require('asteroids')
require('powerups')

function love.load()
    math.randomseed(os.clock())
    Powerups.menu.done = false
    spaceship = Spaceship.new(world)
    Powerups:setSpaceship(spaceship)
    start_asteroids = 10
    for _, asteroid in ipairs(Asteroids) do
        asteroid.physics.fixture:destroy()
    end
    for i = 1, start_asteroids do
        game_asteroid = Asteroid.new(world, math.random(2, 3), i)
    end

    -- + global mouse table & pos
    mouse = {x = love.mouse.getX(), y = love.mouse.getY(), width = 1, height = 1}
end 

function love.update(dt)
    -- fix the 
    mouse.x, mouse.y = love.mouse.getPosition()
    if game.state == 'menu' then
        menu:update()
        --Asteroid:update(dt)
    elseif game.state == 'running' then
        audio.sounds.explode:setPitch(math.random(3))
        world:update(dt)
        Asteroid:update(dt)
        spaceship:update(dt)
        if #Asteroids == 0 then
            game.state = 'loading level'
        end
    elseif game.state == 'loading level' then
        Level:update()
    end
end

function love.draw()
    if game.state == 'menu' then
        menu:draw()
        --Asteroid:draw()
    elseif game.state == 'running' then
        love.graphics.print(_G.collisionData, 10, 10)
        Asteroid:draw()
        spaceship:draw()
        love.graphics.print("SCORE: "..game.score..",  LEVEL:"..Level.level, game.font, window_width / 2, 10, nil, 1.1)
    elseif game.state == 'loading level' then
        Level:draw()
    end
end

function love.keypressed(k)
    if k == 'escape' then 
        love.event.quit() 
        print('manual quit...')
    end
    if game.state == 'running' then
        spaceship:checkKeypress(k)
    end
end 

function love.mousepressed(x, y, MB)
    if game.state == 'menu' then
        menu:checkMousepress(MB)
    elseif game.state == 'loading level' then
        Powerups:checkMousepress(x, y, MB)
    end
end