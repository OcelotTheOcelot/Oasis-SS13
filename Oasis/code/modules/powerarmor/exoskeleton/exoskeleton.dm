/* Power armor system by NDOcelot (#4852)
Credits:
	NDOcelot
		for all the monkey code and most of the sprites;
	TottalyNotC
		for his balance recommendations, sprites and concepts;
	NDHavch1k
		for his balance recommendations, sprites and code;
*/

/obj/item/clothing/suit/armor/exoskeleton
	name = "exoskeleton"
	desc = "A complex system of servo-motors designed to support its wearer."

	// Note: we use our own magic to render the exoskeleton
	icon = 'Oasis/icons/powerarmor/exoskeleton/exoskeleton_basic.dmi'
	pass_flags = 0
	alternate_worn_icon = 'Oasis/icons/powerarmor/exoskeleton/exoskeleton_basic.dmi'
	icon_state = "torso"
	item_state = "item"
	var/exoskeleton_parts_icon = 'Oasis/icons/powerarmor/exoskeleton/exoskeleton_basic.dmi'  // What we render when there's no part attached
	layer = BELOW_MOB_LAYER

	// Be aware that if you remove this, you'll have to register the signal for on_mob_move() yourself.
	move_sound = list('sound/effects/servostep.ogg')

	strip_delay = 100
	equip_delay_other = 80
	pocket_storage_component_path = null
	allowed = list()
	density = TRUE

	w_class = WEIGHT_CLASS_GIGANTIC
	slowdown = 1
	var/bare_slowdown = -0.2  // What slowdown does the bare exoskeleton have when activated

	body_parts_covered = 0

	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the suit, determines what tier parts can be attached to it

	var/panel_opened = TRUE  // If the maintenance panel is opened
	var/obj/item/stock_parts/cell/cell  // The exoskeleton's power cell
	var/activated = FALSE  // Determines if the suit is active
	var/powered = FALSE  // Determines if the suit has a power cell with some charge in it
	var/step_power_consumption = 5  // How much power is drained when the wearer moves
	var/additive_slowdown  // How much the attached parts should slow the user down
	var/eqipment_delay = 0  // How much time it takes to equip the exoskeleton

	var/list/parts = new  // This list contains all the parts attached to the exoskeleton
	var/list/appearances = new  // This list contains all the overlays to be rendered, not to be mistaken with power_armor_overlays
	var/list/power_armor_overlays = new  // This list contains list of sortable power_armor_overlay datums that is processed into appearances to be rendered 

	var/disassemble_speed = 100  // How much time does it take to disassemble the exoskeleton
	var/mob/living/wearer  // Current wearer of the suit; use this instead of loc check, but prefer using 'user' proc parameter if present 
	var/datum/action/innate/power_armor/exoskeleton_eject/eject_action  // A datum responsible for ejection from exosuit
	var/list/exoskeleton_overlays = new  // An associative list containing appearances of bare parts to be rendered when there's no part attached.
	var/list/set_bonuses = new  // List of set bonuses as /datum/component/power_armor_set_bonus

/obj/item/clothing/suit/armor/exoskeleton/Initialize()
	. = ..()
	initialize_exoskeleton_overlays()
	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	eject_action = new(src)
	eject_action.exoskeleton = src
	update_appearances()
	update_icon()

/* Initialize exoskeleton overlays
Fills the exoskeleton_overlays list.
Couldn't be implemented with for loop because of different render layers.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/initialize_exoskeleton_overlays()
	var/datum/power_armor_overlay/PAO = new
	PAO.priority = POWER_ARMOR_LAYER_TORSO
	PAO.appearance = mutable_appearance(exoskeleton_parts_icon, "torso")
	exoskeleton_overlays[EXOSKELETON_SLOT_TORSO] += PAO
	PAO = new
	PAO.priority = POWER_ARMOR_LAYER_TORSO
	PAO.appearance = mutable_appearance(exoskeleton_parts_icon, "torso_opened")
	exoskeleton_overlays["[EXOSKELETON_SLOT_TORSO]_opened"] += PAO
	PAO = new
	PAO.priority = POWER_ARMOR_LAYER_ARMS
	PAO.appearance = mutable_appearance(exoskeleton_parts_icon, "l_arm")
	exoskeleton_overlays[EXOSKELETON_SLOT_L_ARM] += PAO
	PAO = new
	PAO.priority = POWER_ARMOR_LAYER_ARMS
	PAO.appearance = mutable_appearance(exoskeleton_parts_icon, "r_arm")
	exoskeleton_overlays[EXOSKELETON_SLOT_R_ARM] += PAO
	PAO = new
	PAO.priority = POWER_ARMOR_LAYER_LEGS
	PAO.appearance = mutable_appearance(exoskeleton_parts_icon, "l_leg")
	exoskeleton_overlays[EXOSKELETON_SLOT_L_LEG] += PAO
	PAO = new
	PAO.priority = POWER_ARMOR_LAYER_LEGS
	PAO.appearance = mutable_appearance(exoskeleton_parts_icon, "r_leg")
	exoskeleton_overlays[EXOSKELETON_SLOT_R_LEG] += PAO

/obj/item/clothing/suit/armor/exoskeleton/examine(mob/user)
	. = ..()
	if(!QDELETED(cell))
		. += "<span class='notice'>The power indicator reads that \the [src] is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>\The [src] has no power source installed.</span>"
	. += "<span class='notice'>Its maintenance panel is [panel_opened ? "opened" : "closed"]</span>"

	for(var/P in parts)
		if(!parts[P])
			continue
		. += "<span class='notice'>It has \the [parts[P]] attached.</span>"
		var/additional_info = parts[P].get_examination_line()
		if(additional_info)
			. += additional_info

	for(var/datum/component/power_armor_set_bonus/set_bonus in set_bonuses)
		. += "<span class='boldnotice'>[set_bonus.desc]</span>"

/obj/item/clothing/suit/armor/exoskeleton/Destroy()
	if(!QDELETED(cell))
		QDEL_NULL(cell)
	for(var/P in parts)
		QDEL_NULL(parts[P])
	if(eject_action)
		QDEL_NULL(eject_action)
	if(wearer)
		toggle_offsets(wearer, FALSE)
	return ..()

/obj/item/clothing/suit/armor/exoskeleton/handle_atom_del(atom/A)
	. = ..()
	if(A == cell)
		cell = null
		depower()
	return ..()

/obj/item/clothing/suit/armor/exoskeleton/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_OCLOTHING)
		wearer = user
		toggle_offsets(user, TRUE)
		
		dir = SOUTH

		if(eject_action)
			eject_action.Grant(user, src)
		ADD_TRAIT(user, TRAIT_EXOSKELETON, CLOTHING_TRAIT)
		for(var/P in parts)
			parts[P].on_wearer_entered(user)

		if(powered && !activated)
			activate()
		if(slowdown < 0)
			to_chat(user, "<span class='notice'>Your movement becomes more free and your limbs feel more lightweight!</span>")
		else if(!powered)
			to_chat(user, "<span class='warning'>Your limbs can hardly move in this unpowered [name]...</span>")
		else
			to_chat(user, "<span class='notice'>It's difficult to move in this bulky suit...</span>")

		// if user.has_trauma_type ... <TODO> paraplegic people should gain ability to walk using this

/obj/item/clothing/suit/armor/exoskeleton/dropped(mob/living/user)
	if(is_equipped(user))
		for(var/P in parts)
			parts[P].on_wearer_left(user)

		if(eject_action)
			eject_action.Remove(user)

		toggle_offsets(user, FALSE)
		var/obj/item/clothing/head/helmet/power_armor/helmet = user.get_item_by_slot(ITEM_SLOT_HEAD)
		if(istype(helmet) && !helmet.mob_can_equip(user, user, ITEM_SLOT_HEAD, disable_warning = TRUE))
			user.dropItemToGround(helmet)

		REMOVE_TRAIT(user, TRAIT_EXOSKELETON, CLOTHING_TRAIT)
		wearer = null

		if(activated)
			deactivate()
		if(slowdown < 0)
			to_chat(user, "<span class='notice'>Your limbs feel unusually heavy.</span>")
		else
			to_chat(user, "<span class='notice'>Your limbs feel more free.</span>")
	..()

/* Toggle offset
Tweaks the wearer's y icon offset so they look taller in the exoskeleton and vice versa.
Accepts:
	user, the wearer of the exoskeleton whose offsets are being tweaked
	equipped, if the offsets should be added or restored
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/toggle_offsets(mob/living/carbon/user, equipped = FALSE)
	if(!istype(user))
		return

	if(equipped)
		user.pixel_y += EXOSKELETON_ADDITIONAL_HEIGHT
		worn_y_dimension -= 2 * EXOSKELETON_ADDITIONAL_HEIGHT
	else
		user.pixel_y -= EXOSKELETON_ADDITIONAL_HEIGHT
		worn_y_dimension = world.icon_size
	toggle_hand_offsets(user, equipped)
	user.update_inv_wear_suit()

/* Toggle hand offsets
Updates the offsets for the icons of the held items to corresponds the offsets of the arms attached.
Accepts:
	user, the wearer of the exoskeleton whose offsets are being tweaked
	equipped, if the offsets should be added or restored
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/toggle_hand_offsets(mob/living/carbon/user, equipped = FALSE)
	if(!iscarbon(user))
		return

	if(equipped)
		// Note: x-offset is not implemented and I doubt it is possible to be.
		var/obj/item/power_armor_part/l_arm/l_arm = parts[EXOSKELETON_SLOT_L_ARM]
		if(istype(l_arm))
			user.item_inhand_offsets[1]["y"] -= l_arm.item_inhand_offsets["y"]
		var/obj/item/power_armor_part/r_arm/r_arm = parts[EXOSKELETON_SLOT_R_ARM]
		if(istype(r_arm))
			user.item_inhand_offsets[2]["y"] -= r_arm.item_inhand_offsets["y"]
	else
		// Believe me I intented to make it initial(C.item_inhand_offsets), but it returns null; I guess it's because lists aren't initialized when set as default values.
		user.item_inhand_offsets = list(
			list("x" = 0, "y" = 0),
			list("x" = 0, "y" = 0)
		)

	user.update_inv_hands()

/* Update slowdown
Helper proc used to recalculate and update current slowdown.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/update_slowdown()
	slowdown = (activated ? bare_slowdown : initial(slowdown)) + additive_slowdown

/* Power
Called when the cell is inserted or recharged.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/power()
	if(powered)
		return
	powered = TRUE
	to_chat(wearer, "<span class='notice'>\The [src]'s power has been restored!</span>")
	if(!activated)
		activate()

/* Depower
Called when the cell is dead or taken off.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/depower()
	if(!powered)
		return
	powered = FALSE
	if(!QDELETED(wearer))
		if(QDELETED(cell))
			to_chat(wearer, "<span class='warning'>\The [src] has lost its power source!</span>")
		else
			to_chat(wearer, "<span class='warning'>\The [src]'s [cell] is dead!</span>")
	deactivate()

/* Drain power
Drains some amount of power from the cell.
Accepts:
	amount, the amount of power to drain
Returns:
	TRUE if cell was used successfully, FALSE if it's dead or missing
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/drain_power(amount)
	if(QDELETED(cell))
		depower()
		return FALSE
	if(!cell?.use(amount))
		if(cell.charge <= 0)
			depower()
		return FALSE
	return TRUE

/* Charge
Charges the exoskeleton's cell.
Accepts:
	amount, the amount of power to charge the cell with
Returns:
	the amount of power given to the cell or 0 if it's missing 
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/charge(amount)
	var/power_used = 0
	if(QDELETED(cell))
		depower()
		return power_used
	power_used = cell.give(amount)
	if(power_used > 0)
		power()
	return power_used

/obj/item/clothing/suit/armor/exoskeleton/on_mob_move()
	drain_power(step_power_consumption)
	..()

/* Activate
Called when the suit is equipped and powered.
May be used for manual (de)activation later.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/activate()
	if(!powered)
		return
	activated = TRUE
	update_slowdown()

/* Deactivate
Called when the suit is dequipped or unpowered.
May be used for manual (de)activation later.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/deactivate()
	activated = FALSE
	update_slowdown()

/* Attach part
Takes a power_armor part and attaches it to the exoskeleton
Accepts:
	P, the part to attach
	transfer, if the part shoud be moved to the exoskeleton; pass FALSE only when it's handled separately
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/attach_part(obj/item/power_armor_part/P, transfer = TRUE)
	if(!istype(P))
		return
	if(transfer)
		P.forceMove(src)
	parts[P.slot] = P
	P.exoskeleton = src
	P.on_attached(src)
	if(wearer)
		P.on_wearer_entered(wearer)
		wearer.update_inv_wear_suit()

	body_parts_covered |= P.body_parts_covered
	power_armor_overlays |= P.power_armor_overlays
	additive_slowdown += P.slowdown
	eqipment_delay += P.eqipment_delay

	update_slowdown()
	update_appearances()
	toggle_hand_offsets(wearer, TRUE)
	update_set_bonus()
	update_icon()

/* Detach part
Detaches power armor part from the exoskeleton.
Accepts:
	slot, the slot to detach the part from
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/detach_part(slot)
	var/obj/item/power_armor_part/P = parts[slot]
	if(!istype(P))
		return
	P.on_detached(src)
	if(wearer)
		P.on_wearer_left(wearer)
		wearer.update_inv_wear_suit()
	P.forceMove(get_turf(src))
	parts -= slot
	P.exoskeleton = null

	body_parts_covered &= ~P.body_parts_covered
	power_armor_overlays -= P.power_armor_overlays
	additive_slowdown -= P.slowdown
	eqipment_delay -= P.eqipment_delay

	update_slowdown()
	update_appearances()
	toggle_hand_offsets(wearer, TRUE)
	update_set_bonus()
	update_icon()

/obj/item/clothing/suit/armor/exoskeleton/update_icon()
	..()
	cut_overlays()
	// Snowflake code to render the empty torso
	var/obj/item/power_armor_part/torso/T = parts[EXOSKELETON_SLOT_TORSO]
	if(istype(T) && T.uses_empty_state)
		add_overlay(mutable_appearance(T.icon, "torso_empty"))

	for(var/mutable_appearance/MA in appearances)
		add_overlay(MA)

/obj/item/clothing/suit/armor/exoskeleton/worn_overlays(isinhands = FALSE)
	. = ..()
	. |= appearances

/* Update appearances
Updates the schedule of mutable_appearances to be rendered over the exoskeleton.
The mutable_appearance's are extracted from power_armor_overlays.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/update_appearances()
	appearances = list()

	var/list/overlays_to_render = new
	overlays_to_render |= power_armor_overlays
	// Ikr this is not the most exemplary piece of code
	for(var/part_slot in (exoskeleton_overlays - parts - "[EXOSKELETON_SLOT_TORSO]_opened"))
		if(part_slot == EXOSKELETON_SLOT_TORSO && panel_opened)
			overlays_to_render += exoskeleton_overlays["[EXOSKELETON_SLOT_TORSO]_opened"]
			continue
		overlays_to_render += exoskeleton_overlays[part_slot]
	for(var/datum/power_armor_overlay/PAO in sortTim(overlays_to_render, cmp = /proc/cmp_power_armor_overlays_render_order, associative = FALSE))
		appearances += PAO.appearance

/* Disassemble
Deletes the exoskeleton and spawns its disassembled version.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/disassemble()
	var/obj/item/exoskeleton_assembly/E = new(get_turf(src))
	E.obj_integrity = obj_integrity
	if(!QDELETED(cell))
		cell.update_icon()
		cell.forceMove(get_turf(src))
	QDEL_NULL(src)

/* Is equipped
Helper proc used to determine if the suit is equipped by the wearer.
I wonder why nobody has written something like it for /obj/item/clothing.
Accepts:
	user, the wearer
Returns:
	TRUE if the suit is equipped, FALSE otherwise
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/is_equipped(mob/living/carbon/human/user)
	if(istype(user))
		return user.wear_suit == src
	return FALSE

/* Eject
Makes the mob dequip the exosuit, the exosuit is dropped on the floor.
Accepts:
	user, the wearer
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/eject(mob/user)
	if(!is_equipped(user))
		return
	to_chat(user, "<span class='notice'>You begin to eject yourself from \the [src]...</span>")
	if(do_after(user, eqipment_delay, target = user) && user.dropItemToGround(src, TRUE))
		user.update_inv_wear_suit()
		dir = user.dir
		to_chat(user, "<span class='notice'>You eject yourself from \the [src].</span>")

/obj/item/clothing/suit/armor/exoskeleton/attack_hand(mob/user)
	if(panel_opened)
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You remove \the [cell] from \the [src].</span>")
			cell = null
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			depower()
		else
			to_chat(user, "<span class='warning'>There is no power cell in \the [src]!</span>")
	return attack_animal(user)  // Thus we prohibit humans from picking the suit up in their hands

/obj/item/clothing/suit/armor/exoskeleton/MouseDrop_T(mob/living/carbon/human/M, mob/living/user)
	if(!istype(user))
		return
	if(!istype(M))
		if(istype(M, /mob/living))
			to_chat(user, "<span class='warning'>\The [src] is designed to be worn by humanlike lifeforms only!</span>")
		return
	if(M.wear_suit)
		if(M == user)
			to_chat(user, "<span class='warning'>You already have a suit equipped!</span>")
		else
			user.visible_message(
				"<span class='warning'>[user] attempts to put [M] into \the [src], but they already have a suit equipped!</span>",
				"<span class='warning'>You attempt to put [M] into \the [src], but they already have a suit equipped!</span>"
			)
		return
	if(M == user)
		to_chat(user, "<span class='notice'>You begin entering \the [src]...</span>")
	else
		user.visible_message(
			"<span class='warning'>[user] attempts to put [M] into \the [src]!</span>",
			"<span class='warning'>You attempt to put [M] into \the [src]!</span>"
		)
	if(do_after(M, eqipment_delay, target = src))
		M.loc = loc  // I just hope you can't enter an already worn suit by any means... <TODO> investigate this 
		M.dir = dir
		sleep(1)  // This simply prevents the suit transfering animation from being noticeable
		M.equip_to_slot_if_possible(src, ITEM_SLOT_OCLOTHING)

/obj/item/clothing/suit/armor/exoskeleton/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	// Note: this system is imperfect since the intercepting part selection is unrandomized. No one is going to notice, I guess. 
	for(var/P in parts)
		var/obj/item/power_armor_part/part = parts[P]
		if(!istype(part) || part.broken)
			continue
		part.take_damage(damage_amount, damage_type, damage_flag, sound_effect)
		return
	return ..()

/* Update set bonus
Applies and removes armor set bonuses regarding the amount of parts from one set.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/update_set_bonus()
	return
	// var/list/sets = new
	// for(var/P in parts)
	// 	var/obj/item/power_armor_part/part = parts[P]
	// 	if(!istype(part) || !part.set_bonus)
	// 		continue
	// 	var/datum/component/power_armor_set_bonus/set_type = part.set_bonus.type
	// 	sets[set_type] = (sets[set_type] || 0) + 1

	// // Firstly, we remove existing set bonuses if there's not enough parts for full set...
	// for(var/datum/component/power_armor_set_bonus/set_bonus in set_bonuses)
	// 	if((sets[set_bonus.type] || 0) < set_bonus.amount_for_full_set)
	// 		set_bonus.deactivate()
	// 		set_bonuses.Remove(set_bonus)

	// // Then, we add non-existing bonuses...
	// for(var/datum/component/power_armor_set_bonus/set_type in sets)
	// 	if(sets[set_type] >= set_type.amount_for_full_set)
	// 		var/new_bonus = AddComponent(/datum/component/power_armor_set_bonus)
	// 		set_bonuses.Add(new_bonus)

/obj/item/clothing/suit/armor/exoskeleton/attackby(obj/item/W, mob/user, params)
	var/equipped = is_equipped(user)
	var/bare = parts.len <= 0
	var/selected_part_slot = zone_to_exoskeleton_slot(user.zone_selected)
	var/obj/item/power_armor_part/selected_part = parts[selected_part_slot]

	// Behold, horrible if-else spaghetti code!!
	if(panel_opened && istype(W, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There's already a cell installed in \the [src].</span>")
		else
			if(!user.transferItemToLoc(W, src))
				return TRUE
			cell = W
			to_chat(user, "<span class='notice'>You install \the [W] in \the [src].</span>")
			playsound(src.loc, 'sound/machines/click.ogg', 10, TRUE)
			if(!powered)
				power()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(!selected_part)
			if(selected_part_slot == EXOSKELETON_SLOT_TORSO)
				panel_opened = !panel_opened
				update_appearances()
				update_icon()
				to_chat(user, "<span class='notice'>You [panel_opened ? "open" : "close"] the maintenance panel.</span>")
				playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			else
				to_chat(user, "<span class='notice'>There's no part to take modules from!</span>")
			return TRUE
		if(equipped)
			to_chat(user, "<span class='warning'>You can not uninstall modules to \the [src] while you are wearing it!</span>")
			return TRUE
		if (selected_part.modules.len <= 0)
			to_chat(user, "<span class='notice'>\The [selected_part] has no modules installed!</span>")
			return TRUE
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		selected_part.detach_all_modules()
		to_chat(user, "<span class='notice'>You uninstall all modules from \the [selected_part].</span>")

	else if(istype(W, /obj/item/power_armor_part))
		if(equipped)
			to_chat(user, "<span class='warning'>You can not add parts to \the [src] while you are wearing it!</span>")
			return TRUE
		var/obj/item/power_armor_part/part = W
		var/obj/item/other_tool = find_tool(user, TOOL_WRENCH)
		if(!other_tool)
			to_chat(user, "<span class='warning'>You need a wrench to attach parts to \the [src].</span>")
			return TRUE
		if(part.tier > tier)
			to_chat(user, "<span class='warning'>\The [part] is too advanced for \the [src] to support!</span>")
			return TRUE
		if(part.slot == EXOSKELETON_SLOT_LINING && !bare)
			to_chat(user, "<span class='warning'>A lining layer can be added only onto a bare exoskeleton!</span>")
			return TRUE
		if(!part.pauldron_compatible)
			var/obj/item/power_armor_part/torso/T = parts[EXOSKELETON_SLOT_TORSO]
			if(istype(T) && T.pauldrons)
				to_chat(user, "<span class='warning'>\The [part] is incompatible with \the [T]'s pauldrons!</span>")
				return TRUE
		if(part.slot == EXOSKELETON_SLOT_TORSO)
			if(panel_opened)
				to_chat(user, "<span class='warning'>You have to close the maintenance panel before adding [part]!</span>")
				return TRUE
			var/obj/item/power_armor_part/torso/T = part
			if(istype(T) && T.pauldrons)
				for(var/P in parts)
					if(parts[P] && !parts[P].pauldron_compatible)
						to_chat(user, "<span class='warning'>\The [part]'s pauldrons are incompatible with \the [P]!</span>")
						return TRUE
		var/obj/item/power_armor_part/previous_part = parts[part.slot]  // Should be safer than using selected_part y'know
		if(previous_part)
			to_chat(user, "<span class='warning'>This junction is already occupied by \the [previous_part]!</span>")
			return TRUE
		to_chat(user, "<span class='notice'>You begin to attach \the [W] to \the [src]...</span>")
		other_tool.play_tool_sound(src)
		if(do_after(user, part.attachment_speed, target = src) && user.transferItemToLoc(W, src))
			attach_part(part, transfer = FALSE)
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			to_chat(user, "<span class='notice'>You attach \the [W] to \the [src].</span>")

	else if(W.tool_behaviour == TOOL_WRENCH)
		if(equipped)
			to_chat(user, "<span class='warning'>You can not detach parts from \the [src] while you are wearing it!</span>")
			return TRUE
		if(panel_opened && bare)
			to_chat(user, "<span class='notice'>You begin disassembling \the [src]...</span>")
			W.play_tool_sound(src)
			if(do_after(user, disassemble_speed, target = src))
				playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
				to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
				disassemble()
		else
			if(selected_part)
				to_chat(user, "<span class='notice'>You begin to detach \the [selected_part] from \the [src]...</span>")
				W.play_tool_sound(src)
				if(do_after(user, selected_part.detachment_speed, target = src))
					detach_part(selected_part_slot)
					playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
					to_chat(user, "<span class='notice'>You detach \the [selected_part] from \the [src].</span>")
			else
				to_chat(user, "<span class='warning'>There's nothing to detach from this junction!</span>")

	else if(istype(W, /obj/item/power_armor_module))
		if(equipped)
			to_chat(user, "<span class='warning'>You can not attach modules to \the [src] while you are wearing it!</span>")
			return TRUE
		if(selected_part)
			if(selected_part.can_accept_module(W) && user.transferItemToLoc(W, selected_part))
				playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
				selected_part.attach_module(W)
				to_chat(user, "<span class='notice'>You install \the [W] in \the [selected_part].</span>")
			else
				to_chat(user, "<span class='warning'>\The [W] can not fit into \the [selected_part]!</span>")
		else
			to_chat(user, "<span class='notice'>There's no part to hold this module!</span>")

	else if(selected_part?.try_apply_item(W, user))
		return TRUE

	return ..(W, user, params)

/* Find tool
Checks if some tool is present nearby the user
This proc exists in order to not change exisiting /datum/component/personal_crafting/proc/check_tools,
because it wasn't flexible enough for this particular case.
Accepts:
	user, the mob to find the tool nearby,
	tool_behaviour, what type of tool that should be
	blacklist, a list of types of items to be ignored during the search
	radius_range, the range of the area to search in
Returns:
	found item or null
*/
proc/find_tool(mob/living/user, tool_behaviour, list/blacklist = null, radius_range = 1)
	if(!isturf(user.loc))
		return null
	for(var/obj/item/I in range(radius_range, user))
		if((I.flags_1 & HOLOGRAM_1) || (blacklist && (I.type in blacklist)))
			continue
		if((I.tool_behaviour == tool_behaviour))
			return I
	return null
