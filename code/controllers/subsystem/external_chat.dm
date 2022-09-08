SUBSYSTEM_DEF(external_chat)
	name = "External Chat"
	wait = 10
	flags = SS_POST_FIRE_TIMING
	priority = FIRE_PRIORITY_EXTERNAL_CHAT
	runlevels = RUNLEVEL_GAME
	// var/last_update = 0
	// var/obj/item/radio/Radio
	// var/atom/movable/virtualspeaker/speaker

/datum/controller/subsystem/external_chat/Initialize(start_timeofday)
	// Radio = new /obj/item/radio(null)
	// Radio.set_listening(FALSE)
	// speaker = new(null, null, Radio)
	return ..()

/datum/controller/subsystem/external_chat/fire(resumed)
	return
	// var/datum/http_request/request = new()
	// request.prepare(RUSTG_HTTP_METHOD_GET, "http://localhost:8192/messages?last=[last_update]", "", "")
	// request.execute_blocking()

	// var/datum/http_response/response = request.into_response()

	// // var/datum/signal/subspace/vocal/signal = new(null, FREQ_CENTCOM, speaker, /datum/language/common, "TestIcles", list(), list())
	// // signal.broadcast()

	// if(response.errored)
	// 	return

	// var/list/data = json_decode(response["body"])
	// last_update = data["lastMessageTime"]
	// var/list/messages = data["messages"]

	// for(var/list/message in messages)
	// 	var/origin = sanitize(message["origin"])
	// 	var/content = sanitize(message["content"])

	// 	var/radio_freq
	// 	if (origin == "discord")
	// 		radio_freq = FREQ_CENTCOM
	// 	else if (origin == "twitch")
	// 		radio_freq = FREQ_COMMAND

	// 	Radio.set_frequency(radio_freq)
	// 	Radio.talk_into(speaker, content, radio_freq)

	// 	message_admins("\[[origin]] [content]")
