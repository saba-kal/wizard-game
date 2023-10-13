class_name AIWanderArea extends Node3D

var wonder_positions: Array[Marker3D] = []

var agent_to_position_index: Dictionary = {} 


func _ready():
    for child in self.get_children():
        if child is Marker3D:
            self.wonder_positions.append(child)


func register_agent(agent: EnemyAI):
    var agent_position_index = len(self.agent_to_position_index)
    self.agent_to_position_index[agent] = agent_position_index % len(self.wonder_positions)


func get_next_wonder_position(agent: EnemyAI) -> Vector3:
    if len(self.wonder_positions) == 0:
        printerr("Wander area has no Marker3D's to determine wonder positions.")
        return Vector3.ZERO
    if !self.agent_to_position_index.has(agent):
        printerr("Agent was not found in dictionary. Did you ensure registration of the EnemyAI to the AIWanderArea?")
        return Vector3.ZERO

    var position_index = self.agent_to_position_index[agent]
    var next_position = self.wonder_positions[position_index].global_position
    if self.positions_are_equal_2d(agent.global_position, next_position):
        self.agent_to_position_index[agent] = (position_index + 1) % len(self.wonder_positions)
    return next_position



func positions_are_equal_2d(position1: Vector3, position2: Vector3) -> bool:
    return Vector3(position1.x, 0, position1.z).distance_squared_to(Vector3(position2.x, 0, position2.z)) <= 2
