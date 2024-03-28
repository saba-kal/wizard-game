extends AnimationTree

@export var dying_fall_speed: float = 8.0

@onready var enemy_ai: EnemyAI = self.get_parent()

var is_dying: bool = false
var is_dead: bool = false
var death_position: Vector3


func _ready():
    self.enemy_ai.state_changed.connect(self.on_bee_state_changed)
    self.enemy_ai.attack_started.connect(self.on_bee_attack)


func _process(delta):
    if self.is_dying && !self.is_dead:
        self.enemy_ai.global_position = self.enemy_ai.global_position.move_toward(self.death_position, delta * self.dying_fall_speed)
        if self.enemy_ai.global_position.is_equal_approx(self.death_position):
            self.set("parameters/bee_state/transition_request", "dead")
            self.is_dead = true


func on_bee_state_changed(agent: EnemyAI, old_state: EnemyAI.State, new_state: EnemyAI.State) -> void:
    if new_state == EnemyAI.State.DEAD && !self.is_dying:
        self.is_dying = true
        self.set("parameters/bee_state/transition_request", "dying")
        self.death_position = self.get_death_position()
    elif new_state == EnemyAI.State.STUN:
        self.set("parameters/TimeScale/scale", 0)
    if new_state != EnemyAI.State.STUN:
        self.set("parameters/TimeScale/scale", 1)


func on_bee_attack():
    self.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func perform_death_animation():

    var death_position = self.enemy_ai.global_position

    var space_state = self.enemy_ai.get_world_3d().direct_space_state
    var origin = self.enemy_ai.global_position
    var end = origin - Vector3(0, 100, 0)
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    var result = space_state.intersect_ray(query)
    if result:
        death_position = result["position"]


func get_death_position() -> Vector3:
    var target_position = self.enemy_ai.global_position

    var space_state = self.enemy_ai.get_world_3d().direct_space_state
    var origin = self.enemy_ai.global_position
    var end = origin - Vector3(0, 100, 0)
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    var result = space_state.intersect_ray(query)
    if result:
        target_position = result["position"]

    return target_position
