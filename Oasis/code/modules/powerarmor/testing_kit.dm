// If I haven't removed it at the moment of the release, shame on me.

/obj/power_armor_testing_kit/Initialize()
	new /obj/item/screwdriver(loc)
	new /obj/item/wrench(loc)

	// new /obj/item/stock_parts/cell/high/plus(loc)
	// new /obj/item/stock_parts/cell/high/empty(loc)
	new /obj/item/stack/sheet/iron/fifty(loc)

	new /obj/power_armor_assembled/p5000pwl(loc)
	new /obj/power_armor_assembled/praetor(loc)
	new /obj/power_armor_assembled/mk2apa(loc)
	new /obj/power_armor_assembled/cherub(loc)
	new /obj/power_armor_assembled/samovar(loc)
	new /obj/power_armor_assembled/pangolin(loc)

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
	
	new /obj/item/power_armor_module/rcd(loc)
	// new /obj/item/power_armor_module/forcefield(loc)

	QDEL_NULL(src)