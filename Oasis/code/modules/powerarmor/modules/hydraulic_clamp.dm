/obj/item/power_armor_module/hydraulic_clamp
	name = "hydraulic clamp module"
	desc = "A powerful hydraulic clamp capable of carrying heavy loads. Can only be installed on p5000pwl arm."
	icon = 'Oasis/icons/powerarmor/modules/hydraulic_clamp.dmi'
	slot = MODULE_SLOT_ARM
	locks_hand = TRUE
	held_item_type = /obj/item/hydraulic_clamp

/obj/item/power_armor_module/hydraulic_clamp/can_be_attached(obj/item/power_armor_part/part)
	if(istype(part, /obj/item/power_armor_part/l_arm/p5000pwl) || istype(part, /obj/item/power_armor_part/r_arm/p5000pwl))
		return TRUE
	return FALSE

/obj/item/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "A powerful hydraulic clamp capable of carrying heavy loads."
	icon = 'Oasis/icons/powerarmor/modules/hydraulic_clamp.dmi'
	icon_state = "held_item"
	w_class = WEIGHT_CLASS_HUGE
	force = 12
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/hydraulic_clamp/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)
