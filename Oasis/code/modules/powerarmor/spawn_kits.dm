/obj/power_armor_assembled
	var/exoskeleton_type = /obj/item/clothing/suit/armor/exoskeleton
	var/cell_type = /obj/item/stock_parts/cell/high
	var/list/part_types = new
	var/helmet_type

/obj/power_armor_assembled/Initialize()
	var/obj/item/clothing/suit/armor/exoskeleton/exoskeleton
	if(exoskeleton_type)
		exoskeleton = new exoskeleton_type(loc)
		if(cell_type)
			var/obj/item/stock_parts/cell/cell = new cell_type(loc)
			cell.forceMove(exoskeleton)
			exoskeleton.cell = cell
		exoskeleton.panel_opened = FALSE
	for(var/PT in part_types)
		var/obj/item/power_armor_part/part = new PT(loc)
		exoskeleton?.attach_part(part)
	if(helmet_type)
		new helmet_type(loc)
	QDEL_NULL(src)

// p5000pwl
/obj/power_armor_assembled/p5000pwl
	part_types = list(
		/obj/item/power_armor_part/l_arm/p5000pwl,
		/obj/item/power_armor_part/r_arm/p5000pwl,
		/obj/item/power_armor_part/torso/p5000pwl,
		/obj/item/power_armor_part/l_leg/p5000pwl,
		/obj/item/power_armor_part/r_leg/p5000pwl
	)

// pcs
/obj/power_armor_assembled/pcs
	part_types = list(
		/obj/item/power_armor_part/l_arm/pcs,
		/obj/item/power_armor_part/r_arm/pcs,
		/obj/item/power_armor_part/torso/pcs,
		/obj/item/power_armor_part/l_leg/pcs,
		/obj/item/power_armor_part/r_leg/pcs
	)
	helmet_type = /obj/item/clothing/head/helmet/power_armor/pcs

// praetor
/obj/power_armor_assembled/praetor
	part_types = list(
		/obj/item/power_armor_part/l_arm/praetor,
		/obj/item/power_armor_part/r_arm/praetor,
		/obj/item/power_armor_part/torso/praetor,
		/obj/item/power_armor_part/l_leg/praetor,
		/obj/item/power_armor_part/r_leg/praetor
	)
	helmet_type = /obj/item/clothing/head/helmet/power_armor/praetor

// mk2apa
/obj/power_armor_assembled/mk2apa
	exoskeleton_type = /obj/item/clothing/suit/armor/exoskeleton/military
	part_types = list(
		/obj/item/power_armor_part/l_arm/mk2apa,
		/obj/item/power_armor_part/r_arm/mk2apa,
		/obj/item/power_armor_part/torso/mk2apa,
		/obj/item/power_armor_part/l_leg/mk2apa,
		/obj/item/power_armor_part/r_leg/mk2apa
	)
	// helmet_type = /obj/item/clothing/head/helmet/power_armor/mk2apa

// cherub
/obj/power_armor_assembled/cherub
	exoskeleton_type = /obj/item/clothing/suit/armor/exoskeleton/military
	part_types = list(
		/obj/item/power_armor_part/l_arm/cherub,
		/obj/item/power_armor_part/r_arm/cherub,
		/obj/item/power_armor_part/torso/cherub,
		/obj/item/power_armor_part/l_leg/cherub,
		/obj/item/power_armor_part/r_leg/cherub
	)
	helmet_type = /obj/item/clothing/head/helmet/power_armor/cherub

// samovar
/obj/power_armor_assembled/samovar
	exoskeleton_type = /obj/item/clothing/suit/armor/exoskeleton/military
	part_types = list(
		/obj/item/power_armor_part/l_arm/samovar,
		/obj/item/power_armor_part/r_arm/samovar,
		/obj/item/power_armor_part/torso/samovar,
		/obj/item/power_armor_part/l_leg/samovar,
		/obj/item/power_armor_part/r_leg/samovar
	)
	// helmet_type = /obj/item/clothing/head/helmet/power_armor/samovar

// pangolin
/obj/power_armor_assembled/pangolin
	exoskeleton_type = /obj/item/clothing/suit/armor/exoskeleton/military
	part_types = list(
		/obj/item/power_armor_part/l_arm/pangolin,
		/obj/item/power_armor_part/r_arm/pangolin,
		/obj/item/power_armor_part/torso/pangolin,
		/obj/item/power_armor_part/l_leg/pangolin,
		/obj/item/power_armor_part/r_leg/pangolin
	)
	// helmet_type = /obj/item/clothing/head/helmet/power_armor/pangolin
