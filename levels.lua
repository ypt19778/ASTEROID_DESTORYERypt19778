Level = {}
Level.level = 1
Level.transmit_timer = 0
Level.oneEvent = 1
Level.difficulty = 1

function Level:update()
    if not Powerups.rolled then
        self.level = self.level + 1
        for i, v in ipairs({5, 10, 15, 20}) do
            if self.level == v then
                self.difficulty = self.difficulty + 1
            end
        end
        Powerups:rollCards()
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