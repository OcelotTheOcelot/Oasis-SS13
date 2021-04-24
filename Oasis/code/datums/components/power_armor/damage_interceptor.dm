/datum/component/power_armor_damage_interceptor
	// Warning: the interceptor item should have "broken" field in property!
	var/obj/item/interceptor  // What item should take incoming damage instead of the covered limb

/datum/component/power_armor_damage_interceptor/Initialize(obj/item/P)
	if(!(istype(P, /obj/item/power_armor_part) || istype(P, /obj/item/clothing/head/helmet/power_armor)))
		return COMPONENT_INCOMPATIBLE
	interceptor = P

/* Validate interceptor
Helper proc.
Performs a sanity check for the interceptor covering the limb.
If the interceptor or the limb is invalid, removes itself form the parent and suicides.
Valid interceptor should either be a power_armor_part or located in the bodypart owner's inventory.
Returns:
	TRUE if the part is valid, FALSE otherwise
*/
/datum/component/power_armor_damage_interceptor/proc/validate_interceptor()
	var/mob/living/wearer
	
	var/obj/item/power_armor_part/part = interceptor 
	if(istype(part))
		wearer = part?.exoskeleton?.wearer
	else
		wearer = interceptor.loc
	
	if(wearer != parent_as_bodypart()?.owner)
		RemoveComponent()
		return FALSE
	return TRUE

/* Parent as bodypart
Helper proc.
Converts the component's parernt to a bodypart. If the parent is not a valid bodypart, removes itself form the parent and suicides.
Returns:
	The component's parent as bodypart in case of successful conversion, null otherwise
*/
/datum/component/power_armor_damage_interceptor/proc/parent_as_bodypart()
	var/obj/item/bodypart/BP = parent
	if(!istype(BP))
		RemoveComponent()
		return null
	return BP

/* Is broken
Checks if the interceptor is broken.
Returns:
	TRUE if the interceptor is broken, FALSE otherwise
*/
/datum/component/power_armor_damage_interceptor/proc/is_broken()
	// Always treat using ':' operator like a deal with the Devil. Let's not use that lest He capture our souls.
	// return interceptor?:broken || FALSE

	if(istype(interceptor, /obj/item/power_armor_part))
		var/obj/item/power_armor_part/as_part = interceptor
		return as_part.broken
	if(istype(interceptor, /obj/item/clothing/head/helmet/power_armor))
		var/obj/item/clothing/head/helmet/power_armor/as_helmet = interceptor
		return as_helmet.broken
	return FALSE

/* Is protecting
Checks if the interceptor provides enough protection for the limb to intercept incoming damage.
Just inverts is_broken's return for now, but that may be changed later.  
Returns:
	TRUE if the interceptor is protecting, FALSE otherwise
*/
/datum/component/power_armor_damage_interceptor/proc/is_protecting()
	return !is_broken()

/* Intercept damage
This proc is responsible for rerouting incoming damage from the bodypart to the power armor part.
Accepts:
	brute, the incoming BRUTE damage
	burn, the incoming BURN damage
	stamina, the incoming STAMINA damage
Returns:
	TRUE if the damage has been absorbed, FALSE otherwise
*/
/datum/component/power_armor_damage_interceptor/proc/intercept_damage(brute, burn, stamina)
	if(!validate_interceptor())
		return FALSE
	var/obj/item/bodypart/BP = parent_as_bodypart()
	if(!BP)
		return FALSE
	if(!is_protecting())
		return FALSE

	to_chat(BP.owner, "<span class='boldwarning'>DEBUG: [interceptor] intercepts damage incoming to [BP]: \[[brute]/[burn]/[stamina]\]...</span>")
	
	/* Believe me it would be quite painful to overhaul the entire hitsound system, therefore we have sound_effect=FALSE
	Later, we could transfer hitsound from item_attack to mobs and objs attacked_by proc, but this is not the prerogative for now.  
	Even sand golems don't have custom hitsounds, come on!.. 
	*/
	if(brute > 0)
		interceptor.take_damage(brute, BRUTE, sound_effect=FALSE)
	if(burn > 0)
		interceptor.take_damage(burn, BURN, sound_effect=FALSE)

	BP.receive_damage(0, 0, stamina, ignore_interception=TRUE)
	return TRUE
