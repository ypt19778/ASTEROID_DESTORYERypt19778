Asteroids = {}

local Asteroid = {}
Asteroid.__index = Asteroid

function Asteroids_startSpawn(max)
    for i = 1, max do
        local area = #Asteroids + 1
        local vmax = 50
        local map = {{-20, 300}, {400, -20}, {love.graphics.getWidth() + 20, 300}, {400, love.graphics.getHeight() + 20}}
        local angle = {{vmax, math.random(vmax)}, {math.random(vmax), vmax}, {-vmax, -math.random(vmax)}, {-math.random(vmax), -vmax}}
        local x, y = unpack(map[area])
        local vx, vy = unpack(angle[area])
        local tag = #Asteroids + 1
        Asteroid.new(world, tag)
    end
end

function Asteroid.new(world, tag)
    local instance = setmetatable({}, Asteroid)
    instance.tag = tag        
    local vmax = 50
    local map = {{-20, 300}, {400, -20}, {love.graphics.getWidth() + 20, 300}, {400, love.graphics.getHeight() + 20}}
    local angle = {{vmax, math.random(vmax)}, {math.random(vmax), vmax}, {-vmax, -math.random(vmax)}, {-math.random(vmax), -vmax}}

    instance.x, instance.y = map[tag][1], map[tag][2]
    
    instance.sprites = {
        --small
        {
            love.graphics.newImage('sprites/asteroids/asteroid_small_1.png'),
            love.graphics.newImage('sprites/asteroids/asteroid_small_2.png'),
            love.graphics.newImage('sprites/asteroids/asteroid_small_3.png') 
        },
        --medium
        { 
            love.graphics.newImage('sprites/asteroids/asteroid_med_1.png'),
            love.graphics.newImage('sprites/asteroids/asteroid_med_2.png'),
            love.graphics.newImage('sprites/asteroids/asteroid_med_3.png') 
        },
        --chunk / large
        {
            love.graphics.newImage('sprites/asteroids/asteroid_large_1.png'),
            love.graphics.newImage('sprites/asteroids/asteroid_large_2.png'), 
            love.graphics.newImage('sprites/asteroids/asteroid_large_3.png')
        }
    }
    local size = math.random(3)
    instance.sprite = instance.sprites[size][math.random(3)]
    instance.size = size
    instance.radius = 15 * instance.size

    local pSystem_image = love.graphics.newImage('sprites/asteroids/asteroid_particle.png')
    local pSystem_buffer = 999
    instance.pSystem = love.graphics.newParticleSystem(pSystem_image, pSystem_buffer)
    instance.pSystem:setLinearAcceleration(-600, -600, 600, 600)
    instance.pSystem:setParticleLifetime(1, 2)
    instance.pSystem:setSpread(math.pi)

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'dynamic')
    instance.physics.shape = love.physics.newCircleShape(instance.radius)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData(instance)

    instance.angle = angle[tag]

    instance.mark = "alive"

    table.insert(Asteroids, instance)
    return instance
end

function Asteroid:update(dt)
    for index, asteroid in ipairs(Asteroids) do
        asteroid.pSystem:update(dt)
        asteroid.x, asteroid.y = asteroid.physics.body:getPosition()

        asteroid.physics.body:setLinearVelocity(asteroid.angle[1], asteroid.angle[2])

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
            love.graphics.draw(asteroid.sprite, asteroid.x - (asteroid.sprite:getWidth() / 2), asteroid.y - (asteroid.sprite:getHeight() / 2), nil, game.scale)
        end
        love.graphics.draw(asteroid.pSystem, asteroid.x, asteroid.y, nil, game.scale)

        love.graphics.setColor(0, 1, 0)
        love.graphics.circle('line', asteroid.x, asteroid.y, asteroid.physics.shape:getRadius())
        love.graphics.setColor(1, 1, 1)

        if _G.collisionData == asteroid.tag.."collideSPACESHIP_PROJECTILE" then
            asteroid.mark = "dead"
            asteroid.physics.body:setLinearDamping(999)
            if asteroid.physics.fixture then
                asteroid.physics.fixture:destroy()
            end
            asteroid.pSystem:emit(10 * asteroid.size)
        end
    end
end

function Asteroid:destroy(index)
    tag = Asteroids[index].tag
    table.remove(Asteroids, index)
    Asteroid.new(world, tag)
end

return Asteroid