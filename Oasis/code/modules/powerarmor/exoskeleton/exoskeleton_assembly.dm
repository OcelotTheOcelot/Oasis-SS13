/obj/item/exoskeleton_assembly
	name = "exoskeleton assembly"
	desc = "A complex system of servo-motors designed to support its wearer. \
	Its fastenings are <b>unwrenched</b> so it can be packed compactly for quick trasportation."
	icon = 'Oasis/icons/powerarmor/exoskeleton/exoskeleton_basic.dmi'
	icon_state = "item"
	w_class = WEIGHT_CLASS_BULKY
	
	var/assemble_speed = 50  // How much time it takes to assemble the exoskeleton
	var/exoskeleton_type = /obj/item/clothing/suit/armor/exoskeleton

/obj/item/exoskeleton_assembly/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>You begin assembling \the [src]...</span>")
		W.play_tool_sound(src)
		if(do_after(user, assemble_speed, target = src))
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			var/obj/item/clothing/suit/armor/exoskeleton/E = new exoskeleton_type(get_turf(src))
			E.obj_integrity = obj_integrity
			E.loc = loc
			QDEL_NULL(src)
	else
		return ..(W, user, params)
