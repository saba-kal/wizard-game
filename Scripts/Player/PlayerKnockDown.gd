extends KnockDown

@export var immunity_duration: float = 0.5

var player_movement: PlayerMovement
var health: Health
var player_died: bool = false


func _ready() -> void:
    self.player_movement = Util.get_child_node_of_type(self.get_parent(), PlayerMovement)
    self.health = Util.get_child_node_of_type(self.get_parent(), Health)
    SignalBus.player_died.connect(self.on_player_died)


func start_knock_down() -> void:
    self.player_movement.disabled = true
    self.health.is_immune = true
    await get_tree().create_timer(self.immunity_duration).timeout
    self.health.is_immune = false


func end_knock_down() -> void:
    if !self.player_died:
        self.player_movement.disabled = false


func on_player_died() -> void:
    self.player_died = true
