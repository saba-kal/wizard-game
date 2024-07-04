class_name ProjectileAttack extends AIDefaultAttack

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 10
@export var range: float = 20

@onready var player = self.get_tree().get_first_node_in_group("Player")


func attack() -> void:
    var projectile: Projectile = self.projectile_scene.instantiate()
    projectile.direction = self.get_projectile_direction(projectile.projectile_gravity)
    projectile.speed = self.projectile_speed
    projectile.damage = self.damage
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


func get_projectile_direction(projectile_gravity: float) -> Vector3:
    var player_pos = self.player.global_position + Vector3(0, 1, 0) # Offset for player character height.
    if !is_zero_approx(projectile_gravity):
        # Calculating projectile direction when gravity is involved is too complicated.
        # Aiming as if the player was slightly higher is good enough for now.
        player_pos.y += 4
    return self.global_position.direction_to(player_pos)
