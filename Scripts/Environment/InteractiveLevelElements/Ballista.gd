class_name Ballista extends Node3D

@export var ballista_box : CSGBox3D
@export var firing_box : Node3D
@export var collider : Area3D
var player_movement : PlayerMovement
var camera : Camera3D


@export var player_inside := false 

@export var projectile_scene : PackedScene
@export var projectile_speed : float = 10
@export var projectile_damage : float = 50
@export var break_on_use := true

var min_x_angle := -5
var max_x_angle := 15

var min_y_angle := -90
var max_y_angle := 90

var smooth_speed := 10

enum State {
    BROKEN,
    UNMANNED,
    AIMING,
    FIRING,
}

@export var cur_state := State.UNMANNED

var starting_rotation: Vector3


func _ready() -> void:
    set_ballista_color()
    collider.body_entered.connect(self.on_body_entered)
    collider.body_exited.connect(self.on_body_exited)
    self.starting_rotation = self.ballista_box.rotation

    var player: PlayerController = self.get_tree().get_first_node_in_group("Player")
    self.player_movement = Util.get_child_node_of_type(player, PlayerMovement)


func _physics_process(delta) -> void:
    if (cur_state == State.AIMING):
        aim(delta)


func change_state(new_state : State) -> void:
    cur_state = new_state
    set_ballista_color()	


func set_ballista_color() -> void:
    # Temp color change until models
    if cur_state == State.BROKEN:
        ballista_box.material_override.albedo_color = Color(256 , 0, 0, 200)
    else:
        ballista_box.material_override.albedo_color = Color(0 , 0, 256, 200)


func on_body_entered(body : Node3D) -> void:
    if body is PlayerController:
        player_inside = true
        SignalBus.player_entered_ballista_region.emit(self)


func on_body_exited(body : Node3D) -> void:
    if body is PlayerController:
        player_inside = false
        SignalBus.player_exited_ballista_region.emit(self)


func fire() -> void:
    if cur_state != State.AIMING :
        return
    var projectile: Projectile = projectile_scene.instantiate()
    projectile.direction = firing_box.global_transform.basis.z
    projectile.speed = projectile_speed
    projectile.damage = self.projectile_damage
    projectile.collided.connect(self.on_projectile_collided)
    get_tree().root.add_child(projectile)
    projectile.global_position = firing_box.global_position

    if break_on_use:
        change_state(State.BROKEN)
        player_movement.disabled = false


func aim(delta: float) -> void:
    var target_position: Vector3 = screen_point_to_ray()
    self.ballista_box.look_at(target_position)
    self.ballista_box.rotation.x = clamp(self.ballista_box.rotation.x, deg_to_rad(min_x_angle), deg_to_rad(max_x_angle))
    self.ballista_box.rotation.y = clamp(self.ballista_box.rotation.y, deg_to_rad(min_y_angle), deg_to_rad(max_y_angle))
    self.ballista_box.rotation.z = 0


func legacy_aim(delta: float, target_position: Vector3) -> void:
    # Note from saba: I could not get the below code to work when ballista is not in its default rotation.
    # So, I moved it to this function. It is not currently being called by anything.

    ballista_box.global_rotation.y = lerp_angle( ballista_box.global_rotation.y, atan2( -target_position.x, -target_position.z ), delta * smooth_speed ) 
    ballista_box.global_rotation.x = lerp_angle( ballista_box.global_rotation.x, atan2( target_position.y, target_position.z ), delta * smooth_speed ) 
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


func on_projectile_collided(body: Node3D):
    SignalBus.ballista_projectile_collided.emit(body)
