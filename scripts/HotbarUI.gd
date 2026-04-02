extends Control

@export var hotbar_path: NodePath
@export var inventory_path: NodePath

@onready var hotbar = get_node(hotbar_path)
@onready var inventory = get_node(inventory_path)
@onready var slots: HBoxContainer = $Panel/Slots

func _ready() -> void:
    hotbar.selection_changed.connect(_on_selection_changed)
    inventory.inventory_changed.connect(_refresh)
    _build_slots()
    _refresh()

func _build_slots() -> void:
    for child in slots.get_children():
        child.queue_free()

    for i in 9:
        var btn := Button.new()
        btn.custom_minimum_size = Vector2(90, 90)
        btn.text = str(i + 1)
        btn.pressed.connect(func() -> void:
            hotbar.set_selected_index(i)
        )
        slots.add_child(btn)

func _refresh() -> void:
    for i in min(9, slots.get_child_count()):
        var button := slots.get_child(i) as Button
        var block = inventory.get_block_in_slot(i)
        var count = inventory.get_count_in_slot(i)
        if block:
            button.text = "%d\n%s\n%d" % [i + 1, block.display_name, count]
        else:
            button.text = "%d\n-" % [i + 1]

func _on_selection_changed(index: int, _data) -> void:
    for i in min(9, slots.get_child_count()):
        var button := slots.get_child(i) as Button
        button.modulate = Color(1.0, 0.9, 0.5, 1.0) if i == index else Color(1, 1, 1, 1)
