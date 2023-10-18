extends Control


func _enter_tree():
    var player = self.get_tree().get_first_node_in_group("Player")
    $ProgressBar.health = Util.get_child_node_of_type(player, Health)
