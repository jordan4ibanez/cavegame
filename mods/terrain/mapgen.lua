print("test")

--- @type number
local chunk_size = core.get_mapgen_chunksize()

local c_dirt = core.get_content_id("infdev:dirt")
local c_stone = core.get_content_id("infdev:stone")
local c_air = core.get_content_id("air")
local c_grass = core.get_content_id("infdev:grass")

--- This is the terrain generation entry point.
---@param minp table
---@param maxp table
---@param blockseed number
core.register_on_generated(function(voxmanip, minp, maxp, blockseed)
	-- print(minp, maxp, blockseed)

	local noise_parameters     = {
		offset = 0,
		scale = 1,
		spread = { x = 200, y = 100, z = 200 },
		seed = tonumber(core.get_mapgen_setting("seed")) or math.random(0, 999999999),
		octaves = 5,
		persist = 0.63,
		lacunarity = 2.0,
	}

	local __constant_area      = {
		x = (maxp.x - minp.x) + 1,
		y = (maxp.y - minp.y) + 1,
		z = (maxp.z - minp.z) + 1
	}

	local __value_noise_map_3d = core.get_value_noise_map(noise_parameters, __constant_area)

	local value_noise_3d       = {}

	__value_noise_map_3d:get_3d_map_flat(minp, value_noise_3d)

	--- @type number, number
	local emin, emax = voxmanip:get_emerged_area()

	local data = {}

	voxmanip:get_data(data)

	local area = VoxelArea:new({ MinEdge = emin, MaxEdge = emax })

	local index = 1

	-- Use the much faster flat iterator.
	-- Utilize cpu cache linearly.
	-- Important note: z,y,x
	for i in area:iterp(minp, maxp) do
		local pos = area:position(i)

		--- Overworld terrain is shifted up to allow mountains to go into the clouds.
		if (pos.y >= 0 and pos.y <= 160) then
			data[i] = c_dirt
		end


		if value_noise_3d[index] > 0.1 then
			data[i] = c_dirt
		else
			-- This puts grass on top
			pos.y = pos.y - 1
			local below_index = area:indexp(pos)

			if data[below_index] == c_dirt then
				data[below_index] = c_grass
			end
		end

		index = index + 1
	end

	voxmanip:set_data(data)
	voxmanip:calc_lighting()
	-- vm:write_to_map()
end)
