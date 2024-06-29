extends Node3D

@export var rotation_speed: float = 10.0

var random_vector: Vector3


func _ready() -> void:

    # Set initial rotation to something random.
    self.rotation = Vector3(
        randf_range(0, TAU),
        randf_range(0, TAU),
        randf_range(0, TAU)
    )

    # Generate random unit vector which will represent the axis we will rotate around.
    self.random_vector = Vector3(
        randf_range(-1.0, 1.0),
        randf_range(-1.0, 1.0),
        randf_range(-1.0, 1.0)
    ).normalized()


func _process(delta: float) -> void:
    self.rotate(self.random_vector, self.rotation_speed * delta)
