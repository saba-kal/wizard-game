extends Node

var _selected_texture : int = 0
@export var selected_texture : int :
	get: return _selected_texture
	set(value):
		value = clamp(value, 0, textures.size() - 1)
		if _selected_texture == value: return
		_selected_texture = value
		refresh()

@export var textures : Array[Texture2D]
@export var target_meshes : Array[MeshInstance3D]
@export var target_parameter: StringName = 'albedo_texture'

func _ready() -> void:
	refresh()

func refresh() -> void:
	for mesh in target_meshes:
		for i_surf in mesh.mesh.get_surface_count():
			var mat : ShaderMaterial = mesh.mesh.surface_get_material(i_surf)
			if mat == null || not mat is ShaderMaterial : continue
			mat.set_shader_parameter(target_parameter, textures[_selected_texture])
