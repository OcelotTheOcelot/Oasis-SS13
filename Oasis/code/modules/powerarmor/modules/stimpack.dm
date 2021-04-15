#define INJECTION_MODE_MANUAL_ONLY 0
#define INJECTION_MODE_ON_CRIT 1
#define INJECTION_MODE_ON_DEATH 2

#define INJECTION_MODES 3

/obj/item/power_armor_module/stimpack
	name = "stimpack module"
	desc = "A smart backpack that automatically injects supplied syringes in the user's body. Injection conditions can be configured with <b>multitool</b>."
	icon = 'Oasis/icons/powerarmor/modules/stimpack.dmi'
	slot = MODULE_SLOT_BACKPACK
	render_priority = POWER_ARMOR_LAYER_BACKPACK_MODULE_FRONT

	// Type of syringes this module can hold
	var/static/list/syringe_types = typecacheof(list(
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe
		))
	var/list/syringes = new  // Syringes this module currently holds
	var/max_syringes = 6  // How many syringes this module can hold
	var/injection_cost = 500  // How much power one injection costs
	var/injection_mode = INJECTION_MODE_ON_CRIT  // What condition should be met to make the module inject a syringe
	var/auto_inject_delay = 150  // How much time should pass between automatic injections so the backpack won't OD the wearer
	var/last_injection_time = -150  // world.time at the moment of the last injection

/obj/item/power_armor_module/stimpack/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/stimpack_inject
	. += new /datum/action/innate/power_armor/module/stimpack_eject
	return .

/obj/item/power_armor_module/stimpack/create_overlays_for_part_slot(part_slot)
	. = ..()
	if(part_slot != slot)
		return ..()
	var/datum/power_armor_overlay/PAO = new
	PAO.priority = POWER_ARMOR_LAYER_CHEST_MODULE_BACK
	PAO.appearance = mutable_appearance(icon, "torso_back")
	. += PAO
	return .

/obj/item/gun/syringe/handle_atom_del(atom/A)
	. = ..()
	if(A in syringes)
		syringes.Remove(A)

/obj/item/power_armor_module/stimpack/try_apply_item(obj/item/I, mob/user)
	if(is_type_in_typecache(I, syringe_types))
		if(syringes.len >= max_syringes)
			to_chat(user, "<span class='warning'>\The [src] can't hold more than [max_syringes] syringes!</span>")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		syringes += I
		to_chat(user, "<span class='notice'>You insert \the [I] into \the [src]. It now contains [syringes.len] syringes.</span>")
		START_PROCESSING(SSobj, src)
		return TRUE
	return ..()

// Note: we don't use try_apply_item for mode switching!
/obj/item/power_armor_module/stimpack/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		injection_mode = (injection_mode + 1) % INJECTION_MODES
		var/mode_desc = "only on request"
		switch(injection_mode)
			if(INJECTION_MODE_MANUAL_ONLY)
				STOP_PROCESSING(SSobj, src)
			if(INJECTION_MODE_ON_CRIT)
				START_PROCESSING(SSobj, src)
				mode_desc = "when the wearer reaches critical health condition"
			if(INJECTION_MODE_ON_DEATH)
				START_PROCESSING(SSobj, src)
				mode_desc = "when the wearer dies"
		to_chat(user, "<span class='notice'>\The [src] will now inject syringes [mode_desc].</span>")
		return
	return ..(W, user, params)

/obj/item/power_armor_module/stimpack/on_wearer_entered()
	..()
	state(part?.exoskeleton?.wearer, "Smart injection system welcomes you. Remember: safety first!")
	START_PROCESSING(SSobj, src)

/obj/item/power_armor_module/stimpack/on_wearer_left()
	..()
	state(part?.exoskeleton?.wearer, "Goodbye and be safe!")
	STOP_PROCESSING(SSobj, src)

/obj/item/power_armor_module/stimpack/process()
	if(syringes.len <= 0)
		return PROCESS_KILL
	if(!part?.exoskeleton?.wearer)
		return PROCESS_KILL
	switch(injection_mode)
		if(INJECTION_MODE_ON_CRIT)
			if(part.exoskeleton.wearer.InCritical() && world.time > (last_injection_time + auto_inject_delay))
				state(part.exoskeleton.wearer, "Warning: critical health condition! Performing injection...")
				inject()
		if(INJECTION_MODE_ON_DEATH)
			if(part.exoskeleton.wearer.stat == DEAD && world.time > (last_injection_time + auto_inject_delay))
				state(part.exoskeleton.wearer, "Warning: no heartbeat detected! Performing injection...")
				inject()
		else
			return PROCESS_KILL

/obj/item/power_armor_module/stimpack/on_attached()
	START_PROCESSING(SSobj, src)

/* Inject
Makes the module inject the first syringe it holds (syringes are FIFO queued).
*/
/obj/item/power_armor_module/stimpack/proc/inject()
	var/mob/living/carbon/target = part?.exoskeleton?.wearer
	if(!target)
		return
	if(!target.reagents)
		state(target, "Unable to perform injection: invalid injection target!")
		return
	if(syringes.len <= 0)
		state(target, "Unable to perform injection: no syringes detected!")
		return
	if(!part.exoskeleton.drain_power(injection_cost))
		state(target, "Unable to perform injection: not enough power!")
		return
	var/obj/item/reagent_containers/syringe = syringes[1]
	if(!syringe)
		state(target, "Unable to perform injection: invalid syringe!")
		return
	syringes.Remove(syringe)
	last_injection_time = world.time
	syringe.reagents.trans_to(target, syringe.reagents.total_volume, transfered_by = src)
	syringe.update_icon()
	syringe.forceMove(get_turf(src))
	state(target, "Injection completed! Injected: [syringe.name].")

/* State
Helper proc, makes the module state stuff in the chat.
Accepts:
	target, the mob receiving the message
	text, the text to print in the chat
*/
/obj/item/power_armor_module/stimpack/proc/state(mob/target, text="")
	if(target)
		to_chat(target, "<span class='robot'>\The [src] states, \"[text]\".</span>")

/* Eject syringes
Drops all stored syringes on floor.
*/
/obj/item/power_armor_module/stimpack/proc/eject_syringes(mob/target, text="")
	for(var/obj/item/reagent_containers/S in syringes)
		S.forceMove(get_turf(src))
		syringes.Remove(S)

/datum/action/innate/power_armor/module/stimpack_inject
	name = "Inject syringe"
	desc = "Injects the first syringe inserted in the stimpack."
	icon_icon = 'Oasis/icons/powerarmor/modules/stimpack.dmi'
	button_icon_state = "injection_action"

/datum/action/innate/power_armor/module/stimpack_inject/Activate()
	if(!(owner.stat == CONSCIOUS || owner.stat == SOFT_CRIT))
		return
	var/obj/item/power_armor_module/stimpack/M = module
	if(istype(M))
		M.state(owner, "Injection request received! Proceeding...")
		M.inject()

/datum/action/innate/power_armor/module/stimpack_eject
	name = "Eject syringes"
	desc = "Ejects all syringes inserted in the stimpack."
	icon_icon = 'Oasis/icons/powerarmor/modules/stimpack.dmi'
	button_icon_state = "eject_action"

/datum/action/innate/power_armor/module/stimpack_eject/Activate()
	if(!(owner.stat == CONSCIOUS || owner.stat == SOFT_CRIT))
		return
	var/obj/item/power_armor_module/stimpack/M = module
	if(istype(M))
		if((M?.syringes?.len || 0) <= 0)
			M.state(owner, "Unable to eject syringes: no syringes detected!")
			return
		M.state(owner, "Ejecting syringes...")
		M.eject_syringes()

#undef INJECTION_MODE_MANUAL_ONLY
#undef INJECTION_MODE_ON_CRIT
#undef INJECTION_MODE_ON_DEATH

#undef INJECTION_MODES
