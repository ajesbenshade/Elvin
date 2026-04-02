extends Resource
class_name ItemData

# Item resources power collectibles and make drag-and-drop modding easy.
@export var item_id: String = "sparkle_gem"
@export var display_name: String = "Sparkle Gem"
@export_file("*.tscn") var scene_path: String = ""
@export var item_scene: PackedScene
@export var icon: Texture2D
@export var tint: Color = Color(1.0, 0.8, 0.4, 1.0)
@export var pickup_particle_scene: PackedScene
@export var pickup_sfx: AudioStream
@export var stack_size: int = 99
