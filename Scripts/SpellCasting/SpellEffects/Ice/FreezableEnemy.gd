extends Freezable

@onready var enemy_ai: EnemyAI = self.get_parent()

var freeze_position: Vector3


func _process(delta):
    super._process(delta)
    if self.freeze_started:
        self.enemy_ai.global_position = self.freeze_position


func freeze():
    self.enemy_ai.set_state(EnemyAI.State.STUN)
    self.freeze_position = self.enemy_ai.global_position


func unfreeze():
    self.enemy_ai.set_state(EnemyAI.State.WANDER)
