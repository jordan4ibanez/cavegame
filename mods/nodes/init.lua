-- Entry point into what makes up the world.

infdev = infdev or {}

--- Custom node registration.
---@param name string
---@param definition table
function infdev.register_node(name, definition)
	core.register_node(":infdev:" .. name, definition)
end
