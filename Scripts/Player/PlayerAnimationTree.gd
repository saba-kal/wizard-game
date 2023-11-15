extends AnimationTree

var prev_is_on_floor: bool = true
var player_movement: PlayerMovement


func _ready():
    self.player_movement = Util.get_child_node_of_type(self.get_parent(), PlayerMovement)
    SignalBus.player_jumped.connect(self.on_player_jumped)


func _process(delta):
    if !self.player_movement.is_on_floor():
        self.set("parameters/state/transition_request", "fall")
    elif self.player_movement.is_running():
        self.set("parameters/state/transition_request", "run")
    elif self.player_movement.is_walking():
        self.set("parameters/state/transition_request", "walk")
    else:
        self.set("parameters/state/transition_request", "idle")

    if self.prev_is_on_floor == false && self.player_movement.is_on_floor():
        self.set("parameters/land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
    self.prev_is_on_floor = self.player_movement.is_on_floor()


func on_player_jumped():
    self.set("parameters/jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
