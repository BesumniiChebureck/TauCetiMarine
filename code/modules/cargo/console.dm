/obj/machinery/computer/cargo
	name = "Supply console"
	desc = "Используется для заказа расходных материалов, утверждения запросов и управления шаттлом."
	icon = 'icons/obj/computer.dmi'
	icon_state = "supply"
	state_broken_preset = "techb"
	state_nopower_preset = "tech0"
	light_color = "#b88b2e"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/computer/cargo
	var/requestonly = FALSE
	var/contraband = FALSE
	var/hacked = FALSE
	var/temp = ""
	var/last_viewed_group = "categories"
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/safety_warning = "По соображениям безопасности автоматический шаттл снабжения \
		не может перевозить живые организмы, классифицированное ядерное оружие или \
		самонаводящиеся маяки."

/obj/machinery/computer/cargo/request
	name = "Supply request console"
	desc = "Используется для запроса поставок из карго."
	icon = 'icons/obj/computer.dmi'
	icon_state = "request"
	light_color = "#b88b2e"
	req_access = list()
	circuit = /obj/item/weapon/circuitboard/computer/cargo/request
	requestonly = TRUE

/obj/machinery/computer/cargo/atom_init()
	. = ..()
	var/obj/item/weapon/circuitboard/computer/cargo/board = circuit
	contraband = board.contraband_enabled
	hacked = board.hacked

/obj/machinery/computer/cargo/ui_interact(mob/user)
	var/dat
	if(!requestonly)
		post_signal("supply")
	if(temp)
		dat = temp
	else
		dat += {"<BR><B>Шаттл снабжения</B><HR>
		Местонахождение: [SSshuttle.moving ? "Движение к станции ([SSshuttle.eta] мин.)":SSshuttle.at_station ? "Станции":"Док"]<BR>
		<HR>Очки снабжения: [SSshuttle.points]<BR>\n<BR>"} //ОБЯЗАТЕЛЬНО ЗАТЕСТИТЬ "Станции":"Док" и т.д.
		if(requestonly)
			dat += "\n<A href='?src=\ref[src];order=categories'>Запросить товары</A><BR><BR>" //Поставки?
		else
			dat += {"[SSshuttle.moving ? "\n*Должен быть в отъезде, чтобы заказать товары*<BR>\n<BR>":SSshuttle.at_station ? "\n*Должен быть в отъезде, чтобы заказать товары*<BR>\n<BR>":"\n<A href='?src=\ref[src];order=categories'>Товары для заказа</A><BR>\n<BR>"]
			[SSshuttle.moving ? "\n*Шаттл уже вызван*<BR>\n<BR>":SSshuttle.at_station ? "\n<A href='?src=\ref[src];send=1'>Отослать на ЦК</A><BR>\n<BR>":"\n<A href='?src=\ref[src];send=1'>Отправить на станцию</A><BR>\n<BR>"]"} //ТЕСТИТЬ И ТЕСТИТЬ
		dat += {"<A href='?src=\ref[src];viewrequests=1'>Просмотреть запросы</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>Просмотреть утвержденные запросы</A><BR><BR>"}
		if(!requestonly)
			dat += "<A href='?src=\ref[src];viewcentcom=1'>Просмотреть сообщение от ЦК</A><BR><BR>"


	var/datum/browser/popup = new(user, "computer", name, 500, 600)
	popup.add_stylesheet(get_asset_datum(/datum/asset/spritesheet/cargo))
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/cargo/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["send"])
		if(!SSshuttle.can_move())
			temp = "[safety_warning]<BR><BR><A href='?src=\ref[src];mainmenu=1'>ОК</A>"
		else if(SSshuttle.at_station)
			SSshuttle.moving = -1
			SSshuttle.sell()
			SSshuttle.send()
			temp = "Шаттл снабжения отбыл.<BR><BR><A href='?src=\ref[src];mainmenu=1'>ОК</A>"
		else
			SSshuttle.moving = 1
			SSshuttle.buy()
			SSshuttle.eta_timeofday = (world.timeofday + SSshuttle.movetime) % 864000
			temp = "Вызван шаттл снабжения, он прибудет через [round(SSshuttle.movetime/600,1)] мин.<BR><BR><A href='?src=\ref[src];mainmenu=1'>ОК</A>"
			post_signal("supply")

	if(href_list["order"])
		if(!requestonly && SSshuttle.moving)
			return
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<b>Очки снабжения: [SSshuttle.points]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Главное меню</A><HR><BR><BR>"
			temp += "<b>Выбрать категорию</b><BR><BR>"
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp = "<b>Очки снабжения: [SSshuttle.points]</b><BR>"
			temp += "<b>Запрос от: [last_viewed_group]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Вернуться ко всем категориям</A><HR>"
			temp += "<div class='blockCargo'>"
			for(var/supply_name in SSshuttle.supply_packs)
				var/datum/supply_pack/N = SSshuttle.supply_packs[supply_name]
				if(requestonly)
					if(N.hidden || N.contraband || N.group != last_viewed_group)
						continue	//Have to send the type instead of a reference to
				else if((N.hidden && !hacked) || (N.contraband && !contraband) || N.group != last_viewed_group)
					continue
				temp += {"<div class="spoiler"><input type="checkbox" id='[supply_name]'>"}
				temp += {"<table><tr><td><span class="cargo32x32 [replace_characters("[N.crate_type]",  list("[/obj]/" = "", "/" = "-"))]"></span></td>"}
				temp += {"<td><label for='[supply_name]'><b>[supply_name]</b></label></td><td><A href='?src=\ref[src];doorder=[supply_name]'>Стоимость: [N.cost]</A></td></tr></table>"}		//the obj because it would get caught by the garbage
				temp += "<div><table>"
				if(ispath(N.crate_type, /obj/structure/closet/critter))
					var/obj/structure/closet/critter/C = N.crate_type
					var/mob/animal = initial(C.content_mob)
					temp += {"<tr><td><span class="cargo32x32 [replace_characters("[animal]", list("[/mob]/" = "", "/" = "-"))]"></span></td><td>[initial(animal.name)]</td></tr>"}
				else
					var/list/check_content = list()
					for(var/element in N.contains) //let's show what's in the conteiner
						if(element in check_content)
							continue
					//=========count the repetitions=======
						check_content += element
						var/amount = 0
						for(var/check in N.contains)
							if(element == check)
								amount += 1
						var/atom/movable/content = element
						var/final_name = initial(content.name)
						if(amount > 1)
							final_name += " x[amount]"
					//======================================
						var/size = "32x32"
						var/list/sprite_32x48 = list(/obj/machinery/mining/brace, /obj/machinery/mining/drill)
						if(element in sprite_32x48)
							size = "32x48"
						temp += {"<tr><td><span class="cargo[size] [replace_characters("[element]", list("[/obj]/" = "", "/" = "-"))]"></span></td><td>[final_name]</td></tr>"}
				temp += "</table></div></div>"
			temp += "</div>"

	if(href_list["doorder"])
		if(world.time < reqtime)
			visible_message("монитор <b>[src]</b> мигает, \"[world.time - reqtime] сек. осталось до того, как можно будет распечатать другую форму заявки.\"")
			return FALSE
		//Find the correct supply_pack datum
		var/datum/supply_pack/P = SSshuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))
			return FALSE
		var/timeout = world.time + 600
		var/reason = sanitize(input(usr,"Причина:","Зачем вам нужен этот предмет?","") as null|text)
		if(world.time > timeout)
			return FALSE
		if(!reason)
			return FALSE
		var/idname = "*Не указано*"
		var/idrank = "*Не указано*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name
			idrank = "Синтет"

		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order(P, idname, idrank, usr.ckey, reason)
		SSshuttle.requestlist += O
		O.generateRequisition(loc) //print supply request

		if(requestonly)
			temp = "Спасибо за ваш заказ. Грузовая бригада обработает его в кратчайшие сроки..<BR>"
			temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Назад</A> <A href='?src=\ref[src];mainmenu=1'>Главное меню</A>"
		else
			temp = "Запрос на поставку размещен.<BR>"
			temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Назад</A> | <A href='?src=\ref[src];mainmenu=1'>Главное меню</A> | <A href='?src=\ref[src];confirmorder=[O.id]'>Авторизовать заказ</A>"

	if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_pack/P
		temp = "Неверный запрос"
		for(var/i = 1 to SSshuttle.requestlist.len)
			var/datum/supply_order/SO = SSshuttle.requestlist[i]
			if(SO.id == ordernum)
				O = SO
				P = O.object
				if(SSshuttle.points >= P.cost)
					SSshuttle.requestlist.Cut(i,i+1)
					SSshuttle.points -= P.cost
					SSshuttle.shoppinglist += O
					temp = "Спасибо за ваш заказ.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Назад</A> <A href='?src=\ref[src];mainmenu=1'>Главное меню</A>"
				else
					temp = "Недостаточно очков снабжения.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Назад</A> <A href='?src=\ref[src];mainmenu=1'>Главное меню</A>"
				break

	if(href_list["vieworders"])
		temp = "Текущие утвержденные заказы: <BR><BR>"
		for(var/S in SSshuttle.shoppinglist)
			var/datum/supply_order/SO = S
			if(requestonly)
				temp += "[SO.object.name] утвержденно [SO.orderer] [SO.reason ? "([SO.reason])":""]<BR>"//беда с падежами
			else
				temp += "#[SO.id] - [SO.object.name] утвержденно [SO.orderer][SO.reason ? " ([SO.reason])":""]<BR>"//беда с падежами
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>ОК</A>"

	if(href_list["viewrequests"])
		temp = "Текущие запросы: <BR><BR>"
		for(var/S in SSshuttle.requestlist)
			var/datum/supply_order/SO = S
			if(requestonly)
				temp += "#[SO.id] - [SO.object.name] запрошенно [SO.orderer]<BR>" //беда с падежами
			else
				temp += "#[SO.id] - [SO.object.name] запрошенно [SO.orderer]  [SSshuttle.moving ? "":SSshuttle.at_station ? "":"<A href='?src=\ref[src];confirmorder=[SO.id]'>Утвердить</A> <A href='?src=\ref[src];rreq=[SO.id]'>Удалить</A>"]<BR>"//беда с падежами
		if(!requestonly)
			temp += "<BR><A href='?src=\ref[src];clearreq=1'>Очистить список</A>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>ОК</A>"

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		temp = "Неверный запрос.<BR>"
		for(var/i = 1 to SSshuttle.requestlist.len)
			var/datum/supply_order/SO = SSshuttle.requestlist[i]
			if(SO.id == ordernum)
				SSshuttle.requestlist.Cut(i,i+1)
				temp = "Запрос удален.<BR>"
				break
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Назад</A> <A href='?src=\ref[src];mainmenu=1'>Главное Меню</A>"

	else if (href_list["clearreq"])
		SSshuttle.requestlist.Cut()
		temp = "Список очищен.<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>ОК</A>"

	if(href_list["viewcentcom"])
		if(SSshuttle && SSshuttle.centcom_message)
			temp += "Последнее сообщение ЦентрКома: <BR><BR>"
			temp += SSshuttle.centcom_message
			temp += "<BR><BR>"
		else
			temp += "Невозможно найти сообщения от ЦентрКома. <BR><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>ОК</A>"

	if(href_list["mainmenu"])
		temp = null

	updateUsrDialog()

/obj/machinery/computer/cargo/emag_act(mob/user)
	if(hacked)
		return FALSE
	to_chat(user, "<span class='notice'>Разблокированы специальные поставки.</span>")
	hacked = TRUE
	contraband = TRUE
	user.visible_message("<span class='warning'>[user] проводит подозрительной картой через [src]!</span>", //без бед с падежами
	"<span class='notice'>Вы настраиваете маршрутизацию и спектр приемников консоли снабжения, разблокируя специальные поставки и контрабанду.</span>")

	// This also permamently sets this on the circuit board
	var/obj/item/weapon/circuitboard/computer/cargo/board = circuit
	board.contraband_enabled = TRUE
	board.hacked = TRUE
	return TRUE

/obj/machinery/computer/cargo/proc/post_signal(command)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)
