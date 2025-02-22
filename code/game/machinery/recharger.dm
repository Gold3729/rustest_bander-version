/obj/machinery/recharger
	name = "зарядник"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger"
	desc = "Имеет специальный порт для зарядки оружия работающего на энергии."
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 250
	circuit = /obj/item/circuitboard/machine/recharger
	pass_flags = PASSTABLE
	var/obj/item/charging = null
	var/recharge_coeff = 1
	var/using_power = FALSE //Did we put power into "charging" last process()?

	var/static/list/allowed_devices = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/melee/baton,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/modular_computer,
		/obj/item/gun/ballistic/automatic/powered,
		))

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += "<hr><span class='warning'>Слишком далеко что-бы увидеть дисплей [src]!</span>"
		return

	if(charging)
		. += {"<span class='notice'>Внутри [src] видно:</span>
		<span class='notice'>- [charging].</span>"}

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "<hr><span class='notice'>Дисплей показывает:</span>"
		. += "<hr><span class='notice'>- Оружие заряждается <b>[recharge_coeff*10]%</b> каждый цикл.</span>"
		if(charging)
			var/obj/item/stock_parts/cell/C = charging.get_cell()
			. += "<hr><span class='notice'>- Заряд батареи [charging] составляет <b>[C.percent()]%</b>.</span>"


/obj/machinery/recharger/proc/setCharging(new_charging)
	charging = new_charging
	if (new_charging)
		START_PROCESSING(SSmachines, src)
		use_power = ACTIVE_POWER_USE
		using_power = TRUE
		update_icon()
	else
		use_power = IDLE_POWER_USE
		using_power = FALSE
		update_icon()

/obj/machinery/recharger/attackby(obj/item/G, mob/user, params)
	if(G.tool_behaviour == TOOL_WRENCH)
		if(charging)
			balloon_alert(user, "Внутри есть что-то!")
			return
		set_anchored(!anchored)
		power_change()
		balloon_alert(user, "[anchored ? "Прикручиваю" : "Откручиваю"] [src].")
		G.play_tool_sound(src)
		return

	var/allowed = is_type_in_typecache(G, allowed_devices)

	if(allowed)
		if(anchored)
			if(charging || panel_open)
				return TRUE

			//Checks to make sure he's not in space doing it, and that the area got proper power.
			var/area/a = get_area(src)
			if(!isarea(a) || a.power_equip == 0)
				to_chat(user, "<span class='notice'>[src] мигает красным при попытке вставить [G].</span>")
				return TRUE

			if (istype(G, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = G
				if(!E.can_charge)
					to_chat(user, "<span class='notice'>У данного оружия нет порта для зарядки оружия.</span>")
					return TRUE

			if(!user.transferItemToLoc(G, src))
				return TRUE
			setCharging(G)

		else
			to_chat(user, "<span class='notice'>[src] не подключён!</span>")
		return TRUE

	if(anchored && !charging)
		if(default_deconstruction_screwdriver(user, "recharger-open", "recharger", G))
			return

		if(panel_open && G.tool_behaviour == TOOL_CROWBAR)
			default_deconstruction_crowbar(G)
			return

	return ..()

/obj/machinery/recharger/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	add_fingerprint(user)
	if(charging)
		charging.update_icon()
		charging.forceMove(drop_location())
		user.put_in_hands(charging)
		setCharging(null)

/obj/machinery/recharger/attack_tk(mob/user)
	if(charging)
		charging.update_icon()
		charging.forceMove(drop_location())
		setCharging(null)

/obj/machinery/recharger/process()
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return PROCESS_KILL

	using_power = FALSE
	if(charging)
		var/obj/item/stock_parts/cell/C = charging.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(C.chargerate * recharge_coeff)
				use_power(250 * recharge_coeff)
				using_power = TRUE
			update_icon()

		if(istype(charging, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = charging
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)
				use_power(200 * recharge_coeff)
				using_power = TRUE
			update_icon()
			return
	else
		return PROCESS_KILL

/obj/machinery/recharger/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_CONTENTS)
		return
	if(!(machine_stat & (NOPOWER|BROKEN)) && anchored)
		if(istype(charging,  /obj/item/gun/energy))
			var/obj/item/gun/energy/E = charging
			if(E.cell)
				E.cell.emp_act(severity)

		else if(istype(charging, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = charging
			if(B.cell)
				B.cell.charge = 0

/obj/machinery/recharger/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	luminosity = 0
	if(machine_stat & (NOPOWER|BROKEN) || !anchored || panel_open)
		return

	luminosity = 1
	if (charging)
		if(using_power)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-charging", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-charging", EMISSIVE_LAYER, EMISSIVE_PLANE, dir, alpha)
		else
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-full", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-full", EMISSIVE_LAYER, EMISSIVE_PLANE, dir, alpha)
	else
		SSvis_overlays.add_vis_overlay(src, icon, "recharger-empty", layer, plane, dir, alpha)
		SSvis_overlays.add_vis_overlay(src, icon, "recharger-empty", EMISSIVE_LAYER, EMISSIVE_PLANE, dir, alpha)
