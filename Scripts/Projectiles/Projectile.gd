class_name Projectile extends Area3D

signal collided(body: Node3D)

@export var on_destroy_effect: PackedScene
@export var projectile_gravity: float = 0

# These are set by the nodes that spawn projectiles. They should not be exposed via export.
var damage: float = 10.0
var speed: float = 10.0
var direction: Vector3

# Private variables
var velocity: Vector3


func _ready() -> void:
    self.velocity = self.direction * self.speed
    self.body_entered.connect(self.on_body_entered)


func _process(delta: float) -> void:
    self.look_at(self.global_transform.origin + self.direction, Vector3.UP)

    self.velocity.y -= self.projectile_gravity * delta
    self.global_position = self.global_position + (self.velocity * delta)


func on_body_entered(body: Node3D):
    if self.on_destroy_effect != null:
        var effect: Node3D = self.on_destroy_effect.instantiate()
        self.get_tree().root.add_child(effect)
        effect.global_position = self.global_position
    var health: Health = Util.get_child_node_of_type(body, Health)
    if health != null:
        health.take_damage(self.damage)
    self.collided.emit(body)
    self.queue_free()
