advcarts = {}

advcarts.autoconnect_rails = function(pos, node)
	node_dict = {
		{x = pos.x, y = pos.y, z = pos.z - 1},
		{x = pos.x + 1, y = pos.y, z = pos.z - 1},
		{x = pos.x + 1, y = pos.y, z = pos.z},
		{x = pos.x + 1, y = pos.y, z = pos.z + 1},
		{x = pos.x, y = pos.y, z = pos.z + 1},
		{x = pos.x - 1, y = pos.y, z = pos.z + 1},
		{x = pos.x - 1, y = pos.y, z = pos.z},
		{x = pos.x - 1, y = pos.y, z = pos.z - 1},
	}
	local is_rail = function(i)
		if minetest.get_item_group(minetest.get_node(node_dict[i]).name, "advcarts_rail") == 1 then
			return true
		else
			return false
		end
	end
	if minetest.registered_nodes[node.name].advcarts_rail_type == "slope" then
		return
	end
	local prefix = node.name:sub(0, node.name:find("000") + 2)
	if is_rail(1) == true and is_rail(5) == true then
		minetest.set_node(pos, {name = prefix.."straight", param2 = 0})
	elseif is_rail(3) == true and is_rail(7) == true then
		minetest.set_node(pos, {name = prefix.."straight", param2 = 1})
	elseif is_rail(4) == true and is_rail(8) == true then
		minetest.set_node(pos, {name = prefix.."diagonal", param2 = 0})
	elseif is_rail(2) == true and is_rail(6) == true then
		minetest.set_node(pos, {name = prefix.."diagonal", param2 = 1})
	elseif is_rail(1) == true and is_rail(4) == true then
		minetest.set_node(pos, {name = prefix.."curve", param2 = 0})
	elseif is_rail(2) == true and is_rail(7) == true then
		minetest.set_node(pos, {name = prefix.."curve", param2 = 1})
	elseif is_rail(5) == true and is_rail(8) == true then
		minetest.set_node(pos, {name = prefix.."curve", param2 = 2})
	elseif is_rail(3) == true and is_rail(6) == true then
		minetest.set_node(pos, {name = prefix.."curve", param2 = 3})
	elseif is_rail(1) == true and is_rail(6) == true then
		minetest.set_node(pos, {name = prefix.."diagonal_curve", param2 = 3})
	elseif is_rail(4) == true and is_rail(7) == true then
		minetest.set_node(pos, {name = prefix.."diagonal_curve", param2 = 0})
	elseif is_rail(2) == true and is_rail(5) == true then
		minetest.set_node(pos, {name = prefix.."diagonal_curve", param2 = 1})
	elseif is_rail(3) == true and is_rail(8) == true then
		minetest.set_node(pos, {name = prefix.."diagonal_curve", param2 = 2})
	elseif is_rail(1) == true or is_rail(5) == true then
		minetest.set_node(pos, {name = prefix.."straight", param2 = 0})
	elseif is_rail(3) == true or is_rail(7) == true then
		minetest.set_node(pos, {name = prefix.."straight", param2 = 1})
	elseif is_rail(4) == true or is_rail(8) == true then
		minetest.set_node(pos, {name = prefix.."diagonal", param2 = 0})
	elseif is_rail(2) == true or is_rail(6) == true then
		minetest.set_node(pos, {name = prefix.."diagonal", param2 = 1})
	end
end

advcarts.update_nodes_around = function(pos, node)
	node_dict = {
		{x = pos.x, y = pos.y, z = pos.z - 1},
		{x = pos.x + 1, y = pos.y, z = pos.z - 1},
		{x = pos.x + 1, y = pos.y, z = pos.z},
		{x = pos.x + 1, y = pos.y, z = pos.z + 1},
		{x = pos.x, y = pos.y, z = pos.z + 1},
		{x = pos.x - 1, y = pos.y, z = pos.z + 1},
		{x = pos.x - 1, y = pos.y, z = pos.z},
		{x = pos.x - 1, y = pos.y, z = pos.z - 1},
	}
	local is_rail = function(i)
		if minetest.get_item_group(minetest.get_node(node_dict[i]).name, "advcarts_rail") == 1 then
			return true
		else
			return false
		end
	end
	for i = 1, 8 do
		if is_rail(i) then
			advcarts.autoconnect_rails(node_dict[i], minetest.get_node(node_dict[i]))
		end
	end
end

advcarts.register_track_node = function(name_prefix, name_suffix, mesh, texture, track, rail_type, creative_inv, collision, selection)
	minetest.register_node(name_prefix, {
		description = name_suffix,
		drawtype = "mesh",
		mesh = mesh,
		tiles = {texture},
		inventory_image = "advcarts_track_"..track.."_inv.png",
		wield_image = "advcarts_track_"..track.."_inv.png",
		selection_box = {type = "fixed", fixed = selection or {{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}}},
		collision_box = {type = "fixed", fixed = collision or {{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}}},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		advcarts_rail_type = rail_type,
		drop = "advcarts:track_"..track.."_000straight",
		groups = {oddly_breakable_by_hand = 3, advcarts_rail = 1, not_in_creative_inventory = creative_inv or 1},
		sounds = default.node_sound_wood_defaults(),
		after_place_node = function(pos)
			local node = minetest.get_node(pos)
			advcarts.autoconnect_rails(pos, node)
			advcarts.update_nodes_around(pos, node)
		end,
		after_dig_node = function(pos)
			local node = minetest.get_node(pos)
			advcarts.update_nodes_around(pos, node)
		end,
	})
end

advcarts.register_track = function(track, track_desc)
	advcarts.register_track_node("advcarts:track_"..track.."_000straight", track_desc.." Rail", "advcarts_track_straight.obj", "advcarts_track_"..track.."_straight.png", track, "regular", 0)
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal", track_desc.." Rail (Diagonal)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_diagonal.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000curve", track_desc.." Rail (Curved)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_curve.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_curve", track_desc.." Rail (Opposite Curved)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_curve.png^[transformFXR270", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000right_switch", track_desc.." Rail (Right Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_switch.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000left_switch", track_desc.." Rail (Left Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_switch.png^[transformFX", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_right_switch", track_desc.." Rail (Diagonal Right Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_diagonal_switch.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_left_switch", track_desc.." Rail (Diagonal Left Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_diagonal_switch.png^[transformFXR270", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000y_switch", track_desc.." Rail (Split Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_switch_y.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_y_switch", track_desc.." Rail (Diagonal Split Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_diagonal_switch_y.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000ty_switch", track_desc.." Rail (Triple Split Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_switch_ty.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_ty_switch", track_desc.." Rail (Triple Diagonal Split Switch)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_diagonal_switch_ty.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_0004_crossing", track_desc.." Rail (4-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_crossing.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_4_crossing", track_desc.." Rail (Diagonal 4-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_diagonal_crossing.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000skewed_4_crossing", track_desc.." Rail (Skewed 4-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_skewed_crossing.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_skewed_4_crossing", track_desc.." Rail (Diagonal Skewed 4-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_skewed_crossing.png^[transformFYR90", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_0006_crossing", track_desc.." Rail (6-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_6_way_crossing.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_6_crossing", track_desc.." Rail (Diagonal 6-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_diagonal_6_way_crossing.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_0008_crossing", track_desc.." Rail (8-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_8_way_crossing.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_8_crossing", track_desc.." Rail (8-Way Crossing)", "advcarts_track_normal.obj", "advcarts_track_"..track.."_8_way_crossing.png", track, "regular")
	advcarts.register_track_node("advcarts:track_"..track.."_000slope_bottom", track_desc.." Rail (Slope Bottom)", "advcarts_track_slope_bottom.obj", "advcarts_track_"..track.."_inv.png", track, "slope", 1, {{-0.5, -0.4375, -0.5, 0.5, -0.375, -0.25},
			{-0.5, -0.375, -0.375, 0.5, -0.3125, -0.125},
			{-0.5, -0.3125, -0.25, 0.5, -0.25, 6.70552e-008},
			{-0.5, -0.25, -0.125, 0.5, -0.1875, 0.125},
			{-0.5, -0.1875, 0, 0.5, -0.125, 0.25},
			{-0.5, -0.125, 0.125, 0.5, -0.0625, 0.375},
			{-0.5, -0.0625, 0.25, 0.5, -1.49012e-008, 0.5},
			{-0.5, 0, 0.375, 0.5, 0.0625, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.4375, -0.375}}, {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}})
	advcarts.register_track_node("advcarts:track_"..track.."_000slope_top", track_desc.." Rail (Slope Top)", "advcarts_track_slope_top.obj", "advcarts_track_"..track.."_inv.png", track, "slope", 1, {{-0.5, 0.375, 0.25, 0.5, 0.4375, 0.5},
			{-0.5, 0.3125, 0.125, 0.5, 0.375, 0.375},
			{-0.5, 0.25, -6.70552e-008, 0.5, 0.3125, 0.25},
			{-0.5, 0.1875, -0.125, 0.5, 0.25, 0.125},
			{-0.5, 0.125, -0.25, 0.5, 0.1875, -0},
			{-0.5, 0.0625, -0.375, 0.5, 0.125, -0.125},
			{-0.5, 1.49012e-008, -0.5, 0.5, 0.0625, -0.25},
			{-0.5, -0.0625, -0.5, 0.5, -0, -0.375},
			{-0.5, 0.4375, 0.375, 0.5, 0.5, 0.5}}, {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}})
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_slope_bottom", track_desc.." Rail (Diagonal Slope Bottom)", "advcarts_track_diagonal_slope_bottom.obj", "advcarts_track_"..track.."_diagonal_slope.png", track, "slope", 1, {{-0.5, -0.5, -0.5, 0, -0.4375, -0.375},
			{-0.5, -0.5, -0.5, -0.375, -0.4375, 0},
			{-0.5, -0.4375, -0.5, -0.25, -0.375, 0},
			{-0.5, -0.4375, -0.5, 0, -0.375, -0.25},
			{-0.375, -0.375, -0.375, 0.125, -0.3125, -0.125},
			{-0.375, -0.375, -0.375, -0.125, -0.3125, 0.125},
			{-0.25, -0.3125, -0.25, -4.47035e-008, -0.25, 0.25},
			{-0.25, -0.3125, -0.25, 0.25, -0.25, 0},
			{-0.125, -0.25, -0.125, 0.375, -0.1875, 0.125},
			{-0.125, -0.25, -0.125, 0.125, -0.1875, 0.375},
			{0, -0.1875, 0, 0.25, -0.125, 0.5},
			{0, -0.1875, 0, 0.5, -0.125, 0.25},
			{0.125, -0.125, 0.125, 0.625, -0.0625, 0.375},
			{0.125, -0.125, 0.125, 0.375, -0.0625, 0.625},
			{0.25, -0.0625, 0.25, 0.5, -2.23517e-008, 0.75},
			{0.25, -0.0625, 0.25, 0.75, -2.23517e-008, 0.5},
			{0.375, 0, 0.375, 0.75, 0.0625, 0.5},
			{0.375, 0, 0.375, 0.5, 0.0625, 0.75}}, {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}})
	advcarts.register_track_node("advcarts:track_"..track.."_000diagonal_slope_top", track_desc.." Rail (Diagonal Slope Top)", "advcarts_track_diagonal_slope_top.obj", "advcarts_track_"..track.."_diagonal_slope.png", track, "slope", 1, {{0.375, 0.4375, -0, 0.5, 0.5, 0.5},
			{-0, 0.4375, 0.375, 0.5, 0.5, 0.5},
			{-0, 0.375, 0.25, 0.5, 0.4375, 0.5},
			{0.25, 0.375, -0, 0.5, 0.4375, 0.5},
			{0.125, 0.3125, -0.125, 0.375, 0.375, 0.375},
			{-0.125, 0.3125, 0.125, 0.375, 0.375, 0.375},
			{-0.25, 0.25, 4.47035e-008, 0.25, 0.3125, 0.25},
			{-0, 0.25, -0.25, 0.25, 0.3125, 0.25},
			{-0.125, 0.1875, -0.375, 0.125, 0.25, 0.125},
			{-0.375, 0.1875, -0.125, 0.125, 0.25, 0.125},
			{-0.5, 0.125, -0.25, -0, 0.1875, -0},
			{-0.25, 0.125, -0.5, -0, 0.1875, -0},
			{-0.375, 0.0625, -0.625, -0.125, 0.125, -0.125},
			{-0.625, 0.0625, -0.375, -0.125, 0.125, -0.125},
			{-0.75, 2.23517e-008, -0.5, -0.25, 0.0625, -0.25},
			{-0.5, 2.23517e-008, -0.75, -0.25, 0.0625, -0.25},
			{-0.5, -0.0625, -0.75, -0.375, -0, -0.375},
			{-0.75, -0.0625, -0.5, -0.375, -0, -0.375}}, {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}})
end

advcarts.register_track("steel", "Steel")

minetest.register_craftitem("advcarts:railworker", {
	description = "\nRail Worker\n\nLeft-click: Change a rail type\nRight-click: Rotate a rail\nSneak + Left-click: Change to a slope\n",
	inventory_image = "advcarts_hammer.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "nothing" then
			return
		end
		local pos = minetest.get_pointed_thing_position(pointed_thing)
		local node = minetest.get_node(pos)
		local is_rail = function()
			if minetest.get_item_group(node.name, "advcarts_rail") == 1 then
				return true
			else
				return false
			end
		end
		if is_rail() == true then
			local prefix = node.name:sub(0, node.name:find("000") + 2)
			local suffix = node.name:sub(node.name:find("000") + 3, node.name:len())
			local facedir = node.param2
			local ctrl = user:get_player_control()
			if ctrl and ctrl.sneak then
				if suffix:sub(0, 8) == "diagonal" then
					suffix = "diagonal_slope_bottom"
				else
					suffix = "slope_bottom"
				end
			else
				if suffix == "straight" then
					suffix = "curve"
				elseif suffix == "diagonal" then
					suffix = "diagonal_curve"
				elseif suffix == "curve" and minetest.registered_nodes[node.name].advcarts_rail_type == "simple" then
					suffix = "straight"
				elseif suffix == "diagonal_curve" and minetest.registered_nodes[node.name].advcarts_rail_type == "simple" then
					suffix = "diagonal"
				elseif suffix == "curve" and minetest.registered_nodes[node.name].advcarts_rail_type == "regular" then
					suffix = "right_switch"
				elseif suffix == "diagonal_curve" and minetest.registered_nodes[node.name].advcarts_rail_type == "regular" then
					suffix = "diagonal_right_switch"
				elseif suffix == "right_switch" then
					suffix = "left_switch"
				elseif suffix == "diagonal_right_switch" then
					suffix = "diagonal_left_switch"
				elseif suffix == "left_switch" then
					suffix = "y_switch"
				elseif suffix == "diagonal_left_switch" then
					suffix = "diagonal_y_switch"
				elseif suffix == "y_switch" then
					suffix = "ty_switch"
				elseif suffix == "diagonal_y_switch" then
					suffix = "diagonal_ty_switch"
				elseif suffix == "ty_switch" then
					suffix = "4_crossing"
				elseif suffix == "diagonal_ty_switch" then
					suffix = "diagonal_4_crossing"
				elseif suffix == "4_crossing" then
					suffix = "skewed_4_crossing"
				elseif suffix == "diagonal_4_crossing" then
					suffix = "diagonal_skewed_4_crossing"
				elseif suffix == "skewed_4_crossing" then
					suffix = "6_crossing"
				elseif suffix == "diagonal_skewed_4_crossing" then
					suffix = "diagonal_6_crossing"
				elseif suffix == "6_crossing" then
					suffix = "8_crossing"
				elseif suffix == "diagonal_6_crossing" then
					suffix = "diagonal_8_crossing"
				elseif suffix == "8_crossing" then
					suffix = "slope_bottom"
				elseif suffix == "diagonal_8_crossing" then
					suffix = "diagonal_slope_bottom"
				elseif suffix == "slope_bottom" then
					suffix = "slope_top"
				elseif suffix == "diagonal_slope_bottom" then
					suffix = "diagonal_slope_top"
				elseif suffix == "slope_top" then
					suffix = "straight"
				elseif suffix == "diagonal_slope_top" then
					suffix = "diagonal"
				end
			end
			minetest.set_node(pos, {name = prefix..suffix, param2 = facedir})
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "nothing" then
			return
		end
		local pos = minetest.get_pointed_thing_position(pointed_thing)
		local node = minetest.get_node(pos)
		local is_rail = function()
			if minetest.get_item_group(node.name, "advcarts_rail") == 1 then
				return true
			else
				return false
			end
		end
		if is_rail() == true then
			local prefix = node.name:sub(0, node.name:find("000") + 2)
			local suffix = node.name:sub(node.name:find("000") + 3, node.name:len())
			local facedir = node.param2
			if suffix == "straight" then
				suffix = "diagonal"
			elseif suffix == "diagonal" then
				suffix = "straight"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "curve" then
				suffix = "diagonal_curve"
			elseif suffix == "diagonal_curve" then
				suffix = "curve"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "right_switch" then
				suffix = "diagonal_right_switch"
			elseif suffix == "diagonal_right_switch" then
				suffix = "right_switch"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "left_switch" then
				suffix = "diagonal_left_switch"
			elseif suffix == "diagonal_left_switch" then
				suffix = "left_switch"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "y_switch" then
				suffix = "diagonal_y_switch"
			elseif suffix == "diagonal_y_switch" then
				suffix = "y_switch"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "ty_switch" then
				suffix = "diagonal_ty_switch"
			elseif suffix == "diagonal_ty_switch" then
				suffix = "ty_switch"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "4_crossing" then
				suffix = "diagonal_4_crossing"
			elseif suffix == "diagonal_4_crossing" then
				suffix = "4_crossing"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "skewed_4_crossing" then
				suffix = "diagonal_skewed_4_crossing"
			elseif suffix == "diagonal_skewed_4_crossing" then
				suffix = "skewed_4_crossing"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "6_crossing" then
				suffix = "diagonal_6_crossing"
			elseif suffix == "diagonal_6_crossing" then
				suffix = "6_crossing"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "8_crossing" then
				suffix = "diagonal_8_crossing"
			elseif suffix == "diagonal_8_crossing" then
				suffix = "8_crossing"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "slope_bottom" then
				suffix = "diagonal_slope_bottom"
			elseif suffix == "diagonal_slope_bottom" then
				suffix = "slope_bottom"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			if suffix == "slope_top" then
				suffix = "diagonal_slope_top"
			elseif suffix == "diagonal_slope_top" then
				suffix = "slope_top"
				facedir = facedir + 1
				if facedir >= 4 then
					facedir = 0
				end
			end
			minetest.set_node(pos, {name = prefix..suffix, param2 = facedir})
		end
	end
})