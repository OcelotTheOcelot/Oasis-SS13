/obj/item/power_armor_part
	name = "power armor part"
	/* This is extremely retarded, but since DM doesn't support inheritance from multiple parents of interfaces,
	we'll have to define one and the same sprite for every part of one armor set. */
	icon = 'Oasis/icons/powerarmor/exoskeleton/exoskeleton_basic.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 12
	throwforce = 16
	throw_speed = 1
	throw_range = 3
	body_parts_covered = 0

	max_integrity = 80

	// How much damage points the part absorbs until it's broken.
	// Supposed to be lower than max_integrity until you want your part vanished as soon as it takes max_integrity.
	var/armor_points = 60
	var/broken = FALSE  // If the part is broken; broken parts disable the limbs they're attached to

	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the part, needed for balance

	var/slot = EXOSKELETON_SLOT_TORSO  // Determines which slot of an exoskeleton does the part occupy
	var/obj/item/clothing/suit/armor/exoskeleton/exoskeleton  // The exoskeleton the part is attached to
	var/protected_bodyzone  // The body zone from which this part intercepts incoming damage

	var/list/power_armor_overlays = new  // Overlays to render when the part is attached as a list of /datum/power_armor_overlay objects
	var/part_icon_state = "torso"  // The icon state to be added to the default overlay
	var/broken_icon = null  // If specified, will be used for rendering the broken version of the part
	var/render_priority  // The appearence of the default overlay

	var/attachment_speed = 20  // How much time it takes to attach the part to the exoskeleton
	var/detachment_speed = 20  // How much time it takes to detach the part from the exoskeleton

	var/module_slots = MODULE_SLOT_TORSIAL  // Flag specifiying what module slots does this part have 
	var/list/modules = new  // This list contains the modules installed in the part

	slowdown = 0.2  // How much does this part add to the exosuit slowdown; this variable is already defined in the item.dm but used only for equipment
	var/eqipment_delay = 5  // How much does this part add to the exosuit eqipment_delay
	var/list/set_bonuses = new  // Type of components responsible for handling full set bonuses
	var/pauldron_compatible = TRUE  // If this part can be attached to an exoskeleton with pauldrons; intended to be used with arms, but transfered to their parent for better compatibility

	// List of materials needed to repair the part and their coefficients (armor_points_per_sheet multiplier)
	var/list/repair_materials = list(
		/obj/item/stack/sheet/iron = 1
	)
	var/list/armor_points_per_sheet = 20  // How many integrity points are restored with one sheet of material

/obj/item/power_armor_part/Initialize()
	..()
	if(part_icon_state)
		var/datum/power_armor_overlay/PAO = new
		PAO.priority = render_priority
		PAO.appearance = mutable_appearance(icon, part_icon_state)
		power_armor_overlays += PAO

/obj/item/power_armor_part/Destroy()
	exoskeleton?.detach_part(slot)
	var/obj/item/power_armor_module/M
	for(M in modules)
		QDEL_NULL(M)
	return ..()

/obj/item/power_armor_part/examine(mob/user)
	. = ..(user)
	for(var/M in modules)
		. += "<span class='notice'>It has [modules[M]] installed.</span>"
	switch(tier)
		if(POWER_ARMOR_GRADE_BASIC)
			. += "<span class='notice'>It can be installed in any exoskeleton.</span>"
		if(POWER_ARMOR_GRADE_ADVANCED)
			. += "<span class='notice'>This part uses advanced technologies and can not be installed in basic exoskeletons.</span>"
		if(POWER_ARMOR_GRADE_MILITARY)
			. += "<span class='notice'>This part uses military-grade technologies, only military exoskeletons can support it.</span>"

/* Can accept module
Checks if the part can accept the given module.
Accepts:
	module, the module to check
Returns:
	TRUE if the module can be attached, FALSE otherwise
*/
/obj/item/power_armor_part/proc/can_accept_module(obj/item/power_armor_module/module)
	if(!(module_slots & module.slot))
		return FALSE
	if(modules["[module.slot]"])
		return FALSE
	if(module.tier > tier)
		return FALSE
	if(module.slot == MODULE_SLOT_BELT && !(exoskeleton && exoskeleton.parts[EXOSKELETON_SLOT_R_LEG] && exoskeleton.parts[EXOSKELETON_SLOT_L_LEG]))
		return FALSE
	
	return module.can_be_attached(src)

/* Attach module
Attaches the given module to the part.
Accepts:
	module, the module to attach
*/
/obj/item/power_armor_part/proc/attach_module(obj/item/power_armor_module/module)
	modules["[module.slot]"] = module
	module.part = src
	module.on_attached()

	var/list/module_overlays = module.get_overlays_for_part_slot(slot)
	power_armor_overlays |= module_overlays

	if(exoskeleton)
		exoskeleton.power_armor_overlays |= module_overlays
		exoskeleton.update_appearances()
		exoskeleton.update_icon()

/* Detach all modules
Detaches all modules from the part.
*/
/obj/item/power_armor_part/proc/detach_all_modules()
	var/slot
	for(slot in modules)
		detach_module(slot)

/* Detach module
Detaches a module from the given slot of the part.
Accepts:
	module_slot, the slot module to detach module from
*/
/obj/item/power_armor_part/proc/detach_module(module_slot)
	var/obj/item/power_armor_module/module = modules["[module_slot]"]
	modules -= "[module_slot]"
	if(!module)
		return
	module.part = null
	module.forceMove(get_turf(src))
	module.on_detached()

	var/list/module_overlays = module.get_overlays_for_part_slot(slot)
	power_armor_overlays -= module_overlays

	if(exoskeleton)
		exoskeleton.power_armor_overlays -= module_overlays
		exoskeleton.update_appearances()
		exoskeleton.update_icon()

/obj/item/power_armor_part/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/power_armor_module))
		var/obj/item/power_armor_module/module = W
		if(can_accept_module(module) && user.transferItemToLoc(W, src))
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			attach_module(module)
			to_chat(user, "<span class='warning'>You install \the [module] in \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>\The [module] can not fit into \the [src]!</span>")
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		detach_all_modules()
		to_chat(user, "<span class='notice'>You uninstall all modules from \the [src].</span>")
	else if(try_apply_item(W, user))
		return TRUE
	else
		for(var/M in modules)
			if(modules[M]?.try_apply_item(W, user))
				return TRUE
	return ..(W, user, params)

/* On wearer entered
Called when the wearer enters the exoskeleton.
Grants related actions and items.
Adds the damage interception component, crucial for proper power armor working.
Accepts:
	user, the wearer
*/
/obj/item/power_armor_part/proc/on_wearer_entered(mob/living/user)
	if(!user)
		return
	if(!broken)
		user.get_bodypart(protected_bodyzone)?.AddComponent(/datum/component/power_armor_damage_interceptor, src)
	else
		set_limb_disabled(TRUE)
	for(var/M in modules)
		modules[M].on_wearer_entered(user)

/* On wearer left
Called when the wearer leaves the exoskeleton.
Removes related actions and items.
Removes the damage interception component.
Accepts:
	user, the wearer
*/
/obj/item/power_armor_part/proc/on_wearer_left(mob/living/user)
	if(!istype(user))
		return
	if(!broken)
		user.get_bodypart(protected_bodyzone)?.GetComponent(/datum/component/power_armor_damage_interceptor)?.RemoveComponent()
	else
		set_limb_disabled(FALSE)
	for(var/M in modules)
		modules[M]?.on_wearer_left(user)

/* On detached
Called when the part is detached from the exoskeleton.
*/
/obj/item/power_armor_part/proc/on_detached()
	return

/* On attached
Called when the part is attached to an exoskeleton.
*/
/obj/item/power_armor_part/proc/on_attached()
	return

/obj/item/power_armor_part/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..(damage_amount, damage_type, damage_flag, sound_effect)
	if(.)
		if(obj_integrity <= (max_integrity - armor_points))
			break_part()

/* Break
Breaks the part and disables correlated limbs.
Note: we shouldn't remove the interceptor itsef for it's supposed to disable the limb properly.
*/
/obj/item/power_armor_part/proc/break_part()
	if(broken)
		return
	broken = TRUE
	set_limb_disabled(TRUE)
	for(var/M in modules)
		modules[M]?.on_part_broken()
	if(exoskeleton?.wearer)
		to_chat(exoskeleton.wearer, "<span class='userdanger'>\The [src] took too much damage! It is broken!</span>")

/* Set limb disabled
Disables the limb covered by this part.
Sometimes I'm going too far fith conditional nulls Ikr.
Accepts:
	disabled, pass TRUE to disable the limb, FALSE to cancel the effect.
*/
/obj/item/power_armor_part/proc/set_limb_disabled(disabled = TRUE)
	exoskeleton?.wearer?.get_bodypart(protected_bodyzone)?.set_disabled(disabled ? BODYPART_DISABLED_OBSTRUCTED : BODYPART_NOT_DISABLED)

/* Try apply item
Tries to apply an item on the part.
Called when the part's exoskeleton is attacked with an item.
Should be be useable in attackby as well.
Accepts:
	I, the item that the user tries to apply
	user, the mob applying the item
Returns:
	TRUE if there was a successful application attempt, FALSE otherwise; returning TRUE is supposed to prevent other try_apply_item and attackby interactions 
*/
/obj/item/power_armor_part/proc/try_apply_item(obj/item/I, mob/user)
	if(SEND_SIGNAL(src, COMSIG_POWER_ARMOR_PART_APPLY_ITEM, I, user))
		return TRUE
	for(var/M in modules)
		if(modules[M]?.try_apply_item(I, user))
			return TRUE

	for(var/material_type in repair_materials)
		if(!istype(I, material_type))
			continue
		if(exoskeleton?.wearer == user)
			to_chat(user, "<span class='warning'>You can't repair armor while wearing it!</span>")
			return TRUE
		if(max_integrity == obj_integrity)
			to_chat(user, "<span class='notice'>\The [src] is already intact.</span>")
			return TRUE
		var/obj/item/stack/sheet/S = I
		var/to_repair = CLAMP(S.amount * armor_points_per_sheet * (repair_materials[material_type] || 1), 0, max_integrity - obj_integrity)
		var/fuel_to_use = to_repair * POWER_ARMOR_REPAIR_FUEL_CONSUMPTION
		var/obj/item/welder = find_tool(user, TOOL_WELDER)
		if(!welder)
			to_chat(user, "<span class='warning'>You need a working welding tool to repair \the [src]!</span>")
			return TRUE
		if(!welder.tool_start_check(user, fuel_to_use))
			return TRUE
		if(do_after(user, to_repair * POWER_ARMOR_REPAIR_TIME_MULTIPLIER, target = src))
			// We do a double check for we don't know what might have happened during the do_after check.
			welder = find_tool(user, TOOL_WELDER)
			if(!welder) 
				to_chat(user, "<span class='warning'>You need a working welding tool to repair \the [src]!</span>")
				return TRUE
			if(!welder.tool_start_check(user, fuel_to_use))
				return TRUE

			welder.use(fuel_to_use)
			var/to_use = CEILING(repair(to_repair)/armor_points_per_sheet, 1)
			S.use(to_use)
			to_chat(user, "<span class='notice'>You repair \the [src] with [I].</span>")
		return TRUE

	return FALSE

/* Get armor points percent
Calculates the intergity percent of the part. Only armor points are regarded.
Returns:
	the armor points percent of the part
*/
/obj/item/power_armor_part/proc/get_armor_points_percent()
	return max(0, (obj_integrity - max_integrity + armor_points)/armor_points)

/* Get examination line
Builds a line that is shown both on exoskeleton and part examination.
Returns:
	the string that should be printed with examination
*/
/obj/item/power_armor_part/proc/get_examination_line()
	. = ""
	if(broken)
		. += "<span class='boldwarning'>\The [src] is broken!</span>"
	else
		var/integrity = get_armor_points_percent()
		switch(integrity)
			if(0.5 to 0.99)
				. += "<span class='warning'>\The [src] is slightly damaged.</span>"
			if(0.25 to 0.49)
				. += "<span class='warning'>\The [src] is heavily damaged.</span>"
			if(0 to 0.24)
				. += "<span class='warning'>\The [src] is falling apart!</span>"
	return .

/* Repair
Repairs some amount of HPs of the part.
Returns:
	the amount of HPs restored
*/
/obj/item/power_armor_part/proc/repair(amount)
	var/previous_integrity = obj_integrity
	obj_integrity = CLAMP(obj_integrity + amount, 0, max_integrity)
	if(broken)
		if(obj_integrity > (max_integrity - armor_points))
			broken = FALSE
			set_limb_disabled(FALSE)
	return obj_integrity - previous_integrity

/obj/item/power_armor_part/torso
	slot = EXOSKELETON_SLOT_TORSO
	body_parts_covered = CHEST|GROIN
	protected_bodyzone = BODY_ZONE_CHEST
	module_slots = MODULE_SLOT_TORSIAL
	icon_state = "torso_item"
	part_icon_state = "torso"
	render_priority = POWER_ARMOR_LAYER_TORSO
	var/pauldrons = FALSE  // If the torso has pauldrons to be rendered 
	var/collar = FALSE  // If the torso has additional layer for rendering collar over helmet
	var/uses_empty_state = FALSE  // If the torso has additional layer for rendering when not occupied

/obj/item/power_armor_part/torso/on_detached()
	var/obj/item/power_armor_module/M = modules["[MODULE_SLOT_BELT]"]
	if(istype(M))
		detach_module(M)
	..()

/obj/item/power_armor_part/torso/Initialize()
	..()
	if(collar)
		var/datum/power_armor_overlay/PAO = new
		PAO.priority = POWER_ARMOR_LAYER_COLLAR
		PAO.appearance = mutable_appearance(icon, "collar")
		power_armor_overlays += PAO
	if(pauldrons)
		var/datum/power_armor_overlay/PAO = new
		PAO.priority = POWER_ARMOR_LAYER_PAULDRONS
		PAO.appearance = mutable_appearance(icon, "pauldrons")
		power_armor_overlays += PAO

/obj/item/power_armor_part/l_arm
	slot = EXOSKELETON_SLOT_L_ARM
	body_parts_covered = ARM_LEFT|HAND_LEFT
	protected_bodyzone = BODY_ZONE_L_ARM
	module_slots = MODULE_SLOT_ARM
	icon_state = "l_arm_item"
	part_icon_state = "l_arm"
	render_priority = POWER_ARMOR_LAYER_ARMS
	var/item_inhand_offsets = list("x" = 1, "y" = 2)  // How many pixels the icon of the item held in the according hand is shifted on x and y axis

/obj/item/power_armor_part/r_arm
	slot = EXOSKELETON_SLOT_R_ARM
	body_parts_covered = ARM_RIGHT|HAND_RIGHT
	protected_bodyzone = BODY_ZONE_R_ARM
	module_slots = MODULE_SLOT_ARM
	icon_state = "r_arm_item"
	part_icon_state = "r_arm"
	render_priority = POWER_ARMOR_LAYER_ARMS
	var/item_inhand_offsets = list("x" = 1, "y" = 2)  // How many pixels the icon of the item held in the according hand is shifted on x and y axis

/obj/item/power_armor_part/l_leg
	slot = EXOSKELETON_SLOT_L_LEG
	body_parts_covered = LEG_LEFT|FOOT_LEFT
	protected_bodyzone = BODY_ZONE_L_LEG
	icon_state = "l_leg_item"
	part_icon_state = "l_leg"
	render_priority = POWER_ARMOR_LAYER_LEGS

/obj/item/power_armor_part/l_leg/on_detached()
	if(istype(exoskeleton))
		var/obj/item/power_armor_part/torso/T = exoskeleton.parts[EXOSKELETON_SLOT_TORSO]
		if(istype(T))
			var/obj/item/power_armor_module/M = T.modules["[MODULE_SLOT_BELT]"]
			if(istype(M))
				T.detach_module(M)
	..()

/obj/item/power_armor_part/r_leg
	slot = EXOSKELETON_SLOT_R_LEG
	body_parts_covered = LEG_RIGHT|FOOT_RIGHT
	protected_bodyzone = BODY_ZONE_R_LEG
	icon_state = "r_leg_item"
	part_icon_state = "r_leg"
	render_priority = POWER_ARMOR_LAYER_LEGS

/obj/item/power_armor_part/r_leg/on_detached()
	if(istype(exoskeleton))
		var/obj/item/power_armor_part/torso/T = exoskeleton.parts[EXOSKELETON_SLOT_TORSO]
		if(istype(T))
			var/obj/item/power_armor_module/M = T.modules["[MODULE_SLOT_BELT]"]
			if(istype(M))
				T.detach_module(M)
	..()

/obj/item/power_armor_part/lining
	slot = EXOSKELETON_SLOT_LINING
	render_priority = POWER_ARMOR_LAYER_LINING
