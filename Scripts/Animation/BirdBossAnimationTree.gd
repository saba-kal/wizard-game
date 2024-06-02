extends AnimationTree


@onready var bird_boss_ai: MushroomBirdBossAI = self.get_parent()


func _ready():
    self.bird_boss_ai.state_changed.connect(self.on_state_changed)


func on_state_changed(prev_state: MushroomBirdBossAI.State, new_state: MushroomBirdBossAI.State):
    if (new_state == MushroomBirdBossAI.State.GROUNDED_SHORT_RANGE_ATTACK ||
        new_state == MushroomBirdBossAI.State.FLYING_SHORT_RANGE_ATTACK):
        self.set("parameters/short_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
