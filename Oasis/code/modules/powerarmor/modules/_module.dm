/obj/item/power_armor_module
	name = "power armor module"
	icon_state = "module_item"

	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the module, needed for balance
	
	var/slot = MODULE_SLOT_CHESTPLATE  // What slot the module is supposed to be installed into; only one is supported!
	var/obj/item/power_armor_part/part  // The part the module is installed into

	var/locks_hand = FALSE  // If FALSE, the held_item will be deployable, like borgs' tools
	var/hand_occupied = FALSE  // If the hand is currently occupied
	var/obj/item/held_item_type  // If specified, the module prevents using bare hands when attached, placing item of the given type in the wearer's hands; generally used by modules for arms
	var/obj/item/held_item  // The representation of the item in the wearer's inventory

	var/list/power_armor_overlays = new  // Overlays to render when the module is attached as an associative list with part slots as keys and /datum/power_armor_overlay objects as values
	var/render_priority  // The appearence of the default overlay

	var/list/module_actions = new  // List of actions that this module provides

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
		held_item = new held_item_type()
		held_item.forceMove(src)
	for(var/datum/action/innate/power_armor/module/A in create_module_actions())
		A.module = src
		actions += A

/* Get overlays for part slot
This proc is used to get matching overlays for parts, e.g. r_arm icon state for right arms.
Not recommended to be overriden.
Accepts:
	slot, the slot of the part the module will be rendered at
Returns:
	datum/power_armor_overlay object containing the according mutable_appearance
*/
/obj/item/power_armor_module/proc/get_overlays_for_part_slot(slot)
	if(!power_armor_overlays[slot])
		power_armor_overlays[slot] = create_overlays_for_part_slot(slot)
	return power_armor_overlays[slot]

/* Create overlays for part slot
This Proc is used to create matching overlays for parts, e.g. r_arm icon state for right arms.
Can be overriden.
Accepts:
	slot, the slot of the part the module will be rendered at
Returns:
	datum/power_armor_overlay object containing the according mutable_appearance
*/
/obj/item/power_armor_module/proc/create_overlays_for_part_slot(slot)
	. = list()
	var/datum/power_armor_overlay/PAO = new
	PAO.priority = render_priority
	PAO.appearance = mutable_appearance(icon, slot)
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
	var/list/actions = new
	return actions

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
*/
/obj/item/power_armor_module/proc/occupy_hand()
	if(!held_item_type)
		return
	if(!(part && part.exoskeleton && part.exoskeleton.wearer))
		return
	var/mob/living/carbon/human/H = part.exoskeleton.wearer
	if(!istype(H))
		return
	var/hand_index = part.slot == EXOSKELETON_SLOT_L_ARM ? 1 : 2  // Really, there is no macros for hand indexes?
	if(H.get_item_for_held_index(hand_index) != null)
		H.dropItemToGround(H.get_item_for_held_index(hand_index), force = TRUE)
	hand_occupied = FALSE
	H.put_in_hand(held_item, hand_index, forced = TRUE)
	H.update_inv_hands()

/* Free hand
If held_item_type is specified, deletes the held_item in the wearer's occupied hand.
*/
/obj/item/power_armor_module/proc/free_hand()
	if(!held_item_type)
		return
	if(held_item)
		held_item.forceMove(src)
		hand_occupied = FALSE
	if(!(part && part.exoskeleton && part.exoskeleton.wearer))
		return
	var/mob/living/carbon/human/H = part.exoskeleton.wearer
	if(!istype(H))
		return
	H.update_inv_hands()

/* Grant actions
Grants all actions of the module to the wearer.
*/
/obj/item/power_armor_module/proc/grant_actions()
	if(!(part && part.exoskeleton && part.exoskeleton.wearer))
		return
	var/datum/action/innate/power_armor/module/A
	for(A in actions)
		A.Grant(part.exoskeleton.wearer)

/* Remove actions
Removes all actions of the module from the wearer.
*/
/obj/item/power_armor_module/proc/remove_actions()
	if(!(part && part.exoskeleton && part.exoskeleton.wearer))
		return
	var/datum/action/innate/power_armor/module/A
	for(A in actions)
		A.Remove(part.exoskeleton.wearer)

/* On wearer entered
Called when the wearer enters the exoskeleton.
Grants related actions and items.
Accepts:
	user, the wearer
*/
/obj/item/power_armor_module/proc/on_wearer_entered(mob/user)
	if(locks_hand)  // Otherwise we let the wearer to deploy the tool manually
		occupy_hand()
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
