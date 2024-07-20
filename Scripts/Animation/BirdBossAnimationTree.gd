extends AnimationTree


@onready var bird_boss_ai: MushroomBirdBossAI = self.get_parent()
@onready var short_ranged_attack: AreaAttack = $"../ShortRangeAttack"


func _ready():
    self.bird_boss_ai.state_changed.connect(self.on_state_changed)
    self.short_ranged_attack.attack_started.connect(self.on_short_range_attack_started)


func on_state_changed(prev_state: BirdBossAIState.Type, new_state: BirdBossAIState.Type):
    match new_state:
        BirdBossAIState.Type.FLYING_MEDIUM_RANGE_ATTACK:
            self.set("parameters/medium_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func on_short_range_attack_started():
    if self.bird_boss_ai.current_state.is_flying():
        self.set("parameters/flying_short_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
    else:
        self.set("parameters/grounded_short_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
