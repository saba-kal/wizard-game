class_name DebugCommands extends Node

# Prob not the best way to do this but eh, it works for now
@export var runes : Array

func give_all_runes() -> String:
	for rune : Rune in runes:
		SignalBus.rune_collected.emit(rune)
	return "Runes Given\n"

func reload_scene() -> String:
	get_tree().reload_current_scene()
	return "Scene Reloaded\n"