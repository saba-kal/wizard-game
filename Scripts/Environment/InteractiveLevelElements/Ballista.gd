class_name Ballista extends Node3D

@export var ballista_box : CSGBox3D
@export var firing_box : Node3D
@export var collider : Area3D
var player_movement : PlayerMovement
var camera : Camera3D


@export var player_inside := false 

@export var projectile_scene : PackedScene
@export var projectile_speed : float = 10
@export var break_on_use := true

var min_x_angle := -5
var max_x_angle := 15

var min_y_angle := 90
var max_y_angle := 270

var smooth_speed := 10

enum State {
	BROKEN,
	UNMANNED,
	AIMING,
	FIRING,
}

@export var cur_state := State.UNMANNED

func _ready() -> void:
	set_ballista_color()
	collider.body_entered.connect(player_check)
	collider.body_exited.connect(player_check)

func _physics_process(delta) -> void:
	# Could improve this to use signal, 
	# Also possible issue now with ballista removing disable of movement from console or other disables
	if player_inside && Input.is_action_just_pressed("interact"):
		if cur_state == State.UNMANNED:
			player_movement.on_player_disabled(true);
			cur_state = State.AIMING
		elif cur_state == State.AIMING:
			player_movement.on_player_disabled(false);
			cur_state = State.UNMANNED

	if (player_inside && Input.is_action_just_pressed("mouse_left")):
		fire()

	if (cur_state == State.AIMING):
			aim(delta)

		
func change_State(new_state : State) -> void:
	cur_state = new_state
	set_ballista_color()	

func set_ballista_color() -> void:
	# Temp color change until models
	if cur_state == State.BROKEN:
		ballista_box.material_override.albedo_color = Color(256 , 0, 0, 200)
	else:
		ballista_box.material_override.albedo_color = Color(0 , 0, 256, 200)


func player_check(body : Node3D) -> void:
	var movement := Util.get_child_node_of_type(body, PlayerMovement)
	if movement != null:
		player_inside = !player_inside
		player_movement = movement

func fire() -> void :
	if cur_state != State.AIMING :
		return
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.direction = firing_box.global_transform.basis.z
	projectile.speed = projectile_speed
	get_tree().root.add_child(projectile)
	projectile.global_position = firing_box.global_position

	if break_on_use:
		change_State(State.BROKEN)
		player_movement.disabled = false

func aim(delta) -> void:
	var target_position = screen_point_to_ray()

	ballista_box.rotation.y = lerp_angle( ballista_box.rotation.y, atan2( -target_position.x, -target_position.z ), delta * smooth_speed ) 
	ballista_box.rotation.x = lerp_angle( ballista_box.rotation.x, atan2( target_position.y, target_position.z ), delta * smooth_speed ) 
	# For some reason accessing the degrees directly didnt work
	ballista_box.rotation.x = clamp(ballista_box.rotation.x, deg_to_rad(min_x_angle), deg_to_rad(max_x_angle))
	# Normalize the y rotation cause clamping doesn't account for rotation wrapping 
	# or inverse orientation (which the ballista is in rn)
	var y_rotation := ballista_box.rotation_degrees.y
	if y_rotation < 0:
		y_rotation += 360
	ballista_box.rotation_degrees.y = clamp(y_rotation, min_y_angle, max_y_angle)

func screen_point_to_ray() -> Vector3:
	if not camera:
		camera = get_tree().root.get_camera_3d()
	var worldSpace = get_world_3d().direct_space_state
	var mousePos = get_viewport().get_mouse_position()
	
	var rayOrigin = camera.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + camera.project_ray_normal(mousePos) * 1000
	return rayEnd
