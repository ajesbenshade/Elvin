extends Node3D

@export var camera_path: NodePath
@export var world_path: NodePath
@export var initial_block_scene: PackedScene
@export var place_sound: AudioStream
@export var remove_sound: AudioStream
@export var boop_sound: AudioStream
@export var place_particle_scene: PackedScene
@export var remove_particle_scene: PackedScene
@export var preview_color: Color = Color(0.3, 0.8, 1.0, 0.4)

@onready var camera: Camera3D = get_node(camera_path)
@onready var world: Node3D = get_node(world_path)

var selected_block_scene: PackedScene
var preview: MeshInstance3D

func _ready() -> void:
    selected_block_scene = initial_block_scene
    create_preview()

func create_preview() -> void:
    preview = MeshInstance3D.new()
    preview.mesh = BoxMesh.new()
    var mat := StandardMaterial3D.new()
    mat.albedo_color = preview_color
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
    preview.material_override = mat
    preview.visible = false
    add_child(preview)

func _process(_delta: float) -> void:
    var hit := raycast()
    if hit:
        var target_pos: Vector3 = ((hit["position"] as Vector3) + (hit["normal"] as Vector3) * 0.5).snapped(Vector3.ONE)
        preview.global_position = target_pos
        preview.visible = true
    else:
        preview.visible = false

    if Input.is_action_just_pressed("place_block") and hit:
        place_block(hit)
    if Input.is_action_just_pressed("remove_block") and hit:
        remove_block(hit)

func raycast() -> Dictionary:
    var from := camera.global_position
    var to := from + camera.global_transform.basis.z * -50.0
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = []
    var space_state := get_world_3d().direct_space_state
    return space_state.intersect_ray(query)

func place_block(hit: Dictionary) -> void:
    if not selected_block_scene:
        return
    var target_pos: Vector3 = ((hit["position"] as Vector3) + (hit["normal"] as Vector3) * 0.5).snapped(Vector3.ONE)
    if has_block_at(target_pos):
        return

    var block := selected_block_scene.instantiate() as Node3D
    block.global_position = target_pos
    world.add_child(block)

    if block.has_method("bounce_into_place"):
        block.bounce_into_place()

    play_event(place_sound, target_pos, place_particle_scene)
    play_soothing_boop()

func remove_block(hit: Dictionary) -> void:
    var target_pos: Vector3 = ((hit["position"] as Vector3) - (hit["normal"] as Vector3) * 0.5).snapped(Vector3.ONE)
    var block := block_at(target_pos)
    if block:
        block.queue_free()
        play_event(remove_sound, target_pos, remove_particle_scene)
        play_soothing_boop()

func has_block_at(pos: Vector3) -> bool:
    return block_at(pos) != null

func block_at(pos: Vector3) -> Node3D:
    for child in world.get_children():
        if child is Node3D and child.global_position.snapped(Vector3.ONE) == pos:
            return child
    return null

func play_event(stream: AudioStream, location: Vector3, particle_scene: PackedScene) -> void:
    if stream:
        var player := AudioStreamPlayer3D.new()
        player.stream = stream
        player.global_position = location
        add_child(player)
        player.play()
        player.finished.connect(Callable(player, "queue_free"))

    if particle_scene:
        var particles := particle_scene.instantiate() as Node3D
        particles.global_position = location
        get_tree().current_scene.add_child(particles)
        await get_tree().create_timer(1.0).timeout
        particles.queue_free()

func play_soothing_boop() -> void:
    if boop_sound:
        var boop := AudioStreamPlayer3D.new()
        boop.stream = boop_sound
        boop.global_position = camera.global_position
        add_child(boop)
        boop.play()
        boop.finished.connect(Callable(boop, "queue_free"))
