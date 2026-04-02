extends Control
class_name Hotbar

signal block_selected(scene: PackedScene, preview_tint: Color)

@export var builder_path: NodePath
@export var block_scenes: Array[PackedScene] = []
@export var slot_names: Array[String] = ["Grass", "Rainbow", "Candy"]
@export var preview_tints: Array[Color] = [
    Color(0.35, 0.82, 1.0, 0.45),
    Color(1.0, 0.55, 0.85, 0.45),
    Color(1.0, 0.72, 0.45, 0.45)
]

@onready var builder = get_node_or_null(builder_path)
@onready var title_label: Label = $Panel/VBox/Title
@onready var button_row: HBoxContainer = $Panel/VBox/ButtonRow

var selected_index: int = 0

func _ready() -> void:
    title_label.text = "Pick A Happy Block"
    _build_buttons()
    _select_index(0)

func _process(_delta: float) -> void:
    for i in min(3, block_scenes.size()):
        if Input.is_action_just_pressed("hotbar_%d" % (i + 1)):
            _select_index(i)

func _build_buttons() -> void:
    for child in button_row.get_children():
        child.queue_free()

    for i in min(3, block_scenes.size()):
        var button := Button.new()
        button.custom_minimum_size = Vector2(170, 94)
        button.text = "%d\n%s" % [i + 1, _slot_name(i)]
        button.add_theme_font_size_override("font_size", 24)
        button.add_theme_color_override("font_color", Color(0.15, 0.17, 0.22, 1.0))
        button.add_theme_color_override("font_color_hover", Color(0.1, 0.1, 0.1, 1.0))
        button.add_theme_color_override("font_color_pressed", Color(0.1, 0.1, 0.1, 1.0))
        var normal_style := StyleBoxFlat.new()
        normal_style.bg_color = _slot_color(i)
        normal_style.corner_radius_top_left = 14
        normal_style.corner_radius_top_right = 14
        normal_style.corner_radius_bottom_left = 14
        normal_style.corner_radius_bottom_right = 14
        button.add_theme_stylebox_override("normal", normal_style)
        button.add_theme_stylebox_override("hover", normal_style)
        button.add_theme_stylebox_override("pressed", normal_style)
        button.pressed.connect(func() -> void:
            _select_index(i)
        )
        button_row.add_child(button)

func _select_index(index: int) -> void:
    if index < 0 or index >= block_scenes.size():
        return
    selected_index = index
    _refresh_button_highlight()

    var scene := block_scenes[selected_index]
    var tint := _preview_tint(selected_index)
    if builder and builder.has_method("set_selected_block"):
        builder.set_selected_block(scene, tint)
    block_selected.emit(scene, tint)

func _refresh_button_highlight() -> void:
    for i in button_row.get_child_count():
        var button := button_row.get_child(i) as Button
        if i == selected_index:
            button.modulate = Color(1.0, 0.9, 0.55, 1.0)
        else:
            button.modulate = Color(1, 1, 1, 1)

func _slot_name(index: int) -> String:
    if index < slot_names.size():
        return slot_names[index]
    return "Block %d" % (index + 1)

func _preview_tint(index: int) -> Color:
    if index < preview_tints.size():
        return preview_tints[index]
    return Color(0.35, 0.82, 1.0, 0.45)

func _slot_color(index: int) -> Color:
    if index == 0:
        return Color(0.58, 0.95, 0.58, 1.0)
    if index == 1:
        return Color(0.98, 0.6, 0.88, 1.0)
    if index == 2:
        return Color(1.0, 0.82, 0.58, 1.0)
    return Color(0.85, 0.9, 1.0, 1.0)
