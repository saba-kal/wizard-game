class_name DialogBox extends Control

@export var label: RichTextLabel
@export var talk_speed: float = 50

var time_remainder: float = 0

func  talk(text: String):
    label.text = text
    label.visible_characters = 1
    time_remainder = 0

func _process(delta):
    var characters: int = label.visible_characters
    var talk_time: float = 1/talk_speed
    time_remainder += delta
    if characters > -1 and characters < label.text.length() and time_remainder >= talk_time:
        time_remainder -= talk_time
        label.visible_characters += 1
