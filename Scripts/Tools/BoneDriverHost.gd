@tool
class_name BoneDriverHost extends Node

@export var animation_player : AnimationPlayer

@export var refresh_all: bool :
	get: return false
	set(value):
		refresh()

var _drivers : Array[BoneDriver]
@export var drivers: Array[BoneDriver] :
	get: return _drivers
	set(value):
		_drivers = value

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()

func refresh() -> void:
	for library_id in animation_player.get_animation_library_list():
		var library := animation_player.get_animation_library(library_id)
		for animation_id in library.get_animation_list():
			var anim := library.get_animation(animation_id)
			# Skip RESET tracks
			if anim.resource_name == '' : continue
			for driver in _drivers:
				driver.link_to(anim)