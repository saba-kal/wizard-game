class_name PlayerMovement extends Node3D

@export var player_node: CharacterBody3D
@export var player_visuals_node: Node3D
@export var speed: float = 5
@export var aim_speed: float = 3
@export var mana_regen_speed: float = 1.5
@export var jump_velocity: float = 6
@export var turn_speed: float = 20
@export var animation_tree: AnimationTree
@export var slippery_friction: float = 0.003
@export var ground_friction = 1
@export var push_force: float = 10
@export var doppleganger: Doppleganger

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_adjustment: float = 0
var input_direction: Vector2
var disabled: bool = false
var dead: bool = false
var third_persion_camera: ThirdPersonCamera
var player_swimming: PlayerSwimming
var player_sliding: PlayerSliding
var is_mana_regen_active: bool = false
var sticky_zip: int = 0
var sticker: Node3D


func _ready():
    self.animation_tree.active = true
    self.third_persion_camera = Util.get_child_node_of_type(self.get_parent(), ThirdPersonCamera)
    self.player_swimming = Util.get_child_node_of_type(self.get_parent(), PlayerSwimming)
    self.player_sliding = Util.get_child_node_of_type(self.get_parent(), PlayerSliding)
    self.slippery_friction = 1.0/player_sliding.slip_factor
    SignalBus.player_died.connect(self.on_player_died)
    SignalBus.player_disabled.connect(on_player_disabled)
    SignalBus.player_mana_regen_changed.connect(self.on_player_mana_regen_changed)


func _physics_process(delta):
    if self.dead or self.disabled:
        self.input_direction = Vector2.ZERO
        return
    self.process_velocity(delta)
    self.process_rotation(delta)


func process_velocity(delta):
    var friction = ground_friction
    if(self.player_sliding.is_sliding()): friction = slippery_friction

    self.player_node.velocity.y -= (self.gravity + self.gravity_adjustment) * delta

    if Input.is_action_just_pressed("jump") && self.player_node.is_on_floor():
        self.apply_vertical_velocity(self.jump_velocity)
        SignalBus.player_jumped.emit()

    var direction = (self.player_node.transform.basis *
        Vector3(self.input_direction.x, 0, self.input_direction.y)).normalized()
    if doppleganger and direction:
        var self_pos = player_node.position
        var player_pos = doppleganger.player.position
        var from_player: Vector3 = self_pos - player_pos
        direction = direction.bounce(from_player.normalized())

    var move_speed: float = self.speed
    if self.third_persion_camera.is_aiming:
        move_speed = self.aim_speed
    if self.is_mana_regen_active:
        move_speed = self.mana_regen_speed

    if direction:
        self.player_node.velocity.x = move_toward(self.player_node.velocity.x, direction.x * move_speed, move_speed * sqrt(friction))
        self.player_node.velocity.z = move_toward(self.player_node.velocity.z, direction.z * move_speed, move_speed * sqrt(friction))
    else:
        self.player_node.velocity.x = move_toward(self.player_node.velocity.x, 0, move_speed * friction)
        self.player_node.velocity.z = move_toward(self.player_node.velocity.z, 0, move_speed * friction)
    
    self.player_node.move_and_slide()
    for i in player_node.get_slide_collision_count():
        var collision: KinematicCollision3D = player_node.get_slide_collision(i)
        if(collision.get_collider() is RigidBody3D):
            var v: float = self.player_node.velocity.length()
            collision.get_collider().apply_central_force(collision.get_normal() * -push_force)
    if(sticky_zip == 0):
        #TODO: This causes the player to hop slightly. Fix by conserving only horizontal velocity.
        #self.player_node.velocity = self.player_node.get_real_velocity() - self.player_node.get_platform_velocity()
        pass
    else:
        player_node.global_position.x = sticker.global_position.x
        player_node.global_position.z = sticker.global_position.z
        player_node.apply_floor_snap()
        sticky_zip -= 1


func apply_vertical_velocity(vertical_velocity: float):
    self.player_node.velocity.y += vertical_velocity


func set_vertical_velocity(vertical_velocity: float):
    self.player_node.velocity.y = vertical_velocity
    self.player_node.velocity.y = vertical_velocity


func process_rotation(delta):
    var target_quaternion: Quaternion
    if self.third_persion_camera.is_aiming:
        target_quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
    else:
        var target_y_rotation = Vector3.FORWARD.signed_angle_to(Vector3(self.input_direction.x, 0, self.input_direction.y), Vector3.UP)
        target_quaternion = Quaternion.from_euler(Vector3(0, target_y_rotation, 0))

    self.player_visuals_node.quaternion = self.player_visuals_node.quaternion.slerp(target_quaternion, delta * self.turn_speed)

    if self.input_direction || self.third_persion_camera.is_aiming:
        var player_rotation = Quaternion.from_euler(Vector3(0, self.third_persion_camera.get_camera_y_rotation(), 0))
        self.player_node.quaternion = self.player_node.quaternion.slerp(player_rotation, delta * self.turn_speed)


func is_running() -> bool:
    return !self.third_persion_camera.is_aiming && self.player_node.velocity.length_squared() > 0.1


func is_walking() -> bool:
    return self.third_persion_camera.is_aiming && self.player_node.velocity.length_squared() > 0.1


func is_on_floor() -> bool:
    return self.player_node.is_on_floor()


func on_player_died() -> void:
    self.dead = true


func on_player_disabled(is_disabled: bool) -> void:
    self.disabled = is_disabled


func get_velocity() -> Vector3:
    return self.player_node.velocity


func on_player_mana_regen_changed(is_mana_regen_on: bool) -> void:
    self.is_mana_regen_active = is_mana_regen_on


func get_sticky(sticker: Node3D):
    sticky_zip = 5
    self.sticker = sticker
