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

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:gold",
	wherein        = "infdev:stone",
	clust_scarcity = 14,
	clust_num_ores = 5,
	clust_size     = 3,
	y_max          = -128,
	y_min          = -1023,
})


infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:diamond",
	wherein        = "infdev:stone",
	clust_scarcity = 15,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -256,
	y_min          = -1023,
})

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:ruby",
	wherein        = "infdev:stone",
	clust_scarcity = 18,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -384,
	y_min          = -1023,
})

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:sapphire",
	wherein        = "infdev:stone",
	clust_scarcity = 20,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -448,
	y_min          = -1023,
})

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:emerald",
	wherein        = "infdev:stone",
	clust_scarcity = 22,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -512,
	y_min          = -1023,
})

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:lapis",
	wherein        = "infdev:stone",
	clust_scarcity = 24,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -640,
	y_min          = -1023,
})

infdev.register_ore({
	ore_type       = "scatter",
	ore            = "infdev:moonstone",
	wherein        = "infdev:stone",
	clust_scarcity = 26,
	clust_num_ores = 7,
	clust_size     = 3,
	y_max          = -768,
	y_min          = -1023,
})
