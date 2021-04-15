/obj/item/power_armor_module/mandible
	name = "mandible module"
	desc = "A durable plasteel mandible that can be attached to an exoskeleton arm. Not as deadly as powered melee weapons, but immune to disarming."
	icon = 'Oasis/icons/powerarmor/modules/mandible.dmi'
	slot = MODULE_SLOT_ARM
	locks_hand = TRUE
	held_item_type = /obj/item/melee/power_armor_mandible
	render_priority = POWER_ARMOR_LAYER_ARM_MODULES

/obj/item/melee/power_armor_mandible
	name = "plasteel mandible"
	desc = "A durable plasteel mandible ."
	icon = 'Oasis/icons/powerarmor/modules/mandible.dmi'
	icon_state = "held_item"
	// Stats pretty much copied from /obj/item/melee/arm_blade
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	block_power = 15
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	sharpness = IS_SHARP
	block_level = 1
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/melee/power_armor_mandible/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)
	AddComponent(/datum/component/butchering, 60, 80)

/obj/item/melee/power_armor_mandible/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.deconstruct(FALSE)

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower())
			return
		if(A.locked)
			to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
			return

		if(A.hasPower())
			user.visible_message(
				"<span class='warning'>[user] jams [src] into the airlock and starts prying it open!</span>",
				"<span class='warning'>You start forcing the [A] open.</span>",
				"<span class='italics'>You hear a metal screeching sound.</span>"
				)
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
			if(!do_after(user, 100, target = A))
				return
		user.visible_message(
			"<span class='warning'>[user] forces the airlock to open with [user.p_their()] [src]!</span>",
			"<span class='warning'>We force the [A] to open.</span>",
			"<span class='italics'>You hear a metal screeching sound.</span>"
			)
		A.open(2)
