/obj/item/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "red"
	var/open = FALSE
	var/lipstick_trait

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/jade
	//It's still called Jade, but theres no HTML color for jade, so we use lime.
	name = "jade lipstick"
	colour = "lime"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/random
	name = "lipstick"
	icon_state = "random_lipstick"

/obj/item/lipstick/black/death
	name = "\improper Kiss of Death"
	desc = "An incredibly potent tube of lipstick made from the venom of the dreaded Yellow Spotted Space Lizard, as deadly as it is chic. Try not to smear it!"
	lipstick_trait = TRAIT_KISS_OF_DEATH

/obj/item/lipstick/random/Initialize()
	. = ..()
	icon_state = "lipstick"
	colour = pick("red","purple","lime","black","green","blue","white")
	name = "[colour] lipstick"

/obj/item/lipstick/attack_self(mob/user)
	cut_overlays()
	to_chat(user, "<span class='notice'>You twist [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		var/mutable_appearance/colored_overlay = mutable_appearance(icon, "lipstick_uncap_color")
		colored_overlay.color = colour
		icon_state = "lipstick_uncap"
		add_overlay(colored_overlay)
	else
		icon_state = "lipstick"

/obj/item/lipstick/attack(mob/M, mob/user)
	if(!open || !ismob(M))
		return

	if(!ishuman(M))
		to_chat(user, span_warning("Where are the lips on that?"))
		return

	var/mob/living/carbon/human/target = M
	if(target.is_mouth_covered())
		to_chat(user, span_warning("Remove [ target == user ? "your" : "[target.p_their()]" ] mask!"))
		return
	if(target.lip_style) //if they already have lipstick on
		to_chat(user, span_warning("You need to wipe off the old lipstick first!"))
		return

	if(target == user)
		user.visible_message(span_notice("[user] does [user.p_their()] lips with [src]."), \
			span_notice("You take a moment to apply [src]. Perfect!"))
		target.update_lips("lipstick", colour, lipstick_trait)
		return

	user.visible_message(span_warning("[user] begins to do [target]'s lips with [src]."), \
		span_notice("You begin to apply [src] on [target]'s lips..."))
	if(!do_after(user, 2 SECONDS, target = target))
		return
	user.visible_message(span_notice("[user] does [target]'s lips with [src]."), \
		span_notice("You apply [src] on [target]'s lips."))
	target.update_lips("lipstick", colour, lipstick_trait)

//you can wipe off lipstick with paper!
/obj/item/paper/attack(mob/M, mob/user)
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || !ishuman(M))
		return ..()

	var/mob/living/carbon/human/target = M
	if(target == user)
		to_chat(user, span_notice("You wipe off the lipstick with [src]."))
		target.update_lips(null)
		return

	user.visible_message(span_warning("[user] begins to wipe [target]'s lipstick off with [src]."), \
		span_notice("You begin to wipe off [target]'s lipstick..."))
	if(!do_after(user, 10, target = target))
		return
	user.visible_message(span_notice("[user] wipes [target]'s lipstick off with [src]."), \
		span_notice("You wipe off [target]'s lipstick."))
	target.update_lips(null)

/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "razor"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY

/obj/item/razor/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins shaving [user.p_them()]self without the razor guard! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	shave(user, BODY_ZONE_PRECISE_MOUTH)
	shave(user, BODY_ZONE_HEAD)//doesnt need to be BODY_ZONE_HEAD specifically, but whatever
	return BRUTELOSS

/obj/item/razor/proc/shave(mob/living/carbon/human/H, location = BODY_ZONE_PRECISE_MOUTH)
	if(location == BODY_ZONE_PRECISE_MOUTH)
		H.facial_hairstyle = "Shaved"
	else
		H.hairstyle = "Skinhead"

	H.update_hair()
	playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)

/obj/item/razor/attack(mob/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/location = user.zone_selected
		if((location in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_HEAD)) && !H.get_bodypart(BODY_ZONE_HEAD))
			to_chat(user, "<span class='warning'>[H] doesn't have a head!</span>")
			return
		if(location == BODY_ZONE_PRECISE_MOUTH)
			if(user.a_intent == INTENT_HELP)
				if(H.gender == MALE)
					if (H == user)
						to_chat(user, "<span class='warning'>You need a mirror to properly style your own facial hair!</span>")
						return
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					var/new_style = input(user, "Select a facial hairstyle", "Grooming")  as null|anything in GLOB.facial_hairstyles_list
					if(!get_location_accessible(H, location))
						to_chat(user, "<span class='warning'>The mask is in the way!</span>")
						return
					user.visible_message("<span class='notice'>[user] tries to change [H]'s facial hairstyle using [src].</span>", "<span class='notice'>You try to change [H]'s facial hairstyle using [src].</span>")
					if(new_style && do_after(user, 60, target = H))
						user.visible_message("<span class='notice'>[user] successfully changes [H]'s facial hairstyle using [src].</span>", "<span class='notice'>You successfully change [H]'s facial hairstyle using [src].</span>")
						H.facial_hairstyle = new_style
						H.update_hair()
						return
				else
					return

			else
				if(!(FACEHAIR in H.dna.species.species_traits))
					to_chat(user, "<span class='warning'>There is no facial hair to shave!</span>")
					return
				if(!get_location_accessible(H, location))
					to_chat(user, "<span class='warning'>The mask is in the way!</span>")
					return
				if(H.facial_hairstyle == "Shaved")
					to_chat(user, "<span class='warning'>Already clean-shaven!</span>")
					return

				if(H == user) //shaving yourself
					user.visible_message(
						"<span class='notice'>[user] starts to shave [user.p_their()] facial hair with [src].</span>",
						"<span class='notice'>You take a moment to shave your facial hair with [src]...</span>")
					if(do_after(user, 50, target = H))
						user.visible_message(
							"<span class='notice'>[user] shaves [user.p_their()] facial hair clean with [src].</span>",
							"<span class='notice'>You finish shaving with [src]. Fast and clean!</span>")
						shave(H, location)
				else
					user.visible_message(
						"<span class='warning'>[user] tries to shave [H]'s facial hair with [src].</span>",
						"<span class='notice'>You start shaving [H]'s facial hair...</span>")
					if(do_after(user, 50, target = H))
						user.visible_message(
							"<span class='warning'>[user] shaves off [H]'s facial hair with [src].</span>",
							"<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						shave(H, location)

		else if(location == BODY_ZONE_HEAD)
			if("moth_fluff" in H.dna.species.mutant_bodyparts)
				if(user.a_intent == INTENT_HELP)
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					var/new_style = input(user, "Select a fluff style", "Grooming")  as null|anything in GLOB.moth_fluff_list
					if(!get_location_accessible(H, location))
						to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
						return
					user.visible_message("<span class='notice'>[user] tries to change [H]'s fluff style using [src].</span>", "<span class='notice'>You try to change [H]'s fluff style using [src].</span>")
					if(new_style && do_after(user, 60, target = H))
						user.visible_message("<span class='notice'>[user] successfully changes [H]'s fluff style using [src].</span>", "<span class='notice'>You successfully change [H]'s fluff style using [src].</span>")
						H.dna.features["moth_fluff"] = new_style
						H.update_body()
						return

				else
					if(!get_location_accessible(H, location))
						to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
						return
					if(H.dna.features["moth_fluff"] == "Shaved")
						to_chat(user, "<span class='warning'>There is not enough fluff left to shave!</span>")
						return

					if(H == user) //shaving yourself
						user.visible_message("<span class='notice'>[user] starts to shave [user.p_their()] fluff off with [src].</span>", \
											"<span class='notice'>You start to shave your fluff off with [src]...</span>")
						if(do_after(user, 5, target = H))
							user.visible_message("<span class='notice'>[user] shaves [user.p_their()] fluff off with [src].</span>", \
												"<span class='notice'>You finish shaving your fluff off with [src].</span>")
							H.dna.features["moth_fluff"] = "Shaved"
							H.update_body()
							playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)
					else
						var/turf/H_loc = H.loc
						user.visible_message("<span class='warning'>[user] tries to shave [H]'s fluff with [src]!</span>", \
											"<span class='notice'>You start shaving [H]'s fluff...</span>")
						if(do_after(user, 50, target = H))
							if(H_loc == H.loc)
								user.visible_message("<span class='warning'>[user] shaves [H]'s fluff off with [src]!</span>", \
													"<span class='notice'>You shave [H]'s fluff off.</span>")

								H.dna.features["moth_fluff"] = "Shaved"
								H.update_body()
								playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)

			else if(HAIR in H.dna.species.species_traits)
				if(user.a_intent == INTENT_HELP)
					if (H == user)
						to_chat(user, "<span class='warning'>You need a mirror to properly style your own hair!</span>")
						return
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					var/new_style = input(user, "Select a hairstyle", "Grooming")  as null|anything in GLOB.hairstyles_list
					if(!get_location_accessible(H, location))
						to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
						return
					if(HAS_TRAIT(H, TRAIT_BALD))
						to_chat(H, "<span class='warning'>[H] is just way too bald. Like, really really bald.</span>")
						return
					user.visible_message("<span class='notice'>[user] tries to change [H]'s hairstyle using [src].</span>", "<span class='notice'>You try to change [H]'s hairstyle using [src].</span>")
					if(new_style && do_after(user, 60, target = H))
						user.visible_message("<span class='notice'>[user] successfully changes [H]'s hairstyle using [src].</span>", "<span class='notice'>You successfully change [H]'s hairstyle using [src].</span>")
						H.hairstyle = new_style
						H.update_hair()
						return

				else
					if(!(HAIR in H.dna.species.species_traits))
						to_chat(user, "<span class='warning'>There is no hair to shave!</span>")
						return
					if(!get_location_accessible(H, location))
						to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
						return
					if(H.hairstyle == "Bald" || H.hairstyle == "Balding Hair" || H.hairstyle == "Skinhead")
						to_chat(user, "<span class='warning'>There is not enough hair left to shave!</span>")
						return

					if(H == user) //shaving yourself
						user.visible_message("<span class='notice'>[user] starts to shave [user.p_their()] head with [src].</span>", \
											"<span class='notice'>You start to shave your head with [src]...</span>")
						if(do_after(user, 5, target = H))
							user.visible_message("<span class='notice'>[user] shaves [user.p_their()] head with [src].</span>", \
												"<span class='notice'>You finish shaving with [src].</span>")
							shave(H, location)
					else
						var/turf/H_loc = H.loc
						user.visible_message("<span class='warning'>[user] tries to shave [H]'s head with [src]!</span>", \
											"<span class='notice'>You start shaving [H]'s head...</span>")
						if(do_after(user, 50, target = H))
							if(H_loc == H.loc)
								user.visible_message("<span class='warning'>[user] shaves [H]'s head bald with [src]!</span>", \
													"<span class='notice'>You shave [H]'s head bald.</span>")
								shave(H, location)
			else
				..()
		else
			..()
