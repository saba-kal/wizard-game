extends Node

var runeCounter: int = 0

func get_child_node_of_type(node: Node, type: Variant) -> Node:
    for child in node.get_children():
        if is_instance_of(child, type):
            return child
    return null


func get_child_nodes_of_type(node: Node3D, type: Variant) -> Array:
    var nodes: Array[Variant] = []
    for child in node.get_children():
        if is_instance_of(child, type):
            nodes.append(child)
    return nodes


func remove_elem(array: Array, elem: Variant) -> bool:
    var index: int = array.find(elem)
    if index >= 0:
        array.remove_at(index)
    return index >= 0

func count_rune() -> int:
    runeCounter += 1
    return runeCounter
