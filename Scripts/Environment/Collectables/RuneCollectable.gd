extends Area3D

@export var rune: Rune

@onready var sprite: Sprite3D = $Sprite3D


func _ready():
    if rune == null:
        printerr("Rune must be set on collectable. Cannot initialize otherwise.")
        return
    self.sprite.texture = rune.texture
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
    if body.is_in_group("Player"):
        SignalBus.rune_collected.emit(self.rune)
        self.queue_free()
