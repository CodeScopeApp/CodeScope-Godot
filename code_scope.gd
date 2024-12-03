@tool
extends Control

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var error: Label = $TabContainer/Account/VBoxContainer/error
@onready var btn_login: Button = $TabContainer/Account/VBoxContainer/HBoxContainer/btn_login
@onready var username: LineEdit = $TabContainer/Account/VBoxContainer/username
@onready var password: LineEdit = $TabContainer/Account/VBoxContainer/password
@onready var btn_register: Button = $TabContainer/Account/VBoxContainer/HBoxContainer/btn_register
@onready var welcome: Label = $TabContainer/Account/VBoxContainer/welcome
@onready var btn_logout: Button = $TabContainer/Account/VBoxContainer/HBoxContainer/btn_logout

## Code Generation
@onready var input: LineEdit = $TabContainer/Generation/VBoxContainer/input
@onready var btn_generate: Button = $TabContainer/Generation/VBoxContainer/HBoxContainer/btn_generate
@onready var code_edit: CodeEdit = $TabContainer/Generation/VBoxContainer/CodeEdit

signal store_code

func _ready() -> void:
	if Codals.auth_token != null:
		hideItems(false)
	# Connect the request_completed signal to a method
	http_request.request_completed.connect(self._on_http_request_completed)

	# Connect the login button to the login_user function
	btn_login.connect("pressed", _on_login_button_pressed)

	# Hide the error label initially
	error.visible = false
	
	Codals.connect("returned_data", get_new_data)
	Codals.connect("cancel_data", cancel_data_request)

func _on_btn_register_pressed() -> void:
	OS.shell_open("https://codescope.app/register")
	print("Register on CodeScope")

# Function to log in the user
func login_user(email: String, password: String):
	var url = "https://codescope.app/api/login"  # Make sure this is the correct API URL
	# User data for login as expected by Laravel
	var data = {
		"email": email,
		"password": password
	}

	var headers = ["Content-Type: application/json"]
	# Convert data dictionary to JSON
	var json_data = JSON.stringify(data)

	# Disable the login button while the request is being processed
	btn_login.disabled = true
	
	# Hide the error label in case it's still visible from a previous error
	error.visible = false

	# Send a POST request to the login endpoint
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)

	# Log request error if any
	if error != OK:
		print("HTTP Request Error: ", error)

# Callback for when the HTTP request is completed
func _on_http_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	var response_body = body.get_string_from_utf8()

	## Debugging: print the response code and raw response body
	print("Response Code: ", response_code)
	print("Response Body: ", response_body)

	# Re-enable the login button after the request is completed
	btn_login.disabled = false

	if response_code == 200:
		# Parse the JSON response using parse_string
		var parse_result = JSON.parse_string(response_body)

		# Check if parsing was successful
		if parse_result.message != '':
			# Access the parsed JSON data stored in result
			var response_data = parse_result
			
			# Ensure that the response data is a dictionary before proceeding
			if typeof(response_data) == TYPE_DICTIONARY:
				# Check if the response contains the token
				if response_data.has("token"):
					print("Login Successful. Token: ", response_data["token"])

					# Store the token
					var auth_token = response_data["token"]
					Codals.auth_token = auth_token
					Codals.user = response_data["data"]
					welcome.text = "Welcome back, " + Codals.user["name"]
					hideItems(false)
				else:
					print("Token not found in response.")
					show_error("Login failed: Token not received.")
			else:
				print("Response data is not a dictionary.")
				show_error("Unexpected response format.")
		else:
			# Handle JSON parsing errors
			print("Error parsing response JSON: ", parse_result.error_string)
			show_error("An error occurred while processing the response.")
	elif response_code == 401:
		# Handle invalid credentials
		print("Invalid credentials: ", response_body)
		show_error("Invalid credentials. Please try again.")
	else:
		# Handle other HTTP errors
		print("HTTP Error: ", response_code, response_body)
		show_error("Cannot submit. Please try again later")

# Function to handle the login button press
func _on_login_button_pressed():
	# Get user input from the email and password fields
	var email = username.text.strip_edges()
	var password = password.text.strip_edges()

	# Call the login_user function with the provided email and password
	login_user(email, password)

# Function to display an error message
func show_error(message: String) -> void:
	error.text = message  # Update the error label text
	error.visible = true  # Make the error label visible
	
func hideItems(visible: bool):
	username.visible = visible
	password.visible = visible
	btn_login.visible = visible
	btn_register.visible = visible
	welcome.visible = !visible
	btn_logout.visible = !visible


func _on_btn_logout_pressed() -> void:
	Codals.auth_token = null
	Codals.user = null
	hideItems(true)

func _on_btn_generate_pressed() -> void:
	if Codals.user != null:
		diable_buttons(true)
		$TabContainer/Generation/VBoxContainer/CodeEdit.text = "Generating code..."
		$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true
		var data = {
			"language": "Godot 4",
			"prompt": input.text,
			"builder": true,
			"user_id": Codals.user['id'],
			"action": "generate"
		}
		Codals.post_data("plugin-generation", data)
	else:
		$TabContainer/Generation/VBoxContainer/CodeEdit.text = "Please access your CodeScope account first"
		$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true

func _on_btn_optimise_pressed() -> void:
	if Codals.user != null:
		diable_buttons(true)
		$TabContainer/Generation/VBoxContainer/CodeEdit.text = "Generating code..."
		$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true
		var data = {
			"language": "Godot 4",
			"builder": true,
			"user_id": Codals.user['id'],
			"action": "optimise",
			"code": $TabContainer/Generation/VBoxContainer/CodeEdit.text
		}
		Codals.post_data("plugin-generation", data)
	else:
		$TabContainer/Generation/VBoxContainer/CodeEdit.text = "Please access your CodeScope account first"
		$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true

func _on_btn_modify_pressed() -> void:
	if Codals.user != null:
		diable_buttons(true)
		$TabContainer/Generation/VBoxContainer/CodeEdit.text = "Generating code..."
		$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true
		var data = {
			"language": "Godot 4",
			"prompt": input.text,
			"builder": true,
			"user_id": Codals.user['id'],
			"action": "modify",
			"code": $TabContainer/Generation/VBoxContainer/CodeEdit.text
		}
		Codals.post_data("plugin-generation", data)
	else:
		$TabContainer/Generation/VBoxContainer/CodeEdit.text = "Please access your CodeScope account first"
		$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true

func diable_buttons(state):
	btn_generate.disabled = state
	$TabContainer/Generation/VBoxContainer/HBoxContainer/btn_optimise.disabled = state
	$TabContainer/Generation/VBoxContainer/HBoxContainer/btn_modify.disabled = state

func get_new_data(data):
	diable_buttons(false)
	# Save the data to a variable
	Codals.stored_code = str(data)
	# Optionally, show it in your UI
	$TabContainer/Generation/VBoxContainer/CodeEdit.text = Codals.stored_code
	$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true

func cancel_data_request(data):
	diable_buttons(false)
	$TabContainer/Generation/VBoxContainer/CodeEdit.text = data['error']
	$TabContainer/Generation/VBoxContainer/CodeEdit.visible = true

func _on_btn_insert_pressed() -> void:
	if Codals.stored_code != "":
		Codals.emit_signal("store_code")
