Spaceships = {}

local Spaceship = {}
Spaceship.__index = Spaceship

function Spaceship.new(world)
    local instance = setmetatable({}, Spaceship)
    instance.tag = "SPACESHIP"
    instance.name = ""
    instance.named = false
    instance.mark = 'alive'
    instance.opt_menu = false
    instance.index = #Spaceships + 1
    instance.x = window_width / 2
    instance.y = window_height / 2

    instance.radius = 5
    instance.sprite = love.graphics.newImage('graphics/sprites/spaceship_2.png')
    instance.sprite_width, instance.sprite_height = instance.sprite:getDimensions()
    instance.width, instance.height = 10, 10
    instance.rotation = 0

    instance.projectile_size = 0

    local pSystem_image = love.graphics.newImage('graphics/sprites/spaceship_particle.png')
    instance.pSystem = love.graphics.newParticleSystem(pSystem_image)
    instance.pSystem:setSizes(1)
    instance.pSystem:setLinearAcceleration(-300, -300, 300, 300)
    instance.pSystem:setParticleLifetime(1, 2)
    instance.pSystem:setSpread(math.pi)

    instance.color = {1, 1, 1, 1}

    instance.iFrameFlash = 0

    instance.speed = 1
    instance.angularSpeed = 0.04
    instance.defSpeed = instance.speed
    instance.velocity = nil
    instance.maxVelocity = 230
    instance.isAccelerating = false

    instance.iFrames = 200

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
    instance.fireRate = 50 -- this is added to timer to see when timer > 10 or sum
    instance.fireTimer = 30
    instance.asteroid_killcount = 0

    instance.shields = 0
    instance.shield_sprite = love.graphics.newImage('graphics/sprites/shield.png')
    instance.shield_width, instance.shield_height = instance.shield_sprite:getDimensions()
    instance.shield_rotation = 0

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
    
    self.angle = math.atan2(self.y - self.lookAt.y, self.x - self.lookAt.x)
    self.cos = -math.cos(self.angle)
    self.sin = -math.sin(self.angle)
    if love.keyboard.isDown("w") and self.velocity < self.maxVelocity then
        self.physics.body:applyLinearImpulse(self.speed * self.cos, self.speed * self.sin)
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
        if self.fireTimer > 1 then
            self.fireTimer = self.fireTimer - self.fireRate * dt
        end
        if self.iFrames > 0 then
            self.iFrames = math.floor(self.iFrames - 1 * dt)
        end
        self.shield_rotation = self.shield_rotation + 1 * dt
        self.iFrameFlash = self.iFrameFlash + dt * 20
        for _, asteroid in ipairs(Asteroids) do
            if self.iFrames == 0 then
                if _G.collisionData == self.tag.."collide"..asteroid.tag then
                    if self.shields == 0 then
                        if self.mark == 'alive' then
                            self.pSystem:emit(30)
                        end
                        self.mark = 'dead'
                        game.saveScore()
                        print('you died from:'..asteroid.tag)
                        audio.sounds.explode:stop()
                        audio.sounds.explode:play()
                    elseif self.shields > 0 then
                        self.shields = self.shields - 1
                        audio.spaceship.shield_down:stop()
                        audio.spaceship.shield_down:play()
                        self.iFrames = 200
                    end
                end
            end
        end

        -- add an end credits screen showing level reached and score, along with upgrades and aseroids destroyed, and time
        if self.mark == 'dead' and self.pSystem:getCount() == 0 then
            self:kill(self.index)
        end

        if self.iFrameFlash > 2 then
            self.iFrameFlash = 0
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
    elseif self.opt_menu then
        game.state = 'menu'
        love.load()
    end
end

local scoreScreen_timer = 0

function Spaceship:getNamingInput(input)
    --adds last input to name
    if #self.name < 12 then
        self.name = self.name .. input
    end
end

function Spaceship:printEndCredits()
    local scoreColor = {250 / 255, 250 / 255, 200 / 255}
    scoreScreen_timer = scoreScreen_timer + 1

    love.graphics.setColor(scoreColor)
    love.graphics.print('you reached level: '..Level.level, game.font, 30, 30, nil, 1.1)
    love.graphics.print('asteroids killed: '..self.asteroid_killcount, game.font, 30, 50, nil, 1.1)

    love.graphics.print("please enter your name: \n\n"..self.name.."\n\nand ENTER to continue.", game.font, window_width * (1/3), window_height * (1/4), nil, 1.2)

    if self.named then
        love.graphics.print('PRESS "q" TO WARP TO MAIN MENU', game.font, 10, window_height / 2, nil, 1.1)
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
        if self.isAccelerating == true and self.iFrameFlash >= 1 then
            love.graphics.line(afterburner_front_x, afterburner_front_y, afterburner_left_x, afterburner_left_y)
            love.graphics.line(afterburner_right_x, afterburner_right_y, afterburner_front_x, afterburner_front_y)
        end
    end
    --]]
    -- game-based spaceship
    if self.mark == 'alive' then
        if self.fireTimer > 1 then
            love.graphics.rectangle('fill', self.x - self.fireTimer / 2, self.y - 25, self.fireTimer, 10)
        end
        if self.shields >= 1 then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print('x'..self.shields..' shields', game.font, 30, window_height - 30)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.shield_sprite, self.x, self.y, self.shield_rotation, game.scale * 2, nil, self.shield_width / 2, self.shield_height / 2)
        end
        if self.iFrames == 0 then
            love.graphics.draw(self.sprite, self.x, self.y, self.rotation - 1.5, game.scale, nil, self.sprite_width / 2, self.sprite_height / 2)
        elseif self.iFrameFlash >= 1 then
            love.graphics.draw(self.sprite, self.x, self.y, self.rotation - 1.5, game.scale, nil, self.sprite_width / 2, self.sprite_height / 2)
        end
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
            if self.fireTimer < 1 then
                self:shoot()
                self.fireTimer = 30
            end
        end
    elseif self.mark == 'dead' then
        if key == 'backspace' then
            self.name = string.sub(self.name, 1, #self.name - 1)
        end
        if key == 'return' then
            self.named = true
        end
        if spaceship.named then
            if key == 'q' then
                spaceship.opt_menu = true
            end
        end
    end
end

function Spaceship:shoot()
    local angle = math.atan2(self.y - self.lookAt.y, self.x - self.lookAt.x)
    local cos = -math.cos(angle)
    local sin = -math.sin(angle)

    local projectile = {}
    projectile.tag = "SPACESHIP_PROJECTILE"
    projectile.x = self.lookAt.x
    projectile.y = self.lookAt.y

    projectile.speed = 500

    projectile.cos = cos * projectile.speed
    projectile.sin = sin * projectile.speed

    projectile.radius = self.projectile_size + 1.5

    projectile.lifetime = 75
    projectile.life = 0

    projectile.physics = {}
    projectile.physics.body = love.physics.newBody(world, self.lookAt.x, self.lookAt.y, 'dynamic')
    projectile.physics.shape = love.physics.newCircleShape(projectile.radius)
    projectile.physics.fixture = love.physics.newFixture(projectile.physics.body, projectile.physics.shape)
    projectile.physics.fixture:setUserData(projectile)

    table.insert(self.projectiles, projectile)

    projectile.trail = {}
    projectile.trail_timer = 0
    projectile.trail_spawnrate = 1 / projectile.speed

    audio.spaceship.shoot:stop()
    audio.spaceship.shoot:play()
end

function Spaceship:updateProjectiles()
    for index, projectile in ipairs(self.projectiles) do
        projectile.trail_timer = projectile.trail_timer + 1
        if projectile.trail_timer >= projectile.trail_spawnrate then
            new_trail = {x = projectile.x, y = projectile.y, radius = projectile.radius}
            table.insert(projectile.trail, new_trail)
        end
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
            self:killProjectile(index)
        end
    end
end

function Spaceship:drawProjectiles()
    for _, projectile in ipairs(self.projectiles) do
        love.graphics.circle('fill', projectile.x, projectile.y, projectile.radius)
        for index_trail, trail in ipairs(projectile.trail) do
            trail.radius = trail.radius - 0.25
            if trail.radius <= 0 then
                table.remove(projectile.trail, index_trail)
            end
            love.graphics.circle('fill', trail.x, trail.y, trail.radius)
        end
    end
end

function Spaceship:killProjectile(index)
    self.projectiles[index].physics.fixture:destroy()
    self.projectiles[index] = nil
    table.remove(self.projectiles, index)
end

function Spaceship:kill(index)
    Spaceships[index] = {}
    table.remove(Spaceships, index)
    print('killed spaceship')
end

return Spaceship