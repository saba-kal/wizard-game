extends Control

@onready var health_bar: HealthBar = $ProgressBar


func _ready() -> void:
    var player: Node3D = self.get_tree().get_first_node_in_group("Player")
    self.health_bar.set_health(Util.get_child_node_of_type(player, Health))
