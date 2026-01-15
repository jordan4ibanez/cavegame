-- Entry point into what makes up the world.

infdev = infdev or {}

--- Custom node registration.
---@param name string
---@param definition table
function infdev.register_node(name, definition)
	core.register_node(":infdev:" .. name, definition)
end

infdev.register_node("stone", {
	tiles = { "default_stone.png" }
})

infdev.register_node("dirt", {
	tiles = { "default_dirt.png" }
})


infdev.register_node("grass", {
	tiles = {
		"default_grass.png",
		"default_dirt.png",
		{
			name = "default_dirt.png^default_grass_side.png",
			tileable_vertical = false
		}
	},
})
