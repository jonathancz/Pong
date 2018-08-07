--[[
    GD50 2018
    Pong Remake

    pong-0
    "The Day-0 Update"

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

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

	-- more "retro-looking" font object we can use for any text
	smallFont = love.graphics.newFont('font.ttf' , 8)

	-- set LOVE2D's active font to the smallFont object
	love.graphics.setFont(smallFont)

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT {
		fullscreen = false,
		resizable = false,
		vsync = true
	})
})
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
	love.graphics.printf(
		'Hello Pong!',  		--text to render
		0,						-- starting X (0 since we're going to center it based on width)
		WINDOW_HEIGHT / 2 - 6,   -- starting Y (halfway down the screen)
		WINDOW_WIDTH,
		'center')
end