extends Freezable

@onready var bearclops: BearclopsAI = self.get_parent()

var freeze_position: Vector3


func _process(delta):
    super._process(delta)
    if self.freeze_started:
        self.bearclops.global_position = self.freeze_position


func freeze():
    self.bearclops.set_state(BearclopsAI.State.STUN)
    self.freeze_position = self.bearclops.global_position


func unfreeze():
    self.bearclops.set_state(BearclopsAI.State.IDLE)
