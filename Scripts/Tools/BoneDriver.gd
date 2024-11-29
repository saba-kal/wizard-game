@tool
class_name BoneDriver extends Resource

@export var source_track : NodePath
static var source_type : Animation.TrackType = Animation.TrackType.TYPE_POSITION_3D
# @export var source_type : Animation.TrackType = Animation.TrackType.TYPE_POSITION_3D
static var target_type : Animation.TrackType = Animation.TrackType.TYPE_VALUE
# @export var target_type : Animation.TrackType = Animation.TrackType.TYPE_VALUE
@export var target_path_x : NodePath
@export var target_path_y : NodePath
@export var target_path_z : NodePath

func get_axis_path(axis: int) -> NodePath:
	match axis:
		0: return target_path_x
		1: return target_path_y
		2: return target_path_z
	return ""

func link_to(anim: Animation) -> void:
	for axis in 2:

		# If the path is empty, skip
		var target_path := get_axis_path(axis)
		if target_path.is_empty(): continue

		# If the target track already exists, remove it
		var target := anim.find_track(target_path, target_type)
		if target != -1:
			anim.remove_track(target)

		# Now add a new one
		target = anim.add_track(target_type)
		anim.track_set_path(target, target_path)

		# Get the source track
		var source := anim.find_track(source_track, source_type)
		if source == -1:
			push_warning("The source track '", source_track, "' does not exist for animation '", anim.resource_name, "'.")
			return

		# Link the source track axis to the target track value
		for i in anim.track_get_key_count(source):
			var time := anim.track_get_key_time(source, i)
			var key : Vector3 = anim.track_get_key_value(source, i)
			var transition := anim.track_get_key_transition(source, i)
			anim.track_insert_key(target, time, key[axis], transition)