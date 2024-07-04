extends Area3D

@export var duration: float = 60


func _ready():
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    var flammable_nodes = Util.get_child_nodes_of_type(body, Flammable)
    for flammable_node: Flammable in flammable_nodes:
        flammable_node.start_un_fire(self.duration)
