-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

-- Cette ligne permet d'afficher des traces dans la console pendant l'execution
io.stdout:setvbuf("no")

-- Screen définition
success = love.window.setMode(750, 500)
if success then
    screen_width, screen_height = love.graphics.getDimensions()
end

-- Initialize random number
math.randomseed(os.time())

-- Set initial score
player_score = 0
ia_score = 0

-- Definition of pad 1
pad1 = {}
pad1.x = 0
pad1.y = 0
pad1.offset = 20
pad1.width = 50 - 2 * pad1.offset
pad1.height = 150 - 2 * pad1.offset

-- Definition of pad 2
pad2 = {}
pad2.x = 0
pad2.y = 0
pad2.offset = 20
pad2.width = 50 - 2 * pad2.offset
pad2.height = 150 - 2 * pad2.offset

-- Definition of ball
ball = {}
ball.x = 0
ball.y = 0
ball.offset = 15 -- halo width
ball.width = 50 - 2 * ball.offset
ball.height = 50 - 2 * ball.offset

left_edge = pad1.x + pad1.offset

function CenterBall()
    bg_width = bg:getWidth() / 2

    ball.x = screen_width / 2 - (ball.width / 2 + ball.offset)
    ball.y = screen_height / 2 - (ball.height / 2 + ball.offset)
    -- Randomize initial ball velocity
    ball.velocityX = -math.random(-4, 4)
    ball.velocityY = -math.random(-4, 4)

    pad1.y = screen_height / 2 - (pad1.height / 2 + pad1.offset)
    pad2.x = screen_width - pad2.width - 2 * pad2.offset
    pad2.y = screen_height / 2 - (pad2.height / 2 + pad2.offset)
end

function round(num, decimal)
    local mult = 10 ^ (decimal or 0)
    return math.floor(num * mult + 0.5) / mult
end

function BallAcceleration(padY, ballY)
    local padCenter = padY + 75
    local ballCenter = ballY + 25
    local acceleration = round(math.abs(padCenter - ballCenter) * 0.1 / 75, 4)
    ball.velocityX = -(ball.velocityX * (1 + acceleration * 2))
    ball.velocityY = -(ball.velocityY * (1 + acceleration * 2))
end

function love.load()
    -- Initialization of the images
    -- sprites sheet (pads & ball)
    sprites = love.graphics.newImage("images/sprites.png")

    -- background image
    bg = love.graphics.newImage("images/bg.jpg")

    -- pad sprite
    pad1.quad = love.graphics.newQuad(0, 0, 50, 150, sprites)
    pad2.quad = love.graphics.newQuad(50, 0, 100, 150, sprites)
    -- ball sprite
    ball.quad = love.graphics.newQuad(100, 0, 50, 50, sprites)

    -- font initialization
    local Font = love.graphics.newFont("fonts/PixelMaster.ttf", 60)
    love.graphics.setFont(Font)

    CenterBall()
end

function love.update(dt)
    -- Moving the pad 1
    -- Down arrow for downward movement
    if love.keyboard.isDown("down") and pad1.y < screen_height - pad1.height - pad1.offset then
        pad1.y = pad1.y + 4
    end
    -- Up arrow for upward movement
    if love.keyboard.isDown("up") and pad1.y > 0 - pad1.offset then
        pad1.y = pad1.y - 4
    end

    -- Moving the pad 2 by IA
    local ballCenter = ball.y + ball.height / 2
    local pad2Center = pad2.y + pad2.height / 2
    if ballCenter ~= pad2Center then
        if ballCenter < pad2Center and pad2.y > 0 - pad2.offset then
            pad2.y = pad2.y - 4
        end
        if ballCenter > pad2Center and pad2.y < screen_height - pad2.height - pad2.offset then
            pad2.y = pad2.y + 4
        end
    end

    -- Collision of ball with high and low walls
    -- Top wall
    if ball.y + ball.offset < 0 then
        ball.velocityY = -ball.velocityY
    end
    -- Bottom wall
    if ball.y - ball.offset > screen_height - ball.height - 2 * ball.offset then
        ball.velocityY = -ball.velocityY
    end

    --Did the ball reach the left pad
    if ball.x <= left_edge + pad1.width - pad1.offset then
        -- Test if the ball is on the pad or not
        if ball.y + ball.width > pad1.y + pad1.offset and ball.y < pad1.y + pad1.height then
            BallAcceleration(pad1.y, ball.y)
            ball.x = pad1.x + pad1.width + pad1.offset
        end
    end

    --Did the ball reach the right pad
    if ball.x >= pad2.x then
        -- Test if the ball is on the pad or not
        if ball.y + ball.width > pad2.y + pad2.offset and ball.y < pad2.y + pad2.height then
            BallAcceleration(pad2.y, ball.y)
            ball.x = pad2.x + pad2.width - pad2.offset
        end
    end

    -- Did the ball hit the left edge of the screen
    if ball.x + ball.offset < left_edge then
        -- Lost for the left player
        CenterBall()
        ia_score = ia_score + 1
    end

    -- Did the ball hit the right edge of the screen
    if ball.x + ball.width > pad2.x + pad2.width + pad2.offset then
        -- Lost for the right player
        CenterBall()
        player_score = player_score + 1
    end

    ball.x = ball.x + ball.velocityX
    ball.y = ball.y + ball.velocityY
end

function love.draw()
    love.graphics.draw(bg, screen_width / 2 - bg_width, screen_height / 2 - bg_width)
    love.graphics.draw(sprites, pad1.quad, pad1.x, pad1.y)
    love.graphics.draw(sprites, pad2.quad, pad2.x, pad2.y)
    love.graphics.draw(sprites, ball.quad, ball.x, ball.y)

    -- Dessin des score
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local score = player_score .. "    " .. ia_score
    local screen_height = font:getWidth(score)
    love.graphics.print(score, (screen_width / 2) - (screen_height / 2), 5)

    love.graphics.line(25, 0, 25, screen_height)
    love.graphics.line(screen_width - 25, 0, screen_width - 25, screen_height)
    love.graphics.line(0, screen_height / 2, screen_width, screen_height / 2)
end

function love.keypressed()
end
