-- Copied from https://forums.factorio.com/viewtopic.php?f=25&t=61822&p=374178
-- Credit to TheSAguy
function allow_productivity(recipe_name)
  if data.raw.recipe[recipe_name] then
    for i, module in pairs(data.raw.module) do
      if module.limitation and module.effect.productivity then
        table.insert(module.limitation, recipe_name)
      end
    end
  end
end

allow_productivity("ammonia")
allow_productivity("nitric-acid")
allow_productivity("ammonium-nitrate")
