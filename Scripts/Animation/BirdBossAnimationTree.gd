extends AnimationTree

@export var medium_attack_effect: GPUParticles3D
@export var skeleton: Skeleton3D

@onready var bird_boss_ai: MushroomBirdBossAI = self.get_parent()
@onready var short_ranged_attack: AreaAttack = $"../ShortRangeAttack"

var head_bone_index: int
var player: Node3D
var look_bone_up_vector: Vector3

func _ready() -> void:
    self.bird_boss_ai.state_changed.connect(self.on_state_changed)
    self.short_ranged_attack.attack_started.connect(self.on_short_range_attack_started)
    self.set("parameters/boss_state/transition_request", "idle")
    self.medium_attack_effect.emitting = false
    self.head_bone_index = self.skeleton.find_bone("Neck")
    self.player = self.get_tree().get_first_node_in_group("Player")
    
    var head_bone_transform: Transform3D = self.skeleton.global_transform * self.skeleton.get_bone_global_rest(self.head_bone_index)
    self.look_bone_up_vector = head_bone_transform.basis.y


func _process(delta: float) -> void:
    var head_bone_transform: Transform3D = self.skeleton.global_transform * self.skeleton.get_bone_global_pose(self.head_bone_index)
    head_bone_transform = head_bone_transform.looking_at(
        self.player.global_position, 
        self.look_bone_up_vector, 
        true)

    var local_transform: Transform3D = self.skeleton.global_transform.affine_inverse() * head_bone_transform
    var rotation: Quaternion = local_transform.basis.get_rotation_quaternion()
    #rotation.x = clamp(rotation.x, -0.286, 0.1)
    #rotation.y = clamp(rotation.y, -0.5, 0.5)

    var new_local_transform = Transform3D(Basis(rotation), local_transform.origin)

    # self.skeleton.set_bone_global_pose_override(self.head_bone_index, local_transform, 1.0, true)


func on_state_changed(prev_state: BirdBossAIState.Type, new_state: BirdBossAIState.Type) -> void:

    self.medium_attack_effect.emitting = false
    var new_state_data: BirdBossAIState = self.bird_boss_ai.get_state(new_state)

    if new_state == BirdBossAIState.Type.GROUNDED_IDLE:
        self.set("parameters/boss_state/transition_request", "idle")
    elif new_state == BirdBossAIState.Type.FLYING_IDLE:
        self.set("parameters/boss_state/transition_request", "flying_idle")
    elif new_state_data.is_flying():
        self.set("parameters/boss_state/transition_request", "flying")
    else:
        self.set("parameters/boss_state/transition_request", "running")

    match new_state:
        BirdBossAIState.Type.FLYING_MEDIUM_RANGE_ATTACK:
            self.set("parameters/medium_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
            self.medium_attack_effect.emitting = true
        BirdBossAIState.Type.GROUNDED_MEDIUM_RANGE_ATTACK:
            self.set("parameters/medium_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
            self.medium_attack_effect.emitting = true


func on_short_range_attack_started() -> void:
    if self.bird_boss_ai.current_state.is_flying():
        self.set("parameters/flying_short_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
    else:
        self.set("parameters/grounded_short_range_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
