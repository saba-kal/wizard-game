class_name AIState extends Node

# Some AI characters (mushroom valley bird boss) utilize action points to determine what to do next.
# It is up to the implementation of the state or state machine on how this is used.
@export var action_points: int = 0


func enter_state() -> void:
    pass # Implemented by inhereting classes.


func process_state(delta: float) -> void:
    pass # Implemented by inhereting classes.


func exit_state() -> void:
    pass # Implemented by inhereting classes.
