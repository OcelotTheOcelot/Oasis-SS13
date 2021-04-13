#define SELF_DESTRUCTION_MODE_MANUAL_ONLY 0
#define SELF_DESTRUCTION_MODE_ON_UNEQUIP 1
#define SELF_DESTRUCTION_MODE_ON_CRIT 2
#define SELF_DESTRUCTION_MODE_ON_DEATH 3

#define SELF_DESTRUCTION_MODES 2  // <TODO> Set to 4 only when other mods are implemented!!

/obj/item/power_armor_module/self_destruction
	name = "self-destruction module"
	desc = "A device containing explosive charge that can be triggered manually or under certain conditions."  //<TODO> implement the other mods! " Use <b>multitool</b> to specify those conditions."
	icon = 'Oasis/icons/powerarmor/modules/self_destruction.dmi'
	slot = MODULE_SLOT_CHESTPLATE
	locks_hand = FALSE
	held_item_type = /obj/item/hydraulic_clamp
	render_priority = POWER_ARMOR_LAYER_CHEST_MODULE_FRONT

	var/detonation_mode = SELF_DESTRUCTION_MODE_MANUAL_ONLY

/obj/item/power_armor_module/self_destruction/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/self_destruction
	return .

/obj/item/power_armor_module/self_destruction/emp_reaction()
	trigger()

/* Trigger
Makes the module go boom
*/
/obj/item/power_armor_module/self_destruction/proc/trigger()
	if(part && part.exoskeleton)
		part.exoskeleton.visible_message("<span class='boldwarning'>Warning: self-destruction sequence has been initiated!</span>")
	explosion(loc, 1, 2, 4, 3,
		adminlog = TRUE,
		ignorecap = FALSE,
		flame_range = 1,
		smoke = TRUE
		)
	QDEL_NULL(src)

/obj/item/power_armor_module/self_destruction/on_wearer_left()
	..()
	if(detonation_mode == SELF_DESTRUCTION_MODE_ON_UNEQUIP)
		trigger()

/obj/item/power_armor_module/self_destruction/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		detonation_mode = (detonation_mode + 1) % SELF_DESTRUCTION_MODES
		var/mode_desc = "only manually"
		switch(detonation_mode)
			if(SELF_DESTRUCTION_MODE_ON_UNEQUIP)
				mode_desc = "when the wearer leaves the exoskeleton"
			if(SELF_DESTRUCTION_MODE_ON_CRIT)
				mode_desc = "when the wearer reaches critical health condition"
			if(SELF_DESTRUCTION_MODE_ON_CRIT)
				mode_desc = "when the wearer dies"

		to_chat(user, "<span class='notice'>\The [src] will now be triggered [mode_desc].</span>")

/datum/action/innate/power_armor/module/self_destruction
	name = "Initiate self-destruction"
	desc = "Launches the self-destruction system, resulting in a huge explosion. The exoskeleton most probably will be completely destroyed."
	icon_icon = 'Oasis/icons/powerarmor/modules/self_destruction.dmi'
	button_icon_state = "self_destruction_action"

/datum/action/innate/power_armor/module/self_destruction/Activate()
	var/obj/item/power_armor_module/self_destruction/M = module
	if(istype(M))
		M.trigger()

#undef SELF_DESTRUCTION_MODE_MANUAL_ONLY
#undef SELF_DESTRUCTION_MODE_ON_UNEQUIP
#undef SELF_DESTRUCTION_MODE_ON_CRIT
#undef SELF_DESTRUCTION_MODE_ON_DEATH

#undef SELF_DESTRUCTION_MODES
