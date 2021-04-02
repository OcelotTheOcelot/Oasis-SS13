/obj/item/twohanded/required/power_weapon_melee
	name = "melee power weapon"

	// This is so fucking retarded, but who am I to judge the wizard who wrote this?
	lefthand_file = 'Oasis/icons/powerarmor/weapons/in_hands/64x_power_weapons_lefthand.dmi'
	righthand_file = 'Oasis/icons/powerarmor/weapons/in_hands/64x_power_weapons_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64

	var/can_be_sheathed = FALSE  // If this weapon can be stored in a sheath module. Requires sheathed icon state to work.
	var/sheathed_icon_state  // The icon state to render this weapon when it's sheathed.
	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the weapon, needed for balance

	var/powered = FALSE  // If this weapon is currently used by a proper user.
	var/force_powered = 24  // The force of the weapon when it's powered
	var/throwforce_powered = 15  // The throw force of the weapon when it's powered
	var/slowdown_powered = 0  // The slowdown of the weapon when it's powered

/* Is proper user
Used to determine if the user fits the weapon's requirements.
To use the melee power weapons, they have to wear a powered exoskeleton or to be a hulk. 
Accepts:
	user, the user of the weapon
Returns:
	TRUE if the user fits the weapon's requirements, FALSE otherwise
*/
/obj/item/twohanded/required/power_weapon_melee/proc/is_proper_user(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return FALSE

	if(H.dna && H.dna.check_mutation(HULK))
		return TRUE

	var/obj/item/clothing/suit/armor/exoskeleton/E = H.wear_suit
	if(!istype(E))
		return FALSE
	if(!E.tier < tier)
		return FALSE
	if(!E.powered)
		return FALSE
	return TRUE

/obj/item/twohanded/required/power_weapon_melee/equipped(mob/user, slot)
	..()
	update_user_status(user)
	if(!powered)
		to_chat(user, "<span class='warning'>\The [src] is too heavy for you to handle!</span>")

/obj/item/twohanded/required/power_weapon_melee/dropped(mob/user)
	..()
	update_user_status(user)

/* Update user status
Checks if the current user fits the weapon's requirements and applies buffs or debuffs accordingly.
Accepts:
	user, the user of the weapon
*/
/obj/item/twohanded/required/power_weapon_melee/proc/update_user_status(mob/user)
	toggle_power_buffs(is_proper_user(user))

/* Toggle power buffs
Toggles buffs of the power weapon ON and OFF.
Accepts:
	on, status of the buffs, pass TRUE to enable and FALSE to disable
*/
/obj/item/twohanded/required/power_weapon_melee/proc/toggle_power_buffs(on = TRUE)
	powered = on
	if(on)
		force_wielded = force_powered
		throwforce = throwforce_powered
		slowdown = slowdown_powered
	else
		force_wielded = initial(force_wielded)
		throwforce = initial(throwforce)
		slowdown = initial(slowdown)

/obj/item/twohanded/required/power_weapon_melee/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/mob/living/L = user
	if(!istype(L))
		return
	if(!powered)
		to_chat(user, "<span class='warning'>\The [src] is too heavy for you to swing!</span>")
		L.adjustStaminaLoss(POWER_WEAPON_STAMINA_LOSS)
		if(rand(1, 100) <= POWER_WEAPON_COLLAPSE_CHANCE)
			L.Knockdown(20)
		else
			step(L, L.dir)
