extends FreezablePlayer

var freezable_player: Freezable

func _ready():
    super()
    var player: CharacterBody3D = get_parent().player
    freezable_player = Util.get_child_node_of_type(player, Freezable)

func start_freeze(duration: float, status_damage: float, source: Node3D):
    freezable_player.start_freeze(duration, status_damage, source)
    super(duration, status_damage, source)
