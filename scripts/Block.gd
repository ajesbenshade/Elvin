extends Node3D

func bounce_into_place() -> void:
    scale = Vector3(0.6, 0.6, 0.6)
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
