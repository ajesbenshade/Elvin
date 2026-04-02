extends Camera3D

@export var move_speed: float = 8.0
@export var boost_multiplier: float = 2.5
@export var look_sensitivity: float = 0.003
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

var yaw: float = 0.0
var pitch: float = 0.0
var mouse_locked: bool = true

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        mouse_locked = not mouse_locked
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_locked else Input.MOUSE_MODE_VISIBLE)

    if event is InputEventMouseMotion and mouse_locked:
        yaw -= event.relative.x * look_sensitivity
        pitch = clamp(pitch - event.relative.y * look_sensitivity, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
        rotation = Vector3(pitch, yaw, 0.0)

func _physics_process(delta: float) -> void:
    var input_dir := Vector3.ZERO
    if Input.is_action_pressed("move_forward"): input_dir.z -= 1
    if Input.is_action_pressed("move_back"): input_dir.z += 1
    if Input.is_action_pressed("move_left"): input_dir.x -= 1
    if Input.is_action_pressed("move_right"): input_dir.x += 1
    if Input.is_action_pressed("move_up"): input_dir.y += 1
    if Input.is_action_pressed("move_down"): input_dir.y -= 1

    if input_dir != Vector3.ZERO:
        input_dir = input_dir.normalized()
        var speed := move_speed * (1.0 + (boost_multiplier - 1.0 if Input.is_action_pressed("speed_boost") else 0.0))
        translate_object_local(input_dir * speed * delta)
