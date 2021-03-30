/datum/action/innate/power_armor
	name = "Exoskeleton or power armor action"
	icon_icon = 'Oasis/icons/powerarmor/exoskeleton_actions.dmi'
	// action_background_icon_state = "bg_tech_blue_on"  // <TODO>

	var/obj/item/clothing/suit/armor/exoskeleton/exoskeleton  // The exoskeleton this action is bound to
	var/power_consumption = 0  // How much power does this action consume per use

/datum/action/innate/power_armor/Activate()
	if(!exoskeleton)
		return FALSE
	if((exoskeleton.cell && exoskeleton.cell.charge > power_consumption))
		if(owner)
			to_chat(owner, "<span class='warning'>Error: not enough power!</span>")
			return FALSE
	exoskeleton.cell.use(power_consumption)
	exoskeleton.cell.update_icon()
	return TRUE

// The action an exoskeleton wearer uses to dequip it
/datum/action/innate/power_armor/exoskeleton_eject
	name = "Eject"
	desc = "Unlocks the exoskeleton allowing the wearer to leave it"
	button_icon_state = "eject"

/datum/action/innate/power_armor/exoskeleton_eject/Activate()
	exoskeleton.eject(owner)

// Actions used by modules
/datum/action/innate/power_armor/module
	name = "Module action"
	var/obj/item/power_armor_module/module  // The module this action is bound to

// Actions used by modules to toggle their tools
/datum/action/innate/power_armor/module/deploy_tool
	name = "Toggle tools"

/datum/action/innate/power_armor/module/deploy_tool/Activate()
	if(module.hand_occupied)
		module.occupy_hand()
	else
		module.free_hand()
