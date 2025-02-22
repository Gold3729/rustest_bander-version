/obj/machinery/recharger/portable_recharger
	name = "Переносной Зарядный Комплекс"
	desc = "Металлический чемодан. Имеет специальный порт для зарядки оружия работающего на энергии. Из-за компактной конструкции не имеет доступа к внутренним компонентам"
	icon = 'lambda/ss7v/icons/obj/portable_recharger.dmi'
	icon_state = "portable_recharger"
	anchored = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	var/closed = TRUE
	var/obj/item/case_portable_recharger/portable_recharger

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating


/obj/machinery/recharger/portable_recharger/Initialize(mapload, portable_recharger)
	. = ..()
	if(!portable_recharger)
		return INITIALIZE_HINT_QDEL
	src.portable_recharger = portable_recharger
/**
Очень долго ебался, но вроде сделал
Возможно потребуется калибровка множителей
*/
/obj/machinery/recharger/portable_recharger/process()
	using_power = FALSE

	if(!portable_recharger.incell)
		return PROCESS_KILL

	if(portable_recharger.incell.charge < 200 * recharge_coeff)
		return PROCESS_KILL

	if(charging)
		var/obj/item/stock_parts/cell/C = charging.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(C.chargerate * recharge_coeff)
				portable_recharger.incell.use(250 * recharge_coeff)
				using_power = TRUE
			update_icon()

		if(istype(charging, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = charging
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)
				portable_recharger.incell.use(200 * recharge_coeff)
				using_power = TRUE
			update_icon()
	else
		return PROCESS_KILL


/**
Возможно требуется доработка
Узнаю после тестмерджа
 */


/obj/machinery/recharger/portable_recharger/attackby(obj/item/G, mob/user, params)
	if(G.tool_behaviour == TOOL_WRENCH)
		return
	if(G.tool_behaviour == TOOL_SCREWDRIVER)
		return
	var/allowed = is_type_in_typecache(G, allowed_devices)

	if(allowed)
		if(charging)
			to_chat(user, "<span class='warning'>В [src] только один порт зарядки.</span>")
			return TRUE
		if (istype(G, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = G
			if(!E.can_charge)
				to_chat(user, "<span class='notice'>У данного оружия нет порта для зарядки оружия.</span>")
				return TRUE

		if(!user.transferItemToLoc(G, src))
			return TRUE
		setCharging(G)

		return TRUE

/obj/machinery/recharger/portable_recharger/Destroy()
	QDEL_NULL(portable_recharger)
	end_processing()
	return ..()

//складывание
/obj/machinery/recharger/portable_recharger/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr)
		if(!portable_recharger || !usr.can_hold_items())
			return
		if(!usr.canUseTopic(src, BE_CLOSE, ismonkey(usr)))
			return
		if(charging)
			usr.visible_message(self_message = "<span class='notice'>Ещё заряжает [charging]...</span>")
			return
		usr.visible_message("<span class='notice'>[usr] начинает закрывать [src]...</span>", "<span class='notice'>Закрываю [src]...</span>")
		if(do_after(usr, 5, target = usr))
			end_processing()
			usr.put_in_hands(portable_recharger)
			moveToNullspace()
			closed = TRUE

//Картиночки
/obj/machinery/recharger/portable_recharger/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	luminosity = 1
	if (charging)

		if(portable_recharger.incell.charge < 200 * recharge_coeff)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-fail", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-fail", EMISSIVE_LAYER, EMISSIVE_PLANE, dir, alpha)
		else if(using_power)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-charging", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-charging", EMISSIVE_LAYER, EMISSIVE_PLANE, dir, alpha)
		else
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-full", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-full", EMISSIVE_LAYER, EMISSIVE_PLANE, dir, alpha)
	else
		SSvis_overlays.add_vis_overlay(src, icon, "recharger-empty", layer, plane, dir, alpha)
		SSvis_overlays.add_vis_overlay(src, icon, "recharger-empty", EMISSIVE_LAYER, EMISSIVE_PLANE, dir, alpha)


//кейс с зарядником
/obj/item/case_portable_recharger
	name = "Кейс П.З.К"
	desc = "Металлический кейс с маленькой надписью \"Переносной Зарядный Комплекс.\"."
	icon = 'lambda/ss7v/icons/obj/portable_recharger.dmi'
	icon_state = "case_portable_recharger"
	lefthand_file = 'lambda/ss7v/icons/obj/lefthand.dmi'
	righthand_file = 'lambda/ss7v/icons/obj/righthand.dmi'
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("бьёт", "забивает", "избивает", "ударяет")
	resistance_flags = FLAMMABLE
	var/obj/machinery/recharger/portable_recharger/link
	var/obj/item/stock_parts/cell/incell = null

/obj/item/case_portable_recharger/examine(mob/user)
	. = ..()
	. += "<hr><span class='notice'>Внутри [incell ? "есть [incell]" : "остутствует аккумулятор"]!</span>"
	if(incell)
		. += "<hr><span class='notice'>[incell] заряжен на [incell.percent()]!</span>"

//Типа линковка
/obj/item/case_portable_recharger/Initialize()
	link = new(null, src)
	. = ..()

/obj/item/case_portable_recharger/Destroy()
	if(!QDELETED(link))
		QDEL_NULL(link)
	return ..()

//Раскладывание
/obj/item/case_portable_recharger/attack_self(mob/user)
	if(!isturf(user.loc))
		return
	add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] начинает ставить [link]...</span>", "<span class='notice'>Начинаю ставить [link]...</span>")
	if(do_after(user, 5, target = user))
		link.forceMove(get_turf(src))
		link.closed = FALSE
		user.transferItemToLoc(src, link, TRUE)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_HIDE_ALL)

/obj/item/case_portable_recharger/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(istype(W, /obj/item/stock_parts/cell))
		if(incell)
			to_chat(user, "<span class='warning'>[src] нет места для второго [W]!</span>")
		if(!incell)
			incell = W
			user.transferItemToLoc(W, src)
			update_icon()
			to_chat(user, "<span class='notice'>Вставляю [incell] в [src].</span>")
	else
		return

/obj/item/case_portable_recharger/AltClick(mob/user)
	. = ..()
	if(incell)
		user.put_in_hands(incell)
		incell = null
		incell.update_icon()
		to_chat(user, "<span class='notice'>Вытаскиваю [incell] из [src].</span>")
	else
		to_chat(user, "<span class='notice'>Внутри ничего нет.</span>")
