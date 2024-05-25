class_name AIMeleeAttack extends AIDefaultAttack

@onready var player = self.get_tree().get_first_node_in_group("Player")
@onready var hitbox: Area3D = $Area3D

@export var range: float = 3

var entered_bodies: Array[Node3D] = []

func _ready():
    hitbox.body_entered.connect(_on_body_entered)
    hitbox.body_exited.connect(on_body_exited)

func attack() -> void:
    for body in self.entered_bodies:
        var health: Health = Util.get_child_node_of_type(body, Health)
        if health != null && self.get_parent() != body:
            health.take_damage(self.damage)

func _on_body_entered(body: Node3D):
    self.entered_bodies.append(body)

func on_body_exited(body: Node3D):
    self.entered_bodies.erase(body)

func is_in_range():
    var player_pos: Vector3 = self.player.global_position
    player_pos.y = 0
    var self_position: Vector3 = self.global_transform.origin
    self_position.y = 0

    return (
        self.global_position.distance_squared_to(self.player.global_position) <= self.range * self.range
    )
