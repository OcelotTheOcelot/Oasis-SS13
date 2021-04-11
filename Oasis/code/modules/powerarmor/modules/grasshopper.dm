/obj/item/power_armor_module/grasshopper
	name = "AJM-22 \"Grasshopper\""
	desc = "A spring-loaded module attached to legs that allows the wearer to perform giant leaps."
	icon = 'Oasis/icons/powerarmor/modules/grasshopper.dmi'
	slot = MODULE_SLOT_BELT
	render_priority = POWER_ARMOR_LAYER_BELT_MODULE_FRONT
	var/hop_power_cost = 200  // How much power does the hopping consume

	// The following code is pretty much copied from jump boots
	var/jumpdistance = 5 // How many tiles forward the wearer lands afther the hop
	var/jumpspeed = 2 // The speed of the hop
	var/recharging_delay = 30 // Delay between each hop
	var/recharging_time = 0 // Time until next hop

/obj/item/power_armor_module/grasshopper/create_module_actions()
	. = ..()
	. += new /datum/action/innate/power_armor/module/grasshopper_hop
	return .

/* Hop
Makes the wearer leap in their current direction , if they have enough power in their exoskeleton for that.
*/
/obj/item/power_armor_module/grasshopper/proc/hop()
	var/obj/item/clothing/suit/armor/exoskeleton/E = part?.exoskeleton
	if(!istype(E))
		return
	var/mob/living/user = E.wearer
	if(!istype(user))
		return
	if(!both_legs_intact())
		to_chat(user, "<span class='warning'>\The [E]'s leg armor pieces are malfunctioning!</span>")
		return
	if(!(user.mobility_flags & MOBILITY_STAND))
		to_chat(user, "<span class='warning'>You should be standing to jump!</span>")
		return
	if(recharging_time > world.time)
		to_chat(user, "<span class='warning'>\The [src]'s spring mechanism is still reloading!</span>")
		return
	if(!E.drain_power(hop_power_cost))
		to_chat(user, "<span class='danger'>\The [E] has not enough power to load \the [src]!</span>")
		return

	var/atom/target = get_edge_target_turf(user, user.dir)
	user.weather_immunities += "lava"  // We need to do this at the beginning of the leap actually, so the user won't burn if they jumped from a tile adjacent to lava
	if(user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, .proc/hop_end, user)))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message("<span class='warning'>[usr] leaps forward using their [src]!</span>")
		recharging_time = world.time + recharging_delay
	else
		to_chat(user, "<span class='warning'>Something prevents you from leaping forward!</span>")
		user.weather_immunities -= "lava"

/obj/item/power_armor_module/grasshopper/proc/hop_end(mob/living/user)
	if(istype(user))
		user.weather_immunities -= "lava"

/datum/action/innate/power_armor/module/grasshopper_hop
	name = "Hop"
	desc = "Use the AJM-22 module to take jump over four steps forward. Chasms and lava are no longer a problem!"
	icon_icon = 'Oasis/icons/powerarmor/modules/grasshopper.dmi'
	button_icon_state = "hop_action"

/datum/action/innate/power_armor/module/grasshopper_hop/Activate()
	var/obj/item/power_armor_module/grasshopper/M = module
	if(istype(M))
		M.hop()