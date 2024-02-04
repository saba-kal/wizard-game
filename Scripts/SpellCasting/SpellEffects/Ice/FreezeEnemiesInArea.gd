extends Area3D

@export var duration: float = 5
@export var status_damage: float = 50


func _ready():
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    var freezable_node: Freezable = Util.get_child_node_of_type(body, Freezable)
    if freezable_node != null:
        freezable_node.start_freeze(self.duration, self.status_damage, self)
