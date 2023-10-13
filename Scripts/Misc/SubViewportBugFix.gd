extends SubViewport

func _ready():
    self.set_update_mode(SubViewport.UPDATE_WHEN_PARENT_VISIBLE)
