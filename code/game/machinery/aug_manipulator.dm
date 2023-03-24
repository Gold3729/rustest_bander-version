/obj/machinery/aug_manipulator
	name = "аугментационный манипулятор"
	desc = "Машина для индивидуальной подгонки аугментаций со встроенным аэрозольным красителем."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	circuit = /obj/item/circuitboard/machine/aug_manipulator
	density = TRUE
	obj_integrity = 200
	max_integrity = 200
	var/obj/item/bodypart/storedpart
	var/initial_icon_state
	var/static/list/style_list_icons = list("standard" = 'icons/mob/augmentation/augments.dmi', "engineer" = 'icons/mob/augmentation/augments_engineer.dmi', "security" = 'icons/mob/augmentation/augments_security.dmi', "mining" = 'icons/mob/augmentation/augments_mining.dmi')
	var/static/list/type_whitelist = list(/obj/item/bodypart/head/robot, /obj/item/bodypart/r_arm/robot, /obj/item/bodypart/l_arm/robot, /obj/item/bodypart/chest/robot, /obj/item/bodypart/r_leg/robot, /obj/item/bodypart/l_leg/robot)

/obj/machinery/aug_manipulator/examine(mob/user)
	. = ..()
	if(storedpart)
		. += "<hr><span class='notice'>Alt-клик для вытаскивания части тела.</span>"

/obj/machinery/aug_manipulator/Initialize()
	initial_icon_state = initial(icon_state)
	return ..()

/obj/machinery/aug_manipulator/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[initial_icon_state]-broken"
		return

	if(powered())
		icon_state = initial_icon_state
	else
		icon_state = "[initial_icon_state]-off"

/obj/machinery/aug_manipulator/update_overlays()
	. = ..()
	if(storedpart)
		. += "[initial_icon_state]-closed"

/obj/machinery/aug_manipulator/Destroy()
	QDEL_NULL(storedpart)
	return ..()

/obj/machinery/aug_manipulator/on_deconstruction()
	if(storedpart)
		storedpart.forceMove(loc)
		storedpart = null

/obj/machinery/aug_manipulator/contents_explosion(severity, target)
	if(storedpart)
		storedpart.ex_act(severity, target)

/obj/machinery/aug_manipulator/handle_atom_del(atom/A)
	if(A == storedpart)
		storedpart = null
		update_icon()

/obj/machinery/aug_manipulator/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "pdapainter-broken", "pdapainter", O)) //placeholder, get a sprite monkey to make an actual sprite, I can't be asked.
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(default_unfasten_wrench(user, O))
		power_change()
		return TRUE
	else if(istype(O, /obj/item/bodypart))
		var/obj/item/bodypart/B = O
		if(IS_ORGANIC_LIMB(B))
			to_chat(user, "<span class='warning'>Машина принимает только кибернетические части тела!</span>")
			return
		if(!(O.type in type_whitelist)) //Kepori won't break my system damn it
			to_chat(user, "<span class='warning'>Этот тип протеза не поддерживается!</span>")
			return
		if(storedpart)
			to_chat(user, "<span class='warning'>Внутри что-то есть!</span>")
			return
		else
			O = user.get_active_held_item()
			if(!user.transferItemToLoc(O, src))
				return
			storedpart = O
			O.add_fingerprint(user)
			update_icon()

	else if(O.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(obj_integrity < max_integrity)
			if(!O.tool_start_check(user, amount=0))
				return

			user.visible_message("<span class='notice'>[user] чинит [src].</span>", \
				"<span class='notice'>Чиню [src]...</span>", \
				"<span class='hear'>Слышу сварку.</span>")

			if(O.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>Успешно восстанавливаю [src].</span>")
				set_machine_stat(machine_stat & ~BROKEN)
				obj_integrity = max(obj_integrity, max_integrity)
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] уже в рабочем состоянии.</span>")
	else
		return ..()

/obj/machinery/aug_manipulator/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)

	if(storedpart)
		var/augstyle = input(user, "Выберите стиль", "Кастомизация конечностей") as null|anything in style_list_icons
		if(!augstyle)
			return
		if(!in_range(src, user))
			return
		if(!storedpart)
			return
		storedpart.static_icon = style_list_icons[augstyle]
		storedpart.should_draw_greyscale = FALSE //Premptive fuck you to greyscale IPCs trying to break something
		storedpart.update_icon_dropped()
		eject_part(user)

	else
		to_chat(user, "<span class='warning'>[src] пуст!</span>")

/obj/machinery/aug_manipulator/proc/eject_part(mob/living/user)
	if(storedpart)
		storedpart.forceMove(get_turf(src))
		storedpart = null
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src] пуст!</span>")

/obj/machinery/aug_manipulator/AltClick(mob/living/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	else
		eject_part(user)
