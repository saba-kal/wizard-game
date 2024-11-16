extends Area3D

@export var rune: Rune

func _ready() -> void:
    if rune == null:
        printerr("Rune must be set on collectable. Cannot initialize otherwise.")
        return
    $PlacementHelper.queue_free()
    for player_rune in PlayerData.runes:
        if player_rune.equals(self.rune):
            print("Player alread collected rune %d %d. Destroying collectible in %s." % [self.rune.get_type(), self.rune.type, self.get_tree().current_scene.name])
            self.queue_free() # Player already collected this rune. Destroy self.
            return
    if(rune.visual):
        var node: Node = rune.visual.instantiate()
        add_child(node)
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player"):
        SignalBus.rune_collected.emit(self.rune)
        self.queue_free()
