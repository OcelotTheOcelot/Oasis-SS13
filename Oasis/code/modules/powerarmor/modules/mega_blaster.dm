/obj/item/power_armor_module/mega_blaster
	name = "mega blaster module"
	desc = "A module capable of firing charged energy blasts."
	icon = 'Oasis/icons/powerarmor/modules/mega_blaster.dmi'
	slot = MODULE_SLOT_ARM
	locks_hand = TRUE
	held_item_type = /obj/item/gun/energy/mega_blaster
	render_priority = POWER_ARMOR_LAYER_ARM_MODULES

/obj/item/gun/energy/mega_blaster
	name = "mega blaster"
	desc = "A powerful energy weapon capable of firing charged energy blasts."
	icon = 'Oasis/icons/powerarmor/modules/mega_blaster.dmi'
	icon_state = "held_item"
	lefthand_file = null
	righthand_file = null
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 8
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	dead_cell = FALSE
	can_charge = FALSE
	ammo_type = list(/obj/item/ammo_casing/energy/mega_blast_light,  /obj/item/ammo_casing/energy/mega_blast_charged)

/obj/item/gun/energy/mega_blaster/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_POWER_ARMOR)

/obj/item/gun/energy/mega_blaster/recharge_newshot()
	if (!ammo_type || !cell)
		return
	var/datum/component/power_armor_item/PAI = GetComponent(/datum/component/power_armor_item)
	if(!istype(PAI))
		return
	var/obj/item/stock_parts/cell/C = PAI.get_cell()
	if(!istype(C))
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(!shot)
		return
	if(C.use(shot.e_cost))
		cell.give(shot.e_cost)
	..()

/obj/item/gun/energy/mega_blaster/select_fire(mob/living/user)
	..()
	if(istype(ammo_type[select], /obj/item/ammo_casing/energy/mega_blast_charged))
		charge_delay = 5
	else
		charge_delay = 1

/obj/item/ammo_casing/energy/mega_blast_light
	projectile_type = /obj/item/projectile/mega_blast_light
	select_name = "quick shots"
	fire_sound = 'sound/weapons/pulse3.ogg'
	e_cost = 50

/obj/item/projectile/mega_blast_light
	name = "mini blast"
	icon_state = "pulse1"
	damage = 8
	range = 6
	damage_type = BURN
	ricochet_chance = 40

/obj/item/ammo_casing/energy/mega_blast_charged
	projectile_type = /obj/item/projectile/mega_blast_charged
	select_name = "charged shots"
	fire_sound = 'sound/weapons/pulse3.ogg'
	e_cost = 200

/obj/item/projectile/mega_blast_charged
	name = "mega blast"
	icon_state = "pulse1"
	damage = 24
	range = 8
	damage_type = BURN
	ricochet_chance = 0
