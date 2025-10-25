Powerups = {}
Powerups.menu = {done = false}
Powerups.card_sprite = love.graphics.newImage('graphics/sprites/card.png')
Powerups.card_width = Powerups.card_sprite:getWidth()
Powerups.card_height = Powerups.card_sprite:getHeight()
Powerups.card_rotation = 1
Powerups.spin_timer = 0
Powerups.card_types = {
    'less cooldown',
    'add shield'
}
Powerups.cards = {}
Powerups.buttons = {
    {x = window_width - 100, y = window_height - 100, width = 100, height = 50, text = 'exit'}
}
Powerups.rolled = false

function Powerups:setSpaceship(spaceship)
    self.spaceship = spaceship
end

function Powerups:rollCards()
    local random_cards = {math.random(#self.card_types), math.random(#self.card_types), math.random(#self.card_types)}
    local start_location_x = 100
    local start_location_y = 300
    self.card_rotation = 0
    for i = 0, 2 do
        local new_card = {}
        new_card.width = self.card_width * (game.scale * 10)
        new_card.height = self.card_height * (game.scale * 10)
        new_card.x = (start_location_x * (i + 2) + 125 * i) - new_card.width / 2
        new_card.y = start_location_y - new_card.height / 2
        new_card.powerup = self.card_types[random_cards[i + 1]]
        table.insert(self.cards, new_card)
        --print('inserted new card to cards. Card:'..self.cards[i + 1].powerup)
    end

    --{x = start_location_x, y = start_location_y, width = self.card_width, height = self.card_height, powerup = self.card_types[random_cards[1]]},
    --{x = start_location_x * 3, y = start_location_y, width = self.card_width, height = self.card_height, powerup = self.card_types[random_cards[2]]},
    --{x = start_location_x * 5, y = start_location_y, width = self.card_width, height = self.card_height, powerup = self.card_types[random_cards[3]]}
    self.rolled = true
end

function Powerups:display()
    --[[
    self.spin_timer = self.spin_timer + 1
    if self.spin_timer < 105 then
        self.card_rotation = self.card_rotation + 0.02
    end
    ]]
    for _, card in ipairs(self.cards) do
        love.graphics.draw(self.card_sprite, card.x, card.y, self.card_rotation, game.scale * 10)
        love.graphics.print('choose your card.', game.font, 300, 75, nil, 1.2)
        love.graphics.print(card.powerup, game.font, card.x + (#card.powerup * 1.3) + 8, card.y + card.width / 2)
        love.graphics.print(self.card_rotation)
    end
    for _, button in ipairs(self.buttons) do
        love.graphics.print(button.text, game.font, button.x + (button.height / 3), button.y + (button.height / 2))
        love.graphics.rectangle('line', button.x, button.y, button.width, button.height)
    end
end

function Powerups:checkMousepress(x, y, MB)
    local mouse_loc = {x = x, y = y, width = 1, height = 1}
    if MB == 1 then
        for _, card in ipairs(self.cards) do
            if checkOverlap(mouse_loc, card) then
                print("mouse overlap true"..card.powerup)
                if card.powerup == 'less cooldown' then
                    self.spaceship.fireRate = self.spaceship.fireRate + (self.spaceship.fireRate * (1/10))
                    print('spaceship firerate changed to'..self.spaceship.fireRate)
                elseif card.powerup == 'add shield' then
                    self.spaceship.shields = (self.spaceship.shields) + 1
                    print('added a shield'..self.spaceship.shields)
                end
                self.menu.done = true
                break
            else
                print('mouse overlap false'..card.powerup)
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