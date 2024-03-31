extends AnimationTree

var prev_is_on_floor: bool = true
var player_movement: PlayerMovement
var health: Health
var is_swimming: bool
var mana_regen_is_active: bool = false

@onready var player_model: Node3D = self.get_node("../Visuals/Player")
@onready var original_model_rotation: Vector3 = self.player_model.rotation
@onready var original_model_position: Vector3 = self.player_model.position


func _ready():
    self.player_movement = Util.get_child_node_of_type(self.get_parent(), PlayerMovement)
    SignalBus.player_jumped.connect(self.on_player_jumped)
    SignalBus.player_died.connect(self.on_player_died)
    SignalBus.player_swim_mode_changed.connect(self.on_player_swim_mode_changed)
    SignalBus.spell_cast.connect(self.on_player_cast_spell)
    SignalBus.player_mana_regen_changed.connect(self.on_player_mana_regen_changed)
    self.health = Util.get_child_node_of_type(self.get_parent(), Health)
    if self.health != null:
        self.health.damage_taken.connect(self.on_damage_taken)


func _process(delta: float):
    if self.is_swimming:
        self.process_swim_animations(delta)
    elif !self.player_movement.is_on_floor():
        self.set("parameters/state/transition_request", "fall")
    elif self.player_movement.is_running() && !self.mana_regen_is_active:
        self.set("parameters/state/transition_request", "run")
    elif self.player_movement.is_walking() || self.mana_regen_is_active:
        self.set("parameters/state/transition_request", "walk")
    else:
        self.set("parameters/state/transition_request", "idle")

    if self.prev_is_on_floor == false && self.player_movement.is_on_floor():
        self.set("parameters/land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
    self.prev_is_on_floor = self.player_movement.is_on_floor()
    
    if !self.is_swimming:
        var target_rotation = Quaternion.from_euler(self.original_model_rotation)
        self.player_model.quaternion = self.player_model.quaternion.slerp(target_rotation, delta * 5.0)
        self.player_model.position = self.player_model.position.lerp(self.original_model_position, delta * 5.0)


func process_swim_animations(delta: float) -> void:

     #TODO: replace with actual animation
    var target_rotation = Quaternion.from_euler(Vector3(PI / 4.0, self.original_model_rotation.y, self.original_model_rotation.z))
    var target_position = Vector3(0, -0.17, 1.162)

    var horizontal_velocity: Vector3 = self.player_movement.get_velocity()
    horizontal_velocity.y = 0
    if horizontal_velocity.length_squared() > 0.1:
        self.set("parameters/state/transition_request", "run")
    else:
        self.set("parameters/state/transition_request", "idle")
        target_rotation = Quaternion.from_euler(self.original_model_rotation)
        target_position = self.original_model_position

     #TODO: replace with actual animation
    self.player_model.quaternion = self.player_model.quaternion.slerp(target_rotation, delta * 5.0)
    self.player_model.position = self.player_model.position.lerp(target_position, delta * 5.0)


func on_player_jumped():
    self.set("parameters/jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_damage_taken(damage: float):
    if !self.get("parameters/small_stagger/active"):
        self.set("parameters/small_stagger/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_player_died():
    self.set("parameters/dead_state/transition_request", "dead")


func on_player_swim_mode_changed(new_is_swimming: bool):
    self.is_swimming = new_is_swimming


func on_player_cast_spell(target_is_self: bool):
    var anim_path: String = "parameters/cast_spell_other"
    if target_is_self:
        anim_path = "parameters/cast_spell_self"
    if !self.get(anim_path + "/active"):
        self.set(anim_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_player_mana_regen_changed(mana_regen_is_on: bool):
    self.mana_regen_is_active = mana_regen_is_on
