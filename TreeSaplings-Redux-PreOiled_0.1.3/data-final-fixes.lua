-- Make sure that dead/dry trees only give 2 wood.  There's 1 variant in vanilla that gives 4 for some reason, and I think there's another mod that may inadvertently be modifying them to 4 as well.
local dead_or_dry_wood_count = 2
for _, tree in pairs(data.raw["tree"]) do
	if (tree.name:find("dead") or tree.name:find("dry")) and tree.minable.result == "wood" and tree.minable.count ~= dead_or_dry_wood_count then
		tree.minable.count = dead_or_dry_wood_count
		if tree.order:find("dry") then tree.order = "a[tree]-b[dead-tree]" end
	end
end

-- Support for "Restrictions on Artificial Tiles" mod
if mods["RestrictionsOnArtificialTiles"] then
	RestrictionsOnArtificialTiles.Register_other(data.raw["assembling-machine"]["planter"], "trees")
	RestrictionsOnArtificialTiles.Register_tree(data.raw["simple-entity"]["sapling-placer"])
end