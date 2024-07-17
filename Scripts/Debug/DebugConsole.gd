extends Control

@export var line_edit: LineEdit
@export var console: RichTextLabel
@export var commandHolder: Node

var history: Array[String] = []
var history_index := -1

# Methods that are viable for autocomplete
var autocomplete_methods := []
var autocomplete_index := 0
# Track if the last input was related to autocomplete
var last_input_was_autocomplete := false
# Store matches of the last autocomplete so that the search doesn't have to be repeated
# when Tab is pressed multiple times
var prev_autocomplete_matches := []

func _ready():
	autocomplete_methods = commandHolder.get_script().get_script_method_list().map(func(x): return x.name)
	print("Debug Commands Available: ", autocomplete_methods)
	line_edit.text_submitted.connect(on_input_submitted)
	visible = false

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("consoleautocomplete"):
			autocomplete()
			last_input_was_autocomplete = true
		elif event.is_action_released('consoleautocomplete'):
			last_input_was_autocomplete = true
		else:
			last_input_was_autocomplete = false

		if event.is_action_pressed("console"):
			if not visible:
				print("Console opened")
				ShowConsole(true)
			else:
				print("Console closed")
				ShowConsole(false)
		elif event.is_action_pressed("consoleuphistory"):
			traverseHistory(true)
		elif event.is_action_pressed("consoledownhistory"):
			traverseHistory(false)

func ShowConsole(show_console: bool) -> void:
	visible = show_console
	if show_console:
		line_edit.grab_focus()
		SignalBus.player_disabled.emit(true)
	else:
		line_edit.release_focus()
		SignalBus.player_disabled.emit(false)

func on_input_submitted(command: String) -> void:
	history.push_front(command)
	history_index = -1
	line_edit.text = ''

	# Check if the command is a valid function before executing
	if not commandHolder.has_method(command):
		console.text += "Invalid command: " + command + '\n'
		return
	print("Executing command: ", command)
	
	var result = commandHolder.call(command)
	console.text += str(result) + "\n"

func traverseHistory(isUp: bool) -> void:
	if history.size() == 0:
		return
	if isUp:
		history_index = clamp(history_index + 1, 0, history.size() - 1)
	else:
		history_index = clamp(history_index - 1, 0, history.size() - 1)
	line_edit.text = history[history_index]
	line_edit.caret_column = line_edit.text.length()

func autocomplete() -> void:
	var matches := []
	var match_string := line_edit.text

	# Run through matches for the last string if the user is stepping through autocomplete options
	if last_input_was_autocomplete:
		matches = prev_autocomplete_matches
	# Step through all possible matches if no input string
	elif match_string.length() == 0:
		matches = autocomplete_methods
	# Otherwise check if each possible method begins with the user string
	else:
		for method in autocomplete_methods:
			if method.begins_with(match_string):
				matches.append(method)

	prev_autocomplete_matches = matches
	if matches.size() == 0:
		return

	# Go to the next possible autocomplete option if the user is Tabbing through options
	if last_input_was_autocomplete:
		autocomplete_index = wrapi(autocomplete_index + 1, 0, matches.size())
	else:
		autocomplete_index = 0

	line_edit.text = matches[autocomplete_index]
	line_edit.caret_column = line_edit.text.length()