require("technology/warp-technology")
require("sound/sound")

function recipe_item_entity_extend(entity)
	local recipe = table.deepcopy(data.raw.recipe["nuclear-reactor"])
	recipe.enabled = false
	recipe.name = entity.name
	recipe.ingredients = {{"steel-plate",1}}
	recipe.result = entity.name
	
	local item = table.deepcopy(data.raw.item["nuclear-reactor"])
	item.name = entity.name
	item.place_result = entity.name	
	
	data:extend{item,recipe,entity}
end


-- Warp reactor fuel definition
data:extend(
{
  {
    type = "fuel-category",
    name = "warp"
  },
  {
    type = "item",
    name = "warp-reactor-fuel-cell",
    --icon = "__base__/graphics/icons/uranium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "r[uranium-processing]-a[uranium-fuel-cell]",
    fuel_category = "warp",
    burnt_result = "uranium-fuel-cell",
    fuel_value = "4GJ",
    stack_size = 50,
	icons= {
		{
		  icon="__base__/graphics/icons/uranium-fuel-cell.png",
		  tint={r=1,g=0,b=0.1,a=0.8}
		},
	},
  },
})

local recipe = table.deepcopy(data.raw.recipe["uranium-fuel-cell"])
recipe.enabled = false
recipe.name = "warp-reactor-fuel-cell"
recipe.result = "warp-reactor-fuel-cell"

data:extend{recipe}


-- Warp reactor definition
local entity = table.deepcopy(data.raw.reactor["nuclear-reactor"])
entity.name = "warp-reactor"
entity.light = {intensity = 10, size = 9.9, shift = {0.0, 0.0}, color = {r = 1.0, g = 0.0, b = 0.0}}
entity.working_light_picture.filename = "__base__/graphics/entity/nuclear-reactor/reactor-lights-grayscale.png"
entity.working_light_picture.hr_version.filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-lights-grayscale.png"
entity.working_light_picture.tint = {r = 1, g = 0.4, b = 0.4, a = 1}
entity.working_light_picture.hr_version.tint = {r = 1, g = 0.4, b = 0.4, a = 1}
entity.picture.layers[1].tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.picture.layers[1].hr_version.tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.energy_source.fuel_category = "warp"
entity.consumption = "20MW"
entity.neighbour_bonus = 6
entity.max_health = 5000
entity.heat_buffer.specific_heat = "1MJ"

recipe_item_entity_extend(entity)


--warp reactor stabilizer accumulator definition
local entity = table.deepcopy(data.raw.accumulator["accumulator"])
entity.name = "warp-stab-accu-1"
entity.picture.layers[1].tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.picture.layers[1].hr_version.tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.energy_source =
{
  type = "electric",
  buffer_capacity = "1GJ",
  usage_priority = "tertiary",
  input_flow_limit = "2000kW",
  output_flow_limit = "0kW",
  emissions_per_minute = 5
}

recipe_item_entity_extend(entity)

local entity = table.deepcopy(data.raw.accumulator["warp-stab-accu-1"])	
entity.name = "warp-stab-accu-2"
entity.energy_source.buffer_capacity = "10GJ"
entity.energy_source.input_flow_limit = "20000kW"

recipe_item_entity_extend(entity)

local entity = table.deepcopy(data.raw.accumulator["warp-stab-accu-1"])	
entity.name = "warp-stab-accu-3"
entity.energy_source.buffer_capacity = "100GJ"
entity.energy_source.input_flow_limit = "200000kW"

recipe_item_entity_extend(entity)


--warp reactor teleporter definition
local entity = {}
entity.name = "warp-teleporter-1"
entity.type = "accumulator"
entity.collision_box = {{-1.01, -1.01}, {1.01, 1.01}}
entity.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}

entity.picture = 
  {
    layers =
    {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
		  tint = {r = 0.6, g = 0.6, b = 1, a = 0.6},
          width = 98,
          height = 87,
          frame_count = 33,
          line_length = 11,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 1.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab.png",
			tint = {r = 0.6, g = 0.6, b = 1, a = 0.6},
            width = 194,
            height = 174,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-shadow.png",
          width = 122,
          height = 68,
          frame_count = 1,
          line_length = 1,
          repeat_count = 33,
          animation_speed = 1 / 3,
          shift = util.by_pixel(13, 11),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true
          }
        },	
        {
          filename = "__base__/graphics/entity/lab/lab-integration.png",
          width = 122,
          height = 81,
          frame_count = 1,
          line_length = 1,
          repeat_count = 33,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 15.5),
          hr_version =
          {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
          }
        },		

    }
  } 
entity.charge_cooldown = 30
entity.charge_light = {intensity = 0.3, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}}
entity.discharge_cooldown = 60
entity.discharge_light = {intensity = 0.7, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}}
entity.vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }

entity.circuit_wire_connection_point = circuit_connector_definitions["accumulator"].points
entity.circuit_connector_sprites = circuit_connector_definitions["accumulator"].sprites
entity.circuit_wire_max_distance = default_circuit_wire_max_distance

entity.default_output_signal = {type = "virtual", name = "signal-A"}

entity.energy_source =
{
  type = "electric",
  buffer_capacity = "2MJ",
  usage_priority = "tertiary",
  input_flow_limit = "200kW",
  output_flow_limit = "200kW"
}
entity.max_health = 500

recipe_item_entity_extend(entity)


----warp reactor lvl 2 teleporter definition
local entity = table.deepcopy(data.raw.accumulator["warp-teleporter-1"])
entity.name = "warp-teleporter-2"
entity.energy_source =
{
  type = "electric",
  buffer_capacity = "4MJ",
  usage_priority = "tertiary",
  input_flow_limit = "2MW",
  output_flow_limit = "2MW"
}

recipe_item_entity_extend(entity)


----warp reactor lvl 3 teleporter definition
local entity = table.deepcopy(data.raw.accumulator["warp-teleporter-1"])
entity.name = "warp-teleporter-3"
entity.energy_source =
{
  type = "electric",
  buffer_capacity = "8MJ",
  usage_priority = "tertiary",
  input_flow_limit = "20MW",
  output_flow_limit = "20MW"
}

recipe_item_entity_extend(entity)


--warp teleporter 1 exit definition
local entity = table.deepcopy(data.raw.accumulator["warp-teleporter-1"])
entity.name = "warp-teleporter-1-exit"
entity.picture.layers[1].tint = {r = 1, g = 0.8, b = 0.8, a = 0.6}
entity.picture.layers[1].hr_version.tint = {r = 1, g = 0.8, b = 0.8, a = 0.6}
entity.minable = {mining_time = 2, result = "warp-teleporter-1-exit"}

local recipe = table.deepcopy(data.raw.recipe["warp-stab-accu-1"])
recipe.name = "warp-teleporter-1-exit"
local item = table.deepcopy(data.raw.item["lab"])
item.name = "warp-teleporter-1-exit"
item.place_result = "warp-teleporter-1-exit"
item.icons= {
   {
      icon="__base__/graphics/icons/lab.png",
      tint={r = 1, g = 0.6, b = 0.6, a = 0.6}
   }
}

data:extend{item,recipe,entity}


--warp teleporter 2 exit definition
local entity = table.deepcopy(data.raw.accumulator["warp-teleporter-1-exit"])
entity.name = "warp-teleporter-2-exit"
entity.energy_source = table.deepcopy(data.raw.accumulator["warp-teleporter-2"].energy_source)
 
recipe_item_entity_extend(entity)


--warp teleporter 3 exit definition
local entity = table.deepcopy(data.raw.accumulator["warp-teleporter-1-exit"])
entity.name = "warp-teleporter-3-exit"
entity.energy_source = table.deepcopy(data.raw.accumulator["warp-teleporter-3"].energy_source)
 
recipe_item_entity_extend(entity)

 
--warp reactor platform tile definition
local warp_tile = table.deepcopy(data.raw.tile["tutorial-grid"])
warp_tile.name = "warp-tile"
warp_tile.tint = {r = 0.6, g = 0.6, b = 0.7, a = 1}
warp_tile.decorative_removal_probability = 1
warp_tile.walking_speed_modifier = 1.6

data:extend{warp_tile}


--logistic pipe defenition
local entity = table.deepcopy(data.raw["pipe-to-ground"]["pipe-to-ground"])
entity.name = "logistic-pipe"
entity.pictures.left.tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.pictures.left.hr_version.tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.pictures.right.tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.pictures.right.hr_version.tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.fluid_box.base_area = 50
entity.fluid_box.pipe_connections[2].max_underground_distance = 1

recipe_item_entity_extend(entity)


--underground-entrance lvl 1
local entity = table.deepcopy(data.raw.accumulator["warp-teleporter-1"])
entity.name = "underground-entrance-1"
entity.picture = 
  {
      layers =
      {
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-base.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace.png",
            priority = "high",
            width = 239,
            height = 219,
            frame_count = 1,
            shift = util.by_pixel(0.75, 5.75),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
            priority = "high",
            width = 227,
            height = 171,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(11.25, 7.75),
            scale = 0.5
          }
        }
      }
  } 
entity.picture.layers[1].tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.picture.layers[1].hr_version.tint = {r = 0.8, g = 0.8, b = 1, a = 1}
entity.energy_source =
{
  type = "electric",
  buffer_capacity = "2MJ",
  usage_priority = "tertiary",
  input_flow_limit = "5MW",
  output_flow_limit = "5MW"
}

recipe_item_entity_extend(entity)


--underground-entrance lvl 2
local entity = table.deepcopy(data.raw.accumulator["underground-entrance-1"])
entity.name = "underground-entrance-2"

entity.energy_source =
{
  type = "electric",
  buffer_capacity = "10MJ",
  usage_priority = "tertiary",
  input_flow_limit = "500MW",
  output_flow_limit = "500MW"
}

recipe_item_entity_extend(entity)


--underground-entrance lvl 3
local entity = table.deepcopy(data.raw.accumulator["underground-entrance-1"])
entity.name = "underground-entrance-3"

entity.energy_source =
{
  type = "electric",
  buffer_capacity = "50MJ",
  usage_priority = "tertiary",
  input_flow_limit = "50GW",
  output_flow_limit = "50GW"
}

recipe_item_entity_extend(entity)


--warp beacon
local entity = table.deepcopy(data.raw.beacon["beacon"])
entity.name = "warp-beacon"
entity.supply_area_distance = 32
entity.module_specification.module_slots = 4
entity.base_picture.tint = {r = 0.5, g = 0.7, b = 1, a = 1}
entity.animation.tint = {r = 1, g = 0.2, b = 0.2, a = 0.8}
entity.allowed_effects = {"consumption", "speed", "pollution", "productivity"}
entity.distribution_effectivity = 1

recipe_item_entity_extend(entity)


--warp accelerator
local entity = table.deepcopy(data.raw.accumulator["accumulator"])
entity.name = "warp-accelerator"
entity.picture.layers[1].tint = {r = 1, g = 0.8, b = 0.8, a = 1}
entity.picture.layers[1].hr_version.tint = {r = 1, g = 0.8, b = 0.8, a = 1}
entity.energy_source =
{
  type = "electric",
  buffer_capacity = "5MJ",
  usage_priority = "tertiary",
  input_flow_limit = "5GW",
  output_flow_limit = "0GW"
}

recipe_item_entity_extend(entity)


--dummy
local entity = table.deepcopy(data.raw.boiler["boiler"])
entity.name = "dummy"
--entity.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
--entity.selection_box = {{-0.1, -0.1}, {0.1, 0.1}}
entity.max_health = 6000

recipe_item_entity_extend(entity)