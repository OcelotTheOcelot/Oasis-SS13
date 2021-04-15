#define INJECTION_MODE_MANUAL_ONLY 0
#define INJECTION_MODE_ON_CRIT 1
#define INJECTION_MODE_ON_DEATH 2

#define INJECTION_MODES 3

/obj/item/power_armor_module/auto_repair_kit
	name = "repair module"
	desc = "An automatic repair system that analyzes the power armor's integrity and fixes damaged parts."
	icon = 'Oasis/icons/powerarmor/modules/auto_repair_kit.dmi'
	slot = MODULE_SLOT_BACKPACK
	render_priority = POWER_ARMOR_LAYER_BACKPACK_MODULE_FRONT

	var/cost_per_point = 50  // How much power repairing one HP costs
	var/max_hp_per_tick = 10  // How many HPs can be repaired at a single tick
	var/active = FALSE  // If the system is repairing the armor right now

/obj/item/power_armor_module/auto_repair_kit/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/toggle_auto_repair
	return .

/obj/item/power_armor_module/auto_repair_kit/create_overlays_for_part_slot(part_slot)
	. = ..()
	if(part_slot != slot)
		return ..()
	var/datum/power_armor_overlay/PAO = new
	PAO.priority = POWER_ARMOR_LAYER_CHEST_MODULE_BACK
	PAO.appearance = mutable_appearance(icon, "torso_back")
	. += PAO
	return .

/obj/item/power_armor_module/auto_repair_kit/on_wearer_entered()
	..()
	state("Automatic repair system is ready to serve. Never surrender!")

/obj/item/power_armor_module/auto_repair_kit/on_wearer_left()
	..()
	state("It was my honor to serve you, commander!")

/obj/item/power_armor_module/auto_repair_kit/process()
	var/list/damaged_parts = analyze_integrity()
	if(damaged_parts.len <= 0)
		state("The repair is complete.")
		deactivate()
		return PROCESS_KILL
	var/repair_points = max_hp_per_tick
	for(var/obj/item/power_armor_part/P in damaged_parts)
		if(repair_points <= 0)
			break
		var/to_repair = CLAMP(P.max_integrity - P.obj_integrity, 0, repair_points)
		if(!part?.exoskeleton?.drain_power(to_repair * cost_per_point))
			state("\The [src] has ran out of power, commander! Field repair is recommended.")
			deactivate()
			return PROCESS_KILL
		repair_points -= P.repair(to_repair)

/* Toggle auto repair
Turns the automatic repair system on and off.
*/
/obj/item/power_armor_module/auto_repair_kit/proc/toggle_auto_repair()
	if(active)
		deactivate()
	else
		activate()

/* Activate
Activates the automatic repair system.
*/
/obj/item/power_armor_module/auto_repair_kit/proc/activate()
	if(active)
		return
	if((part?.exoskeleton?.cell?.charge || 0) <= cost_per_point)
		state("Not enough power for repair procedures, commander! Field repair is recommended.")
		deactivate()
		return
	var/list/damaged_parts = analyze_integrity()
	if(damaged_parts.len <= 0)
		state("The analysis is complete, commander. All parts of the armor are intact. No repairs required.")
		deactivate()
		return
	active = TRUE
	part?.exoskeleton?.wearer?.update_action_buttons()
	state("The analysis is complete, commander. Proceeeding to repair...")
	START_PROCESSING(SSobj, src)

/* Deactivate
Deactivates the automatic repair system.
*/
/obj/item/power_armor_module/auto_repair_kit/proc/deactivate()
	if(!active)
		return
	active = FALSE
	part?.exoskeleton?.wearer?.update_action_buttons()
	state("Deactivating the system...")
	STOP_PROCESSING(SSobj, src)

/* Analyze intergrity
Analyzes the integrity of each part of the exoskeleton.
Returns:
	list of every damaged part sorted by intergity in ascending orded
*/
/obj/item/power_armor_module/auto_repair_kit/proc/analyze_integrity()
	var/list/damaged_parts = new
	var/list/parts = part?.exoskeleton?.parts
	if(!parts)
		return damaged_parts
	for(var/slot in parts)
		if(!parts[slot])
			continue
		if(parts[slot].obj_integrity < parts[slot].max_integrity)
			damaged_parts += parts[slot]
	damaged_parts = sortTim(damaged_parts, cmp=/proc/cmp_power_armor_parts_integrity, associative = FALSE)
	return damaged_parts

/* State
Helper proc, makes the module state stuff in the exoskeleton wearer's chat.
Accepts:
	text, the text to print in the chat
*/
/obj/item/power_armor_module/auto_repair_kit/proc/state(text)
	if(part?.exoskeleton?.wearer)
		to_chat(part.exoskeleton.wearer, "<span class='robot'>\The [src] states, \"[text]\".</span>")

/datum/action/innate/power_armor/module/toggle_auto_repair
	name = "Toggle auto repair"
	desc = "Turns the automatic repair system on and off."
	icon_icon = 'Oasis/icons/powerarmor/modules/auto_repair_kit.dmi'
	button_icon_state = "repair_action_off"

/datum/action/innate/power_armor/module/toggle_auto_repair/Activate()
	if(!(owner.stat == CONSCIOUS || owner.stat == SOFT_CRIT))
		return
	var/obj/item/power_armor_module/auto_repair_kit/M = module
	if(istype(M))
		M.toggle_auto_repair()
		button_icon_state = "repair_action_[M.active ? "on" : "off"]"
		UpdateButtonIcon()
