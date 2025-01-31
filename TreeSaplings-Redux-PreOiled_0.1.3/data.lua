if settings.startup["treesaplingsredux_minimumgrowtime"].value > settings.startup["treesaplingsredux_maximumgrowtime"].value then
	settings.startup["treesaplingsredux_maximumgrowtime"].value = settings.startup["treesaplingsredux_minimumgrowtime"].value
end

require("prototypes/category")
require("prototypes/item")
require("prototypes/fluid")
require("prototypes/entity")
require("prototypes/recipe")
require("prototypes/technology")