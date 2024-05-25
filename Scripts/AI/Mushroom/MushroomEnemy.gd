class_name mushroomAI extends EnemyAI

signal mushroom_state_changed(agent: EnemyAI,
 old_state: Mushroom_State, new_state: Mushroom_State)

@export var hide_attack: AIMeleeAttack
@export var combat_attack: AIMeleeAttack
@export var jump_attatck: AIDefaultAttack
@export var attack_cooldown: float = 2
@export var jump_distance: float = 5

enum Mushroom_State {HIDE, JUMP, COMBAT}
var seen: bool = false
var current_mushroom_state: Mushroom_State
var attack_timer = 0

func _ready():
    set_mushroom_state(Mushroom_State.HIDE)
    set_state(State.PERSUIT)
    self.player = self.get_tree().get_first_node_in_group("Player")
    health.damage_taken.connect(on_damage_taken)
    combat_attack.attack_finished.connect(on_combat_attack_finished)
    hide_attack.attack_finished.connect(on_hide_attack_finished)
    jump_attatck.attack_finished.connect(on_jump_attack_finished)

func on_damage_taken(damage: float):
    self.set_state(State.STUN)

func on_health_lost():
    self.set_state(State.DEAD)

func on_combat_attack_finished():
    finish_attack()

func on_hide_attack_finished():
    finish_attack()

func on_jump_attack_finished():
    finish_attack()

func finish_attack():
    attack_timer = attack_cooldown
    set_state(State.PERSUIT)


func set_mushroom_state(new_state: Mushroom_State):
    var old_state = self.current_mushroom_state
    self.current_mushroom_state = new_state
    match new_state:
        Mushroom_State.HIDE:
            ai_default_attack = hide_attack
        Mushroom_State.COMBAT:
            ai_default_attack = combat_attack
        Mushroom_State.JUMP:
            ai_default_attack = jump_attatck
    self.mushroom_state_changed.emit(self, old_state, new_state)

func _physics_process(delta: float):
    attack_timer -= delta
    match self.current_state:
        State.STUN:
            self.remain_still()
        State.ATTACK:
            self.attack(delta)
        State.DEAD:
            self.remain_still()
        _:
            match self.current_mushroom_state:
                Mushroom_State.HIDE:
                    hiding()
                Mushroom_State.JUMP:
                    jump(delta)
                Mushroom_State.COMBAT:
                    combat(delta)

func hiding():
    var distance = self.global_position.distance_to(player.global_position)
    if(distance < hide_attack.range && attack_timer <= 0):
        set_state(State.ATTACK)
        ai_default_attack = hide_attack
        pursue_target_ai.set_enabled(true)

func jump(delta: float):
    pass

func combat(delta: float):
    match(current_state):
        State.WANDER:
            self.pursue_target_ai.set_enabled(false)
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
    elif attack_cooldown <= 0 && dist > jump_distance * jump_distance:
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

