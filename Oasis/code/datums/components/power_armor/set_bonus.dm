/datum/component/power_armor_set_bonus
	var/desc  // Description of the set bonus
	var/amount_for_full_set = POWER_ARMOR_FULL_SET  // How many armor pieces it takes to activate the bonus

/datum/component/power_armor_set_bonus/Initialize()
	if(!istype(parent, /obj/item/clothing/suit/armor/exoskeleton))
		return COMPONENT_INCOMPATIBLE
	activate()

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
	var/mob/living/user = parent_as_exoskeleton()?.wearer
	if(user)
		on_wearer_entered(user)

/datum/component/power_armor_set_bonus/RemoveComponent()
	deactivate()
	..()

/* Deactivate
Deactivates the bonus and suicides.
Used to revert changes done with activate proc.
*/
/datum/component/power_armor_set_bonus/proc/deactivate()
	var/mob/living/user = parent_as_exoskeleton()?.wearer
	if(user)
		on_wearer_left(user)

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

/datum/component/power_armor_set_bonus/spaceworthy
	desc = "The set of airtight armor parts provides protection against low pressure environments."
	amount_for_full_set = POWER_ARMOR_FULL_SET - 1  // Full set minus helmet
	var/clothing_flags_to_add = STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY  // What flags will be added to the exoskeleton when the bonus is active

/datum/component/power_armor_set_bonus/spaceworthy/activate()
	..()
	parent_as_exoskeleton()?.clothing_flags |= clothing_flags_to_add

/datum/component/power_armor_set_bonus/spaceworthy/deactivate()
	..()
	parent_as_exoskeleton()?.clothing_flags &= ~clothing_flags_to_add
