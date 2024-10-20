extends Node3D

@export var projectile_speed: float = 50.0
@export var projectile_gravity: float = 9.8
@export var time_until_fire: float = 5.0

@onready var entrance_area: Area3D = $EntranceArea
@onready var projectile_start_pos: Marker3D = $ProjectileStartPosition
@onready var barrel: Node3D = $CannonVisuals/Barrel
@onready var barrel_collider: StaticBody3D = $CannonVisuals/Barrel/StaticBody3D
@onready var wagon_collider: StaticBody3D = $WagonCollider
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player: PlayerController
var player_projectile: PlayerSelfProjectile
var is_player_attached_to_cannon: bool = false
var timer_started: bool = false
var elapsed_time: float = 0
var projectile_fired: bool = false
var projectile_velocity: Vector3


func _ready() -> void:
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.player_projectile = Util.get_child_node_of_type(self.player, PlayerSelfProjectile)
    self.entrance_area.body_entered.connect(self.on_entrance_area_body_entered)


func _process(delta: float) -> void:
    if self.timer_started:
        self.elapsed_time += delta
    
    if self.is_player_attached_to_cannon:
        self.player.global_position = self.projectile_start_pos.global_position
        self.player.global_rotation = self.barrel.global_rotation
        self.player.rotate_object_local(Vector3.LEFT, -PI / 2.0)
        
    if !self.projectile_fired && self.elapsed_time >= self.time_until_fire:
        self.projectile_fired = true
        self.is_player_attached_to_cannon = false
        #self.player.reparent(self.get_tree().root)
        self.player.set_player_disabled(false)
        self.player_projectile.fire(self.barrel.global_transform.basis.z, self.projectile_speed, self.projectile_gravity)


func on_entrance_area_body_entered(body: Node3D) -> void:
    if body is PlayerController:
        body.set_player_disabled(true)
        body.global_position = self.projectile_start_pos.global_position
        #body.reparent(self.barrel)
        body.rotation = Vector3(PI / 2.0, 0, 0)
        self.entrance_area.process_mode = Node.PROCESS_MODE_DISABLED
        self.barrel_collider.process_mode = Node.PROCESS_MODE_DISABLED
        self.wagon_collider.process_mode = Node.PROCESS_MODE_DISABLED
        self.is_player_attached_to_cannon = true
        self.timer_started = true
        self.animation_player.play("aim_cannon")
