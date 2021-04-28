/obj/item/power_armor_part/torso/praetor
	name = "\"Praetor\" chestplate"
	desc = "\"Praetor\" power armor chestplate. \
Unlike other kinds of armor, this one was designed specifically not to hinder the wearer's movement. \
Furthermore, when fully equipped, the armor set gives the wearer additional protection from dangerous fauna dwelling asteroids."
	icon = 'Oasis/icons/powerarmor/pa_parts/praetor.dmi'
	slowdown = 0.1
	render_priority = POWER_ARMOR_LAYER_TORSO
	uses_empty_state = TRUE
	collar = TRUE
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/praetor,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	max_integrity = 100
	armor_points = 80

/obj/item/power_armor_part/torso/praetor/Initialize()
	..()
	AddComponent(/datum/component/praetor_armor_plate, 3)

/obj/item/power_armor_part/l_arm/praetor
	name = "\"Praetor\" left arm"
	desc = "\"Praetor\" left arm power armor piece. \
Unlike other kinds of armor, this one was designed specifically not to hinder the wearer's movement. \
Furthermore, when fully equipped, the armor set gives the wearer additional protection from dangerous fauna dwelling asteroids."
	icon = 'Oasis/icons/powerarmor/pa_parts/praetor.dmi'
	slowdown = 0.05
	pauldron_compatible = FALSE
	module_slots = MODULE_SLOT_ARM
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/praetor,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	max_integrity = 80
	armor_points = 60
	item_inhand_offsets = list("x" = 1, "y" = 3)

/obj/item/power_armor_part/l_arm/praetor/Initialize()
	..()
	AddComponent(/datum/component/praetor_armor_plate)

/obj/item/power_armor_part/r_arm/praetor
	name = "\"Praetor\" right arm"
	desc = "\"Praetor\" right arm power armor piece. \
Unlike other kinds of armor, this one was designed specifically not to hinder the wearer's movement. \
Furthermore, when fully equipped, the armor set gives the wearer additional protection from dangerous fauna dwelling asteroids."
	icon = 'Oasis/icons/powerarmor/pa_parts/praetor.dmi'
	slowdown = 0.05
	pauldron_compatible = FALSE
	module_slots = MODULE_SLOT_ARM
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/praetor,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	max_integrity = 80
	armor_points = 60
	item_inhand_offsets = list("x" = 1, "y" = 3)

/obj/item/power_armor_part/r_arm/praetor/Initialize()
	..()
	AddComponent(/datum/component/praetor_armor_plate)

/obj/item/power_armor_part/l_leg/praetor
	name = "\"Praetor\" left leg"
	desc = "\"Praetor\" left leg power armor piece. \
Unlike other kinds of armor, this one was designed specifically not to hinder the wearer's movement. \
Furthermore, when fully equipped, the armor set gives the wearer additional protection from dangerous fauna dwelling asteroids."
	icon = 'Oasis/icons/powerarmor/pa_parts/praetor.dmi'
	slowdown = 0.05
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/praetor,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	max_integrity = 80
	armor_points = 60

/obj/item/power_armor_part/l_leg/praetor/Initialize()
	..()
	AddComponent(/datum/component/praetor_armor_plate)

/obj/item/power_armor_part/r_leg/praetor
	name = "\"Praetor\" right leg"
	desc = "\"Praetor\" right leg power armor piece. \
Unlike other kinds of armor, this one was designed specifically not to hinder the wearer's movement. \
Furthermore, when fully equipped, the armor set gives the wearer additional protection from dangerous fauna dwelling asteroids."
	icon = 'Oasis/icons/powerarmor/pa_parts/praetor.dmi'
	slowdown = 0.05
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/praetor,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	max_integrity = 80
	armor_points = 60

/obj/item/power_armor_part/r_leg/praetor/Initialize()
	..()
	AddComponent(/datum/component/praetor_armor_plate)

/datum/component/power_armor_set_bonus/praetor
	desc = "Full set of \"Praetor\" armor provides you robust protection from the local fauna, halving the incoming damage."

/datum/component/power_armor_set_bonus/on_wearer_entered(mob/living/user)
	..()
	if(istype(user))
		user.AddComponent(/datum/component/faction_damage_resistance, list("mining", "boss"), 0.5)

/datum/component/power_armor_set_bonus/on_wearer_left(mob/living/user)
	..()
	if(istype(user))
		user.GetComponent(/datum/component/faction_damage_resistance)?.RemoveComponent()
