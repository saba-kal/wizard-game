@tool
extends NavigationRegion3D

var debug_draw: DebugDraw


func _process(delta):
    if Engine.is_editor_hint():
        self.debug_draw = DebugDraw.start(self)
        var box_size: Vector3 = self.navigation_mesh.filter_baking_aabb.size
        var box_pos_offset: Vector3 = self.navigation_mesh.filter_baking_aabb.position
        self.debug_draw.draw_box(box_pos_offset, box_size.x, box_size.y, box_size.z)
