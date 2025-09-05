Audio = {}

function Audio:init()
    audio = {
        spaceship = {
            shoot = love.audio.newSource('audio/spaceship/fire.mp3', 'static')
        },

        asteroid = {
            explode = {
                love.audio.newSource('audio/asteroid/explode.mp3', 'static'),
            },
        },
    }
end

return Audio