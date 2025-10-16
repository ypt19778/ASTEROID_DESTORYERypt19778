Spaceships = {}

local Spaceship = {}
Spaceship.__index = Spaceship

function Spaceship.new(world)
    local instance = setmetatable({}, Spaceship)
    instance.tag = "SPACESHIP"
    instance.mark = 'alive'
    instance.opt_menu = false
    instance.index = #Spaceships + 1
    instance.x = 400
    instance.y = 300

    instance.radius = 5
    instance.sprite = love.graphics.newImage('graphics/sprites/spaceship_2.png')
    instance.sprite_width, instance.sprite_height = instance.sprite:getDimensions()
    instance.width, instance.height = 10, 10
    instance.rotation = 0

    local pSystem_image = love.graphics.newImage('graphics/sprites/spaceship_particle.png')
    instance.pSystem = love.graphics.newParticleSystem(pSystem_image)
    instance.pSystem:setSizes(1)
    instance.pSystem:setLinearAcceleration(-300, -300, 300, 300)
    instance.pSystem:setParticleLifetime(1, 2)
    instance.pSystem:setSpread(math.pi)

    instance.iFrameTimer = 0
    instance.iFrames = 10

    instance.color = {1, 1, 1, 1}

    instance.afterburner_flash = 0

    instance.speed = 1
    instance.angularSpeed = 0.04
    instance.defSpeed = instance.speed
    instance.velocity = nil
    instance.maxVelocity = 230
    instance.isAccelerating = false

    instance.physics = {}
    instance.physics.damping = 2.7
    instance.physics.defDamping = instance.physics.damping
    instance.physics.brakeDamping = 3
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "dynamic")
    instance.physics.body:setLinearDamping(2)
    instance.physics.shape = love.physics.newCircleShape(instance.radius)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData(instance)

    instance.lookAt = {
        x, y = nil, nil
    }

    instance.projectiles = {}
    instance.asteroid_killcount = 0

    table.insert(Spaceships, instance)
    return instance
end

function Spaceship:move()
    self.x, self.y = self.physics.body:getPosition()
    
    self.physics.body:setLinearDamping(self.physics.damping)
    self.physics.body:setAngularDamping(self.physics.damping)

    self.lookAt.x = self.x - math.cos(self.rotation) * 12
    self.lookAt.y = self.y - math.sin(self.rotation) * 12

    self.velocity = self.physics.body:getLinearVelocity()
    
    local angle = math.atan2(self.y - self.lookAt.y, self.x - self.lookAt.x)
    local cos = -math.cos(angle)
    local sin = -math.sin(angle)
    if love.keyboard.isDown("w") and self.velocity < self.maxVelocity then
        self.physics.body:applyLinearImpulse(self.speed * cos, self.speed * sin)
        self.isAccelerating = true
    else self.isAccelerating = false end
    if love.keyboard.isDown("a") then
        self.rotation = self.rotation - self.angularSpeed
    elseif love.keyboard.isDown("d") then
        self.rotation = self.rotation + self.angularSpeed
    end
    if love.keyboard.isDown("s") then
        self.physics.damping = self.physics.brakeDamping
    else self.physics.damping = self.physics.defDamping end
end

function Spaceship:update(dt)
    audio.spaceship.shoot:setPitch(math.random(0.9, 1.1))
    self.pSystem:update(dt)
    if self.mark == 'alive' then
        self.afterburner_flash = self.afterburner_flash + dt * 40
        for _, asteroid in ipairs(Asteroids) do
            if _G.collisionData == self.tag.."collide"..asteroid.tag then
                if self.mark == 'alive' then
                    self.pSystem:emit(30)
                end
                self.mark = 'dead'
                print('you died from:'..asteroid.tag)
                audio.sounds.explode:stop()
                audio.sounds.explode:play()
            end
        end

        -- add an end credits screen showing level reached and score, along with upgrades and aseroids destroyed, and time
        if self.mark == 'dead' and self.pSystem:getCount() == 0 then
            self:destroy(self.index)
        end

        if self.afterburner_flash > 2 then
            self.afterburner_flash = 0
        end
        if self.y < 0 - 5 then
            self.physics.body:setY(window_height - 5)
        elseif self.x < 0 - 5 then
            self.physics.body:setX(window_width - 5)
        end
        if self.y > window_height + 5 then
            self.physics.body:setY(0 - 5)
        elseif self.x > window_width + 5 then
            self.physics.body:setX(0 - 5)
        end
        self:move()
        self:updateProjectiles()
    end
end

local scoreScreen_timer = 0
function Spaceship:printEndCredits()
    local scoreColor = {250 / 255, 250 / 255, 200 / 255}
    scoreScreen_timer = scoreScreen_timer + 1

    love.graphics.setColor(scoreColor)
    love.graphics.print('you reached level: '..Level.level, game.font, 30, 30, nil, 1.1)
    love.graphics.print('asteroids killed: '..self.asteroid_killcount, game.font, 30, 50, nil, 1.1)
    if scoreScreen_timer > 100 then
        love.graphics.print('PRESS ANY KEY TO WARP TO MAIN MENU', game.font, 10, window_height / 2, nil, 1.1)
        self.opt_menu = true
    end
    love.graphics.setColor(1, 1, 1)
end

function Spaceship:draw()
    love.graphics.draw(self.pSystem, self.x, self.y, nil, game.scale)
    --[[ retro spaceship
    if self.x and self.y then
        self:drawProjectiles()
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle('line', self.x, self.y, self.physics.shape:getRadius())
        love.graphics.setColor(1, 1, 1)

        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4])
        --love.graphics.draw(self.sprite, self.x, self.y, self.rotation - 0.79, game.scale, nil, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
        local left_x, left_y = self.lookAt.x + math.cos(self.rotation - 0.3) * 22, self.lookAt.y + math.sin(self.rotation - 0.3) * 22
        local right_x, right_y = self.lookAt.x + math.cos(self.rotation + 0.3) * 22, self.lookAt.y + math.sin(self.rotation + 0.3) * 22
        local front_x, front_y = self.lookAt.x + math.cos(self.rotation), self.lookAt.y + math.sin(self.rotation)
        -- Calculate bottom line points at original distance to keep back the same size,
        local bottom_left_x, bottom_left_y = self.lookAt.x + math.cos(self.rotation - 0.3) * 19, self.lookAt.y + math.sin(self.rotation - 0.3) * 19
        local bottom_right_x, bottom_right_y = self.lookAt.x + math.cos(self.rotation + 0.3) * 19, self.lookAt.y + math.sin(self.rotation + 0.3) * 19
        --R and L lines (longer)
        love.graphics.line(front_x, front_y, left_x, left_y)
        love.graphics.line(right_x, right_y, front_x, front_y)
        --BOTTOM line (same size as before)
        love.graphics.line(bottom_left_x, bottom_left_y, bottom_right_x, bottom_right_y)

        local afterburner_left_x, afterburner_left_y = self.lookAt.x + math.cos(self.rotation - 0.2) * 19, self.lookAt.y + math.sin(self.rotation - 0.2) * 19
        local afterburner_right_x, afterburner_right_y = self.lookAt.x + math.cos(self.rotation + 0.2) * 19, self.lookAt.y + math.sin(self.rotation + 0.2) * 19
        local afterburner_front_x, afterburner_front_y = self.lookAt.x + math.cos(self.rotation) * 25, self.lookAt.y + math.sin(self.rotation) * 25
        if self.isAccelerating == true and self.afterburner_flash >= 1 then
            love.graphics.line(afterburner_front_x, afterburner_front_y, afterburner_left_x, afterburner_left_y)
            love.graphics.line(afterburner_right_x, afterburner_right_y, afterburner_front_x, afterburner_front_y)
        end
    end
    --]]
    -- game-based spaceship
    if self.mark == 'alive' then
        love.graphics.draw(self.sprite, self.x, self.y, self.rotation - 1.5, game.scale, nil, self.sprite_width / 2, self.sprite_height / 2)
        self:drawProjectiles()
    elseif self.mark == 'dead' then
        self:printEndCredits()
    end
end

function Spaceship:checkMousepress(button)
    if self.mark == 'alive' then
        if button == 1 then
            self:shoot()
        end
    end
end

function Spaceship:checkKeypress(key)
    if self.mark == 'alive' then
        if key == 'j' or key == 'k' or key == 'space' then
            self:shoot()
        end
    elseif self.opt_menu then
        game.state = 'menu'
        love.load()
    end
end

function Spaceship:shoot()
    local angle = math.atan2(self.y - self.lookAt.y, self.x - self.lookAt.x)
    local cos = -math.cos(angle)
    local sin = -math.sin(angle)

    local projectile = {}
    projectile.tag = "SPACESHIP_PROJECTILE"
    projectile.x = self.x
    projectile.y = self.y

    projectile.speed = 500

    projectile.cos = cos * projectile.speed
    projectile.sin = sin * projectile.speed

    projectile.radius = 1.5

    projectile.lifetime = 75
    projectile.life = 0

    projectile.physics = {}
    projectile.physics.body = love.physics.newBody(world, self.lookAt.x, self.lookAt.y, 'dynamic')
    projectile.physics.shape = love.physics.newCircleShape(projectile.radius)
    projectile.physics.fixture = love.physics.newFixture(projectile.physics.body, projectile.physics.shape)
    projectile.physics.fixture:setUserData(projectile)

    table.insert(self.projectiles, projectile)

    audio.spaceship.shoot:stop()
    audio.spaceship.shoot:play()
end

function Spaceship:updateProjectiles()
    for index, projectile in ipairs(self.projectiles) do
        projectile.x, projectile.y = projectile.physics.body:getPosition()
        if projectile.y < 0 - 5 then
            projectile.physics.body:setY(window_height - 5)
        elseif projectile.x < 0 - 5 then
            projectile.physics.body:setX(window_width - 5)
        end
        if projectile.y > window_height + 5 then
            projectile.physics.body:setY(0 - 5)
        elseif projectile.x > window_width + 5 then
            projectile.physics.body:setX(0 - 5)
        end
        projectile.physics.body:setLinearVelocity(projectile.cos, projectile.sin)

        projectile.life = projectile.life + 1
            
        if projectile.life > projectile.lifetime then
            self:destroyProjectile(index)
        end
    end
end

function Spaceship:drawProjectiles()
    for _, projectile in ipairs(self.projectiles) do
        love.graphics.circle('line', projectile.x, projectile.y, projectile.radius)
    end
end

function Spaceship:destroyProjectile(index)
    self.projectiles[index].physics.fixture:destroy()
    --self.projectiles[index] = {}
    table.remove(self.projectiles, index)
    print('killed spaceship projectile')
end

function Spaceship:destroy(index)
    Spaceships[index] = {}
    table.remove(Spaceships, index)
    self.mark = false
    print('killed spaceship')
end

return Spaceship