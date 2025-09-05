Asteroids = {}

local Asteroid = {}
Asteroid.__index = Asteroid

local ww, wh = love.graphics.getDimensions()
function Asteroids_startSpawn(max)
    for i = 1, max do
        local area = #Asteroids + 1
        local vmax = 50
        local map = {{-20, wh / 2}, {ww / 2, -20}, {ww + 20, wh / 2}, {ww / 2, wh + 20}}
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
    local map = {{-20, wh / 2}, {ww / 2, -20}, {ww + 20, wh / 2}, {ww / 2, wh + 20}}
    local angle = {{vmax, math.random(vmax)}, {math.random(vmax), vmax}, {-vmax, -math.random(vmax)}, {-math.random(vmax), -vmax}}

    instance.x, instance.y = map[tag][1], map[tag][2]
    
    instance.sprites = {

    }

    local size = math.random(3)
    instance.size = size
    instance.radius = 15 * instance.size

    local pSystem_image = love.graphics.newImage('graphics/sprites/asteroids/asteroid_particle.png')
    instance.pSystem = love.graphics.newParticleSystem(pSystem_image)
    instance.pSystem:setLinearAcceleration(-700, -700, 700, 700)
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
            -- make 5 - 10 polygon shapes each size can use 
            -- make this choose a random number to see which polygon it uses
        end
        love.graphics.draw(asteroid.pSystem, asteroid.x, asteroid.y, nil, game.scale)

        love.graphics.setColor(0, 1, 0)
        love.graphics.circle('line', asteroid.x, asteroid.y, asteroid.physics.shape:getRadius())
        love.graphics.setColor(1, 1, 1)

        if _G.collisionData == asteroid.tag.."collideSPACESHIP_PROJECTILE" or _G.collisionData == "SPACESHIP_PROJECTILEcollide"..asteroid.tag then
            asteroid.mark = "dead"
            asteroid.physics.body:setLinearDamping(999)
            if asteroid.physics.fixture then
                asteroid.physics.fixture:destroy()
            end
            game.score = game.score + asteroid.size * 10
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