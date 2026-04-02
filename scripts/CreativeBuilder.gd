extends Node3D

# Node paths wired from Main.tscn.
@export var camera_path: NodePath
@export var block_container_path: NodePath
@export var starter_block_scene: PackedScene

# Optional sound and particle resources.
@export var place_sound: AudioStream
@export var remove_sound: AudioStream
@export var boop_sound: AudioStream
@export var place_particle_scene: PackedScene
@export var remove_particle_scene: PackedScene

# Tweakable building behavior.
@export var max_build_distance: float = 50.0
@export var grid_step: Vector3 = Vector3.ONE
@export var preview_color: Color = Color(0.3, 0.8, 1.0, 0.4)
@export var preview_scale: Vector3 = Vector3.ONE
@export var remove_pop_scale: Vector3 = Vector3(0.75, 0.75, 0.75)
@export var remove_pop_time: float = 0.08

@onready var camera: Camera3D = get_node(camera_path)
@onready var block_container: Node3D = get_node(block_container_path)

var preview: MeshInstance3D
var selected_block_scene: PackedScene

func _ready() -> void:
    # Start with a default block, then let hotbar selections override it.
    selected_block_scene = starter_block_scene
    create_preview()

func create_preview() -> void:
    # The preview ghost is a transparent cube to show exactly where block will go.
    preview = MeshInstance3D.new()
    var ghost_box := BoxMesh.new()
    ghost_box.size = preview_scale
    preview.mesh = ghost_box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = preview_color
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    preview.material_override = mat
    preview.visible = false
    add_child(preview)

func _process(_delta: float) -> void:
    # Update preview every frame.
    var hit := raycast()
    if hit:
        var target_pos := _snapped_place_position(hit)
        preview.global_position = target_pos
        preview.visible = true
    else:
        preview.visible = false

    if Input.is_action_just_pressed("place_block") and hit:
        place_block(hit)
    if Input.is_action_just_pressed("remove_block") and hit:
        remove_block(hit)

func raycast() -> Dictionary:
    # Cast forward from camera to find what the player is aiming at.
    var from := camera.global_position
    var to := from + camera.global_transform.basis.z * -max_build_distance
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collide_with_areas = false
    query.exclude = []
    var space_state := get_world_3d().direct_space_state
    return space_state.intersect_ray(query)

func place_block(hit: Dictionary) -> void:
    if selected_block_scene == null:
        return

    var target_pos := _snapped_place_position(hit)
    if has_block_at(target_pos):
        return

    var block := selected_block_scene.instantiate() as Node3D
    block.global_position = target_pos
    block_container.add_child(block)

    if block.has_method("bounce_into_place"):
        block.bounce_into_place()

    play_event(place_sound, target_pos, place_particle_scene)
    play_soothing_boop()

func remove_block(hit: Dictionary) -> void:
    var target_pos := _snapped_remove_position(hit)
    var block := block_at(target_pos)
    if block:
        var tween := block.create_tween()
        tween.tween_property(block, "scale", remove_pop_scale, remove_pop_time)
        block.queue_free()
        play_event(remove_sound, target_pos, remove_particle_scene)

func has_block_at(pos: Vector3) -> bool:
    return block_at(pos) != null

func block_at(pos: Vector3) -> Node3D:
    for child in block_container.get_children():
        if child is Node3D and child.global_position.snapped(grid_step) == pos:
            return child
    return null

func play_event(stream: AudioStream, location: Vector3, particle_scene: PackedScene) -> void:
    # Audio feedback (optional).
    if stream:
        var player := AudioStreamPlayer3D.new()
        player.stream = stream
        player.global_position = location
        add_child(player)
        player.play()
        player.finished.connect(Callable(player, "queue_free"))

    # Particle feedback (optional).
    if particle_scene:
        var particles := particle_scene.instantiate() as Node3D
        particles.global_position = location
        add_child(particles)
        await get_tree().create_timer(1.0).timeout
        particles.queue_free()

func play_soothing_boop() -> void:
    # The soft boop makes every placement feel rewarding.
    if boop_sound:
        var boop := AudioStreamPlayer3D.new()
        boop.stream = boop_sound
        boop.global_position = camera.global_position
        add_child(boop)
        boop.play()
        boop.finished.connect(Callable(boop, "queue_free"))

func _snapped_place_position(hit: Dictionary) -> Vector3:
    var hit_position := hit["position"] as Vector3
    var hit_normal := hit["normal"] as Vector3
    return (hit_position + hit_normal * 0.5).snapped(grid_step)

func _snapped_remove_position(hit: Dictionary) -> Vector3:
    var hit_position := hit["position"] as Vector3
    var hit_normal := hit["normal"] as Vector3
    return (hit_position - hit_normal * 0.5).snapped(grid_step)

func set_selected_block(scene: PackedScene, new_preview_tint: Color) -> void:
    # Called by hotbar when player clicks a slot.
    selected_block_scene = scene
    var mat := preview.material_override as StandardMaterial3D
    if mat:
        mat.albedo_color = new_preview_tint
