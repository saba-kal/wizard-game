class_name Dialog extends Sprite3D

@export_multiline  var text: Array[String]

@onready var box: DialogBox = $SubViewport/DialogBox
@onready var viewport: SubViewport = $SubViewport
var dialog_count: int = 0

func _ready() -> void:
    Util.get_child_nodes_of_type(self, Node3D)


func activate() -> void:
    self.texture = viewport.get_texture()

func talk(text: String) -> void:
    box.talk(text)

func advance_dialog() -> bool:
    if(dialog_count < text.size()):
        box.talk(text[dialog_count])
        dialog_count += 1
    return dialog_count >= text.size()

func _on_dialog_box_resized() -> void:
    $SubViewport.size.y = $SubViewport/DialogBox.size.y
