// <WARNING! IT'S NOT IMPLEMENTED YET!!!>
/* Intercept damage
Checks if the limb has power armor part covering it. If it has, applies damage to the part.
Accepts:
	bodypart, the bodypart receiving damage
	???
Returns:
	TRUE if the damage should be intercepted, FALSE otherwise
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/intercept_damage(obj/item/bodypart/bodypart, damage, damagetype)
	to_chat(bodypart.owner, "<span class='notice'>Intercepting damage received by [bodypart]...</span>")
	var/slot = zone_to_exoskeleton_slot(bodypart.body_zone)
	var/obj/item/power_armor_part/P = parts[slot]
	if(istype(P))
		P.take_damage(damage, damagetype)
		return TRUE
	return FALSE



	// /* Power armor damage interception
	// The only reason I didn't use armor system  to intercept damage is because it would require refactoring of the entire armor system:
	// armor checks alone won't allow to apply damage to the parts properly,
	// and the applying damage won't allow to determine what body part this damage is applied to.
	// – Ocelot */
	// if(HAS_TRAIT(src, TRAIT_EXOSKELETON))
	// 	var/obj/item/bodypart/BP = get_bodypart(check_zone(def_zone))
	// 	if(istype(BP))
	// 		var/obj/item/clothing/suit/armor/exoskeleton/E = wear_suit
	// 		if(istype(E) && E.intercept_damage(BP, damage, damagetype))
	// 			return