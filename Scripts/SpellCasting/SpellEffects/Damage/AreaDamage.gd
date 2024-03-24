extends Area3D

@export var damage: float = 50.0
@export var disabled: bool = false

func _ready():
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    if self.disabled:
        return
    var health_nodes: Array = Util.get_child_nodes_of_type(body, Health)
    for health_node in health_nodes:
        health_node.take_damage(self.damage)
