#define HALFWAYCRITDEATH ((HEALTH_THRESHOLD_CRIT + HEALTH_THRESHOLD_DEAD) * 0.5)

/obj/item/power_armor_module/defibrillator
	name = "defibrillator module"
	desc = "A device that delivers a dose of electric current to the wearer's heart. Activates automatically when the wearer's heart stops beating."
	icon = 'Oasis/icons/powerarmor/modules/defibrillator.dmi'
	slot = MODULE_SLOT_CHESTPLATE
	locks_hand = FALSE
	render_priority = POWER_ARMOR_LAYER_CHEST_MODULE_FRONT

	var/defibrillation_cost = 1000  // How much does a charge cost
	var/cooldown = 100  // How much time should pass between two charges 
	var/last_charge = -100  // world.time at the moment of the last charge 
	var/charging = FALSE  // If the module is charging right now
	var/charge_delay = 30  // How much time is needed to charge the defibrillator
	var/shock_damage = 30  // How much damage is dealt by electrocution
	var/futile = FALSE  // If TRUE, module will stop attempting to reanimate the wearer automatically
	var/tlimit = DEFIB_TIME_LIMIT * 10

/obj/item/power_armor_module/defibrillator/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/defibrillation
	return .

/obj/item/power_armor_module/defibrillator/emp_reaction()
	defibrillate()

/* Charge
Prepares to defibrillate the wearer and callse the defibrillate proc.
*/
/obj/item/power_armor_module/defibrillator/proc/charge()
	if(charging)
		return
	if(world.time < last_charge + cooldown)
		state("Operaion failed: system is not ready yet.")
		return
	if(!part?.exoskeleton?.drain_power(defibrillation_cost))
		state("Operaion failed: not enough power.")
		futile = TRUE
		return
	playsound(src, 'sound/machines/defib_charge.ogg', 100, FALSE)
	charging = TRUE
	addtimer(CALLBACK(src, .proc/defibrillate, part?.exoskeleton?.wearer), charge_delay, TIMER_UNIQUE)

/* Shock touching
Electocutes anyone who holds the wearer of this module or anyone who the wearer is holding if they're not insulated.
Original code from /obj/item/twohanded/shockpaddles/, modified to affect the held mobs as well.
Accepts:
	damage, damage dealth by electrocution
*/
/obj/item/power_armor_module/defibrillator/proc/shock_touching(damage)
	var/mob/living/H = part?.exoskeleton?.wearer
	if(!H)
		return
	for(var/mob/living/M in list(H.pulling, H.pulledby))
		if(!isliving(M))
			return
		if(M.electrocute_act(damage, H))
			M.visible_message("<span class='danger'>[M] is electrocuted by [M.p_their()] contact with [H]!")
			M.emote("scream")

/* Defibrillate
Defibrillates the wearer. Will affect 
Mostly copied from /obj/item/twohanded/shockpaddles/ for there was no possibility to implement the module otherwise.
Accepts:
	H, the mob to defibrillate
*/
/obj/item/power_armor_module/defibrillator/proc/defibrillate(mob/living/carbon/H)
	if(!istype(H))
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		return

	playsound(src, 'sound/machines/defib_zap.ogg', 75, 1, -1)
	shock_touching(shock_damage, H)

	var/total_burn	= H.getBruteLoss()
	var/total_brute	= H.getFireLoss()
	var/tplus = world.time - H.timeofdeath
	var/obj/item/organ/heart = H.getorgan(/obj/item/organ/heart)

	if(H.stat == DEAD)
		H.grab_ghost()
		H.notify_ghost_cloning("Your heart is being defibrillated!")

		playsound(src, "bodyfall", 50, 1)
		var/failed
		H.visible_message("<span class='warning'>[H]'s body convulses a bit.")

		futile = TRUE
		if (H.suiciding)
			failed = "Operaion failed: recovery of patient impossible. Further attempts futile."
		else if (H.hellbound)
			failed = "Operaion failed: patient's soul appears to be on another plane of existence. Further attempts futile."
		else if (tplus > tlimit)
			failed = "Operaion failed: body has decayed for too long. Further attempts futile."
		else if (!heart)
			failed = "Operaion failed: patient's heart is missing."
		else if (heart.organ_flags & ORGAN_FAILING)
			failed = "Operaion failed: patient's heart too damaged."
		else if(total_burn >= MAX_REVIVE_FIRE_DAMAGE || total_brute >= MAX_REVIVE_BRUTE_DAMAGE || HAS_TRAIT(H, TRAIT_HUSK))
			failed = "Operaion failed: severe tissue damage makes recovery of patient impossible via defibrillator. Further attempts futile."
		else if(H.get_ghost())
			failed = "Operaion failed: no activity in patient's brain. Further attempts may be successful."
			futile = FALSE
		else
			var/obj/item/organ/brain/BR = H.getorgan(/obj/item/organ/brain)
			if(BR)
				if(BR.organ_flags & ORGAN_FAILING)
					failed = "Operaion failed: Patient's brain tissue is damaged making recovery of patient impossible via defibrillator. Further attempts futile."
				if(BR.brain_death)
					failed = "Operaion failed: Patient's brain damaged beyond point of no return. Further attempts futile."
				if(BR.suicided || BR.brainmob?.suiciding)
					failed = "Operaion failed: No intelligence pattern can be detected in patient's brain. Further attempts futile."
			else
				failed = "Operaion failed: Patient's brain is missing. Further attempts futile."

		if(failed)
			state(failed)
			playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		else
			if (H.health > HALFWAYCRITDEATH)
				H.adjustOxyLoss(H.health - HALFWAYCRITDEATH, 0)
			else
				var/overall_damage = total_brute + total_burn + H.getToxLoss() + H.getOxyLoss()
				var/mobhealth = H.health
				H.adjustOxyLoss((mobhealth - HALFWAYCRITDEATH) * (H.getOxyLoss() / overall_damage), 0)
				H.adjustToxLoss((mobhealth - HALFWAYCRITDEATH) * (H.getToxLoss() / overall_damage), 0)
				H.adjustFireLoss((mobhealth - HALFWAYCRITDEATH) * (total_burn / overall_damage), 0)
				H.adjustBruteLoss((mobhealth - HALFWAYCRITDEATH) * (total_brute / overall_damage), 0)
			H.updatehealth()
			state("Operation successful.")
			playsound(src, 'sound/machines/defib_success.ogg', 50, 0)
			H.set_heartattack(FALSE)
			H.revive()
			H.emote("gasp")
			H.Jitter(100)
			SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK)
			log_combat(src, H, "revived", src)
		update_icon()
		last_charge = world.time
	else if(H.undergoing_cardiac_arrest())
		playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)
		if(!(heart.organ_flags & ORGAN_FAILING))
			H.set_heartattack(FALSE)
			state("Patient's heart is now beating again.")
		else
			state("Operaion failed, heart damage detected.")
	else
		H.electrocute_act(shock_damage, src)
	
	charging = FALSE

/* State
Helper proc, makes the module state stuff in the exoskeleton wearer's chat.
Accepts:
	text, the text to print in the chat
*/
/obj/item/power_armor_module/defibrillator/proc/state(text)
	part?.exoskeleton?.wearer?.visible_message("<span class='robot'>\The [src] states, \"[text]\".</span>")

/obj/item/power_armor_module/defibrillator/on_wearer_entered()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/power_armor_module/defibrillator/on_wearer_left()
	..()
	STOP_PROCESSING(SSobj, src)

// Alas, but this should track the wearer's health all the time.
/obj/item/power_armor_module/defibrillator/process()
	if(futile)
		if((part?.exoskeleton?.cell?.charge || 0) > defibrillation_cost && part?.exoskeleton?.wearer?.stat != DEAD)
			futile = FALSE
	else
		if(part?.exoskeleton?.wearer?.stat == DEAD)
			if(charging || world.time <= last_charge + cooldown)
				return
			state("No heartbeat detected, activating...")
			charge()

/datum/action/innate/power_armor/module/defibrillation
	name = "Defibrillate"
	desc = "Manually activates the defibrillator module."
	icon_icon = 'Oasis/icons/powerarmor/modules/defibrillator.dmi'
	button_icon_state = "defibrillation_action"

/datum/action/innate/power_armor/module/defibrillation/Activate()
	if(!(owner.stat == CONSCIOUS || owner.stat == SOFT_CRIT))
		return
	var/obj/item/power_armor_module/defibrillator/M = module
	if(istype(M))
		M.charge()

#undef HALFWAYCRITDEATH
