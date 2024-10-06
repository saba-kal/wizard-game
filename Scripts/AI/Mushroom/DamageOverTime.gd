extends Area3D

@export var damage_per_second = 20
@export var source: CharacterBody3D
var active: bool = false
var entered_bodies: Array[Node3D] = []

func _ready():
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)


func _process(delta):
    if active:
        for body in entered_bodies:
            var health = Util.get_child_node_of_type(body, Health)
            health.take_damage(damage_per_second * delta / (source.position.distance_to(body.position)))


func on_body_entered(body: Node3D):
    var health = Util.get_child_node_of_type(body, Health)
    if health != null and not(body is mushroomAI):
        entered_bodies.append(body)


func on_body_exited(body: Node3D):
    if body != null && entered_bodies.has(body):
        entered_bodies.erase(body)
