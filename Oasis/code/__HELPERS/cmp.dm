
/* Compare power armor overlay render order
A comparator proc needed to sort parts' and modules' overlays in a proper render order
*/
/proc/cmp_power_armor_overlays_render_order(datum/power_armor_overlay/A, datum/power_armor_overlay/B)
	return A.priority - B.priority
