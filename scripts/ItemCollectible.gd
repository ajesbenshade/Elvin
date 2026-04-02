extends Area3D

@export var item_data: Resource
@export var inventory_path: NodePath
@export var player_path: NodePath
@export var pickup_distance: float = 1.7
@export var bob_height: float = 0.22
@export var bob_speed: float = 2.5
@export var spin_speed: float = 1.2

var _start_y: float = 0.0
var _time: float = 0.0
var _collected: bool = false

@onready var inventory = get_node_or_null(inventory_path)
@onready var player: Node3D = get_node_or_null(player_path)

func _ready() -> void:
    _start_y = global_position.y

func _process(delta: float) -> void:
    if _collected:
        return

    _time += delta
    global_position.y = _start_y + sin(_time * bob_speed) * bob_height
    rotate_y(delta * spin_speed)

    if player and global_position.distance_to(player.global_position) <= pickup_distance:
        _collect()

func _collect() -> void:
    _collected = true

    if inventory and item_data:
        inventory.add_collectible(item_data, 1)

    if item_data and item_data.pickup_sfx:
        var sfx := AudioStreamPlayer3D.new()
        sfx.stream = item_data.pickup_sfx
        sfx.global_position = global_position
        get_tree().current_scene.add_child(sfx)
        sfx.play()
        sfx.finished.connect(Callable(sfx, "queue_free"))

    if item_data and item_data.pickup_particle_scene:
        var particles := item_data.pickup_particle_scene.instantiate() as Node3D
        particles.global_position = global_position
        get_tree().current_scene.add_child(particles)
        await get_tree().create_timer(0.8).timeout
        particles.queue_free()

    queue_free()
