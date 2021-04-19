// Mostly recovers /datum/component/armor_plate

/datum/component/praetor_armor_plate
	var/amount = 0
	var/maxamount = 2
	var/upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide
	var/armor_points = 10
	var/upgrade_name

/datum/component/praetor_armor_plate/Initialize(max_amount, obj/item/upgrade_item, armor_points)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/applyplate)
	RegisterSignal(parent, COMSIG_POWER_ARMOR_PART_APPLY_ITEM, .proc/applyplate)

	if(max_amount)
		src.maxamount = max_amount
	if(upgrade_item)
		src.upgrade_item = upgrade_item
	if(armor_points)
		src.armor_points = armor_points

	var/obj/item/typecast = upgrade_item
	upgrade_name = initial(typecast.name)

/datum/component/praetor_armor_plate/proc/examine(datum/source, mob/user, list/examine_list)
	if(amount)
		examine_list += "<span class='notice'>It has been strengthened with [amount]/[maxamount] [upgrade_item].</span>"
	else
		examine_list += "<span class='notice'>It can be strengthened with up to [maxamount] [upgrade_item].</span>"

/datum/component/praetor_armor_plate/proc/applyplate(datum/source, obj/item/I, mob/user, params)
	if(!istype(I,upgrade_item))
		return
	var/obj/item/power_armor_part/P = parent
	if(!istype(P))
		return
	if(amount >= maxamount)
		to_chat(user, "<span class='warning'>You can't improve [parent] any further!</span>")
		return

	if(istype(I,/obj/item/stack))
		I.use(1)
	else
		if(length(I.contents))
			to_chat(user, "<span class='warning'>[I] cannot be used for armoring while there's something inside!</span>")
			return
		qdel(I)
	to_chat(user, "<span class='info'>You strengthen [P], improving its armour to sustain more damage.</span>")
	amount++
	P.max_integrity += armor_points
	P.armor_points += armor_points
	P.repair(armor_points)
