extends Freezable

@export var player_movement: PlayerMovement


func freeze():
    self.player_movement.disabled = true


func unfreeze():
    self.player_movement.disabled = false
