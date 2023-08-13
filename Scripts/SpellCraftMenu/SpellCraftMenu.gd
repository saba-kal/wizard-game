extends Control

@export var rune_slots: Array[RuneSlot]


func _ready():
    self.visible = false
    for slot in rune_slots:
        slot.socketed_rune_changed.connect(self.on_rune_slots_changed)


func _process(delta):
    if Input.is_action_just_pressed("show_spell_craft_menu"):
        self.visible = !self.visible
        if self.visible:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func on_rune_slots_changed(_rune_slot: RuneSlot):
    var blue_rune: BlueRune = get_rune(Rune.Type.BLUE)
    var red_rune: RedRune = get_rune(Rune.Type.RED)
    var yellow_rune: YellowRune = get_rune(Rune.Type.YELLOW)
    SignalBus.rune_slots_changed.emit(blue_rune, red_rune, yellow_rune)


func get_rune(type: Rune.Type) -> Rune:
    for slot in rune_slots:
        if slot.rune_type == type:
            return slot.socketed_rune
    return null
