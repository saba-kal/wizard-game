class_name Floating extends Node3D

@export var force: float = 3.5
var parent: RigidBody3D
# Called when the node enters the scene tree for the first time.
func _ready():
    var parent = get_parent_node_3d()
    if(parent is RigidBody3D):
        self.parent = parent
    else:
        print("error: Floating must have a RigidBody parent")
        queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var points = Util.get_child_nodes_of_type(self, RayCast3D)
    for point: RayCast3D in points:
        if(point.is_colliding()):
            parent.apply_force(Vector3(0, force * parent.mass, 0), point.global_position - parent.global_position)
