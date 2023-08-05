extends Node3D

@export var player_node: CharacterBody3D
@export var speed: float = 5
@export var jump_velocity: float = 5
@export var animation_tree: AnimationTree

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
    self.animation_tree.active = true
    var animation_player: AnimationPlayer = get_node(self.animation_tree.anim_player)
    animation_player.get_animation("Walk").loop_mode = Animation.LOOP_LINEAR
    animation_player.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR


func _process(delta):
    self.update_animation_parameters()


func _physics_process(delta):

    if !self.player_node.is_on_floor():
        self.player_node.velocity.y -= self.gravity * delta

    if Input.is_action_pressed("jump") && self.player_node.is_on_floor():
        self.player_node.velocity.y += self.jump_velocity

    var input_direction: Vector2 = Input.get_vector(
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


func update_animation_parameters():
    var is_moving: bool = self.player_node.velocity.length_squared() > 0.1
    self.animation_tree["parameters/conditions/is_moving"] = is_moving
    self.animation_tree["parameters/conditions/is_idle"] = !is_moving

    var is_grounded: bool = self.player_node.is_on_floor()
    self.animation_tree["parameters/conditions/is_jumping"] = !is_grounded
    self.animation_tree["parameters/conditions/is_grounded"] = is_grounded
