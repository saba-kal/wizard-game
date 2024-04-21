extends AnimationTree

var prev_is_on_floor: bool = true
var player_movement: PlayerMovement
var health: Health
var is_swimming: bool
var mana_regen_is_active: bool = false


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
        self.process_swim_animations()
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


func process_swim_animations() -> void:
    var horizontal_velocity: Vector3 = self.player_movement.get_velocity()
    horizontal_velocity.y = 0
    if horizontal_velocity.length_squared() > 0.1:
        self.set("parameters/state/transition_request", "swim")
    else:
        self.set("parameters/state/transition_request", "float")


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
