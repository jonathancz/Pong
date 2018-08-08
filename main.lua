--[[
    GD50 2018
    Pong Remake

    pong-0
    "The Day-0 Update"

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

    -- paddle positions on the Y axis (they can only move up or down)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

	-- velocity and position variables for our ball when play starts
	ballX = VIRTUAL_WIDTH / 2 - 2
	ballY = VIRTUAL_HEIGHT / 2 - 2

	-- math.random returns a random value between the left and right number
	ballDX = math.random(2) == 1 and 100 or -100
	ballDY = math.random(-50, 50)

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
    -- player 1 movement
    if love.keyboard.isDown('w') then
        -- add negative paddle speed to current Y scaled by deltaTime
		-- now, we clamp our position between the bounds of the screen
		-- math.max returns the greater of two values; 0 and player Y
		-- will ensure we don't go above it
        player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s') then
        -- add positive paddle speed to current Y scaled by deltaTime
		-- math.min returns the lesser of two values; bottom of the edge minus paddle
		-- and player Y will ensure we don't go below it
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        -- add negative paddle speed to current Y scaled by deltaTime
        player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        -- add positive paddle speed to current Y scaled by deltaTime
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

	-- update our ball based on its DX and DY only if we're in play state;
	-- scale the velocity by dt so movement is framerate-independet
	if gameState == 'play' then
		ballX = ballX + ballDX * dt
		ballY = ballY + ballDY * dt
	end
end

--[[
	Keyboard handling, called by LOVE2D each frame;
	passes in the key we pressed so we can access.
]]

function love.keypressed(key)
	-- keys can be accessed by string name
    if key == 'escape' then
        -- function L�VE gives us to terminate application
        love.event.quit()
    -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
		else
			gameState = 'start'

			-- reinitialize variables
			-- start ball's position in the middle of the screen
			ballX = VIRTUAL_WIDTH / 2 - 2
			ballY = VIRTUAL_HEIGHT / 2 - 2

			-- given ball's x and y velocity a random starting value
			-- the and/or pattern here is Lua's way of accomplising a ternary operation
			-- in other programming languages like C
			ballDX = math.random(2) == 1 and 100 or -100
			ballDY = math.random(-50, 50) * 1.50
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
	-- begin rendering at virtual resolution
	push:apply('start')

	-- clear the screen with a specific colorl in this case, a color similar
	-- to some versions of the original Pong
	-- love.graphics.clear(r, g, b, a)
	-- Wipes entire screen with a color defined by a RGBA set, each component
	-- of which being from 0 to  255
	love.graphics.clear(40, 45, 52, 255)

	--draw welcome text toward the top of the screen
    love.graphics.setFont(smallFont)
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

	-- draw score on the left and right center of the screen
	-- need to switch font to draw before actually printing
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
		VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
		VIRTUAL_HEIGHT / 3)


	--
	-- paddles are simply rectangles we draw on the screen at certain points
	-- as is the ball
	--

	-- render first paddle (left side)
	-- love.graphics.rectangle(mode, x, y, width, height)
	-- Draws a rectangle onto the screen using whichever our active color is
	-- (love.graphics.setColor, which we don't need to use in this particular
	-- project since most everything is white, the default LOVE2D color). mode
	-- can be set to 'fill' or 'line', which result in a filled or outlined 
	-- rectangle, respectively, and the other four parameters are its position 
	-- and size dimensions. This is the cornerstone drawing function of the 
	-- entirety of our Pong implementation!
	love.graphics.rectangle('fill', 10, player1Y, 5, 20)

	-- render second paddle (right side)
	love.graphics.rectangle('fill', VIRTUAL_WIDTH -10, player2Y, 5, 20)

	-- render ball (center... actually just a small square, not a circle)
	love.graphics.rectangle('fill', ballX, ballY, 4, 4)

	-- end rendering at virtual resolution
	push:apply('end')
end