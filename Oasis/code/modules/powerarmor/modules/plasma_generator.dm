/obj/item/power_armor_module/plasma_generator
	name = "plasma generator module"
	desc = "Even more portable version of P.A.C.M.A.N.-type generator that allows to recharge the exoskeleton with energy of refined plasma."
	icon = 'Oasis/icons/powerarmor/modules/plasma_generator.dmi'
	slot = MODULE_SLOT_BACKPACK
	locks_hand = FALSE
	held_item_type = /obj/item/hydraulic_clamp
	render_priority = POWER_ARMOR_LAYER_BACKPACK_MODULE_FRONT

	var/sheet_type = /obj/item/stack/sheet/mineral/plasma  // What is used as the generator's fuel
	var/max_sheets = 10
	var/sheets = 0

/obj/item/power_armor_module/self_destruction/create_overlays_for_part_slot(part_slot)
	. = ..()
	if(part_slot != slot)
		return ..()
	var/datum/power_armor_overlay/PAO = new
	PAO.priority = POWER_ARMOR_LAYER_CHEST_MODULE_BACK
	PAO.appearance = mutable_appearance(icon, "torso_back")
	. += PAO
	return .

// Mostly restores the P.A.C.M.A.N.'s code
/obj/item/power_armor_module/plasma_generator/try_apply_item(obj/item/I, mob/user)
	if(istype(I, sheet_type))
		var/obj/item/stack/addstack = I
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount <= 0)
			to_chat(user, "<span class='warning'>\The [src] is full!</span>")
			return TRUE
		to_chat(user, "<span class='notice'>You add [amount] sheets to \the [src]. It now contains [sheets] sheets.</span>")
		sheets += amount
		addstack.use(amount)
		return TRUE
	return ..()
