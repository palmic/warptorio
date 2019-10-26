data:extend(
{
    {
    type = "technology",
    name = "warp-platform-size-1",
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/concrete.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	 

    unit =
    {
      count = "300",
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 10
    },
    upgrade = true,
    order = "c-k-f-e"
  },  
  {
    type = "technology",
    name = "warp-platform-size-2",
	prerequisites = {"warp-platform-size-1","logistic-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/concrete.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit =
    {
      count = "300",
      ingredients =
      {
        {"automation-science-pack", 1},
		{"logistic-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-f-e"
  },  
    {
    type = "technology",
    name = "warp-platform-size-3",
	prerequisites = {"warp-platform-size-2","chemical-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/concrete.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit =
    {
      count = "500",
      ingredients =
      {
        {"automation-science-pack", 2},
		{"logistic-science-pack", 2},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-f-e"
  },  
    {
    type = "technology",
    name = "warp-platform-size-4",
	prerequisites = {"warp-platform-size-3","production-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/concrete.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit =
    {
      count = "500",
      ingredients =
      {
        {"automation-science-pack", 2},
		{"logistic-science-pack", 2},
		{"chemical-science-pack", 1},
		
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-f-e"
  }, 
  {
    type = "technology",
    name = "warp-platform-size-5",
	prerequisites = {"warp-platform-size-3","utility-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/concrete.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit =
{
    count = "500",
    ingredients =
      {
        {"automation-science-pack", 2},
		{"logistic-science-pack", 2},
		{"chemical-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-f-e"
  },    
  {
    type = "technology",
    name = "warp-stabilizer-accumulator-1",
	prerequisites = {"military-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/electric-energy-acumulators.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit ={
      count = "500",--"100",
      ingredients =
      {
        {"automation-science-pack", 5},
		{"logistic-science-pack", 5},
		{"military-science-pack", 1},
		
      },
      time = 10
    },
    upgrade = true,
    order = "c-k-f-e"
  },
  {
    type = "technology",
    name = "warp-stabilizer-accumulator-2",
	prerequisites = {"warp-stabilizer-accumulator-1","chemical-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/electric-energy-acumulators.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit ={
      count = "500",--"100",
      ingredients =
      {
        {"automation-science-pack", 10},
		{"logistic-science-pack", 10},
		{"military-science-pack", 10},
		{"chemical-science-pack", 1},
		
      },
      time = 10
    },
    upgrade = true,
    order = "c-k-f-e"
  },   
  {
    type = "technology",
    name = "warp-stabilizer-accumulator-3",
	prerequisites = {"warp-stabilizer-accumulator-2","production-science-pack","utility-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/electric-energy-acumulators.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit ={
      count = "500",--"100",
      ingredients =
      {
        {"automation-science-pack", 20},
		{"logistic-science-pack", 20},
		{"military-science-pack", 20},
		{"chemical-science-pack", 10},	
		{"production-science-pack", 1},	
		{"utility-science-pack", 1},	
		
      },
      time = 10
    },
    upgrade = true,
    order = "c-k-f-e"
  },   
  {
    type = "technology",
    name = "warp-teleporter-1",
	prerequisites = {"logistics"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/research-speed.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit ={
      count = "500",
      ingredients =
      {
        {"automation-science-pack", 1},		
      },
      time = 20
    },
    upgrade = true,
    order = "c-k-f-e"
  },  
  {
    type = "technology",
    name = "warp-reactor-logistic-1",
	prerequisites = {"logistics","logistic-science-pack"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/logistics.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit ={
      count = "500",
      ingredients =
      {
        {"automation-science-pack", 5},	
		{"logistic-science-pack", 1},		
      },
      time = 20
    },
    upgrade = true,
    order = "c-k-f-e"
  },    
  {
    type = "technology",
    name = "warp-reactor-logistic-2",
	prerequisites = {"logistics-2","warp-reactor-logistic-1"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/logistics.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit ={
      count = "500",
      ingredients =
      {
        {"automation-science-pack", 200},	
		{"logistic-science-pack", 100},		
      },
      time = 20
    },
    upgrade = true,
    order = "c-k-f-e"
  },    
  {
    type = "technology",
    name = "warp-reactor-logistic-3",
	prerequisites = {"logistics-3","warp-reactor-logistic-2"},
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/logistics.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    unit ={
      count = "300",
      ingredients =
      {
        {"automation-science-pack", 20},	
		{"logistic-science-pack", 10},		
		{"chemical-science-pack", 5},	
		{"production-science-pack", 2},			
      },
      time = 20
    },
    upgrade = true,
    order = "c-k-f-e"
  },    
 {
    type = "technology",
    name = "warp-beacon",
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/effect-transmission.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    prerequisites = {"chemical-science-pack"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 4},
        {"logistic-science-pack", 3},
        {"chemical-science-pack", 2},
      },
      time = 30
    },
    order = "i-i"
  },
  {
    type = "technology",
    name = "warp-accelerator",
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/battery.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    prerequisites = {"chemical-science-pack"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 4},
        {"logistic-science-pack", 3},
        {"chemical-science-pack", 2},
      },
      time = 30
    },
    order = "i-i"
  },
  {
    type = "technology",
    name = "warp-energy",
    icon_size = 128,
	icons= {
		{
		  icon = "__base__/graphics/technology/nuclear-power.png",
		  tint={r = 0.2, g = 0.2, b = 1, a = 0.8}
		},
	},	
    prerequisites = {"laser"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 10
    },
    order = "i-i"
  },  
})