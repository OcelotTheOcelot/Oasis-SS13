/* Zone to exoskeleton slot
Accepts:
	zone, body_zone that a player could target
Returns:
	exoskeleton slot matching the selected slot
*/
/proc/zone_to_exoskeleton_slot(zone)
	switch(zone)
		if(BODY_ZONE_PRECISE_GROIN)
			. = EXOSKELETON_SLOT_TORSO
		if(BODY_ZONE_CHEST)
			. = EXOSKELETON_SLOT_TORSO
		if(BODY_ZONE_L_ARM)
			. = EXOSKELETON_SLOT_L_ARM
		if(BODY_ZONE_R_ARM)
			. = EXOSKELETON_SLOT_R_ARM
		if(BODY_ZONE_L_LEG)
			. = EXOSKELETON_SLOT_L_LEG
		if(BODY_ZONE_R_LEG)
			. = EXOSKELETON_SLOT_R_LEG
	return .
