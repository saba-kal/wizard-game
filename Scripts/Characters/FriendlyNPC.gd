extends CharacterBody3D

@export var talk_radius: float = 10

var player: Node3D
var isTalking: bool = false
var quest_item_collected: bool = false
var reward_given: bool = false

func _ready() -> void:
    self.player = self.get_tree().get_first_node_in_group("Player")
    SignalBus.quest_item_collected.connect(on_quest_item_collected)

func _physics_process(delta: float) -> void:
    var distance: float = player.position.distance_to(position)
    if(distance < talk_radius and not isTalking):
        talk("(in range)")
    if(distance > talk_radius):
        talk("(out of range)")
        isTalking = false

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action("interact") && event.is_pressed():
        interactWithPlayer()

func interactWithPlayer() -> void:
    var text: String = ""
    if quest_item_collected:
        text += "Thank you!"
        if not reward_given:
            text += " Here's a rune for your trouble"
            give_rune()
            reward_given = true
    else:
        text += "Hello, could you fetch me the blessed cylinder?"
    isTalking = true
    talk(text)
    

func talk(text: String) -> void:
    $DebugText.set_text(text)

func on_quest_item_collected(_item) -> void:
    quest_item_collected = true
    if isTalking:
        interactWithPlayer()
    
func give_rune() -> void:
    var rune: Area3D  = $RuneCollectable
    if rune:
        rune.visible = true
        rune.monitoring = true
