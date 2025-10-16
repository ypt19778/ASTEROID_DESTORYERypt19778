Asteroids = {}

local Asteroid = {}
Asteroid.__index = Asteroid

function Asteroid.new(world, size, tagnum, location)
    local instance = setmetatable({}, Asteroid)
    instance.tag = "ASTEROID"..tagnum
    local vmax = 40
    local inward = 10
    local angle = {{vmax, math.random(vmax)}, {math.random(vmax), vmax}, {-vmax, -math.random(vmax)}, {-math.random(vmax), -vmax}}
    
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

    instance.x, instance.y = math.random(window_width), math.random(window_height)
    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'dynamic')
    --instance.physics.body:setFixedRotation(true)
    instance.physics.shape = love.physics.newCircleShape(instance.radius)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData(instance)
    instance.physics.fixture:setRestitution(0.2 * size)
    
    --[[
    local min_distance = 10
    local asteroid_distance = 0
    local spaceship_distance = 0
    if #Asteroids > 1 then
        local placed = false
        repeat 
            for _, spaceship in ipairs(Spaceships) do
                for _, asteroid in ipairs(Asteroids) do
                    asteroid_distance = love.physics.getDistance(instance.physics.fixture, asteroid.physics.fixture)
                    spaceship_distance = love.physics.getDistance(instance.physics.fixture, spaceship.physics.fixture)
                    if asteroid_distance > min_distance and spaceship_distance > min_distance then
                        placed = true
                        print("placed!")
                    else
                        print("instance.x, instance.y:"..instance.x..", "..instance.y)
                        instance.x, instance.y = math.random(window_width), math.random(window_height)
                        print("not placed. asteroid distance:"..asteroid_distance.."spaceship distance:"..spaceship_distance)
                    end
                end
            end
        until placed == true
    end
    ]]
    local placed = false
    local mindist = 30
    local loopcounter = 0
    local maxloops = 100
    if #Asteroids > 1 then
        repeat
            loopcounter = loopcounter + 1
            for _, asteroid in ipairs(Asteroids) do
                for _, spaceship in ipairs(Spaceships) do
                    local spaceship_dist = love.physics.getDistance(instance.physics.fixture, spaceship.physics.fixture)
                    local asteroid_dist = love.physics.getDistance(instance.physics.fixture, asteroid.physics.fixture)
                    print(asteroid_dist..", "..spaceship_dist)
                    if asteroid_dist >= mindist and spaceship_dist >= mindist * 1.5 then
                        placed = true
                        print('placed. dist_spaceship='..spaceship_dist..", dist_asteroid="..asteroid_dist)
                    else
                        math.randomseed(os.time())
                        instance.x = math.random(window_height)
                        instance.y = math.random(window_width)
                        print('not placed. dist_spaceship='..spaceship_dist..", dist_asteroid="..asteroid_dist)
                        print("loops taken: "..loopcounter)
                    end
                end
            end
        until placed == true
    end
    instance.velAngle = angle[math.random(4)]

    instance.mark = "alive"
    table.insert(Asteroids, instance)
    return instance
end

function Asteroid:update(dt)
    for index, asteroid in ipairs(Asteroids) do
        asteroid.pSystem:update(dt)
        asteroid.x, asteroid.y = asteroid.physics.body:getPosition()
        asteroid.angle = asteroid.physics.body:getAngle()
        local velocity = asteroid.physics.body:getLinearVelocity()

        if asteroid.y < 0 - 10 then
            asteroid.physics.body:setY(window_height - 10)
        elseif asteroid.x < 0 - 10 then
            asteroid.physics.body:setX(window_width - 10)
        end
        if asteroid.y > window_height + 10 then
            asteroid.physics.body:setY(0 - 10)
        elseif asteroid.x > window_width + 10 then
            asteroid.physics.body:setX(0 - 10)
        end
        asteroid.physics.body:setLinearVelocity(asteroid.velAngle[1], asteroid.velAngle[2])

        for index_projectile, projectile in ipairs(spaceship.projectiles) do
            if _G.collisionData == asteroid.tag.."collide"..projectile.tag or _G.collisionData == projectile.tag.."collide"..asteroid.tag then
                if asteroid.mark == 'alive' then
                    asteroid.mark = 'dead'
                    asteroid.physics.fixture:destroy()

                    spaceship:destroyProjectile(index_projectile)
                    spaceship.asteroid_killcount = spaceship.asteroid_killcount + 1

                    game.score = game.score + asteroid.size * 10

                    asteroid.pSystem:emit(10 * asteroid.size)

                    audio.sounds.explode:stop()
                    audio.sounds.explode:play()
                end
            end
        end

        if asteroid.mark == "dead" and asteroid.pSystem:getCount() == 0 then
            asteroid:destroy(index)
        end
    end
end

function Asteroid:draw()
    for index, asteroid in ipairs(Asteroids) do
        if asteroid.mark == "alive" then
            love.graphics.print(asteroid.pSystem:getCount(), 100, 100)
            love.graphics.circle('line', asteroid.x, asteroid.y, asteroid.radius)
            love.graphics.print(asteroid.tag, asteroid.x, asteroid.y - 10)

            love.graphics.draw(asteroid.sprite, asteroid.x, asteroid.y, asteroid.angle, game.scale, nil, asteroid.sprite:getWidth() / 2, asteroid.sprite:getHeight() / 2)
        end
        love.graphics.draw(asteroid.pSystem, asteroid.x, asteroid.y, nil, game.scale)
    end
end

function Asteroid:destroy(index)
    self.tag, self.mark = false, false
    table.remove(Asteroids, index)
    self = {}
end

return Asteroid