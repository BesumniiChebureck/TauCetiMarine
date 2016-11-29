#define OPTIMISM_MAX 2
#define OPTIMISM_MIN -2
#define PERFORMANCE_MAX 2.5 //250% performance, YAY!
#define PERFORMANCE_MIN 0.5

/datum/stock
	var/name = "Stock"
	var/short_name = "STK"
	var/desc = "A company that does not exist."
	var/list/values = list()
	var/current_value = 10
	var/last_value = 10
	var/list/products = list()

	var/performance = 1 // The current performance of the company. Tends itself to 0 when no events happen.

	// These variables determine standard fluctuational patterns for this stock.
	var/last_trend = 0
	var/bankrupt = 0

	var/disp_value_change = 0
	var/optimism = 0
	var/last_unification = 0
	var/available_shares = 500000

	var/list/shareholders = list()
	var/list/events = list()
	var/list/articles = list()
	var/fluctuation_rate = 15
	var/fluctuation_counter = 0
	var/datum/industry/industry = null

/datum/stock/proc/changeOptimism(dn)
	optimism = Clamp(optimism + dn, OPTIMISM_MIN, OPTIMISM_MAX)

/datum/stock/proc/setOptimism(n)
	optimism = Clamp(n, OPTIMISM_MIN, OPTIMISM_MAX)

/datum/stock/proc/addEvent(datum/stockEvent/E)
	events |= E

/datum/stock/proc/addArticle(datum/article/A)
	if (!(A in articles))
		articles.Insert(1, A)
	A.ticks = world.time

/datum/stock/proc/generateEvents()
	var/list/types = subtypesof(/datum/stockEvent)
	for (var/T in types)
		generateEvent(T)

/datum/stock/proc/generateEvent(T)
	var/datum/stockEvent/E = new T(src)
	addEvent(E)

/datum/stock/proc/affectPublicOpinion(boost)
	changeOptimism(rand(0, 100) * 0.003 * boost) //0.003 = 0.01*0.3 (for balance)

/datum/stock/proc/generateIndustry()
	if (findtext(name, "Farms"))
		industry = new /datum/industry/agriculture
	else if (findtext(name, "Software") || findtext(name, "Programming")  || findtext(name, "IT Group") || findtext(name, "Electronics") || findtext(name, "Electric") || findtext(name, "Nanotechnology"))
		industry = new /datum/industry/it
	else if (findtext(name, "Mobile") || findtext(name, "Communications"))
		industry = new /datum/industry/communications
	else if (findtext(name, "Pharmaceuticals") || findtext(name, "Health"))
		industry = new /datum/industry/health
	else if (findtext(name, "Wholesale") || findtext(name, "Stores"))
		industry = new /datum/industry/consumer
	else
		var/ts = typesof(/datum/industry) - /datum/industry
		var/in_t = pick(ts)
		industry = new in_t
	for (var/i = 0, i < rand(2, 5), i++)
		products += industry.generateProductName(name)

/datum/stock/proc/supplyGrowth(amt)
	available_shares += amt
	var/t = amt / available_shares
	if(abs(t) < 0.0001)
		return
	current_value -= NormalDistr(t, t * 0.1) * current_value

/datum/stock/proc/supplyDrop(amt)
	supplyGrowth(-amt)

/datum/stock/proc/fluctuate()
	var/change = abs(NormalDistr()) * optimism
	current_value += change * performance
	if(current_value < 5)
		current_value = 5

	if(performance)
		performance = Clamp(rand(900,1050) * 0.001 * performance, PERFORMANCE_MIN, PERFORMANCE_MAX)

	disp_value_change = (change > 0) ? 1 : ((change < 0) ? -1 : 0)
	last_value = current_value
	if(values.len >= 50)
		values.Cut(1,2)
	values += current_value

	if(current_value < 10)
		unifyShares()

/datum/stock/proc/unifyShares()
	for (var/I in shareholders)
		var/shr = shareholders[I]
		if (shr % 2)
			sellShares(I, 1)
		shr -= 1
		shareholders[I] /= 2
		if (!shareholders[I])
			shareholders -= I
	available_shares /= 2
	current_value *= 2
	last_unification = world.time

/datum/stock/process()
	if(bankrupt)
		return
	fluctuation_counter++
	if(fluctuation_counter >= fluctuation_rate)
		for(var/E in events)
			var/datum/stockEvent/EV = E
			EV.process()
		fluctuation_counter = 0
		fluctuate()

/datum/stock/proc/modifyAccount(whose, by, force = 0)
	if (SSshuttle.points)
		if (by < 0 && SSshuttle.points + by < 0 && !force)
			return 0
		SSshuttle.points += by
		stockExchange.balanceLog(whose, by)
		return 1
	return 0

/datum/stock/proc/buyShares(who, howmany)
	if (howmany <= 0)
		return
	howmany = round(howmany)
	var/loss = howmany * current_value
	if (available_shares < howmany)
		return 0
	if (modifyAccount(who, -loss))
		supplyDrop(howmany)
		if (!(who in shareholders))
			shareholders[who] = howmany
		else
			shareholders[who] += howmany
		return 1
	return 0

/datum/stock/proc/sellShares(whose, howmany)
	if(howmany <= 0)
		return
	howmany = round(howmany)
	var/gain = howmany * current_value
	if(shareholders[whose] < howmany)
		return 0
	if(modifyAccount(whose, gain))
		supplyGrowth(howmany)
		shareholders[whose] -= howmany
		if(shareholders[whose] <= 0)
			shareholders -= whose
		return 1
	return 0

/datum/stock/proc/displayValues(mob/user)
	user << browse(plotBarGraph(values, "[name] share value per share"), "window=stock_[name];size=450x450")

#undef OPTIMISM_MAX
#undef OPTIMISM_MIN
#undef PERFORMANCE_MIN
#undef PERFORMANCE_MAX
