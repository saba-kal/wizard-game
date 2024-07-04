extends Control

@onready var health_bar: HealthBar = $ProgressBar


func _ready() -> void:
    var player: Node3D = self.get_tree().get_first_node_in_group("Player")
    var status_health: StatusHealth = Util.get_child_node_of_type(player, StatusHealth)
    var health: Health = Util.get_child_node_of_type(status_health, Health)
    self.health_bar.set_health(health)
