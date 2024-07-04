extends RayCast3D
var scene: PackedScene
var new: bool = true
var spell_effect: Node3D


func _ready():
    scene = load("res://Scenes/Effects/IcyGround.tscn")


func _process(delta):
    if(new and global_position != Vector3.ZERO):
        force_raycast_update()
        if(is_colliding()):
            scene = load("res://Scenes/Effects/IceBoard.tscn")
        spell_effect= scene.instantiate()
        new = false
        self.get_tree().root.add_child(spell_effect)
        spell_effect.global_position = self.global_position
