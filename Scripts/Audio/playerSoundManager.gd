extends Node3D

@export var jump_sound: AudioStreamPlayer3D
@export var small_ouchie_sound: AudioStreamPlayer3D
@export var big_ouchie_sound: AudioStreamPlayer3D
@onready var knock_down: KnockDown = $"../KnockDown"

func _ready() -> void:
    SignalBus.player_jumped.connect(self.on_player_jumped)
    if self.knock_down != null:
        self.knock_down.knock_down_started.connect(self.on_knock_down_started)
    var health: Health = Util.get_child_node_of_type(self.get_parent(), Health)
    if health != null:
        health.damage_taken.connect(self.on_damage_taken)

func on_player_jumped() -> void:
    jump_sound.play()

func on_damage_taken(damage: float) -> void:
    if not small_ouchie_sound.playing and not big_ouchie_sound.playing:
        small_ouchie_sound.play()

func on_knock_down_started() -> void:
    if small_ouchie_sound.playing:
        small_ouchie_sound.stop()
    big_ouchie_sound.play()
