class_name PlayerSwimming extends Area3D

@export var float_height: float = 0.0
@export var water_density: float = 0.4
@export var dampening_factor: float = 2.0
@export var max_sink_speed: float = 5.0
@export var max_float_speed: float = 10.0
@export var state_change_cooldown: float = 0.5


var player_movement: PlayerMovement
var is_swimming: bool = false
var global_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var entered_water_body: Water
var time_since_last_state_change: float = 100.0


func _ready():
    self.player_movement = Util.get_child_node_of_type(self.get_parent(), PlayerMovement)
    self.area_entered.connect(self.on_area_entered)
    self.area_exited.connect(self.on_area_exited)


func _physics_process(delta: float):

    if self.is_swimming && self.time_since_last_state_change > self.state_change_cooldown:

        var water_level: float = self.entered_water_body.get_water_height()
        var displacement: float = max(0.0, water_level - self.global_position.y + self.float_height)
        var submerged_volume: float = displacement * 1.3 # 1.3 is the volume of the player's capsule collider
        var buoyant_force: float = submerged_volume * self.water_density * self.global_gravity * delta;
        self.player_movement.apply_vertical_velocity(buoyant_force)

        if self.player_movement.get_velocity().y < -self.max_sink_speed:
            self.player_movement.set_vertical_velocity(-self.max_sink_speed)

        var vertical_velocity: float = self.player_movement.get_velocity().y
        self.player_movement.apply_vertical_velocity(-vertical_velocity * self.dampening_factor * delta)
    else:
        self.player_movement.gravity_adjustment = 0

    self.time_since_last_state_change += delta


func on_area_entered(area: Area3D):
    if area is Water:
        self.time_since_last_state_change = 0
        self.is_swimming = true
        self.entered_water_body = area
        var depth: float = self.entered_water_body.get_water_height() - self.global_position.y
        self.player_movement.apply_vertical_velocity(clamp(depth, 0, self.max_float_speed))
        SignalBus.player_swim_mode_changed.emit(true)


func on_area_exited(area: Area3D):
    if area is Water:
        self.time_since_last_state_change = 0
        self.is_swimming = false
        self.entered_water_body = null
        SignalBus.player_swim_mode_changed.emit(false)
