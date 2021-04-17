// If I haven't removed it at the moment of the release, shame on me.

/obj/power_armor_testing_kit/Initialize()
	new /obj/item/screwdriver(loc)
	new /obj/item/wrench(loc)
	new /obj/item/stock_parts/cell/high/plus(loc)
	// new /obj/item/stock_parts/cell/high/empty(loc)

	// new /obj/item/clothing/suit/armor/exoskeleton(loc)

	/*
	new /obj/item/power_armor_part/l_arm/p5000pwl(loc)
	new /obj/item/power_armor_part/r_arm/p5000pwl(loc)
	new /obj/item/power_armor_part/torso/p5000pwl(loc)
	new /obj/item/power_armor_part/l_leg/p5000pwl(loc)
	new /obj/item/power_armor_part/r_leg/p5000pwl(loc)
	*/

	// new /obj/item/clothing/suit/armor/exoskeleton/advanced(loc)

	new /obj/item/clothing/suit/armor/exoskeleton/military(loc)

	new /obj/item/power_armor_part/l_arm/cherub(loc)
	new /obj/item/power_armor_part/r_arm/cherub(loc)
	new /obj/item/power_armor_part/torso/cherub(loc)
	new /obj/item/power_armor_part/l_leg/cherub(loc)
	new /obj/item/power_armor_part/r_leg/cherub(loc)

	new /obj/item/power_armor_module/hydraulic_clamp(loc)
	// new /obj/item/power_armor_module/magnetic_clamp(loc)
	// new /obj/item/power_armor_module/plasma_cutter(loc)  // <DONE>
	// new /obj/item/power_armor_module/grasshopper(loc)  // <DONE>
	// new /obj/item/power_armor_module/mining_drill(loc)  // <DONE>
	// new /obj/item/power_armor_module/plasma_generator(loc)  // <DONE>
	// new /obj/item/power_armor_module/self_destruction(loc)  // <DONE>
	// new /obj/item/power_armor_module/stimpack(loc)  // <DONE>
	// new /obj/item/power_armor_module/mandible(loc)  // <DONE>
	// new /obj/item/power_armor_module/auto_repair_kit(loc)  // <DONE>
	new /obj/item/power_armor_module/mega_blaster(loc)  // <TODO> We should implement beamrifles' charging
	// new /obj/item/power_armor_module/defibrillator(loc)  // <DONE>

	QDEL_NULL(src)