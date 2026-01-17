-- Terrain generation entry point.

core.set_mapgen_setting("mg_name", "singlenode", true)
core.set_mapgen_setting("mg_flags", "nolight", true)

local mod_path = core.get_modpath(core.get_current_modname())

dofile(mod_path .. "/ore.lua")

core.register_mapgen_script(
	mod_path .. "/mapgen.lua"
)
