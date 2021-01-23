/obj/structure/cult/tech_table
	name = "scientific altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "techaltar"
	light_color = "#2f0e0e"
	light_power = 2
	light_range = 3

	// /datum/aspect = image
	// Maybe be wrapped too in /datum/building_agent
	var/static/list/aspect_images = list()
	// /datum/building_agent = image
	var/static/list/uniq_images = list()
	// string = image
	var/static/list/category_images = list()
	var/researching = FALSE
	var/research_time = 20 MINUTES
	var/end_research_time

	var/current_research = "Nothing"

	var/list/pylon_around

	var/datum/religion/religion

/obj/structure/cult/tech_table/Destroy()
	pylon_around = null
	return ..()

/obj/structure/cult/tech_table/examine(mob/user, distance)
	..()
	if(isliving(user))
		if(!user.mind?.holy_role || !religion || religion.aspects.len == 0)
			return

	to_chat(user, "<span class='notice'>Текущее исследование: [current_research].</span>")
	to_chat(user, "<span class='notice'>Аспекты и их сила в [religion.name]:</span>")
	for(var/name in religion.aspects)
		var/datum/aspect/A = religion.aspects[name]
		to_chat(user, "\t<font color='[A.color]'>[name]</font> с силой <font size='[1+A.power]'><i>[A.power]</i></font>")

/obj/structure/cult/tech_table/attack_hand(mob/living/user)
	if(!user.mind.holy_role || !user.my_religion)
		return

	if(!religion)
		religion = user.my_religion

	if(researching)
		to_chat(user, "<span class='warning'>Осталось [round((end_research_time - world.time) * 0.1)] секунд до конца исследования.</span>")
		return

	if(!aspect_images.len)
		gen_aspect_images()
	if(uniq_images.len < religion.available_techs.len)
		gen_tech_images(user)
	if(!category_images.len)
		gen_category_images()

	var/choice = show_radial_menu(user, src, category_images, tooltips = TRUE, require_near = TRUE)

	switch(choice)
		if("Аспекты")
			choose_aspect(user)
		if("Уникальные технологии")
			choose_uniq_tech(user)

/obj/structure/cult/tech_table/proc/choose_uniq_tech(mob/living/user)
	for(var/datum/building_agent/B in uniq_images)
		B.name = "[initial(B.name)] [B.get_costs()]"

	var/datum/building_agent/choosed_tech = show_radial_menu(user, src, uniq_images, tooltips = TRUE, require_near = TRUE)
	if(!choosed_tech)
		return
	if(!religion.check_costs(choosed_tech.favor_cost, choosed_tech.piety_cost, user))
		return

	to_chat(user, "<span class='notice'>Вы начали изучение [initial(choosed_tech.name)].</span>")

	current_research = initial(choosed_tech.name)
	start_activity(CALLBACK(src, .proc/research_tech, choosed_tech))

/obj/structure/cult/tech_table/proc/research_tech(datum/building_agent/tech/choosed_tech)
	var/datum/religion_tech/T = new choosed_tech.building_type
	T.apply_effect(religion)
	qdel(T)

	uniq_images -= choosed_tech
	religion.available_techs -= choosed_tech
	qdel(uniq_images[choosed_tech])

	end_activity()

/obj/structure/cult/tech_table/proc/choose_aspect(mob/living/user)
	// Generates a name with the power of an aspect and upgrade cost
	for(var/datum/aspect/A in aspect_images)
		var/datum/aspect/in_religion = religion.aspects[initial(A.name)]
		A.name = "[initial(A.name)], сила: [in_religion ? in_religion.power : "0"], piety: [get_upgrade_cost(in_religion)]"

	var/datum/aspect/choosed_aspect = show_radial_menu(user, src, aspect_images, tooltips = TRUE, require_near = TRUE)
	if(!choosed_aspect)
		return
	var/datum/aspect/in_religion = religion.aspects[initial(choosed_aspect.name)]
	if(!religion.check_costs(null, get_upgrade_cost(in_religion), user))
		return

	to_chat(user, "<span class='notice'>Вы начали [in_religion ? "улучшение" : "изучение"] [initial(choosed_aspect.name)].</span>")
	current_research = "[in_religion ? "улучшение" : "изучение"] [initial(choosed_aspect.name)]"
	start_activity(CALLBACK(src, .proc/upgrade_aspect, choosed_aspect))

/obj/structure/cult/tech_table/proc/upgrade_aspect(datum/religion/R, datum/aspect/aspect_to_upgrade)
	if(initial(aspect_to_upgrade.name) in R)
		var/datum/aspect/A = R.aspects[initial(aspect_to_upgrade.name)]
		A.power += 1
	else
		R.add_aspects(list(aspect_to_upgrade.type = 1))

	end_activity()

/obj/structure/cult/tech_table/proc/get_upgrade_cost(datum/aspect/in_religion)
	if(!in_religion)
		return 300
	else
		return in_religion.power * 50

/obj/structure/cult/tech_table/proc/gen_category_images()
	category_images = list(
		"Аспекты" = aspect_images[pick(aspect_images)],
		"Уникальные технологии" = uniq_images[pick(uniq_images)],
	)

/obj/structure/cult/tech_table/proc/gen_tech_images(mob/living/user)
	uniq_images = list()
	for(var/datum/building_agent/tech/BA in religion.available_techs)
		uniq_images[BA] = image(icon = BA.icon, icon_state = BA.icon_state)

/obj/structure/cult/tech_table/proc/gen_aspect_images()
	var/list/aspects = subtypesof(/datum/aspect)
	aspect_images = list()
	for(var/type in aspects)
		var/datum/aspect/A = new type
		if(!A.name)
			qdel(A)
			continue
		aspect_images[A] = image(icon = A.icon, icon_state = A.icon_state)

/obj/structure/cult/tech_table/proc/start_activity(datum/callback/end_activity)
	LAZYINITLIST(pylon_around)
	for(var/obj/structure/cult/pylon/P in oview(3))
		if(!P.anchored)
			continue
		new /obj/effect/temp_visual/cult/sparks(P.loc)
		pylon_around += P
		P.icon_state = "pylon_glow"
	researching = TRUE
	end_research_time = world.time + research_time - (pylon_around.len SECONDS)
	addtimer(end_activity, research_time)

/obj/structure/cult/tech_table/proc/end_activity()
	researching = FALSE
	for(var/obj/structure/cult/pylon/P in pylon_around)
		pylon_around -= P
		P.icon_state = "pylon"

	current_research = "Ничего"
