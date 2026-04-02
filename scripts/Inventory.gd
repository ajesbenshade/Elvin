extends Node
class_name Inventory

signal inventory_changed

@export var use_infinite_blocks: bool = true
@export var starting_hotbar_blocks: Array[Resource] = []

const HOTBAR_SIZE := 9

var hotbar_blocks: Array[Resource] = []
var hotbar_counts: Array[int] = []
var collectible_counts: Dictionary = {}
var selected_slot_index: int = 0

func _ready() -> void:
    _initialize_hotbar()
    inventory_changed.emit()

func _initialize_hotbar() -> void:
    hotbar_blocks.clear()
    hotbar_counts.clear()

    for i in HOTBAR_SIZE:
        hotbar_blocks.append(null)
        hotbar_counts.append(0)

    if starting_hotbar_blocks.is_empty():
        var default_paths := [
            "res://resources/blocks/GrassBlock.tres",
            "res://resources/blocks/RainbowBlock.tres",
            "res://resources/blocks/FlowerBlock.tres",
            "res://resources/blocks/CandyBlock.tres",
            "res://resources/blocks/CloudBlock.tres",
            "res://resources/blocks/SunshineBlock.tres",
            "res://resources/blocks/MintBlock.tres",
            "res://resources/blocks/StarBlock.tres",
            "res://resources/blocks/PeachBlock.tres"
        ]
        for i in min(default_paths.size(), HOTBAR_SIZE):
            var loaded := load(default_paths[i])
            if loaded:
                hotbar_blocks[i] = loaded
                hotbar_counts[i] = 999 if use_infinite_blocks else max(1, loaded.stack_size)
        return

    for i in min(starting_hotbar_blocks.size(), HOTBAR_SIZE):
        hotbar_blocks[i] = starting_hotbar_blocks[i]
        hotbar_counts[i] = 999 if use_infinite_blocks else max(1, starting_hotbar_blocks[i].stack_size)

func set_selected_slot(index: int) -> void:
    selected_slot_index = clamp(index, 0, HOTBAR_SIZE - 1)
    inventory_changed.emit()

func get_block_in_slot(index: int):
    if index < 0 or index >= hotbar_blocks.size():
        return null
    return hotbar_blocks[index]

func get_count_in_slot(index: int) -> int:
    if index < 0 or index >= hotbar_counts.size():
        return 0
    return hotbar_counts[index]

func can_place_selected() -> bool:
    if use_infinite_blocks:
        return get_block_in_slot(selected_slot_index) != null
    return get_block_in_slot(selected_slot_index) != null and get_count_in_slot(selected_slot_index) > 0

func consume_selected_block() -> void:
    if use_infinite_blocks:
        return
    if selected_slot_index < 0 or selected_slot_index >= hotbar_counts.size():
        return
    if hotbar_counts[selected_slot_index] > 0:
        hotbar_counts[selected_slot_index] -= 1
    inventory_changed.emit()

func add_generic_block(amount: int = 1) -> void:
    if use_infinite_blocks:
        return
    if selected_slot_index < 0 or selected_slot_index >= hotbar_counts.size():
        return
    hotbar_counts[selected_slot_index] += amount
    inventory_changed.emit()

func add_collectible(item_data, amount: int = 1) -> void:
    if item_data == null:
        return
    var key: String = item_data.item_id
    collectible_counts[key] = collectible_counts.get(key, 0) + amount
    inventory_changed.emit()

func serialize_inventory() -> Dictionary:
    var slot_data: Array = []
    for i in HOTBAR_SIZE:
        var block = hotbar_blocks[i]
        slot_data.append({
            "block_id": block.block_id if block else "",
            "count": hotbar_counts[i]
        })

    return {
        "selected_slot_index": selected_slot_index,
        "slots": slot_data,
        "collectibles": collectible_counts.duplicate()
    }
