extends Node3D

var visibility_distance: float = 10.0  # Adjust this value based on your scene
@export var model_1: Node3D 

# Called every frame
func _process(delta: float) -> void:
	# Get the player's camera using get_node
	var player_camera = get_node("/root/Mushroom_Valley/Player/ThirdPersonCamera/HorizontalPivot/VerticalPivot/SpringArm3D/Camera3D")  # Adjust the path accordingly

	if player_camera != null and player_camera is Camera3D:
		# Calculate the distance between this node and the camera
		var distance_to_camera = global_transform.origin.distance_to(player_camera.global_transform.origin)

		# Toggle visibility based on the distance
		if distance_to_camera > visibility_distance:
			set_visibility(false)
		else:
			set_visibility(true)

# Function to set visibility
func set_visibility(is_visible: bool) -> void:
	# Set the visibility property of the current node
	$House/House_012.visible = is_visible
	$Redwood_1/Redwood_1/Redwood_1.visible = !is_visible
