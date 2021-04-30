//Actually, this whole shit started as an amalgamation of exosuit and power armor part...
/obj/item/clothing/head/helmet/power_armor
	name = "power armor helmet"
	desc = "A helmet that can be worn only with exoskeleton."
	max_integrity = 80
	icon = 'Oasis/icons/powerarmor/helmets/helmet_items.dmi'
	alternate_worn_icon = 'Oasis/icons/powerarmor/helmets/helmets.dmi'

	// PA helmets are space-worthy by default
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY | SNUG_FIT
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT

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

	var/datum/component/power_armor_set_bonus/set_bonus  // Type of component responsible for handling full set bonus 

	// List of materials needed to repair the helmet and their coefficients (armor_points_per_sheet multiplier)
	var/list/repair_materials = list(
		/obj/item/stack/sheet/iron = 1
	)
	var/list/armor_points_per_sheet = 20  // How many integrity points are restored with one sheet of material

/obj/item/clothing/head/helmet/power_armor/Initialize()
	..()
	worn_y_dimension += EXOSKELETON_ADDITIONAL_HEIGHT * 2
	var/datum/power_armor_overlay/PAO = new
	PAO.priority = POWER_ARMOR_LAYER_HELMET
	PAO.appearance = mutable_appearance(alternate_worn_icon, icon_state)
	power_armor_overlays += PAO

/obj/item/clothing/head/helmet/power_armor/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M

	// Yes, hulks can equip basic helmets, viva le powergaming
	if(tier == POWER_ARMOR_GRADE_BASIC && H.dna?.check_mutation(HULK))
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
		synchronize_with_exoskeleton(user.get_item_by_slot(ITEM_SLOT_OCLOTHING))

/obj/item/clothing/head/helmet/power_armor/dropped(mob/living/user)
	if(is_equipped(user))
		wearer = null
		on_wearer_left(user)
		for(var/M in modules)
			modules[M].on_wearer_left(user)
		desynchronize_with_exoskeleton()
	..(user)

/* Synchronize with exosketon
Synchronize HUD and trackers with the exoskeleton worn by the helmet's wearer.
Accepts:
	exoskeleton, the exoskeleton
*/
/obj/item/clothing/head/helmet/power_armor/proc/synchronize_with_exoskeleton(var/obj/item/clothing/suit/armor/exoskeleton/exoskeleton)
	if(!istype(exoskeleton))
		return
	src.exoskeleton = exoskeleton
	exoskeleton.update_set_bonuses()
	exoskeleton.update_appearances()
	alternate_worn_icon = null
	wearer?.update_inv_head()
	wearer?.update_inv_wear_suit()

/* Desynchronize with exosketon
Cancels changes made by synchronize_with_exoskeleton
*/
/obj/item/clothing/head/helmet/power_armor/proc/desynchronize_with_exoskeleton()
	exoskeleton = null
	exoskeleton.update_set_bonuses()
	exoskeleton.update_appearances()
	alternate_worn_icon = initial(alternate_worn_icon)
	wearer?.update_inv_wear_suit()

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

// Repair mechanics mostly duplicate _part.dm code
/obj/item/clothing/head/helmet/power_armor/attackby(obj/item/W, mob/user, params)
	for(var/material_type in repair_materials)
		if(!istype(W, material_type))
			continue
		if(exoskeleton?.wearer == user)
			to_chat(user, "<span class='warning'>You can't repair armor while wearing it!</span>")
			return
		if(max_integrity == obj_integrity)
			to_chat(user, "<span class='notice'>\The [src] is already intact.</span>")
			return
		var/obj/item/stack/sheet/S = W
		var/to_repair = CLAMP(S.amount * armor_points_per_sheet * (repair_materials[material_type] || 1), 0, max_integrity - obj_integrity)
		var/fuel_to_use = to_repair * POWER_ARMOR_REPAIR_FUEL_CONSUMPTION
		var/obj/item/welder = find_tool(user, TOOL_WELDER)
		if(!welder)
			to_chat(user, "<span class='warning'>You need a working welding tool to repair \the [src]!</span>")
			return
		if(!welder.tool_start_check(user, fuel_to_use))
			return
		if(do_after(user, to_repair * POWER_ARMOR_REPAIR_TIME_MULTIPLIER, target = src))
			welder = find_tool(user, TOOL_WELDER)
			if(!welder) 
				to_chat(user, "<span class='warning'>You need a working welding tool to repair \the [src]!</span>")
				return
			if(!welder.tool_start_check(user, fuel_to_use))
				return

			welder.use(fuel_to_use)
			var/to_use = CEILING(repair(to_repair)/armor_points_per_sheet, 1)
			S.use(to_use)
			to_chat(user, "<span class='notice'>You repair \the [src] with [W].</span>")
			return
	return ..(W, user, params)

/* Repair
Repairs some amount of HPs of the helmet.
Returns:
	the amount of HPs restored
*/
/obj/item/clothing/head/helmet/power_armor/proc/repair(amount)
	var/previous_integrity = obj_integrity
	obj_integrity = CLAMP(obj_integrity + amount, 0, max_integrity)
	if(broken)
		if(obj_integrity > (max_integrity - armor_points))
			broken = FALSE
	return obj_integrity - previous_integrity
