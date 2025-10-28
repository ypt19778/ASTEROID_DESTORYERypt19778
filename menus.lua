local Menu = {}
Menu.__index = Menu

function Menu.new()
    local instance = setmetatable({}, Menu)
    instance.buttons = {
        {x = window_width - window_width + 100, y = 300, width = 100, height = 50, text = "start"},
        {x = window_width - (window_width * (2/3)) + 100, y = 300, width = 100, height = 50, text = "hiscores"},
        {x = window_width - (window_width * (1/3)) + 100, y = 300, width = 100, height = 50, text = "quit"}
    }
    instance.MAXWIDTH, instance.MAXHEIGHT = 200, 100
    instance.MINWIDTH, instance.MINHEIGHT = 100, 50
    instance.title = "Asterzoids"

    instance.tweenspeed = 5
    instance.state = 'main'
    return instance
end

function Menu:update()

end

function Menu:draw()
    if self.state == 'main' then
        love.graphics.print(self.title, game.font, window_width * (1/5), 40, nil, game.scale * 2)
        for num, button in ipairs(self.buttons) do
            love.graphics.print(button.text, game.font, button.x + button.width / 2 - 45, button.y + button.height / 2)
            love.graphics.rectangle('line', button.x, button.y, button.width, button.height)
        end
    elseif self.state == 'hiscores' then
        if love.keyboard.isDown('escape') then
            self.state = 'main'
        end
        love.graphics.setFont(game.font)
        if game.highscores[1] then
            love.graphics.print('HIGHSCORE TO BEAT: '..game.highscores[1].score..", BY: "..game.highscores[1].name..".", 100, 30, nil, 1.2)
        end
        love.graphics.print('press "escape" to go back.', window_width - 350, window_height - 100)
        for i, v in ipairs(game.highscores) do
            love.graphics.print(game.highscores[i].name..".\nscore:"..game.highscores[i].score, 100 * i, 300, nil, 1.1)
        end
    end
end

function Menu:checkMousepress(MB)
    for num, button in ipairs(self.buttons) do
        if MB == 1 then
            if checkOverlap(mouse, button) then
                if button.text == 'start' then
                    audio.menutheme:stop()
                    game.state = 'running'
                elseif button.text == 'quit' then
                    love.event.quit()
                elseif button.text == "hiscores" then
                    self.state = 'hiscores'
                    print(game.highscore)
                end
            end
        end
    end
end

return Menu