/obj/item/power_armor_part/torso/pcs
	name = "PCS torso"
	desc = "Powered Construction Suit torso. \
The PCS was designed to assist engineers and provide them with protection against hazardous environments. \
A complete set of suit parts is needed in order to provide protection from radiation."
	icon = 'Oasis/icons/powerarmor/pa_parts/pcs.dmi'
	slowdown = 0.2
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/spaceworthy,
		/datum/component/power_armor_set_bonus/armor/pcs
		)
	render_priority = POWER_ARMOR_LAYER_TORSO_ALT
	uses_empty_state = TRUE

/obj/item/power_armor_part/l_arm/pcs
	name = "PCS left manipulator"
	desc = "Powered Construction Suit left manipulator. \
The PCS was designed to assist engineers and provide them with protection against hazardous environments. \
A complete set of suit parts is needed in order to provide protection from radiation."
	icon = 'Oasis/icons/powerarmor/pa_parts/pcs.dmi'
	slowdown = 0.3
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/spaceworthy,
		/datum/component/power_armor_set_bonus/armor/pcs
		)
	pauldron_compatible = FALSE
	item_inhand_offsets = list("x" = 1, "y" = 4)

/obj/item/power_armor_part/r_arm/pcs
	name = "PCS right manipulator"
	desc = "Powered Construction Suit right manipulator. \
The PCS was designed to assist engineers and provide them with protection against hazardous environments. \
A complete set of suit parts is needed in order to provide protection from radiation."
	icon = 'Oasis/icons/powerarmor/pa_parts/pcs.dmi'
	slowdown = 0.3
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/spaceworthy,
		/datum/component/power_armor_set_bonus/armor/pcs
		)
	pauldron_compatible = FALSE
	item_inhand_offsets = list("x" = 1, "y" = 4)

/obj/item/power_armor_part/l_leg/pcs
	name = "PCS left leg"
	desc = "Powered Construction Suit left leg. \
The PCS was designed to assist engineers and provide them with protection against hazardous environments. \
A complete set of suit parts is needed in order to provide protection from radiation."
	icon = 'Oasis/icons/powerarmor/pa_parts/pcs.dmi'
	slowdown = 0.2
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/spaceworthy,
		/datum/component/power_armor_set_bonus/armor/pcs
		)

/obj/item/power_armor_part/r_leg/pcs
	name = "PCS right leg"
	desc = "Powered Construction Suit right leg. \
The PCS was designed to assist engineers and provide them with protection against hazardous environments. \
A complete set of suit parts is needed in order to provide protection from radiation."
	icon = 'Oasis/icons/powerarmor/pa_parts/pcs.dmi'
	slowdown = 0.2
	set_bonuses = list(
		/datum/component/power_armor_set_bonus/spaceworthy,
		/datum/component/power_armor_set_bonus/armor/pcs
		)

/datum/component/power_armor_set_bonus/armor/pcs
	desc = "Full set of PCS parts provides you strong protection against radiation and heat."
	additional_armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 80, "rad" = 80, "fire" = 80, "acid" = 50)
