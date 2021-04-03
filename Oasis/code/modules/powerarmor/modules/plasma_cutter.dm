/obj/item/power_armor_module/plasma_cutter
	name = "plasma cutter module"
	desc = "A module containing a deployable plasma cutter powered by the module's exoskeleton."
	icon = 'Oasis/icons/powerarmor/modules/plasma_cutter.dmi'
	slot = MODULE_SLOT_ARM
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
	lefthand_file = 'Oasis/icons/powerarmor/modules/in_hands/module_items_lefthand.dmi'
	righthand_file = 'Oasis/icons/powerarmor/modules/in_hands/module_items_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	dead_cell = FALSE
	can_charge = FALSE
	tool_behaviour = null

/obj/item/gun/energy/plasmacutter/power_armor_module/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)

/obj/item/gun/energy/plasmacutter/power_armor_module/recharge_newshot()
	if (!ammo_type || !cell)
		return
	var/datum/component/power_armor_item/PAI = GetComponent(/datum/component/power_armor_item)
	if(!istype(PAI))
		return
	var/obj/item/stock_parts/cell/C = PAI.get_cell()
	if(!istype(C))
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(!shot)
		return
	if(C.use(shot.e_cost))
		cell.give(shot.e_cost)
	..()
