extends Node3D

@onready var area: Area3D = $Area3D

var healed_nodes: Array[Node] = [];


func _ready():
    self.area.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    var healable: Healable = Util.get_child_node_of_type(body, Healable)
    if healable != null && !healed_nodes.has(body):
        healed_nodes.append(body)
        # healing 30 for now, should make this dependant on spell
        healable.healed.emit(30)
