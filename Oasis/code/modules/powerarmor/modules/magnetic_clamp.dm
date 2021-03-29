/obj/item/power_armor_module/magnetic_clamp
	name = "magnetic clamp module"
	desc = "A clamp that uses powerful magnets for carrying heavy loads."
	icon = 'Oasis/icons/powerarmor/modules/hydraulic_clamp.dmi'
	slot = MODULE_SLOT_ARM
	locks_hand = FALSE
	held_item_type = /obj/item/hydraulic_clamp
	// tier = POWER_ARMOR_GRADE_ADVANCED

/obj/item/power_armor_module/magnetic_clamp/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/deploy_tool

/obj/item/magnetic_clamp
	name = "magnetic clamp"
	desc = "A clamp that uses powerful magnets for carrying heavy loads."
	icon = 'Oasis/icons/powerarmor/modules/hydraulic_clamp.dmi'
	icon_state = "held_item"
	w_class = WEIGHT_CLASS_HUGE
	force = 12
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/magnetic_clamp/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)
