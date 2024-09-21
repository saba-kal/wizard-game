@tool
class_name ProjectedPlane extends Node3D

@export_range(1.0, 100.0) var size_x: float = 10.0
@export_range(1.0, 100.0) var size_y: float = 10.0
@export_range(1, 30) var resolution_x: int = 10
@export_range(1, 30) var resolution_y: int = 10
@export var projection_start_height: float = 2.5
@export var projection_end_height: float = -2.5
@export_flags_3d_physics var collision_mask: int = 1

@export_category("DEBUG")
@export var project_plane_onto_surface: bool:
    get:
        return false
    set(value):
        self.project_plane()


func _ready() -> void:
    await get_tree().physics_frame
    self.project_plane()


func project_plane() -> void:
    self.update_plane_mesh_resolution()
    self.update_plane_mesh_size()
    # self.update_ray_casts()
    self.update_shader(true)


func update_plane_mesh_resolution() -> void:
    var plane_mesh: PlaneMesh = $PlaneMesh.mesh
    plane_mesh.subdivide_width = self.resolution_x - 1
    plane_mesh.subdivide_depth = self.resolution_y - 1


func update_plane_mesh_size() -> void:
    var plane_mesh: PlaneMesh = $PlaneMesh.mesh
    plane_mesh.size = Vector2(self.size_x, self.size_y)


func update_ray_casts() -> void:
    var raycast_container: Node3D = $RayCasts
    for child in raycast_container.get_children():
        child.free()
    for yi: int in range(self.resolution_y + 1):
        for xi: int in range(self.resolution_x + 1):
            var ray_cast: ProjectedPlaneRayCast = ProjectedPlaneRayCast.new()
            raycast_container.add_child(ray_cast)
            ray_cast.owner = self
            ray_cast.name = "RayCast_%d_%d" % [xi, yi]
            ray_cast.x_index = xi
            ray_cast.y_index = yi
            self.update_ray_cast(ray_cast)


func update_ray_cast(ray_cast: ProjectedPlaneRayCast) -> void:

    #Ray starting position
    var offset_x: float = self.resolution_x / 2.0
    var offset_y: float = self.resolution_y / 2.0
    ray_cast.position.x = (float(ray_cast.x_index - offset_x) / self.resolution_x) * self.size_x
    ray_cast.position.y = self.projection_start_height
    ray_cast.position.z = (float(ray_cast.y_index - offset_y) / self.resolution_y) * self.size_y

    #Ray endpoint
    ray_cast.target_position = Vector3(0, self.projection_end_height - self.projection_start_height, 0)


func update_shader(force_raycast: bool) -> void:
    var raycast_container: Node3D = $RayCasts
    var heightmap = Image.create(self.resolution_x + 1, self.resolution_y + 1, false, Image.FORMAT_RGB8)

    for yi: int in range(self.resolution_y + 1):
        for xi: int in range(self.resolution_x + 1):
            var collision_point = self.cast_ray(xi, yi)
            var height = inverse_lerp(self.projection_start_height, self.projection_end_height, collision_point.y)
            printt(self.projection_start_height, self.projection_end_height, collision_point.y, height)
            heightmap.set_pixel(xi, yi, Color(height, height, height, 1.0))

    var mesh_instance: MeshInstance3D = $PlaneMesh
    var material: Material = mesh_instance.get_surface_override_material(0)
    var texture: ImageTexture = ImageTexture.create_from_image(heightmap)
    material.set("shader_parameter/heightmap", texture)
    material.set("shader_parameter/min_height", self.projection_start_height)
    material.set("shader_parameter/max_height", self.projection_end_height)


func cast_ray(x_index: int, y_index: int) -> Vector3:

    var offset_x: float = self.resolution_x / 2.0
    var offset_y: float = self.resolution_y / 2.0
    var from_position: Vector3 = self.global_position + Vector3(
        (float(x_index - offset_x) / self.resolution_x) * self.size_x,
        self.projection_start_height,
        (float(y_index - offset_y) / self.resolution_y) * self.size_y
    )
    var to_position: Vector3 = Vector3(
        from_position.x,
        self.global_position.y + self.projection_end_height,
        from_position.z
    )

    var worldspace = self.get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from_position, to_position, self.collision_mask)
    var result = worldspace.intersect_ray(query)
    print(result)
    if result:
        var ground_pos: Vector3 = result["position"]
        return ground_pos - self.global_position

    return from_position
