extends Area3D

@export var duration: float = 5
@export var status_damage: float = 33


func _ready():
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    var flammable_nodes: Array = Util.get_child_nodes_of_type(body, Flammable)
    for flammable_node in flammable_nodes:
        flammable_node.start_fire(self.duration, self.status_damage, self)
