class_name EnemyAI extends CharacterBody3D

signal state_changed(agent: EnemyAI, old_state: State, new_state: State)

enum State {WANDER, PERSUIT, STUN}

@export var speed: float = 200.0
@export var turn_speed: float = 20.0
@export var detect_radius: float = 10.0
@export var ai_wander_area: AIWanderArea

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: Health = $Health
@onready var spawn_position: Vector3 = self.global_position

var player: Node3D
var nav_server_ready: bool = false
var current_state: State = State.WANDER
var move_target_position: Vector3


func _ready():
    self.player = self.get_tree().get_first_node_in_group("Player")
    if self.ai_wander_area != null:
        self.ai_wander_area.register_agent(self)
    self.health.health_lost.connect(self.on_health_lost)
    call_deferred("actor_setup")


func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame
    self.nav_server_ready = true


func _physics_process(delta):
    match self.current_state:
        State.WANDER:
            self.wander()
        State.PERSUIT:
            self.persue_player()
        State.STUN:
            self.remain_still()
    if self.current_state != State.STUN:
        self.process_nav_agent(delta)
        self.look_at_target(delta)


func persue_player():
    if self.global_position.distance_squared_to(self.player.global_position) > self.detect_radius * self.detect_radius:
        self.set_state(State.WANDER)
    else:
        self.move_target_position = self.player.global_position


func wander():
    if self.global_position.distance_squared_to(self.player.global_position) <= self.detect_radius * self.detect_radius:
        self.set_state(State.PERSUIT)
    elif self.ai_wander_area != null:
        self.move_target_position = self.ai_wander_area.get_next_wonder_position(self)
    else:
        self.move_target_position = self.spawn_position


func remain_still():
    self.move_target_position = self.global_position


func process_nav_agent(delta):
    if !self.nav_server_ready:
        return
    self.nav_agent.target_position = self.move_target_position
    var next_nav_point = self.nav_agent.get_next_path_position()
    if self.nav_agent.is_navigation_finished():
        return
    self.velocity = (next_nav_point - self.global_position).normalized() * self.speed * delta
    self.move_and_slide()


func look_at_target(delta):
    var look_position = Vector3(self.move_target_position.x, self.global_position.y, self.move_target_position.z)
    if look_position.distance_squared_to(self.global_position) > 1:
        self.transform = self.transform.interpolate_with(self.transform.looking_at(look_position, Vector3.UP, true), delta * turn_speed)


func set_state(new_state: State):
    var old_state = self.current_state
    self.current_state = new_state
    self.state_changed.emit(self, old_state, new_state)


func on_health_lost():
    self.queue_free()
