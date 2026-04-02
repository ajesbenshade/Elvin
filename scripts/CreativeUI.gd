extends CanvasLayer

# Points to CreativeBuilder in Main scene.
@export var builder_node_path: NodePath = NodePath("../CreativeBuilder")
@export var block_presets: Array[PackedScene] = []
@export var selected_style: StyleBoxFlat
@export var normal_style: StyleBoxFlat
@export var button_min_size: Vector2 = Vector2(160, 84)

@onready var builder = get_node_or_null(builder_node_path)
@onready var block_buttons = $Panel/VBox/BlockButtons
@onready var save_button = $Panel/VBox/SaveButton
@onready var title_label = $Panel/VBox/Title

func _ready() -> void:
    _setup_default_styles()
    title_label.text = "Pick a Block and Build Joy"
    refresh_block_palette()
    save_button.pressed.connect(_on_save_pressed)

func refresh_block_palette() -> void:
    for child in block_buttons.get_children():
        child.queue_free()

    for preset in block_presets:
        var b := Button.new()
        b.text = preset.resource_path.get_file().get_basename().replace("Block", "")
        b.custom_minimum_size = button_min_size
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.size_flags_vertical = Control.SIZE_EXPAND_FILL
        b.add_theme_color_override("font_color", Color(1, 1, 1))
        b.add_theme_color_override("font_color_hover", Color(1, 1, 0.9))
        b.add_theme_color_override("font_color_pressed", Color(1, 0.95, 0.7))
        b.add_theme_stylebox_override("normal", normal_style)
        b.add_theme_stylebox_override("hover", normal_style)
        b.add_theme_stylebox_override("pressed", selected_style)
        b.pressed.connect(Callable(self, "_on_block_selected").bind(preset, b))
        block_buttons.add_child(b)

    if block_buttons.get_child_count() > 0:
        var first_button := block_buttons.get_child(0) as Button
        _on_block_selected(block_presets[0], first_button)

func _on_block_selected(preset: PackedScene, button: Button) -> void:
    if builder:
        builder.selected_block_scene = preset

    for b in block_buttons.get_children():
        (b as Button).add_theme_stylebox_override("normal", normal_style)

    _select_button(button)

func _select_button(button: Button) -> void:
    if button:
        button.add_theme_stylebox_override("normal", selected_style)

func _on_save_pressed() -> void:
    var file_path = "user://joyblocks_world.tscn"
    if not builder:
        return

    var saved_world := builder.world.duplicate() as Node
    var packed_scene = PackedScene.new()
    if packed_scene.pack(saved_world) == OK:
        ResourceSaver.save(packed_scene, file_path)

    var dialog := AcceptDialog.new()
    dialog.dialog_text = "Yay! World saved to: " + file_path
    add_child(dialog)
    dialog.popup_centered()

func _setup_default_styles() -> void:
    if normal_style == null:
        normal_style = StyleBoxFlat.new()
        normal_style.bg_color = Color(0.16, 0.23, 0.45, 0.95)
        normal_style.corner_radius_top_left = 14
        normal_style.corner_radius_top_right = 14
        normal_style.corner_radius_bottom_right = 14
        normal_style.corner_radius_bottom_left = 14

    if selected_style == null:
        selected_style = StyleBoxFlat.new()
        selected_style.bg_color = Color(1.0, 0.52, 0.12, 1.0)
        selected_style.border_width_left = 4
        selected_style.border_width_top = 4
        selected_style.border_width_right = 4
        selected_style.border_width_bottom = 4
        selected_style.border_color = Color(1.0, 0.94, 0.4, 1.0)
        selected_style.corner_radius_top_left = 14
        selected_style.corner_radius_top_right = 14
        selected_style.corner_radius_bottom_right = 14
        selected_style.corner_radius_bottom_left = 14
