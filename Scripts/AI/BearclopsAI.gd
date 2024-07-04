class_name BearclopsAI extends CharacterBody3D

signal state_changed(agent: BearclopsAI, old_state: State, new_state: State)

enum State {IDLE, PURSUIT, DEAD, ATTACK, STUN, TELEKINESIS_ATTACK}

@export var detect_radius: float = 10.0
@export var attack_range: float = 2.0

@onready var health: Health = $Health
@onready var spawn_position: Vector3 = self.global_position
@onready var pursue_target_ai: PursueTargetAI = $PursueTargetAI
@onready var area_attack: AreaAttack = $AreaAttack
@onready var telekinesis_attack: BearclopsTelekinesisAttack = $TelekinesisAttack

var player: Node3D
var current_state: State = State.IDLE


func _ready() -> void:
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.health.health_lost.connect(self.on_health_lost)
    self.area_attack.attack_finished.connect(self.on_attack_finished)


func _physics_process(delta: float) -> void:
    match self.current_state:
        State.IDLE:
            self.idle()
        State.ATTACK:
            self.attack()
        State.PURSUIT:
            self.persue_player()
        State.DEAD:
            self.dead()
        State.ATTACK:
            self.attack()
        State.STUN:
            self.stun()
        State.TELEKINESIS_ATTACK:
            self.perform_telekinesis_attack(delta)


func idle() -> void:
    self.pursue_target_ai.set_enabled(true)
    self.telekinesis_attack.set_enabled(false)
    self.pursue_target_ai.set_target(self.spawn_position)
    if self.global_position.distance_squared_to(self.player.global_position) <= self.detect_radius * self.detect_radius:
        self.set_state(State.PURSUIT)


func persue_player() -> void:
    self.telekinesis_attack.set_enabled(false)
    self.pursue_target_ai.set_enabled(true)
    var distance_sqr_to_player: float = self.global_position.distance_squared_to(self.player.global_position)

    if distance_sqr_to_player > self.detect_radius * self.detect_radius:
        self.set_state(State.IDLE)
    else:
        self.pursue_target_ai.set_target(self.player.global_position)
    
    if self.telekinesis_attack.can_attack():
        self.set_state(State.TELEKINESIS_ATTACK)
    elif distance_sqr_to_player < self.attack_range * self.attack_range:
        self.set_state(State.ATTACK)


func attack() -> void:
    self.pursue_target_ai.set_enabled(false)
    self.telekinesis_attack.set_enabled(false)
    if !self.area_attack.is_attacking:
        self.area_attack.perform_attack()


func dead() -> void:
    self.telekinesis_attack.set_enabled(false)
    self.pursue_target_ai.set_enabled(false)


func stun() -> void:
    self.telekinesis_attack.set_enabled(false)
    self.pursue_target_ai.set_enabled(false)


func perform_telekinesis_attack(delta: float) -> void:
    self.pursue_target_ai.set_enabled(false)
    self.pursue_target_ai.set_target(self.player.global_position)
    self.pursue_target_ai.look_at_target(delta)
    self.telekinesis_attack.set_enabled(true)
    if !self.telekinesis_attack.can_attack():
        self.set_state(State.PURSUIT)


func on_health_lost() -> void:
    self.set_state(State.DEAD)


func on_attack_finished() -> void:
    self.set_state(State.IDLE)


func set_state(new_state: State) -> void:
    var old_state: State = self.current_state
    self.current_state = new_state
    self.state_changed.emit(self, old_state, new_state)
