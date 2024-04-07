extends Flammable

@export var burn_duration: float = 5.0
@export var mesh_instance: MeshInstance3D

var shader_material: ShaderMaterial
var burn_started: bool = true


func _ready() -> void:
    self.shader_material = self.mesh_instance.get_active_material(0)


func _process(delta: float) -> void:
    super._process(delta)
    if self.fire_started:
        var dissolve_value: float = clamp(1 - self.time_since_fire / self.burn_duration - 0.1, 0, 1)
        self.shader_material.set_shader_parameter("dissolve_value", dissolve_value)


func light():
    # NOTE: burn duration is different from the fire duration found in the Flammable script.
    # I wanted this fire's duration to be configurable separately from the other one.
    self.duration = self.burn_duration


func extinguish():
    self.get_parent().queue_free()
