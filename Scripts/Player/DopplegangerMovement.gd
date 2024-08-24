extends PlayerMovement


func _ready():
    super()
    self.third_persion_camera = Util.get_child_node_of_type(self.get_parent().player, ThirdPersonCamera)
