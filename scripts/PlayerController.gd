extends Camera3D

# Easy-to-tweak movement values.
@export var move_speed: float = 9.0
@export var boost_multiplier: float = 2.2
@export var look_sensitivity: float = 0.0028
@export var min_pitch_degrees: float = -80.0
@export var max_pitch_degrees: float = 80.0
@export var capture_mouse_on_ready: bool = true

var _yaw: float = 0.0
var _pitch: float = 0.0
var _mouse_locked: bool = true

func _ready() -> void:
    # Start in look mode so the game feels playable instantly.
    _mouse_locked = capture_mouse_on_ready
    _apply_mouse_mode()

func _unhandled_input(event: InputEvent) -> void:
    # Escape releases the mouse for UI clicks.
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        _mouse_locked = not _mouse_locked
        _apply_mouse_mode()

    # Left click recaptures mouse and still allows block placement input.
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not _mouse_locked:
        _mouse_locked = true
        _apply_mouse_mode()

    if event is InputEventMouseMotion and _mouse_locked:
        _yaw -= event.relative.x * look_sensitivity
        _pitch = clamp(
            _pitch - event.relative.y * look_sensitivity,
            deg_to_rad(min_pitch_degrees),
            deg_to_rad(max_pitch_degrees)
        )
        rotation = Vector3(_pitch, _yaw, 0.0)

func _physics_process(delta: float) -> void:
    var move_input := Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        move_input.z -= 1.0
    if Input.is_action_pressed("move_back"):
        move_input.z += 1.0
    if Input.is_action_pressed("move_left"):
        move_input.x -= 1.0
    if Input.is_action_pressed("move_right"):
        move_input.x += 1.0
    if Input.is_action_pressed("move_up"):
        move_input.y += 1.0
    if Input.is_action_pressed("move_down"):
        move_input.y -= 1.0

    if move_input == Vector3.ZERO:
        return

    move_input = move_input.normalized()
    var speed := move_speed
    if Input.is_action_pressed("speed_boost"):
        speed *= boost_multiplier
    translate_object_local(move_input * speed * delta)

func _apply_mouse_mode() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if _mouse_locked else Input.MOUSE_MODE_VISIBLE)
