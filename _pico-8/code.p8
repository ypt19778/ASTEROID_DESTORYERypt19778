-- asteroid destroyer for pico-8
-- converted from love2d

-- game state
spaceship = {}
asteroids = {}
bullets = {}
score = 0
lives = 3
game_over = false

function _init()
    -- initialize spaceship
    spaceship.x = 64
    spaceship.y = 64
    spaceship.vx = 0
    spaceship.vy = 0
    spaceship.angle = 0
    spaceship.speed = 1
    spaceship.rotation_speed = 0.015
    spaceship.thrust = 0.3
    spaceship.drag = 0.78
    
    -- initialize asteroids
    for i = 1, 5 do
        add_asteroid()
    end
    
    -- initialize bullets array
    bullets = {}
end

function _update()
	
				score = flr(score)

    if game_over then
        if btnp(❎) then
            _init()
            game_over = false
        end
        return
    end
    
    update_spaceship()
    update_asteroids()
    update_bullets()
    check_collisions()
    
    -- spawn new asteroids if needed
    if #asteroids < 10 then
        add_asteroid()
    end
end

function _draw()
    cls()
    
    draw_spaceship()
    draw_asteroids()
    draw_bullets()
    
    -- draw ui
    print("score: " .. score, 2, 2, 7)
    print("lives: " .. lives, 2, 10, 7)
    
    if game_over then
        print("game over", 50, 60, 7)
        print("press ❎ to restart", 40, 70, 7)
        asteroids = {}
        lives = 3
    end
end

function update_spaceship()
    -- rotation
    if btn(➡️) then
        spaceship.angle -= spaceship.rotation_speed
    end
    if btn(⬅️) then
        spaceship.angle += spaceship.rotation_speed
    end
    
    -- thrust
    if btn(⬆️) then
        spaceship.vx += cos(spaceship.angle) * spaceship.thrust
        spaceship.vy += sin(spaceship.angle) * spaceship.thrust
    end
    
    -- apply drag
    spaceship.vx *= spaceship.drag
    spaceship.vy *= spaceship.drag
    
    -- update position
    spaceship.x += spaceship.vx
    spaceship.y += spaceship.vy
    
    -- wrap around screen
    spaceship.x = mid(0, spaceship.x, 128)
    spaceship.y = mid(0, spaceship.y, 128)
    
    -- shooting
    if btnp(❎) then
        shoot_bullet()
    end
end

function draw_spaceship()
    -- draw spaceship as a triangle
    local center_x = spaceship.x
    local center_y = spaceship.y
    
    -- calculate triangle points (pointing in the direction of spaceship.angle)
    local front_x = center_x + cos(spaceship.angle) * 6
    local front_y = center_y + sin(spaceship.angle) * 6
    
    local left_x = center_x + cos(spaceship.angle + 0.6) * 4
    local left_y = center_y + sin(spaceship.angle + 0.6) * 4
    
    local right_x = center_x + cos(spaceship.angle - 0.6) * 4
    local right_y = center_y + sin(spaceship.angle - 0.6) * 4
    
    -- fill triangle
    line(front_x, front_y, left_x, left_y, 7)
    line(left_x, left_y, right_x, right_y, 7)
    line(right_x, right_y, front_x, front_y, 7)
    
    -- draw engine flame when thrusting
    if btn(⬆️) then
        local flame_x = spaceship.x - cos(spaceship.angle) * 4
        local flame_y = spaceship.y - sin(spaceship.angle) * 4
        pset(flame_x, flame_y, 10)
        pset(flame_x + rnd(3) - 1, flame_y + rnd(3) - 1, 8)
        pset(flame_x + rnd(3) - 1, flame_y + rnd(3) - 1, 9)
        pset(flame_x + rnd(4) - 1, flame_y + rnd(3) - 1, 8)
        pset(flame_x + rnd(4) - 1, flame_y + rnd(3) - 1, 9)
    end
end

function shoot_bullet()
   local bullet = {}
   bullet.x = spaceship.x + cos(spaceship.angle) * 4
   bullet.y = spaceship.y + sin(spaceship.angle) * 4
   bullet.vx = cos(spaceship.angle) * 2
   bullet.vy = sin(spaceship.angle) * 2
   bullet.life = 5
   add(bullets, bullet)
end

function update_bullets()
    for bullet in all(bullets) do
        bullet.x += bullet.vx
        bullet.y += bullet.vy
        bullet.life -= 1
        
        -- remove old bullets
        if bullet.life <= 0 then
            del(bullets, i)
        end
        if bullet.x > 128 or bullet.x < 0 then
        	del(bullets, bullet)
        end
        if bullet.y > 128 or bullet.y < 0 then
        	del(bullets, bullet)
        end
    end
end

function draw_bullets()
    for bullet in all(bullets) do
        pset(bullet.x, bullet.y, 10)
    end
end

function add_asteroid()
    local asteroid = {}
    asteroid.x = rnd(128)
    asteroid.y = rnd(128)
    asteroid.vx = (rnd(2) - 1) * 0.5
    asteroid.vy = (rnd(2) - 1) * 0.5
    asteroid.size = rnd(4) + 2
    asteroid.angle = rnd(1)
    asteroid.rotation_speed = (rnd(2) - 1) * 0.02
    
    asteroid.score = flr(asteroid.size * 10)
    
    add(asteroids, asteroid)
end

function explode_asteroid(x, y)
    local num_asteroids = rnd(3)  -- 3 to 6 asteroids
    
    for i = 1, num_asteroids do
        local asteroid = {}
        asteroid.small = true
        -- spawn near the explosion point with some random offset
        asteroid.x = x + (rnd(16) - 8)
        asteroid.y = y + (rnd(16) - 8)
        -- faster movement for explosion effect
        asteroid.vx = (rnd(2) - 1) * 1.2
        asteroid.vy = (rnd(2) - 1) * 1.2
        -- smaller size for fragments
        asteroid.size = rnd(3) + 1
        asteroid.angle = rnd(1)
        asteroid.rotation_speed = (rnd(2) - 1) * 0.04
        asteroid.score = flr(asteroid.size * 10)
        
        add(asteroids, asteroid)
    end
end

function update_asteroids()
    for asteroid in all(asteroids) do
        asteroid.x += asteroid.vx
        asteroid.y += asteroid.vy
        asteroid.angle += asteroid.rotation_speed

        -- wrap around screen
        asteroid.x = mid(0, asteroid.x, 128)
        asteroid.y = mid(0, asteroid.y, 128)

        if asteroid.size <= 10 then
            del(asteroids, i)
        end
    end
end

function draw_asteroids()
    for asteroid in all(asteroids) do
        -- draw asteroid as a circle
        circ(asteroid.x, asteroid.y, asteroid.size, 5)
        -- draw some detail
        pset(asteroid.x + cos(asteroid.angle) * asteroid.size * 0.7, 
              asteroid.y + sin(asteroid.angle) * asteroid.size * 0.7, 3)
    end
end

function check_collisions()
-- bullet vs asteroid collisions
for index_bul, bullet in ipairs(bullets) do
	for index_ast, asteroid in ipairs(asteroids) do
		local dist = sqrt((asteroid.x - bullet.x)^2 + (asteroid.y - bullet.y)^2)

		if dist < asteroid.size then
			asteroid.size -= 0.5
			
			score += asteroid.score
			
			if not asteroid.small then
				explode_asteroid(asteroid.x, asteroid.y)
			end
		end
	end
end
    
    -- spaceship vs asteroid collisions
    for asteroid in all(asteroids) do
        local dist = sqrt((spaceship.x - asteroid.x)^2 + (spaceship.y - asteroid.y)^2)
        if dist < asteroid.size + 2 then
            -- collision!
            lives -= 1
            if lives <= 0 then
                game_over = true
            else
                -- reset spaceship position
                spaceship.x = 64
                spaceship.y = 64
                spaceship.vx = 0
                spaceship.vy = 0
            end
            break
        end
    end
end