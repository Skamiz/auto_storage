-- add nodes here to which items can be auto stored
auto_storage.compat = {
	-- [modname:nodename] = "invenotry list name"
	["default:chest"] = "main",
	["default:chest_locked"] = "main",
	["portableboxes:portableboxes"] = "inbox",
}

local function add_group(item, group, rating)
	if not minetest.registered_items[item] then return end

	local groups = minetest.registered_items[item].groups or {}
	groups[group] = rating or 1

	minetest.override_item(item, {
		groups = groups,
	})
end

for node, _ in pairs(auto_storage.compat) do
	add_group(node, "storage")
end
