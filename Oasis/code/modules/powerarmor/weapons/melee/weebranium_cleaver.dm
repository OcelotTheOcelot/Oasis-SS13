
/obj/item/twohanded/required/power_weapon_melee/weebranium_cleaver
	name = "weebranium cleaver"
	desc = "A giant cleaver made of pure weebranium. To be wielded only by the weirdest of weirdos."
	icon = 'Oasis/icons/powerarmor/weapons/64x_melee.dmi'
	icon_state = "weeb_cleaver"

	w_class = WEIGHT_CLASS_GIGANTIC
	attack_weight = 4
	block_power_wielded = 40
	block_upgrade_walk = 1
	throwforce = 15
	force = 5
	slowdown = 2
	force_wielded = 24
	force_powered = 24
	attack_verb = list("attacked", "chopped", "cleaved", "tore", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	max_integrity = 200

/obj/item/twohanded/fireaxe/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 80, 0 , hitsound)
