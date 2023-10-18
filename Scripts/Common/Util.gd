extends Node


static func get_child_node_of_type(node: Node, type: Variant) -> Node:
    for child in node.get_children():
        if is_instance_of(child, type):
            return child
    return null


static func get_child_nodes_of_type(node: Node3D, type: Variant) -> Array:
    var nodes: Array[Variant] = []
    for child in node.get_children():
        if is_instance_of(child, type):
            nodes.append(child)
    return nodes
