/obj/item/power_armor_part/torso/pangolin
	name = "\"Pangolin\" power armor chestplate"
	desc = "<TODO>"
	icon = 'Oasis/icons/powerarmor/pa_parts/pangolin.dmi'
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/pangolin,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	repair_materials = list(/obj/item/stack/sheet/plasteel = 1)
	slowdown = 1
	render_priority = 5
	tier = POWER_ARMOR_GRADE_MILITARY
	max_integrity = 220
	armor_points = 200
	uses_empty_state = TRUE
	collar = TRUE
	pauldrons = TRUE

/obj/item/power_armor_part/l_arm/pangolin
	name = "\"Pangolin\" power armor left arm"
	desc = "<TODO>"
	icon = 'Oasis/icons/powerarmor/pa_parts/pangolin.dmi'
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/pangolin,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	repair_materials = list(/obj/item/stack/sheet/plasteel = 1)
	slowdown = 0.8
	tier = POWER_ARMOR_GRADE_MILITARY
	max_integrity = 170
	armor_points = 150
	item_inhand_offsets = list("x" = 1, "y" = 1)

/obj/item/power_armor_part/r_arm/pangolin
	name = "\"Pangolin\" power armor right arm"
	desc = "<TODO>"
	icon = 'Oasis/icons/powerarmor/pa_parts/pangolin.dmi'
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/pangolin,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	repair_materials = list(/obj/item/stack/sheet/plasteel = 1)
	slowdown = 0.8
	tier = POWER_ARMOR_GRADE_MILITARY
	max_integrity = 170
	armor_points = 150
	item_inhand_offsets = list("x" = 1, "y" = 1)

/obj/item/power_armor_part/l_leg/pangolin
	name = "\"Pangolin\" power armor left leg"
	desc = "<TODO>"
	icon = 'Oasis/icons/powerarmor/pa_parts/pangolin.dmi'
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/pangolin,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	repair_materials = list(/obj/item/stack/sheet/plasteel = 1)
	slowdown = 0.8
	render_priority = 0
	tier = POWER_ARMOR_GRADE_MILITARY
	max_integrity = 170
	armor_points = 150

/obj/item/power_armor_part/r_leg/pangolin
	name = "\"Pangolin\" power armor right leg"
	desc = "<TODO>"
	icon = 'Oasis/icons/powerarmor/pa_parts/pangolin.dmi'
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/pangolin,
		/datum/component/power_armor_set_bonus/spaceworthy
		)
	repair_materials = list(/obj/item/stack/sheet/plasteel = 1)
	slowdown = 0.8
	render_priority = 0
	tier = POWER_ARMOR_GRADE_MILITARY
	max_integrity = 170
	armor_points = 150

/datum/component/power_armor_set_bonus/pangolin
	desc = "Full set of \"Pangolin\" armor provides you ability to activate more mobile form of the suit."
