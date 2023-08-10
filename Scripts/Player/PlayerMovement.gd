extends Node3D

@export var player_node: CharacterBody3D
@export var speed: float = 5
@export var jump_velocity: float = 5
@export var animation_tree: AnimationTree

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var input_direction: Vector2


func _ready():
    self.animation_tree.active = true


func _process(delta):
    self.update_animation_parameters(delta)


func _physics_process(delta):

    if !self.player_node.is_on_floor():
        self.player_node.velocity.y -= self.gravity * delta

    if Input.is_action_pressed("jump") && self.player_node.is_on_floor():
        self.player_node.velocity.y += self.jump_velocity

    self.input_direction = Input.get_vector(
        "move_left", "move_right", "move_forward", "move_backward")
    var direction = (self.player_node.transform.basis *
        Vector3(input_direction.x, 0, input_direction.y)).normalized()
    if direction:
        self.player_node.velocity.x = direction.x * self.speed
        self.player_node.velocity.z = direction.z * self.speed
    else:
        self.player_node.velocity.x = move_toward(self.player_node.velocity.x, 0, self.speed)
        self.player_node.velocity.z = move_toward(self.player_node.velocity.z, 0, self.speed)

    self.player_node.move_and_slide()


func update_animation_parameters(delta: float):
    if self.input_direction.length_squared() > 0.1:
        self.animation_tree["parameters/idle_walk/blend_amount"] = 1
    else:
        self.animation_tree["parameters/idle_walk/blend_amount"] = 0

    var current_blend_amount: float = self.animation_tree.get("parameters/jump/blend_amount");
    var jump_anim_speed = delta * 10
    if self.player_node.is_on_floor():
        self.animation_tree["parameters/jump/blend_amount"] = move_toward(current_blend_amount, 0, jump_anim_speed)
    else:
        self.animation_tree["parameters/jump/blend_amount"] = move_toward(current_blend_amount, 1, jump_anim_speed)
