class_name RuneContainer extends Control

@export var rune_type: Rune.Type = Rune.Type.BLUE
@export var grid_container: Control
@export var draggable_rune_scene: PackedScene


func _ready():
    for inventory_slot in self.grid_container.get_children():
        inventory_slot.rune_type = self.rune_type


func add_rune(rune: Rune):
    if rune.get_type() != self.rune_type:
        printerr("Cannot add rune type " + str(rune.get_type()) + " to rune container type " + str(self.rune_type))
        return
    for inventory_slot in self.grid_container.get_children():
        if inventory_slot.socketed_rune == null:
            inventory_slot.add_rune(rune)
            return
