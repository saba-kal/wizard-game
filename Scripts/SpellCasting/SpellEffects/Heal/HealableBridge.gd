extends Healable

@export var bridge: RopeBridge


func heal():
    self.bridge.is_broken = false
