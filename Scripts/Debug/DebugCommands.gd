class_name DebugCommands extends Node

# Prob not the best way to do this but eh, it works for now
@export var runes : Array

var superman_mode_enabled: bool = false


func give_all_runes() -> String:
    for rune : Rune in runes:
        SignalBus.rune_collected.emit(rune)
    return "Runes Given\n"

func reload_scene() -> String:
    get_tree().reload_current_scene()
    return "Scene Reloaded\n"

func teleport_boss() -> String:
    var position_node: Node3D = self.get_tree().get_first_node_in_group("BossStartPosition")
    var player: Node3D = self.get_tree().get_first_node_in_group("Player")
    if is_instance_valid(position_node):
        player.global_position = position_node.global_position
        return "Teleported to the boss\n"
    else:
        return "Failed to teleport to boss. This level does not have a node assigned to group \"BossStartPosition\"\n"

func superman() -> String:
    self.superman_mode_enabled = !self.superman_mode_enabled
    SignalBus.superman_mode_changed.emit(self.superman_mode_enabled)
    if self.superman_mode_enabled:
        return "Superman mode enabled\n"
    else:
        return "Superman mode disabled\n"
