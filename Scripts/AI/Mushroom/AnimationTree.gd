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
            match(ai.current_state):
                mushroomAI.State.ATTACK:
                    self.set("parameters/hide_transition/transition_request", "attack")
                mushroomAI.State.STUN:
                    self.set("parameters/hide_transition/transition_request", "hurt")
                _:
                    self.set("parameters/hide_transition/transition_request", "idle")

