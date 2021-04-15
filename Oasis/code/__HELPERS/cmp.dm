/* Compare power armor overlay render order
A comparator proc needed to sort parts' and modules' overlays in a proper render order
*/
/proc/cmp_power_armor_overlays_render_order(datum/power_armor_overlay/A, datum/power_armor_overlay/B)
	return A.priority - B.priority

/* Compare power armor parts integrity
A comparator proc needed to sort parts by their integrity
*/
/proc/cmp_power_armor_parts_integrity(obj/item/power_armor_part/A, obj/item/power_armor_part/B)
	return A.get_armor_points_percent() - B.get_armor_points_percent()
