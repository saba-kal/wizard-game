extends AnimationTree

@export var hurt_cooldown: float = 1

var ai: mushroomAI
var health: Health
var is_dead: bool = false
var is_hurt: bool = false
var time_since_hurt: float = 0

func _ready():
    self.ai = self.get_parent()
    self.health = Util.get_child_node_of_type(self.get_parent(), Health)
    health.damage_taken.connect(on_damage_taken)
    ai.died.connect(on_death)


func _process(delta):
    if(is_dead):
        return
    if(is_hurt):
        match(ai.current_mushroom_state):
            mushroomAI.Mushroom_State.HIDE:
                self.set("parameters/hide_transition/transition_request", "hurt")
            mushroomAI.Mushroom_State.COMBAT:
                self.set("parameters/combat_transition/transition_request", "hurt")
        return
    time_since_hurt += delta
    match(ai.current_mushroom_state):
        mushroomAI.Mushroom_State.HIDE:
            self.set("parameters/Transition/transition_request", "hide")
            match(ai.current_state):
                mushroomAI.State.ATTACK:
                    self.set("parameters/hide_transition/transition_request", "attack")
                mushroomAI.State.STUN:
                    self.set("parameters/hide_transition/transition_request", "hurt")
                _:
                    self.set("parameters/hide_transition/transition_request", "idle")
        mushroomAI.Mushroom_State.COMBAT:
            self.set("parameters/Transition/transition_request", "combat")
            match(ai.current_state):
                mushroomAI.State.ATTACK:
                    self.set("parameters/combat_transition/transition_request", "attack")
                mushroomAI.State.STUN:
                    self.set("parameters/combat_transition/transition_request", "hurt")
                _:
                    if self.ai.velocity.length_squared() > 2:
                        var val: String = get("parameters/combat_transition/current_state")
                        if(val != "walking"):
                            self.set("parameters/combat_transition/transition_request", "walking")
                    else:
                        self.set("parameters/combat_transition/transition_request", "idle")
        mushroomAI.Mushroom_State.JUMP:
            self.set("parameters/Transition/transition_request", "jump")

func on_death(midjump: bool):
    if(!is_dead && !midjump):
        self.set("parameters/Transition/transition_request", "death")
    self.is_dead = true

func on_damage_taken(damage):
    if(time_since_hurt >= hurt_cooldown):
        time_since_hurt = 0
        is_hurt = true


func _on_animation_finished(anim_name):
    match anim_name:
        "DamagedWhileHiding", "Ouchie":
            is_hurt = false
