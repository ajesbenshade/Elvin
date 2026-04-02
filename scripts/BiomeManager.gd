extends Node3D

@export var world_path: NodePath
@export var block_container_path: NodePath
@export var item_container_path: NodePath
@export var player_path: NodePath
@export var inventory_path: NodePath

@export var biome_size: Vector2 = Vector2(20, 20)
@export var biome_spacing: float = 24.0
@export var collectible_scenes: Array[PackedScene] = []

@onready var world: Node3D = get_node(world_path)
@onready var block_container: Node3D = get_node(block_container_path)
@onready var item_container: Node3D = get_node(item_container_path)
@onready var player: Node3D = get_node(player_path)
@onready var inventory = get_node_or_null(inventory_path)

func _ready() -> void:
    randomize()
    if collectible_scenes.is_empty():
        collectible_scenes = [
            load("res://scenes/items/SparkleGem.tscn"),
            load("res://scenes/items/ButterflyCharm.tscn"),
            load("res://scenes/items/StarFlower.tscn"),
            load("res://scenes/items/CandyHeart.tscn"),
            load("res://scenes/items/CloudFeather.tscn"),
            load("res://scenes/items/MoonDrop.tscn"),
            load("res://scenes/items/HappyAcorn.tscn"),
            load("res://scenes/items/RainbowShell.tscn")
        ]
    _spawn_biomes()

func _spawn_biomes() -> void:
    _create_biome_ground("Meadow", Vector3(-biome_spacing, -1.2, 0), Color(0.48, 0.85, 0.46, 1.0))
    _create_biome_ground("CandyGrove", Vector3(0, -1.2, 0), Color(0.98, 0.72, 0.88, 1.0))
    _create_biome_ground("CloudIsles", Vector3(biome_spacing, 3.0, 0), Color(0.88, 0.96, 1.0, 1.0))

    _scatter_collectibles(Vector3(-biome_spacing, 0.5, 0), 3)
    _scatter_collectibles(Vector3(0, 0.5, 0), 3)
    _scatter_collectibles(Vector3(biome_spacing, 4.5, 0), 2)

func _create_biome_ground(biome_name: String, center: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = "%sGround" % biome_name
    body.position = center
    world.add_child(body)

    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(biome_size.x, 1.0, biome_size.y)
    mesh_instance.mesh = mesh

    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.95
    mesh_instance.material_override = mat
    body.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = mesh.size
    collision.shape = shape
    body.add_child(collision)

func _scatter_collectibles(center: Vector3, count: int) -> void:
    if collectible_scenes.is_empty():
        return

    for i in count:
        var idx := i % collectible_scenes.size()
        var item_scene := collectible_scenes[idx]
        if item_scene == null:
            continue

        var item := item_scene.instantiate() as Node3D
        item.position = center + Vector3(randf_range(-6.0, 6.0), randf_range(0.2, 1.4), randf_range(-6.0, 6.0))
        item_container.add_child(item)
        if inventory:
            item.set("inventory_path", item.get_path_to(inventory))
        if player:
            item.set("player_path", item.get_path_to(player))
