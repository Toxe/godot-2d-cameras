class_name CustomCamera extends Camera2D

enum CoordsType {
    Unknown,
    World,
    UI,
    Screen,
}

@export var coords_type := CoordsType.Unknown

var _zoom_tween: Tween

@onready var _zoom_target := zoom


static func get_symbol_for_coords_type(type: CoordsType) -> String:
    match type:
        CoordsType.World: return "🌐"
        CoordsType.UI: return "📐"
        CoordsType.Screen: return "🖥️"
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
