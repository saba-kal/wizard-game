extends PlayerMovement


func _ready():
    super()
    if not get_parent().player:
        get_parent().player = self.get_tree().get_first_node_in_group("Player")
    self.third_persion_camera = Util.get_child_node_of_type(self.get_parent().player, ThirdPersonCamera)


func _on_health_lost():
    on_player_died()
