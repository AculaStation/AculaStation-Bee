/obj/machinery/atmospherics/pipe/simple/multiz ///This is an atmospherics pipe which can relay air up a deck (Z+1). It currently only supports being on pipe layer 1
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon_state = "multiz_pipe"
	icon = 'icons/obj/atmos.dmi'
	level = 2 //Always visible.

/obj/machinery/atmospherics/pipe/simple/multiz/layer1
	piping_layer = 1

/obj/machinery/atmospherics/pipe/simple/multiz/layer3
	piping_layer = 3

/obj/machinery/atmospherics/pipe/simple/multiz/update_icon()
	. = ..()
	cut_overlays() //This adds the overlay showing it's a multiz pipe. This should go above turfs and such
	var/image/multiz_overlay_node = new(src) //If we have a firing state, light em up!
	multiz_overlay_node.icon = 'icons/obj/atmos.dmi'
	multiz_overlay_node.icon_state = "multiz_pipe-[piping_layer]"
	multiz_overlay_node.layer = HIGH_OBJ_LAYER
	add_overlay(multiz_overlay_node)

///Attempts to locate a multiz pipe that's above us, if it finds one it merges us into its pipenet
/obj/machinery/atmospherics/pipe/simple/multiz/pipeline_expansion(expand_up = TRUE, expand_down = TRUE)
	icon = 'icons/obj/atmos.dmi' //Just to refresh.
	var/turf/T = get_turf(src)
	//Expand above pipes recursively
	if(SSmapping.get_turf_above(T) && expand_up)
		for(var/obj/machinery/atmospherics/pipe/simple/multiz/above in SSmapping.get_turf_above(T))
			if(above.piping_layer == piping_layer)
				//Link ourself to the above node
				nodes |= above
				above.nodes |= src
				//Link above node to their above nodes.
				above.pipeline_expansion(TRUE, FALSE)
	//Expand below pipes recursively
	if(SSmapping.get_turf_below(T) && expand_down)
		for(var/obj/machinery/atmospherics/pipe/simple/multiz/below in SSmapping.get_turf_below(T))
			if(below.piping_layer == piping_layer)
				//Link ourself to the below node
				nodes |= below
				below.nodes |= src
				//Link below node to their below nodes
				below.pipeline_expansion(FALSE, TRUE)
	return ..()
