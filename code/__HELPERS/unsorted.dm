

/*
 * A large number of misc global procs.
 */

//Inverts the colour of an HTML string
/proc/invertHTML(HTMLstring)
	if(!istext(HTMLstring))
		CRASH("Given non-text argument!")
	else if(length(HTMLstring) != 7)
		CRASH("Given non-HTML argument!")
	else if(length_char(HTMLstring) != 7)
		CRASH("Given non-hex symbols in argument!")
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	return rgb(255 - hex2num(textr), 255 - hex2num(textg), 255 - hex2num(textb))

/proc/Get_Angle(atom/movable/start,atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/dy
	var/dx
	dy=(32*end.y+end.pixel_y)-(32*start.y+start.pixel_y)
	dx=(32*end.x+end.pixel_x)-(32*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360

/proc/Get_Pixel_Angle(y, x)//for getting the angle when animating something's pixel_x and pixel_y
	if(!y)
		return (x>=0)?90:270
	.=arctan(x/y)
	if(y<0)
		.+=180
	else if(x<0)
		.+=360

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs = abs(dx)//Absolute value of x distance
	var/dyabs = abs(dy)
	var/sdx = SIGN(dx)	//Sign of x distance (+ or -)
	var/sdy = SIGN(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return FALSE

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i) //we know the first 6 chars are Guest-
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57) //0-9
			return FALSE
	return TRUE

//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
/mob/proc/apply_pref_name(role, client/C)
	if(!C)
		C = client
	var/oldname = real_name
	var/newname
	var/loop = 1
	var/safety = 0

	var/banned = C ? is_banned_from(C.ckey, "Appearance") : null

	while(loop && safety < 5)
		if(C && C.prefs.custom_names[role] && !safety && !banned)
			newname = C.prefs.custom_names[role]
		else
			switch(role)
				if("human")
					newname = random_unique_name(gender)
				if("clown")
					newname = pick(GLOB.clown_names)
				if("mime")
					newname = pick(GLOB.mime_names)
				if("ai")
					newname = pick(GLOB.ai_names)
				else
					return FALSE

		for(var/mob/living/M in GLOB.player_list)
			if(M == src)
				continue
			if(!newname || M.real_name == newname)
				newname = null
				loop++ // name is already taken so we roll again
				break
		loop--
		safety++

	if(newname)
		fully_replace_character_name(oldname,newname)
		return TRUE
	return FALSE


//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//Returns a list of all items of interest with their name
/proc/getpois(mobs_only = FALSE, skip_mindless = FALSE, specify_dead_role = TRUE)
	var/list/mobs = sortmobs()
	var/list/namecounts = list()
	var/list/pois = list()
	for(var/mob/M in mobs)
		if(skip_mindless && (!M.mind && !M.ckey))
			if(!isbot(M) && !iscameramob(M) && !ismegafauna(M))
				continue
		if(M.client && M.client.holder && M.client.holder.fakekey) //stealthmins
			continue
		var/name = avoid_assoc_duplicate_keys(M.name, namecounts) + M.get_realname_string()

		if(M.stat == DEAD && specify_dead_role)
			if(isobserver(M))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	if(!mobs_only)
		for(var/atom/A in GLOB.poi_list)
			if(!A || !A.loc)
				continue
			pois[avoid_assoc_duplicate_keys(A.name, namecounts)] = A

	return pois
//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortNames(GLOB.mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/camera/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/pai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/alien/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/monkey/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/slime/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/true_devil/M in sortmob)
		moblist.Add(M)
	return moblist

// Format a power value in W, kW, MW, or GW.
/proc/DisplayPower(powerused)
	if(powerused < 1000) //Less than a kW
		return "[powerused] W"
	else if(powerused < 1000000) //Less than a MW
		return "[round((powerused * 0.001),0.01)] kW"
	else if(powerused < 1000000000) //Less than a GW
		return "[round((powerused * 0.000001),0.001)] MW"
	return "[round((powerused * 0.000000001),0.0001)] GW"

// Format an energy value in J, kJ, MJ, or GJ. 1W = 1J/s.
/proc/DisplayJoules(units)
	if (units < 1000) // Less than a kJ
		return "[round(units, 0.1)] J"
	else if (units < 1000000) // Less than a MJ
		return "[round(units * 0.001, 0.01)] kJ"
	else if (units < 1000000000) // Less than a GJ
		return "[round(units * 0.000001, 0.001)] MJ"
	return "[round(units * 0.000000001, 0.0001)] GJ"

// Format an energy value measured in Power Cell units.
/proc/DisplayEnergy(units)
	// APCs process every (SSmachines.wait * 0.1) seconds, and turn 1 W of
	// excess power into GLOB.CELLRATE energy units when charging cells.
	// With the current configuration of wait=20 and CELLRATE=0.002, this
	// means that one unit is 1 kJ.
	return DisplayJoules(units * SSmachines.wait * 0.1 / GLOB.CELLRATE)

/proc/get_mob_by_ckey(key)
	if(!key)
		return
	var/list/mobs = sortmobs()
	for(var/mob/M in mobs)
		if(M.ckey == key)
			return M

/*
	Gets all contents of contents and returns them all in a list.
*/

/atom/proc/GetAllContents(T, ignore_flag_1)
	var/list/processing_list = list(src)
	if(T)
		. = list()
		var/i = 0
		while(i < length(processing_list))
			var/atom/A = processing_list[++i]
			//Byond does not allow things to be in multiple contents, or double parent-child hierarchies, so only += is needed
			//This is also why we don't need to check against assembled as we go along
			if (!(A.flags_1 & ignore_flag_1))
				processing_list += A.contents
				if(istype(A,T))
					. += A
	else
		var/i = 0
		while(i < length(processing_list))
			var/atom/A = processing_list[++i]
			if (!(A.flags_1 & ignore_flag_1))
				processing_list += A.contents
		return processing_list

/atom/proc/GetAllContentsIgnoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return GetAllContents()
	var/list/processing = list(src)
	. = list()
	var/i = 0
	while(i < length(processing))
		var/atom/A = processing[++i]
		if(!ignore_typecache[A.type])
			processing += A.contents
			. += A

//Repopulates sortedAreas list
/proc/repopulate_sorted_areas()
	GLOB.sortedAreas = list()

	for(var/area/A in world)
		GLOB.sortedAreas.Add(A)

	sortTim(GLOB.sortedAreas, GLOBAL_PROC_REF(cmp_name_asc))

/area/proc/addSorted()
	GLOB.sortedAreas.Add(src)
	sortTim(GLOB.sortedAreas, GLOBAL_PROC_REF(cmp_name_asc))

//Takes: Area type as a text string from a variable.
//Returns: Instance for the area in the world.
/proc/get_area_instance_from_text(areatext)
	if(istext(areatext))
		areatext = text2path(areatext)
	return GLOB.areas_by_type[areatext]

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype, subtypes=TRUE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/areas = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(cache[A.type])
				areas += V
	else
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(A.type == areatype)
				areas += V
	return areas

/**
 * Returns a list of all turfs in the provided area instance.
 *
 * Arguments:
 * * A - The area to get all the turfs from
 */
/proc/get_area_turfs(area/A)
	. = list()
	for(var/turf/T in A)
		. += T

/**
 * Returns a list of all turfs in ALL areas of that type in the world.
 *
 * Arguments:
 * * areatype - The type of area to search for as a text string or typepath or instance
 * * target_z - The z level to search for areas on
 * * subtypes - Whether or not areas of a subtype type are included in the results
 */
/proc/get_areatype_turfs(areatype, target_z = 0, subtypes=FALSE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/turfs = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(!cache[A.type])
				continue
			for(var/turf/T in A)
				if(target_z == 0 || target_z == T.z)
					turfs += T
	else
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(A.type != areatype)
				continue
			for(var/turf/T in A)
				if(target_z == 0 || target_z == T.z)
					turfs += T
	return turfs

//chances are 1:value. anyprob(1) will always return true
/proc/anyprob(value)
	return (rand(1,value)==value)

/proc/parse_zone(zone)	// Именительный
	if(zone == BODY_ZONE_PRECISE_R_HAND)
		return "правая кисть"
	else if (zone == BODY_ZONE_PRECISE_L_HAND)
		return "левая кисть"
	else if (zone == BODY_ZONE_L_ARM)
		return "левая рука"
	else if (zone == BODY_ZONE_R_ARM)
		return "правая рука"
	else if (zone == BODY_ZONE_L_LEG)
		return "левая нога"
	else if (zone == BODY_ZONE_R_LEG)
		return "правая нога"
	else if (zone == BODY_ZONE_PRECISE_L_FOOT)
		return "левая ступня"
	else if (zone == BODY_ZONE_PRECISE_R_FOOT)
		return "правая ступня"
	else if (zone == "chest")
		return "грудь"
	else if (zone == "mouth")
		return "рот"
	else if (zone == "groin")
		return "пах"
	else if (zone == "head")
		return "голова"
	else if (zone == "eyes")
		return "глаза"
	else
		return zone

/proc/ru_parse_zone(zone)	// Винительный
	if(zone == "правая кисть")
		return "правую кисть"
	else if (zone == "левая кисть")
		return "левую кисть"
	else if (zone == "левая рука")
		return "левую руку"
	else if (zone == "правая рука")
		return "правую руку"
	else if (zone == "левая нога")
		return "левую ногу"
	else if (zone == "правая нога")
		return "правую ногу"
	else if (zone == "левая ступня")
		return "левую ступню"
	else if (zone == "правая ступня")
		return "правую ступню"
	else if (zone == "грудь")
		return "грудь"
	else if (zone == "рот")
		return "рот"
	else if (zone == "пах")
		return "пах"
	else if (zone == "голова")
		return "голову"
	else
		return zone

/proc/ru_gde_zone(zone)	// Дательный
	if(zone == "правая кисть")
		return "правой кисти"
	else if (zone == "левая кисть")
		return "левой кисти"
	else if (zone == "левая рука")
		return "левой руке"
	else if (zone == "правая рука")
		return "правой руке"
	else if (zone == "левая нога")
		return "левой ноге"
	else if (zone == "правая нога")
		return "правой ноге"
	else if (zone == "левая ступня")
		return "левой ступне"
	else if (zone == "правая ступня")
		return "правой ступне"
	else if (zone == "грудь")
		return "груди"
	else if (zone == "рот")
		return "ротовой полости"
	else if (zone == "пах")
		return "паховой области"
	else if (zone == "голова")
		return "голове"
	else
		return zone

/proc/ru_otkuda_zone(zone)	// Родительный
	if(zone == "правая кисть")
		return "правой кисти"
	else if (zone == "левая кисть")
		return "левой кисти"
	else if (zone == "левая рука")
		return "левой руки"
	else if (zone == "правая рука")
		return "правой руки"
	else if (zone == "левая нога")
		return "левой ноги"
	else if (zone == "правая нога")
		return "правой ноги"
	else if (zone == "левая ступня")
		return "левой ступни"
	else if (zone == "правая ступня")
		return "правой ступни"
	else if (zone == "грудь")
		return "груди"
	else if (zone == "рот")
		return "ротовой полости"
	else if (zone == "пах")
		return "паховой области"
	else if (zone == "голова")
		return "головы"
	else
		return zone

/proc/ru_chem_zone(zone)	// Творительный
	if(zone == "правая кисть")
		return "правой кистью"
	else if (zone == "левая кисть")
		return "левой кистью"
	else if (zone == "левая рука")
		return "левой рукой"
	else if (zone == "правая рука")
		return "правой рукой"
	else if (zone == "левая нога")
		return "левой ногой"
	else if (zone == "правая нога")
		return "правой ногой"
	else if (zone == "левая ступня")
		return "левой ступней"
	else if (zone == "правая ступня")
		return "правой ступней"
	else if (zone == "грудь")
		return "грудью"
	else if (zone == "рот")
		return "ртом"
	else if (zone == "пах")
		return "пахом"
	else if (zone == "голова")
		return "головой"
	else
		return zone

/proc/ru_exam_parse_zone(zone)
	if (zone == "chest")
		return "грудь"
	else if (zone == "mouth")
		return "рот"
	else if (zone == "groin")
		return "пах"
	else if (zone == "head")
		return "голова"
	else
		return zone

/proc/ru_intent(intent)
	switch(intent)
		if (INTENT_HELP)
			return "помогать"
		if (INTENT_GRAB)
			return "хватать"
		if (INTENT_DISARM)
			return "толкать"
		if (INTENT_HARM)
			return "вредить"
		else
			return intent

/proc/jumpsuit_to_ru_conversion(jumpsuit)
	switch(jumpsuit)
		if("Jumpsuit")
			return "Комбез"
		if("Jumpskirt")
			return "Юбкомбез"
		else
			return jumpsuit

/proc/backpack_to_ru_conversion(backpack)
	switch(backpack)
		if("Grey Backpack")
			return "Серый рюкзак"
		if("Grey Satchel")
			return "Серая сумка"
		if("Grey Duffel Bag")
			return "Серый вещмешок"
		if("Leather Satchel")
			return "Кожаная сумка"
		if("Department Backpack")
			return "Рюкзак отдела"
		if("Department Satchel")
			return "Сумка отдела"
		if("Department Duffel Bag")
			return "Вещмешок отдела"
		else
			return backpack

/proc/uplink_to_ru_conversion(uplink)
	switch(uplink)
		if("PDA")
			return "ПДА"
		if("Radio")
			return "Наушник"
		if("Pen")
			return "Ручка"
		if("Implant")
			return "Имплант"
		else
			return uplink

///Returns a string based on the weight class define used as argument
/proc/weight_class_to_text(w_class)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			. = "маленького"
		if(WEIGHT_CLASS_SMALL)
			. = "небольшого"
		if(WEIGHT_CLASS_NORMAL)
			. = "среднего"
		if(WEIGHT_CLASS_BULKY)
			. = "большого"
		if(WEIGHT_CLASS_HUGE)
			. = "огромного"
		if(WEIGHT_CLASS_GIGANTIC)
			. = "гигантского"
		else
			. = ""

//Finds the distance between two atoms, in pixels
//centered = FALSE counts from turf edge to edge
//centered = TRUE counts from turf center to turf center
//of course mathematically this is just adding world.icon_size on again
/proc/getPixelDistance(atom/A, atom/B, centered = TRUE)
	if(!istype(A)||!istype(B))
		return 0
	. = bounds_dist(A, B) + sqrt((((A.pixel_x+B.pixel_x)**2) + ((A.pixel_y+B.pixel_y)**2)))
	if(centered)
		. += world.icon_size

/*
Checks if that loc and dir has an item on the wall
*/
GLOBAL_LIST_INIT(WALLITEMS, typecacheof(list(
	/obj/machinery/power/apc, /obj/machinery/airalarm, /obj/item/radio/intercom,
	/obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/button,
	/obj/machinery/computer/security/telescreen, /obj/machinery/embedded_controller/radio/simple_vent_controller,
	/obj/item/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment,
	/obj/structure/sign/picture_frame, /obj/machinery/bounty_board
	)))

GLOBAL_LIST_INIT(WALLITEMS_EXTERNAL, typecacheof(list(
	/obj/machinery/camera, /obj/structure/camera_assembly,
	/obj/structure/light_construct, /obj/machinery/light)))

GLOBAL_LIST_INIT(WALLITEMS_INVERSE, typecacheof(list(
	/obj/structure/light_construct, /obj/machinery/light)))


/proc/gotwallitem(loc, dir, check_external = 0)
	var/locdir = get_step(loc, turn(dir,180)) //SinguloStation13 Edit
	for(var/obj/O in loc)
		if(is_type_in_typecache(O, GLOB.WALLITEMS) && check_external != 2)
			//Direction works sometimes
			if(is_type_in_typecache(O, GLOB.WALLITEMS_INVERSE))
				if(O.dir == turn(dir, 180))
					return 1
			else if(O.dir == dir)
				return 1

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			//That's exactly what get_turf_pixel() does
			if(get_turf_pixel(O) == locdir)
				return 1

		if(is_type_in_typecache(O, GLOB.WALLITEMS_EXTERNAL) && check_external)
			if(is_type_in_typecache(O, GLOB.WALLITEMS_INVERSE))
				if(O.dir == turn(dir, 180))
					return 1
			else if(O.dir == dir)
				return 1

	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in locdir)
		if(is_type_in_typecache(O, GLOB.WALLITEMS) && check_external != 2)
			if(O.pixel_x == 0 && O.pixel_y == 0)
				return 1
	return 0

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overridden at the same time*/
	if(!isliving(target) || target.body_position == LYING_DOWN)
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FALSE
	if(initator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_A_facing_B(initator,target) && is_A_facing_B(target,initator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR

/proc/living_player_count()
	var/living_player_count = 0
	for(var/mob in GLOB.player_list)
		if(mob in GLOB.alive_mob_list)
			living_player_count += 1
	return living_player_count

/proc/randomColor(mode = 0)	//if 1 it doesn't pick white, black or gray
	switch(mode)
		if(0)
			return pick("white","black","gray","red","green","blue","brown","yellow","orange","darkred",
						"crimson","lime","darkgreen","cyan","navy","teal","purple","indigo")
		if(1)
			return pick("red","green","blue","brown","yellow","orange","darkred","crimson",
						"lime","darkgreen","cyan","navy","teal","purple","indigo")
		else
			return "white"

/proc/params2turf(scr_loc, turf/origin, client/C)
	if(!scr_loc)
		return null
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + text2num(tX) - round(actual_view[1] / 2) - 1, 1, world.maxx)
	tY = clamp(origin.y + text2num(tY) - round(actual_view[2] / 2) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)

/proc/screen_loc2turf(text, turf/origin, client/C)
	if(!text)
		return null
	var/tZ = splittext(text, ",")
	var/tX = splittext(tZ[1], "-")
	var/tY = text2num(tX[2])
	tX = splittext(tZ[2], "-")
	tX = text2num(tX[2])
	tZ = origin.z
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + round(actual_view[1] / 2) - tX, 1, world.maxx)
	tY = clamp(origin.y + round(actual_view[2] / 2) - tY, 1, world.maxy)
	return locate(tX, tY, tZ)

/proc/IsValidSrc(datum/D)
	if(istype(D))
		return !QDELETED(D)
	return 0

//Compare A's dir, the clockwise dir of A and the anticlockwise dir of A
//To the opposite dir of the dir returned by get_dir(B,A)
//If one of them is a match, then A is facing B
/proc/is_A_facing_B(atom/A,atom/B)
	if(!istype(A) || !istype(B))
		return FALSE
	if(isliving(A))
		var/mob/living/LA = A
		if(LA.body_position == LYING_DOWN)
			return FALSE
	var/goal_dir = get_dir(A,B)
	var/clockwise_A_dir = turn(A.dir, -45)
	var/anticlockwise_A_dir = turn(A.dir, 45)

	if(A.dir == goal_dir || clockwise_A_dir == goal_dir || anticlockwise_A_dir == goal_dir)
		return TRUE
	return FALSE


/*
* rough example of the "cone" made by the 3 dirs checked*
*
* B
*  \
*   \
*    >
*      <
*       \
*        \
*B --><-- A
*        /
*       /
*      <
*     >
*    /
*   /
* B
*
*/


//Center's an image.
//Requires:
//The Image
//The x dimension of the icon file used in the image
//The y dimension of the icon file used in the image
// eg: center_image(I, 32,32)
// eg2: center_image(I, 96,96)

/proc/center_image(image/I, x_dimension = 0, y_dimension = 0)
	if(!I)
		return

	if(!x_dimension || !y_dimension)
		return

	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return I

	//Offset the image so that it's bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension/world.icon_size)-1)*(world.icon_size*0.5)
	var/y_offset = -((y_dimension/world.icon_size)-1)*(world.icon_size*0.5)

	//Correct values under world.icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	I.pixel_x = x_offset
	I.pixel_y = y_offset

	return I

/proc/flick_overlay_static(O, atom/A, duration)
	set waitfor = 0
	if(!A || !O)
		return
	A.add_overlay(O)
	sleep(duration)
	A.cut_overlay(O)

/proc/get_random_ship_turf()
	var/obj/docking_port/mobile/shuttle = pick(SSshuttle.mobile)
	var/area/A = pick(shuttle.shuttle_areas)
	return pick(A.contents)

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)

/datum/proc/stack_trace(msg)
	CRASH(msg)

/obj/item/bodypart/proc/limb_stacktrace(msg, bypass_cap) //yes yes this uses a magic number but fuck it.
	var/static/mcount
	if(mcount == 10)
		message_debug("Kapu1178/LimbSystem: Limb Stack trace cap exceeded, further traces silenced.")
		mcount++
	if((mcount < 10) || bypass_cap)
		mcount++
		CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null

//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

//returns the number of ticks slept
/proc/stoplag(initial_delay)
	if (!Master || Master.init_stage_completed < INITSTAGE_MAX)
		sleep(world.tick_lag)
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i*DELTA_CALC, 1)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

/proc/flash_color(mob_or_client, flash_color="#960000", flash_time=20)
	var/client/C
	if(ismob(mob_or_client))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(istype(mob_or_client, /client))
		C = mob_or_client

	if(!istype(C))
		return

	var/animate_color = C.color
	C.color = flash_color
	animate(C, color = animate_color, time = flash_time)

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

/proc/random_nukecode()
	var/val = rand(0, 99999)
	var/str = "[val]"
	while(length(str) < 5)
		str = "0" + str
	. = str

/atom/proc/Shake(pixelshiftx = 15, pixelshifty = 15, duration = 250)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shiftx = rand(-pixelshiftx,pixelshiftx)
	var/shifty = rand(-pixelshifty,pixelshifty)
	animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = 0.2, loop = duration)
	pixel_x = initialpixelx
	pixel_y = initialpixely

/proc/weightclass2text(w_class)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			. = "tiny"
		if(WEIGHT_CLASS_SMALL)
			. = "small"
		if(WEIGHT_CLASS_NORMAL)
			. = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			. = "bulky"
		if(WEIGHT_CLASS_HUGE)
			. = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			. = "gigantic"
		else
			. = ""

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

//Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.see_invisible = invis_flags

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	name = "INTERNAL DVIEW MOB"
	invisibility = 101
	density = FALSE
	see_in_dark = 1e6
	move_resist = INFINITY
	var/ready_to_die = FALSE

/mob/dview/Initialize() //Properly prevents this mob from gaining huds or joining any global lists
	SHOULD_CALL_PARENT(FALSE)
	return INITIALIZE_HINT_NORMAL

/mob/dview/Destroy(force = FALSE)
	if(!ready_to_die)
		stack_trace("ALRIGHT WHICH FUCKER TRIED TO DELETE *MY* DVIEW?")

		if (!force)
			return QDEL_HINT_LETMELIVE

		log_world("EVACUATE THE SHITCODE IS TRYING TO STEAL MUH JOBS")
		GLOB.dview_mob = new
	return ..()


#define FOR_DVIEW(type, range, center, invis_flags) \
	GLOB.dview_mob.loc = center;           \
	GLOB.dview_mob.see_invisible = invis_flags; \
	for(type in view(range, GLOB.dview_mob))

#define FOR_DVIEW_END GLOB.dview_mob.loc = null

#define UNTIL(X) while(!(X)) stoplag()

/proc/get_mob_or_brainmob(occupant)
	var/mob/living/mob_occupant

	if(isliving(occupant))
		mob_occupant = occupant

	else if(isbodypart(occupant))
		var/obj/item/bodypart/head/head = occupant

		mob_occupant = head.brainmob

	else if(isorgan(occupant))
		var/obj/item/organ/brain/brain = occupant
		mob_occupant = brain.brainmob

	return mob_occupant

//counts the number of bits in Byond's 16-bit width field
//in constant time and memory!
/proc/BitCount(bitfield)
	var/temp = bitfield - ((bitfield>>1)&46811) - ((bitfield>>2)&37449) //0133333 and 0111111 respectively
	temp = ((temp + (temp>>3))&29127) % 63	//070707
	return temp

//same as do_mob except for movables and it allows both to drift and doesn't draw progressbar
/proc/do_atom(atom/movable/user , atom/movable/target, time = 30, uninterruptible = 0,datum/callback/extra_checks = null)
	if(!user || !target)
		return TRUE
	var/user_loc = user.loc

	var/drifting = FALSE
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = TRUE

	var/target_drifting = FALSE
	if(!target.Process_Spacemove(0) && target.inertia_dir)
		target_drifting = TRUE

	var/target_loc = target.loc

	var/endtime = world.time+time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if(QDELETED(user) || QDELETED(target))
			. = 0
			break
		if(uninterruptible)
			continue

		if(drifting && !user.inertia_dir)
			drifting = FALSE
			user_loc = user.loc

		if(target_drifting && !target.inertia_dir)
			target_drifting = FALSE
			target_loc = target.loc

		if((!drifting && user.loc != user_loc) || (!target_drifting && target.loc != target_loc) || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

//returns a GUID like identifier (using a mostly made up record format)
//guids are not on their own suitable for access or security tokens, as most of their bits are predictable.
//	(But may make a nice salt to one)
/proc/GUID()
	var/const/GUID_VERSION = "b"
	var/const/GUID_VARIANT = "d"
	var/node_id = copytext_char(md5("[rand()*rand(1,9999999)][world.name][world.hub][world.hub_password][world.internet_address][world.address][world.contents.len][world.status][world.port][rand()*rand(1,9999999)]"), 1, 13)

	var/time_high = "[num2hex(text2num(time2text(world.realtime,"YYYY")), 2)][num2hex(world.realtime, 6)]"

	var/time_mid = num2hex(world.timeofday, 4)

	var/time_low = num2hex(world.time, 3)

	var/time_clock = num2hex(TICK_DELTA_TO_MS(world.tick_usage), 3)

	return "{[time_high]-[time_mid]-[GUID_VERSION][time_low]-[GUID_VARIANT][time_clock]-[node_id]}"

// \ref behaviour got changed in 512 so this is necesary to replicate old behaviour.
// If it ever becomes necesary to get a more performant REF(), this lies here in wait
// #define REF(thing) (thing && istype(thing, /datum) && (thing:datum_flags & DF_USE_TAG) && thing:tag ? "[thing:tag]" : "\ref[thing]")
/proc/REF(input)
	if(istype(input, /datum))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return "\ref[input]"

// Makes a call in the context of a different usr
// Use sparingly
/world/proc/PushUsr(mob/M, datum/callback/CB, ...)
	var/temp = usr
	usr = M
	if (length(args) > 2)
		. = CB.Invoke(arglist(args.Copy(3)))
	else
		. = CB.Invoke()
	usr = temp

//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)

#define VARSET_LIST_CALLBACK(target, var_name, var_value) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___callbackvarset), ##target, ##var_name, ##var_value)
//dupe code because dm can't handle 3 level deep macros
#define VARSET_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___callbackvarset), ##datum, NAMEOF(##datum, ##var), ##var_value)

/proc/___callbackvarset(list_or_datum, var_name, var_value)
	if(length(list_or_datum))
		list_or_datum[var_name] = var_value
		return
	var/datum/D = list_or_datum
	if(IsAdminAdvancedProcCall())
		D.vv_edit_var(var_name, var_value)	//same result generally, unless badmemes
	else
		D.vars[var_name] = var_value

#define TRAIT_CALLBACK_ADD(target, trait, source) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___TraitAdd), ##target, ##trait, ##source)
#define TRAIT_CALLBACK_REMOVE(target, trait, source) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___TraitRemove), ##target, ##trait, ##source)

///DO NOT USE ___TraitAdd OR ___TraitRemove as a replacement for ADD_TRAIT / REMOVE_TRAIT defines. To be used explicitly for callback.
/proc/___TraitAdd(target,trait,source)
	if(!target || !trait || !source)
		return
	if(islist(target))
		for(var/i in target)
			if(!isatom(i))
				continue
			var/atom/the_atom = i
			ADD_TRAIT(the_atom,trait,source)
	else if(isatom(target))
		var/atom/the_atom2 = target
		ADD_TRAIT(the_atom2,trait,source)

///DO NOT USE ___TraitAdd OR ___TraitRemove as a replacement for ADD_TRAIT / REMOVE_TRAIT defines. To be used explicitly for callback.
/proc/___TraitRemove(target,trait,source)
	if(!target || !trait || !source)
		return
	if(islist(target))
		for(var/i in target)
			if(!isatom(i))
				continue
			var/atom/the_atom = i
			REMOVE_TRAIT(the_atom,trait,source)
	else if(isatom(target))
		var/atom/the_atom2 = target
		REMOVE_TRAIT(the_atom2,trait,source)

/proc/get_random_food()
	var/list/blocked = list(/obj/item/reagent_containers/food/snacks/store/bread,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/store/cake,
		/obj/item/reagent_containers/food/snacks/cakeslice,
		/obj/item/reagent_containers/food/snacks/store,
		/obj/item/reagent_containers/food/snacks/pie,
		/obj/item/reagent_containers/food/snacks/kebab,
		/obj/item/reagent_containers/food/snacks/pizza,
		/obj/item/reagent_containers/food/snacks/pizzaslice,
		/obj/item/reagent_containers/food/snacks/salad,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat/slab,
		/obj/item/reagent_containers/food/snacks/soup,
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/deepfryholder,
		/obj/item/reagent_containers/food/snacks/clothing,
		/obj/item/reagent_containers/food/snacks/grown/shell, //base types
		/obj/item/reagent_containers/food/snacks/store/bread,
		/obj/item/reagent_containers/food/snacks/grown/nettle
		)
	blocked |= typesof(/obj/item/reagent_containers/food/snacks/customizable)

	return pick(subtypesof(/obj/item/reagent_containers/food/snacks) - blocked)

/proc/get_random_drink()
	var/list/blocked = list(/obj/item/reagent_containers/food/drinks/soda_cans,
		/obj/item/reagent_containers/food/drinks/bottle
		)
	return pick(subtypesof(/obj/item/reagent_containers/food/drinks) - blocked)

//For these two procs refs MUST be ref = TRUE format like typecaches!
/proc/weakref_filter_list(list/things, list/refs)
	if(!islist(things) || !islist(refs))
		return
	if(!refs.len)
		return things
	if(things.len > refs.len)
		var/list/f = list()
		for(var/i in refs)
			var/datum/weakref/r = i
			var/datum/d = r.resolve()
			if(d)
				f |= d
		return things & f

	else
		. = list()
		for(var/i in things)
			if(!refs[WEAKREF(i)])
				continue
			. |= i

/proc/weakref_filter_list_reverse(list/things, list/refs)
	if(!islist(things) || !islist(refs))
		return
	if(!refs.len)
		return things
	if(things.len > refs.len)
		var/list/f = list()
		for(var/i in refs)
			var/datum/weakref/r = i
			var/datum/d = r.resolve()
			if(d)
				f |= d

		return things - f
	else
		. = list()
		for(var/i in things)
			if(refs[WEAKREF(i)])
				continue
			. |= i

/proc/special_list_filter(list/L, datum/callback/condition)
	if(!islist(L) || !length(L) || !istype(condition))
		return list()
	. = list()
	for(var/i in L)
		if(condition.Invoke(i))
			. |= i

/proc/num2sign(numeric)
	if(numeric > 0)
		return 1
	else if(numeric < 0)
		return -1
	else
		return 0

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

#define TURF_FROM_COORDS_LIST(List) (locate(List[1], List[2], List[3]))
