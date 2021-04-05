
/obj/item/twohanded/required/power_weapon_melee/makeshift_cleaver
	name = "makeshift cleaver"
	desc = "A sword so big that no humanlike creature is capable of wielding it properly without some additional support. Apparently, made from scrap materials."
	icon = 'Oasis/icons/powerarmor/weapons/64x_melee.dmi'
	icon_state = "makeshift_cleaver"

	attack_weight = 4
	block_power_wielded = 40
	block_upgrade_walk = 1
	throwforce = 15
	force = 5
	slowdown = 2
	force_wielded = 16
	force_powered = 24
	attack_verb = list("attacked", "chopped", "cleaved", "tore", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/twohanded/required/power_weapon_melee/makeshift_cleaver/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 80, 0 , hitsound)
