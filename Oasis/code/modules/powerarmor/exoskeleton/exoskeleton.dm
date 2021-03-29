/* Power armor system by
	NDOcelot (#4852) (spriting and coding),
	TotyalyNotC (spriting)
	and
	NDHavch1k (spriting)
*/

/obj/item/clothing/suit/armor/exoskeleton
	name = "exoskeleton"
	desc = "A complex system of servo-motors designed to support its wearer."

	// Note: we use our own magic to render the exoskeleton
	icon = null
	alternate_worn_icon = null
	icon_state = ""
	item_state = ""
	var/exoskeleton_parts_icon = 'Oasis/icons/powerarmor/exoskeleton/exoskeleton_basic.dmi'  // What we render when there's no part attached

	strip_delay = 100
	equip_delay_other = 80
	pocket_storage_component_path = null
	allowed = list()
	density = TRUE

	w_class = WEIGHT_CLASS_GIGANTIC
	slowdown = EXOSKELETON_DEACTIVATED_SLOWDOWN

	body_parts_covered = 0

	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the suit, determines what tier parts can be attached to it

	var/panel_opened = TRUE  // If the maintenance panel is opened
	var/obj/item/stock_parts/cell/cell  // The exoskeleton's power cell
	var/activated = FALSE  // Determines if the suit is active
	var/powered = FALSE  // Determines if the suit has a power cell with some charge in it

	var/additive_slowdown  // How much the attached parts should slow the user down
	var/eqipment_delay = 0  // How much time it takes to equip the exoskeleton

	var/list/parts = new // This list contains all the parts attached to the exoskeleton
	var/list/exoskeleton_overlays = new // This list contains all the overlays to be rendered

	var/disassemble_speed = 100 // How much time does it take to disassemble the exoskeleton


	var/mob/living/wearer  // Current wearer of the suit, prefer using 'user' parameter if possible
	var/datum/action/innate/power_armor/exoskeleton_eject/eject_action  // A datum responsible for ejection from exosuit
	var/static/exoskeleton_parts = list(
		EXOSKELETON_SLOT_TORSO = "torso",
		EXOSKELETON_SLOT_L_ARM = "l_arm",
		EXOSKELETON_SLOT_R_ARM = "r_arm",
		EXOSKELETON_SLOT_L_LEG = "l_leg",
		EXOSKELETON_SLOT_R_LEG = "r_leg"
	)

/obj/item/clothing/suit/armor/exoskeleton/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)
	eject_action = new(src)
	eject_action.exoskeleton = src
	update_exoskeleton_overlays()
	update_icon()

/obj/item/clothing/suit/armor/exoskeleton/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>The power indicator reads that \the [src] is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>\The [src] has no power source installed.</span>"
	. += "<span class='notice'>Its maintenance panel is [panel_opened ? "opened" : "closed"]</span>"

	var/P
	for(P in parts)
		. += "<span class='notice'>It has [parts[P]] attached.</span>"

/obj/item/clothing/suit/armor/exoskeleton/Destroy()
	if(cell)
		QDEL_NULL(cell)
	var/obj/item/power_armor_part/P
	for(P in parts)
		QDEL_NULL(P)
	if(eject_action)
		QDEL_NULL(eject_action)
	toggle_offset(FALSE)
	return ..()

/obj/item/clothing/suit/armor/exoskeleton/handle_atom_del(atom/A)
	. = ..()
	if(A == cell)
		cell = null
		depower()
	return ..()

/obj/item/clothing/suit/armor/exoskeleton/equipped(mob/user, slot)
	..()
	if(slot == SLOT_WEAR_SUIT)
		wearer = user
		toggle_offset(user, TRUE)
		dir = SOUTH

		eject_action.Grant(user, src)
		ADD_TRAIT(user, TRAIT_EXOSKELETON, CLOTHING_TRAIT)
		var/P
		for(P in parts)
			parts[P].on_wearer_entered(user)

		if(powered && !activated)
			activate()
		if(slowdown < 0)
			to_chat(user, "<span class='notice'>Your movement becomes more free and your limbs feel more lightweight!</span>")
		else if(!powered)
			to_chat(user, "<span class='warning'>Your limbs can hardly move in this unpowered [src]...</span>")
		else
			to_chat(user, "<span class='notice'>It's kinda difficult to move in this bulky suit...</span>")
		// if user.has_trauma_type ... <TODO> paraplegic people should gain ability to walk using this

/obj/item/clothing/suit/armor/exoskeleton/dropped(mob/living/user)
	if(is_equipped(user))
		wearer = null
		toggle_offset(user, FALSE)

		eject_action.Remove(user)
		REMOVE_TRAIT(user, TRAIT_EXOSKELETON, CLOTHING_TRAIT)
		var/P
		for(P in parts)
			parts[P].on_wearer_left(user)

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
	user, the wearer of the exoskeleton whose offsets are being tweaked.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/toggle_offset(mob/living/carbon/user, equipped=FALSE)
	if(equipped)
		user.pixel_y += EXOSKELETON_ADDITIONAL_HEIGHT
		worn_y_dimension -= 2 * EXOSKELETON_ADDITIONAL_HEIGHT
	else
		user.pixel_y -= EXOSKELETON_ADDITIONAL_HEIGHT
		worn_y_dimension = world.icon_size
	user.update_inv_wear_suit()

/* Update slowdown
Helper proc used to recalculate and update current slowdown.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/update_slowdown()
	slowdown = (activated ? EXOSKELETON_ACTIVATED_SLOWDOWN : EXOSKELETON_DEACTIVATED_SLOWDOWN) + additive_slowdown

/* Power
Called when the cell is inserted.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/power()
	powered = TRUE
	if(!activated)
		activate()

/* Depower
Called when the cell is dead or taken off.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/depower()
	powered = FALSE
	deactivate()

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
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/attach_part(obj/item/power_armor_part/P)
	parts[P.slot] = P
	body_parts_covered |= P.body_parts_covered
	P.exoskeleton = src

	additive_slowdown += P.slowdown
	eqipment_delay += P.eqipment_delay

	update_slowdown()
	update_exoskeleton_overlays()
	update_hand_offsets()
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
	P.forceMove(get_turf(src))
	parts -= slot
	body_parts_covered &= ~P.body_parts_covered
	P.exoskeleton = null

	additive_slowdown -= P.slowdown
	eqipment_delay -= P.eqipment_delay

	update_slowdown()
	update_exoskeleton_overlays()
	update_hand_offsets()
	update_icon()

/* Update hand offsets
Updates the offsets for the icons of the held items to correspons the offsets of the arms attached.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/update_hand_offsets()
	// <TODO>

/obj/item/clothing/suit/armor/exoskeleton/update_icon()
	..()
	cut_overlays()
	var/mutable_appearance/MA
	for(MA in exoskeleton_overlays)
		add_overlay(MA)

/obj/item/clothing/suit/armor/exoskeleton/worn_overlays(isinhands = FALSE)
	. = ..()
	. |= exoskeleton_overlays

/* Update exoskeleton overlays
Updates the schedule of icons to be rendered over the user of the exoskeleton and applies the according overlay.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/update_exoskeleton_overlays()
	exoskeleton_overlays = list()

	var/part_slot
	for(part_slot in (exoskeleton_parts - parts))
		var/part_icon_state = exoskeleton_parts[part_slot]
		if(part_slot == EXOSKELETON_SLOT_TORSO && panel_opened)
			part_icon_state = "torso_opened"
		exoskeleton_overlays += mutable_appearance(exoskeleton_parts_icon, part_icon_state)
	// We need to sort the attached parts before we render them, hence the additional loop.
	for(part_slot in sortTim(parts, cmp=/proc/cmp_parts_render_order, associative=TRUE))
		var/obj/item/power_armor_part/P = parts[part_slot]
		exoskeleton_overlays += mutable_appearance(P.icon, P.part_icon_state)
		var/module_slot
		for(module_slot in P.modules)
			var/obj/item/power_armor_module/M = P.modules[module_slot]
			if(istype(M))
				exoskeleton_overlays += mutable_appearance(M.icon, part_slot)

/* Disassemble
Deletes the exoskeleton and spawns its disassembled version.
*/
/obj/item/clothing/suit/armor/exoskeleton/proc/disassemble()
	var/obj/item/exoskeleton_assembly/E = new(get_turf(src))
	E.obj_integrity = obj_integrity
	if(cell)
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
	if(do_after(user, eqipment_delay, target = src))
		user.dropItemToGround(src, TRUE)
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
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			depower()
		else
			to_chat(user, "<span class='warning'>There is no power cell in \the [src]!</span>")
	return attack_animal(user)  // Thus we prohibit humans from picking the suit up in their hands

/obj/item/clothing/suit/armor/exoskeleton/MouseDrop_T(mob/M, mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.wear_suit)
		to_chat(user, "<span class='warning'>You already have a suit equipped!</span>")
		return
	to_chat(user, "<span class='notice'>You begin entering \the [src]...</span>")
	if(do_after(user, eqipment_delay, target = src))
		user.loc = loc
		user.dir = dir
		sleep(1)  // This simply prevents the suit transfering animation from being noticeable
		user.equip_to_slot_if_possible(src, SLOT_WEAR_SUIT)

/obj/item/clothing/suit/armor/exoskeleton/attackby(obj/item/W, mob/user, params)
	var/equipped = is_equipped(user)
	var/bare = parts.len <= 0

	// Behold, horrible if-else spaghetti code!!
	if(panel_opened && istype(W, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There's already a cell installed in \the [src].</span>")
		else
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You install \the [W] in \the [src].</span>")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			if(!powered)
				power()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(bare)
			panel_opened = !panel_opened
			update_exoskeleton_overlays()
			update_icon()
			to_chat(user, "<span class='notice'>You [panel_opened ? "open" : "close"] the maintenance panel.</span>")
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		else
			var/obj/item/power_armor_part/part = parts[zone_to_exoskeleton_slot(user.zone_selected)]
			if(part)
				if (part.modules.len <= 0)
					to_chat(user, "<span class='notice'>\The [part] has no modules installed!</span>")
					return
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				part.detach_all_modules()
				to_chat(user, "<span class='notice'>You uninstall all modules from \the [part].</span>")
			else
				to_chat(user, "<span class='notice'>There's no part to take modules from!</span>")

	else if(istype(W, /obj/item/power_armor_part))
		if(equipped)
			to_chat(user, "<span class='warning'>You can not add parts to \the [src] while you are wearing it!</span>")
			return
		if(panel_opened)
			to_chat(user, "<span class='warning'>You have to close the maintenance panel before adding parts!</span>")
			return
		var/obj/item/power_armor_part/part = W
		var/obj/item/other_item = user.get_inactive_held_item()
		if(!other_item || other_item.tool_behaviour != TOOL_WRENCH)
			to_chat(user, "<span class='warning'>You need a wrench to attach parts to \the [src].</span>")
			return
		if(part.tier > tier)
			to_chat(user, "<span class='warning'>\The [part] is too advanced for \the [src] to support!</span>")
			return
		if(part.slot == EXOSKELETON_SLOT_LINING && !bare)
			to_chat(user, "<span class='notice'>A lining layer can be added only onto a bare exoskeleton!</span>")
			return
		var/obj/item/power_armor_part/previous_part = parts[part.slot]
		if(previous_part)
			to_chat(user, "<span class='warning'>This junction is already occupied by \the [previous_part]!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to attach \the [W] to \the [src]...</span>")
		other_item.play_tool_sound(src)
		if(do_after(user, part.attachment_speed, target = src) && user.transferItemToLoc(W, src))
			attach_part(part)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You attach \the [W] to \the [src].</span>")

	else if(W.tool_behaviour == TOOL_WRENCH)
		if(equipped)
			to_chat(user, "<span class='warning'>You can not detach parts from \the [src] while you are wearing it!</span>")
			return
		if(panel_opened && bare)
			to_chat(user, "<span class='notice'>You begin disassembling \the [src]...</span>")
			W.play_tool_sound(src)
			if(do_after(user, disassemble_speed, target = src))
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
				disassemble()
		else
			var/slot = zone_to_exoskeleton_slot(user.zone_selected)
			var/obj/item/power_armor_part/part = parts[slot]
			if(part)
				to_chat(user, "<span class='notice'>You begin to detach \the [part] from \the [src]...</span>")
				W.play_tool_sound(src)
				if(do_after(user, part.detachment_speed, target = src))
					detach_part(slot)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You detach \the [part] from \the [src].</span>")
			else
				to_chat(user, "<span class='warning'>There's nothing to detach from this junction!</span>")

	else if(istype(W, /obj/item/power_armor_module))
		if(equipped)
			to_chat(user, "<span class='warning'>You can not attach modules to \the [src] while you are wearing it!</span>")
			return
		var/obj/item/power_armor_module/module = W
		var/obj/item/power_armor_part/part = parts[zone_to_exoskeleton_slot(user.zone_selected)]
		if(part)
			if(part.can_accept_module(module) && user.transferItemToLoc(W, part))
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				part.attach_module(module)
				to_chat(user, "<span class='notice'>You install \the [module] in \the [part].</span>")
			else
				to_chat(user, "<span class='warning'>\The [module] can not fit into \the [part]!</span>")
		else
			to_chat(user, "<span class='notice'>There's no part to hold this module!</span>")

	else
		return ..(W, user, params)
 