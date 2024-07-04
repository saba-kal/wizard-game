extends RigidBody3D

@export var accel_tolerance: float = 9
var prev_velocity: Vector3
var first_frame: bool = true

func _process(delta):
    var veldiff: float = prev_velocity.distance_to(linear_velocity)
    if(first_frame):
        lock_rotation = false
    else:
        if(veldiff > accel_tolerance):
            get_parent_node_3d().queue_free()
    prev_velocity = linear_velocity
