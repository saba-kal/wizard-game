extends Spell

@export var projectile_speed: float = 10
@export var fire_ball_projectile_scene: PackedScene

var camera: Camera3D


func _ready():
    self.camera = self.get_viewport().get_camera_3d()


func cast_spell(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune):
    var fire_ball: Projectile = self.fire_ball_projectile_scene.instantiate()
    fire_ball.direction = self.get_direction(yellow_rune)
    fire_ball.speed = self.projectile_speed
    self.get_tree().root.add_child(fire_ball)
    fire_ball.global_position = self.global_position


func supports_runes(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune) -> bool:
    return (blue_rune.type == BlueRune.BlueRuneType.FIRE &&
            red_rune.type == RedRune.RedRuneType.DETRIMENT &&
            (
                yellow_rune.type == YellowRune.YellowRuneType.GROUND ||
                yellow_rune.type == YellowRune.YellowRuneType.SELF
            ))


func get_direction(yellow_rune: YellowRune) -> Vector3:
    match yellow_rune.type:
        YellowRune.YellowRuneType.GROUND:
            return self.get_direction_to_screen_center()
        YellowRune.YellowRuneType.SELF:
            return self.get_direction_to_player()
    printerr("Unable to calculate direction for yellow rune type %d" % yellow_rune.type)
    return Vector3.ZERO


func get_direction_to_player() -> Vector3:
    return self.global_position.direction_to(self.get_parent().global_position)


func get_direction_to_screen_center() -> Vector3:
    var screen_center = get_viewport().size / 2
    var from = self.camera.project_ray_origin(screen_center)
    var to = from + self.camera.project_ray_normal(screen_center) * 1000
    var worldspace = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to)
    var result = worldspace.intersect_ray(query)
    if result:
        return self.global_position.direction_to(result["position"])
    return self.global_position.direction_to(to)
