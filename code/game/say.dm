/*
	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/
GLOBAL_LIST_INIT(freqtospan, list(
	"[FREQ_NANOTRASEN]" = "ntradio",
	"[FREQ_MINUTEMEN]" = "cmmradio",
	"[FREQ_INTEQ]" = "irmgradio",
	"[FREQ_PIRATE]" = "pirradio",
	"[FREQ_COMMAND]" = "comradio",
	"[FREQ_AI_PRIVATE]" = "aiprivradio",
	"[FREQ_SYNDICATE]" = "syndradio",
	"[FREQ_CENTCOM]" = "centcomradio",
	"[FREQ_SOLGOV]" = "solgovradio",		//WS Edit - SolGov Rep
	"[FREQ_WIDEBAND]" = "widebandradio",	//WS Edit - Overmaps
	"[FREQ_CTF_RED]" = "redteamradio",
	"[FREQ_CTF_BLUE]" = "blueteamradio",
	"[FREQ_FACTION]" = "centcomradio",
	))

/atom/movable/proc/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	spans |= speech_span
	if(!language)
		language = get_selected_language()
	send_speech(message, 7, src, , spans, message_language=language)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)

/atom/movable/proc/can_speak()
	//SHOULD_BE_PURE(TRUE)
	return TRUE

/atom/movable/proc/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language = null, list/message_mods = list())
	var/rendered = compose_message(src, message_language, message, , spans, message_mods)
	for(var/atom/movable/AM as anything in get_hearers_in_view(range, source))
		AM.Hear(rendered, src, message_language, message, , spans, message_mods)

/atom/movable/proc/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), face_name = FALSE)
	//This proc uses text() because it is faster than appending strings. Thanks BYOND.
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Radio freq/name display
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Speaker name
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	if(face_name && ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		namepart = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised
	//End name span.
	var/endspanpart = "</span>"

	//Message
	var/messagepart
	var/languageicon = ""
	if (message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		messagepart = message_mods[MODE_CUSTOM_SAY_EMOTE]
	else
		messagepart = lang_treat(speaker, message_language, raw_message, spans, message_mods)

		var/datum/language/D = GLOB.language_datum_instances[message_language]
		if(istype(D) && D.display_icon(src))
			languageicon = "[D.get_icon()] "

	messagepart = " <span class='message'>[say_emphasis(messagepart)]</span></span>"

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	var/speakerJob = speaker.GetJob()
	return "[ speakerJob ? " (" +  speakerJob + ")" : ""]"

/atom/movable/proc/say_mod(input, list/message_mods = list())
	var/ending = copytext_char(input, -1)
	if(copytext_char(input, -2) == "!!")
		return verb_yell
	else if(message_mods[MODE_SING])
		. = verb_sing
	else if(ending == "?")
		return verb_ask
	else if(ending == "!")
		return verb_exclaim
	else
		return verb_say

/atom/movable/proc/say_quote(input, list/spans=list(speech_span), list/message_mods = list())
	if(!input)
		input = "..."

	if(copytext_char(input, -2) == "!!")
		spans |= SPAN_YELL

	var/say_mod = message_mods[MODE_CUSTOM_SAY_EMOTE]
	if (!say_mod)
		say_mod = say_mod(input, message_mods)

	var/spanned = attach_spans(input, spans)
	return "[say_mod], \"[spanned]\""

/// Transforms the speech emphasis mods from [/atom/movable/proc/say_emphasis] into the appropriate HTML tags. Includes escaping.
#define ENCODE_HTML_EMPHASIS(input, char, html, varname) \
	var/static/regex/##varname = regex("(?<!\\\\)[char](.+?)(?<!\\\\)[char]", "g");\
	input = varname.Replace_char(input, "<[html]>$1</[html]>")

/// Scans the input sentence for speech emphasis modifiers, notably |italics|, +bold+, and _underline_ -mothblocks
/atom/proc/say_emphasis(input)
	ENCODE_HTML_EMPHASIS(input, "\\|", "i", italics)
	ENCODE_HTML_EMPHASIS(input, "\\+", "b", bold)
	ENCODE_HTML_EMPHASIS(input, "_", "u", underline)
	var/static/regex/remove_escape_backlashes = regex("\\\\(_|\\+|\\|)", "g") // Removes backslashes used to escape text modification.
	input = remove_escape_backlashes.Replace_char(input, "$1")
	return input

#undef ENCODE_HTML_EMPHASIS

/atom/movable/proc/lang_treat(atom/movable/speaker, datum/language/language, raw_message, list/spans, list/message_mods = list(), no_quote = FALSE)
	var/atom/movable/source = speaker.GetSource() || speaker //is the speaker virtual
	if(has_language(language))
		return no_quote ? raw_message : source.say_quote(raw_message, spans, message_mods)
	else if(language)
		var/datum/language/D = GLOB.language_datum_instances[language]
		raw_message = D.scramble(raw_message)
		return no_quote ? raw_message : source.say_quote(raw_message, spans, message_mods)
	else
		return "makes a strange sound."

/proc/get_radio_span(freq)
	var/returntext = GLOB.freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	var/returntext = ru_comms(GLOB.reverseradiochannels["[freq]"])
	if(returntext)
		return returntext
	return "[copytext_char("[freq]", 1, 4)].[copytext_char("[freq]", 4, 5)]"

/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"

/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output

/proc/say_test(text)
	var/ending = copytext_char(text, -1)
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

/atom/movable/proc/GetVoice()
	return "[src]"	//Returns the atom's name, prepended with 'The' if it's not a proper noun

/atom/movable/proc/IsVocal()
	return 1

/atom/movable/proc/get_alt_name()

//HACKY VIRTUALSPEAKER STUFF BEYOND THIS POINT
//these exist mostly to deal with the AIs hrefs and job stuff.

/atom/movable/proc/GetJob() //Get a job, you lazy butte

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()

//VIRTUALSPEAKERS
/atom/movable/virtualspeaker
	var/atom/movable/source
	var/obj/item/radio/radio

INITIALIZE_IMMEDIATE(/atom/movable/virtualspeaker)
/atom/movable/virtualspeaker/Initialize(mapload, atom/movable/M, radio)
	. = ..()
	radio = radio
	source = M
	if (istype(M))
		name = M.GetVoice()
		verb_say = M.verb_say
		verb_ask = M.verb_ask
		verb_exclaim = M.verb_exclaim
		verb_yell = M.verb_yell

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio
