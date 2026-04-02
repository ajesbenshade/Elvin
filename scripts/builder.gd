extends Node3D

@export var selected_block: Resource
@export var block_scene: PackedScene

const GRID_SIZE = 1.0

var preview_mesh: MeshInstance3D

func _ready():
    create_preview()

func create_preview():
    preview_mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3.ONE * GRID_SIZE
    preview_mesh.mesh = box
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(1, 1, 1, 0.4)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    preview_mesh.material_override = mat
    add_child(preview_mesh)

func _process(_delta):
    var cam = get_viewport().get_camera_3d()
    if not cam:
        return

    var mouse_pos = get_viewport().get_mouse_position()
    var from = cam.project_ray_origin(mouse_pos)
    var dir = cam.project_ray_normal(mouse_pos)

    var query = PhysicsRayQueryParameters3D.create(from, from + dir * 100)
    var result = get_world_3d().direct_space_state.intersect_ray(query)

    if result:
        var place_pos = (result.position + result.normal * 0.51).snapped(Vector3.ONE * GRID_SIZE)
        preview_mesh.global_position = place_pos

        if Input.is_action_just_pressed("place_block"):
            place_block(place_pos)
        elif Input.is_action_just_pressed("tag_block"):
            tag_block(result.position)

func place_block(pos: Vector3):
    if not block_scene:
        return

    var block = block_scene.instantiate() as Node3D
    block.global_position = pos

    if block is MeshInstance3D and selected_block:
        var mat = StandardMaterial3D.new()
        mat.albedo_color = selected_block.color
        block.material_override = mat

    get_tree().current_scene.add_child(block)
    print("🌈 YAY! Placed a ", selected_block.display_name if selected_block else "Block")

func tag_block(pos: Vector3):
    if selected_block and selected_block.bouncy_on_tag and selected_block.tag_particles:
        var particles = selected_block.tag_particles.instantiate() as Node3D
        particles.global_position = pos
        get_tree().current_scene.add_child(particles)

    print("✨ Tagged at ", pos, " with ", selected_block.display_name if selected_block else "nothing")
