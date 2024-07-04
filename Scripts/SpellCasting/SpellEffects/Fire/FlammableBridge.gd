extends Flammable

@export var bridge: RopeBridge


func light():
    bridge.is_broken = true
