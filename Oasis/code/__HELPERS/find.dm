/* Find tool
Checks if some tool is present nearby the user
This proc exists in order to not change exisiting /datum/component/personal_crafting/proc/check_tools,
because it wasn't flexible enough for this particular case.
Accepts:
	user, the mob to find the tool nearby,
	tool_behaviour, what type of tool that should be
	blacklist, a list of types of items to be ignored during the search
	radius_range, the range of the area to search in
Returns:
	found item or null
*/
proc/find_tool(mob/living/user, tool_behaviour, list/blacklist = null, radius_range = 1)
	if(!isturf(user.loc))
		return null
	for(var/obj/item/I in range(radius_range, user))
		if((I.flags_1 & HOLOGRAM_1) || (blacklist && (I.type in blacklist)))
			continue
		if((I.tool_behaviour == tool_behaviour))
			return I
	return null
