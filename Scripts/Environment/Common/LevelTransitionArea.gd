extends Area3D


@export var transition_to: SceneLoader.SceneType = SceneLoader.SceneType.HUB


func _ready():
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    if body.is_in_group("Player"):
        SceneLoader.load_scene(self.transition_to)
