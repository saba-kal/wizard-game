extends Healable


func heal():
    var health: Health = Util.get_child_node_of_type(self.get_parent(), Health)
    if health != null:
        health.heal(30)
