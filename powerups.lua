Powerups = {
    menu = {done = false},
    card_width = 100,
    card_height = 200,
    card_types = {
        'bullet size',
        'new attack',
        'larger asteroids',
    },
    cards = {},
    buttons = {
        {x = window_width - 100, y = window_height - 100, width = 100, height = 50, text = 'exit'},
    }
}

function Powerups:setSpaceship(spaceship)
    self.spaceship = spaceship
end

function Powerups:rollCards()
    local random_cards = {math.random(#Powerups.card_types), math.random(#Powerups.card_types), math.random(#Powerups.card_types)}
    self.cards = {
        {x = 100, y = 100, width = Powerups.card_width, height = Powerups.card_height, powerup = self.card_types[random_cards[1]]},
        {x = 200, y = 100, width = Powerups.card_width, height = Powerups.card_height, powerup = self.card_types[random_cards[2]]},
        {x = 300, y = 100, width = Powerups.card_width, height = Powerups.card_height, powerup = self.card_types[random_cards[3]]}
    }
end

function Powerups:display()
    for _, card in ipairs(self.cards) do
        love.graphics.print(card.powerup, card.x, card.y + 30)
        love.graphics.rectangle('line', card.x, card.y, card.width, card.height)
    end
    for _, button in ipairs(self.buttons) do
        love.graphics.print(button.text, game.font, button.x, button.y)
        love.graphics.rectangle('line', button.x, button.y, button.width, button.height)
    end
end

function Powerups:checkMousepress(x, y, MB)
    local mouse_loc = {x = x, y = y, width = 1, height = 1}
    if MB == 1 then
        for _, card in ipairs(self.cards) do
            if checkOverlap(mouse_loc, card) then
                print(card.powerup)
            else
                print('mouse overlap is false.')
            end
        end
        for _, button in ipairs(self.buttons) do
            if checkOverlap(mouse_loc, button) then
                if button.text == 'exit' then
                    self.menu.done = true
                end
            end
        end
    end
end