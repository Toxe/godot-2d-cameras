class_name CameraManager extends Node

@export var cameras: Array[CustomCamera]

@onready var current_camera: CustomCamera = _get_first_enabled_camera()


func _process(delta: float) -> void:
    var camera_movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if !camera_movement.is_zero_approx():
        var camera_speed := 0.1 if Input.is_physical_key_pressed(Key.KEY_SHIFT) else 1.0
        if Input.is_physical_key_pressed(Key.KEY_CTRL):
            current_camera.position += camera_movement * 100.0 * delta * camera_speed / current_camera.zoom.x
        else:
            current_camera.offset += camera_movement * 100.0 * delta * camera_speed / current_camera.zoom.x


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("next_camera", false, true):
        next_camera()
    elif event.is_action_pressed("previous_camera", false, true):
        previous_camera()
    elif event.is_action_pressed("recenter_camera"):
        current_camera.recenter_camera()
    elif event.is_action_pressed("toggle_camera_smoothing"):
        current_camera.toggle_camera_smoothing()
    elif event.is_action_pressed("zoom_in"):
        var new_zoom_target := current_camera.get_zoom_target() + Vector2(0.1, 0.1)
        current_camera.set_zoom_target(new_zoom_target)
    elif event.is_action_pressed("zoom_out"):
        var new_zoom_target := current_camera.get_zoom_target() - Vector2(0.1, 0.1)
        current_camera.set_zoom_target(new_zoom_target)


func next_camera() -> void:
    var next_index := wrapi(_get_current_camera_index() + 1, 0, cameras.size())
    _switch_to_camera(next_index)


func previous_camera() -> void:
    var previous_index := wrapi(_get_current_camera_index() - 1, 0, cameras.size())
    _switch_to_camera(previous_index)


func select_camera(camera_name: String) -> void:
    var next_index := _find_camera_by_name(camera_name)
    if next_index >= 0:
        _switch_to_camera(next_index)


func _find_camera_by_name(camera_name: String) -> int:
    return cameras.find_custom(func(c: CustomCamera) -> bool: return c.name == camera_name)


func _get_first_enabled_camera() -> CustomCamera:
    return cameras.get(cameras.find_custom(func(c: CustomCamera) -> bool: return c.enabled))


func _get_current_camera_index() -> int:
    return cameras.find(current_camera)


func _switch_to_camera(index: int) -> void:
    assert(index >= 0 && index < cameras.size())
    current_camera.enabled = false
    current_camera = cameras[index]
    current_camera.enabled = true
