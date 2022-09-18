/obj/machinery/external_chat
	name = "External Chat"
	desc = "An invalid object. Don't do it."
	icon = 'icons/obj/machines/telecomms.dmi'

/obj/machinery/external_chat/relay
	name = ""
	desc = "A very complex router and transmitter capable of connecting bluespace networks together. Looks fragile."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "relay"
	verb_say = "unknown says"

	var/list/service_freq_mapping = list(
		"twitch" = FREQ_COMMAND,
		"discord" = FREQ_CENTCOM,
		"youtube" = FREQ_SYNDICATE
		)

	var/datum/http_request/current_request
	var/obj/item/radio/radio
	var/last_update = 0
	var/first_request = TRUE

/obj/machinery/external_chat/relay/proc/fetch_messages()
	if(!current_request)
		current_request = new()
		current_request.prepare(RUSTG_HTTP_METHOD_GET, "http://localhost:8192/messages?last=[last_update]", "", "")
		current_request.begin_async()
		return null

	if(!current_request.is_complete())
		return null

	var/datum/http_response/response = current_request.into_response()
	current_request = null

	if(response.errored)
		return null

	var/list/data = json_decode(response["body"])
	last_update = data["lastMessageTime"]

	if(first_request)
		first_request = FALSE
		return null

	var/list/messages = data["messages"]

	for(var/list/message in messages)
		message["origin"] = sanitize(message["origin"])
		message["sender"] = sanitize(message["sender"])
		message["content"] = sanitize(message["content"])


	return messages

/obj/machinery/external_chat/relay/Initialize(mapload)
	. = ..()

	radio = new(src)
	radio.set_listening(FALSE)

	var/list/messages = fetch_messages()
	if(!messages)
		return

	if(messages.len > 0)
		last_update = messages[messages.len]["time"]

/obj/machinery/external_chat/relay/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/external_chat/relay/process(delta_time)
	var/list/messages = fetch_messages()

	if(!messages)
		return

	for(var/list/message in messages)
		if (!(message["origin"] in service_freq_mapping))
			return

		verb_say = "[message["sender"]] says"

		var/radio_freq = service_freq_mapping[message["origin"]]
		var/list/spans = list(get_radio_span(radio_freq))
		radio.set_frequency(radio_freq)
		radio.talk_into(src, message["content"], radio_freq, spans)
