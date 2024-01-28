extends Node3D

signal button_pressed()
signal button_unpressed()

var pressed = false;

# Called when the node enters the scene tree for the first time.
func _ready():
    $Model/Armature/GeneralSkeleton/Cube_001/ShapeCast3D.add_exception(
        $Model/Armature/GeneralSkeleton/Cube_001/StaticBodyPress)
    $Model/Armature/GeneralSkeleton/Cube_001/ShapeCast3D.add_exception(
        $StaticBodyBase)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var cast = $Model/Armature/GeneralSkeleton/Cube_001/ShapeCast3D
    var result = $Model/Armature/GeneralSkeleton/Cube_001/ShapeCast3D.collision_result
    
    if(cast.is_colliding() and !pressed):
        press()
        print(result)
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
