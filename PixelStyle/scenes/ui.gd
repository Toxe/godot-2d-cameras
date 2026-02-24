class_name UI extends Control

@export var game: Game
@export var camera_manager: CameraManager
@export var texture_rect: TextureRect
@export var sub_viewport: SubViewport

@onready var frame_label: Label = $HBoxContainer/VBoxContainer/HBoxContainer9/FrameLabel
@onready var camera_label: Label = $HBoxContainer/VBoxContainer/HBoxContainer/CameraLabel
@onready var camera_zoom_slider: HSlider = $HBoxContainer/VBoxContainer/GridContainer/CameraZoomSlider
@onready var camera_zoom_label: Label = $HBoxContainer/VBoxContainer/GridContainer/CameraZoomLabel
@onready var texture_rect_label: Label = $HBoxContainer/VBoxContainer/HBoxContainer2/TextureRectLabel
@onready var king_label: Label = $HBoxContainer/VBoxContainer/HBoxContainer3/KingLabel
@onready var king_speed_slider: HSlider = $HBoxContainer/VBoxContainer/GridContainer/KingSpeedSlider
@onready var king_speed_label: Label = $HBoxContainer/VBoxContainer/GridContainer/KingSpeedLabel
@onready var priest_label: Label = $HBoxContainer/VBoxContainer/HBoxContainer7/PriestLabel
@onready var priest_speed_slider: HSlider = $HBoxContainer/VBoxContainer/GridContainer/PriestSpeedSlider
@onready var priest_speed_label: Label = $HBoxContainer/VBoxContainer/GridContainer/PriestSpeedLabel
@onready var window_size_label: Label = $HBoxContainer/VBoxContainer/HBoxContainer5/WindowSizeLabel


func _process(_delta: float) -> void:
    frame_label.text = "%0.6f\n%d\n%0.1f" % [Time.get_ticks_usec() / 1_000_000.0, Engine.get_process_frames(), Performance.get_monitor(Performance.TIME_FPS)]

    if camera_manager && camera_manager.current_camera:
        camera_label.text = "%s\n%s\n%s\n%s\n%s\n%s\n%s" % [
            camera_manager.current_camera.name,
            "on" if camera_manager.current_camera.position_smoothing_enabled else "off",
            Format.format_position(camera_manager.current_camera.position, camera_manager.get_current_camera_coords_type()),
            Format.format_position(camera_manager.current_camera.global_position, camera_manager.get_current_camera_coords_type()),
            Format.format_position(camera_manager.current_camera.get_target_position(), camera_manager.get_current_camera_coords_type()),
            Format.format_position(camera_manager.current_camera.offset, camera_manager.get_current_camera_coords_type()),
            Format.format_position(camera_manager.current_camera.get_screen_center_position(), camera_manager.get_current_camera_coords_type()),
        ]

        camera_zoom_slider.set_value_no_signal(camera_manager.get_current_camera_zoom_target().x)
        camera_zoom_label.text = "%.2f" % camera_manager.get_current_camera_zoom_target().x

    if texture_rect:
        texture_rect_label.text = "%s\n%s" % [Format.format_position(texture_rect.get_canvas_transform().origin), Format.format_position(texture_rect.get_screen_transform().origin)]

    if game:
        king_label.text = "%s\n%s" % [Format.format_position(game.king.global_position, CameraManager.CoordsType.World), Format.format_position(game.king.get_screen_transform().origin, CameraManager.CoordsType.World)]
        priest_label.text = "%s\n%s" % [Format.format_position(game.priest.global_position, CameraManager.CoordsType.World), Format.format_position(game.priest.get_screen_transform().origin, CameraManager.CoordsType.World)]
        window_size_label.text = "%s\n%s\n%s\n%s" % [Format.format_size(get_window().size), Format.format_size((game.get_viewport() as SubViewport).size), sub_viewport.snap_2d_transforms_to_pixel, sub_viewport.snap_2d_vertices_to_pixel]

        king_speed_slider.value = game.king_speed
        king_speed_label.text = "%.2f" % game.king_speed
        priest_speed_slider.value = game.priest_speed
        priest_speed_label.text = "%.2f (pixels per frame)" % game.priest_speed

    queue_redraw()


func _draw() -> void:
    if !DebugDraw.draw_enabled:
        return

    # axes
    DebugDraw.draw_axes(self, size / 2.0, "UI center: %s" % [Format.format_position(size / 2.0, CameraManager.CoordsType.UI, true)], Color.WHEAT, Color.BLACK)

    # camera
    if camera_manager && camera_manager.current_camera:
        var camera_position := camera_manager.current_camera.position
        var camera_offset := camera_manager.current_camera.offset
        var camera_target_position := camera_manager.current_camera.get_target_position()
        var camera_target_position_plus_offset := camera_target_position + camera_offset
        var camera_screen_center_position := camera_manager.current_camera.get_screen_center_position()
        var camera_coords_type := camera_manager.get_current_camera_coords_type()

        assert(camera_coords_type in [CameraManager.CoordsType.World, CameraManager.CoordsType.UI])

        var ui_coords_camera_target_position_plus_offset := transform_to_ui_coords(camera_coords_type, camera_target_position_plus_offset)
        var ui_coords_camera_screen_center_position := transform_to_ui_coords(camera_coords_type, camera_screen_center_position)
        var world_coords_camera_target_position_plus_offset := transform_to_world_coords(camera_coords_type, camera_target_position_plus_offset)
        var world_coords_camera_screen_center_position := transform_to_world_coords(camera_coords_type, camera_screen_center_position)

        draw_dashed_line(ui_coords_camera_target_position_plus_offset, ui_coords_camera_screen_center_position, Color.GREEN, 0.5, 1, false)
        DebugDraw.draw_labeled_circle(self, ui_coords_camera_target_position_plus_offset, 5, Color.YELLOW, Color.BLACK, 1, [
            "🎥 target_position + offset: %s" % [Format.format_position(world_coords_camera_target_position_plus_offset, CameraManager.CoordsType.World)],
            "%s" % [Format.format_position(ui_coords_camera_target_position_plus_offset, CameraManager.CoordsType.UI)],
        ])
        DebugDraw.draw_labeled_circle(self, ui_coords_camera_screen_center_position, 7, Color.GREEN, Color.BLACK, 1, [
            "🎥 screen_center_position: %s" % [Format.format_position(world_coords_camera_screen_center_position, CameraManager.CoordsType.World)],
            "%s" % [Format.format_position(ui_coords_camera_screen_center_position, CameraManager.CoordsType.UI)],
        ])

        if !camera_position.is_zero_approx():
            var ui_coords_from := transform_to_ui_coords(camera_coords_type, camera_target_position - camera_position)
            var ui_coords_to := transform_to_ui_coords(camera_coords_type, camera_target_position)
            draw_line(ui_coords_from, ui_coords_to, Color.DARK_GRAY, 0.5)
            DebugDraw.draw_labeled_circle(self, ui_coords_from, 3, Color.DARK_GRAY, Color.BLACK, 0.5, ["🎥 position: %s" % [Format.format_position(camera_position, camera_coords_type)]])

        if !camera_offset.is_zero_approx():
            var ui_coords_from := transform_to_ui_coords(camera_coords_type, camera_target_position)
            var ui_coords_to := transform_to_ui_coords(camera_coords_type, camera_target_position_plus_offset)
            draw_line(ui_coords_from, ui_coords_to, Color.DARK_GRAY, 0.5)
            DebugDraw.draw_labeled_circle(self, ui_coords_from, 3, Color.DARK_GRAY, Color.BLACK, 0.5, ["🎥 target_position (without offset): %s" % [Format.format_position(camera_target_position, camera_coords_type)]])

    # mouse
    var mouse_coords := get_local_mouse_position()
    var screen_coords := transform_ui_to_screen_coords(mouse_coords)
    var lines: Array[String]
    if texture_rect && game:
        lines.append(Format.format_position(transform_to_world_coords(CameraManager.CoordsType.UI, mouse_coords), CameraManager.CoordsType.World))
    lines.append(Format.format_position(mouse_coords, CameraManager.CoordsType.UI))
    lines.append(Format.format_position(screen_coords, CameraManager.CoordsType.Screen, true))
    DebugDraw.draw_labeled_circle(self, mouse_coords, 3, Color.LIGHT_GRAY, Color.BLACK, 0.25, lines)


func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_fullscreen"):
        if DisplayServer.window_get_mode() != DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
            DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
        else:
            DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
    elif event.is_action_pressed("toggle_ui"):
        ($HBoxContainer as Control).visible = !($HBoxContainer as Control).visible
    elif event.is_action_pressed("toggle_debug_draw"):
        DebugDraw.draw_enabled = !DebugDraw.draw_enabled
    elif event.is_action_pressed("toggle_debug_text"):
        DebugDraw.text_enabled = !DebugDraw.text_enabled
    elif event.is_action_pressed("toggle_snap_2d_transforms_to_pixel"):
        sub_viewport.snap_2d_transforms_to_pixel = !sub_viewport.snap_2d_transforms_to_pixel
    elif event.is_action_pressed("toggle_snap_2d_vertices_to_pixel"):
        sub_viewport.snap_2d_vertices_to_pixel = !sub_viewport.snap_2d_vertices_to_pixel
    elif event.is_action_pressed("quit"):
        get_tree().quit()


func transform_to_ui_coords(from: CameraManager.CoordsType, coords: Vector2) -> Vector2:
    assert(from in [CameraManager.CoordsType.World, CameraManager.CoordsType.UI])

    if from == CameraManager.CoordsType.UI:
        return coords

    var world_coords := coords
    var coords_on_world_canvas := game.get_global_transform_with_canvas() * world_coords
    var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas() * coords_on_world_canvas
    var coords_on_ui_canvas := get_global_transform_with_canvas().affine_inverse() * coords_on_texture_rect
    return coords_on_ui_canvas


func transform_to_world_coords(from: CameraManager.CoordsType, coords: Vector2) -> Vector2:
    assert(from in [CameraManager.CoordsType.World, CameraManager.CoordsType.UI])

    if from == CameraManager.CoordsType.World:
        return coords

    var ui_coords := coords
    var coords_on_ui_canvas := get_global_transform_with_canvas() * ui_coords
    var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_ui_canvas
    var coords_on_world_canvas := game.get_global_transform_with_canvas().affine_inverse() * coords_on_texture_rect
    return coords_on_world_canvas


func transform_ui_to_screen_coords(ui_coords: Vector2) -> Vector2:
    var coords_on_ui_canvas := get_global_transform_with_canvas() * ui_coords
    var coords_on_screen := get_viewport().get_screen_transform() * coords_on_ui_canvas
    return coords_on_screen


func _on_camera_zoom_slider_value_changed(value: float) -> void:
    camera_manager.set_current_camera_zoom_target(Vector2(value, value))


func _on_king_speed_slider_value_changed(value: float) -> void:
    game.king_speed = value
    king_speed_label.text = "%.2f" % game.king_speed


func _on_priest_speed_slider_value_changed(value: float) -> void:
    game.priest_speed = value
    priest_speed_label.text = "%.2f" % game.priest_speed
