class_name CustomCamera extends Camera2D

@export var coords_type := Enums.CoordsType.Unknown

var _zoom_tween: Tween

@onready var _zoom_target := zoom


func recenter_camera() -> void:
    position = Vector2.ZERO
    offset = Vector2.ZERO


func toggle_camera_smoothing() -> void:
    position_smoothing_enabled = !position_smoothing_enabled


static func get_symbol_for_coords_type(type: Enums.CoordsType) -> String:
    match type:
        Enums.CoordsType.World: return "(World)"
        Enums.CoordsType.WorldActor: return "(WorldActor)"
        Enums.CoordsType.WorldViewportCanvas: return "(WorldViewportCanvas)"
        Enums.CoordsType.Texture: return "(Texture)"
        Enums.CoordsType.UI: return "(UI)"
        Enums.CoordsType.UICanvas: return "(UICanvas)"
        Enums.CoordsType.Main: return "(Main)"
        Enums.CoordsType.Screen: return "(Screen)"
        _: return "❓"


func get_coords_type_symbol() -> String:
    return get_symbol_for_coords_type(coords_type)


func get_zoom_target() -> Vector2:
    return _zoom_target


func set_zoom_target(target: Vector2) -> void:
    _zoom_target = target.clamp(Vector2(0.1, 0.1), Vector2(8, 8))
    if _zoom_tween:
        _zoom_tween.kill()
    _zoom_tween = create_tween()
    _zoom_tween.tween_property(self, "zoom", _zoom_target, 1.0).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_SINE)
