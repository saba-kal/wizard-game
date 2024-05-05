extends AnimationTree

var bearclops_ai: BearclopsAI
var health: Health
var is_dead: bool = false

func _ready():
    self.bearclops_ai = self.get_parent()
    self.bearclops_ai.state_changed.connect(self.on_state_changed)
    self.health = Util.get_child_node_of_type(self.get_parent(), Health)
    self.health.health_lost.connect(self.on_health_lost)


func _process(delta):
    if self.is_dead:
        return

    if self.bearclops_ai.current_state == BearclopsAI.State.TELEKINESIS_ATTACK:
        self.set("parameters/state/transition_request", "telekinesis")
    elif self.bearclops_ai.velocity.length_squared() > 0.1 && self.bearclops_ai.current_state != BearclopsAI.State.ATTACK:
        self.set("parameters/state/transition_request", "walk")
    else:
        self.set("parameters/state/transition_request", "idle")


func on_health_lost():
    self.is_dead = true
    self.set("parameters/state/transition_request", "dead")


func on_state_changed(agent: BearclopsAI, old_state: BearclopsAI.State, new_state: BearclopsAI.State):
    if new_state == BearclopsAI.State.ATTACK:
        self.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
