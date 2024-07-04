extends Healable

@export var ballista: Ballista

func heal():
	ballista.change_State(ballista.State.UNMANNED)