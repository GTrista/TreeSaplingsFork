local util = require("util")
local collision_mask_util = require("collision-mask-util")
local globalvalues = require("stdlib/globalvalues")
local sounds = require("__base__/prototypes/entity/sounds")

local leaf_sound = sounds.tree_leaves
local leaf_sound_trigger = {
	{
		type = "play-sound",
		sound = leaf_sound,
		damage_type_filters = "fire"
	}
}

local seed = { -- TODO: want better sprites
	{
		filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/seed/seed-1.png",
		priority = "extra-high",
		width = 5,
		height = 5,
		shift = util.by_pixel(0, 2),
		hr_version = {
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/seed/hr-seed-1.png",
			priority = "extra-high",
			width = 10,
			height = 10,
			shift = util.by_pixel(0, -1),
			scale = 0.5
		}
	},
	{
		filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/seed/seed-2.png",
		priority = "extra-high",
		width = 5,
		height = 5,
		shift = util.by_pixel(0, 2),
		hr_version = {
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/seed/hr-seed-2.png",
			priority = "extra-high",
			width = 10,
			height = 10,
			shift = util.by_pixel(0, -1),
			scale = 0.5
		}
	}
}
local dirt_mound = { -- TODO: want better sprites
	filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/dirt-mound/dirt-mound.png",
	priority = "extra-high",
	width = 32,
	height = 32,
	hr_version = {
		filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/dirt-mound/hr-dirt-mound.png",
		priority = "extra-high",
		width = 64,
		height = 64,
		scale = 0.5
	}
}

local modified_tree_collision_mask = collision_mask_util.get_default_mask("tree")
local remove_index = 0
for k, v in pairs(modified_tree_collision_mask) do
	if v == "player-layer" then
		remove_index = k
		break
	end
end
if remove_index > 0 then table.remove(modified_tree_collision_mask, remove_index) end

local sapling_placer = { -- By having a separate entity for placing, it allows the primary sapling to stay centered in planters, regardless of manual placement settings
	type = "simple-entity",
	name = "sapling-placer",
	flags = {"placeable-neutral"},
	hidden = true,
	icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling.png", -- TODO: different icon?
	icon_size = 32,
	collision_box = {{-0.45, -0.45}, {0.45, 0.45}},
	collision_mask = modified_tree_collision_mask,
	picture = {layers = seed},
	integration_patch = dirt_mound
}
local placeable_option = settings.startup["treesaplingsredux_placeableoffgrid"].value
if placeable_option == "no_snap" then
	sapling_placer.flags[#sapling_placer.flags + 1] = "placeable-off-grid"
elseif placeable_option == "snap_grid" then
	sapling_placer.collision_box = {{-0.55, -0.55}, {0.55, 0.55}} -- Increasing collision box so net square is grater than 1x1 (but less than or equal to 2x2) forces the snap-to feature to treat it as a 2x2 entity, placing it on the grid lines.  Less than or equal to a net 1x1 collision box, and it'll treat it as a 1x1 entity and force the snap-to feature to be center of the tile.
end

local planted_seed = {
	type = "tree",
	name = "sapling-stage-1", -- planted seed
	subgroup = "trees",
	flags = {"placeable-neutral", "placeable-off-grid", "breaths-air"},
	icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling.png", -- TODO: different icon?
	icon_size = 32,
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = "sapling-grow-bag",
		count = 1
	},
	emissions_per_second = {pollution = -0.000001},
	collision_box = {{-0.45, -0.45}, {0.45, 0.45}},
	collision_mask = {layers={water_tile=true, doodad=true, object=true}},
	selection_box = {{-0.45, -0.45}, {0.45, 0.45}},
	subgroup = "trees",
	order = "a[tree]-b[sapling]-a[planted-seed]",
	placeable_by = {item = "sapling-grow-bag", count = 1},
	pictures = seed,
	integration_patch = dirt_mound
}

local sprout = table.deepcopy(planted_seed)
sprout.name = "sapling-stage-2" -- sprout
-- sprout.flags[#sprout.flags + 1] = "hidden"
sprout.icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling.png" -- TODO: different icon?
sprout.max_health = 5
sprout.emissions_per_second = {pollution = -0.00008}
sprout.order = "a[tree]-b[sapling]-b[sprout]"
sprout.RestrictionsOnArtificialTiles_ExcludeFromPlacer = true -- Support for "Restrictions on Artificial Tiles" mod
sprout.pictures = { -- TODO: want better sprites
	{
		filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sprout/sprout-1.png",
		priority = "extra-high",
		width = 18,
		height = 21,
		shift = util.by_pixel(-1, -10),
		hr_version =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sprout/hr-sprout-1.png",
			priority = "extra-high",
			width = 35,
			height = 42,
			shift = util.by_pixel(-1, -10),
			scale = 0.5
		}
	},
	{
		filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sprout/sprout-2.png",
		priority = "extra-high",
		width = 18,
		height = 21,
		shift = util.by_pixel(1, -10),
		hr_version =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sprout/hr-sprout-2.png",
			priority = "extra-high",
			width = 35,
			height = 42,
			shift = util.by_pixel(1, -10),
			scale = 0.5
		}
	}
}

local seedling = table.deepcopy(sprout)
seedling.name = "sapling-stage-3" -- seedling
seedling.minable.mining_particle = "wooden-particle"
seedling.minable.results = {{type="item", name = "wood", amount_min = 0, amount_max = 1}}
--seedling.minable.result = nil
--seedling.minable.count = nil
seedling.minable.mining_trigger = {
	{
		type = "direct",
		action_delivery = {
			{
				type = "instant",
				target_effects = leaf_sound_trigger
			}
		}
	}
}
seedling.icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling.png" -- TODO: different icon?
seedling.max_health = 15
seedling.damaged_trigger_effect = leaf_sound_trigger
seedling.mined_sound = leaf_sound
seedling.emissions_per_second = {pollution = -0.00022}
seedling.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
seedling.collision_mask = nil -- this defaults it
seedling.selection_box = {{-0.45, -0.9}, {0.45, 0.45}}
seedling.drawing_box = {{-0.45, -2.1}, {0.45, 0}}
seedling.order = "a[tree]-b[sapling]-c[seedling]"
seedling.vehicle_impact_sound = {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.25}
seedling.pictures = nil
seedling.variations = { -- TODO: need different sprites
	{
		trunk =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-a-trunk.png",
			flags = {"mipmap"},
			width = 51,
			height = 145,
			scale = 0.35,
			frame_count = 1,
			shift = util.by_pixel(0,-22.4)
		},
		leaves =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-a-leaves.png",
			width = 81,
			height = 93,
			scale = 0.35,
			frame_count = 3,
			shift = util.by_pixel(-0.35,-38.15)
		},
		shadow =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/noshadow.png",
			flags = {"mipmap", "shadow"},
			width = 1,
			height = 1,
			scale = 0.5,
			frame_count = 4,
			shift = {0, 0},
			draw_as_shadow = true,
			disable_shadow_distortion_beginning_at_frame = 0
		},
		leaf_generation =
		{
			type = "create-particle",
			particle_name = "leaf-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 0.5,
			speed_from_center = 0.01
		},
		branch_generation =
		{
			type = "create-particle",
			particle_name = "branch-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 1,
			speed_from_center = 0.01,
			frame_speed = 0.1,
			repeat_count = 5
		}
	},
	{
		trunk =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-b-trunk.png",
			flags = {"mipmap"},
			width = 51,
			height = 145,
			scale = 0.35,
			frame_count = 1,
			shift = util.by_pixel(0,-22.4)
		},
		leaves =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-b-leaves.png",
			width = 81,
			height = 93,
			scale = 0.35,
			frame_count = 3,
			shift = util.by_pixel(-0.35,-38.15)
		},
		shadow =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/noshadow.png",
			flags = {"mipmap", "shadow"},
			width = 1,
			height = 1,
			scale = 0.5,
			frame_count = 4,
			shift = {0, 0},
			draw_as_shadow = true,
			disable_shadow_distortion_beginning_at_frame = 0
		},
		leaf_generation =
		{
			type = "create-particle",
			particle_name = "leaf-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 0.5,
			speed_from_center = 0.01
		},
		branch_generation =
		{
			type = "create-particle",
			particle_name = "branch-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 1,
			speed_from_center = 0.01,
			frame_speed = 0.1,
			repeat_count = 5
		}
	}
}
seedling.colors = { -- TODO: maybe reduce color variations for this stage?
	{r =  81, g = 126, b =  85},
	{r =  81, g = 166, b =  89},
	{r = 101, g = 191, b = 110},
	{r = 147, g = 192, b =  39},
	{r = 162, g = 222, b =  19},
	{r = 201, g = 236, b = 116},
	{r = 179, g = 199, b =  12},
	{r = 181, g = 189, b = 114},
	{r = 179, g = 199, b =  12},
	{r = 200, g = 214, b =  83}
}

local sapling = table.deepcopy(seedling)
sapling.name = "sapling-stage-4" -- sapling
sapling.minable.results = {{type="item", name = "wood", amount_min = 1, amount_max = 2}}
sapling.icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling.png"
sapling.max_health = 25
sapling.emissions_per_second = {pollution = -0.00042}
sapling.collision_box = {{-0.2, -0.2}, {0.2, 0.2}}
sapling.selection_box = {{-0.45, -1.25}, {0.45, 0.3}}
sapling.drawing_box = {{-0.45, -2.1}, {0.45, 0}}
sapling.order = "a[tree]-b[sapling]-d[sapling]"
sapling.integration_patch = nil
sapling.variations = {
	{
		trunk =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-a-trunk.png",
			flags = {"mipmap"},
			width = 51,
			height = 145,
			scale = 0.5,
			frame_count = 1,
			shift = util.by_pixel(0,-32)
		},
		leaves =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-a-leaves.png",
			width = 81,
			height = 93,
			scale = 0.5,
			frame_count = 3,
			shift = util.by_pixel(0.5,-54.5)
		},
		shadow =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/noshadow.png",
			flags = {"mipmap", "shadow"},
			width = 1,
			height = 1,
			scale = 0.5,
			frame_count = 4,
			shift = {0, 0},
			draw_as_shadow = true,
			disable_shadow_distortion_beginning_at_frame = 0
		},
		leaf_generation =
		{
			type = "create-particle",
			particle_name = "leaf-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 0.5,
			speed_from_center = 0.01
		},
		branch_generation =
		{
			type = "create-particle",
			particle_name = "branch-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 1,
			speed_from_center = 0.01,
			frame_speed = 0.1,
			repeat_count = 5
		}
	},
	{
		trunk =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-b-trunk.png",
			flags = {"mipmap"},
			width = 51,
			height = 145,
			scale = 0.5,
			frame_count = 1,
			shift = util.by_pixel(0,-32)
		},
		leaves =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/sapling-b-leaves.png",
			width = 81,
			height = 93,
			scale = 0.5,
			frame_count = 3,
			shift = util.by_pixel(-0.5,-54.5)
		},
		shadow =
		{
			filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/sapling/noshadow.png",
			flags = {"mipmap", "shadow"},
			width = 1,
			height = 1,
			scale = 0.5,
			frame_count = 4,
			shift = {0, 0},
			draw_as_shadow = true,
			disable_shadow_distortion_beginning_at_frame = 0
		},
		leaf_generation =
		{
			type = "create-particle",
			particle_name = "leaf-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 0.5,
			speed_from_center = 0.01
		},
		branch_generation =
		{
			type = "create-particle",
			particle_name = "branch-particle",
			offset_deviation = {{-0.35, -0.35}, {0.35, 0.35}},
			initial_height = 1,
			initial_height_deviation = 1,
			speed_from_center = 0.01,
			frame_speed = 0.1,
			repeat_count = 5
		}
	}
}
sapling.colors = {
	{r =  81, g = 126, b =  85},
	{r =  81, g = 166, b =  89},
	{r = 101, g = 191, b = 110},
	{r = 147, g = 192, b =  39},
	{r = 162, g = 222, b =  19},
	{r = 201, g = 236, b = 116},
	{r = 179, g = 199, b =  12},
	{r = 181, g = 189, b = 114},
	{r = 179, g = 199, b =  12},
	{r = 200, g = 214, b =  83}
}

-- Copy vanilla trees to create "Young" trees
-- TODO: different sprites?
-- TODO: different icons?
local young_trees = {}
for i = 1, 6 do
	local young_tree = {}
	if i == 6 then
		young_tree = table.deepcopy(data.raw.tree["tree-02-red"])
		young_tree.order = "a[tree]-b[sapling]-e[young-tree-02-red]"
	else
		young_tree = table.deepcopy(data.raw.tree["tree-0" .. i])
		young_tree.order = "a[tree]-b[sapling]-e[young-tree-0" .. i .. "]"
	end
	-- replace properties specific to the "young tree"
	young_tree.autoplace = nil
	young_tree.name = young_tree.name:gsub("tree", "sapling-stage-5")
	young_tree.localised_name = {"entity-name.sapling-stage-5"}
--	young_tree.minable.result = nil
--	young_tree.minable.count = nil
	young_tree.minable.results = {{type="item", name = "wood", amount_min = 2, amount_max = 3}}
	young_tree.max_health = 40
	young_tree.emissions_per_second = {pollution = -0.00068}
	young_tree.placeable_by = {item = "sapling-grow-bag", count = 1}
	young_tree.RestrictionsOnArtificialTiles_ExcludeFromPlacer = true -- Support for "Restrictions on Artificial Tiles" mod
	
	-- rescale to 70% of original
	young_tree.collision_box = {{young_tree.collision_box[1][1] * 0.75, young_tree.collision_box[1][2] * 0.75}, {young_tree.collision_box[2][1] * 0.75, young_tree.collision_box[2][2] * 0.75}}
	young_tree.selection_box = {{young_tree.selection_box[1][1] * 0.7, young_tree.selection_box[1][2] * 0.7}, {young_tree.selection_box[2][1] * 0.7, young_tree.selection_box[2][2] * 0.7}}
	for _, variation in pairs(young_tree.variations) do
		for _, component in pairs(variation) do
			if type(component) == "table" then
				component.scale = (component.scale or 1) * 0.7
				if component.shift then
					component.shift = {component.shift[1] * 0.7, component.shift[2] * 0.7}
				end
				if component.hr_version then
					component.hr_version.scale = (component.hr_version.scale or 1) * 0.7
					component.hr_version.shift = {component.hr_version.shift[1] * 0.7, component.hr_version.shift[2] * 0.7}
				end
			end
		end
	end
	-- any variations that have a weight less than 1, halve it so they are less common (typically variations that have less branches or are laying on the ground; shouldn't be impossible, but definitely less likely)
	if young_tree.variation_weights then
		for index, weight in pairs(young_tree.variation_weights) do
			if weight < 1 then
				young_tree.variation_weights[index] = weight / 2
			end
		end
	end
	-- copy and store
	young_trees[i] = table.deepcopy(young_tree)
end

local planter =
{
	type = "assembling-machine",
	name = "planter",
	flags = {"placeable-player", "player-creation"},
	icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/planter.png",
	icon_size = 32,
	max_health = 100,
	minable = {mining_time = 0.5, result = "planter"},
	corpse = "small-remnants",
	collision_box = {{-0.75, -0.75}, {0.75, 0.75}},
	selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
	energy_usage = "1W",
	energy_source =
	{
		type = "void"
	},
	fixed_recipe= "grow-sapling",
	show_recipe_icon = false,
	crafting_categories = {"growing"},
	crafting_speed = 1,
	ingredient_count = 1,
	vehicle_impact_sound = {filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0},
	picture =
	{
		layers =
		{
			{
				filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/planter/planter.png",
				priority = "extra-high",
				width = 64,
				height = 64,
			}
		}
	}
}
if globalvalues.ups_friendly then
	planter.drawing_box = {{-0.5, -2.25},{0.5, 0.6}}
	planter.energy_source.emissions_per_minute = sapling.emissions_per_second * 60 * (globalvalues.frames_with_sapling / globalvalues.planter_animation_frame_count)
	planter.working_visualisations = {
		{
			effect = "none",
			animation = {
				layers = {
					{
						filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/planter/ups_friendly_planter_animation.png",
						priority = "extra-high",
						width = 82,
						height = 122,
						frame_count = globalvalues.planter_animation_frame_count,
						shift = util.by_pixel(0, -20.5),
						animation_speed = globalvalues.planter_animation_speed,
						hr_version = {
							filename = "__TreeSaplings-Redux-PreOiled__/graphics/entities/planter/hr-ups_friendly_planter_animation.png",
							priority = "extra-high",
							width = 163,
							height = 244,
							scale = 0.5,
							frame_count = globalvalues.planter_animation_frame_count,
							shift = util.by_pixel(0, -41),
							animation_speed = globalvalues.planter_animation_speed
						}
					}
				}
			}
		}
	}
end

data:extend({sapling_placer, planted_seed, sprout, seedling, sapling, planter})
data:extend(young_trees)