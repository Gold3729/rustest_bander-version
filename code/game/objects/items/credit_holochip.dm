/obj/item/holochip
	name = "голочип"
	desc = "Полупрозрачный чип состоящий из чистого света. Это современная замена физическим деньгам, которые могут быть напрямую конвертированы в виртуальную валюту и наоборот. Держите подальше от магнитов."
	icon = 'icons/obj/economy.dmi'
	icon_state = "holochip"
	throwforce = 0
	force = 0
	w_class = WEIGHT_CLASS_TINY
	var/credits = 0

/obj/item/holochip/Initialize(mapload, amount)
	. = ..()
	credits = amount
	update_icon()

/obj/item/holochip/examine(mob/user)
	. = ..()
	. += "<hr><span class='notice'>По минидисплею можно понять что тут записано [credits] кредит[get_num_string(credits)]</span>\n"+\
	"<span class='notice'>Альт-клик для разделения.</span>"

/obj/item/holochip/get_item_credit_value()
	return credits

/obj/item/holochip/update_icon()
	name = "голочип - [credits] кредит[get_num_string(credits)]"
	var/rounded_credits = credits
	switch(credits)
		if(1 to 999)
			icon_state = "holochip"
		if(1000 to 999999)
			icon_state = "holochip_kilo"
			rounded_credits = round(rounded_credits * 0.001)
		if(1000000 to 999999999)
			icon_state = "holochip_mega"
			rounded_credits = round(rounded_credits * 0.000001)
		if(1000000000 to INFINITY)
			icon_state = "holochip_giga"
			rounded_credits = round(rounded_credits * 0.000000001)
	var/overlay_color = "#914792"
	switch(rounded_credits)
		if(0 to 4)
			overlay_color = "#8E2E38"
		if(5 to 9)
			overlay_color = "#914792"
		if(10 to 19)
			overlay_color = "#BF5E0A"
		if(20 to 49)
			overlay_color = "#358F34"
		if(50 to 99)
			overlay_color = "#676767"
		if(100 to 199)
			overlay_color = "#009D9B"
		if(200 to 499)
			overlay_color = "#0153C1"
		if(500 to INFINITY)
			overlay_color = "#2C2C2C"
	cut_overlays()
	var/mutable_appearance/holochip_overlay = mutable_appearance('icons/obj/economy.dmi', "[icon_state]-color")
	holochip_overlay.color = overlay_color
	add_overlay(holochip_overlay)

/obj/item/holochip/proc/spend(amount, pay_anyway = FALSE)
	if(credits >= amount)
		credits -= amount
		if(credits == 0)
			qdel(src)
		update_icon()
		return amount
	else if(pay_anyway)
		qdel(src)
		return credits
	else
		return 0

/obj/item/holochip/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/holochip))
		var/obj/item/holochip/H = I
		credits += H.credits
		to_chat(user, "<span class='notice'>Вставляю деньги на голочипе в [src].</span>")
		update_icon()
		qdel(H)

/obj/item/holochip/AltClick(mob/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	var/split_amount = round(input(user,"На сколько разделяем?") as null|num)
	if(split_amount == null || split_amount <= 0 || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		var/new_credits = spend(split_amount, TRUE)
		var/obj/item/holochip/H = new(user ? user : drop_location(), new_credits)
		if(user)
			if(!user.put_in_hands(H))
				H.forceMove(user.drop_location())
			add_fingerprint(user)
		H.add_fingerprint(user)
		to_chat(user, "<span class='notice'>Отделяю [split_amount] кредит[get_num_string(split_amount)] от голочипа.</span>")

/obj/item/holochip/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/wipe_chance = 60 / severity
	if(prob(wipe_chance))
		visible_message("<span class='warning'>[src] начинает распадаться!</span>")
		qdel(src) //rip cash
