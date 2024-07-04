class_name Water extends Area3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func get_water_height() -> float:
    var box_shape: BoxShape3D = self.collision_shape.shape
    return self.collision_shape.global_position.y + box_shape.size.y / 2.0 * self.scale.y
