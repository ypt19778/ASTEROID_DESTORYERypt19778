Spaceships = {}

local Spaceship = {}
Spaceship.__index = Spaceship

function Spaceship.new(world, speed, health, shield)
    local instance = setmetatable({}, Spaceship)
    instance.tag = "SPACESHIP"
    instance.x = 400
    instance.y = 300

    instance.radius = 5
    instance.width, instance.height = 10, 10
    instance.rotation = 0

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
    instance.physics.fixture:setRestitution(0.2)
    instance.physics.fixture:setUserData(instance)

    instance.lookAt = {
        x, y = nil, nil
    }

    instance.projectiles = {}

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
    self.afterburner_flash = self.afterburner_flash + dt * 40
    if self.afterburner_flash > 2 then
        self.afterburner_flash = 0
    end
    self:move()
    self:updateProjectiles()
end

function Spaceship:draw()
    self:drawProjectiles()
    love.graphics.print(self.rotation, 20, 20)

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

function Spaceship:checkKeypress(k)
    if k == 'space' then
        self:shoot()
    end
end

-- MAKE THE TRAIL a flashing triangle instead of a streak.
    -- have a timer for drawing the triangle / not 
    -- make the triangle appear at the butt of the ship
    -- and make it non-speed adjustable

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

    projectile.radius = 1

    projectile.lifetime = 75
    projectile.life = 0

    projectile.frames = {}
    for i = 0, 1 do
        --table.insert(projectile.frames, love.graphics.newQuad()
    end

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
        projectile.physics.body:setLinearVelocity(projectile.cos, projectile.sin)

        projectile.life = projectile.life + 1
        
        -- make projectiles dissapear when it collides with an asteroid.
            -- change asteroid removing steps so it can properly be resolved.
            
        if projectile.life < 0 or _G.collisionData == "collide" then
            projectile = {}
            table.remove(self.projectiles, index)
        end
    end
end

function Spaceship:drawProjectiles()
    for _, projectile in ipairs(self.projectiles) do
        love.graphics.circle('line', projectile.x, projectile.y, projectile.radius)
    end
end

return Spaceship