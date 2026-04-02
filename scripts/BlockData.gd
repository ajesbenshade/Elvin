extends Resource
class_name BlockData

# A block resource can be duplicated and edited by kids to make new content.
@export var block_id: String = "happy_block"
@export var display_name: String = "Happy Block"
@export_file("*.tscn") var scene_path: String = ""
@export var block_scene: PackedScene
@export var icon: Texture2D
@export var material_color: Color = Color(0.3, 0.8, 0.3, 1.0)
@export var preview_tint: Color = Color(0.4, 0.8, 1.0, 0.5)
@export var place_particle_scene: PackedScene
@export var break_particle_scene: PackedScene
@export var place_sfx: AudioStream
@export var break_sfx: AudioStream
@export var stack_size: int = 999
