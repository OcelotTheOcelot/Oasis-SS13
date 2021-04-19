/datum/component/power_armor_set_bonus
	var/name = "no_set"  // The name of the set; must be unique
	var/desc  // Description of the set bonus
	var/amount_for_full_set = 6  // How many armor pieces it takes to activate the bonus

/datum/component/power_armor_set_bonus/Initialize()
	if(!istype(parent, /obj/item/clothing/suit/armor/exoskeleton))
		return COMPONENT_INCOMPATIBLE

/*
Activates the bonus.
*/
/datum/component/power_armor_set_bonus/proc/activate()
	return

/* Deactivate
Deactivates the bonus and suicides.
*/
/datum/component/power_armor_set_bonus/proc/deactivate()
	QDEL_NULL(src)
	return
