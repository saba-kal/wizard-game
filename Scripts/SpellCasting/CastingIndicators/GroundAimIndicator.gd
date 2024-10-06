class_name GroundAimIndicator extends Node3D

@export var valid_color: Color = Color.SKY_BLUE
@export var invalid_color: Color = Color.RED
@export_flags_3d_physics var collision_mask: int = 1

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var disabled: bool = true
var camera: Camera3D
var max_distance: float = 20.0 #This will be overriden by GroundSummonSpell.gd
var flat_ground_check_height: float = 0.5
var flat_ground_normal_check: float = 0.5
var is_valid: bool = false


func _ready() -> void:
    self.camera = self.get_viewport().get_camera_3d()


func _process(delta: float) -> void:
    if disabled:
        return
    var ray_cast_pos = self.get_raycast_position_from_camera()
    self.is_valid = self.is_position_on_flat_ground(ray_cast_pos)
    self.global_position = ray_cast_pos

    var color: Color
    if self.is_valid:
        color = self.valid_color
    else:
        color = self.invalid_color
    self.mesh_instance.get_surface_override_material(0).set("shader_parameter/color", color)


func get_raycast_position_from_camera() -> Vector3:
    var screen_center: Vector2 = self.camera.get_viewport().get_visible_rect().size / 2
    var from: Vector3 = self.camera.project_ray_origin(screen_center)
    var to: Vector3 = from + self.camera.project_ray_normal(screen_center) * self.max_distance
    var worldspace = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to, self.collision_mask)
    query.collide_with_areas = true
    var result = worldspace.intersect_ray(query)
    if result:
        return result["position"]
    else:
        result = self.get_down_raycast_result(to, 100)
        if result:
            return result["position"]
        return self.global_position


func is_position_on_flat_ground(target_position: Vector3) -> bool:
    var from: Vector3 = target_position
    from.y += self.flat_ground_check_height
    var result = self.get_down_raycast_result(from, self.flat_ground_check_height + 0.1)
    if result:
        var normal: Vector3 = result["normal"]
        # Ensure the collision normal is pointing up.
        return (
            normal.x > -self.flat_ground_normal_check && normal.x < self.flat_ground_normal_check &&
            normal.y > 1.0 - self.flat_ground_normal_check && normal.y < 1.0 + self.flat_ground_normal_check &&
            normal.z > -self.flat_ground_normal_check && normal.z < self.flat_ground_normal_check
        )
    return false


func get_down_raycast_result(from_pos: Vector3, distance: float) -> Variant:
    var to_pos: Vector3 = from_pos
    to_pos.y -= distance
    var worldspace = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos, self.collision_mask)
    var result = worldspace.intersect_ray(query)
    return result


func set_indicator_visible(is_visible: bool) -> void:
    self.disabled = !is_visible
    self.visible = is_visible
