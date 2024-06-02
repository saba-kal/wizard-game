extends AnimationTree

var ai: mushroomAI
var health: Health
var is_dead: bool = false

func _ready():
    self.ai = self.get_parent()
    self.health = Util.get_child_node_of_type(self.get_parent(), Health)


func _process(delta):
    if(is_dead):
        return
    match(ai.current_mushroom_state):
        mushroomAI.Mushroom_State.HIDE:
            self.set("parameters/Transition/transition_request", "hide")
            match(ai.current_state):
                mushroomAI.State.ATTACK:
                    var val: String = get("parameters/hide_transition/current_state")
                    if(val != "attack" && val != "reverseattack"):
                        self.set("parameters/hide_transition/transition_request", "attack")
                mushroomAI.State.STUN:
                    self.set("parameters/hide_transition/transition_request", "hurt")
                _:
                    self.set("parameters/hide_transition/transition_request", "idle")
        mushroomAI.Mushroom_State.COMBAT:
            self.set("parameters/Transition/transition_request", "combat")
            match(ai.current_state):
                mushroomAI.State.ATTACK:
                    var val: String = get("parameters/combat_transition/current_state")
                    if(val != "attack" && val != "reverseattack"):
                        self.set("parameters/combat_transition/transition_request", "attack")
                mushroomAI.State.STUN:
                    self.set("parameters/combat_transition/transition_request", "hurt")
                _:
                    if self.ai.velocity.length_squared() > 0.1:
                        var val: String = get("parameters/combat_transition/current_state")
                        if(val != "walking"):
                            self.set("parameters/combat_transition/transition_request", "walking")
                    else:
                        self.set("parameters/combat_transition/transition_request", "idle")
        mushroomAI.Mushroom_State.JUMP:
            self.set("parameters/Transition/transition_request", "jump")

