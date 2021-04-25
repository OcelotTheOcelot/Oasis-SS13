/datum/component/power_armor_set_bonus
	var/desc  // Description of the set bonus
	var/amount_for_full_set = POWER_ARMOR_FULL_SET  // How many armor pieces it takes to activate the bonus

/datum/component/power_armor_set_bonus/Initialize()
	if(!istype(parent, /obj/item/clothing/suit/armor/exoskeleton))
		return COMPONENT_INCOMPATIBLE

/* Parent as exoskeleton
Returns:
	the components's parent as an instance of /obj/item/clothing/suit/armor/exoskeleton or null 
*/
/datum/component/power_armor_set_bonus/proc/parent_as_exoskeleton()
	var/obj/item/clothing/suit/armor/exoskeleton/E = parent
	if(!istype(E))
		return null
	return E

/* Activate
Activates the bonus.
Used when the bonus is aquired by the exoskeleton, not the user.
*/
/datum/component/power_armor_set_bonus/proc/activate()
	return

/* Deactivate
Deactivates the bonus and suicides.
Used to revert changes done with activate proc.
*/
/datum/component/power_armor_set_bonus/proc/deactivate()
	var/mob/living/user = parent_as_exoskeleton()?.wearer
	if(user)
		on_wearer_left(user)
	RemoveComponent()
	return

/* On wearer entered
Called when the wearer enters the exoskeleton.
Accepts:
	user, the wearer
*/
/datum/component/power_armor_set_bonus/proc/on_wearer_entered(mob/living/user)
	return

/* On wearer left
Called when the wearer leaves the exoskeleton.
Accepts:
	user, the wearer
*/
/datum/component/power_armor_set_bonus/proc/on_wearer_left(mob/living/user)
	return
