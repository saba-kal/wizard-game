class_name mushroomAI extends EnemyAI

signal mushroom_state_changed(agent: EnemyAI,
 old_state: Mushroom_State, new_state: Mushroom_State)

@export var hide_attack: AIMeleeAttack
@export var combat_attack: AIMeleeAttack

enum Mushroom_State {HIDE, JUMP, COMBAT}
var seen: bool = false
var current_mushroom_state: Mushroom_State

func _ready():
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.health.damage_taken.connect(self.on_damage_taken)

func on_damage_taken():
    pass

func on_health_lost():
    self.set_state(State.DEAD)

func set_mushroom_state(new_state: Mushroom_State):
    var old_state = self.current_mushroom_state
    self.current_mushroom_state = new_state
    self.mushroom_state_changed.emit(self, old_state, new_state)

func _physics_process(delta: float):
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
    if(distance < hide_attack.range):
        set_state(State.ATTACK)
        ai_default_attack = hide_attack
        pursue_target_ai.set_enabled(true)

func jump(delta: float):
    pass

func combat(delta: float):
    pass

func on_screen_entered():
    seen = true


func _on_screen_exited():
    seen = false
