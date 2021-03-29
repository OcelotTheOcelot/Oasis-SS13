
/* CMP parts render order
A comparator proc needed to sort parts in a proper render order
*/
/proc/cmp_parts_render_order(obj/item/power_armor_part/A, obj/item/power_armor_part/B)
	return A.render_priority - B.render_priority
