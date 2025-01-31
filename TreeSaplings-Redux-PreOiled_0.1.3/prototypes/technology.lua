data:extend({
	{
		type = "technology",
		name = "ammonium-nitrate",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/ammonium-nitrate.png",
		icon_size = 32,
		prerequisites = {"fluid-handling"},
		effects =
		{
		    {
				type = "unlock-recipe",
				recipe = "chemical-plant"
			},
			{
				type = "unlock-recipe",
				recipe = "sapling-grow-bag"
			},
			{
				type = "unlock-recipe",
				recipe = "fertilizer"
			},
			{
				type = "unlock-recipe",
				recipe = "potassium-phosphate"
			},
			{
				type = "unlock-recipe",
				recipe = "nitric-acid"
			},
		},
		unit =
		{
			count = 50,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 20
		}
	},
	{
		type = "technology",
		name = "auto-tree-farming",
		icon = "__TreeSaplings-Redux-PreOiled__/graphics/icons/sapling-grow-bag.png",
		icon_size = 32,
		prerequisites = {"ammonium-nitrate"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "planter"
			},
			{
				type = "unlock-recipe",
				recipe = "grow-sapling"
			}
		},
		unit =
		{
			count = 100,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		}
	}
})