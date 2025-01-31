data:extend({
	{
		type = "int-setting",
		name = "treesaplingsredux_minimumgrowtime",
		description = "treesaplingsredux_minimumgrowtime",
		setting_type = "startup",
		default_value = 14, -- in minutes
		minimum_value = 1,
		order = "a-a"
	},
	{
		type = "int-setting",
		name = "treesaplingsredux_maximumgrowtime",
		description = "treesaplingsredux_maximumgrowtime",
		setting_type = "startup",
		default_value = 21, -- in minutes
		minimum_value = 1,
		order = "a-b"
	},
	{
		type = "string-setting",
		name = "treesaplingsredux_placeableoffgrid",
		description = "treesaplingsredux_placeableoffgrid",
		setting_type = "startup",
		default_value = "no_snap",
		allow_blank = false,
		allowed_values = {"no_snap", "snap_tile_center", "snap_grid"},
		order = "b"
	},
	{
		type = "bool-setting",
		name = "treesaplingsredux_upsfriendlyplanters",
		description = "treesaplingsredux_upsfriendlyplanters",
		setting_type = "startup",
		default_value = false,
		-- hidden = true,
		-- forced_value = false,
		order = "c"
	},
	{
		type = "int-setting",
		name = "treesaplingsredux_updateinterval",
		description = "treesaplingsredux_updateinterval",
		setting_type = "startup",
		default_value = 300, -- spread over 5 seconds
		minimum_value = 60, -- spread over 60 ticks (1 second)
		maximum_value = 3600, -- spread over 1 minute
		order = "d"
	}
})