extends Node

@export var max_strength: float = 0.5

@onready var camera: Camera3D = self.get_parent()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var current_strength: float = 0
var shake_fade: float = 5.0


func _ready() -> void:
    SignalBus.mushroom_valley_tower_hit.connect(self.on_mushroom_valley_tower_hit)
    SignalBus.mushroom_valley_tower_destruction_started.connect(self.on_mushroom_valley_tower_destruction_started)


func _process(delta: float) -> void:

    if self.current_strength > 0:
        # fade down the camera shake
        self.current_strength = lerpf(self.current_strength, 0, self.shake_fade * delta)
        # fapply the shake shake
        self.camera.h_offset = rng.randf_range(-self.current_strength, self.current_strength)
        self.camera.v_offset = rng.randf_range(-self.current_strength, self.current_strength)


func shake_camera() -> void:
    self.current_strength = self.max_strength


func on_mushroom_valley_tower_hit() -> void:
    # Different events should have different amount of camera shake duration.
    # This is why we are not directly calling shake_camera
    self.shake_fade = 3.0
    self.shake_camera()

func on_mushroom_valley_tower_destruction_started() -> void:
    self.shake_fade = 1.0
    self.shake_camera()
