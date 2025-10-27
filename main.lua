math.randomseed(os.clock())
love.graphics.setDefaultFilter('nearest', 'nearest')
game = {
    saveDirectoryFile = "score_save_data.txt",

    scale = 2, 
    state = 'menu', 
    score = 0, 
    font = love.graphics.newFont('graphics/fonts/PressStart2P-Regular.ttf'),
}
game.serialize = function (o)
    local tab = "     "
    if type(o) == "table" then
        love.filesystem.write(game.saveDirectoryFile, "{\n")
        for k, v in pairs(o) do
            love.filesystem.append(tab..k.." = ")
            game.serialize(v)
            love.filesystem.append(game.saveDirectoryFile, ",\n")
        end
        love.filesystem.append("}\n")
    end
    print('serailized highscore data')
end

game.deserialize = function (o)
    
end
game.highscores = {first = {score = 10, name = "love2d"}}
for outk, outv in pairs(game.highscores) do
    print("key="..outk..", value="..type(outv))
    for ink, inv in pairs(outv) do
        print("key="..ink..", value="..inv)
    end
end

window_width, window_height = love.graphics.getDimensions()

world = love.physics.newWorld(0, 0, true)

_G.collisionTable = {}
_G.collisionData = ""
onCollisionEnter = function (a, b) 
    local o1, o2 = a:getUserData(), b:getUserData()

    if o1 and o2 then
        o1.type = string.lower(o1.tag:gsub("%d", ""))
        o2.type = string.lower(o2.tag:gsub("%d", ""))
        if o1.type == "asteroid" and o2.type == "asteroid" then return end
        _G.collisionData = o1.tag.."collide"..o2.tag
        table.insert(_G.collisionTable, {collisionData = o1.tag, o2.tag})
    end
end
onCollisionExit = function (a, b)
    _G.collisionData = ""
    
    --terates through the collision table
    for i = 1, #_G.collisionTable do
        if _G.collisionTable[i] == {a, b} or _G.collisionTable[i] == {b, a} then
            table.remove(_G.collisionData, i)
        end
    end
end
world:setCallbacks(onCollisionEnter, onCollisionExit)

-- global functions
checkOverlap = function (a, b)
    return a.x < b.x + b.width and
    b.x < a.x + a.width and 
    a.y < b.y + b.height and
    b.y < a.y + a.height
end

getDistance = function (...)
    local x1, y1, x2, y2 = unpack(...)
    return math.floor(math.sqrt((x2 - x1)^2 + (y2 - y1)^2))
end

-- requires & inits
Audio = require('audio')
Audio:init()
Menu = require('menus')
require('powerups')
require('levels')    
menu = Menu.new()
Spaceship = require('spaceship')
spaceship = Spaceship.new(world)
Asteroid = require('asteroids')

function love.load()
    table.sort(game.highscores, function(a, b)
        return a.score > b.score
    end)

    math.randomseed(os.clock())

    game.highscore = love.filesystem.read(game.saveDirectoryFile)

    Powerups.rolled = false
    Powerups.cards = {}
    Level.oneEvent = 1
    Powerups.menu.done = false
    spaceship.mark = 'alive'
    spaceship.physics.body:setPosition(window_width / 2, window_height / 2)
    spaceship.iFrames = 200
    for asteroid_index, asteroid in ipairs(Asteroids) do
        if asteroid.mark == 'alive' then
            asteroid.physics.fixture:destroy()
        end
        asteriod = nil
    end
    if game.state == "menu" then
        print('reset "cave" progress.')
        Level.level = 1
        Level.difficulty = 1
        spaceship.physics.fixture:destroy()
        spaceship:kill(1)
        spaceship = Spaceship.new(world)
        Powerups:setSpaceship(spaceship)
    end
    Asteroids = {}
    start_asteroids = 5 * Level.difficulty
    for i = 1, start_asteroids do
        game_asteroid = Asteroid.new(world, math.random(2, 3), i)
    end

    -- + global mouse table & pos
    mouse = {x = love.mouse.getX(), y = love.mouse.getY(), width = 1, height = 1}
end 

function instaLv()
    game.state = 'loading level'
end

function love.update(dt)
    mouse.x, mouse.y = love.mouse.getPosition()
    world:update(dt)
    if love.keyboard.isDown('escape') and love.keyboard.isDown('1') then
        love.event.quit()
    end
    if game.state == 'menu' then
        audio.menutheme:play()
        Asteroid:update(dt)
        menu:update()
    elseif game.state == 'running' then
        if love.keyboard.isDown('lshift') and love.keyboard.isDown('e') then
            instaLv()
        end
        audio.sounds.explode:setPitch(math.random(3))
        Asteroid:update(dt)
        spaceship:update(dt)
        if #Asteroids == 0 then
            game.state = 'loading level'
        end
    elseif game.state == 'loading level' then
        Level:update()
    end
end

function love.textinput(text)
    if game.state == 'running' and spaceship.mark == 'dead' then
        spaceship:getNamingInput(text)
    end
end

function love.draw()
    --[[
    local bodies = world:getBodies()
    for _, body in ipairs(bodies) do
        local fixtures = body:getFixtures()
        for _, fixture in ipairs(fixtures) do
            if fixture:getShape():type() == 'PolygonShape' then
                love.graphics.polygon('line', body:getWorldPoints(fixture:getShape():getPoints()))
            elseif fixture:getShape():type() == 'EdgeShape' or fixture:getShape():type() == 'ChainShape' then
                local points = {body:getWorldPoints(fixture:getShape():getPoints())}
                for i = 1, #points, 2 do
                    if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
                end
            elseif fixture:getShape():type() == 'CircleShape' then
                local body_x, body_y = body:getPosition()
                local shape_x, shape_y = fixture:getShape():getPoint()
                local r = fixture:getShape():getRadius()
                love.graphics.circle('line', body_x + shape_x, body_y + shape_y, r, 360)
            end
        end
    end
    ]]
    if game.state == 'menu' then
        Asteroid:draw()
        menu:draw()
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