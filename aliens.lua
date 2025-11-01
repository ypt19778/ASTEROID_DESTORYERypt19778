Aliens = {}

local Alien = {}
Alien.maxAliens = 8
Alien.__index = Alien

function Alien.new(world, spaceship, location, vectors)
    local instance = setmetatable({}, Alien)
    instance.tag = "ALIEN"..#Aliens + 1
    instance.tagnum = #Aliens + 1
    instance.mark = "alive"
    instance.world = world
    instance.spaceship = spaceship
    instance.pointValue = 500

    instance.x, instance.y = location[1] or -10, location[2] or 300

    instance.radius = 20

    instance.speed = 100
    instance.vx, instance.vy = vectors.vx, vectors.vy

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'dynamic')
    instance.physics.shape = love.physics.newCircleShape(instance.radius)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData(instance)

    instance.projectile_sprite = love.graphics.newImage("graphics/sprites/alien_projectile.png")
    instance.projectile_sprite_width = instance.projectile_sprite:getWidth()
    instance.projectile_sprite_height = instance.projectile_sprite:getHeight()
    instance.sprite = love.graphics.newImage("graphics/sprites/alien_spritesheet.png")
    local frames = 2
    local frame_width, frame_height = 17, 17
    local image_width, image_height = instance.sprite:getDimensions()
    instance.frames = {}
    for i = 0, frames - 1 do
        table.insert(instance.frames, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, image_width, image_height))
    end
    instance.frameSpeed = 2 -- in (_00%) percentage

    instance.currentFrame = 1

    instance.fireRate = 0.0167
    instance.fireAmount = 0
    instance.fireTimer = 0 
    instance.maxFires = 7
    instance.projectiles = {}

    --[[
    for index, value in ipairs(Aliens) do
        if value == nil then
            Aliens[index] = instance
        end
        --table.insert(Aliens, instance)
    end
    ]]
    --[[
    local added = false
    for i = 1, #Aliens do
        if Aliens[i] == nil then
            added = true
            instance.tag = "ALIEN"..i
            instance.tagnum = i
            Aliens[i] = instance
        end
    end
    if not added then
        instance.tag = "ALIEN"..#Aliens + 1
        instance.tagnum = #Aliens + 1
        table.insert(Aliens, instance)
    end
    ]]

    table.insert(Aliens, instance)

    audio.alien.alert:stop()
    audio.alien.alert:play()
    return instance
end

local edge_ofs = 200 -- from edges of the screen
local dicerolls = 0
function Alien.enableSpawning(chance)
    if #Aliens < Alien.maxAliens then
        -- chance is "one in a (chance)"
        if chance <= 100 then chance = 100 end
        local dice = math.random(1, chance)
        dicerolls = dicerolls + 1
        if dice == Level.level - 5 or dicerolls == chance * 5 then
            print("dice: "..dice..", chance:"..chance)
            local rand_window_width, rand_window_height = math.random(window_width), math.random(window_height)
            local spawnpoints = {
                {rand_window_width, 0 - edge_ofs},
                {rand_window_width, window_height + edge_ofs},
                {0 - edge_ofs, rand_window_height},
                {window_width + edge_ofs, rand_window_height}
            }
            local spawnvectors = {
                {vx = 0, vy = 1},
                {vx = 0, vy = -1},
                {vx = 1, vy = 0},
                {vx = -1, vy = 0}
            }
            local spawnDice = math.random(1, 4)
            Alien.new(world, spaceship, spawnpoints[spawnDice], spawnvectors[spawnDice])
            dicerolls = 0
        end
    end
end

function Alien:shoot()
    local projectile = {}
    projectile.tag = self.tag.."_PROJECTILE"

    projectile.cos = self.cosToSpaceship
    projectile.sin = self.sinToSpaceship

    projectile.x, projectile.y = self.x, self.y

    projectile.radius = 5

    projectile.speed = 200

    projectile.physics = {}
    projectile.physics.body = love.physics.newBody(self.world, projectile.x, projectile.y, 'dynamic')
    projectile.physics.shape = love.physics.newCircleShape(projectile.radius)
    projectile.physics.fixture = love.physics.newFixture(projectile.physics.body, projectile.physics.shape)
    projectile.physics.fixture:setUserData(projectile)

    projectile.sprite = love.graphics.newImage('graphics/sprites/alien_projectile.png')
    projectile.trail = {}
    projectile.trail_rate = 1
    projectile.trail_timer = 0

    table.insert(self.projectiles, projectile)

    audio.alien.shoot:stop()
    audio.alien.shoot:play()

    self.fireAmount = self.fireAmount + 1
    self.fireTimer = 0
end

function Alien:updateProjectiles()
    for index_projectile, projectile in ipairs(self.projectiles) do
        projectile.trail_timer = projectile.trail_timer + 1
        if projectile.trail_timer > projectile.trail_rate then
            table.insert(projectile.trail, {x = projectile.x, y = projectile.y, radius = projectile.radius})
            projectile.trail_timer = 0
        end

        if projectile.x > window_width + edge_ofs or projectile.x < 0 - edge_ofs or projectile.y > window_height + edge_ofs or projectile.y < 0 - edge_ofs then
            projectile.physics.fixture:destroy()
            table.remove(self.projectiles, index_projectile)
        end

        projectile.x, projectile.y = projectile.physics.body:getPosition()
        projectile.physics.body:setLinearVelocity(-projectile.cos * projectile.speed, -projectile.sin * projectile.speed)
    end
end

function Alien:drawProjectiles()
    for index_projectile, projectile in ipairs(self.projectiles) do
        for index_trail, trail in ipairs(projectile.trail) do
            trail.radius = trail.radius - 0.3
            if trail.radius <= 0 then
                table.remove(projectile.trail, index_trail)
            end

            love.graphics.setColor(0, 1, 0)
            love.graphics.circle('fill', trail.x, trail.y, trail.radius)
            love.graphics.setColor(1, 1, 1)
        end

        --love.graphics.circle('fill', projectile.x, projectile.y, projectile.radius)
        love.graphics.draw(self.projectile_sprite, projectile.x, projectile.y, nil, game.scale, nil, self.projectile_sprite_width / 2, self.projectile_sprite_height / 2)
    end
end

function Alien:move()
    self.angleToSpaceship = math.atan2(self.y - self.spaceship.y, self.x - self.spaceship.x)
    self.cosToSpaceship = math.cos(self.angleToSpaceship)
    self.sinToSpaceship = math.sin(self.angleToSpaceship)

    self.physics.body:setLinearVelocity(self.vx * self.speed, self.vy * self.speed)
end

function Alien:update(dt)
    for index_alien, alien in ipairs(Aliens) do
        alien.spaceship = spaceship
        alien.x, alien.y = alien.physics.body:getPosition()
        if alien.mark == 'alive' then
            alien.currentFrame = alien.currentFrame + dt * alien.frameSpeed
            alien.fireTimer = alien.fireTimer + alien.fireRate 
            if alien.currentFrame >= 3 then
                alien.currentFrame = 1
            end

            if alien.x > window_width + edge_ofs or alien.x < 0 - edge_ofs or alien.y > window_height + edge_ofs or alien.y < 0 - edge_ofs then
                alien.mark = "dead"
            end
            for index_spaceship_projectile, spaceship_projectile in ipairs(alien.spaceship.projectiles) do
                if _G.collisionData == alien.tag.."collide"..spaceship_projectile.tag then
                    game.score = game.score + alien.pointValue
                    alien.physics.fixture:destroy()
                    alien.spaceship:killProjectile(index_spaceship_projectile)
                    alien.mark = "dead"
                    audio.alien.die:stop()
                    audio.alien.die:play()
                end
            end

            alien:move()
            if alien.fireAmount < alien.maxFires and alien.fireTimer >= 1 then
                alien:shoot()
            end
            alien:updateProjectiles()
        elseif alien.mark == 'dead' then
            --Alien:kill(alien.tagnum)
            if not alien.physics.fixture:isDestroyed() then alien.physics.fixture:destroy() end
            alien = nil
            table.remove(Aliens, index_alien)
        end
    end
end

function Alien:draw()
    for index_alien, alien in ipairs(Aliens) do
        if alien.mark == 'alive' then
            love.graphics.print(alien.tagnum, alien.x, alien.y)
            love.graphics.draw(alien.sprite, alien.frames[math.floor(alien.currentFrame)], alien.x, alien.y, alien.physics.body:getAngle(), game.scale * 1.5, nil, alien.radius / 2 - 2, alien.radius / 2 - 2)
            alien:drawProjectiles()
        end
    end
end

function Alien:kill(tagnum)
    if not Aliens[tagnum].physics.fixture:isDestroyed() then Aliens[tagnum].physics.fixture:destroy() end
    Aliens[tagnum] = nil 
end


return Alien