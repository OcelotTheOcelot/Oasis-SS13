/datum/power_armor_overlay
	var/mutable_appearance/appearance  // The mutable_appearance of the overlay 
	var/priority  // The lesser this value, the earlier this overlay will be drawn

/datum/power_armor_overlay/Destroy()
	QDEL_NULL(appearance)
