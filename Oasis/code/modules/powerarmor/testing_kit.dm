// If I haven't removed it at the moment of the release, shame on me.

/*
	ХОХОЛ И ДЕД
	ИСПОЛЬЗУЙТЕ ЭТУ ХУЙНЮ ДЛЯ ТЕСТОВ
	ГЛАВНОЕ НЕ ЗАБЫТЬ УДАЛИТЬ ПЕРЕД РЕЛИЗОМ
*/

/obj/power_armor_testing_kit/Initialize()
	new /obj/item/screwdriver(loc)
	new /obj/item/wrench(loc)

	new /obj/item/clothing/suit/armor/exoskeleton(loc)
	new /obj/item/clothing/suit/armor/exoskeleton/advanced(loc)
	new /obj/item/clothing/suit/armor/exoskeleton/military(loc)

	new /obj/item/power_armor_module/plasma_cutter(loc)

	new /obj/item/power_armor_part/l_arm/cherub(loc)

	QDEL_NULL(src)