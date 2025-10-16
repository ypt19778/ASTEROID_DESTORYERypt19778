Audio = {}

function Audio:init()
    audio = {
        sounds = {
            explode = love.audio.newSource('audio/asteroid/explode.mp3', 'static'),
        },
        spaceship = {
            shoot = love.audio.newSource('audio/spaceship/fire.mp3', 'static')
        },
    }
end

return Audio