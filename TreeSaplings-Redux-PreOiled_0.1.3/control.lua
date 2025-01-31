local globalvalues = require("stdlib/globalvalues")
local next = next -- https://stackoverflow.com/a/1252776/8909564
if script.active_mods["gvv"] then require("__gvv__.gvv")() end

-- global vars locally to this file that do not need to persist between save/load cycles
local removingSapling = false -- avoids repeat recursive function calls during a removeSapling() call that could result in errors or an infinite loop

local function saplingGrowTime(offset) -- offset is optional.  Used primarily for migration from previous mod iterations and any orphaned saplings that have a planter at their location (syncing their growth stage to the planter's crafting progress)
	local grow_time = math.floor(((math.random() * (globalvalues.max_grow_time - globalvalues.min_grow_time)) + globalvalues.min_grow_time) * 3600)

	-- Calculate the grow times of the different growth stages.  These need to be calculated now in case there's a planter involved that'll alter the grow_time
	local planted_seed_stage = globalvalues.frames_as_planted_seed / globalvalues.planter_animation_frame_count
	local grow_times = {grow_time * planted_seed_stage}
	for i = 1, globalvalues.sapling_stages - 1 do
		grow_times[i] = math.floor((grow_time * (planted_seed_stage + (((i - 1) * globalvalues.frames_with_sapling / (globalvalues.sapling_stages - 1)) / globalvalues.planter_animation_frame_count))) + 0.5)
	end
	grow_times[#grow_times + 1] = grow_time

	if offset then
		for i = 1, globalvalues.sapling_stages do
			grow_times[i] = grow_times[i] - math.floor((offset * globalvalues.planter_grow_time * 60) + 0.5)
		end
		if grow_times[globalvalues.sapling_stages] < 1 then grow_times[globalvalues.sapling_stages] = 1 end
	end

	-- Finally, add the current game tick to the times
	local game_tick = game.tick
	for i = 1, globalvalues.sapling_stages do
		if grow_times[i] > 0 then
			grow_times[i] = grow_times[i] + game_tick
			if grow_times[i] >= 2^32 then -- If it's greater than 2^32, manually roll it over
				grow_times[i] = grow_times[i] - 2^32
			end
		end
	end

	return grow_times
end

local function getSaplingAtTick(sapling_entity, stage_tick)
	for i, sapling in pairs(storage.saplings[stage_tick]) do
		if sapling.entity == sapling_entity then return i, sapling end
	end
	return nil, nil
end

local function getSapling(sapling_entity)
	for _, saplings in pairs(storage.saplings) do
		for i, sapling in pairs(saplings) do
			if sapling.entity == sapling_entity then return i, sapling end
		end
	end
	return nil, nil
end

local function addSapling(grow_times, sapling_entity, planter_entity_id)
	local sapling = {}
	for i = 1, globalvalues.sapling_stages do
		if grow_times[i] >= 0 then
			sapling = {grow_times = grow_times, stage = i, entity = sapling_entity, planter = planter_entity_id}
			break
		end
	end

	local stage_tick = grow_times[sapling.stage]

	if planter_entity_id then storage.planters[planter_entity_id].sapling = {stage_tick = stage_tick, entity = sapling_entity} end
	if not storage.saplings[stage_tick] then storage.saplings[stage_tick] = {} end
	table.insert(storage.saplings[stage_tick], sapling)
end

local function addPlanter(planter_entity)
	local planter = {entity = planter_entity, unit_number = planter_entity.unit_number}
	storage.planters[planter.unit_number] = planter
	storage.planters_count = storage.planters_count + 1
	storage.planter_index = nil
end

local function removeSapling(sapling, index)
	if removingSapling or not sapling then return end
	if sapling.planter then
		local planter = storage.planters[sapling.planter]
		planter.sapling = nil
		if planter.entity.valid then -- typically should only trigger if the sapling was removed (like by a bot) from a working planter
			planter.entity.crafting_progress = 0.0
		end
	end
	if sapling.entity.valid then
		removingSapling = true
		sapling.entity.destroy{raise_destroy = true}
		removingSapling = false
	end
	storage.saplings[sapling.grow_times[sapling.stage]][index] = nil
	if next(storage.saplings[sapling.grow_times[sapling.stage]]) == nil then storage.saplings[sapling.grow_times[sapling.stage]] = nil end
end

local function removePlanter(planter)
	if not planter then return end
	if planter.sapling then
		local i, sapling = getSaplingAtTick(planter.sapling.entity, planter.sapling.stage_tick)
		sapling.planter = nil
	end
	storage.planters[planter.unit_number] = nil
	storage.planters_count = storage.planters_count - 1
end

local function Init()
	storage.saplings = {}
	storage.planters = {}
	storage.planters_count = 0
	storage.upsfriendly = globalvalues.ups_friendly
	storage.update_remainder = 0
end

local function getNewSaplingName(stage)
	local storagetype = "sapling-stage-" .. stage
	if stage == globalvalues.sapling_stages then
		local selection = math.random(6)
		if selection == 6 then
			storagetype = storagetype .. "-02-red"
		else
			storagetype = storagetype .. "-0" .. selection
		end
	end
	return storagetype
end

local function ConfigChanged(event)
	if event.mod_changes then
		if event.mod_changes["treeSaplings-Revisted"] or event.mod_changes["treeSaplings-Revisted-RevivePatch"] then
			local found_planters = game.surfaces[1].find_entities_filtered{type = "assembling-machine", name = "planter"}
			for _, planter_entity in pairs(found_planters) do
				if not planter_entity.get_recipe() then
					planter_entity.surface.create_entity{name = "planter", position = planter_entity.position, force = planter_entity.last_user.force, fast_replace = true, player = planter_entity.last_user, raise_built = true, create_build_effect_smoke = false}
					planter_entity.destroy{raise_destroy = true}
				else
					addPlanter(planter_entity)
				end
			end
			local found_saplings = game.surfaces[1].find_entities_filtered{type = "storage", name = "sapling-stage-1"}
			for _, sapling_entity in pairs(found_saplings) do
				local planter_entity = sapling_entity.surface.find_entity("planter", sapling_entity.position)
				if planter_entity then
					if not globalvalues.ups_friendly then
						local grow_times = saplingGrowTime(planter_entity.crafting_progress)
						for i, grow_time in ipairs(grow_times) do
							if grow_time >= 0 then
								if i > 1 then
									sapling_entity.destroy{raise_destroy = true}
									sapling_entity = planter_entity.surface.create_entity{name = getNewSaplingName(i), position = {x = planter_entity.position.x, y = planter_entity.position.y + 0.01}, raise_built = true}
								end
								addSapling(grow_times, sapling_entity, planter_entity.unit_number)
								break
							end
						end
					else
						sapling_entity.destroy{raise_destroy = true}
					end
				else
					local grow_times = saplingGrowTime(math.max(0.001, math.random()))
					for i, grow_time in ipairs(grow_times) do
						if grow_time >= 0 then
							if i > 1 then
								local new_sapling = sapling_entity.surface.create_entity{name = getNewSaplingName(i), position = sapling_entity.position, raise_built = true}
								sapling_entity.destroy{raise_destroy = true}
								sapling_entity = new_sapling
							end
							addSapling(grow_times, sapling_entity)
							break
						end
					end
				end
			end
		elseif event.mod_startup_settings_changed and storage.upsfriendly ~= globalvalues.ups_friendly then
			storage.upsfriendly = globalvalues.ups_friendly
			if globalvalues.ups_friendly then
				for _, saplings in pairs(storage.saplings) do
					for i, sapling in pairs(saplings) do
						if sapling.planter then
							local planter = storage.planters[sapling.planter]
							planter.sapling = nil
							sapling.planter = nil
							removeSapling(sapling, i)
						end
					end
				end
			else
				for unit_number, planter in pairs(storage.planters) do
					if planter.entity.crafting_progress > 0 then
						local grow_times = saplingGrowTime(planter.entity.crafting_progress)
						for i, grow_time in ipairs(grow_times) do
							if grow_time > 0 then
								local sapling_entity = planter.entity.surface.create_entity{name = getNewSaplingName(i), position = {x = planter.entity.position.x, y = planter.entity.position.y + 0.01}, raise_built = true}
								addSapling(grow_times, sapling_entity, unit_number)
								break
							end
						end
					end
				end
			end
		end
	end
	if storage.planter_index then storage.planter_index = nil end
end

local function InternalBuiltEntity(entity)
	if entity.name == "sapling-placer" then
		local sapling_entity = entity.surface.create_entity{name = getNewSaplingName(1), position = entity.position, raise_built = true}
		entity.destroy{}
		addSapling(saplingGrowTime(), sapling_entity)
	elseif entity.name == "planter" then
		addPlanter(entity)
	end
end

local function BuiltEntity(event)
	InternalBuiltEntity(event.entity)
end

local function ScriptBuiltEntity(event)
	InternalBuiltEntity(event.entity)
end

local function MinedEntity(event)
	if event.entity.name:find("sapling%-stage%-") and not removingSapling then
		local i, sapling = getSapling(event.entity)
		removeSapling(sapling, i)
	elseif event.entity.name == "planter" then
		if storage.planters[event.entity.unit_number] and storage.planters[event.entity.unit_number].sapling and event.buffer and event.buffer.get_item_count("sapling-grow-bag") > 0 then
			event.buffer.remove({name="sapling-grow-bag", count = 1})
		end
		removePlanter(storage.planters[event.entity.unit_number])
	end
end

local function planterSaplingDied(planter, sapling)
	-- Reset the crafting progress and determine an amount of wood (if any) to manually insert into the output
	planter.entity.crafting_progress = 0.0
	local sapling_products = sapling.entity.prototype.mineable_properties.products
	if sapling_products.name == "wood" then -- Only wood.  If it died before being "big" enough to yield wood, the grow bag should not be refunded (it's *dead*)
		sapling.entity.mine{inventory = planter.entity.get_output_inventory(), force = true}
	end
	planter.sapling = nil
	sapling.planter = nil
end

local function processPlanter(planter)
	if not planter then -- Err, what?
		return
	elseif not planter.entity.valid then -- Somehow the planter has been removed/destroyed without the table being updated
		removePlanter(planter)
	elseif planter.sapling then -- Planter says it has a sapling
		local i, sapling = getSaplingAtTick(planter.sapling.entity, planter.sapling.stage_tick)
		if not sapling.entity.valid then -- In case the sapling entity has somehow been removed/destroyed without the table being updated
			removeSapling(sapling, i)
		elseif planter.entity.crafting_progress == 0.0 then -- Most likely: planter finished "crafting" the sapling.  Typically this shouldn't happen as the sapling should remove itself before the planter finishes.  At any rate, remove it
			planter.sapling = nil
			sapling.planter = nil
			removeSapling(sapling, i)
		elseif sapling.entity.tree_stage_index == sapling.entity.tree_stage_index_max then -- sapling "died"
			planterSaplingDied(planter, sapling)
			removeSapling(sapling, i)
		end
	elseif not planter.sapling then -- Planter says it doesn't have a sapling
		if planter.entity.crafting_progress > 0 then -- Planter is crafting; create sapling
			local sapling_entity = planter.entity.surface.create_entity{name = "sapling-stage-1", position = {x = planter.entity.position.x, y = planter.entity.position.y + 0.01}, raise_built = true}
			addSapling(saplingGrowTime(), sapling_entity, planter.unit_number)
		end
	end
end

local function processSaplings()
	if storage.saplings[game.tick] then
		local saplings = storage.saplings[game.tick]
		for i, sapling in pairs(saplings) do
			if sapling.entity.valid then
				local treetype = nil
				local stillgrowing = false
				local matured = false
				if sapling.entity.tree_stage_index == sapling.entity.tree_stage_index_max then -- sapling "died"
					if sapling.planter then -- Sapling is in a planter
						planterSaplingDied(storage.planters[sapling.planter], sapling)
					else -- Manually planted sapling
						-- TODO: Need dead sapling variants
						local dead_variants = {"dry-tree", "dead-grey-trunk", "dead-dry-hairy-tree", "dry-hairy-tree"}
						treetype = dead_variants[math.random(1, #dead_variants)]
					end
				else -- It's still alive!
					if sapling.stage < globalvalues.sapling_stages then -- Sapling still growing
						treetype = getNewSaplingName(sapling.stage + 1)
						stillgrowing = true
					else -- Sapling matured
						if sapling.planter then -- Sapling is in a planter
							local planter = storage.planters[sapling.planter]
							planter.entity.crafting_progress = 1.0
							planter.sapling = nil
							sapling.planter = nil
						else -- Manually planted sapling
							treetype = sapling.entity.name:gsub("sapling%-stage%-" .. sapling.stage, "tree")
							matured = true
						end
					end
				end

				if treetype then -- Any case except a sapling in a planter that has reached full maturity
					local new_tree_entity = sapling.entity.surface.create_entity{name = treetype, position = sapling.entity.position, raise_built = true}
					if sapling.entity.tree_stage_index and sapling.entity.tree_stage_index > 1 then
						new_tree_entity.tree_stage_index = math.max(1, math.floor(((sapling.entity.tree_stage_index / sapling.entity.tree_stage_index_max) * new_tree_entity.tree_stage_index_max) + 0.5))
						new_tree_entity.tree_gray_stage_index = math.floor(((sapling.entity.tree_gray_stage_index / sapling.entity.tree_gray_stage_index_max) * new_tree_entity.tree_gray_stage_index_max) + 0.5)
					end
					if matured then
						new_tree_entity.graphics_variation = sapling.entity.graphics_variation
					end

					if stillgrowing then
						local new_grow_times = {}
						for i = 1, #sapling.grow_times do
							new_grow_times[i] = sapling.grow_times[i]
						end
						new_grow_times[sapling.stage] = -1
						addSapling(new_grow_times, new_tree_entity, sapling.planter)
					end
				end

				sapling.planter = nil
			end
			removeSapling(sapling, i)
		end
	end
end

local function onTick_LoopPlantersSaplings(event)
	local update_count = math.floor(storage.planters_count / globalvalues.update_interval)
	storage.update_remainder = storage.update_remainder + (storage.planters_count % globalvalues.update_interval)
	if storage.update_remainder >= globalvalues.update_interval then
		storage.update_remainder = storage.update_remainder - globalvalues.update_interval
		update_count = update_count + 1
	end

	for i = 1, update_count do
		local index = next(storage.planters, storage.planter_index)
		if not index then -- Continue to next valid index if end of table reached (return of nil).  If the contents are small (ie, 1), this will prevent double the interval passing before processing.
			index = next(storage.planters)
		end
		processPlanter(storage.planters[index])
		storage.planter_index = index
	end

	processSaplings()
end

local function onTick_NoLoopPlanters(event)
	processSaplings()
end

script.on_init(Init)
script.on_configuration_changed(ConfigChanged)

script.on_event(defines.events.on_built_entity, BuiltEntity, {{filter = "name", name = "sapling-placer"}, {filter = "name", name = "planter"}})
script.on_event(defines.events.on_robot_built_entity, BuiltEntity, {{filter = "name", name = "sapling-placer"}, {filter = "name", name = "planter"}})
script.on_event(defines.events.script_raised_built, ScriptBuiltEntity, {{filter = "name", name = "sapling-placer"}, {filter = "name", name = "planter"}})
script.on_event(defines.events.script_raised_revive, ScriptBuiltEntity, {{filter = "name", name = "planter"}})

script.on_event(defines.events.on_player_mined_entity, MinedEntity, {{filter = "type", type = "storage"}, {filter = "name", name = "planter"}})
script.on_event(defines.events.on_robot_mined_entity, MinedEntity, {{filter = "type", type = "storage"}, {filter = "name", name = "planter"}})
script.on_event(defines.events.on_entity_died, MinedEntity, {{filter = "type", type = "storage"}, {filter = "name", name = "planter"}})
script.on_event(defines.events.script_raised_destroy, MinedEntity, {{filter = "type", type = "storage"}, {filter = "name", name = "planter"}})

if globalvalues.ups_friendly then
	script.on_event(defines.events.on_tick, onTick_NoLoopPlanters)
else
	script.on_event(defines.events.on_tick, onTick_LoopPlantersSaplings)
end

