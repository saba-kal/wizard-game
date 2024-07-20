extends BirdBossAIState

@export var gravity: float = 9.8

var current_velocity: Vector3
var health: Health


func get_type() -> Type:
    return Type.FLYING_FALL


func enter_state() -> void:

    self.current_velocity = self.shared_data.fly_to_target_ai.current_velocity
    self.health = Util.get_child_node_of_type(self.shared_data.character_body, Health)
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)


func process_state(delta: float) -> void:
    self.current_velocity += Vector3.DOWN * self.gravity * delta
    var collision: KinematicCollision3D = self.shared_data.character_body.move_and_collide(self.current_velocity * delta)
    if collision:
        if self.health.current_health <= 0:
            self.transition_state.emit(Type.DEAD)
        else:
            self.transition_state.emit(Type.GROUNDED_KNOCKED_OUT)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true
