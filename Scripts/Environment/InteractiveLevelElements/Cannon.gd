class_name Cannon extends Node3D

@export var projectile_speed: float = 50.0
@export var projectile_damage: float = 100.0
@export var projectile_gravity: float = 9.8
@export var time_until_aim: float = 5.0
@export var time_until_fire: float = 10.0
@export var player_fire_duration: float = 6.0
@export var default_projectile_scene: PackedScene

@onready var entrance_area: Area3D = $EntranceArea
@onready var player_projectile_start_pos: Marker3D = $PlayerProjectileStartPosition
@onready var cannon_projectile_start_pos: Marker3D = $CannonVisuals/Barrel/CannonProjectileStartPosition
@onready var player_exit_pos: Marker3D = $PlayerExitPosition
@onready var barrel: Node3D = $CannonVisuals/Barrel
@onready var barrel_collider: StaticBody3D = $CannonVisuals/Barrel/StaticBody3D
@onready var wagon_collider: StaticBody3D = $WagonCollider
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player: PlayerController
var player_flammible: Flammable
var player_projectile: PlayerSelfProjectile
var is_player_attached_to_cannon: bool = false
var timer_started: bool = false
var elapsed_time: float = 0
var projectile_velocity: Vector3


func _ready() -> void:
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.player_flammible = Util.get_child_node_of_type(self.player, Flammable)
    self.player_projectile = Util.get_child_node_of_type(self.player, PlayerSelfProjectile)
    self.entrance_area.body_entered.connect(self.on_entrance_area_body_entered)


func _process(delta: float) -> void:
    if self.timer_started:
        self.elapsed_time += delta

    if self.is_player_attached_to_cannon:
        self.player.global_position = self.player_projectile_start_pos.global_position
        self.player.global_rotation = self.barrel.global_rotation
        self.player.rotate_object_local(Vector3.LEFT, -PI / 2.0)

    if self.elapsed_time >= self.time_until_fire:
        self.fire_cannon()


# This method is called by the FlammableCannon node.
func start_timer() -> void:
    if self.timer_started:
        return
    self.timer_started = true
    await get_tree().create_timer(self.time_until_aim).timeout
    self.animation_player.play("aim_cannon")


func fire_cannon() -> void:
    self.elapsed_time = 0
    self.timer_started = false
    if self.is_player_attached_to_cannon:
        self.fire_player_projectile()
    else:
        self.fire_cannon_projectile()
    await get_tree().create_timer(1.0).timeout
    self.animation_player.play("reset_cannon")


func fire_cannon_projectile() -> void:
    var projectile: Projectile = self.default_projectile_scene.instantiate()
    projectile.direction = self.barrel.global_transform.basis.z
    projectile.speed = self.projectile_speed
    projectile.damage = self.projectile_damage
    projectile.projectile_gravity = self.projectile_gravity
    projectile.collided.connect(self.on_projectile_collided)
    self.get_tree().root.add_child(projectile)
    projectile.global_position = self.cannon_projectile_start_pos.global_position


func fire_player_projectile() -> void:
    self.is_player_attached_to_cannon = false
    self.player.set_player_disabled(false)
    self.player_projectile.fire(self.barrel.global_transform.basis.z, self.projectile_speed, self.projectile_gravity)
    self.player_flammible.start_fire(self.player_fire_duration)
    SignalBus.player_fired_from_cannon.emit(self)


func remove_player_from_cannon() -> void:
    if self.is_player_attached_to_cannon:
        self.player.global_position = self.player_exit_pos.global_position
        self.is_player_attached_to_cannon = false
        SignalBus.player_exited_cannon.emit(self)


func on_entrance_area_body_entered(body: Node3D) -> void:
    if not body is PlayerController:
        return
    self.player.set_player_disabled(true)
    self.player.global_position = self.player_projectile_start_pos.global_position
    self.player.rotation = Vector3(PI / 2.0, 0, 0)
    self.is_player_attached_to_cannon = true
    SignalBus.player_entered_cannon.emit(self)
    call_deferred("temporarily_disabled_colliders")


func on_projectile_collided(body: Node3D) -> void:
    if body.is_in_group("DestructibleTower"):
        SignalBus.mushroom_valley_tower_hit.emit()


func temporarily_disabled_colliders() -> void:
    # This is so that the player does not collide with the cannon while inside the cannon.
    self.disable_colliders()
    await get_tree().create_timer(self.time_until_fire + 2.0).timeout
    self.enable_colliders()


func disable_colliders() -> void:
    self.entrance_area.process_mode = Node.PROCESS_MODE_DISABLED
    self.barrel_collider.process_mode = Node.PROCESS_MODE_DISABLED
    self.wagon_collider.process_mode = Node.PROCESS_MODE_DISABLED


func enable_colliders() -> void:
    self.entrance_area.process_mode = Node.PROCESS_MODE_INHERIT
    self.barrel_collider.process_mode = Node.PROCESS_MODE_INHERIT
    self.wagon_collider.process_mode = Node.PROCESS_MODE_INHERIT
