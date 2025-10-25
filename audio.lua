Audio = {}

function Audio:init()
    audio = {
        sounds = {
            explode = love.audio.newSource('audio/asteroid/explode.mp3', 'static'),
        },
        spaceship = {
            shoot = love.audio.newSource('audio/spaceship/fire.mp3', 'static'),
            shield_down = love.audio.newSource('audio/spaceship/shield_down.mp3', 'static')
        },
        asteroid = {
            shield_down = love.audio.newSource('audio/asteroid/shield_down.mp3', 'static'),
        },
        menutheme = love.audio.newSource('audio/main_menu_theme.mp3', 'stream')
    }
    audio.menutheme:setLooping(true)
end

return Audio