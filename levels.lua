Level = {}
Level.level = 1
Level.transmit_timer = 0
Level.oneEvent = 1
Level.difficulty = 1

Level.upgrade_levels = {}
local iteration = 0
repeat
    iteration = iteration + 1
    local num = 6 * iteration
    table.insert(Level.upgrade_levels, num)
until #Level.upgrade_levels > 10

function Level:update()
    if not Powerups.rolled then
        self.level = self.level + 1

        for i, v in ipairs(self.upgrade_levels) do -- max difficulty = 9
            if self.level == v then
                self.difficulty = self.difficulty + 1
            end
        end
        Powerups:rollCards()
    end
    if Powerups.menu.done == true then
        game.alien_spawnchance = game.alien_spawnchance - (self.difficulty * 10)
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