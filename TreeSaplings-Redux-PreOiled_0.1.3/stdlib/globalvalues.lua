-- These aren't "user friendly" config options.  Unless you know what you are doing and are purposefully changing the way some of this works, I advise not making changes in here.

local globalvalues = {
	min_grow_time = settings.startup["treesaplingsredux_minimumgrowtime"].value,
	max_grow_time = settings.startup["treesaplingsredux_maximumgrowtime"].value,
	update_interval = settings.startup["treesaplingsredux_updateinterval"].value,
	ups_friendly = settings.startup["treesaplingsredux_upsfriendlyplanters"].value,
	planter_animation_frame_count = 9, -- default setup is 1 frame with planted seed, then 8 frames of the various sapling growth stages, 2 frames per stage (so each stage lasts twice as long as it took for the seed to bust out of the ground)
	frames_with_sapling = 8,
	frames_as_planted_seed = 1,
	sapling_stages = 5 -- (planted-seed, sprout, seedling, sapling, young tree)
}

if globalvalues.ups_friendly then
	globalvalues.planter_grow_time = ((globalvalues.min_grow_time + globalvalues.max_grow_time) / 2) * 60
	globalvalues.planter_animation_speed = (1 / (globalvalues.planter_grow_time * 60)) * globalvalues.planter_animation_frame_count * 2 -- Animation speed is not 1 frame per tick like the wiki says, so requires an additional *2: https://forums.factorio.com/viewtopic.php?p=567908#p567908
else
	globalvalues.planter_grow_time = globalvalues.max_grow_time * 60 + 1 + (math.ceil(globalvalues.update_interval / 60) * 2)
end

local sapling_names = {}
for i = 1, globalvalues.sapling_stages do
	sapling_names[i] = "sapling-stage-" .. i
end
globalvalues.sapling_names = sapling_names

return globalvalues