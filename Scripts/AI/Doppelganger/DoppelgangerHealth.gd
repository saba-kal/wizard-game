extends Health


var player_health: Health

func _ready():
    var player: CharacterBody3D = get_parent().player
    player_health = Util.get_child_node_of_type(player, Health)

func take_damage(damage: float, type: DamageType = DamageType.NEUTRAL):
    super(damage, type)
    player_health.take_damage(damage, type)
