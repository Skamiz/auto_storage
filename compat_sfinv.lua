local modname = minetest.get_current_modname()

-- add button to main inventory page
local orig_get = sfinv.pages["sfinv:crafting"].get

if minetest.get_modpath("cicrev") then
	sfinv.override_page("sfinv:crafting", {
	    get = function(self, player, context)
	        local fs = orig_get(self, player, context)
			return fs .. ""
			.. "image_button[9,4;1,1;store_to_nearby.png;store_to_nearby;]"
			.. "tooltip[store_to_nearby;Store to nearby]"
			.. "container[0.25,5.25]"
			.. auto_storage.get_locked_highlight(player)
			.. "container_end[]"
	    end
	})
else
	sfinv.override_page("sfinv:crafting", {
	    get = function(self, player, context)
	        local fs = orig_get(self, player, context)
			return fs .. ""
			.. "image_button[7,4;1,1;store_to_nearby.png;store_to_nearby;]"
			.. "tooltip[store_to_nearby;Store to nearby]"
	    end
	})
end

-- add sfinv tab to configure locked slots
sfinv.register_page(modname .. ":config", {
    title = "Slot Conf",
    get = function(self, player, context)

		local locked = auto_storage.slot_conf[player:get_player_name()]
		local inv = player:get_inventory()
        local inv_size = inv:get_size("main")
		local fs = {
			"formspec_version[6]",
			"size[10.75,6.25]",
			"label[0.5,0.5;Configure which inventory slots can be automatically stored to nearby containers.]",
			"container[0.5,1]",
			auto_storage.get_slot_conf_formspec(player, auto_storage.inv_width),
			"container_end[]",
			sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
		}

		return table.concat(fs)
    end
})

-- form_name for inventory formspec is an empty string
auto_storage.register_callback("", function(player) sfinv.set_page(player, modname .. ":config") end)
