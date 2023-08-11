class_name Projectile extends Area3D

@export var on_destroy_effect: PackedScene


var direction: Vector3
var speed: float = 10.0

func _ready():
    self.body_entered.connect(self.on_body_entered)

func _process(delta):
    self.translate(direction * self.speed * delta)


func on_body_entered(body: Node3D):
    if self.on_destroy_effect != null:
        var effect: Node3D = self.on_destroy_effect.instantiate()
        self.get_tree().root.add_child(effect)
        effect.global_position = self.global_position
    self.queue_free()
