/obj/item/power_armor_module/forcefield
	name = "forcefield module"
	desc = "A device that establishes unpenetratable forcefield around the wearer. The forcefield may be overloaded by taking enough damage. Can only recharge when not under fire."
	icon = 'Oasis/icons/powerarmor/modules/forcefield.dmi'
	slot = MODULE_SLOT_CHESTPLATE
	render_priority = POWER_ARMOR_LAYER_CHEST_MODULE_FRONT
	tier = POWER_ARMOR_GRADE_MILITARY

	// var/defibrillation_cost = 1000  // How much does a charge cost
	var/power_consumption = 10  // How much power does the module consume per tick when active
	var/charge_delay = 30  // How much time is needed to recharge the forcefield
	var/forcefield_active = FALSE  // If the forcefield is active

	var/forcefield_state = "shield"  // The icon state of the forcefield 

/obj/item/power_armor_module/forcefield/emp_reaction()
	destroy_forcefield()

/* Charge
Attempts to estabishes the forcefield.
*/
/obj/item/power_armor_module/forcefield/proc/charge()
	if(charging)
		return
	if(world.time < last_charge + cooldown)
		state("Operaion failed: system is not ready yet.")
		return
	if(!part?.exoskeleton?.drain_power(defibrillation_cost))
		state("Operaion failed: not enough power.")
		futile = TRUE
		return
	playsound(src, 'sound/machines/defib_charge.ogg', 100, FALSE)
	charging = TRUE
	addtimer(CALLBACK(src, .proc/defibrillate, part?.exoskeleton?.wearer), charge_delay, TIMER_UNIQUE)

/* Create force field
Creates forcefield around the wearer.
*/
/obj/item/power_armor_module/forcefield/proc/create_forcefield()
	forcefield_active = TRUE
	// <TODO> le epic BZZZZZZT sound here
	START_PROCESSING(SSobj, src)
	return

/* Destroy force field
Destroys the forcefield around the wearer.
*/
/obj/item/power_armor_module/forcefield/proc/destroy_forcefield()
	forcefield_active = FALSE
	// <TODO> sad discharge sound here
	return

/obj/item/power_armor_module/forcefield/on_wearer_entered()
	charge()
	..()

/obj/item/power_armor_module/forcefield/on_wearer_left()
	..()
	destroy_forcefield()
	STOP_PROCESSING(SSobj, src)

// Alas, but this should track the wearer's health all the time.
/obj/item/power_armor_module/forcefield/process()
	if(part?.exoskeleton?.drain_power(power_consumption))
		destroy_forcefield()
		return PROCESS_KILL
