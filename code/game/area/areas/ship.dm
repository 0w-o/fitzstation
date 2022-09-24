/area/ship
	name = "Ship Areas"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "station"

	// TODO(fitz): add gravity gen
	has_gravity = STANDARD_GRAVITY

/area/ship/ai
	name = "AI Access"
	icon_state = "ai"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ship/ai/turret_protected
	name = "AI Upload"
	icon_state = "ai_chamber"
	ambientsounds = list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/ship/cargo
	name = "Cargo Bay"
	icon_state = "cargo_bay"
	airlock_wires = /datum/wires/airlock/service
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ship/engineering
	name = "Engineering"
	icon_state = "engine"
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/ship/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/ship/maintenance
	name = "Maintenance"
	icon_state = "centralmaint"
