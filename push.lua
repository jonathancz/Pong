-- push.lua v0.2

local push = {
	defaults = {
		fullscreen = false,
		resizable = false,
		pixelperfect = false,
		highdpi = true,
		canvas = true
	}
}

setmetatable(push, push)

--TODO: rendering resolution?
--TODO: clean up code

function push:applySettings(settings)
	for k, v in pairs(settings) do
		self["_" .. k] = v
	end
end

