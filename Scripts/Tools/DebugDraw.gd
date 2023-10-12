@tool
class_name DebugDraw extends MeshInstance3D

var mat: StandardMaterial3D = StandardMaterial3D.new()


static func start(parent: Node) -> DebugDraw:
    if parent.has_node("DebugDraw"):
        return parent.get_node("DebugDraw")
    var debug_draw = DebugDraw.new()
    debug_draw.name = "DebugDraw"
    parent.add_child(debug_draw)
    return debug_draw


func draw_box(pos: Vector3, width: float, height: float, depth: float, color: Color = Color.RED) -> void:
    self.mesh.clear_surfaces()
    self.mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    self.mesh.surface_set_color(color)

    var vertices = [
        pos, # Front bottom-left
        pos + Vector3(width, 0, 0),  # Front bottom-right
        pos + Vector3(width, height, 0),   # Front top-right
        pos + Vector3(0, height, 0),  # Front top-left
        pos + Vector3(0, 0, depth),  # Back bottom-left
        pos + Vector3(width, 0, depth),   # Back bottom-right
        pos + Vector3(width, height, depth),    # Back top-right
        pos + Vector3(0, height, depth)    # Back top-left
    ]

    var lines = [
        0, 1, 1, 2, 2, 3, 3, 0,  # Front face
        4, 5, 5, 6, 6, 7, 7, 4,  # Back face
        0, 4, 1, 5, 2, 6, 3, 7   # Connect front and back faces
    ]

    for vertex_index in lines:
        self.mesh.surface_add_vertex(vertices[vertex_index])
    self.mesh.surface_end()


func draw_sphere(center: Vector3, radius: float = 1.0, color: Color = Color.RED) -> void:
    self.mesh.clear_surfaces()
    var step: int = 15
    var sppi: float = 2 * PI / step
    var axes = [
        [Vector3.UP, Vector3.RIGHT],
        [Vector3.RIGHT, Vector3.FORWARD],
        [Vector3.FORWARD, Vector3.UP]
    ]
    mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    mesh.surface_set_color(color)
    for axis in axes:
        for i in range(step + 1):
            mesh.surface_add_vertex(center + (axis[0] * radius).rotated(axis[1], sppi * (i % step)))
    mesh.surface_end()


# Called when the node enters the scene tree for the first time.
func _ready():
    self.mesh = ImmediateMesh.new()
    self.mat.no_depth_test = true
    self.mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    self.mat.vertex_color_use_as_albedo = true
    self.mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    self.set_material_override(mat)
