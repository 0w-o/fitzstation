/area/archipelago
	name = "Beach"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "station"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')
	base_lighting_alpha = 255
	base_lighting_color = "#FFFFCC"
	static_lighting = FALSE
	requires_power = FALSE

/area/archipelago/inside
	name = "inside"
	// TODO(fitz): make a new icon lol
	icon_state = "toilet"
	requires_power = TRUE
	ambientsounds = null

/area/archipelago/inside/engineering
	name = "engineering"
	icon_state = "engie"

/area/archipelago/inside/engineering/atmos
	name = "atmospherics"
	icon_state = "atmos"

/area/archipelago/inside/engineering/incinerator
	name = "incinerator"
	icon_state = "incinerator"

/area/archipelago/inside/engineering/engine
	name = "engine room"
	icon_state = "engine"

// remove me
/area/archipelago/engine
	name = "engine - old"
	icon_state = "unknown"
