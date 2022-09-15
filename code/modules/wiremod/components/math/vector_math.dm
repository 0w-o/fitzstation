#define COMP_VECTOR_LENGTH "Length"
#define COMP_VECTOR_SUBTRACT "Subtract"
#define COMP_VECTOR_DIVIDE "Divide"
#define COMP_VECTOR_NORMALIZE "Normalize"

/obj/item/circuit_component/vector_math
	display_name = "Vector Math"
	desc = "Vector math component with vector math capabilities."
	category = "Math"

	var/datum/port/input/option/arithmetic_option

	/// The result from the output
	var/datum/port/output/output_x
	var/datum/port/output/output_y

	var/list/arithmetic_ports
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/vector_math/populate_options()
	var/static/component_options = list(
		COMP_VECTOR_LENGTH,
		COMP_VECTOR_SUBTRACT,
		COMP_VECTOR_DIVIDE,
		COMP_VECTOR_NORMALIZE,
	)
	arithmetic_option = add_option_port("Operation", component_options)

/obj/item/circuit_component/vector_math/populate_ports()
	arithmetic_ports = list()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = arithmetic_ports, \
		port_type = PORT_TYPE_NUMBER, \
		prefix = "Port", \
		minimum_amount = 4 \
	)
	output_x = add_output_port("X", PORT_TYPE_NUMBER, order = 1.1)
	output_y = add_output_port("Y", PORT_TYPE_NUMBER, order = 1.2)

/obj/item/circuit_component/vector_math/input_received(datum/port/input/port)
	var/list/ports = arithmetic_ports.Copy()

	var/datum/port/input/port_x = popleft(ports)
	var/datum/port/input/port_y = popleft(ports)
	var/datum/port/input/port_b_x = popleft(ports)
	var/datum/port/input/port_b_y = popleft(ports)

	var/result_x
	var/result_y

	if(!isnull(port_x) && !isnull(port_y))
		result_x = port_x.value
		result_y = port_y.value

		if (!isnull(port_b_x) && !isnull(port_b_y))
			var/input_b_x = port_b_x.value
			var/input_b_y = port_b_y.value

			switch(arithmetic_option.value)
				if(COMP_VECTOR_SUBTRACT)
					result_x -= input_b_x
					result_y -= input_b_y

				if(COMP_VECTOR_DIVIDE)
					// protect against div0
					if(input_b_x == 0 || input_b_y == 0)
						result_x = null
						result_y = null
					else
						result_x /= input_b_x
						result_y /= input_b_y

		else
			switch(arithmetic_option.value)
				if(COMP_VECTOR_LENGTH)
					result_x = sqrt(result_x*result_x + result_y*result_y)
					result_y = null

				if(COMP_VECTOR_NORMALIZE)
					var/vec_length = sqrt(result_x*result_x + result_y*result_y)
					if(vec_length == 0)
						vec_length = 1

					result_x /= vec_length
					result_y /= vec_length

	output_x.set_output(result_x)
	output_y.set_output(result_y)

#undef COMP_VECTOR_LENGTH
#undef COMP_VECTOR_SUBTRACT
#undef COMP_VECTOR_DIVIDE
#undef COMP_VECTOR_NORMALIZE
