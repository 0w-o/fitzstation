/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon = 'icons/paradise/obj/power.dmi'
	icon_state = "teg"
	density = TRUE
	use_power = NO_POWER_USE

	circuit = /obj/item/circuitboard/machine/generator

	var/obj/machinery/atmospherics/components/binary/circulator/cold_circ
	var/obj/machinery/atmospherics/components/binary/circulator/hot_circ

	var/lastgen = 0
	var/lastgenlev = -1
	var/lastcirc = "00"

/obj/machinery/power/generator/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)
	find_circs()
	connect_to_network()
	SSair.start_processing_machine(src)
	update_appearance()

/obj/machinery/power/generator/Destroy()
	kill_circs()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/power/generator/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	var/L = min(round(lastgenlev / 100000), 11)
	if(L != 0)
		. += mutable_appearance('icons/paradise/obj/power.dmi', "teg-op[L]")
	if(hot_circ && cold_circ)
		. += "teg-oc[lastcirc]"


#define GENRATE 800 // generator output coefficient from Q

/obj/machinery/power/generator/process_atmos()
	if(!cold_circ || !hot_circ)
		return

	var/datum/gas_mixture/cold_air = cold_circ.return_transfer_air()
	var/datum/gas_mixture/hot_air = hot_circ.return_transfer_air()

	if(cold_air && hot_air)
		var/cold_air_heat_capacity = cold_air.heat_capacity()
		var/hot_air_heat_capacity = hot_air.heat_capacity()

		var/delta_temperature = hot_air.temperature - cold_air.temperature


		if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
			var/efficiency = 0.65

			var/energy_transfer = delta_temperature*hot_air_heat_capacity*cold_air_heat_capacity/(hot_air_heat_capacity+cold_air_heat_capacity)

			var/heat = energy_transfer*(1-efficiency)
			lastgen += energy_transfer*efficiency

			hot_air.temperature = hot_air.temperature - energy_transfer/hot_air_heat_capacity
			cold_air.temperature = cold_air.temperature + heat/cold_air_heat_capacity

	if(hot_air)
		var/datum/gas_mixture/hot_circ_air1 = hot_circ.airs[1]
		if(hot_circ.flipped)
			hot_circ_air1 = hot_circ.airs[2]
		hot_circ_air1.merge(hot_air)

	if(cold_air)
		var/datum/gas_mixture/cold_circ_air1 = cold_circ.airs[1]
		if(cold_circ.flipped)
			cold_circ_air1 = cold_circ.airs[2]
		cold_circ_air1.merge(cold_air)


	var/circ = "[cold_circ?.last_pressure_delta > 0 ? "1" : "0"][hot_circ?.last_pressure_delta > 0 ? "1" : "0"]"
	if(circ != lastcirc)
		lastcirc = circ

	update_appearance()

/obj/machinery/power/generator/process()
	//Setting this number higher just makes the change in power output slower, it doesnt actualy reduce power output cause **math**
	var/power_output = round(lastgen / 10)
	add_avail(power_output)
	lastgenlev = power_output
	lastgen -= power_output
	..()

/obj/machinery/power/generator/ui_interact(mob/user, datum/tgui/ui)
	if(panel_open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TEGenerator", name)
		ui.open()

/obj/machinery/power/generator/ui_data()
	var/list/data = list()
	data["output"] = lastgenlev

	var/datum/gas_mixture/cold_inlet_air = cold_circ.airs[1]
	var/datum/gas_mixture/cold_outlet_air = cold_circ.airs[2]
	var/datum/gas_mixture/hot_inlet_air = hot_circ.airs[1]
	var/datum/gas_mixture/hot_outlet_air = hot_circ.airs[2]

	if(cold_circ.flipped)
		cold_inlet_air = cold_circ.airs[2]
		cold_outlet_air = cold_circ.airs[1]
	if(hot_circ.flipped)
		hot_inlet_air = hot_circ.airs[2]
		hot_outlet_air = hot_circ.airs[1]

	data["cold"] = list()
	if(cold_circ)
		data["cold"]["inletPressure"] = cold_inlet_air.return_pressure()
		data["cold"]["inletTemperature"] = cold_inlet_air.temperature
		data["cold"]["outletPressure"] = cold_outlet_air.return_pressure()
		data["cold"]["outletTemperature"] = cold_outlet_air.temperature

	data["hot"] = list()
	if(hot_circ)
		data["hot"]["inletPressure"] = hot_inlet_air.return_pressure()
		data["hot"]["inletTemperature"] = hot_inlet_air.temperature
		data["hot"]["outletPressure"] = hot_outlet_air.return_pressure()
		data["hot"]["outletTemperature"] = hot_outlet_air.temperature

	return data

/obj/machinery/power/generator/proc/find_circs()
	kill_circs()
	var/list/circs = list()
	var/obj/machinery/atmospherics/components/binary/circulator/C
	var/circpath = /obj/machinery/atmospherics/components/binary/circulator
	if(dir == NORTH || dir == SOUTH)
		C = locate(circpath) in get_step(src, EAST)
		if(C && C.dir == NORTH)
			circs += C

		C = locate(circpath) in get_step(src, WEST)
		if(C && C.dir == SOUTH)
			circs += C
	else
		C = locate(circpath) in get_step(src, NORTH)
		if(C && C.dir == EAST)
			circs += C

		C = locate(circpath) in get_step(src, SOUTH)
		if(C && C.dir == SOUTH)
			circs += C

	if(circs.len)
		for(C in circs)
			if(C.mode == CIRCULATOR_COLD && !cold_circ)
				cold_circ = C
				C.generator = src
			else if(C.mode == CIRCULATOR_HOT && !hot_circ)
				hot_circ = C
				C.generator = src

/obj/machinery/power/generator/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!panel_open)
		return
	set_anchored(!anchored)
	I.play_tool_sound(src)
	if(!anchored)
		kill_circs()
	connect_to_network()
	to_chat(user, span_notice("You [anchored?"secure":"unsecure"] [src]."))
	return TRUE

/obj/machinery/power/generator/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(!anchored)
		return
	find_circs()
	to_chat(user, span_notice("You update [src]'s circulator links."))
	return TRUE

/obj/machinery/power/generator/screwdriver_act(mob/user, obj/item/I)
	if(..())
		return TRUE
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, span_notice("You [panel_open?"open":"close"] the panel on [src]."))
	return TRUE

/obj/machinery/power/generator/crowbar_act(mob/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/power/generator/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/machinery/power/generator/on_deconstruction()
	kill_circs()

/obj/machinery/power/generator/proc/kill_circs()
	if(hot_circ)
		hot_circ.generator = null
		hot_circ = null
	if(cold_circ)
		cold_circ.generator = null
		cold_circ = null
