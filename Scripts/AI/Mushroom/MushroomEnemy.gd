class_name mushroomAI extends EnemyAI

signal mushroom_state_changed(agent: EnemyAI,
 old_state: Mushroom_State, new_state: Mushroom_State)

signal died(midjump: bool)

@export var hide_attack: AIMeleeAttack
@export var combat_attack: AIMeleeAttack
@export var jump_attack: AIDefaultAttack
@export var attack_cooldown: float = 2
@export var jump_distance: float = 5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
enum Mushroom_State {HIDE, JUMP, COMBAT}
var seen: bool = false
var soaring: bool = false
var current_mushroom_state: Mushroom_State
var attack_timer: float = 0

func _ready():
    set_mushroom_state(Mushroom_State.HIDE)
    set_state(State.PERSUIT)
    self.player = self.get_tree().get_first_node_in_group("Player")
    health.damage_taken.connect(on_damage_taken)
    health.health_lost.connect(on_health_lost)
    combat_attack.attack_finished.connect(on_combat_attack_finished)
    hide_attack.attack_finished.connect(on_hide_attack_finished)
    jump_attack.attack_finished.connect(on_jump_attack_finished)
    jump_attack.jumped.connect(on_jump_attack_started)

func on_damage_taken(damage: float):
    if current_state == State.STUN:
        return
    self.set_state(State.STUN)
    health.visible = true

func on_health_lost():
    self.set_state(State.DEAD)
    died.emit(current_mushroom_state == Mushroom_State.JUMP && soaring)

func on_combat_attack_finished():
    finish_attack()

func on_hide_attack_finished():
    finish_attack()
    set_mushroom_state(Mushroom_State.COMBAT)

func on_jump_attack_finished():
    #soaring = false
    #set_mushroom_state(Mushroom_State.COMBAT)
    #finish_attack()
    velocity.x = 0
    velocity.z = 0

func finish_attack() -> void:
    attack_timer = attack_cooldown
    set_state(State.PERSUIT)

func on_jump_attack_started() -> void:
    soaring = true
    var duration: float = jump_attack.attack_duration
    velocity = (player.position - position) / duration
    velocity += player.velocity
    velocity.y = duration * gravity / 2
    self.pursue_target_ai.set_enabled(false)

func set_mushroom_state(new_state: Mushroom_State) -> void:
    if current_state == State.DEAD:
        return
    var old_state: Mushroom_State = self.current_mushroom_state
    self.current_mushroom_state = new_state
    health.visible = true
    match new_state:
        Mushroom_State.HIDE:
            ai_default_attack = hide_attack
            health.visible = false
        Mushroom_State.COMBAT:
            ai_default_attack = combat_attack
        Mushroom_State.JUMP:
            ai_default_attack = jump_attack
            jump_attack.perform_attack()
    self.mushroom_state_changed.emit(self, old_state, new_state)

func _physics_process(delta: float) -> void:
    attack_timer -= delta
    match self.current_state:
        State.STUN:
            self.remain_still()
        State.ATTACK:
            self.attack(delta)
        State.DEAD:
            be_dead(delta)
        _:
            match self.current_mushroom_state:
                Mushroom_State.HIDE:
                    hiding()
                Mushroom_State.JUMP:
                    jump(delta)
                Mushroom_State.COMBAT:
                    combat(delta)

func hiding():
    var distance: float = self.global_position.distance_to(player.global_position)
    if(distance < hide_attack.range && attack_timer <= 0):
        set_state(State.ATTACK)
        ai_default_attack = hide_attack
        pursue_target_ai.set_enabled(true)

    elif jump_distance < distance && distance < detect_radius && not seen:
        set_mushroom_state(Mushroom_State.JUMP)

func be_dead(delta: float):
    remain_still()
    if(soaring):
        soar(delta)

func soar(delta: float):
    velocity.y -= gravity * delta
    move_and_slide()
    if(is_on_floor() && velocity.y <= 0):
        soaring = false
        set_mushroom_state(Mushroom_State.COMBAT)
        finish_attack()

func jump(delta: float):
    if soaring:
        self.pursue_target_ai.set_enabled(false)
        soar(delta)
    else:
        self.pursue_target_ai.set_target(self.player.global_position)
        self.pursue_target_ai.look_at_target(delta)

func combat(delta: float):
    match(current_state):
        State.WANDER:
            self.pursue_target_ai.set_enabled(false)
            var distance: float = self.global_position.distance_to(player.global_position)
            if distance > detect_radius && not seen:
                set_mushroom_state(Mushroom_State.HIDE)
        State.PERSUIT:
            self.pursue_target_ai.set_enabled(true)
            self.pursue_target_ai.set_target(self.player.global_position)
        _:
            pass
    check_zone()

func check_zone() -> void:
    var dist = self.global_position.distance_squared_to(self.player.global_position)
    if dist > self.detect_radius * self.detect_radius:
        self.set_state(State.WANDER)
    elif attack_timer <= 0 && dist > jump_distance * jump_distance:
        set_mushroom_state(Mushroom_State.JUMP)
    elif attack_timer <= 0 && self.ai_default_attack.is_in_range():
        self.set_state(State.ATTACK)
    else:
        self.set_state(State.PERSUIT)

func on_screen_entered():
    seen = true


func _on_screen_exited():
    seen = false


func _on_animation_finished(anim_name):
    match anim_name:
        "DamagedWhileHiding", "Ouchie":
            set_mushroom_state(Mushroom_State.COMBAT)
            set_state(State.PERSUIT)

