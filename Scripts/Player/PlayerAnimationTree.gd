extends AnimationTree

var prev_is_on_floor: bool = true
var player_movement: PlayerMovement
var is_swimming: bool
var mana_regen_is_active: bool = false
var is_dead: bool = false
var knock_down: KnockDown


func _ready() -> void:
    self.player_movement = Util.get_child_node_of_type(self.get_parent(), PlayerMovement)
    SignalBus.player_jumped.connect(self.on_player_jumped)
    SignalBus.player_died.connect(self.on_player_died)
    SignalBus.player_swim_mode_changed.connect(self.on_player_swim_mode_changed)
    SignalBus.spell_cast.connect(self.on_player_cast_spell)
    SignalBus.player_mana_regen_changed.connect(self.on_player_mana_regen_changed)
    var health: Health = Util.get_child_node_of_type(self.get_parent(), Health)
    if health != null:
        health.damage_taken.connect(self.on_damage_taken)
    self.knock_down = Util.get_child_node_of_type(self.get_parent(), KnockDown)
    if self.knock_down != null:
        self.knock_down.knock_down_started.connect(self.on_knock_down_started)
        self.knock_down.knock_down_ended.connect(self.on_knock_down_ended)


func _process(delta: float) -> void:
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


func on_player_jumped() -> void:
    self.set("parameters/jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_damage_taken(damage: float) -> void:
    if self.knock_down.is_knocked_down || self.get("parameters/small_stagger/active"):
        return
    self.set("parameters/small_stagger/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_player_died() -> void:
    self.set("parameters/dead_state/transition_request", "dead")
    self.is_dead = true


func on_player_swim_mode_changed(new_is_swimming: bool):
    self.is_swimming = new_is_swimming


func on_player_cast_spell(target_is_self: bool) -> void:
    var anim_path: String = "parameters/cast_spell_other"
    if target_is_self:
        anim_path = "parameters/cast_spell_self"
    if !self.get(anim_path + "/active"):
        self.set(anim_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_player_mana_regen_changed(mana_regen_is_on: bool) -> void:
    self.mana_regen_is_active = mana_regen_is_on


func on_knock_down_started() -> void:
    if !self.is_dead:
        self.set("parameters/dead_state/transition_request", "knocked_down")
        self.set("parameters/small_stagger/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

        #start to get back up
        var standup_anime_duration: float = 0.9167
        var duration: float = self.knock_down.knock_down_duration - standup_anime_duration
        await get_tree().create_timer(duration).timeout
        self.set("parameters/KnockDownStateMachine/conditions/start_standup", true)


func on_knock_down_ended() -> void:
    if !self.is_dead:
        self.set("parameters/dead_state/transition_request", "not_dead")
        self.set("parameters/KnockDownStateMachine/conditions/start_standup", false)
