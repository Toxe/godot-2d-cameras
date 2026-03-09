class_name UI extends Control

@export var world: World
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
        camera_label.text = "%s %s\n%s\n%s\n%s\n%s\n%s\n%s" % [
            camera_manager.current_camera.get_coords_type_symbol(), camera_manager.current_camera.name,
            "on" if camera_manager.current_camera.position_smoothing_enabled else "off",
            Format.format_position(camera_manager.current_camera.position, camera_manager.current_camera.coords_type),
            Format.format_position(camera_manager.current_camera.global_position, camera_manager.current_camera.coords_type),
            Format.format_position(camera_manager.current_camera.get_target_position(), camera_manager.current_camera.coords_type),
            Format.format_position(camera_manager.current_camera.offset, camera_manager.current_camera.coords_type),
            Format.format_position(camera_manager.current_camera.get_screen_center_position(), camera_manager.current_camera.coords_type),
        ]

        camera_zoom_slider.set_value_no_signal(camera_manager.current_camera.get_zoom_target().x)
        camera_zoom_label.text = "%.2f" % camera_manager.current_camera.get_zoom_target().x

    if texture_rect:
        texture_rect_label.text = "%s\n%s" % [Format.format_position(texture_rect.get_canvas_transform().origin), Format.format_position(texture_rect.get_screen_transform().origin)]

    if world:
        king_label.text = "%s\n%s" % [Format.format_position(world.king.global_position, Enums.CoordsType.World), Format.format_position(world.king.get_screen_transform().origin, Enums.CoordsType.World)]
        priest_label.text = "%s\n%s" % [Format.format_position(world.priest.global_position, Enums.CoordsType.World), Format.format_position(world.priest.get_screen_transform().origin, Enums.CoordsType.World)]
        window_size_label.text = "%s\n%s\n%s\n%s" % [Format.format_size(get_window().size), Format.format_size((world.get_viewport() as SubViewport).size), sub_viewport.snap_2d_transforms_to_pixel, sub_viewport.snap_2d_vertices_to_pixel]

        king_speed_slider.value = world.king_speed
        king_speed_label.text = "%.2f" % world.king_speed
        priest_speed_slider.value = world.priest_speed
        priest_speed_label.text = "%.2f (pixels per frame)" % world.priest_speed

    queue_redraw()


func _draw() -> void:
    if !DebugDraw.draw_enabled:
        return

    # axes
    DebugDraw.draw_axes(self, get_rect(), "UI center: %s" % [Format.format_position(get_rect().get_center(), Enums.CoordsType.UI, true)], Color.WHEAT, Color.BLACK)

    # camera
    if camera_manager && camera_manager.current_camera:
        var camera_position := camera_manager.current_camera.position
        var camera_offset := camera_manager.current_camera.offset
        var camera_target_position := camera_manager.current_camera.get_target_position()
        var camera_target_position_plus_offset := camera_target_position + camera_offset
        var camera_screen_center_position := camera_manager.current_camera.get_screen_center_position()
        var camera_coords_type := camera_manager.current_camera.coords_type
        var ui_coords_camera_target_position_plus_offset := transform_to_ui_coords(camera_coords_type, camera_target_position_plus_offset)
        var ui_coords_camera_screen_center_position := transform_to_ui_coords(camera_coords_type, camera_screen_center_position)

        if !camera_position.is_zero_approx():
            var ui_coords_from := transform_to_ui_coords(camera_coords_type, camera_target_position - camera_position)
            var ui_coords_to := transform_to_ui_coords(camera_coords_type, camera_target_position)
            draw_line(ui_coords_from, ui_coords_to, Color.DARK_GRAY, 0.5)
            DebugDraw.draw_labeled_circle(self, ui_coords_to, 3, Color.DARK_GRAY, Color.BLACK, 0.5, ["🎥 position: %s" % Format.format_position(camera_position, camera_coords_type)])

        if !camera_offset.is_zero_approx():
            var ui_coords_from := transform_to_ui_coords(camera_coords_type, camera_target_position)
            var ui_coords_to := transform_to_ui_coords(camera_coords_type, camera_target_position_plus_offset)
            draw_line(ui_coords_from, ui_coords_to, Color.DARK_GRAY, 0.5)

        draw_dashed_line(ui_coords_camera_target_position_plus_offset, ui_coords_camera_screen_center_position, Color.YELLOW, 0.5, 1, false)
        DebugDraw.draw_labeled_circle(self, ui_coords_camera_screen_center_position, 8, Color.YELLOW, Color.BLACK, 1, ["🎥 screen_center_position: %s" % Format.format_position(camera_screen_center_position, camera_coords_type)])

        var target_position_label_lines: Array[String]
        if camera_offset.is_zero_approx():
            target_position_label_lines = [
                "🎥 target_position: %s" % Format.format_position(camera_target_position_plus_offset, camera_coords_type),
            ]
        else:
            target_position_label_lines = [
                "🎥 target_position + offset: %s" % Format.format_position(camera_target_position_plus_offset, camera_coords_type),
                "🎥 offset: %s" % Format.format_position(camera_offset, camera_coords_type),
            ]
        DebugDraw.draw_labeled_circle(self, ui_coords_camera_target_position_plus_offset, 12, Color.GREEN, Color.BLACK, 1, target_position_label_lines)

    # mouse
    const from_type := Enums.CoordsType.UI
    var ui_coords := get_local_mouse_position()
    var world_coords := transform_to_world_coords(from_type, ui_coords)
    var world_actor_coords := transform_to_world_actor_coords(from_type, ui_coords)
    var world_viewport_canvas_coords := transform_to_world_viewport_canvas_coords(from_type, ui_coords)
    var texture_coords := transform_to_texture_coords(from_type, ui_coords)
    var ui_canvas_coords := transform_to_ui_canvas_coords(from_type, ui_coords)
    var main_viewport_coords := transform_to_main_viewport_coords(from_type, ui_coords)
    var screen_coords := transform_to_screen_coords(from_type, ui_coords)

    var lines: Array[String]
    lines.append(Format.format_position(world_coords, Enums.CoordsType.World))
    lines.append(Format.format_position(world_actor_coords, Enums.CoordsType.WorldActor))
    lines.append(Format.format_position(world_viewport_canvas_coords, Enums.CoordsType.WorldViewportCanvas))
    lines.append(Format.format_position(texture_coords, Enums.CoordsType.Texture))
    lines.append(Format.format_position(ui_coords, Enums.CoordsType.UI))
    lines.append(Format.format_position(ui_canvas_coords, Enums.CoordsType.UICanvas))
    lines.append(Format.format_position(main_viewport_coords, Enums.CoordsType.Main))
    lines.append(Format.format_position(screen_coords, Enums.CoordsType.Screen, true))
    DebugDraw.draw_labeled_circle(self, ui_coords, 3, Color.LIGHT_GRAY, Color.BLACK, 0.25, lines)


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


func transform_to_world_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    match from:
        Enums.CoordsType.World, Enums.CoordsType.WorldActor:
            return coords
        Enums.CoordsType.WorldViewportCanvas:
            var coords_on_world_viewport_canvas := coords
            var coords_in_world := world.get_global_transform_with_canvas().affine_inverse() * coords_on_world_viewport_canvas
            return coords_in_world
        Enums.CoordsType.Texture:
            var coords_on_texture_rect := coords
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            var coords_in_world := world.get_global_transform_with_canvas().affine_inverse() * coords_on_world_viewport_canvas
            return coords_in_world
        Enums.CoordsType.UI:
            var coords_on_ui := coords
            var coords_on_ui_canvas := get_global_transform_with_canvas() * coords_on_ui
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_ui_canvas
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            var coords_in_world := world.get_global_transform_with_canvas().affine_inverse() * coords_on_world_viewport_canvas
            return coords_in_world
        Enums.CoordsType.UICanvas:
            var coords_on_ui_canvas := coords
            var coords_on_main_viewport := get_canvas_transform() * coords_on_ui_canvas
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            var coords_in_world := world.get_global_transform_with_canvas().affine_inverse() * coords_on_world_viewport_canvas
            return coords_in_world
        Enums.CoordsType.Main:
            var coords_on_main_viewport := coords
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            var coords_in_world := world.get_global_transform_with_canvas().affine_inverse() * coords_on_world_viewport_canvas
            return coords_in_world
        Enums.CoordsType.Screen:
            var coords_on_screen := coords
            var coords_on_main_viewport := get_viewport().get_screen_transform().affine_inverse() * coords_on_screen
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            var coords_in_world := world.get_global_transform_with_canvas().affine_inverse() * coords_on_world_viewport_canvas
            return coords_in_world
        _:
            assert(false, "Enums.CoordsType %s not supported" % from)
            return Vector2.ZERO


func transform_to_world_actor_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    return transform_to_world_coords(from, coords)


func transform_to_world_viewport_canvas_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    match from:
        Enums.CoordsType.World, Enums.CoordsType.WorldActor:
            var coords_in_world := coords
            var coords_on_world_viewport_canvas := world.get_global_transform_with_canvas() * coords_in_world
            return coords_on_world_viewport_canvas
        Enums.CoordsType.WorldViewportCanvas:
            return coords
        Enums.CoordsType.Texture:
            var coords_on_texture_rect := coords
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            return coords_on_world_viewport_canvas
        Enums.CoordsType.UI:
            var coords_on_ui := coords
            var coords_on_ui_canvas := get_global_transform_with_canvas() * coords_on_ui
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_ui_canvas
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            return coords_on_world_viewport_canvas
        Enums.CoordsType.UICanvas:
            var coords_on_ui_canvas := coords
            var coords_on_main_viewport := get_canvas_transform() * coords_on_ui_canvas
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            return coords_on_world_viewport_canvas
        Enums.CoordsType.Main:
            var coords_on_main_viewport := coords
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            return coords_on_world_viewport_canvas
        Enums.CoordsType.Screen:
            var coords_on_screen := coords
            var coords_on_main_viewport := get_viewport().get_screen_transform().affine_inverse() * coords_on_screen
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            var coords_on_world_viewport_canvas := to_viewport_coords(coords_on_texture_rect)
            return coords_on_world_viewport_canvas
        _:
            assert(false, "Enums.CoordsType %s not supported" % from)
            return Vector2.ZERO


func transform_to_texture_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    match from:
        Enums.CoordsType.World, Enums.CoordsType.WorldActor:
            var coords_in_world := coords
            var coords_on_world_viewport_canvas := world.get_global_transform_with_canvas() * coords_in_world
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            return coords_on_texture_rect
        Enums.CoordsType.WorldViewportCanvas:
            var coords_on_world_viewport_canvas := coords
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            return coords_on_texture_rect
        Enums.CoordsType.Texture:
            return coords
        Enums.CoordsType.UI:
            var coords_on_ui := coords
            var coords_on_ui_canvas := get_global_transform_with_canvas() * coords_on_ui
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_ui_canvas
            return coords_on_texture_rect
        Enums.CoordsType.UICanvas:
            var coords_on_ui_canvas := coords
            var coords_on_main_viewport := get_canvas_transform() * coords_on_ui_canvas
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            return coords_on_texture_rect
        Enums.CoordsType.Main:
            var coords_on_main_viewport := coords
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            return coords_on_texture_rect
        Enums.CoordsType.Screen:
            var coords_on_screen := coords
            var coords_on_main_viewport := get_viewport().get_screen_transform().affine_inverse() * coords_on_screen
            var coords_on_texture_rect := texture_rect.get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            return coords_on_texture_rect
        _:
            assert(false, "Enums.CoordsType %s not supported" % from)
            return Vector2.ZERO


func transform_to_ui_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    match from:
        Enums.CoordsType.World, Enums.CoordsType.WorldActor:
            var coords_in_world := coords
            var coords_on_world_viewport_canvas := world.get_global_transform_with_canvas() * coords_in_world
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_ui_canvas := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_ui := get_global_transform_with_canvas().affine_inverse() * coords_on_ui_canvas
            return coords_on_ui
        Enums.CoordsType.WorldViewportCanvas:
            var coords_on_world_viewport_canvas := coords
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_ui_canvas := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_ui := get_global_transform_with_canvas().affine_inverse() * coords_on_ui_canvas
            return coords_on_ui
        Enums.CoordsType.Texture:
            var coords_on_texture_rect := coords
            var coords_on_ui_canvas := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_ui := get_global_transform_with_canvas().affine_inverse() * coords_on_ui_canvas
            return coords_on_ui
        Enums.CoordsType.UI:
            return coords
        Enums.CoordsType.UICanvas:
            var coords_on_ui_canvas := coords
            var coords_on_ui := get_global_transform().affine_inverse() * coords_on_ui_canvas
            return coords_on_ui
        Enums.CoordsType.Main:
            var coords_on_main_viewport := coords
            var coords_on_ui := get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            return coords_on_ui
        Enums.CoordsType.Screen:
            var coords_on_screen := coords
            var coords_on_main_viewport := get_viewport().get_screen_transform().affine_inverse() * coords_on_screen
            var coords_on_ui := get_global_transform_with_canvas().affine_inverse() * coords_on_main_viewport
            return coords_on_ui
        _:
            assert(false, "Enums.CoordsType %s not supported" % from)
            return Vector2.ZERO


func transform_to_ui_canvas_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    match from:
        Enums.CoordsType.World, Enums.CoordsType.WorldActor:
            var coords_in_world := coords
            var coords_on_world_viewport_canvas := world.get_global_transform_with_canvas() * coords_in_world
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_ui_canvas := get_canvas_transform().affine_inverse() * coords_on_main_viewport
            return coords_on_ui_canvas
        Enums.CoordsType.WorldViewportCanvas:
            var coords_on_world_viewport_canvas := coords
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_ui_canvas := get_canvas_transform().affine_inverse() * coords_on_main_viewport
            return coords_on_ui_canvas
        Enums.CoordsType.Texture:
            var coords_on_texture_rect := coords
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_ui_canvas := get_canvas_transform().affine_inverse() * coords_on_main_viewport
            return coords_on_ui_canvas
        Enums.CoordsType.UI:
            var coords_on_ui := coords
            var coords_on_ui_canvas := get_global_transform() * coords_on_ui
            return coords_on_ui_canvas
        Enums.CoordsType.UICanvas:
            return coords
        Enums.CoordsType.Main:
            var coords_on_main_viewport := coords
            var coords_on_ui_canvas := get_canvas_transform().affine_inverse() * coords_on_main_viewport
            return coords_on_ui_canvas
        Enums.CoordsType.Screen:
            var coords_on_screen := coords
            var coords_on_main_viewport := get_viewport().get_screen_transform().affine_inverse() * coords_on_screen
            var coords_on_ui_canvas := get_canvas_transform().affine_inverse() * coords_on_main_viewport
            return coords_on_ui_canvas
        _:
            assert(false, "Enums.CoordsType %s not supported" % from)
            return Vector2.ZERO


func transform_to_main_viewport_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    match from:
        Enums.CoordsType.World, Enums.CoordsType.WorldActor:
            var coords_in_world := coords
            var coords_on_world_viewport_canvas := world.get_global_transform_with_canvas() * coords_in_world
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            return coords_on_main_viewport
        Enums.CoordsType.WorldViewportCanvas:
            var coords_on_world_viewport_canvas := coords
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            return coords_on_main_viewport
        Enums.CoordsType.Texture:
            var coords_on_texture_rect := coords
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            return coords_on_main_viewport
        Enums.CoordsType.UI:
            var coords_on_ui := coords
            var coords_on_main_viewport := get_global_transform_with_canvas() * coords_on_ui
            return coords_on_main_viewport
        Enums.CoordsType.UICanvas:
            var coords_on_ui_canvas := coords
            var coords_on_main_viewport := get_canvas_transform() * coords_on_ui_canvas
            return coords_on_main_viewport
        Enums.CoordsType.Main:
            return coords
        Enums.CoordsType.Screen:
            var coords_on_screen := coords
            var coords_on_main_viewport := get_viewport().get_screen_transform().affine_inverse() * coords_on_screen
            return coords_on_main_viewport
        _:
            assert(false, "Enums.CoordsType %s not supported" % from)
            return Vector2.ZERO


func transform_to_screen_coords(from: Enums.CoordsType, coords: Vector2) -> Vector2:
    match from:
        Enums.CoordsType.World, Enums.CoordsType.WorldActor:
            var coords_in_world := coords
            var coords_on_world_viewport_canvas := world.get_global_transform_with_canvas() * coords_in_world
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_screen := get_viewport().get_screen_transform() * coords_on_main_viewport
            return coords_on_screen
        Enums.CoordsType.WorldViewportCanvas:
            var coords_on_world_viewport_canvas := coords
            var coords_on_texture_rect := to_viewport_coords(coords_on_world_viewport_canvas)
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_screen := get_viewport().get_screen_transform() * coords_on_main_viewport
            return coords_on_screen
        Enums.CoordsType.Texture:
            var coords_on_texture_rect := coords
            var coords_on_main_viewport := texture_rect.get_global_transform_with_canvas() * coords_on_texture_rect
            var coords_on_screen := get_viewport().get_screen_transform() * coords_on_main_viewport
            return coords_on_screen
        Enums.CoordsType.UI:
            var coords_on_ui := coords
            var coords_on_main_viewport := get_global_transform_with_canvas() * coords_on_ui
            var coords_on_screen := get_viewport().get_screen_transform() * coords_on_main_viewport
            return coords_on_screen
        Enums.CoordsType.UICanvas:
            var coords_on_ui_canvas := coords
            var coords_on_main_viewport := get_canvas_transform() * coords_on_ui_canvas
            var coords_on_screen := get_viewport().get_screen_transform() * coords_on_main_viewport
            return coords_on_screen
        Enums.CoordsType.Main:
            var coords_on_main_viewport := coords
            var coords_on_screen := get_viewport().get_screen_transform() * coords_on_main_viewport
            return coords_on_screen
        Enums.CoordsType.Screen:
            return coords
        _:
            assert(false, "Enums.CoordsType %s not supported" % from)
            return Vector2.ZERO


func to_viewport_coords(pos: Vector2) -> Vector2:
    var normalized_pos := pos / texture_rect.size
    if texture_rect.flip_h:
        normalized_pos.x = 1.0 - normalized_pos.x
    if texture_rect.flip_v:
        normalized_pos.y = 1.0 - normalized_pos.y
    return normalized_pos * texture_rect.size


func _debug_dump_coords(from_type: Enums.CoordsType) -> void:
    var values: Dictionary[int, Array] = {}
    for t: int in Enums.CoordsType.values():
        values[t] = []
    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    for i in from.size():
        values[Enums.CoordsType.World].append(transform_to_world_coords(from_type, from[i]))
        values[Enums.CoordsType.WorldActor].append(transform_to_world_actor_coords(from_type, from[i]))
        values[Enums.CoordsType.WorldViewportCanvas].append(transform_to_world_viewport_canvas_coords(from_type, from[i]))
        values[Enums.CoordsType.Texture].append(transform_to_texture_coords(from_type, from[i]))
        values[Enums.CoordsType.UI].append(transform_to_ui_coords(from_type, from[i]))
        values[Enums.CoordsType.UICanvas].append(transform_to_ui_canvas_coords(from_type, from[i]))
        values[Enums.CoordsType.Main].append(transform_to_main_viewport_coords(from_type, from[i]))
        values[Enums.CoordsType.Screen].append(transform_to_screen_coords(from_type, from[i]))
    for t: int in Enums.CoordsType.values():
        var s := ""
        for i: int in values[t].size():
            if i > 0:
                s += ", "
            s += "Vector2%.3v" % values[t][i]
        print("[%s]" % s)


func _on_camera_zoom_slider_value_changed(value: float) -> void:
    camera_manager.current_camera.set_zoom_target(Vector2(value, value))


func _on_king_speed_slider_value_changed(value: float) -> void:
    world.king_speed = value
    king_speed_label.text = "%.2f" % world.king_speed


func _on_priest_speed_slider_value_changed(value: float) -> void:
    world.priest_speed = value
    priest_speed_label.text = "%.2f" % world.priest_speed
