extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

var player_mana: PlayerMana


func _ready():
    var player = self.get_tree().get_first_node_in_group("Player")
    self.player_mana = Util.get_child_node_of_type(player, PlayerMana)
    self.progress_bar.max_value = self.player_mana.max_mana


func _process(delta):
    self.progress_bar.value = self.player_mana.current_mana
    self.label.text = "%d/%d" % [self.player_mana.current_mana, self.player_mana.max_mana]
