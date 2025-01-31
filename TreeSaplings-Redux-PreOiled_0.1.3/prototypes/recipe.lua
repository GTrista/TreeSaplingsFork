local globalvalues = require("stdlib/globalvalues")

data:extend({
	{
		type = "recipe",
		name = "fertilizer",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/ammonium-nitrate.png",
		icon_size = 32,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="potassium-phosphate", amount=1},
			{type="fluid", name="nitric-acid", amount=10}
		},
		results = {{type="item", name="fertilizer", amount=1}},
		allow_productivity = true,
		energy_required = 5,
		enabled = false
	},
	{
		type = "recipe",
		name = "potassium-phosphate",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/potassium-phosphate.png",
		icon_size = 32,
		category = "chemistry",
		ingredients =
		{
			{type="fluid", name="water", amount=50},
			{type="item", name="stone", amount=5},
			{type="item", name="coal", amount=1}
		},
		results = {{type="item", name="potassium-phosphate", amount=20}},
		allow_productivity = true,
		energy_required = 60,
		enabled = false
	},
	{
		type = "recipe",
		name = "nitric-acid",
		subgroup = "fluid-recipes",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/fluids/nitric-acid.png",
		icon_size = 32,
		category = "chemistry",
		ingredients =
		{
			{type="fluid", name="water", amount=40},
			{type="item", name="wood", amount=1}
		},
		results = {{type="fluid", name="nitric-acid", amount=40}},
		allow_productivity = true,
		energy_required = 20,
		enabled = false
	},
	{
		type = "recipe",
		name = "planter",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/planter.png",
		icon_size = 32,
		category = "crafting",
		ingredients = {{type="item", name="wood", amount=4}},
		results = {{type="item", name="planter", amount=1}},
		enabled = false
	},
	{
		type = "recipe",
		name = "sapling-grow-bag",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling-grow-bag.png",
		icon_size = 32,
		category = "crafting",
		ingredients =
		{
			{type="item", name="wood", amount=1},
			{type="item", name="fertilizer", amount=1}
		},
		results = {{type="item", name="sapling-grow-bag", amount=1}},
		enabled = false
	},
	{
		type = "recipe",
		name = "grow-sapling",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling.png",
		icon_size = 32,
		category = "growing",
		ingredients = {{type="item", name="sapling-grow-bag", amount=1}},
		results = {{type="item", name="wood", amount=4}},
		energy_required = globalvalues.planter_grow_time,
		overload_multiplier = 1,
		enabled = false,
		hidden = true
	}
})