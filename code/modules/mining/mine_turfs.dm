#define MIN_TUNNEL_LENGTH 20
#define MAX_TUNNEL_LENGTH 60
#define DISTANCE_BEETWEEN_MOSTERS 16
#define CRATE_DROP_CHANCE 0.5 // 1 in 200

/**********************Mineral deposits**************************/
/turf/simulated/mineral
	name = "Rock"
	icon = 'icons/turf/asteroid.dmi'
	icon_state = "rock"
	oxygen = 0
	nitrogen = 0

	opacity = 1
	density = TRUE
	blocks_air = 1
	temperature = TCMB

	hud_possible = list(MINE_MINERAL_HUD, MINE_ARTIFACT_HUD)
	var/mineral/mineral
	var/mined_ore = 0
	basetype = /turf/simulated/floor/plating/airless/asteroid
	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds
	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find

	var/ore_amount = 0

	has_resources = TRUE

	var/global/list/rock_side_overlays

/turf/simulated/mineral/atom_init(mapload)
	. = ..()
	icon_state = "rock"
	geologic_data = new(src)
	if(!rock_side_overlays)
		rock_side_overlays = list(null, null, null, null, null, null, null, null, null) // 9 nulls to create dir -> appearance list
		for(var/direction_to_check in cardinal)
			var/mutable_appearance/MA = mutable_appearance('icons/turf/asteroid.dmi', "rock_side_[direction_to_check]", 6, FLOOR_PLANE)
			rock_side_overlays[direction_to_check] = MA

	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	update_overlays_full()
	return .

/turf/simulated/mineral/atom_init_late()
	MineralSpread()
	update_overlays()

/turf/simulated/mineral/update_overlays()
	cut_overlays()
	if(!mineral || ore_amount < 8)
		name = "Rock"
		icon_state = "rock"
	else
		name = "[mineral.display_name] rich deposit"
		add_overlay("rock_[mineral.name]")
	if(excav_overlay)
		add_overlay(excav_overlay)
	if(archaeo_overlay)
		add_overlay(archaeo_overlay)
	var/turf/T
	for(var/direction_to_check in cardinal)
		T = get_step(src, direction_to_check)
		if(isfloorturf(T) || isenvironmentturf(T) || istype(T, /turf/simulated/shuttle/floor))
			T.add_overlay(rock_side_overlays[direction_to_check])

	if(excav_overlay || archaeo_overlay || mineral)
		update_hud()

/turf/simulated/mineral/proc/update_hud()
	if(hud_list)
		return
	prepare_huds()
	var/datum/atom_hud/mine/mine = global.huds[DATA_HUD_MINER]
	mine.add_to_hud(src)
	set_mine_hud()

/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(30))
				return
		if(EXPLODE_LIGHT)
			return
	mined_ore = 3 - severity
	GetDrilled()
/turf/simulated/mineral/Bumped(AM)
	. = ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(istype(H.l_hand, /obj/item/weapon/pickaxe))
			attackby(H.l_hand, H)
		else if(istype(H.r_hand, /obj/item/weapon/pickaxe))
			attackby(H.r_hand, H)

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active, /obj/item/weapon/pickaxe))
			attackby(R.module_active, R)

	else if(istype(AM, /obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected, /obj/item/mecha_parts/mecha_equipment/drill))
			M.selected.action(src)

/turf/simulated/mineral/proc/MineralSpread()
	if(mineral?.spread)
		for(var/trydir in cardinal)
			if(prob(mineral.spread_chance))
				var/turf/simulated/mineral/random/target_turf = get_step(src, trydir)
				if(istype(target_turf) && !target_turf.mineral)
					target_turf.mineral = mineral
					target_turf.UpdateMineral()
					target_turf.MineralSpread()

/turf/simulated/mineral/proc/UpdateMineral()
	if(!mineral)
		name = "Rock"
		icon_state = "rock"
		return
	else
		if(prob(15))
			ore_amount = rand(7, 9)
		else if(prob(45))
			ore_amount = rand(5, 7)
		else
			ore_amount = rand(3, 5)
	if(ore_amount >= 8)
		name = "[mineral.display_name] rich deposit"
		cut_overlays()
		add_overlay("rock_[mineral.name]")
	else
		name = "Rock"
		icon_state = "rock"

	update_hud()

/turf/simulated/mineral/proc/CaveSpread()	//Integration of cave system
	if(mineral)
		for(var/trydir in cardinal)
			var/turf/simulated/mineral/random/target_turf = get_step(src, trydir)
			if(istype(target_turf, /turf/simulated/mineral/random/caves))
				if(prob(2))
					if(SSticker.current_state > GAME_STATE_SETTING_UP)
						ChangeTurf(/turf/simulated/floor/plating/airless/asteroid/cave)
					else
						new/turf/simulated/floor/plating/airless/asteroid/cave(src)

//Not even going to touch this pile of spaghetti
/turf/simulated/mineral/attackby(obj/item/weapon/W, mob/user)
	user.SetNextMove(CLICK_CD_RAPID)

	if (user.is_busy(src))
		return

	if (istype(W, /obj/item/device/core_sampler))
		geologic_data.UpdateNearbyArtifactInfo(src)
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("<span class='notice'>[user] extends [P] towards [src].</span>","<span class='notice'>You extend [P] towards [src].</span>")
		if(W.use_tool(src, user, 2.5 SECONDS, volume = 50))
			to_chat(user, "<span class='notice'>[bicon(P)] [src] has been excavated to a depth of [2*excavation_level]cm.</span>")
		return

	if (istype(W, /obj/item/weapon/sledgehammer))
		var/obj/item/weapon/sledgehammer/S = W
		if(HAS_TRAIT(S, TRAIT_DOUBLE_WIELDED))
			user.do_attack_animation(src)
			shake_camera(user, 1, 0.37)
			playsound(src, 'sound/misc/sledgehammer_hit_rock.ogg', VOL_EFFECTS_MASTER)
			GetDrilled(artifact_fail = 1, mineral_drop_coefficient = 0.7)
		else
			to_chat(user, "<span class='warning'>You need to take it with both hands to break it!</span>")

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!isturf(T))
			return

		var/obj/item/weapon/pickaxe/P = W
		if(istype(P, /obj/item/weapon/pickaxe/drill))
			var/obj/item/weapon/pickaxe/drill/D = P
			if(!(istype(D, /obj/item/weapon/pickaxe/drill/borgdrill) || istype(D, /obj/item/weapon/pickaxe/drill/jackhammer)))	//borgdrill & jackhammer can't lose energy and crit fail
				if(D.state)
					to_chat(user, "<span class='danger'>[D] is not ready!</span>")
					return
				if(!D.power_supply?.use(D.drill_cost))
					to_chat(user, "<span class='danger'>No power!</span>")
					return

		// handle any archaeological finds we might uncover
		var/fail_message
		if(length(finds))
			var/datum/find/F = finds[1]
			if(excavation_level + P.excavation_amount > F.excavation_required)
				// Chance to destroy / extract any finds here
				fail_message = ", <b>[pick("there is a crunching noise","[W] collides with some different rock","part of the rock face crumbles away","something breaks under [W]")]</b>"

		to_chat(user, "<span class='warning'>You start [P.drill_verb][fail_message ? fail_message : ""].</span>")

		if(fail_message && prob(90))
			if(prob(25))
				excavate_find(5, finds[1])
			else if(prob(50))
				finds.Remove(finds[1])
				set_mine_hud()
				if(prob(50))
					artifact_debris()

		if(P.use_tool(src, user, 50, volume = 100))
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/BPHand = H.get_bodypart(H.hand ? BP_L_ARM : BP_R_ARM)
				BPHand.adjust_pumped(0.1, 30)
			to_chat(user, "<span class='notice'>You finish [P.drill_verb] the rock.</span>")

			if(istype(P, /obj/item/weapon/pickaxe/drill/jackhammer))	//Jackhammer will just dig 3 tiles in dir of user
				for(var/turf/simulated/mineral/M in range(user, 1))
					if(get_dir(user, M) & user.dir)
						M.GetDrilled()
				return

			if(length(finds))
				var/datum/find/F = finds[1]
				if(round(excavation_level + P.excavation_amount) == F.excavation_required)
					//Chance to extract any items here perfectly, otherwise just pull them out along with the rock surrounding them
					if(excavation_level + P.excavation_amount > F.excavation_required)
						//if you can get slightly over, perfect extraction
						excavate_find(100, F)
					else
						excavate_find(80, F)

				else if(excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)
					//just pull the surrounding rock out
					excavate_find(0, F)

			if( excavation_level + P.excavation_amount >= 100 )
				// if players have been excavating this turf, leave some rocky debris behind
				var/obj/structure/boulder/B
				if(artifact_find)
					if( excavation_level > 0 || prob(15) )
						// boulder with an artifact inside
						B = new(src)
						if(artifact_find)
							B.artifact_find = artifact_find
					else
						artifact_debris(1)
				else if(prob(15))
					// empty boulder
					B = new(src)

				if(B)
					GetDrilled(0)
				else
					GetDrilled(1)
				return

			excavation_level += P.excavation_amount

			// archaeo overlays
			if(!archaeo_overlay && finds && finds.len)
				var/datum/find/F = finds[1]
				if(F.excavation_required <= excavation_level + F.view_range)
					archaeo_overlay = "overlay_archaeo[rand(1,3)]"
					add_overlay(archaeo_overlay)

			// there's got to be a better way to do this
			var/update_excav_overlay = 0
			if(excavation_level >= 75)
				if(excavation_level - P.excavation_amount < 75)
					update_excav_overlay = 1
			else if(excavation_level >= 50)
				if(excavation_level - P.excavation_amount < 50)
					update_excav_overlay = 1
			else if(excavation_level >= 25)
				if(excavation_level - P.excavation_amount < 25)
					update_excav_overlay = 1

			// update overlays displaying excavation level
			if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
				var/excav_quadrant = round(excavation_level / 25) + 1
				excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
				add_overlay(excav_overlay)

			// drop some rocks
			next_rock += P.excavation_amount * 10
			while(next_rock > 100)
				next_rock -= 100
				var/obj/item/weapon/ore/O = new(src)
				geologic_data.UpdateNearbyArtifactInfo(src)
				O.geologic_data = geologic_data

	else
		return attack_hand(user)


/turf/simulated/mineral/proc/DropMineral()
	if(!mineral)
		return

	var/obj/item/weapon/ore/O = new mineral.ore (src)
	if(istype(O))
		geologic_data.UpdateNearbyArtifactInfo(src)
		O.geologic_data = geologic_data
	return O


/turf/simulated/mineral/proc/GetDrilled(artifact_fail = 0, mineral_drop_coefficient = 1)
	playsound(src, 'sound/effects/rockfall.ogg', VOL_EFFECTS_MASTER)
	// var/destroyed = 0 //used for breaking strange rocks
	if (mineral && ore_amount)
		
		// if the turf has already been excavated, some of it's ore has been removed
		for (var/i = 1 to round((ore_amount - mined_ore) * mineral_drop_coefficient, 1))
			DropMineral()

	// destroyed artifacts have weird, unpleasant effects
	// make sure to destroy them before changing the turf though
	if(artifact_find && artifact_fail)
		var/pain = 0
		if(prob(50))
			pain = 1
		for(var/mob/living/M in range(src, 200))
			to_chat(M, "<span class='danger'>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</span>")
			if(pain)
				if(prob(50))
					M.adjustBruteLoss(5)
			else
				M.flash_eyes()
				if(prob(50))
					M.Stun(5)
			M.apply_effect(25, IRRADIATE)


	var/datum/atom_hud/mine/mine = global.huds[DATA_HUD_MINER]
	if(src in mine.hudatoms)
		mine.remove_from_hud(src)

	var/turf/N = ChangeTurf(basetype)
	N.update_overlays_full()

	if(prob(CRATE_DROP_CHANCE))
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		new /obj/structure/closet/crate/secure/loot(src)

/turf/simulated/mineral/proc/excavate_find(prob_clean = 0, datum/find/F)
	//with skill and luck, players can cleanly extract finds
	//otherwise, they come out inside a chunk of rock
	var/obj/item/weapon/W
	if(prob_clean)
		W = new /obj/item/weapon/archaeological_find(src, F.find_type)
	else
		W = new /obj/item/weapon/ore/strangerock(src, F.find_type)
		geologic_data.UpdateNearbyArtifactInfo(src)
		W:geologic_data = geologic_data

	//some find types delete the /obj/item/weapon/archaeological_find and replace it with something else, this handles when that happens
	//yuck
	var/display_name = "something"
	if(!W)
		W = last_find
	if(W)
		display_name = W.name

	//many finds are ancient and thus very delicate - luckily there is a specialised energy suspension field which protects them when they're being extracted
	if(prob(F.prob_delicate))
		var/obj/effect/suspension_field/S = locate() in src
		if(!S || S.field_type != get_responsive_reagent(F.find_type))
			if(W)
				visible_message("<span class='danger'>[pick("[display_name] crumbles away into dust","[display_name] breaks apart")].</span>")
				qdel(W)

	finds.Remove(F)
	set_mine_hud()


/turf/simulated/mineral/proc/artifact_debris(severity = 0)
	//cael's patented random limited drop componentized loot system!
	//sky's patented not-fucking-retarded overhaul!

	//Give a random amount of loot from 1 to 3 or 5, varying on severity.
	for(var/j in 1 to rand(1, 3 + max(min(severity, 1), 0) * 2))
		switch(rand(1, 7))
			if(1)
				new/obj/item/stack/rods(src, rand(5,25))

			if(2)
				new/obj/item/stack/tile/plasteel(src, rand(1,5))

			if(3)
				new/obj/item/stack/sheet/metal(src, rand(5,25))

			if(4)
				new/obj/item/stack/sheet/plasteel(src, rand(5,25))

			if(5)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/weapon/shard(src)

			if(6)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/weapon/shard/phoron(src)

			if(7)
				new/obj/item/stack/sheet/mineral/uranium(src, rand(5,25))

//this fucking caves works very badly with afterinit mapload (and with atominit generally)
//todo: move cavespread from atominit for side trigger?
/turf/simulated/mineral/random
	name = "Mineral deposit"
	icon_state = "rock"

	var/mineralSpawnChanceList = list("Phoron" = 25, "Iron" = 20, "Coal" = 15, "Silver" = 15, "Gold" = 15, "Uranium" = 10, "Platinum" = 10, "Diamond" = 5)
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

/turf/simulated/mineral/random/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/mineral/random/atom_init_late()
	if (prob(mineralChance) && !mineral)
		var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name

		if(!name_to_mineral)
			SetupMinerals()

		if (mineral_name && (mineral_name in name_to_mineral))
			mineral = name_to_mineral[mineral_name]
			UpdateMineral()
			CaveSpread()
	. = ..()

/turf/simulated/mineral/random/caves
	mineralChance = 25

/turf/simulated/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 40
	mineralSpawnChanceList = list("Phoron" = 50, "Silver" = 50, "Gold" = 45, "Uranium" = 35, "Platinum" = 45, "Diamond" = 30)

/turf/simulated/mineral/random/high_chance/atom_init()
	icon_state = "rock"
	. = ..()

/turf/simulated/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 5
	mineralSpawnChanceList = list("Phoron" = 1, "Iron" = 33, "Coal" = 20, "Silver" = 1, "Gold" = 1, "Uranium" = 1,  "Platinum" = 1, "Diamond" = 1)

/turf/simulated/mineral/random/low_chance/atom_init()
	icon_state = "rock"
	. = ..()

/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list("Phoron" = 2, "Iron" = 28, "Coal" = 17, "Silver" = 1, "Gold" = 1, "Uranium" = 1, "Platinum" = 2, "Diamond" = 1)
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/atom_init()
	icon_state = "rock"
	. = ..()

/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user)
	..()
	if(user.environment_smash >= 2)
		GetDrilled(mineral_drop_coefficient = 0.5)

/**********************Caves**************************/
/turf/simulated/floor/plating/airless/asteroid
	basetype = /turf/simulated/floor/plating/airless/asteroid
	can_deconstruct = FALSE

/turf/simulated/floor/plating/airless/asteroid/cave
	var/length = 20
	var/sanity = TRUE

/turf/simulated/floor/plating/airless/asteroid/cave/atom_init(mapload, length, go_backwards = 1, exclude_dir = -1)
	if(!length)
		src.length = rand(MIN_TUNNEL_LENGTH, MAX_TUNNEL_LENGTH)
	else
		src.length = length

	// Get our directiosn
	var/forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	var/backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(go_backwards)
		make_tunnel(backward_cave_dir)

	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/floor/plating/airless/asteroid/cave/atom_init_late()
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)

/turf/simulated/floor/plating/airless/asteroid/cave/proc/make_tunnel(dir)

	var/turf/simulated/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IS_ODD(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/simulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				if(SSticker.current_state > GAME_STATE_SETTING_UP)
					var/list/arguments = list(tunnel, rand(10, 15), 0, dir)
					ChangeTurf(src.type, arguments)
				else
					new type(tunnel, rand(10, 15), 0, dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			dir = angle2dir(dir2angle(dir) + next_angle)

/turf/simulated/floor/plating/airless/asteroid/cave/proc/SpawnFloor(turf/T)
	for(var/turf/S in range(2, T))
		if(isenvironmentturf(S) || istype(S.loc, /area/asteroid/mine/explored))
			sanity = FALSE
			break

	if(!sanity)
		return

	if(prob(6))
		if(istype(loc, /area/asteroid/mine/explored))
			return
		for(var/obj/machinery/artifact/bluespace_crystal/BC in range(DISTANCE_BEETWEEN_MOSTERS, T)) //Lowers chance of crystal clumps
			return
		new /obj/machinery/artifact/bluespace_crystal(T)

	var/turf/t
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		t = new basetype(T)
	else
		t = T.ChangeTurf(basetype)
	spawn(2)
		t.update_overlays_full()

/**********************Asteroid**************************/

/turf/simulated/floor/plating/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'icons/turf/asteroid.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	var/dug = FALSE       //FALSE = has not yet been dug, TRUE = has already been dug
	has_resources = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_SAND

/turf/simulated/floor/plating/airless/asteroid/atom_init()
	var/proper_name = name
	..()
	name = proper_name
	if(prob(20))
		icon_state = "asteroid_stone_[rand(1, 10)]"

	//I dont know how, but it gets into hudatoms
	var/datum/atom_hud/mine/mine = global.huds[DATA_HUD_MINER]
	if(src in mine.hudatoms)
		mine.remove_from_hud(src)

	return INITIALIZE_HINT_LATELOAD

/turf/proc/update_overlays()
	cut_overlays()

	for(var/direction_to_check in cardinal)
		var/turf/simulated/mineral/T = get_step(src, direction_to_check)
		if(istype(T))
			add_overlay(T.rock_side_overlays[reverse_dir[direction_to_check]])

/turf/simulated/floor/plating/airless/asteroid/update_overlays()
	..()
	var/turf/T
	for(var/direction_to_check in cardinal)
		T = get_step(src, direction_to_check)
		if(T && isspaceturf(T))
			var/lattice = locate(/obj/structure/lattice) in T
			if(!lattice)
				var/image/I = image('icons/turf/asteroid.dmi', "asteroid_edge_[direction_to_check]")
				add_overlay(I)

/turf/proc/update_overlays_full()
	var/turf/A
	for(var/newdir in cardinal)
		A = get_step(src, newdir)
		A.update_overlays()
	update_overlays()

/turf/simulated/floor/plating/airless/asteroid/atom_init_late()
	update_overlays()

/turf/simulated/floor/plating/airless/asteroid/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(30))
				return
		if(EXPLODE_LIGHT)
			return
	gets_dug()

/turf/simulated/floor/plating/airless/asteroid/attackby(obj/item/weapon/W, mob/user)

	if(!W || !user)
		return 0

	if (istype(W, /obj/item/weapon/shovel))
		var/turf/T = user.loc
		if(!isturf(T))
			return

		if (dug)
			to_chat(user, "<span class='danger'>This area has already been dug.</span>")
			return
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='warning'>You start digging.</span>")
		if(W.use_tool(src, user, 3.5 SECONDS, volume = 100))
			if((user.loc == T && user.get_active_hand() == W))
				to_chat(user, "<span class='notice'>You dug a hole.</span>")
				gets_dug()

	else if(istype(W, /obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/ore/O in contents)
				O.attackby(W,user)
				return
	else if(istype(W, /obj/item/weapon/storage/bag/fossils))
		var/obj/item/weapon/storage/bag/fossils/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/fossil/F in contents)
				F.attackby(W,user)
				return

	else
		..()

/turf/simulated/floor/plating/airless/asteroid/proc/gets_dug()
	if(dug)
		return
	for(var/i in 1 to rand(3, 6))
		new /obj/item/weapon/ore/glass(src)
	dug = TRUE
	icon_plating = "asteroid_dug"
	icon_state = "asteroid_dug"

/turf/simulated/floor/plating/airless/asteroid/Entered(atom/movable/M)
	..()
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(istype(R.module, /obj/item/weapon/robot_module/miner))
			if(istype(R.module_state_1,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_1,R)
			else if(istype(R.module_state_2,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_2,R)
			else if(istype(R.module_state_3,/obj/item/weapon/storage/bag/ore))
				attackby(R.module_state_3,R)
			else
				return

#undef MIN_TUNNEL_LENGTH
#undef MAX_TUNNEL_LENGTH
#undef DISTANCE_BEETWEEN_MOSTERS
#undef CRATE_DROP_CHANCE
