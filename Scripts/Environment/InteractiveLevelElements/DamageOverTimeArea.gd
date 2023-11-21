extends Area3D

@export var damage_per_second: float = 5

var entered_healths: Array[Health] = []


func _ready():
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)


func _process(delta):
    for health in self.entered_healths:
        health.take_damage(self.damage_per_second * delta)


func on_body_entered(body: Node3D):
    var health = Util.get_child_node_of_type(body, Health)
    if health != null:
        self.entered_healths.append(health)


func on_body_exited(body: Node3D):
    var health = Util.get_child_node_of_type(body, Health)
    if health != null && self.entered_healths.has(health):
        self.entered_healths.erase(health)
