/obj/item/power_armor_module/mining_drill
	name = "mining drill module"
	desc = "A module containing a deployable plasma cutter powered by the module's exoskeleton."
	icon = 'Oasis/icons/powerarmor/modules/mining_drill.dmi'
	slot = MODULE_SLOT_ARM
	locks_hand = FALSE
	switch_item_and_module_rendering = TRUE
	held_item_type = /obj/item/pickaxe/drill/power_armor_module
	render_priority = POWER_ARMOR_LAYER_ARM_MODULES

/obj/item/power_armor_module/mining_drill/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/deploy_tool/mining_drill
	return .

/obj/item/power_armor_module/mining_drill/free_hand()
	..()
	var/obj/item/pickaxe/drill/power_armor_module/drill = held_item
	if(istype(drill) && drill.enabled)
		drill.toggle()

/datum/action/innate/power_armor/module/deploy_tool/mining_drill
	name = "Toggle mining drill"
	icon_icon = 'Oasis/icons/powerarmor/modules/mining_drill.dmi'

/obj/item/pickaxe/drill/power_armor_module
	name = "mining drill module"
	desc = "A powerful miining drill installed in the exoskeleton."
	icon = 'Oasis/icons/powerarmor/modules/mining_drill.dmi'
	lefthand_file = 'Oasis/icons/powerarmor/modules/in_hands/module_items_lefthand.dmi'
	righthand_file = 'Oasis/icons/powerarmor/modules/in_hands/module_items_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0

	var/faction_bonus_force = 8
	var/list/nemesis_factions = list("mining", "boss")

	var/obj/item/clothing/suit/armor/exoskeleton/exoskeleton  // We store the exoskeleton in this item separately for the sake of efficient processing

	var/enabled = FALSE  // Is the drill enabled
	var/power_consumption = 50  // How much power does the drill consume every tick when enabled

	// The following "enabled_..." variables represent the according values used when the drill is enabled. 
	icon_state = "held_item"
	var/enabled_icon_state = "held_item_active"
	item_state = "mining_drill"
	var/enabled_item_state = "mining_drill_active"
	var/enabled_hitsound = 'sound/weapons/circsawhit.ogg'
	force = 12
	var/enabled_force = 16
	toolspeed = 1
	var/enabled_toolspeed = 0.1

/obj/item/pickaxe/drill/power_armor_module/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)

// Restores the /obj/item/melee/transforming/attack
/obj/item/pickaxe/drill/power_armor_module/attack(mob/living/target, mob/living/carbon/human/user)
	var/nemesis_faction = FALSE
	if(LAZYLEN(nemesis_factions))
		for(var/F in target.faction)
			if(F in nemesis_factions)
				nemesis_faction = TRUE
				force += faction_bonus_force
				break
	. = ..()
	if(nemesis_faction)
		force -= faction_bonus_force

/* Toggle
Attempts to toggle the drill on and off.
Accepts:
	mode, pass TRUE to enable the drill and FALSE to disable it
Returns:
	TRUE if the drill was toggled, false otherwise
*/
/obj/item/pickaxe/drill/power_armor_module/proc/toggle()
	exoskeleton = GetComponent(/datum/component/power_armor_item)?.get_exoskeleton()
	if(!exoskeleton)
		QDEL_NULL(src)
		return FALSE

	if(!enabled)  // If it's turned off and we try to enable it with no energy, return.
		if(!exoskeleton.cell || exoskeleton.cell.charge <= power_consumption)
			return FALSE

	enabled = !enabled
	if(enabled)  // Better than an array of ternary operators
		force = enabled_force
		toolspeed = enabled_toolspeed
		hitsound = enabled_hitsound
		icon_state = enabled_icon_state
		item_state = enabled_item_state
		START_PROCESSING(SSobj, src)
	else
		force = initial(force)
		toolspeed = initial(toolspeed)
		hitsound = initial(hitsound)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		STOP_PROCESSING(SSobj, src)
	update_icon()
	exoskeleton.wearer?.update_inv_hands()
	return TRUE

/obj/item/pickaxe/drill/power_armor_module/attack_self(mob/user)
	if(toggle())
		to_chat(user, "<span class='notice'>You [enabled ? "en" : "dis"]able \the [src].</span>")
	else
		to_chat(user, "<span class='warning'>\The [src] can't be activated due to the lack of power!</span>")

/obj/item/pickaxe/drill/power_armor_module/process()
	. = ..()  // For we never know when the original drill's code will use process
	if(!exoskeleton)
		return PROCESS_KILL
	if(enabled && !exoskeleton.drain_power(power_consumption))
		toggle()
		return PROCESS_KILL
	return .
