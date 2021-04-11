/datum/component/power_armor_damage_interceptor
	var/obj/item/power_armor_part/part  // The part covering the limb owning this component

/datum/component/power_armor_damage_interceptor/Initialize(obj/item/power_armor_part/P)
	if(!istype(P))
		return COMPONENT_INCOMPATIBLE
	// if(!parent_as_bodypart())
		// return COMPONENT_INCOMPATIBLE
	part = P

/* Validate part
Helper proc.
Performs a sanity check for the part covering the limb. If the part or the limb is invalid, removes itself form the parent and suicides.
Returns:
	TRUE if the part is valid, FALSE otherwise
*/
/datum/component/power_armor_damage_interceptor/proc/validate_part()
	if(part?.exoskeleton?.wearer != parent_as_bodypart()?.owner)
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
	
	var/obj/item/bodypart/testbp = parent
	to_chat(testbp?.owner, "<span class='boldwarning'>DEBUG: 1!</span>")
	
	if(!validate_part())
		return FALSE

	to_chat(testbp?.owner, "<span class='boldwarning'>DEBUG: 2!</span>")

	if(part.broken)
		return FALSE
	
	to_chat(testbp?.owner, "<span class='boldwarning'>DEBUG: 3!</span>")

	var/obj/item/bodypart/BP = parent_as_bodypart()
	if(!BP)
		return FALSE
	to_chat(BP.owner, "<span class='boldwarning'>DEBUG: [part] intercepts damage incoming to [BP]: \[[brute]/[burn]/[stamina]\]...</span>")
	if(brute > 0)
		part.take_damage(brute, BRUTE)
	if(burn > 0)
		part.take_damage(burn, BURN)

	BP.receive_damage(0, 0, stamina, ignore_interception=TRUE)
	return TRUE
