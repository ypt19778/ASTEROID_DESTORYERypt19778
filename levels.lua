Level = {}
Level.level = 1
Level.transmit_timer = 0
Level.oneEvent = 1

function Level:update()
    print('transitioning to next level...')
    if Level.oneEvent == 1 then
        Level.level = Level.level + 1
        Powerups:rollCards()
        Level.oneEvent = 0
    end
    if Powerups.menu.done == true then
        love.load()
        game.state = 'running'
    end
end

function Level:draw()
    if game.state == 'loading level' then
        Powerups:display()
        love.graphics.setColor(1, 1, 1)
        love.graphics.print('LEVEL: '..Level.level, game.font, window_width / 2 - 150, 10)
    end
end