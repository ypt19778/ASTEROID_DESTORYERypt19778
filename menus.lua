local Menu = {}
Menu.__index = Menu

function Menu.new()
    local instance = setmetatable({}, Menu)
    instance.buttons = {
        {x = 100, y = 100, width = 100, height = 50, text = "start"},
        {x = 100, y = 200, width = 100, height = 50, text = "hiscores"},
        {x = 100, y = 300, width = 100, height = 50, text = "quit"}
    }
    instance.MAXWIDTH, instance.MAXHEIGHT = 200, 100
    instance.MINWIDTH, instance.MINHEIGHT = 100, 50

    instance.tweenspeed = 5
    return instance
end

function Menu:update()
    for num, button in ipairs(self.buttons) do
        --[[
        if checkOverlap(mouse, button) then
            if button.width < self.MAXWIDTH and button.height < self.MAXHEIGHT then
                button.width, button.height = button.width + self.tweenspeed, button.height + self.tweenspeed
            end
        elseif button.width > self.MINWIDTH and button.height > self.MINHEIGHT then
            button.width, button.height = button.width - self.tweenspeed, button.height - self.tweenspeed
        end
        --]]
    end
end

function Menu:draw()
    for num, button in ipairs(self.buttons) do
        love.graphics.print(button.text, button.x + button.width / 2, button.y + button.height / 2, nil, game.scale)
        love.graphics.rectangle('line', button.x, button.y, button.width, button.height)
    end
end

function Menu:checkMousepress(MB)
    for num, button in ipairs(self.buttons) do
        if MB == 1 then
            if checkOverlap(mouse, button) then
                if button.text == 'start' then
                    game.state = 'running'
                elseif button.text == 'quit' then
                    love.event.quit()
                end
            end
        end
    end
end

return Menu