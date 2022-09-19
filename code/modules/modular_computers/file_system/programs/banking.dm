/datum/computer_file/program/banking
	filename = "banking"
	filedesc = "Interdimensional Banking Suite"
	category = PROGRAM_CATEGORY_CREW
	ui_header = "atm.gif"
	program_icon_state = "atm"
	extended_desc = "blah blah"
	requires_ntnet = TRUE
	size = 2
	tgui_id = "Banking"
	program_icon = "radiation"
	alert_able = FALSE

	var/withdrawal_amount = 0
	var/deposit_amount = 0

/datum/computer_file/program/banking/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/card_slot/card_slot

	if(computer)
		card_slot = computer.all_components[MC_CARD]
		if(!card_slot)
			return

	var/obj/item/card/id/user_id_card = card_slot.stored_card

	if(!user_id_card)
		data["locked"] = TRUE
		return data

	if(!user_id_card.registered_account)
		data["locked"] = TRUE
		return data

	data["locked"] = FALSE
	data["withdrawal_amount"] = withdrawal_amount
	data["deposit_amount"] = deposit_amount
	data["balance"] = fetch_balance(user)
	data["id_balance"] = user_id_card.registered_account.account_balance

	return data

/datum/computer_file/program/banking/ui_act(action, params)
	if(..())
		return

	var/obj/item/computer_hardware/card_slot/card_slot

	if(computer)
		card_slot = computer.all_components[MC_CARD]
		if(!card_slot)
			return

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = card_slot.stored_card

	if(!user)
		return FALSE

	if(!user_id_card || !user_id_card.registered_account)
		return FALSE

	var/id_balance = user_id_card.registered_account.account_balance

	switch(action)
		if("PRG_change_withdrawal")
			var/amount = text2num(params["amount"])
			if(!isnull(amount))
				withdrawal_amount = amount

			. = TRUE

		if("PRG_withdraw")
			var/network_balance = fetch_balance(user)
			if(withdrawal_amount > 0 && withdrawal_amount <= network_balance)
				user_id_card.registered_account.adjust_money(withdrawal_amount)
				adjust_balance(user, -withdrawal_amount)
				. = TRUE

		if("PRG_change_deposit")
			var/amount = text2num(params["amount"])
			if(!isnull(amount))
				deposit_amount = clamp(amount, 0, id_balance)

			. = TRUE

		if("PRG_deposit")
			if(deposit_amount > 0 && deposit_amount <= id_balance)
				user_id_card.registered_account.adjust_money(-deposit_amount)
				adjust_balance(user, deposit_amount)
				. = TRUE

/datum/computer_file/program/banking/proc/fetch_balance(mob/user)
	if(!SSdbcore.Connect())
		return 0

	var/datum/db_query/query_fetch_balance = SSdbcore.NewQuery({"
		SELECT balance
		FROM [format_table_name("bank_account")]
		WHERE ckey = :ckey
	"}, list("ckey" = user.ckey))

	var/query_succeeded = query_fetch_balance.Execute()
	if(query_succeeded && query_fetch_balance.NextRow())
		var/account_balance = query_fetch_balance.item[1]
		qdel(query_fetch_balance)
		return account_balance

	return 0

/datum/computer_file/program/banking/proc/adjust_balance(mob/user, difference)
	set waitfor = FALSE
	if(!SSdbcore.Connect())
		return

	var/datum/db_query/query_set_balance = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("bank_account")] (ckey, balance)
		VALUES (:ckey, :difference)
		ON DUPLICATE KEY
		UPDATE [format_table_name("bank_account")].balance = [format_table_name("bank_account")].balance + :difference
	"}, list("difference" = difference, "ckey" = user.ckey))

	query_set_balance.Execute()
	qdel(query_set_balance)
