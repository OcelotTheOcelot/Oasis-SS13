#define SELF_DESTRUCTION_MODE_MANUAL_ONLY 0
#define SELF_DESTRUCTION_MODE_ON_UNEQUIP 1
#define SELF_DESTRUCTION_MODE_ON_CRIT 2
#define SELF_DESTRUCTION_MODE_ON_DEATH 3

#define SELF_DESTRUCTION_MODES 4

/obj/item/power_armor_module/self_destruction
	name = "self-destruction module"
	desc = "A device containing explosive charge that can be triggered manually or under certain conditions. Use <b>multitool</b> to specify those conditions."
	icon = 'Oasis/icons/powerarmor/modules/self_destruction.dmi'
	slot = MODULE_SLOT_CHESTPLATE
	locks_hand = FALSE
	render_priority = POWER_ARMOR_LAYER_CHEST_MODULE_FRONT

	var/detonation_mode = SELF_DESTRUCTION_MODE_MANUAL_ONLY  // What triggers the self-destruction system 
	var/delay = 30 // The delay before the explosion 

/obj/item/power_armor_module/self_destruction/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/self_destruction
	return .

/obj/item/power_armor_module/self_destruction/emp_reaction()
	trigger()

/* Trigger
Starts the countdown befoore the explosion
*/
/obj/item/power_armor_module/self_destruction/proc/trigger()
	part?.exoskeleton?.wearer?.visible_message("<span class='boldwarning'>Warning: self-destruction sequence has been initiated!</span>")
	// playsound(src, 'sound/weapons/armbomb.ogg', 100, FALSE)
	playsound(src, 'sound/machines/triple_beep.ogg', 100, FALSE)
	addtimer(CALLBACK(src, .proc/explode), delay, TIMER_UNIQUE)

/* Explode
Makes the module go boom
*/
/obj/item/power_armor_module/self_destruction/proc/explode()
	explosion(loc, 1, 2, 4, 3,
		adminlog = TRUE,
		ignorecap = FALSE,
		flame_range = 1,
		smoke = TRUE
		)
	QDEL_NULL(src)

/obj/item/power_armor_module/self_destruction/on_wearer_entered()
	..()
	if(detonation_mode == SELF_DESTRUCTION_MODE_ON_CRIT || detonation_mode == SELF_DESTRUCTION_MODE_ON_DEATH)
		START_PROCESSING(SSobj, src)

/obj/item/power_armor_module/self_destruction/on_wearer_left()
	..()
	STOP_PROCESSING(SSobj, src)
	if(detonation_mode == SELF_DESTRUCTION_MODE_ON_UNEQUIP)
		trigger()

/obj/item/power_armor_module/self_destruction/process()
	if(!part?.exoskeleton?.wearer)
		return PROCESS_KILL
	switch(detonation_mode)
		if(SELF_DESTRUCTION_MODE_ON_CRIT)
			if(part.exoskeleton.wearer.InCritical())
				trigger()
		if(SELF_DESTRUCTION_MODE_ON_DEATH)
			if(part.exoskeleton.wearer.stat == DEAD)
				trigger()
		else
			return PROCESS_KILL

// Note: we don't use try_apply_item for mode switching!
/obj/item/power_armor_module/self_destruction/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		detonation_mode = (detonation_mode + 1) % SELF_DESTRUCTION_MODES
		var/mode_desc = "only manually"
		var/span_class = "notice"
		switch(detonation_mode)
			if(SELF_DESTRUCTION_MODE_MANUAL_ONLY)
				STOP_PROCESSING(SSobj, src)
			if(SELF_DESTRUCTION_MODE_ON_UNEQUIP)
				STOP_PROCESSING(SSobj, src)
				mode_desc = "when the wearer leaves the exoskeleton. This is one-way road"
				span_class = "boldwarning"
			if(SELF_DESTRUCTION_MODE_ON_CRIT)
				START_PROCESSING(SSobj, src)
				mode_desc = "when the wearer reaches critical health condition"
			if(SELF_DESTRUCTION_MODE_ON_DEATH)
				START_PROCESSING(SSobj, src)
				mode_desc = "when the wearer dies"
		to_chat(user, "<span class='[span_class]'>\The [src] will now be triggered [mode_desc].</span>")
		return TRUE
	return ..(W, user, params)

/datum/action/innate/power_armor/module/self_destruction
	name = "Initiate self-destruction"
	desc = "Launches the self-destruction system, resulting in a huge explosion. The exoskeleton most probably will be completely destroyed."
	icon_icon = 'Oasis/icons/powerarmor/modules/self_destruction.dmi'
	button_icon_state = "self_destruction_action"

/datum/action/innate/power_armor/module/self_destruction/Activate()
	if(!(owner.stat == CONSCIOUS || owner.stat == SOFT_CRIT))
		return
	var/obj/item/power_armor_module/self_destruction/M = module
	if(istype(M))
		M.trigger()

#undef SELF_DESTRUCTION_MODE_MANUAL_ONLY
#undef SELF_DESTRUCTION_MODE_ON_UNEQUIP
#undef SELF_DESTRUCTION_MODE_ON_CRIT
#undef SELF_DESTRUCTION_MODE_ON_DEATH

#undef SELF_DESTRUCTION_MODES
