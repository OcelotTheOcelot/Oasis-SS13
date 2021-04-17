/obj/item/clothing/head/helmet/power_armor
	name = "power armor helmet"
	desc = "A helmet that can be worn only with exoskeleton."
	max_integrity = 80

	var/tier = POWER_ARMOR_GRADE_BASIC  // The tier of the helmet, needed for balance
	var/armor_set  // String describing what armor set this helmet belongs to; needed only to activate set bonuses
	var/armor_points = 60  // How much damage points the part absorbs until it's broken
	var/module_slots = MODULE_SLOT_HELMET  // Flag specifiying what module slots does this helmet have

/obj/item/clothing/head/helmet/power_armor/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M

	// Yes, hulks can equip basic helmets, viva le powergaming
	if(tier == POWER_ARMOR_GRADE_BASIC && H.dna && H.dna.check_mutation(HULK))
		return TRUE

	var/obj/item/clothing/suit/armor/exoskeleton/E = H.wear_suit
	if(!istype(E))
		if(!disable_warning)
			to_chat(M, "<span class='warning'>It's unsafe for your neck to wear this helmet without any additional support!</span>")
		return FALSE
	if(E.tier < tier)
		if(!disable_warning)
			to_chat(M, "<span class='warning'>This helmet is too advanced to synchronize with \the [E]!</span>")
		return FALSE
	return TRUE
