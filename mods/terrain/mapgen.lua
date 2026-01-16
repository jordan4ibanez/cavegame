print("test")

local ceil = math.ceil

--- @type number
local chunk_size = core.get_mapgen_chunksize()

local c_dirt = core.get_content_id("infdev:dirt")
local c_stone = core.get_content_id("infdev:stone")
local c_air = core.get_content_id("air")
local c_grass = core.get_content_id("infdev:grass")
local c_water_source = core.get_content_id("infdev:water_source")
local c_sand = core.get_content_id("infdev:sand")

local ocean_level = 60

--- This is the terrain generation entry point.
---@param minp table
---@param maxp table
---@param blockseed number
core.register_on_generated(function(voxmanip, minp, maxp, blockseed)
	-- print(minp, maxp, blockseed)

	local big_cave_noise_parameters          = {
		offset = 0,
		scale = 1,
		spread = { x = 15, y = 15, z = 15 },
		seed = tonumber(core.get_mapgen_setting("seed")) or math.random(0, 999999999),
		octaves = 2,
		persist = 0.01,
		lacunarity = 2.0,
	}

	local small_cave_noise_parameters        = {
		offset = 0,
		scale = 1,
		spread = { x = 7, y = 7, z = 7 },
		seed = tonumber(core.get_mapgen_setting("seed")) or math.random(0, 999999999),
		octaves = 1,
		persist = 0.005,
		lacunarity = 1.5,
	}

	local overworld_terrain_noise_parameters = {
		offset = 0,
		scale = 0.5,
		spread = { x = 250, y = 250, z = 250 },
		seed = tonumber(core.get_mapgen_setting("seed")) or math.random(0, 999999999),
		octaves = 5,
		persist = 0.63,
		lacunarity = 2.0,
	}

	local __constant_area_3d                 = {
		x = (maxp.x - minp.x) + 1,
		y = (maxp.y - minp.y) + 1,
		z = (maxp.z - minp.z) + 1
	}

	local big_cave_noise                     = {}
	local __big_cave_noise_map_3d            = core.get_value_noise_map(big_cave_noise_parameters, __constant_area_3d)
	__big_cave_noise_map_3d:get_3d_map_flat(minp, big_cave_noise)


	local small_cave_noise          = {}
	local __small_cave_noise_map_3d = core.get_value_noise_map(small_cave_noise_parameters, __constant_area_3d)
	__small_cave_noise_map_3d:get_3d_map_flat(minp, small_cave_noise)

	local __constant_area_2d = {
		x = (maxp.x - minp.x) + 1,
		y = (maxp.z - minp.z) + 1
	}


	local overworld_terrain_noise          = {}
	local __overworld_terrain_noise_map_2d = core.get_value_noise_map(overworld_terrain_noise_parameters,
		__constant_area_2d)
	__overworld_terrain_noise_map_2d:get_2d_map_flat({ x = minp.x, y = minp.z }, overworld_terrain_noise)

	--- @type table, table
	local emin, emax = voxmanip:get_emerged_area()

	local data = {}

	voxmanip:get_data(data)

	local area = VoxelArea:new({ MinEdge = emin, MaxEdge = emax })

	local index = 1

	local width = (maxp.x - minp.x) + 1
	local depth = (maxp.z - minp.z) + 1

	-- Use the much faster flat iterator.
	-- Utilize cpu cache linearly. (Or attempt to)
	-- Important note: z,y,x
	for i in area:iterp(minp, maxp) do
		local pos = area:position(i)


		local height_at_xz = 0

		--- Overworld terrain is shifted up to allow mountains to go into the clouds.
		--- The overworld is a 2D height map. It is polled in 3D space.
		if (pos.y >= 0 and pos.y <= 160) then
			-- Zero indices.
			local x_in_data = pos.x - minp.x
			local z_in_data = pos.z - minp.z

			-- Basically shove a 3D space into a 1D space.
			local index_2d = (z_in_data * depth) + x_in_data + 1

			local raw_noise = overworld_terrain_noise[index_2d]

			if (raw_noise == nil) then
				error("terrain generation error at index: " .. tostring(index_2d))
			end

			-- Amplitude in nodes.
			local amplitude = 80
			local base = 80

			height_at_xz = ceil(base + (amplitude * raw_noise))

			local is_sandy = height_at_xz <= ocean_level + 3

			if (pos.y == height_at_xz) then
				data[i] = (is_sandy and c_sand) or c_grass
			elseif (pos.y < height_at_xz and pos.y >= height_at_xz - 2) then
				data[i] = (is_sandy and c_sand) or c_dirt
			elseif (pos.y < height_at_xz) then
				-- TODO: Sandstone calculation?
				data[i] = c_stone
			end

			-- print(raw_noise)

			-- print(value_noise_2d[index_2d])
		end


		-- Cave carving.
		if (pos.y <= 160) then
			local hit = false

			-- Big caves.
			if big_cave_noise[index] > 0.5 then
				data[i] = c_air
				hit = true
			elseif -- Small caves. (Terrain accentuation)
				small_cave_noise[index] > 0.55 then
				data[i] = c_air
				hit = true
			end

			if hit then
				-- Check if dirt so that there isn't a bunch of dirt all over the place on the surface.
				local possible_dirt_index = area:index(pos.x, pos.y - 1, pos.z)

				local grass_check_1 = area:index(pos.x, pos.y + 1, pos.z)
				local grass_check_2 = area:index(pos.x, pos.y + 2, pos.z)

				if data[possible_dirt_index] == c_dirt then
					-- Prevent double grass.
					if data[grass_check_1] ~= c_grass and data[grass_check_2] ~= c_grass then
						data[possible_dirt_index] = c_grass
					end
				end
			end
		end

		-- Water generation.
		-- This is shaky at best and produces weird results along with flooding.
		if (
				pos.y <= ocean_level and
				pos.y >= 0 and
				data[i] == c_air
			) then
			-- Try not to go too deep into a cave.
			-- Don't flood all the above 0 Y caves.
			if (
					pos.y >= height_at_xz - 3 or
					pos.y == ocean_level and height_at_xz < pos.y + 20
				) then
				data[i] = c_water_source
			end
		end


		-- if value_noise_3d[index] > 0.1 then
		-- 	data[i] = c_dirt
		-- else
		-- 	-- This puts grass on top
		-- 	pos.y = pos.y - 1
		-- 	local below_index = area:indexp(pos)

		-- 	if data[below_index] == c_dirt then
		-- 		data[below_index] = c_grass
		-- 	end
		-- end

		index = index + 1
	end

	voxmanip:set_data(data)
	voxmanip:calc_lighting()
	voxmanip:update_liquids()

	-- vm:write_to_map()
end)
