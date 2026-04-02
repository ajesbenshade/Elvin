extends CanvasLayer

@export var builder_path: NodePath
@export var inventory_path: NodePath
@export var hotbar_path: NodePath
@export var block_container_path: NodePath

@onready var builder = get_node_or_null(builder_path)
@onready var inventory = get_node(inventory_path)
@onready var hotbar = get_node(hotbar_path)
@onready var item_label: Label = $RootPanel/VBox/CollectibleLabel
@onready var save_button: Button = $RootPanel/VBox/ButtonRow/SaveButton
@onready var load_button: Button = $RootPanel/VBox/ButtonRow/LoadButton
@onready var mode_label: Label = $RootPanel/VBox/ModeLabel

func _ready() -> void:
    save_button.pressed.connect(_on_save_pressed)
    load_button.pressed.connect(_on_load_pressed)
    inventory.inventory_changed.connect(_refresh_collectibles)

    var player := get_tree().current_scene.get_node_or_null("Camera3D")
    if player and player.has_signal("walk_mode_changed"):
        player.walk_mode_changed.connect(_on_walk_mode_changed)

    _refresh_collectibles()

func _refresh_collectibles() -> void:
    var lines: Array[String] = []
    for key in inventory.collectible_counts.keys():
        lines.append("%s: %d" % [key, int(inventory.collectible_counts[key])])
    item_label.text = "Collectibles: none yet" if lines.is_empty() else "Collectibles\n" + "\n".join(lines)

func _on_walk_mode_changed(is_walk_mode: bool) -> void:
    mode_label.text = "Mode: Walk (F to fly)" if is_walk_mode else "Mode: Fly (F to walk)"

func _on_save_pressed() -> void:
    var container: Node3D = get_node(block_container_path)
    var world_copy := container.duplicate()
    var packed := PackedScene.new()
    if packed.pack(world_copy) == OK:
        ResourceSaver.save(packed, "user://elvin_world_blocks.tscn")
        _show_message("Saved! user://elvin_world_blocks.tscn")
    else:
        _show_message("Save failed")

func _on_load_pressed() -> void:
    var path := "user://elvin_world_blocks.tscn"
    if not ResourceLoader.exists(path):
        _show_message("No save file yet")
        return

    var packed := load(path) as PackedScene
    if packed == null:
        _show_message("Could not load save")
        return

    var target: Node3D = get_node(block_container_path)
    for child in target.get_children():
        child.queue_free()

    var loaded := packed.instantiate() as Node3D
    for child in loaded.get_children():
        child.reparent(target)
    loaded.queue_free()
    _show_message("Loaded saved blocks")

func _show_message(text: String) -> void:
    var dlg := AcceptDialog.new()
    dlg.dialog_text = text
    add_child(dlg)
    dlg.popup_centered()
