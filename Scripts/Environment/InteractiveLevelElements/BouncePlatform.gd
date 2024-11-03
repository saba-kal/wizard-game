extends Area3D

@export var bounce_amount: float = 13
@onready var bounce_sound = $"../BounceSound"
@onready var animation_player = $"../Springshroom/AnimationPlayer"


func _ready():
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    if body.is_in_group("Player"):
        var movement: PlayerMovement = Util.get_child_node_of_type(body, PlayerMovement)
        movement.apply_vertical_velocity(self.bounce_amount)
        bounce_sound.play()
        animation_player.play("Springshroom_Skeleton_002Action")
