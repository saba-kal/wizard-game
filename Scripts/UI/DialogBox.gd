class_name DialogBox extends Control

@export var label: RichTextLabel

func  talk(text: String):
    label.text = text
