/datum/component/faction_damage_resistance
	var/multiplier  // The number the incoming damage is multiplied by 
	var/list/factions = new  // List of factions to apply damage resistance for

/datum/component/faction_damage_resistance/Initialize(list/factions = list(), multiplier = 0.8)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.factions = factions
	src.multiplier = multiplier

/* Get multiplier
Calculates the multiplyier for the damage taken by the given mob
Accepts:
	M, the attacking mob
Returns:
	multiplier if the mob's faction is in factions or 1
*/
/datum/component/faction_damage_resistance/proc/get_multiplier(mob/living/M)
	if(!((M.faction & factions).len))
		return 1
	return multiplier