extends Node3D

var camera: Camera3D


func _ready():
    self.camera = self.get_viewport().get_camera_3d()


func _process(delta):
    var screen_center = self.camera.get_viewport().get_visible_rect().size / 2
    var from = self.camera.project_ray_origin(screen_center)
    var to = from + self.camera.project_ray_normal(screen_center) * 1000
    var worldspace = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to)
    var result = worldspace.intersect_ray(query)
    if result:
        self.global_position = result["position"]
