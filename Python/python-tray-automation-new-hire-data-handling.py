'''
Python code snippet for tray.io automation tool - used to ingest, sanitize, and transform the New Hire data from Greenhouse, and pass to the rest of the tray.io automation workflow 
Script sanitized - Organization Name replaced with "Company" - Company had 5 sub-DBAs, that got one of 3 different email domains, so this script included logic to handle that domain selection. 
Elliott Price | 2022
'''

def executeScript(input):
	# might need to parse the json first
	new_hire_raw = input["greenhouse_json"]["payload"] # input from Greenhouse webhook, triggered on Candidate Offer Accepted action 
	new_hire_computer = input["computer_assignment"] # input from tray.io workflow

	candidate = new_hire_raw["application"]["candidate"]
	job = new_hire_raw["application"]["job"]
	offer_custom = new_hire_raw["application"]["offer"]["custom_fields"]
	new_hire_data = {}

	# Candiate data

	new_hire_data["it_alerts"] = ""
	new_hire_data["computer_type"] = new_hire_computer

	new_hire_data["start_date"] = new_hire_raw["application"]["offer"]["starts_at"]

	#Sanitize first and last name
	sanitize_first_name = candidate["first_name"].strip(' ')
	sanitize_last_name = candidate["last_name"].strip(' ')

	specialCharsName = "!#$%^&*()1234567890"
	for specialCharName in specialCharsName:
		sanitize_first_name = sanitize_first_name.replace(specialCharName, '')
		sanitize_last_name = sanitize_last_name.replace(specialCharName, '')

	new_hire_data["first_name"] = sanitize_first_name
	new_hire_data["last_name"] = sanitize_last_name
	new_hire_data["full_name"] = new_hire_data["first_name"] + " " + new_hire_data["last_name"]

	if candidate["candidate_gender_pronouns"]["pronouns"] == None:
		new_hire_data["pronouns"] = ""
	else:
		new_hire_data["pronouns"] = candidate["candidate_gender_pronouns"]["pronouns"]

	if "market" in offer_custom:
		if offer_custom["market"]["value"]:
			new_hire_data["brokerage_market"] = offer_custom["market"]["value"][0:3].lower()
	else:
		new_hire_data["brokerage_market"] = "none"

	new_hire_data["personal_email"] = candidate["email_addresses"][0]["value"]
	new_hire_data["personal_phone"] = candidate["phone_numbers"][0]["value"]
	new_hire_data["company_entity"] = offer_custom["company_entity"]["value"]

	if new_hire_data["company_entity"] == "Company A" or new_hire_data["company_entity"] == "Company B":
		new_hire_data["company_dba"] = "Company"
		new_hire_data["company_domain"] = "company.com"
	elif new_hire_data["company_entity"] == "company title org" or new_hire_data["company_entity"] == "company title company":
		new_hire_data["company_dba"] = "Company Title Co."
		new_hire_data["company_domain"] = "companytitleco.com"
	elif new_hire_data["company_entity"] == "company Loans Co.":
		new_hire_data["company_dba"] = "company Loans"
		new_hire_data["company_domain"] = "companyloans.com"

	#Sanitize first and last name for email creation
	temp_first_name = new_hire_data["first_name"].lower().strip(' ')
	temp_last_name = new_hire_data["last_name"].lower().strip(' ')

	specialChars = "!#$%^&*()-–—1234567890" 
	for specialChar in specialChars:
		temp_first_name = temp_first_name.replace(specialChar, '')
		temp_last_name = temp_last_name.replace(specialChar, '')

	specialCharsE = "éêëèēėę" 
	for specialCharE in specialCharsE:
		temp_first_name = temp_first_name.replace(specialCharE, 'e')
		temp_last_name = temp_last_name.replace(specialCharE, 'e')

	specialCharsU = "ûüùúū" 
	for specialCharU in specialCharsU:
		temp_first_name = temp_first_name.replace(specialCharU, 'u')
		temp_last_name = temp_last_name.replace(specialCharU, 'u')

	specialCharsA = "àáâäãåā" 
	for specialCharA in specialCharsA:
		temp_first_name = temp_first_name.replace(specialCharA, 'a')
		temp_last_name = temp_last_name.replace(specialCharA, 'a')

	specialCharsN = "ñń" 
	for specialCharN in specialCharsN:
		temp_first_name = temp_first_name.replace(specialCharN, 'n')
		temp_last_name = temp_last_name.replace(specialCharN, 'n')

	specialCharsI = "îïíīįì" 
	for specialCharI in specialCharsI:
		temp_first_name = temp_first_name.replace(specialCharI, 'i')
		temp_last_name = temp_last_name.replace(specialCharI, 'i')

	specialCharsO = "ôöòóøōõ"
	for specialCharO in specialCharsO:
		temp_first_name = temp_first_name.replace(specialCharO, 'o')
		temp_last_name = temp_last_name.replace(specialCharO, 'o')

	specialCharsC = "çćč"
	for specialCharC in specialCharsC:
		temp_first_name = temp_first_name.replace(specialCharC, 'c')
		temp_last_name = temp_last_name.replace(specialCharC, 'c')

	specialCharsS = "ßśš"
	for specialCharS in specialCharsS:
		temp_first_name = temp_first_name.replace(specialCharS, 's')
		temp_last_name = temp_last_name.replace(specialCharS, 's')

	specialCharsY = "ÿ"
	for specialCharY in specialCharsY:
		temp_first_name = temp_first_name.replace(specialCharY, 'y')
		temp_last_name = temp_last_name.replace(specialCharY, 'y')

	specialCharsZ = "žźż"
	for specialCharZ in specialCharsZ:
		temp_first_name = temp_first_name.replace(specialCharZ, 'z')
		temp_last_name = temp_last_name.replace(specialCharZ, 'z')

	specialCharsAE = "æ"
	for specialCharAE in specialCharsAE:
		temp_first_name = temp_first_name.replace(specialCharAE, 'ae')
		temp_last_name = temp_last_name.replace(specialCharAE, 'ae')

	# Generate company Email address
	new_hire_data["company_email"] = (temp_first_name + "." + temp_last_name ) + "@" + new_hire_data["company_domain"]


	#Put together some IT Data Alerts if Name was sanitized, or if email is too long!
	if temp_first_name != new_hire_data["first_name"].lower().strip(' '):
		new_hire_data["it_alerts"] = new_hire_data["it_alerts"] + " First name Sanitized. "

	if temp_last_name != new_hire_data["last_name"].lower().strip(' '):
		new_hire_data["it_alerts"] = new_hire_data["it_alerts"] + " Last name Sanitized. "

	temp_un = temp_first_name + "." + temp_last_name

	# Alert if name over 20 characters 

	if len(temp_un) > 20:
		new_hire_data["it_alerts"] = new_hire_data["it_alerts"] + " Username over 20 chars! "


	# Job data
	new_hire_data["department"] = job["departments"][0]["name"]
	new_hire_data["job_family"] = offer_custom["job_family"]["value"]
	new_hire_data["job_title"] = offer_custom["job_title"]["value"]
	new_hire_data["manager_id"] = offer_custom["manager_name"]["value"]["email"]
	new_hire_data["manager_name"] = offer_custom["manager_name"]["value"]["name"]
	

	# Other Data
	new_hire_data["recruiter"] = candidate["recruiter"]["email"]
	new_hire_data["office"] = ""


	# Legal/HR Data DO NOT SHARE OUTSIDE OF LEGAL/HR
	new_hire_data["job_level"] = offer_custom["job_level_offer_XXXX"]["value"]

	# Bonus
	bonus_total_value = offer_custom["bonus_total"]["value"]["amount"]
	if bonus_total_value == "0.0":
		new_hire_data["bonus"] = "No"
	else:
		new_hire_data["bonus"] = offer_custom["bonus_total"]["value"]["amount"]

	# Comission
	if offer_custom["commission_plan"]["value"] == None:
		new_hire_data["commission_plan"] = "No"
	else:
		new_hire_data["commission_plan"] = offer_custom["commission_plan"]["value"]


	#Generate Google OU
	google_ou = "/" + new_hire_data["company_dba"] + "/Employees/" + new_hire_data["department"] + "/" + new_hire_data["job_family"]
	new_hire_data["google_ou"] = google_ou

	if new_hire_data["company_dba"] == "Company Loans Co.":
		new_hire_data["google_ou"] = "/company Loans/Employees"

	if new_hire_data["company_dba"] == "Company Title Co.":
		new_hire_data["google_ou"] = "/Company Title/Employees"


	# Void values to add later by Recruiting
	new_hire_data["computer_type"] = ""
	new_hire_data["address"] = ""
	new_hire_data["reports_to"] = ""
	new_hire_data["notes"] = ""
	new_hire_data["t_shirt"] = ""
	new_hire_data["license"] = ""
	new_hire_data["legal_name"] = ""
	

	print(new_hire_data)
	return new_hire_data # Returns sanitized and generated data back to the tray.io Workflow
