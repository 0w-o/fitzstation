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

	var/obj/item/radio/radio

	var/last_update = 0

/obj/machinery/external_chat/relay/proc/fetch_messages()
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "http://localhost:8192/messages?last=[last_update]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())

	var/datum/http_response/response = request.into_response()

	if(response.errored)
		return

	var/list/data = json_decode(response["body"])
	last_update = data["lastMessageTime"]
	var/list/messages = data["messages"]

	for(var/list/message in messages)
		message["origin"] = sanitize(message["origin"])
		message["sender"] = sanitize(message["sender"])
		message["content"] = sanitize(message["content"])

	return messages

/obj/machinery/external_chat/relay/Initialize(mapload)
	. = ..()
	SHOULD_NOT_SLEEP(FALSE)

	radio = new(src)
	radio.set_listening(FALSE)

	var/list/messages = fetch_messages()
	if (messages.len > 0)
		last_update = messages[messages.len]["time"]

/obj/machinery/external_chat/relay/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/external_chat/relay/process(delta_time)
	var/list/messages = fetch_messages()

	for(var/list/message in messages)
		if (!(message["origin"] in service_freq_mapping))
			return

		verb_say = "[message["sender"]] says"

		var/radio_freq = service_freq_mapping[message["origin"]]
		var/list/spans = list(get_radio_span(radio_freq))
		radio.set_frequency(radio_freq)
		radio.talk_into(src, message["content"], radio_freq, spans)
