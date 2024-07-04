class_name DebugText extends Node

@onready var label: Label = $SubViewport/Label


func set_text(text: String) -> void:
    self.label.text = text
