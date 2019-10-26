--****

local mod_gui = require("mod-gui")
local util = require("util")


--local warp_charge_time_lengthening = settings.global['warptorio_warp_charge_time_lengthening'].value --in seconds
--local warp_charge_time_at_start = settings.global['warptorio_warp_charge_time_at_start'].value --in seconds
local warp_polution_factor = settings.global['warptorio_warp_polution_factor'].value
local warp_charge_factor = settings.global['warptorio_warp_charge_factor'].value
local warp_base_expansion_cooldown = 1000 * 60
local warp_teleporter_per_item_joule_cost = 2000
local warp_teleporter_per_fluid_joule_cost = 400

local warp_module_size = 16

local warp_transport = {
	transfert_type = "in_and_out",
	reference = nil,
	name = nil,
	entities = {
		chest_1 = nil,
		chest_2 = nil,
		loader_1 = nil,
		loader_2 = nil,
		pipe_1 = nil,
		pipe_2 = nil,
		pipe_3 = nil,
		pipe_4 = nil,
		pipe_5 = nil,
		pipe_6 = nil,
	}
}

local underground_level_table = {
	surface = nil,
	size,
	upstairs = table.deepcopy(warp_transport),
	downstairs = table.deepcopy(warp_transport),
	upgrade_level = 0,
}
	
local function init_globals()
	global.warp_platform_pos = {x=-warp_module_size/2,y=-warp_module_size/2}
	global.warpzone_n = 0
	global.current_surface = "nauvis"
	global.surf_to_leave_angry_biters_counter = 0
	global.warp_charge_time = 10--warp_charge_time_at_start --in seconds
	global.polution_amount = 1

	global.warp_charge_start_tick = 0 
	global.warp_charging = 0
	global.warp_time_left = 60*10
	global.warp_reactor = nil
	global.warp_stabilizer_accumulator = nil
	global.warp_stabilizer_accumulator_discharge_count = 0
	global.warp_stabilizer_accumulator_research_level = 0
	global.warp_module_size = warp_module_size --in tiles
	
	--global.warp_teleporter = nil
	global.warp_teleporter_transport = table.deepcopy(warp_transport)
	
	--global.warp_teleporter_exit = nil
	global.warp_teleporter_exit_transport = table.deepcopy(warp_transport)
	
	global.warp_reactor_logistic_research_level = 0
	global.warp_teleporter_research_level = 0
	
	global.underground_level_1 = table.deepcopy(underground_level_table)
	global.underground_level_2 = table.deepcopy(underground_level_table)
	
	global.to_underground_entrance = table.deepcopy(warp_transport)
	
	global.time_spent_start_tick = 0
	global.time_passed = 0
	
	global.warp_beacon = nil
	global.warp_accelerator = nil

	global.warp_energy_research = 0
	global.warp_heat_pipe = nil
	
end	

script.on_init(function()
    init_globals()
end)

script.on_load(function()

end)

function build_main_floor(surface)
	local floor_type = "warp-tile"
	local offset_pos = {x=0,y=0}
	local warp_module_bouding_box = {area = {{global.warp_platform_pos.x,global.warp_platform_pos.y},{global.warp_platform_pos.x+global.warp_module_size-1,global.warp_platform_pos.y+global.warp_module_size}}}
	surface.destroy_decoratives(warp_module_bouding_box)
	
	--warp main floor
	lay_warpfloor(floor_type,surface,offset_pos,global.warp_platform_pos,{x=global.warp_module_size-1,y=global.warp_module_size})
	
	--warp upgrade buildings hazard floor
	--teleporter
	lay_warpfloor("hazard-concrete-left",surface,offset_pos,{x=-4,y=-7},{x=7,y=3})
	--warp reactor stabilizer
	lay_warpfloor("hazard-concrete-left",surface,offset_pos,{x=-6,y=-2},2)
	--??
	lay_warpfloor("hazard-concrete-left",surface,offset_pos,{x=3,y=-2},2)
	--underground
	lay_warpfloor("hazard-concrete-left",surface,offset_pos,{x=-4,y=3},{x=7,y=3})
end

function create_underground_surfaces()
	function create_underground(floor_table,name,downstairs)
		--local underground_level
		floor_table.surface = game.create_surface(name,{width = 14, height = 16})
		floor_table.surface.always_day = true 
		floor_table.surface.daytime = 0.5
		floor_table.surface.request_to_generate_chunks({0,0}, 10)
		floor_table.surface.force_generate_chunk_requests()	
		local clear_ent = floor_table.surface.find_entities()
		for i, v in ipairs(clear_ent) do
			clear_ent[i].destroy()
		end
		floor_table.name = name
		floor_table.size = 16
		
		floor_table.surface.destroy_decoratives({area = {{-floor_table.size,-floor_table.size},{floor_table.size,floor_table.size}}})

		create_underground_floor(floor_table.surface,floor_table.size,downstairs)
		
		--lay_warpfloor("warp-tile",floor_table.surface,{x=0,y=0},global.warp_platform_pos,{x=global.warp_module_size-1,y=global.warp_module_size})
		
		--upstairs
		--lay_warpfloor("hazard-concrete-left",floor_table.surface,{x=0,y=0},{x=-4,y=-7},{x=7,y=3})
		floor_table.upstairs.reference = floor_table.surface.create_entity{name = "underground-entrance-1", position = {-1,-6}, force = game.forces.player}
		floor_table.upstairs.reference.minable = false		
		floor_table.upstairs.reference.destructible = false		
		
		--downstairs
		if downstairs then
			--lay_warpfloor("hazard-concrete-left",floor_table.surface,{x=0,y=0},{x=-4,y=3},{x=7,y=3})
			floor_table.downstairs.reference = floor_table.surface.create_entity{name = "underground-entrance-1", position = {-1,4}, force = game.forces.player}
			floor_table.downstairs.reference.minable = false
			floor_table.downstairs.reference.destructible = false	
		end
		
	end
	
	create_underground(global.underground_level_1, "underground-level-1",true)
	create_underground(global.underground_level_2, "underground-level-2",false)
	
end

function create_underground_floor(surface,size,downstairs)
	lay_warpfloor("warp-tile",surface,{x=0,y=0},{x=-size/2,y=-size/2},{x=size-1,y=size})
	lay_warpfloor("hazard-concrete-left",surface,{x=0,y=0},{x=-4,y=-7},{x=7,y=3})
	
	if downstairs then
		lay_warpfloor("hazard-concrete-left",surface,{x=0,y=0},{x=-4,y=3},{x=7,y=3})
		lay_warpfloor("hazard-concrete-left",surface,{x=0,y=0},{x=-2,y=-2},{x=3,y=3})
	else
		lay_warpfloor("hazard-concrete-left",surface,{x=0,y=0},{x=-3,y=-3},{x=5,y=5})
	end
	
	surface_play_sound("warp_in", surface.name)
end

function build_void(surface)
	local floor_type = "out-of-map"
	local offset_pos = {x=0,y=0}
	local warp_module_bouding_box = {area = {{global.warp_platform_pos.x,global.warp_platform_pos.y},{global.warp_platform_pos.x+global.warp_module_size-1,global.warp_platform_pos.y+global.warp_module_size}}}
	surface.destroy_decoratives(warp_module_bouding_box)
	
	lay_warpfloor(floor_type,surface,offset_pos,global.warp_platform_pos,{x=global.warp_module_size-1,y=global.warp_module_size})
end

function init_floors(surface)
	
	build_main_floor(surface)
	
	warp_module_bouding_box = {{global.warp_platform_pos.x,global.warp_platform_pos.y},{global.warp_platform_pos.x+global.warp_module_size,global.warp_platform_pos.y+global.warp_module_size}} 
	clean_ent_bounding_box(surface,warp_module_bouding_box)
	
end
	
function warp_modules(warp_module,surface_to)

	warp_module_bouding_box = {{global.warp_platform_pos.x,global.warp_platform_pos.y},{global.warp_platform_pos.x+global.warp_module_size-1,global.warp_platform_pos.y+global.warp_module_size}}
	
	game.surfaces[global.current_surface].clone_area{
		source_area=warp_module_bouding_box, 
		destination_area=warp_module_bouding_box,
		destination_surface=surface_to,
		clone_tiles=true,
		clone_entities=true,
		clone_decoratives=false,
		clear_destination=true,
		expand_map=false
	}	
	
	global.current_surface = surface_to.name
end

script.on_event(defines.events.on_player_respawned, function(event)
	if game.players[event.player_index].character.surface ~= global.current_surface then
		local player_pos = game.surfaces[global.current_surface].find_non_colliding_position("character", {0,-5}, 0, 1, 1)
		game.players[event.player_index].teleport(player_pos, global.current_surface)	
	end
end)

function on_player_created() end
script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	
	button_warp = mod_gui.get_frame_flow(player).add{type = "button", name = "warp", caption = {"warp"}}
	mod_gui.get_frame_flow(player).add{type = "label", name = "time_passed_label", caption = {"time-passed-label", "-"}}	
	mod_gui.get_frame_flow(player).add{type = "label", name = "time_left", caption = {"time-left", "-"}}
	mod_gui.get_frame_flow(player).add{type = "label", name = "number_of_warps_label", caption = {"number-of-warps-label", "-"}}	

	
	local label = mod_gui.get_frame_flow(player).number_of_warps_label
	label.caption = "   Warp number : " .. global.warpzone_n
	
	local label = mod_gui.get_frame_flow(player).time_left
	label.caption = "   Charge Time : " .. util.formattime(global.warp_time_left)
	
	if event.player_index == 1 then
		--player.force.research_all_technologies()
		init_floors(game.surfaces["nauvis"])
		
		create_underground_surfaces()

		global.to_underground_entrance.reference = game.surfaces["nauvis"].create_entity{name = "underground-entrance-1", position = {-1,4}, force = game.forces.player}
		global.to_underground_entrance.reference.minable = false		
		global.to_underground_entrance.reference.destructible = false
		
		global.warp_reactor = game.surfaces["nauvis"].create_entity{name = "warp-reactor", position = {-1,-1}, force = game.forces.player}
		global.warp_reactor.minable = false
		
		--This is to attract biters when no buildings emit pollution
		local dummy = game.surfaces["nauvis"].create_entity{name = "dummy", position = {-1,-1}, force = game.forces.player}
		dummy.minable = false
		--dummy.destructible = false
		local dummy_inv = dummy.get_inventory(defines.inventory.fuel)
		dummy_inv.insert({name="coal"})
		
		--global.warp_teleporter_exit.destructible = false
		
		game.map_settings.pollution.diffusion_ratio = 0.1
		game.map_settings.pollution.pollution_factor = 0.0000001
		
		game.map_settings.pollution.min_to_diffuse=15
		game.map_settings.unit_group.min_group_gathering_time = 600
		game.map_settings.unit_group.max_group_gathering_time = 2 * 600
		game.map_settings.unit_group.max_unit_group_size = 200
		game.map_settings.unit_group.max_wait_time_for_late_members = 2 * 360
		game.map_settings.unit_group.settler_group_min_size = 1
		game.map_settings.unit_group.settler_group_max_size = 1				
	end
	
	--local player_pos = game.surfaces[global.current_surface].find_non_colliding_position("character", {0,-5}, 0, 1, 1)
	--player.teleport(player_pos, global.current_surface)		
	sane_teleport(player.character, {0,-5}, game.surfaces[global.current_surface])
end)

function on_entity_cloned() end
script.on_event(defines.events.on_entity_cloned, function(event)
	if event.destination.type == "character" then
		event.destination.destroy()
	elseif event.destination.name == "warp-reactor"  then
		if global.warp_energy_research == 1 then event.destination.insert{name="warp-reactor-fuel-cell",count=1} end
		global.warp_reactor = event.destination
	elseif event.destination.name == "offshore-pump" then
		event.destination.destroy()		
	elseif event.destination.type == "resource" then
		event.destination.destroy()	
	elseif event.destination.name == "warp-teleporter-1" or event.destination.name == "warp-teleporter-2" or event.destination.name == "warp-teleporter-3" then
		global.warp_teleporter_transport.reference = event.destination
	elseif event.destination.name == "underground-entrance-1" or event.destination.name == "underground-entrance-2" or event.destination.name == "underground-entrance-3" then
		global.to_underground_entrance.reference = event.destination		
	elseif event.destination.name == "warp-teleporter-1-exit" or event.destination.name == "warp-teleporter-2-exit" or event.destination.name == "warp-teleporter-3-exit" then
		event.destination.destroy()	
	elseif event.destination.name == "warp-accelerator" then
		global.warp_accelerator = event.destination
	else
		for k, v in pairs(global.warp_teleporter_exit_transport.entities) do
			if event.source == v then event.destination.destroy() end
		end
		
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local gui = event.element
	if gui.name == "warp" then
		global.warp_charge_start_tick = event.tick
		global.warp_charging = 1
	end
end)

function on_tick() end
script.on_event({defines.events.on_tick},
function (e)
	if e.tick % 5 then
		
		logistic_update()
		
		if e.tick % 30 then
		
			through_teleporter_update()
		
			if e.tick % 60 == 0 then
						
				if e.tick % 120 == 0 then
				
					--*** warp energy upgrade update
					if global.warp_energy_research == 1 and global.warp_reactor.valid then
						transfert_resources(global.warp_reactor, global.warp_heat_pipe, "average")
					end
					
					--*** attack left behind engineers
					if global.current_surface ~= "nauvis" then 
						for k, v in pairs(game.surfaces) do 
							global.surf_to_leave_angry_biters_counter = global.surf_to_leave_angry_biters_counter + 1
							if v.name ~= global.current_surface  and v.name ~= "underground-level-1" and v.name ~= "underground-level-2"  then 
								create_angry_biters("behemoth-biter",global.surf_to_leave_angry_biters_counter,v.name) 
							end
						end
					end
					
					--*** polution update
					game.surfaces[global.current_surface].pollute({-1,-1}, global.polution_amount)	
					
					global.polution_amount = global.polution_amount * settings.global['warptorio_warp_polution_factor'].value
					local calculate_expansion_cooldown = math.floor(warp_base_expansion_cooldown / game.forces["enemy"].evolution_factor / 100)
					if calculate_expansion_cooldown > 3600*60 then game.map_settings.enemy_expansion.min_expansion_cooldown = 3600*60-1 else game.map_settings.enemy_expansion.min_expansion_cooldown = calculate_expansion_cooldown end
					game.map_settings.enemy_expansion.max_expansion_cooldown = game.map_settings.enemy_expansion.min_expansion_cooldown + 1
					
					--*** play alarm or not update
					if global.warp_charging == 1 then 
						if global.warp_time_left <= 3600 then 
							surface_play_sound("warp_alarm", global.current_surface)
						end
					end 
					
					--*** bitter anger clean capacity
					if global.warp_stabilizer_accumulator ~= nil then
						local stabilize = 0
						if global.warp_stabilizer_accumulator_discharge_count == 0 and global.warp_stabilizer_accumulator.energy > 1*math.pow(10, 8)-1 then
							global.warp_stabilizer_accumulator_discharge_count = 1
							stabilize = 1
							if global.warp_stabilizer_accumulator_research_level > 1 then
								create_warp_stab_accu(2)
							end	
						elseif global.warp_stabilizer_accumulator_discharge_count == 1 and global.warp_stabilizer_accumulator.energy > 1*math.pow(10, 10)-1 and global.warp_stabilizer_accumulator_research_level > 1 then
							stabilize = 1
							if global.warp_stabilizer_accumulator_research_level > 2 then
								create_warp_stab_accu(3)
							end					
						elseif global.warp_stabilizer_accumulator_discharge_count == 2 and global.warp_stabilizer_accumulator.energy > 1*math.pow(10, 11)-1 and global.warp_stabilizer_accumulator_research_level > 2 then
							stabilize = 1
							global.warp_stabilizer_accumulator_discharge_count = 3
						end
						if stabilize == 1 then
							game.forces["enemy"].evolution_factor=0	
							global.polution_amount = 1
							game.surfaces[global.current_surface].clear_pollution()
							game.surfaces[global.current_surface].set_multi_command{command={type=defines.command.flee, from=global.warp_reactor}, unit_count=1000, unit_search_distance=500}
							surface_play_sound("reactor-stabilized", global.current_surface)	

						end

					end
					
					--*** warp accelerator logic
					if global.warp_accelerator ~= nil and global.warp_charging == 0 then
						if global.warp_accelerator.energy > 5*math.pow(10, 6)-1 then
							global.warp_accelerator.energy = 0
							global.warp_charge_time = global.warp_charge_time *0.99
							local caption = "   Charge Time : " .. util.formattime(math.ceil(60*global.warp_charge_time))
							update_label("time_left",caption)
						end
					end
				end
			  
				--update time to warp caption and warp out if 0
				local caption
				if global.warp_charging == 1 then		
					global.warp_time_left = 60*global.warp_charge_time - (e.tick - global.warp_charge_start_tick)
					caption = "   Time to warp : " .. util.formattime(global.warp_time_left)
					update_label("time_left",caption)
					if global.warp_time_left <= 0 then
						warp_out()
						global.time_spent_start_tick = e.tick
					end
				end
				
				--update time spent on this surface
				local caption
				global.time_passed = e.tick - global.time_spent_start_tick
				caption = "   Time passed on this planet : " .. util.formattime(global.time_passed)
				update_label("time_passed_label",caption)
			end
		end
	end
end)

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "warp-teleporter-1" or event.entity.name == "warp-teleporter-2" or event.entity.name == "warp-teleporter-3" then
		create_warp_teleporter(1)
	end	
end)

function transfert_resources(container1, container2, transfert_type, cost)
	function average(c1c,c2c)
		local average_content = (c1c+c2c)/2
		c1c = average_content
		c2c = average_content
		return c1c,c2c
	end
	
	function get_steam_temperature(container)	
		local temperature = 0
		
		function test_for(temp)
			local count = container.remove_fluid({name="steam",amount=1,temperature=temp})
			if count ~= 0 then temperature = temp else return end
			container.insert_fluid({name="steam",amount=count,temperature=temp})
		end
		
		test_for(15)
		if temperature == 0 then 
			test_for(165)
			if temperature == 0 then 			
				test_for(500)
				if temperature == 0 then 	
					temperature = 165
				end
			end
		end
		return temperature
	end

	if container1 == nil or container2 == nil then 

		return 
	end
	
	if not container1.valid or not container2.valid then return end


	
	if container1.type == "accumulator" and container2.type == "accumulator" then
		if transfert_type == "average" then
			container1.energy,container2.energy = average(container1.energy,container2.energy)
		end
	elseif container1.type == "container" and container2.type == "container" then 
		if transfert_type == "in-out" then
			local to_transfert = container1.get_inventory(defines.inventory.chest).get_contents()
			
			--local total_count = 0
			for k, v in pairs(to_transfert) do
				
				local count = container2.get_inventory(defines.inventory.chest).insert({name = k,count = v})
				if count > 0 then container1.get_inventory(defines.inventory.chest).remove({name = k,count = count}) end
				if cost == false then return end
				local transferable = transfert_energy_use(count,warp_teleporter_per_item_joule_cost)
				if transferable ~= count then
					container1.get_inventory(defines.inventory.chest).insert({name = k,count = count})
					container2.get_inventory(defines.inventory.chest).remove({name = k,count = count})
					if transferable == 0 then return end
					container2.get_inventory(defines.inventory.chest).insert({name = k,count = transferable})
					container1.get_inventory(defines.inventory.chest).remove({name = k,count = transferable})	
					break
				end
			end
		end		
	elseif container1.type == "pipe-to-ground" and container2.type == "pipe-to-ground" then 
		local fluid_content1 = container1.get_fluid_contents()
		local fluid_type1
		local fluid_amount1
		for k,v in pairs(fluid_content1) do
			fluid_type1 = k
			fluid_amount1 = v
		end
		
		local fluid_content2 = container2.get_fluid_contents()
		local fluid_type2
		local fluid_amount2
		for k,v in pairs(fluid_content2) do
			fluid_type2 = k
			fluid_amount2 = v
		end
		
		if fluid_type1 == nil and fluid_type2 == nil then return end
		if fluid_type1 ~= nil and fluid_type2 ~= nil and fluid_type1 ~= fluid_type2 then return end
		if fluid_amount1 == nil then fluid_amount1 = 0 end
		if fluid_amount2 == nil then fluid_amount2 = 0 end
		if fluid_type1 == nil then fluid_type1 = fluid_type2 end
		
		if transfert_type == "average" then
			fluid_amount1,fluid_amount2 = average(fluid_amount1,fluid_amount2)
			container1.clear_fluid_inside()
			container2.clear_fluid_inside()
			container1.insert_fluid({name=fluid_type1,amount=fluid_amount1})
			container2.insert_fluid({name=fluid_type1,amount=fluid_amount1})
		elseif transfert_type == "in-out" then 
			if fluid_amount1 == 0 then return end
			local temperature = 0
			if fluid_type1 == "steam" then
				temperature = get_steam_temperature(container1)	
				--game.players[1].print(temperature)
			else
				temperature = 15
			end
			
			local count = container2.insert_fluid({name=fluid_type1,amount=fluid_amount1,temperature=temperature})
			container1.remove_fluid({name=fluid_type1,amount=count})
			if cost == false then return end
			transferable = transfert_energy_use(count,warp_teleporter_per_fluid_joule_cost)
			if transferable ~= count then
				container1.insert_fluid({name=fluid_type1,amount=count})
				container2.remove_fluid({name=fluid_type1,amount=count})
				if transferable == 0 then return end
				transfert_energy_use(transferable,warp_teleporter_per_fluid_joule_cost)

				container2.insert_fluid({name=fluid_type1,amount=transferable})
				container1.remove_fluid({name=fluid_type1,amount=transferable})
			end
			
		end
	else
		if transfert_type == "average" then
			container1.temperature,container2.temperature = average(container1.temperature,container2.temperature)
			--if container1.name == "warp-reactor" then game.players[1].print(container1.energy .. "/" .. container2.energy) end
		end
	end
end

function logistic_update()

	
	function entrance_transfert_resources(transport1,transport2,cost)
		transfert_resources(transport1.reference,transport2.reference,"average",cost)
		
		if transport1.transfert_type == "out_and_out" then
			transfert_resources(transport2.entities.chest_1,transport1.entities.chest_1,"in-out",cost)
			transfert_resources(transport2.entities.chest_2,transport1.entities.chest_2,"in-out",cost)
		elseif transport1.transfert_type == "in_and_out" then
			transfert_resources(transport1.entities.chest_1,transport2.entities.chest_1,"in-out",cost)
			transfert_resources(transport2.entities.chest_2,transport1.entities.chest_2,"in-out",cost)		
		end

		transfert_resources(transport1.entities.pipe_1,transport2.entities.pipe_1,"in-out",cost)
		transfert_resources(transport2.entities.pipe_2,transport1.entities.pipe_2,"in-out",cost)
		
		if global.warp_reactor_logistic_research_level > 1 then
			transfert_resources(transport1.entities.pipe_3,transport2.entities.pipe_3,"in-out",cost)
			transfert_resources(transport2.entities.pipe_4,transport1.entities.pipe_4,"in-out",cost)
		
			if global.warp_reactor_logistic_research_level > 2 then 
				transfert_resources(transport1.entities.pipe_5,transport2.entities.pipe_5,"in-out",cost)
				transfert_resources(transport2.entities.pipe_6,transport1.entities.pipe_6,"in-out",cost)
			end
		end
	end
	
	entrance_transfert_resources(global.warp_teleporter_transport,global.warp_teleporter_exit_transport,true)
	entrance_transfert_resources(global.to_underground_entrance,global.underground_level_1.upstairs,false)
	entrance_transfert_resources(global.underground_level_1.downstairs,global.underground_level_2.upstairs,false)	
	transfert_resources(global.underground_level_1.downstairs.reference,global.underground_level_1.upstairs.reference,"average")
end

function through_teleporter_update()	
	function teleport_players_around(origin_teleporter,to_teleporter,cost)
		if origin_teleporter == nil or origin_teleporter.valid ~= true then 
		return end
		if to_teleporter == nil or (not to_teleporter.valid) then return end
		
		
		local to_teleport_out_entity_list = origin_teleporter.surface.find_entities_filtered{area={{origin_teleporter.position.x-1.1,origin_teleporter.position.y-1.1},{origin_teleporter.position.x+1.1,origin_teleporter.position.y+1.1}},type="character"}--area={{-2,-7},{-4+5,-7+3}}}
		for i, v in ipairs(to_teleport_out_entity_list) do
			if v.type == "character" then 
				
				local player_inventory_count = v.get_main_inventory().get_item_count()
				if cost == 0 or (player_inventory_count == transfert_energy_use(player_inventory_count,warp_teleporter_per_item_joule_cost/2)) then
					local pos = {x = to_teleporter.position.x, y = to_teleporter.position.y}
					if v.position.y < origin_teleporter.position.y then pos.y = pos.y + 2 else pos.y = pos.y - 2 end
					sane_teleport(v,pos,to_teleporter.surface) 
					local sound
					if cost == 1 then sound = "teleport" else sound = "stairs" end
					surface_play_sound(sound, origin_teleporter.surface.name, origin_teleporter.position)
					surface_play_sound(sound, to_teleporter.surface.name, to_teleporter.position)
				else
					for k,w in pairs(game.players) do
						if w.character == v then w.print("Not enough energy to teleport ! Recharge the teleporter or lighten your inventory.") end
					end
				end
			end

		end			
	end
	
	teleport_players_around(global.warp_teleporter_transport.reference,global.warp_teleporter_exit_transport.reference,1) 
	teleport_players_around(global.warp_teleporter_exit_transport.reference,global.warp_teleporter_transport.reference,1) 	

	teleport_players_around(global.to_underground_entrance.reference,global.underground_level_1.upstairs.reference,0) 
	teleport_players_around(global.underground_level_1.upstairs.reference,global.to_underground_entrance.reference,0) 	
	
	teleport_players_around(global.underground_level_1.downstairs.reference,global.underground_level_2.upstairs.reference,0) 
	teleport_players_around(global.underground_level_2.upstairs.reference,global.underground_level_1.downstairs.reference,0) 	
end

function transfert_energy_use(count,cost_factor)
	local relative_teleporters_pos = {x=global.warp_teleporter_exit_transport.reference.position.x-global.warp_teleporter_transport.reference.position.x,y=global.warp_teleporter_exit_transport.reference.position.y-global.warp_teleporter_transport.reference.position.y}
	local player_distance_from_teleporter = math.sqrt(relative_teleporters_pos.x^2+relative_teleporters_pos.y^2)
	local joule_cost = (count*cost_factor)*(1+player_distance_from_teleporter/200)
	if global.warp_teleporter_transport.reference.energy >= joule_cost then
		global.warp_teleporter_transport.reference.energy = global.warp_teleporter_transport.reference.energy - joule_cost
		return count
	else 
		energy_per_unit = joule_cost/count
		new_count = math.floor(global.warp_teleporter_transport.reference.energy/energy_per_unit)
		return new_count
	end
end

script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == "warp-teleporter-1-exit" or event.created_entity.name == "warp-teleporter-2-exit" or event.created_entity.name == "warp-teleporter-3-exit" then
		if global.warp_teleporter_exit_transport.reference == nil or global.warp_teleporter_exit_transport.reference.valid == false 
		then 
			local level
			if global.warp_reactor_logistic_research_level == 0 then level = 1 else level = global.warp_reactor_logistic_research_level end
			local return_message = create_warp_teleporter(level, event.created_entity)
			if return_message ~= nil then game.players[event.player_index].print(return_message) end
		else
			event.created_entity.destroy()
		end
	end
end)

function on_research_finished() end
script.on_event(defines.events.on_research_finished, function(event)
	
	if event.research.name == "warp-platform-size-1" or event.research.name == "warp-platform-size-2" then		
		if event.research.name == "warp-platform-size-1" then
			global.warp_module_size = 32
		elseif event.research.name == "warp-platform-size-2" then
			global.warp_module_size = 64
		end
		surface_play_sound("warp_in", global.current_surface)
		global.warp_platform_pos = {x=-global.warp_module_size/2,y=-global.warp_module_size/2}
		build_main_floor(game.surfaces[global.current_surface])
	elseif event.research.name == "warp-platform-size-3" or event.research.name == "warp-platform-size-4" or event.research.name == "warp-platform-size-5" then	
		if event.research.name == "warp-platform-size-3" then
			global.underground_level_1.size = 32
			global.underground_level_2.size = 32
			create_underground_floor(global.underground_level_1.surface,global.underground_level_1.size,true)
			create_underground_floor(global.underground_level_2.surface,global.underground_level_1.size,false)
		elseif event.research.name == "warp-platform-size-4" then
			global.underground_level_1.size = 64
			create_underground_floor(global.underground_level_1.surface,global.underground_level_1.size,true)
		elseif event.research.name == "warp-platform-size-5" then
			global.underground_level_2.size = 64
			create_underground_floor(global.underground_level_2.surface,global.underground_level_1.size,false)
		end
	elseif event.research.name == "warp-stabilizer-accumulator-1" or event.research.name == "warp-stabilizer-accumulator-2" or event.research.name == "warp-stabilizer-accumulator-3" then
		if event.research.name == "warp-stabilizer-accumulator-1" then
			global.warp_stabilizer_accumulator_research_level = 1
			surface_play_sound("warp_in", global.current_surface)
			create_warp_stab_accu(1)
		elseif event.research.name == "warp-stabilizer-accumulator-2" then
			global.warp_stabilizer_accumulator_research_level = 2
		elseif event.research.name == "warp-stabilizer-accumulator-3" then
			global.warp_stabilizer_accumulator_research_level = 3
		end	
	elseif event.research.name == "warp-teleporter-1" then
		global.warp_teleporter_research_level = 1
		local level
		if global.warp_reactor_logistic_research_level == 0 then level = 1 else level = global.warp_reactor_logistic_research_level end
 		create_warp_teleporter(level)
	elseif event.research.name == "warp-reactor-logistic-1" then
		global.warp_reactor_logistic_research_level = 1
		create_warp_teleporter(1)
		create_underground_logistic(1)
	elseif event.research.name == "warp-reactor-logistic-2" then
		global.warp_reactor_logistic_research_level = 2
		upgrade_transport_buildings(2)
	elseif event.research.name == "warp-reactor-logistic-3" then
		global.warp_reactor_logistic_research_level = 3
		upgrade_transport_buildings(3)		
	elseif event.research.name == "warp-beacon" then
		clean_ent_bounding_box(global.underground_level_1.surface,{{-2,-2},{1,1}})
		global.warp_beacon = global.underground_level_1.surface.create_entity{name = "warp-beacon", position = {-1,-1}, force = game.forces.player}
		global.warp_beacon.minable = false
		global.warp_beacon.destructible = false		
		
		surface_play_sound("warp_in", global.underground_level_1.surface.name)
	elseif event.research.name == "warp-accelerator" then
		clean_ent_bounding_box(game.surfaces[global.current_surface],{{4,-1},{5,0}})
		global.warp_accelerator = game.surfaces[global.current_surface].create_entity{name = "warp-accelerator", position = {4,-1}, force = game.forces.player}
		global.warp_accelerator.minable = false
		global.warp_accelerator.destructible = false	
	elseif event.research.name == "warp-energy" then	
		global.warp_energy_research = 1
		clean_ent_bounding_box(global.underground_level_2.surface,{{-3,-3},{2,2}})
		
		create_warp_energy_upgrade()
	end
	
end)

function create_warp_energy_upgrade()
	function create(name,pos,direction)
		local entity = global.underground_level_2.surface.create_entity{name = name, position = pos, force = game.forces.player, direction = direction}
		entity.minable = false
		entity.destructible = false	
		return entity
	end
	
	create("heat-exchanger",{-2,-0},defines.direction.west)
	create("heat-exchanger",{1,0},defines.direction.east)
	
	--create("heat-pipe",{-1,1})
	global.warp_heat_pipe = create("heat-pipe",{-1,0})
	--[[
	create("heat-pipe",{-1,-1})
	create("heat-pipe",{-1,-2})
	create("heat-pipe",{-1,-3})
	create("heat-pipe",{-2,-3})
	create("heat-pipe",{-3,-3})
	create("heat-pipe",{0,-3})
	create("heat-pipe",{1,-3})
	--]]
	
end

script.on_event(defines.events.on_player_mined_entity, function(event)
	if event.entity.name == "warp-teleporter-1-exit" or event.entity.name == "warp-teleporter-2-exit" or event.entity.name == "warp-teleporter-3-exit" then 
		event.entity.destroy()
		create_warp_teleporter(global.warp_reactor_logistic_research_level) 
	end
end)

function create_warp_stab_accu(level)
	clean_ent_bounding_box(game.surfaces[global.current_surface],{{-6,-2},{-4,0}})
	global.warp_stabilizer_accumulator = game.surfaces[global.current_surface].create_entity{name = "warp-stab-accu-".. level, position = {-5,-1}, force = game.forces.player}
	global.warp_stabilizer_accumulator.minable = false
	global.warp_stabilizer_accumulator.destructible = false
	surface_play_sound("warp_in", global.current_surface)
end

function create_warp_teleporter(level, exit_entity)
	local return_message = nil
	
	if global.warp_teleporter_research_level == 0 then return end 

	--create warp teleporter
	if global.warp_teleporter_transport.reference == nil then
		clean_ent_bounding_box(game.surfaces[global.current_surface],{{-4,-7},{-4+7,-7+3}})
		global.warp_teleporter_transport.reference = game.surfaces[global.current_surface].create_entity{name = "warp-teleporter-".. level, position = {-1,-6}, force = game.forces.player}
		global.warp_teleporter_transport.reference.minable = false
		global.warp_teleporter_transport.reference.destructible = false
	end
	
	--create warp teleporter's logistic
	if global.warp_reactor_logistic_research_level > 0 and (global.warp_teleporter_transport.entities.chest_1 == nil or global.warp_teleporter_transport.entities.chest_1.valid == false) then
		create_transfert_logistic(global.warp_teleporter_transport,global.warp_reactor_logistic_research_level,"out_and_out")
		--global.warp_teleporter_transport.entities.loader_1.rotate({reverse = true})
	end
	
	--create warp teleporter mobile gate
	if global.warp_teleporter_exit_transport.reference == nil then

		local pos = game.surfaces[global.current_surface].find_non_colliding_position("warp-teleporter-" .. level .. "-exit", {-1,-9}, 0, 1, 1)
		global.warp_teleporter_exit_transport.reference = game.surfaces[global.current_surface].create_entity{name = "warp-teleporter-" .. level .. "-exit", position = pos, force = game.forces.player}

	end
	
	--create warp teleporter mobile gate at pos
	if exit_entity ~= nil then
		local pos = exit_entity.position
		exit_entity.destroy()
		global.warp_teleporter_exit_transport.reference = game.surfaces[global.current_surface].create_entity{name = "warp-teleporter-" .. level .. "-exit", position = pos, force = game.forces.player}
		--global.warp_teleporter_exit_transport.reference = exit_entity
	end
	
	--destroy warp teleporter mobile gate's logistic
	if global.warp_teleporter_exit_transport.reference ~= nil and global.warp_teleporter_exit_transport.reference.valid ~= true then 
		for k, v in pairs(global.warp_teleporter_exit_transport.entities) do
			v.destroy()
		end
	end
	
	--create warp teleporter mobile gate's logistic
	if global.warp_reactor_logistic_research_level > 0 and global.warp_teleporter_exit_transport.reference.valid and (global.warp_teleporter_exit_transport.entities.chest_1 == nil or global.warp_teleporter_exit_transport.entities.chest_1.valid == false) then
		--global.warp_teleporter_exit_transport.reference = global.warp_teleporter_exit_transport.reference
	
		local pos = global.warp_teleporter_exit_transport.reference.position
		local logistic_bb = {{pos.x-3,pos.y-1},{pos.x+3,pos.y+1}}
		local logistic_area = global.warp_teleporter_exit_transport.reference.surface.find_entities(logistic_bb)
		
		local clear = true 
		for k, v in pairs(logistic_area) do
			if v.name ~= "warp-teleporter-" .. global.warp_reactor_logistic_research_level .. "-exit" then clear = false end
		end
		if clear == true then 
			create_transfert_logistic(global.warp_teleporter_exit_transport,global.warp_reactor_logistic_research_level,"in_and_in") 
			--global.warp_teleporter_exit_transport.entities.loader_2.rotate({reverse = true})
		else
			return_message = "Mobile warp teleporter gate's logistic system not activated, place the mobile warp teleporter gate on a cleared space to enable it."
		end
	end
	
	surface_play_sound("warp_in", global.current_surface)
	
	return return_message
end

function create_underground_logistic(level)
	create_transfert_logistic(global.to_underground_entrance,level,"in_and_out")
	create_transfert_logistic(global.underground_level_1.upstairs,level,"out_and_in")
	create_transfert_logistic(global.underground_level_1.downstairs,level,"in_and_out")
	create_transfert_logistic(global.underground_level_2.upstairs,level,"out_and_in")
end

function upgrade_transport_buildings(level)
	function upgrade(transport,building_type,level)
		function copy_chest_content(content,chest)
			for k, v in pairs(content) do
				chest.insert({name=k,count=v})
			end
		end
	
		if transport.reference == nil or transport.reference.valid ~= true then return end
		if transport.entities.chest_1 == nil or transport.entities.chest_1.valid ~= true then return end
		
		local chest_1_inventory = transport.entities.chest_1.get_inventory(defines.inventory.chest).get_contents()
		local chest_2_inventory = transport.entities.chest_2.get_inventory(defines.inventory.chest).get_contents()

		local pos = transport.reference.position
		local logistic_bb = {{pos.x-3,pos.y-1},{pos.x+3,pos.y+1}}
		
		local surface = transport.reference.surface
		
		clean_ent_bounding_box(transport.reference.surface,logistic_bb)
		
		transport.reference = surface.create_entity{name = building_type, position = pos, force = game.forces.player}
		
		create_transfert_logistic(transport,level,transport.transfert_type)
		
		copy_chest_content(chest_1_inventory,transport.entities.chest_1)
		copy_chest_content(chest_2_inventory,transport.entities.chest_2)
	end

	
	upgrade(global.warp_teleporter_transport,"warp-teleporter-" .. level, level)
	upgrade(global.warp_teleporter_exit_transport,"warp-teleporter-" .. level .. "-exit", level)
	upgrade(global.to_underground_entrance,"underground-entrance-" .. level, level)
	upgrade(global.underground_level_1.upstairs,"underground-entrance-" .. level, level)
	upgrade(global.underground_level_1.downstairs,"underground-entrance-" .. level, level)
	upgrade(global.underground_level_2.upstairs,"underground-entrance-" .. level, level)
	
end

function create_transfert_logistic(logistic_building_transport,level,build_type)
	logistic_building_transport.transfert_type = build_type
	local direction1
	local direction2
	local rotation1
	local rotation2
	if build_type == "in_and_out" then
		
		direction1 = defines.direction.south
		direction2 = defines.direction.north
		rotation1 = "input"
		rotation2 = "output"
	elseif build_type == "out_and_in" then
		direction1 = defines.direction.north
		direction2 = defines.direction.south
		rotation1 = "output"
		rotation2 = "input"
	elseif build_type == "in_and_in" then
		direction1 = defines.direction.south
		direction2 = defines.direction.south	
		rotation1 = "input"
		rotation2 = "input"
	else 
		direction1 = defines.direction.north
		direction2 = defines.direction.north	
		rotation1 = "output"
		rotation2 = "output"
	end
	local logistic_building = logistic_building_transport.reference
	
	function add_container(name,pos,direction,type)
		local container_entity
		container_entity = logistic_building.surface.find_entity(name,{logistic_building.position.x+pos.x,logistic_building.position.y+pos.y})
		if container_entity == nil then
			local pos2 = {logistic_building.position.x+pos.x,logistic_building.position.y+pos.y}
			if name == "loader" or name == "fast-loader" or name == "express-loader" then 
				container_entity = logistic_building.surface.create_entity{name = name, position = pos2, force = game.forces.player, type = type }
				container_entity.direction = direction
			elseif name == "logistic-pipe" then
				container_entity = logistic_building.surface.create_entity{name = name, position = pos2, force = game.forces.player}
				container_entity.direction = direction				
			else
				container_entity = logistic_building.surface.create_entity{name = name, position = pos2, force = game.forces.player}
			end		
		end
		container_entity.minable = false
		container_entity.destructible = false	
		return container_entity
	end

	local loader
	local chest
	if level == 1 then
		loader = "loader"
		chest = "wooden-chest"
	elseif level == 2 then
		loader = "fast-loader"
		chest = "iron-chest"
	else
		loader = "express-loader"
		chest = "steel-chest"
	end
	
	logistic_building_transport.entities.loader_1 = add_container(loader,{x=-2,y=-1},direction1,rotation1)
	logistic_building_transport.entities.loader_2 = add_container(loader,{x=2,y=-1},direction2,rotation2)
	logistic_building_transport.entities.chest_1 = add_container(chest,{x=-2,y=1})
	logistic_building_transport.entities.chest_2 = add_container(chest,{x=2,y=1})
	logistic_building_transport.entities.pipe_1 = add_container("logistic-pipe",{x=-3,y=1},defines.direction.west)
	logistic_building_transport.entities.pipe_2 = add_container("logistic-pipe",{x=3,y=1},defines.direction.east)	
	if level > 1 then 
		logistic_building_transport.entities.pipe_3 = add_container("logistic-pipe",{x=-3,y=0},defines.direction.west)
		logistic_building_transport.entities.pipe_4 = add_container("logistic-pipe",{x=3,y=0},defines.direction.east)	
		if level > 2 then
			logistic_building_transport.entities.pipe_5 = add_container("logistic-pipe",{x=-3,y=-1},defines.direction.west)
			logistic_building_transport.entities.pipe_6 = add_container("logistic-pipe",{x=3,y=-1},defines.direction.east)	
		end
	end
	
	surface_play_sound("warp_in", logistic_building.surface.name)
end

function warp_out()
	local caption
	
	global.warp_charging = 0
	
	
	global.warpzone_n = global.warpzone_n + 1
	caption = "    Warp number : " .. global.warpzone_n
	update_label("number_of_warps_label",caption)
	
	--charge time update
	function count_entities_on_platform(surface)
		local ent_table = game.surfaces[surface].find_entities({{x=-global.warp_module_size/2-1,y=-global.warp_module_size/2},{x=global.warp_module_size/2,y=global.warp_module_size/2}})
		local count = 0
		for k,v in pairs(ent_table) do
			count = count + 1
		end
		return count	
	end
	
	local count
	count = count_entities_on_platform(global.current_surface) + count_entities_on_platform(global.underground_level_1.surface.name) + count_entities_on_platform(global.underground_level_2.surface.name)
	global.warp_charge_time = 10+count/settings.global['warptorio_warp_charge_factor'].value + global.warpzone_n*0.5
	global.warp_time_left = 60*global.warp_charge_time
	caption = "   Charge Time : " .. util.formattime(global.warp_time_left)	
	update_label("time_left",caption)
	
	--create next surface
	local warp_surf = game.create_surface("warpsurf" .. global.warpzone_n,{seed = (game.surfaces["nauvis"].map_gen_settings.seed + math.random(0,4294967295)) % 4294967296})

	warp_surf.request_to_generate_chunks({0,0}, 1)
	warp_surf.force_generate_chunk_requests()
	
	--clone warp platform to new surface
	warp_modules(warp_module_1,warp_surf)
	
	if global.warpzone_n == 1 then
		surf_to_leave = "nauvis"
	else
		surf_to_leave = "warpsurf" .. global.warpzone_n - 1
	end
	
	if global.warp_stabilizer_accumulator_research_level > 0 then create_warp_stab_accu(1) end
	
	--teleports players to the next surface if they are on the platform
	for i, k in pairs(game.players) do
		if k.character ~= nil and is_in_bounding_box(k.character.position,{x=global.warp_platform_pos.x,y=global.warp_platform_pos.y},{x=global.warp_platform_pos.x+global.warp_module_size-1,y=global.warp_platform_pos.y+global.warp_module_size}) then
			local player_pos = warp_surf.find_non_colliding_position("character", {0,-5}, 0, 1, 1)
			k.teleport(player_pos, warp_surf)			
		else

		end
	end
	
	--build "void" from left surface space after warp
	build_void(game.surfaces[surf_to_leave])

	--delete abandonned surfaces
	for k, v in pairs(game.surfaces) do
		local surface_player_list = v.find_entities_filtered{type="character"}
		if surface_player_list[1] ~= nil then break end
		if v.name ~= global.current_surface then
			if v.name ~= "nauvis" and v.name ~= "underground-level-1" and v.name ~= "underground-level-2" then game.delete_surface(v) end
		end
	end
	
	--stuff to reset
	global.surf_to_leave_angry_biters_counter = 0
		game.forces["enemy"].evolution_factor=0	
	global.polution_amount = 1
	global.warp_stabilizer_accumulator_discharge_count = 0

	--rebuild teleporter to new surface
	if 	global.warp_teleporter_transport.reference ~= nil then
		--global.warp_teleporter_transport.reference = nil
		global.warp_teleporter_exit_transport.reference = nil
		create_warp_teleporter(1)
	end
	
	--reconnect underground's logistic
	if global.to_underground_entrance.entities.chest_1 ~= nil then
		
		create_transfert_logistic(global.to_underground_entrance,global.warp_reactor_logistic_research_level,"in_and_out")
		create_transfert_logistic(global.underground_level_1.upstairs,global.warp_reactor_logistic_research_level,"out_and_in")
	end
	
	--warp sound
	surface_play_sound("warp_in", surf_to_leave)
	surface_play_sound("warp_in", global.current_surface)
	
	--rebuild warp tiles to avoid draw bugs from cloning
	build_main_floor(warp_surf)
	
end

function lay_warpfloor(floor_type,surface,offset_pos,floor_pos,floor_area)
	local area = {}
	if type(floor_area) == "table" then
		area.x = floor_area.x
		area.y = floor_area.y
	else
		area.x = floor_area 
		area.y = floor_area 	
	end

	local pos = {}
	pos.x = floor_pos.x + offset_pos.x
	pos.y = floor_pos.y + offset_pos.y
	local tiles = {}
	for i=0,area.x-1 do
		for j=0,area.y-1 do
			table.insert(tiles, {name = floor_type, position={i+pos.x, j+pos.y}})
		end
	end
	
	surface.set_tiles(tiles)
end

function update_label(label_name,text)
	for k, v in pairs(game.players) do
		local label = mod_gui.get_frame_flow(v)--[label_name]
		local label2 = label[label_name]
		label2.caption = text
	end
end

function clean_ent_bounding_box(surface,bb)
	local clear_ent = surface.find_entities(bb)
	for i, v in ipairs(clear_ent) do
		if clear_ent[i].type ~= "character" then clear_ent[i].destroy()
		else
			sane_teleport(clear_ent[i], {0,0}, clear_ent[i].surface)
		end
		
	end	
end

function is_in_bounding_box(pos,pos1,pos2)
	if (pos.x < pos1.x or pos.y < pos1.y) or (pos.x > pos2.x or pos.y > pos2.y) then return false else return true end
end

function create_angry_biters(biter_type,number,surface)
	local surface_player_list = game.surfaces[surface].find_entities_filtered{type="character"}
	for i, k in ipairs(surface_player_list) do
		for j = 1,number do
			local angle = math.random(0,2*math.pi)
			local dist = 150
			local x = math.cos(angle)*dist+k.position.x
			local y = math.sin(angle)*dist+k.position.y
			
			pos = game.surfaces[surface].find_non_colliding_position(biter_type, {x,y}, 0, 2, 1)
			
			local angry_bitter = game.surfaces[surface].create_entity{name = biter_type, position = pos }--{game.surfaces[spawners_list[1].position.x+10],spawners_list[1].position.y+10}}
		end
		game.surfaces[surface].set_multi_command{command={type=defines.command.attack, target=k}, unit_count=number}
	end
end

function surface_play_sound(sound_path, surface, pos)		
	for k, v in pairs(game.connected_players) do
		if v.surface.name == surface then
			v.play_sound{path=sound_path, position=pos}
		end
	end
end

function sane_teleport(entity, pos, surface)
	local sane_pos = surface.find_non_colliding_position(entity.name, pos, 0, 1, 1)
	if entity.type == "character" then
		for k, v in pairs(game.players) do
			if v.character == entity then v.teleport(sane_pos, surface) end
		end
	else
		--entity.teleport(sane_pos, surface)
	end
end