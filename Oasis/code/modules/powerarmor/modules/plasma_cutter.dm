/obj/item/power_armor_module/plasma_cutter
	name = "plasma cutter module"
	desc = "A module containing a deployable plasma cutter powered by the module's exoskeleton."
	icon = 'Oasis/icons/powerarmor/modules/plasma_cutter.dmi'
	slot = MODULE_SLOT_ARM_UNIVERSAL
	locks_hand = FALSE
	held_item_type = /obj/item/gun/energy/plasmacutter/power_armor_module
	render_priority = POWER_ARMOR_LAYER_ARM_MODULES

/obj/item/power_armor_module/plasma_cutter/create_module_actions()
	. = ..()
	var/datum/action/innate/power_armor/module/deploy_tool/plasma_cutter/A = new 
	A.module = src
	. += A
	return .

/datum/action/innate/power_armor/module/deploy_tool/plasma_cutter
	name = "Toggle plasma cutter"
	icon_icon = 'Oasis/icons/powerarmor/modules/plasma_cutter.dmi'
	button_icon_state = "held_item"

/obj/item/gun/energy/plasmacutter/power_armor_module
	name = "plasma cutter module"
	desc = "A deployable plasma cutter that uses the exoskeleton's energy."
	icon = 'Oasis/icons/powerarmor/modules/plasma_cutter.dmi'
	icon_state = "held_item"
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/gun/energy/plasmacutter/power_armor_module/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)
