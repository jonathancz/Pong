--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Ethan Chen


    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]
push = require 'push'

-- the "Class" library we're using will aloow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables
-- methods
Class = require 'class'

-- our Paddle Class, which stores position and dimensions for each paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720 

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in Update
PADDLE_SPEED = 200

--[[
	Runs when the game first starts up, only once; ised to initialize the game
]]

--[[
	love.load()
	- Used to initialized our game state at the very beginning of program execution.

	love.update(dt)
	- Called each frame by LOVE; dt will be the lapsed time in seconds since the last frame, and we can use this to scale any changes in our game
	for even behaviour across frame rates.

	love.draw()
	- Called each frame by LOVE after update for drawing things to the screen once they've changed.

	-- LOVE2D expects these functions to be implemented in main.lua and calls them internally; if we don't
	define them, it will still function, but our game will be fundamentally incomplete, at least if update or draw are
	missing!
]]

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')


	-- math.randomseed(num)
	-- "Seeds" the random number generator used by Lua(math.random)
	-- with some value such that its randomness is dependent on that
	-- supplied value, allowing us to pass in different numbers each 
	-- playthrough to guarantee non-consistency across different program 
	-- executions (or uniforminty if we want consisten behaviour for testing).
	--"seed" the RNG so that calls to random are always random 
	-- use the current time, since that will vary on startup every time

	-- os.time()
	-- Lua function that returns, in seconds, the time since 00:00:00 UTC 
	-- January 1, 1970, also known as Unix epoch time

	-- math.random(min, max)
	-- Returns a random number, dependent on the seeded random number generator,
	-- between min and max, inclusive.
	math.randomseed(os.time())

    -- more "retro-looking" font object we can use for any text
	-- love.graphics.newFont(path, size)
	-- Loads a font file into memory at a specific path, setting 
	-- it to a specific size, and storing it in an object we can 
	-- use to globally change the currently active font that LOVE2D
	-- is using to render text (functioning like a state machine)
    smallFont = love.graphics.newFont('font.ttf', 8)

	-- larger font for drawing the score on the screen
	scoreFont = love.graphics.newFont('font.ttf', 32)

    -- set L�VE2D's active font to the smallFont obect
	-- love.graphics.setFont(font)
	-- Sets LOVE2D's currently active font (of which there can only
	-- be one at a time) to a passed-in-font obhect that we can create
	-- using love.graphics.newFont.
    love.graphics.setFont(smallFont)

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
	
	-- initialize score variables, used for rendering on the screen and keeping
	-- track of the winner
	player1Score = 0
	player2Score = 0

	--initialize our player paddles; make them global so that they can be
	-- detected by other functions and modules
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	-- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	-- game state variable used to transition between different parts of the game
	-- (used for beginning, menus, main game, high score list, etc.)
	-- we will use this to determin behaviour during render and update
	gameState = 'start'
end

--[[
	Runs every frame, with "dt" passed in, our delta in seconds
	since the last frame, which LOVE2D supplies us.
]]
function love.update(dt)
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position of collision
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end
    end

    -- if we reach the left or right edge of the screen, 
    -- go back to start and update the score
    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1
        ball:reset()
        gameState = 'serve'
    end

    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1
        ball:reset()
        gameState = 'serve'
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

--[[
	Keyboard handling, called by LOVE2D each frame;
	passes in the key we pressed so we can access.
]]
function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

--[[
	love.graphics.printf(text, x, y, [width], [align])
	- Versatile print function that can align text left, right, or center on the screen.

	love.window.setMode(width, height, params)
	- Used to initialize the window's dimenstions and to set parameters like vsync, whether we're fullscreen or not,
	and whether the window is resizable after startup. Won't be using past this example in favor of the push virtual resolution library,
	which has its own method like this, but useful to know if encountered in other code.
]]
function love.draw()

    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40, 45, 52, 255)

    love.graphics.setFont(smallFont)

    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    end

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

--[[
	Renders the current FPS
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

--[[
	Simply draws the score to the screen
]]
function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end
