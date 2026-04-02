extends CanvasLayer

@export var builder_node_path: NodePath
@export var block_presets: Array[PackedScene] = []
@export var selected_style: StyleBoxFlat
@export var normal_style: StyleBoxFlat

@onready var builder = get_node(builder_node_path)
@onready var block_buttons = $Panel/VBox/BlockButtons
@onready var save_button = $Panel/VBox/SaveButton

func _ready() -> void:
    refresh_block_palette()
    save_button.pressed.connect(_on_save_pressed)

func refresh_block_palette() -> void:
    for child in block_buttons.get_children():
        child.queue_free()

    for preset in block_presets:
        var b = Button.new()
        b.text = preset.resource_path.get_file().get_basename()
        b.rect_min_size = Vector2(100, 70)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.add_theme_color_override("font_color", Color(1,1,1))
        b.pressed.connect(Callable(self, "_on_block_selected"), [preset, b])
        block_buttons.add_child(b)

        var fill_color = Color(0.2, 0.6, 0.9)
        b.add_theme_color_override("font_color_hover", Color(1,1,0.8))
        b.add_theme_color_override("font_color_pressed", Color(1,0.9,0.5))

    if block_buttons.get_child_count() > 0:
        _select_button(block_buttons.get_child(0))

func _on_block_selected(preset: PackedScene, button: Button) -> void:
    builder.selected_block_scene = preset
    for b in block_buttons.get_children():
        b.add_theme_stylebox_override("panel", normal_style)
    _select_button(button)

func _select_button(button: Button) -> void:
    if button:
        button.add_theme_stylebox_override("panel", selected_style)

func _on_save_pressed() -> void:
    var file_path = "user://joyblocks_world.tscn"
    var saved_world = builder.world.duplicate() as Node
    var packed_scene = PackedScene.new()
    packed_scene.pack(saved_world)
    ResourceSaver.save(file_path, packed_scene)

    var dlg = ConfirmationDialog.new()
    dlg.dialog_text = "Saved to " + file_path + "!"
    add_child(dlg)
    dlg.popup_centered_minsize()
