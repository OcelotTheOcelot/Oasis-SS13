/obj/item/power_armor_module/plasma_generator
	name = "plasma generator module"
	desc = "Even more portable version of P.A.C.M.A.N.-type generator that allows to recharge the exoskeleton with energy of refined plasma."
	icon = 'Oasis/icons/powerarmor/modules/plasma_generator.dmi'
	slot = MODULE_SLOT_BACKPACK
	locks_hand = FALSE
	held_item_type = /obj/item/hydraulic_clamp
	render_priority = POWER_ARMOR_LAYER_BACKPACK_MODULE_FRONT

	var/sheet_type = /obj/item/stack/sheet/mineral/plasma  // What is used as the generator's fuel
	var/max_sheets = 10  // How many sheets does this module fit
	var/sheets = 0  // How many sheets this module currently stores
	var/accumulated_power = 0  // How much power this module should transfer to the exoskeleton
	var/charge_rate = 100  // How much power this module transfers to the exoskeleton every tick
	var/power_per_sheet = 5000  // How much power one sheet of fuel gives 

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
		if(part?.exoskeleton?.cell)
			START_PROCESSING(SSobj, src)
		return TRUE
	return ..()

/obj/item/power_armor_module/plasma_generator/process()
	var/obj/item/clothing/suit/armor/exoskeleton/E = part?.exoskeleton
	if(!E?.cell)
		return PROCESS_KILL
	if(accumulated_power > 0)
		accumulated_power -= E.charge(min(charge_rate, accumulated_power))
	else if(sheets > 0)
		sheets -= 1
		accumulated_power = power_per_sheet
	else
		return PROCESS_KILL

/obj/item/power_armor_module/plasma_generator/on_attached()
	if(part?.exoskeleton?.cell && (accumulated_power > 0 || sheets > 0))
		START_PROCESSING(SSobj, src)
