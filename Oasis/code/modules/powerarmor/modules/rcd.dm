/obj/item/power_armor_module/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A module containing a deployable RCD"
	icon = 'Oasis/icons/powerarmor/modules/rcd.dmi'
	slot = MODULE_SLOT_ARM
	locks_hand = FALSE
	switch_item_and_module_rendering = TRUE
	held_item_type = /obj/item/construction/rcd/power_armor_module

/obj/item/power_armor_module/rcd/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/deploy_tool/rcd
	return .

/datum/action/innate/power_armor/module/deploy_tool/rcd
	name = "Toggle RCD"
	icon_icon = 'Oasis/icons/powerarmor/modules/rcd.dmi'

/obj/item/construction/rcd/power_armor_module
	name = "rapid-construction-device (RCD)"
	desc = "A deployable RCD"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'Oasis/icons/powerarmor/modules/in_hands/module_items_lefthand.dmi'
	righthand_file = 'Oasis/icons/powerarmor/modules/in_hands/module_items_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = null

/obj/item/construction/rcd/power_armor_module/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)
