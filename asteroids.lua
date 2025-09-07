Asteroids = {}

local Asteroid = {}
Asteroid.__index = Asteroid

function Asteroids_startSpawn(max)
    for i = 1, max do
        local area = #Asteroids + 1
        local vmax = 50
        local inward = 100
        local map = {
            --top
            {window_width / 2, 0 + inward},
            --bottom
            {window_height - inward, window_width / 2},
            --left
            {0 + inward, window_height / 2},
            --right
            {window_width - inward, window_height / 2}
        }
        local angle = {{vmax, math.random(vmax)}, {math.random(vmax), vmax}, {-vmax, -math.random(vmax)}, {-math.random(vmax), -vmax}}
        local x, y = unpack(map[area])
        local vx, vy = unpack(angle[area])
        local tag = #Asteroids + 1
        Asteroid.new(world, tag)
    end
end

function Asteroid.new(world, tag)
    local instance = setmetatable({}, Asteroid)
    instance.tag = "ASTEROID"..tag
    local vmax = 40
    --local map = {{0, window_height / 2}, {window_width / 2, 0}, {window_width , window_height / 2}, {window_width / 2, window_height}}
    --local angle = {{vmax, math.random(vmax)}, {math.random(vmax), vmax}, {-vmax, -math.random(vmax)}m(vmax), -vmax}}, {-math.rando
    local inward = 100
    local map = {
    --top
        {window_width / 2, 0 + inward},
    --bottom
        {window_height - inward, window_width / 2},
    --left
        {0 + inward, window_height / 2},
    --right
        {window_width - inward, window_height / 2}
    }
    local angle = {{vmax, math.random(vmax)}, {math.random(vmax), vmax}, {-vmax, -math.random(vmax)}, {-math.random(vmax), -vmax}}

    instance.x, instance.y = map[tag][1], map[tag][2]
    
    instance.sprites = {
        {
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_small_1.png'),
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_small_2.png'),
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_small_3.png')
        },
        {
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_med_1.png'),
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_med_2.png'),
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_med_3.png')
        },
        {
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_large_1.png'),
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_large_2.png'),
            love.graphics.newImage('graphics/sprites/asteroids/asteroid_large_3.png')
        }
    }

    local size = math.random(3)
    instance.size = size
    instance.radius = 10 * instance.size
    instance.sprite = instance.sprites[instance.size][math.random(3)]
    instance.angle = math.random(360)

    local pSystem_image = love.graphics.newImage('graphics/sprites/asteroids/asteroid_particle.png')
    instance.pSystem = love.graphics.newParticleSystem(pSystem_image)
    instance.pSystem:setSizes(1)
    instance.pSystem:setLinearAcceleration(-900, -900, 900, 900)
    instance.pSystem:setParticleLifetime(1, 2)
    instance.pSystem:setSpread(math.pi)

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'dynamic')
    --instance.physics.body:setFixedRotation(true)
    instance.physics.shape = love.physics.newCircleShape(instance.radius)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData(instance)
    instance.physics.fixture:setRestitution(0.2 * size)

    instance.velAngle = angle[tag]

    instance.mark = "alive"
    table.insert(Asteroids, instance)
    return instance
end

function Asteroid:update(dt)
    audio.asteroid.explode:setPitch(math.random(0.9, 1.1))
    for index, asteroid in ipairs(Asteroids) do
        asteroid.pSystem:update(dt)
        asteroid.x, asteroid.y = asteroid.physics.body:getPosition()
        asteroid.angle = asteroid.physics.body:getAngle()
        local velocity = asteroid.physics.body:getLinearVelocity()

        -- Determine which wall was hit based on asteroid position and reflect velocity appropriately
        local window_width, window_height = love.graphics.getDimensions()
        
        -- Check if asteroid hit top or bottom wall (reflect Y velocity)
        if asteroid.y <= asteroid.radius then
            asteroid.velAngle[2] = math.abs(asteroid.velAngle[2])
        end
        
        -- Check if asteroid hit top or bottom wall (reflect Y velocity)
        if asteroid.y >= window_height - asteroid.radius then
            asteroid.velAngle[2] = -math.abs(asteroid.velAngle[2])
        end
        
        -- Check if asteroid hit left or right wall (reflect X velocity)
        if asteroid.x <= asteroid.radius then
            asteroid.velAngle[1] = math.abs(asteroid.velAngle[1])
        end

        -- Check if asteroid hit left or right wall (reflect X velocity)
        if asteroid.x >= window_width - asteroid.radius then
            asteroid.velAngle[1] = -math.abs(asteroid.velAngle[1])
        end
        --if velocity < 12 then
            --asteroid.physics.body:applyForce(asteroid.velAngle[1], asteroid.velAngle[2])
            asteroid.physics.body:setLinearVelocity(asteroid.velAngle[1], asteroid.velAngle[2])
        --end

        if asteroid.mark == "dead" and asteroid.pSystem:getCount() == 0 then
            asteroid:destroy(index)
        end
    end
end

function Asteroid:draw()
    for index, asteroid in ipairs(Asteroids) do
        love.graphics.print(asteroid.pSystem:getCount(), 100, 100)
        love.graphics.print(asteroid.tag, asteroid.x, asteroid.y - 10)

        if asteroid.mark == "alive" then
            -- make 5 - 10 polygon shapes each size can use 
            -- make this choose a random number to see which polygon it uses
            love.graphics.draw(asteroid.sprite, asteroid.x, asteroid.y, asteroid.angle, game.scale, nil, asteroid.sprite:getWidth() / 2, asteroid.sprite:getHeight() / 2)
        end
        love.graphics.draw(asteroid.pSystem, asteroid.x, asteroid.y, nil, game.scale)

        love.graphics.setColor(0, 1, 0)
        love.graphics.circle('line', asteroid.x, asteroid.y, asteroid.physics.shape:getRadius())
        love.graphics.setColor(1, 1, 1)

        for index_projectile, projectile in ipairs(spaceship.projectiles) do
            if _G.collisionData == asteroid.tag.."collide"..projectile.tag or _G.collisionData == projectile.tag.."collide"..asteroid.tag then
                asteroid.mark = "dead"
                spaceship:destroyProjectile(index_projectile)
                asteroid.physics.body:setLinearDamping(999)
                if asteroid.physics.fixture then
                    asteroid.physics.fixture:destroy()
                end
                game.score = game.score + asteroid.size * 10
                asteroid.pSystem:emit(10 * asteroid.size)

                audio.asteroid.explode:stop()
                audio.asteroid.explode:play()
            end
        end
    end
end

function Asteroid:destroy(index)
    for numstr in Asteroids[index].tag:gmatch('%d') do
        local num = tonumber(numstr)
        if num ~= nil then
            tag = num
        end
    end
    table.remove(Asteroids, index)
    Asteroid.new(world, tag)
end

return Asteroid