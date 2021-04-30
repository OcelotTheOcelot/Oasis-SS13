/obj/item/power_armor_module
	name = "power armor module"
	icon_state = "module_item"
	w_class = WEIGHT_CLASS_NORMAL

	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the module, needed for balance
	
	var/slot = MODULE_SLOT_CHESTPLATE  // What slot the module is supposed to be installed into; only one is supported!
	var/obj/item/power_armor_part/part  // The part the module is installed into

	var/locks_hand = FALSE  // If FALSE, the held_item will be deployable, like borgs' tools
	var/hand_occupied = FALSE  // If the hand is currently occupied
	var/switch_item_and_module_rendering = FALSE  // If TRUE, the module won't be rendered when the item is deployed and vice versa
	var/obj/item/held_item_type  // If specified, the module prevents using bare hands when attached, placing item of the given type in the wearer's hands; generally used by modules for arms
	var/obj/item/held_item  // The representation of the item in the wearer's inventory

	// Overlays to render when the module is attached.
	// Represented by an associative list with part slots as keys and /datum/power_armor_overlay objects as values.
	var/list/power_armor_overlays = new
	var/render_priority  // The appearence of the default overlay

	var/list/module_actions = new  // List of actions that this module provides

	var/emp_reaction_chance = 60  // How likely is EMPs to cause this module's reaction

/obj/item/power_armor_module/examine(mob/user)
	. = ..()
	switch(tier)
		if(POWER_ARMOR_GRADE_ADVANCED)
			. += "<span class='notice'>This module uses advanced technologies and can not be installed in basic parts.</span>"
		if(POWER_ARMOR_GRADE_MILITARY)
			. += "<span class='notice'>This module uses military-grade technologies and can only be installed in military-grade parts.</span>"

/obj/item/power_armor_module/Initialize()
	..()
	if(held_item_type)
		held_item = new held_item_type(loc)
		held_item.forceMove(src)
		held_item.AddComponent(/datum/component/power_armor_item, src)
	for(var/datum/action/innate/power_armor/module/A in create_module_actions())
		A.module = src
		module_actions += A

/obj/item/power_armor_module/Destroy()
	remove_actions()
	for(var/datum/action/innate/power_armor/module/A in module_actions)
		QDEL_NULL(A)
	for(var/part_slot in power_armor_overlays)
		if(power_armor_overlays[part_slot])
			QDEL_NULL(power_armor_overlays[part_slot])
	..()

/obj/item/power_armor_module/emp_act(severity)
	if(prob(emp_reaction_chance))
		emp_reaction()

/* EMP reaction
Called when the exoskeleton is getting EMPed.
*/
/obj/item/power_armor_module/proc/emp_reaction()
	return

/* Get overlays for part slot
This proc is used to get matching overlays for parts, e.g. r_arm icon state for right arms.
Not recommended to be overriden.
Accepts:
	part_slot, the slot of the part the module will be rendered at
Returns:
	datum/power_armor_overlay object containing the according mutable_appearance
*/
/obj/item/power_armor_module/proc/get_overlays_for_part_slot(part_slot)
	if(!power_armor_overlays[part_slot])
		power_armor_overlays[part_slot] = create_overlays_for_part_slot(part_slot)
	return power_armor_overlays[part_slot]

/* Create overlays for part slot
This Proc is used to create matching overlays for parts, e.g. r_arm icon state for right arms.
Can be overriden.
Accepts:
	slot, the slot of the part the module will be rendered at
Returns:
	datum/power_armor_overlay object containing the according mutable_appearance
*/
/obj/item/power_armor_module/proc/create_overlays_for_part_slot(part_slot)
	. = list()
	var/datum/power_armor_overlay/PAO = new
	PAO.priority = render_priority
	PAO.appearance = mutable_appearance(icon, part_slot)
	. += PAO
	return .

/* Create module actions
Helper proc added for simplicity of module actions modification.
Creates module actions, the actions themselves aren't bound to the modules itself so they're unsafe to use.
Intended only to be overriden and not to be used anywhere else.
Returns:
	list of /datum/action/innate/power_armor/module/
*/
/obj/item/power_armor_module/proc/create_module_actions()
	return list()

/* Can be attached
Checks if the module can be attached to the part.
Its purpose is not to check for slot availability, which the part does, but to check for certain conditions that are unique to the module
(e.g. hydraulic claw can be attached only to the p5000pwl arms).
Returns:
	TRUE if the module can be attached to the part, FALSE otherwise
*/
/obj/item/power_armor_module/proc/can_be_attached(obj/item/power_armor_part/part)
	return TRUE

/* Occupy hand
If held_item_type is specified, puts an item of held_item_type to the wearer's occupied hand.
Accepts:
	forced, if set to TRUE will cause currently held item to be dropped on the floor, otherwise won't occupy hand in case it was already occupied.
*/
/obj/item/power_armor_module/proc/occupy_hand(forced = FALSE)
	if(!held_item_type)
		return
	var/mob/living/carbon/human/H = part?.exoskeleton?.wearer
	if(!istype(H))
		return
	var/hand_index = part.slot == EXOSKELETON_SLOT_L_ARM ? 1 : 2  // Really, there is no macros for hand indexes?
	if(H.get_item_for_held_index(hand_index) != null)
		if(forced)
			H.dropItemToGround(H.get_item_for_held_index(hand_index), force = TRUE)
		else
			return
	hand_occupied = TRUE
	H.put_in_hand(held_item, hand_index, forced = TRUE)
	H.update_inv_hands()
	if(switch_item_and_module_rendering)
		part.exoskeleton.power_armor_overlays -= get_overlays_for_part_slot(part.slot)
		part.exoskeleton.update_appearances()
		H.update_inv_wear_suit()

/* Free hand
If held_item_type is specified, deletes the held_item in the wearer's occupied hand.
*/
/obj/item/power_armor_module/proc/free_hand()
	if(!held_item_type)
		return
	if(held_item)
		held_item.forceMove(src)
		hand_occupied = FALSE
	var/mob/living/carbon/human/H = part?.exoskeleton?.wearer
	if(!istype(H))
		return
	H.update_inv_hands()
	if(switch_item_and_module_rendering)
		part.exoskeleton.power_armor_overlays += get_overlays_for_part_slot(part.slot)
		part.exoskeleton.update_appearances()
		H.update_inv_wear_suit()

/* Grant actions
Grants all actions of the module to the wearer.
*/
/obj/item/power_armor_module/proc/grant_actions()
	if(!(part?.exoskeleton?.wearer))
		return
	for(var/datum/action/innate/power_armor/module/A in module_actions)
		A.Grant(part.exoskeleton.wearer)

/* Remove actions
Removes all actions of the module from the wearer.
*/
/obj/item/power_armor_module/proc/remove_actions()
	if(!(part?.exoskeleton?.wearer))
		return
	for(var/datum/action/innate/power_armor/module/A in module_actions)
		A.Remove(part.exoskeleton.wearer)

/* On wearer entered
Called when the wearer enters the exoskeleton.
Grants related actions and items.
Accepts:
	user, the wearer
*/
/obj/item/power_armor_module/proc/on_wearer_entered(mob/user)
	if(locks_hand)  // Otherwise we let the wearer to deploy the tool manually
		occupy_hand(TRUE)
	grant_actions()

/* On wearer left
Called when the wearer leaves the exoskeleton.
Removes related actions and items.
Accepts:
	user, the wearer
*/
/obj/item/power_armor_module/proc/on_wearer_left(mob/user)
	free_hand()
	remove_actions()

/* On part broken
Called when the part holding the module is broken.
Removes related actions and items.
*/
/obj/item/power_armor_module/proc/on_part_broken()
	if(!locks_hand)
		free_hand()

/* Both legs intact
Helper proc, performs "broken" check for the exoskeleton legs for belt modules.
Returns:
	TRUE if both power armor legs are present and not broken, FALSE otherwise.
*/
/obj/item/power_armor_module/proc/both_legs_intact()
	var/obj/item/clothing/suit/armor/exoskeleton/E = part?.exoskeleton
	if(!istype(E))
		return FALSE
	if(!E.parts[EXOSKELETON_SLOT_L_LEG] || E.parts[EXOSKELETON_SLOT_L_LEG].broken)
		return FALSE
	if(!E.parts[EXOSKELETON_SLOT_R_LEG] || E.parts[EXOSKELETON_SLOT_R_LEG].broken)
		return FALSE
	return TRUE

/* Try apply item
Tries to apply an item on the module.
Called when the module's part is attacked with an item or when the part's try_apply_item is called.
Should be be useable in attackby as well.
Accepts:
	I, the item that the user tries to apply
	user, the mob applying the item
Returns:
	TRUE if the item was applied successfully, FALSE otherwise; returning TRUE is supposed to prevent other try_apply_item and attackby interactions 
*/
/obj/item/power_armor_module/proc/try_apply_item(obj/item/I, mob/user)
	return FALSE

/obj/item/power_armor_module/attackby(obj/item/W, mob/user, params)
	if(try_apply_item(W, user))
		return TRUE
	return ..(W, user, params)

/* On detached
Called when the module is detached from the part.
*/
/obj/item/power_armor_module/proc/on_detached()
	return

/* On attached
Called when the module is attached to a part.
*/
/obj/item/power_armor_module/proc/on_attached()
	return