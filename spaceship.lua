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

    instance.sprite = love.graphics.newImage('sprites/spaceship_2.png')
    instance.color = {1, 1, 1, 1}

    instance.speed = 45
    instance.defSpeed = instance.speed
    instance.angularSpeed = 10
    instance.velocity = nil
    instance.maxVelocity = 200
    instance.health = 3
    instance.shield = 0

    instance.physics = {}
    instance.physics.damping = 2.7
    instance.physics.defDamping = instance.physics.damping
    instance.physics.brakeDamping = 2
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "dynamic")
    instance.physics.body:setLinearDamping(instance.physics.damping)
    instance.physics.body:setAngularDamping(instance.physics.damping)
    instance.physics.shape = love.physics.newCircleShape(instance.radius)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setRestitution(0.2)
    instance.physics.fixture:setUserData(instance)

    instance.lookAt = {
        x, y = nil, nil
    }

    instance.trail = {}
    instance.trail_timer = 0
    instance.trail_rate = 1

    instance.projectiles = {}

    table.insert(Spaceships, instance)
    return instance
end

function Spaceship:move()
    self.x, self.y = self.physics.body:getPosition()
    
    self.physics.body:setLinearDamping(self.physics.damping)
    self.physics.body:setAngularDamping(self.physics.damping)
    self.rotation = self.physics.body:getAngle()

    self.lookAt.x = self.x + math.cos(self.rotation - 2.335) * 20
    self.lookAt.y = self.y + math.sin(self.rotation - 2.335) * 20

    self.velocity = self.physics.body:getLinearVelocity()
    
    local angle = math.atan2(self.y - self.lookAt.y, self.x - self.lookAt.x)
    local cos = -math.cos(angle)
    local sin = -math.sin(angle)
    if love.keyboard.isDown("w") and self.velocity < self.maxVelocity then
        self.physics.body:applyForce(self.speed * cos, self.speed * sin)
    end
    if love.keyboard.isDown("a") then
        self.physics.body:applyTorque(-self.angularSpeed)
    elseif love.keyboard.isDown("d") then
        self.physics.body:applyTorque(self.angularSpeed)
    end
    if love.keyboard.isDown("s") then
        self.physics.damping = self.physics.brakeDamping
    else self.physics.damping = self.physics.defDamping end
end

function Spaceship:update(dt)
    self:move()
    self:updateProjectiles()
    self:updateTrail()
end

function Spaceship:draw()
    self:drawProjectiles()
    love.graphics.print(self.rotation, 20, 20)
    love.graphics.circle('line', self.x, self.y, self.radius)

    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4])
    self:drawTrail()
    love.graphics.draw(self.sprite, self.x, self.y, self.rotation - 0.79, game.scale, nil, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    love.graphics.setColor(1, 1, 1)
end

function Spaceship:checkKeypress(k)
    if k == 'space' then
        self:shoot()
    end
end

function Spaceship:updateTrail()
    self.trail_timer = self.trail_timer + 1
    if self.trail_timer >= self.trail_rate then
        local trail = {}
        trail.x = self.x
        trail.y = self.y
        trail.life = 0
        trail.lifetime = 30
        trail.radius = 6

        table.insert(self.trail, trail)

        self.trail_timer = 0
    end

    for index, trail in ipairs(self.trail) do
        trail.life = trail.life + 1
        if trail.life > trail.lifetime or trail.radius < 1 then
            table.remove(self.trail, index)
        end

        trail.radius = trail.radius - (trail.life * 0.05)
    end
end

function Spaceship:drawTrail()
    for index, trail in ipairs(self.trail) do
        love.graphics.circle('fill', trail.x, trail.y, trail.radius)
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

    projectile.radius = 3

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
end

function Spaceship:updateProjectiles()
    for index, projectile in ipairs(self.projectiles) do
        projectile.x, projectile.y = projectile.physics.body:getPosition()
        projectile.physics.body:setLinearVelocity(projectile.cos, projectile.sin)

        projectile.life = projectile.life + 1
        
        -- make projectiles dissapear when it collides with an asteroid.
            -- change asteroid removing steps so it can properly be resolved.
            
        if projectile.life < 0 or _G.collisionData ==  then
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