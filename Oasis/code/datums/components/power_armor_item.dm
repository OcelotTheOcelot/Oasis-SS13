/datum/component/power_armor_item
	var/obj/item/power_armor_module/module  // The module the item holding this component is bound to

/datum/component/power_armor_item/Initialize(obj/item/power_armor_module/M)
	if(!istype(M))
		return COMPONENT_INCOMPATIBLE
	module = M

/* Get cell
Helper proc needed to get the component's cell if its module is attached to an exoskeleton
Returns:
	the cell of the exoskeleton or null
*/
/datum/component/power_armor_item/proc/get_cell()
	return module && module.part && module.part.exoskeleton && module.part.exoskeleton.cell

/* Use cell
Uses the exoskeleton's cell.
Accepts:
	amount, the amount of power to use
Returns:
	the value returned by the exoskeleton's cell .use(amount) proc
*/
/datum/component/power_armor_item/proc/use_cell(amount)
	if(!module)
		QDEL_NULL(src)
		return FALSE
	var/obj/item/stock_parts/cell/C = get_cell()
	if(!istype(C))
		return FALSE
	return C.use(amount)
