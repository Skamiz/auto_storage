--[[
	Wouldn't it be cool to have this mod as an unlockble upgrade?
	Yes, yes it would.
	Someone should get to it.
--]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

auto_storage = {}
dofile(modpath .. "/compat_storage.lua")


auto_storage.inv_width = 8
-- cubic storage range from the node the players head is in
auto_storage.range = tonumber(minetest.settings:get("auto_storage_range")) or 2
auto_storage.visual = minetest.settings:get_bool("auto_storage_visual", true)
local slot_conf = {}
auto_storage.slot_conf = slot_conf


local function save_locked(player)
    local meta = player:get_meta()
    meta:set_string("lock_conf", minetest.serialize(slot_conf[player:get_player_name()]))
end

minetest.register_on_joinplayer(
    function(player)
        local name = player:get_player_name()
        local inv = player:get_inventory()
        local inv_size = inv:get_size("main")

        local meta = player:get_meta()

        local locked = minetest.deserialize(meta:get("lock_conf") or "") or {}
        for i = 1, inv_size do
            if locked[i] == nil then
                locked[i] = i <= auto_storage.inv_width
            end
        end

        slot_conf[name] = locked
    end
)
minetest.register_on_leaveplayer(function(player, timed_out)
	local name = player:get_player_name()
	slot_conf[name] = nil
end)

minetest.register_entity(modname .. ":display_object", {
	initial_properties = {
		visual = "item",
		physical = false,
		pointable = false,
		static_save = false,
		shaded = false,
		visual_size = vector.new(0.2, 0.2, 0.2),
		glow = -1,
		-- wield_item = "itemname",
	},
	on_activate = function(self, staticdata, dtime_s)
		self.time = 0
	end,

	on_step = function(self, dtime, moveresult)
		self.time = self.time + dtime

		if self.time > 0.5 and not self.reorient then
			self.reorient = true
			self.object:set_velocity(self.target_pos - self.object:get_pos())
		elseif self.time > 1.5 then
			self.object:remove()
		end
	end,
})


local function spawn_display_item(player, target_pos, stack)
	local p_pos = player:get_pos()
	p_pos.y = p_pos.y + 1


	local d_obj = minetest.add_entity(p_pos, modname .. ":display_object")

	d_obj:set_properties({wield_item = stack:get_name()})
	d_obj:get_luaentity().target_pos = target_pos

	-- start in a random direction so all the items don't overlap
	local random_dir = vector.new(math.random()-0.5, math.random()-0.5, math.random()-0.5):normalize()
	d_obj:set_velocity(random_dir)
end


-- stores items from players inventory to nearby 'storage' nodes
auto_storage.store_to_nearby = function(player, range)
    local name = player:get_player_name()
    local p_inv = player:get_inventory()
    local locked = slot_conf[name]

	range = range or auto_storage.range

	local exact_pos = player:get_pos()
    local p_pos = exact_pos:round()
    p_pos.y = p_pos.y + 1

    local storage = minetest.find_nodes_in_area(p_pos:subtract(range), p_pos:add(range), {"group:storage"}, false)

	table.sort(storage, function(a, b)
		return exact_pos:distance(a) < exact_pos:distance(b)
	end)

    for _, s_pos in pairs(storage) do
		if not minetest.is_protected(s_pos, name) then
			local list = "main"
			local n_name = minetest.get_node(s_pos).name
			if auto_storage.compat[n_name] then list = auto_storage.compat[n_name] end

	        local s_inv = minetest.get_inventory({type = "node", pos = s_pos})

	        for i, lock in ipairs(locked) do
	            if not lock then
	                local stack = p_inv:get_stack("main", i)
	                if not stack:is_empty() then
	                    if s_inv:contains_item(list, stack:get_name(), false) then
	                        local leftover = s_inv:add_item(list, stack)

							if leftover:get_count() < stack:get_count() then
								if auto_storage.visual then
									spawn_display_item(player, s_pos, stack)
								end
								p_inv:set_stack("main", i, leftover)
							end
	                    end
	                end
	            end
	        end
		end
    end
end

-- returns formspec for setting which slots are locked
-- can be embeded into other formspecs
local p = 1/16
auto_storage.get_slot_conf_formspec = function(player, inv_width)
	inv_width = inv_width or auto_storage.inv_width
	local locked = slot_conf[player:get_player_name()]
	local inv = player:get_inventory()
	local inv_size = inv:get_size("main")
	local fs = {}

	for i = 1, inv_size do
		local image = locked[i] and "locked.png" or "unlocked.png"
		local x = (i-1) % inv_width
		local x_pos = x + ((x) * 0.25)
		local y = math.floor((i-1) / inv_width)
		local y_pos = y + ((y) * 0.25)
		-- locking button
		fs[#fs + 1] = "item_image_button[" .. x_pos .. "," .. y_pos .. ";1,1;" .. inv:get_stack("main", i):get_name() .. ";slot_" .. i .. ";]"
		fs[#fs + 1] = "tooltip[slot_" .. i .. ";Slot " .. i .. " - " .. (locked[i] and "Locked" or "Unlocked") .. "]"

		fs[#fs + 1] = "image[" .. x_pos - p .. "," .. y_pos - p .. ";1.125,1.125;" .. image .. "]"
	end


	return table.concat(fs)
end

-- returns formspec which can be overlaid over the normal inventory to make it easier to keep in mind which slots are locked
auto_storage.get_locked_highlight = function(player, inv_width)
	inv_width = inv_width or auto_storage.inv_width
	local locked = slot_conf[player:get_player_name()]
	local inv = player:get_inventory()
	local inv_size = inv:get_size("main")
	local fs = {}

	if not locked then return "" end

	for i = 1, inv_size do
		if locked[i] then
			local x = (i-1) % inv_width
			local x_pos = x + ((x) * 0.25)
			local y = math.floor((i-1) / inv_width)
			local y_pos = y + ((y) * 0.25)

			fs[#fs + 1] = "image[" .. x_pos .. "," .. y_pos .. ";1,1;locked_slot.png]"
		end
	end

	return table.concat(fs)
end

-- show a barebones formspec for configuring locked slots
auto_storage.show_slot_conf_formspec = function(player)
	local name = player:get_player_name()
	local fs = {
		"formspec_version[6]",
		"size[10.75,6.25]",
		"label[0.5,0.5;Configure which inventory slots can be automatically stored to nearby containers.]",
		"container[0.5,1]",
		auto_storage.get_slot_conf_formspec(player, auto_storage.inv_width),
		"container_end[]",
	}
	fs = table.concat(fs)
	if cfs then
		fs = cfs.style_formspec(fs, player)
	end
	minetest.show_formspec(name, modname .. ":slot_conf", fs)
end

-- callback should show updated formspec
function auto_storage.register_callback(form_name, callback)
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname ~= form_name then return end

		local inv = player:get_inventory()
		local inv_size = inv:get_size("main")
	    if fields["store_to_nearby"] then
	        auto_storage.store_to_nearby(player)
	        return true
	    end
	    for i = 1, inv_size do
	        if fields["slot_" .. i] then
				local name = player:get_player_name()
				local locked = slot_conf[name]
	            locked[i] = not locked[i]
	            save_locked(player)

				if callback then callback(player) end
	            return true
	        end
	    end
	end)
end

minetest.register_chatcommand("auto_storage", {
	params = "config | store",
	description = "Display slot configuration for auto_storage.",
	-- privs = {},
	func = function(name, param)
		if param == "config" then
			local player = minetest.get_player_by_name(name)
			auto_storage.show_slot_conf_formspec(player)
		elseif param == "store" then
			auto_storage.store_to_nearby(minetest.get_player_by_name(name))
		else
			minetest.chat_send_player(name, "/auto_storage config - configure which inventory slots can be stored")
			minetest.chat_send_player(name, "/auto_storage store - automatically store items to nearby containers")
		end
	end,
})
auto_storage.register_callback(modname .. ":slot_conf", auto_storage.show_slot_conf_formspec)

if minetest.get_modpath("sfinv") then
	dofile(modpath .. "/compat_sfinv.lua")
end
