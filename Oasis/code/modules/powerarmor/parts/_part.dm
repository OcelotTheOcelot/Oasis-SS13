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

	max_integrity = 60

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

	var/passive_power_consumption = 0  // Amount of power drawn every tick when the exoskeleton is enabled
	var/active_power_consumption = 0  // Amount of power drawn when a specific action is performed
	slowdown = 0.2  // How much does this part add to the exosuit slowdown; this variable is already defined in the item.dm but used only for equipment
	var/eqipment_delay = 5  // How much does this part add to the exosuit eqipment_delay

	var/armor_set  // String describing what armor set this part belongs to; needed only to activate set bonuses

	var/airtight = FALSE  // Wheter this part protects the limb from space or not <TODO> still unused, may be should be removed
	var/pauldron_compatible = TRUE  // If this part can be attached to an exoskeleton with pauldrons; intended to be used with arms, but transferet to their parent for better compatibility

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
	. = ..()
	var/M
	for(M in modules)
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
	modules["[module_slot]"] = null
	module.part = null
	module.forceMove(get_turf(src))

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
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			attach_module(module)
			to_chat(user, "<span class='warning'>You install \the [module] in \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>\The [module] can not fit into \the [src]!</span>")
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		detach_all_modules()
		to_chat(user, "<span class='notice'>You uninstall all modules from \the [src].</span>")
	else
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
	var/M
	for(M in modules)
		modules[M].on_wearer_entered(user)

/* On wearer left
Called when the wearer leaves the exoskeleton.
Removes related actions and items.
Adds the damage interception component, crucial for proper power armor working.
Accepts:
	user, the wearer
*/
/obj/item/power_armor_part/proc/on_wearer_left(mob/living/user)
	if(!user)
		return
	if(!broken)
		user.get_bodypart(protected_bodyzone)?.GetComponent(/datum/component/power_armor_damage_interceptor)?.RemoveComponent()
	else
		set_limb_disabled(FALSE)
	var/M
	for(M in modules)
		modules[M].on_wearer_left(user)

/obj/item/power_armor_part/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..(damage_amount, damage_type, damage_flag, sound_effect)
	if(.)
		if(obj_integrity <= 0 && !broken)
			break_part()

/* Break
Breaks the part and disables correlated limbs.
*/
/obj/item/power_armor_part/proc/break_part()
	broken = TRUE
	set_limb_disabled(TRUE)
	if(exoskeleton?.wearer)
		to_chat(exoskeleton.wearer, "<span class='userdanger'>\The [src] took too much damage! It is broken!</span>")

/obj/item/power_armor_part/proc/set_limb_disabled(disabled = TRUE)
	exoskeleton?.wearer?.get_bodypart(protected_bodyzone)?.set_disabled(disabled ? BODYPART_DISABLED_OBSTRUCTED : BODYPART_NOT_DISABLED)

/obj/item/power_armor_part/torso
	slot = EXOSKELETON_SLOT_TORSO
	body_parts_covered = CHEST|GROIN
	protected_bodyzone = BODY_ZONE_CHEST
	module_slots = MODULE_SLOT_TORSIAL
	icon_state = "torso_item"
	part_icon_state = "torso"
	render_priority = POWER_ARMOR_LAYER_TORSO
	var/pauldrons = FALSE  // If the torso has pauldrons to be rendered 
	var/uses_empty_state = FALSE  // If the torso has additional layer for rendering when not occupied

/obj/item/power_armor_part/torso/Initialize()
	..()
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
	var/held_item_offset_x = 0  // How many pixels the icon of the item held in the according hand is shifted on x-axis
	var/held_item_offset_y = 0  // How many pixels the icon of the item held in the according hand is shifted on y-axis

/obj/item/power_armor_part/r_arm
	slot = EXOSKELETON_SLOT_R_ARM
	body_parts_covered = ARM_RIGHT|HAND_RIGHT
	protected_bodyzone = BODY_ZONE_R_ARM
	module_slots = MODULE_SLOT_ARM
	icon_state = "r_arm_item"
	part_icon_state = "r_arm"
	render_priority = POWER_ARMOR_LAYER_ARMS
	var/held_item_offset_x = 0  // See held_item_offset_x of /obj/item/power_armor_part/l_arm
	var/held_item_offset_y = 0  // See held_item_offset_y of /obj/item/power_armor_part/l_arm

/obj/item/power_armor_part/l_leg
	slot = EXOSKELETON_SLOT_L_LEG
	body_parts_covered = LEG_LEFT|FOOT_LEFT
	protected_bodyzone = BODY_ZONE_L_LEG
	icon_state = "l_leg_item"
	part_icon_state = "l_leg"
	render_priority = POWER_ARMOR_LAYER_LEGS

/obj/item/power_armor_part/r_leg
	slot = EXOSKELETON_SLOT_R_LEG
	body_parts_covered = LEG_RIGHT|FOOT_RIGHT
	protected_bodyzone = BODY_ZONE_R_LEG
	icon_state = "r_leg_item"
	part_icon_state = "r_leg"
	render_priority = POWER_ARMOR_LAYER_LEGS

/obj/item/power_armor_part/lining
	slot = EXOSKELETON_SLOT_LINING
	render_priority = POWER_ARMOR_LAYER_LINING
