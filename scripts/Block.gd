extends Node3D

# Tiny happy bounce settings for every placed block.
@export var spawn_scale: Vector3 = Vector3(0.6, 0.6, 0.6)
@export var bounce_time: float = 0.25
@export var target_scale: Vector3 = Vector3.ONE

func bounce_into_place() -> void:
    # Spring from small to full size for a playful pop.
    scale = spawn_scale
    var tween = create_tween()
    tween.tween_property(self, "scale", target_scale, bounce_time).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
