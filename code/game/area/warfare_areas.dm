/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/

/*-----------------------------------------------------------------------------*/

//Warfare Main Area

/area/warfare
	icon = 'icons/turf/areas_warfare.dmi'
	icon_state = "warfare"

//Syndicat Battle Ship

/area/warfare/syndicat
	looped_ambience = 'sound/ambience/syndicate_station.ogg'

/area/warfare/syndicat/battleship
	icon_state = "syndie_battle_ship"

/area/warfare/syndicat/battleship/hangar
	name = "Syndicat Battle Ship Hangar"
	icon_state = "syndie_hangar"

/area/warfare/syndicat/battleship/central_hallway
	name = "Syndicat Battle Ship Central Hallway"
	icon_state = "syndie_central_hallway"

/area/warfare/syndicat/battleship/east_hallway
	name = "Syndicat Battle Ship East Hallway"
	icon_state = "syndie_east_hallway"

//NanoTrasen Battle Ship

/area/warfare/nanotrasen
	looped_ambience = 'sound/ambience/syndicate_station.ogg'