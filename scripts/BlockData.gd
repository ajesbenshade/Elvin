@icon("res://assets/icons/block.png")
extends Resource
class_name BlockData

@export var display_name: String = "Happy Block"
@export var color: Color = Color(0.3, 0.8, 0.3)
@export var particle_scene: PackedScene
@export var place_sfx: AudioStream
@export var break_sfx: AudioStream
@export var box_scale: Vector3 = Vector3.ONE
