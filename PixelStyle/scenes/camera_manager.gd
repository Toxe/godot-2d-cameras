class_name CameraManager extends Node

enum CoordsType {
    Unknown,
    World,
    UI,
    Screen,
}

@export var cameras: Array[Camera2D]

var _cameras_zoom_tweens: Array[Tween]
var _cameras_zoom_targets: Array[Vector2]

@onready var current_camera: Camera2D = _get_first_enabled_camera()


func _ready() -> void:
    _cameras_zoom_tweens.resize(cameras.size())
    for c in cameras:
        _cameras_zoom_targets.append(c.zoom)


func _process(delta: float) -> void:
    var camera_movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if !camera_movement.is_zero_approx():
        var camera_speed := 0.1 if Input.is_physical_key_pressed(Key.KEY_SHIFT) else 1.0
        if Input.is_physical_key_pressed(Key.KEY_CTRL):
            current_camera.position += camera_movement * 100.0 * delta * camera_speed / current_camera.zoom.x
        else:
            current_camera.offset += camera_movement * 100.0 * delta * camera_speed / current_camera.zoom.x


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("switch_camera"):
        next_camera()
    elif event.is_action_pressed("recenter_camera"):
        recenter_camera()
    elif event.is_action_pressed("toggle_camera_smoothing"):
        toggle_camera_smoothing()
    elif event.is_action_pressed("zoom_in"):
        var new_target_zoom := get_current_camera_zoom_target() + Vector2(0.1, 0.1)
        set_current_camera_zoom_target(new_target_zoom)
    elif event.is_action_pressed("zoom_out"):
        var new_target_zoom := get_current_camera_zoom_target() - Vector2(0.1, 0.1)
        set_current_camera_zoom_target(new_target_zoom)


func _get_first_enabled_camera() -> Camera2D:
    return cameras.get(cameras.find_custom(func(c: Camera2D) -> bool: return c.enabled))


func _get_current_camera_index() -> int:
    return cameras.find(current_camera)


func next_camera() -> void:
    var next_index := _get_current_camera_index() + 1
    current_camera.enabled = false
    current_camera = cameras[next_index] if next_index < cameras.size() else cameras[0]
    current_camera.enabled = true


func recenter_camera() -> void:
    current_camera.position = Vector2.ZERO
    current_camera.offset = Vector2.ZERO


func toggle_camera_smoothing() -> void:
    current_camera.position_smoothing_enabled = !current_camera.position_smoothing_enabled


func get_current_camera_coords_type() -> CoordsType:
    match current_camera.name:
        "GameCamera": return CoordsType.World
        "MainCamera": return CoordsType.UI
        _: return CoordsType.Unknown


func set_current_camera_zoom_target(target_zoom: Vector2) -> void:
    var index := _get_current_camera_index()
    target_zoom = target_zoom.clamp(Vector2(0.1, 0.1), Vector2(8, 8))
    _cameras_zoom_targets[index] = target_zoom
    if _cameras_zoom_tweens[index]:
        _cameras_zoom_tweens[index].kill()
    _cameras_zoom_tweens[index] = create_tween()
    _cameras_zoom_tweens[index].tween_property(current_camera, "zoom", target_zoom, 1.0).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_SINE)


func get_current_camera_zoom_target() -> Vector2:
    return _cameras_zoom_targets[_get_current_camera_index()]
