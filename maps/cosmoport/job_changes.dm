// CosmoPort
#define JOB_MODIFICATION_MAP_NAME "CosmoPort"

//SYND OPERATIVE

/datum/job/hos/New()
	..()
	MAP_JOB_CHECK

	//name = OUTFIT_JOB_NAME("Syndicat Space Ops") //Zatestit'
	title = "Syndicat Space Op" //Zatestit'
	//flag = Synd
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 10
	spawn_positions = 10
	supervisors = "Supreme Council of the Syndicat"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/centcom
	access = list() //access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access() //Zatestit'
	salary = 1001
	minimal_player_ingame_minutes = 11001

	//Only humans (balance)
	/datum/job/hos/special_species_check(datum/species/S)
		return S.name == HUMAN

	/datum/job/hos/get_access()
	return get_all_accesses()


/datum/outfit/job/hos/New()
	..()
	MAP_JOB_CHECK_BASE

	name = OUTFIT_JOB_NAME("Syndicat Space Op")

	uniform = /obj/item/clothing/under/acj/special
	uniform_f = /obj/item/clothing/under/acj/special_fem
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/syndicate
	id = /obj/item/weapon/card/id/syndicate/all_access
	glasses = /obj/item/clothing/glasses/sunglasses/hud/secmed

	belt = /obj/item/weapon/storage/belt/military

	l_pocket = /obj/item/device/flashlight/seclite
	r_pocket = /obj/item/weapon/melee/energy/sword

	l_hand = /obj/item/weapon/gun/projectile/automatic/pistol
	r_hand = /obj/item/device/radio/uplink

	implants = list(/obj/item/weapon/implant/dexplosive)

	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/weapon/reagent_containers/pill/cyanide
		)
	survival_box = FALSE

//NT OPERATIVE

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK

	//access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()

	title = "NanoTrasen Space Op"
	//flag = NT
	total_positions = 10
	spawn_positions = 10
	supervisors = "Supreme Council of the NanoTrasen"
	idtype = /obj/item/weapon/card/id/centcom
	//access = list() //Captain already has full access
	salary = 1000
	minimal_player_ingame_minutes = 11000


/datum/outfit/job/captain/New()
	..()
	MAP_JOB_CHECK_BASE

	name = OUTFIT_JOB_NAME("NanoTrasen Space Op")

	uniform = /obj/item/clothing/under/acj/special
	uniform_f = /obj/item/clothing/under/acj/special_fem
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/ert
	glasses = /obj/item/clothing/glasses/sunglasses/hud/secmed
	id = /obj/item/weapon/card/id/centcom/ert

	belt = /obj/item/weapon/storage/belt/military

	l_pocket = /obj/item/device/flashlight/seclite
	r_pocket = /obj/item/weapon/melee/energy/sword

	l_hand = /obj/item/weapon/gun/projectile/automatic/pistol
	r_hand = /obj/item/device/radio/uplink

	implants = list(/obj/item/weapon/implant/mindshield/loyalty, /obj/item/weapon/implant/dexplosive)

	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/weapon/reagent_containers/pill/cyanide
		)
	survival_box = FALSE


//CIVILIAN

/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK

	//name = OUTFIT_JOB_NAME("NanoTrasen Space Ops")
	//title = "NanoTrasen Space Ops DWA" //Zatestit'
	//access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()

	title = "Civilian"
	//flag = NT
	total_positions = 6
	spawn_positions = 6
	supervisors = "Supreme Council of the NanoTrasen"
	idtype = /obj/item/weapon/card/id/centcom
	//access = list() //See get_access()
	salary = 1000
	minimal_player_age = 14
	minimal_player_ingame_minutes = 11000
	//outfit = /datum/outfit/job/nt_space_op

	//Only humans (balance)
	///datum/job/nt_space_op/special_species_check(datum/species/S)
		//return S.name == HUMAN

	///datum/job/nt_space_op/get_access()
	//return get_all_accesses()



/datum/outfit/job/bartender/New()
	..()
	MAP_JOB_CHECK_BASE

	name = OUTFIT_JOB_NAME("Civilian")

	uniform = /obj/item/clothing/under/acj/special
	uniform_f = /obj/item/clothing/under/acj/special_fem
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/ert
	glasses = /obj/item/clothing/glasses/sunglasses/hud/secmed
	id = /obj/item/weapon/card/id/centcom/ert

	belt = /obj/item/weapon/storage/belt/military

	l_pocket = /obj/item/device/flashlight/seclite
	r_pocket = /obj/item/weapon/melee/energy/sword

	l_hand = /obj/item/weapon/gun/projectile/automatic/pistol
	r_hand = /obj/item/device/radio/uplink

	implants = list(/obj/item/weapon/implant/mindshield/loyalty, /obj/item/weapon/implant/dexplosive)

	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/weapon/reagent_containers/pill/cyanide
		)
	survival_box = FALSE


/*/datum/job/captain/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	MAP_JOB_CHECK_BASE

	if(!H)
		return 0

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)

	..()
*/

/*

//NT OPERATIVE
/datum/job/nt_space_op
	title = "NanoTrasen Space Operative"
	//flag = NT
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 6
	spawn_positions = 6
	supervisors = "Supreme Council of the NanoTrasen"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/centcom
	access = list() //See get_access()
	salary = 1000
	minimal_player_age = 14
	minimal_player_ingame_minutes = 11000
	outfit = /datum/outfit/job/nt_space_op

	//Only humans (balance)
	/datum/job/nt_space_op/special_species_check(datum/species/S)
		return S.name == HUMAN

	/datum/job/nt_space_op/get_access()
	return get_all_accesses()


/datum/outfit/job/nt_space_op
	name = OUTFIT_JOB_NAME("NanoTrasen Space Operative")

	uniform = /obj/item/clothing/under/acj/special
	uniform_f = /obj/item/clothing/under/acj/special_fem
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/ert
	id = /obj/item/weapon/card/id/centcom/ert
	glasses = /obj/item/clothing/glasses/sunglasses/hud/secmed

	belt = /obj/item/weapon/storage/belt/military
	belt_contents = list(
		/obj/item/weapon/gun/projectile/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
		)
	l_pocket_back = /obj/item/device/flashlight/seclite
	r_pocket = /obj/item/weapon/melee/energy/sword

	implants = list(/obj/item/weapon/implant/mindshield/loyalty, /obj/item/weapon/implant/dexplosive)

	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/device/radio/uplink,
		/obj/item/weapon/reagent_containers/pill/cyanide,
		)
	survival_box = FALSE

//SYND OPERATIVE
/datum/job/synd_space_op
	title = "Syndicat Space Operative"
	//flag = Synd
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 6
	spawn_positions = 6
	supervisors = "Supreme Council of the Syndicat"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/centcom
	access = list()
	salary = 1001
	minimal_player_age = 14
	minimal_player_ingame_minutes = 11001
	outfit = /datum/outfit/job/synd_space_op

	//Only humans (balance)
	/datum/job/synd_space_op/special_species_check(datum/species/S)
		return S.name == HUMAN

	/datum/job/synd_space_op/get_access()
	return get_all_accesses()


/datum/outfit/job/synd_space_op
	name = OUTFIT_JOB_NAME("Syndicat Space Operative")

	uniform = /obj/item/clothing/under/acj/special
	uniform_f = /obj/item/clothing/under/acj/special_fem
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/syndicate
	id = /obj/item/weapon/card/id/syndicate/all_access
	glasses = /obj/item/clothing/glasses/sunglasses/hud/secmed

	belt = /obj/item/weapon/storage/belt/military
	belt_contents = list(
		/obj/item/weapon/gun/projectile/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
		)
	l_pocket_back = /obj/item/device/flashlight/seclite
	r_pocket = /obj/item/weapon/melee/energy/sword

	implants = list(/obj/item/weapon/implant/dexplosive)

	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/device/radio/uplink,
		/obj/item/weapon/reagent_containers/pill/cyanide,
		)
	survival_box = FALSE
*/

///////////////////////////////////////////////
//Remove all Jobs
///////////////////////////////////////////////

// Assistant
MAP_REMOVE_JOB(assistant)

// Cargo
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(cargo_tech)
MAP_REMOVE_JOB(mining)
MAP_REMOVE_JOB(recycler)

// Civilian
//MAP_REMOVE_JOB(bartender) - Staff member, Civilian
MAP_REMOVE_JOB(chef)
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(janitor)
MAP_REMOVE_JOB(barber)
MAP_REMOVE_JOB(stylist)
MAP_REMOVE_JOB(librarian)
MAP_REMOVE_JOB(lawyer) //Internal Affairs Agent (make he spectator?)
MAP_REMOVE_JOB(clown)
MAP_REMOVE_JOB(mime)
MAP_REMOVE_JOB(chaplain)

// Command
MAP_REMOVE_JOB(hop)

// Engineering
MAP_REMOVE_JOB(chief_engineer)
MAP_REMOVE_JOB(engineer)
MAP_REMOVE_JOB(atmos)
MAP_REMOVE_JOB(technical_assistant)

// Medical
MAP_REMOVE_JOB(cmo)
MAP_REMOVE_JOB(doctor)
MAP_REMOVE_JOB(surgeon)
MAP_REMOVE_JOB(nurse)
MAP_REMOVE_JOB(paramedic)
MAP_REMOVE_JOB(chemist)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(psychiatrist)
MAP_REMOVE_JOB(psychologist)
MAP_REMOVE_JOB(intern)

// Science
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(scientist)
MAP_REMOVE_JOB(xenoarchaeologist)
MAP_REMOVE_JOB(xenobiologist)
MAP_REMOVE_JOB(roboticist)
MAP_REMOVE_JOB(research_assistant)

// Security
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(officer)
MAP_REMOVE_JOB(forensic)
MAP_REMOVE_JOB(cadet)

// Silicon
MAP_REMOVE_JOB(ai)
MAP_REMOVE_JOB(cyborg)
