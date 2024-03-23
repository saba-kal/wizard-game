class_name ProjectileAttack extends AIDefaultAttack

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 10
@export var range: float = 20

@onready var player = self.get_tree().get_first_node_in_group("Player")


func attack() -> void:
    var projectile: Projectile = self.projectile_scene.instantiate()
    projectile.direction = self.global_position.direction_to(self.player.global_position + Vector3(0, 1, 0))
    projectile.speed = self.projectile_speed
    self.get_tree().root.add_child(projectile)
    projectile.global_position = self.global_position


func is_in_range() -> bool:
    var player_pos: Vector3 = self.player.global_position
    player_pos.y = 0
    var self_position: Vector3 = self.global_transform.origin
    self_position.y = 0

    var direction_to_target: Vector3 = self_position.direction_to(player_pos)
    var facing_direction: Vector3 = self.global_transform.basis.z

    return (
        self.global_position.distance_squared_to(self.player.global_position) <= self.range * self.range &&
        abs(direction_to_target.x - facing_direction.x) < 0.1 &&
        abs(direction_to_target.y - facing_direction.y) < 0.1
    )
