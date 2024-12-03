@tool
extends EditorPlugin  # Use Node or a similar lightweight class for global scripts.

var http_request: HTTPRequest = HTTPRequest.new()
var auth_token = null
var user = null

signal store_code
var stored_code = ""
signal returned_data
signal cancel_data

var api = "https://codescope.app/api/"

# Add HTTPRequest node dynamically when ready.
func _ready() -> void:
	add_child(http_request)
	http_request.connect("request_completed", _on_HTTPRequest_request_completed)

# Function to make a POST request to the API with Bearer Token.
func post_data(api_url: String, params: Variant) -> void:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + str(auth_token)
	]

	var url = api + api_url

	# Convert parameters to a JSON string for the POST body, or handle empty params.
	var json_data = params if params else ""
	if typeof(params) == TYPE_DICTIONARY or typeof(params) == TYPE_ARRAY:
		json_data = JSON.stringify(params)

	# Start the POST request with data.
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)

	if error != OK:
		print("Error requesting URL: ", error)
	else:
		print("Request successfully initiated.")

# Callback function to handle the response.
func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	if response_code == 200:
		# Successfully received response.
		var data = JSON.parse_string(body.get_string_from_utf8())
		emit_signal("returned_data", data)
	else:
		var data = JSON.parse_string(body.get_string_from_utf8())
		print("Request failed with response code: ", response_code)
		emit_signal("cancel_data", data)
		
