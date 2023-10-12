extends Area3D

@export var scene_to_load: PackedScene


func _ready():
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    if body.is_in_group("Player"):
        if self.scene_to_load == null:
            printerr("Cannon load next scene because the scene to load parameter is null.")
        else:
            self.get_tree().change_scene_to_packed(self.scene_to_load)
