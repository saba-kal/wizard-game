class_name BearclopsTelekinesisAttack extends Area3D

@export var object_float_height: float = 10.0
@export var duration: float = 3.5
@export var object_throw_start_time: float = 3.0
@export var object_throw_force: float = 3000.0
@export var cooldown: float = 5.0
@export var minimum_objects_needed_to_attack: int = 2

var player: Node3D
var nearby_physics_objects: Array[PhysicsObject] = []
var is_enabled: bool = false
var objects_were_thrown: bool = false
var time_since_attack_start: float = 0.0
var time_since_attack_end: float = 0.0


func _ready() -> void:
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)


func _process(delta: float) -> void:
    if !self.is_enabled:
        self.time_since_attack_end += delta
        return
    if self.time_since_attack_start >= self.duration:
        self.set_enabled(false)
    if !self.objects_were_thrown && self.time_since_attack_start >= self.object_throw_start_time:
        self.throw_objects()
    self.time_since_attack_start += delta


func can_attack() -> bool:
    return self.time_since_attack_end >= self.cooldown && len(self.nearby_physics_objects) >= self.minimum_objects_needed_to_attack


func set_enabled(enabled: bool) -> void:
    if self.is_enabled == enabled:
        return

    self.is_enabled = enabled
    if enabled:
        self.objects_were_thrown = false
        self.time_since_attack_start = 0
    else:
        self.time_since_attack_end = 0

    for physics_object: PhysicsObject in self.nearby_physics_objects:
        self.float_physics_object(physics_object, enabled)


func throw_objects() -> void:
    self.objects_were_thrown = true
    for physics_object: PhysicsObject in self.nearby_physics_objects:
        var force_direction: Vector3 = (self.player.global_position - physics_object.global_position).normalized()
        physics_object.set_float_enabled(false)
        physics_object.apply_force(force_direction * self.object_throw_force)


func float_physics_object(physics_object: PhysicsObject, is_float_enabled: bool) -> void:
    physics_object.set_float_enabled(is_float_enabled)
    physics_object.float_position = Vector3(
        physics_object.global_position.x, 
        self.global_position.y + self.object_float_height, 
        physics_object.global_position.z)


func on_body_entered(body: Node3D) -> void:
    if body is PhysicsObject:
        self.nearby_physics_objects.append(body)
        self.float_physics_object(body, self.is_enabled)


func on_body_exited(body: Node3D) -> void:
    if body is PhysicsObject:
        Util.remove_elem(self.nearby_physics_objects, body)
        body.set_float_enabled(false)


