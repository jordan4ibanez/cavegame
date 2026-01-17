-- Ores generated in the world.

infdev = infdev or {}

local stone_disabled = true

function infdev.register_ore(def)
	if (stone_disabled) then
		def.wherein = "air"
	end

	-- Automate cluster scarcity. Typing that 3 times is annoying.
	-- Average distance between ore deposits.
	def.clust_scarcity = math.pow(def.clust_scarcity, 3)

	core.register_ore(def)
end

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:coal",
	wherein        = "infdev:stone",
	clust_scarcity = 10,
	clust_num_ores = 8,
	clust_size     = 3,
	y_max          = 160,
	y_min          = -1023,
})

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:iron",
	wherein        = "infdev:stone",
	clust_scarcity = 10,
	clust_num_ores = 8,
	clust_size     = 3,
	y_max          = 160,
	y_min          = -1023,
})
