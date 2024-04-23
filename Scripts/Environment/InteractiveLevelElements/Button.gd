extends Node3D

signal button_pressed()
signal button_unpressed()

var pressed = false;
var cast: ShapeCast3D
# Called when the node enters the scene tree for the first time.
func _ready():
    cast = $Player_detector
    cast.add_exception($Red_Body)
    cast.add_exception($StaticBodyBase)
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

    if(cast.is_colliding() and !pressed):
        press()
    elif (!cast.is_colliding() and pressed):
        unpress()

func press():
    pressed = true
    $Model/AnimationPlayer.play("Press")
    emit_signal("button_pressed")

func unpress():
    pressed = false
    $Model/AnimationPlayer.play("Release")
    emit_signal("button_unpressed")
