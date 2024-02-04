extends Control


func _enter_tree():
    var player = self.get_tree().get_first_node_in_group("Player")
    var status_health: StatusHealth = Util.get_child_node_of_type(player, StatusHealth)
    var health: Health = Util.get_child_node_of_type(status_health, Health)
    $ProgressBar.health = health
