//Actually, this whole shit started as an amalgamation of exosuit and power armor part...
/obj/item/clothing/head/helmet/power_armor
	name = "power armor helmet"
	desc = "A helmet that can be worn only with exoskeleton."
	max_integrity = 80
	icon_state = "helmet_item"
	item_state = "helmet"

	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the helmet, needed for balance
	var/armor_points = 60  // How much damage points the part absorbs until it's broken
	var/broken = FALSE  // If the helmet is broken

	var/obj/item/clothing/suit/armor/exoskeleton/exoskeleton  // The exoskeleton the helmet is synched with; note that hulks can wear it without an exoskeleton
	var/static/protected_bodyzone = BODY_ZONE_HEAD // The body zone from which this part intercepts incoming damage

	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	visor_flags_inv = HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	body_parts_covered = HEAD

	var/list/power_armor_overlays = new  // Overlays to render when the helmet is worn as a list of /datum/power_armor_overlay objects
	var/broken_icon = null  // If specified, will be used for rendering the broken version of the part

	var/module_slots = MODULE_SLOT_HELMET  // Flag specifiying what module slots does this helmet have
	var/list/modules = new  // This list contains the modules installed in the part
	var/mob/living/wearer  // Current wearer of the suit; should be faster than the loc check 

	var/armor_set  // String describing what armor set this helmet belongs to; needed only to activate set bonuses

/obj/item/clothing/head/helmet/power_armor/Initialize()
	..()
	worn_y_dimension -= EXOSKELETON_ADDITIONAL_HEIGHT

/obj/item/clothing/head/helmet/power_armor/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M

	// Yes, hulks can equip basic helmets, viva le powergaming
	if(tier == POWER_ARMOR_GRADE_BASIC && H.dna && H.dna.check_mutation(HULK))
		return TRUE

	var/obj/item/clothing/suit/armor/exoskeleton/E = H.wear_suit
	if(!istype(E))
		if(!disable_warning)
			to_chat(M, "<span class='warning'>It's unsafe for your neck to wear this helmet without any additional support!</span>")
		return FALSE
	if(E.tier < tier)
		if(!disable_warning)
			to_chat(M, "<span class='warning'>This helmet is too advanced to synchronize with \the [E]!</span>")
		return FALSE
	return TRUE

/obj/item/clothing/head/helmet/power_armor/equipped(mob/user, slot)
	..(user, slot)
	if(slot == ITEM_SLOT_HEAD)
		wearer = user
		on_wearer_entered(user)
		for(var/M in modules)
			modules[M].on_wearer_entered(user)

/obj/item/clothing/head/helmet/power_armor/dropped(mob/living/user)
	if(is_equipped(user))
		wearer = null
		on_wearer_left(user)
		for(var/M in modules)
			modules[M].on_wearer_left(user)
	..(user)
	
/* Is equipped
Helper proc used to determine if the helmet is equipped by the wearer.
Accepts:
	user, the wearer
Returns:
	TRUE if the helmet is equipped, FALSE otherwise
*/
/obj/item/clothing/head/helmet/power_armor/proc/is_equipped(mob/living/carbon/human/user)
	if(istype(user))
		return user.get_item_by_slot(ITEM_SLOT_MASK) == src
	return FALSE

/* On wearer entered
Called when the wearer equips the helmet.
Adds the damage interception component, crucial for proper power armor working.
Accepts:
	user, the wearer
*/
/obj/item/clothing/head/helmet/power_armor/proc/on_wearer_entered(mob/living/user)
	if(!user)
		return
	if(!broken)
		user.get_bodypart(protected_bodyzone)?.AddComponent(/datum/component/power_armor_damage_interceptor, src)
	for(var/M in modules)
		modules[M].on_wearer_entered(user)

/* On wearer left
Called when the wearer dequips the helmet.
Removes the damage interception component.
Accepts:
	user, the wearer
*/
/obj/item/clothing/head/helmet/power_armor/proc/on_wearer_left(mob/living/user)
	if(!istype(user))
		return
	if(!broken)
		user.get_bodypart(protected_bodyzone)?.GetComponent(/datum/component/power_armor_damage_interceptor)?.RemoveComponent()
	for(var/M in modules)
		modules[M]?.on_wearer_left(user)
