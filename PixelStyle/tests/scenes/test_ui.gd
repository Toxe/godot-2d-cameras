extends GutTest

const main_scene: PackedScene = preload("uid://dvkb4iyvuwwy4")
const error_margin := Vector2(0.01, 0.01)


func _create_ui() -> UI:
    var main: Main = add_child_autofree(main_scene.instantiate())
    var ui: UI = main.get_node("CanvasLayer/UI")
    ui.scale = Vector2(0.9, 0.9)
    ui.rotation = deg_to_rad(-2)

    var ui_canvas_layer := ui.get_canvas_layer_node()
    ui_canvas_layer.scale = Vector2(0.9, 0.9)
    ui_canvas_layer.rotation = deg_to_rad(5)

    main.scale = Vector2(0.9, 0.9)
    main.rotation = deg_to_rad(5)

    var texture_rect: TextureRect = main.get_node("TextureRect")
    texture_rect.scale = Vector2(0.5, 0.5)
    texture_rect.rotation = deg_to_rad(30)
    texture_rect.flip_h = true
    texture_rect.flip_v = true

    var world: World = main.get_node("SubViewport/World")
    world.scale = Vector2(0.5, 0.5)
    world.rotation = deg_to_rad(-30)

    ui.world.king_speed = 0.0
    ui.camera_manager.select_camera("WorldCamera")
    ui.camera_manager.current_camera.position_smoothing_enabled = false

    await wait_process_frames(1)

    return ui


func test_transform_from_World_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_actor_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(320.000, 180.000), Vector2(640.000, 360.000), Vector2(640.000, 0.000), Vector2(0.000, 360.000), Vector2(4032.000, 3024.000), Vector2(2016.000, 1512.000), Vector2(1920.000, 1080.000), Vector2(3840.000, 2160.000)]
    var to_world_viewport_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(503.564, 177.942), Vector2(687.128, 175.885), Vector2(597.128, 20.000), Vector2(410.000, 335.885), Vector2(2821.907, 481.430), Vector2(1570.954, 330.715), Vector2(1421.384, 167.654), Vector2(2522.769, 155.307)]
    var to_texture_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(136.436, 182.058), Vector2(-47.128, 184.115), Vector2(42.872, 340.000), Vector2(230.000, 24.115), Vector2(-2181.907, -121.430), Vector2(-930.954, 29.285), Vector2(-781.384, 192.346), Vector2(-1882.769, 204.693)]
    var to_ui_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(232.910, 126.928), Vector2(145.820, 73.857), Vector2(142.331, 173.796), Vector2(323.490, 80.061), Vector2(-770.002, -698.576), Vector2(-225.001, -259.288), Vector2(-202.539, -138.430), Vector2(-725.077, -456.861)]
    var to_ui_canvas_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(240.000, 135.000), Vector2(160.000, 90.000), Vector2(160.000, 180.000), Vector2(320.000, 90.000), Vector2(-688.000, -576.000), Vector2(-184.000, -198.000), Vector2(-160.000, -90.000), Vector2(-640.000, -360.000)]
    var to_main_viewport_coords: Array[Vector2] = [Vector2(272.785, 186.484), Vector2(204.589, 139.863), Vector2(136.392, 93.242), Vector2(129.333, 173.934), Vector2(279.844, 105.793), Vector2(-571.662, -570.394), Vector2(-149.439, -191.955), Vector2(-136.392, -93.242), Vector2(-545.570, -372.969)]
    var to_screen_coords: Array[Vector2] = [Vector2(818.355, 559.453), Vector2(613.766, 419.590), Vector2(409.177, 279.727), Vector2(387.998, 521.802), Vector2(839.533, 317.378), Vector2(-1714.986, -1711.182), Vector2(-448.316, -575.865), Vector2(-409.177, -279.727), Vector2(-1636.709, -1118.906)]

    for i in from.size():
        const from_type := Enums.CoordsType.World
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), from[i], error_margin)  # to self
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), to_world_actor_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), to_world_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), to_texture_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), to_ui_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), to_ui_canvas_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), to_main_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), to_screen_coords[i], error_margin)


func test_transform_from_WorldActor_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(320.000, 180.000), Vector2(640.000, 360.000), Vector2(640.000, 0.000), Vector2(0.000, 360.000), Vector2(4032.000, 3024.000), Vector2(2016.000, 1512.000), Vector2(1920.000, 1080.000), Vector2(3840.000, 2160.000)]
    var to_world_viewport_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(503.564, 177.942), Vector2(687.128, 175.885), Vector2(597.128, 20.000), Vector2(410.000, 335.885), Vector2(2821.907, 481.430), Vector2(1570.954, 330.715), Vector2(1421.384, 167.654), Vector2(2522.769, 155.307)]
    var to_texture_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(136.436, 182.058), Vector2(-47.128, 184.115), Vector2(42.872, 340.000), Vector2(230.000, 24.115), Vector2(-2181.907, -121.430), Vector2(-930.954, 29.285), Vector2(-781.384, 192.346), Vector2(-1882.769, 204.693)]
    var to_ui_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(232.910, 126.928), Vector2(145.820, 73.857), Vector2(142.331, 173.796), Vector2(323.490, 80.061), Vector2(-770.002, -698.576), Vector2(-225.001, -259.288), Vector2(-202.539, -138.430), Vector2(-725.077, -456.861)]
    var to_ui_canvas_coords: Array[Vector2] = [Vector2(320.000, 180.000), Vector2(240.000, 135.000), Vector2(160.000, 90.000), Vector2(160.000, 180.000), Vector2(320.000, 90.000), Vector2(-688.000, -576.000), Vector2(-184.000, -198.000), Vector2(-160.000, -90.000), Vector2(-640.000, -360.000)]
    var to_main_viewport_coords: Array[Vector2] = [Vector2(272.785, 186.484), Vector2(204.589, 139.863), Vector2(136.392, 93.242), Vector2(129.333, 173.934), Vector2(279.844, 105.793), Vector2(-571.662, -570.394), Vector2(-149.439, -191.955), Vector2(-136.392, -93.242), Vector2(-545.570, -372.969)]
    var to_screen_coords: Array[Vector2] = [Vector2(818.355, 559.453), Vector2(613.766, 419.590), Vector2(409.177, 279.727), Vector2(387.998, 521.802), Vector2(839.533, 317.378), Vector2(-1714.986, -1711.182), Vector2(-448.316, -575.865), Vector2(-409.177, -279.727), Vector2(-1636.709, -1118.906)]

    for i in from.size():
        const from_type := Enums.CoordsType.WorldActor
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), to_world_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), from[i], error_margin)  # to self
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), to_world_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), to_texture_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), to_ui_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), to_ui_canvas_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), to_main_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), to_screen_coords[i], error_margin)


func test_transform_from_WorldViewport_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_coords: Array[Vector2] = [Vector2(-374.256, -631.769), Vector2(0.000, 0.000), Vector2(374.256, 631.769), Vector2(734.256, 8.231), Vector2(-734.256, -8.231), Vector2(3585.373, 8637.952), Vector2(1605.558, 4003.092), Vector2(1871.281, 3158.846), Vector2(4116.819, 6949.460)]
    var to_world_actor_coords: Array[Vector2] = [Vector2(-374.256, -631.769), Vector2(0.000, 0.000), Vector2(374.256, 631.769), Vector2(734.256, 8.231), Vector2(-734.256, -8.231), Vector2(3585.373, 8637.952), Vector2(1605.558, 4003.092), Vector2(1871.281, 3158.846), Vector2(4116.819, 6949.460)]
    var to_texture_coords: Array[Vector2] = [Vector2(640.000, 360.000), Vector2(320.000, 180.000), Vector2(0.000, 0.000), Vector2(0.000, 360.000), Vector2(640.000, 0.000), Vector2(-3392.000, -2664.000), Vector2(-1376.000, -1152.000), Vector2(-1280.000, -720.000), Vector2(-3200.000, -1800.000)]
    var to_ui_coords: Array[Vector2] = [Vector2(417.772, 359.013), Vector2(320.000, 180.000), Vector2(222.228, 0.987), Vector2(116.244, 170.597), Vector2(523.756, 189.403), Vector2(-591.591, -2252.727), Vector2(-86.910, -946.857), Vector2(-168.861, -715.063), Vector2(-755.494, -1789.140)]
    var to_ui_canvas_coords: Array[Vector2] = [Vector2(413.564, 337.942), Vector2(320.000, 180.000), Vector2(226.436, 22.058), Vector2(136.436, 177.942), Vector2(503.564, 182.058), Vector2(-576.343, -1979.488), Vector2(-81.390, -820.773), Vector2(-147.820, -609.711), Vector2(-709.205, -1557.365)]
    var to_main_viewport_coords: Array[Vector2] = [Vector2(344.283, 335.431), Vector2(272.785, 186.484), Vector2(201.287, 37.538), Vector2(108.367, 170.241), Vector2(437.202, 202.728), Vector2(-361.464, -1819.968), Vector2(-8.590, -742.269), Vector2(-84.706, -558.247), Vector2(-513.695, -1451.925)]
    var to_screen_coords: Array[Vector2] = [Vector2(1032.849, 1006.292), Vector2(818.355, 559.453), Vector2(603.860, 112.614), Vector2(325.102, 510.722), Vector2(1311.607, 608.184), Vector2(-1084.391, -5459.905), Vector2(-25.771, -2226.806), Vector2(-254.118, -1674.742), Vector2(-1541.086, -4355.775)]

    for i in from.size():
        const from_type := Enums.CoordsType.WorldViewport
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), to_world_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), to_world_actor_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), from[i], error_margin)  # to self
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), to_texture_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), to_ui_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), to_ui_canvas_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), to_main_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), to_screen_coords[i], error_margin)


func test_transform_from_Texture_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_coords: Array[Vector2] = [Vector2(374.256, 631.769), Vector2(0.000, 0.000), Vector2(-374.256, -631.769), Vector2(-734.256, -8.231), Vector2(734.256, 8.231), Vector2(-3585.373, -8637.952), Vector2(-1605.558, -4003.091), Vector2(-1871.281, -3158.846), Vector2(-4116.819, -6949.460)]
    var to_world_actor_coords: Array[Vector2] = [Vector2(374.256, 631.769), Vector2(0.000, 0.000), Vector2(-374.256, -631.769), Vector2(-734.256, -8.231), Vector2(734.256, 8.231), Vector2(-3585.373, -8637.952), Vector2(-1605.558, -4003.091), Vector2(-1871.281, -3158.846), Vector2(-4116.819, -6949.460)]
    var to_world_viewport_coords: Array[Vector2] = [Vector2(640.000, 360.000), Vector2(320.000, 180.000), Vector2(0.000, 0.000), Vector2(0.000, 360.000), Vector2(640.000, 0.000), Vector2(-3392.000, -2664.000), Vector2(-1376.000, -1152.000), Vector2(-1280.000, -720.000), Vector2(-3200.000, -1800.000)]
    var to_ui_coords: Array[Vector2] = [Vector2(222.228, 0.987), Vector2(320.000, 180.000), Vector2(417.772, 359.013), Vector2(523.756, 189.403), Vector2(116.244, 170.597), Vector2(1231.591, 2612.728), Vector2(726.910, 1306.857), Vector2(808.861, 1075.063), Vector2(1395.494, 2149.140)]
    var to_ui_canvas_coords: Array[Vector2] = [Vector2(226.436, 22.058), Vector2(320.000, 180.000), Vector2(413.564, 337.942), Vector2(503.564, 182.058), Vector2(136.436, 177.942), Vector2(1216.343, 2339.488), Vector2(721.389, 1180.773), Vector2(787.820, 969.711), Vector2(1349.205, 1917.365)]
    var to_main_viewport_coords: Array[Vector2] = [Vector2(201.287, 37.538), Vector2(272.785, 186.484), Vector2(344.283, 335.431), Vector2(437.202, 202.728), Vector2(108.367, 170.241), Vector2(907.033, 2192.937), Vector2(554.160, 1115.238), Vector2(630.276, 931.216), Vector2(1059.265, 1824.894)]
    var to_screen_coords: Array[Vector2] = [Vector2(603.860, 112.614), Vector2(818.355, 559.453), Vector2(1032.849, 1006.292), Vector2(1311.607, 608.184), Vector2(325.102, 510.722), Vector2(2721.100, 6578.811), Vector2(1662.480, 3345.713), Vector2(1890.827, 2793.648), Vector2(3177.795, 5474.682)]

    for i in from.size():
        const from_type := Enums.CoordsType.Texture
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), to_world_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), to_world_actor_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), to_world_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), from[i], error_margin)  # to self
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), to_ui_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), to_ui_canvas_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), to_main_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), to_screen_coords[i], error_margin)


func test_transform_from_UI_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_coords: Array[Vector2] = [Vector2(1173.913, 607.401), Vector2(0.000, -0.000), Vector2(-1173.913, -607.401), Vector2(-1128.683, 687.809), Vector2(1128.683, -687.810), Vector2(-13712.373, -9765.796), Vector2(-6269.230, -4579.197), Vector2(-5869.565, -3037.005), Vector2(-12913.044, -6681.412)]
    var to_world_actor_coords: Array[Vector2] = [Vector2(1173.913, 607.401), Vector2(0.000, -0.000), Vector2(-1173.913, -607.401), Vector2(-1128.683, 687.809), Vector2(1128.683, -687.810), Vector2(-13712.373, -9765.796), Vector2(-6269.230, -4579.197), Vector2(-5869.565, -3037.005), Vector2(-12913.044, -6681.412)]
    var to_world_viewport_coords: Array[Vector2] = [Vector2(980.170, 149.534), Vector2(320.000, 180.000), Vector2(-340.169, 210.466), Vector2(3.218, 760.001), Vector2(636.782, -400.001), Vector2(-8059.081, -620.620), Vector2(-3539.456, -235.543), Vector2(-2980.848, 332.330), Vector2(-6941.865, 515.125)]
    var to_texture_coords: Array[Vector2] = [Vector2(-340.170, 210.466), Vector2(320.000, 180.000), Vector2(980.169, 149.534), Vector2(636.782, -400.001), Vector2(3.218, 760.001), Vector2(8699.081, 980.620), Vector2(4179.456, 595.543), Vector2(3620.848, 27.670), Vector2(7581.865, -155.125)]
    var to_ui_canvas_coords: Array[Vector2] = [Vector2(26.522, 28.150), Vector2(320.000, 180.000), Vector2(613.478, 331.850), Vector2(602.171, 8.048), Vector2(37.829, 351.952), Vector2(3748.094, 2621.448), Vector2(1887.308, 1324.799), Vector2(1787.391, 939.251), Vector2(3548.261, 1850.353)]
    var to_main_viewport_coords: Array[Vector2] = [Vector2(21.571, 27.319), Vector2(272.785, 186.484), Vector2(523.999, 345.650), Vector2(539.260, 54.450), Vector2(6.309, 318.519), Vector2(3154.820, 2644.327), Vector2(1588.196, 1335.823), Vector2(1528.856, 982.313), Vector2(3036.141, 1937.307)]
    var to_screen_coords: Array[Vector2] = [Vector2(64.712, 81.956), Vector2(818.354, 559.453), Vector2(1571.997, 1036.950), Vector2(1617.780, 163.349), Vector2(18.928, 955.557), Vector2(9464.461, 7932.980), Vector2(4764.587, 4007.468), Vector2(4586.567, 2946.938), Vector2(9108.422, 5811.919)]

    for i in from.size():
        const from_type := Enums.CoordsType.UI
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), to_world_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), to_world_actor_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), to_world_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), to_texture_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), from[i], error_margin)  # to self
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), to_ui_canvas_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), to_main_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), to_screen_coords[i], error_margin)


func test_transform_from_UICanvas_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_coords: Array[Vector2] = [Vector2(1280.000, 720.000), Vector2(0.000, -0.000), Vector2(-1280.000, -720.000), Vector2(-1280.000, 720.000), Vector2(1280.000, -720.000), Vector2(-14848.000, -11376.001), Vector2(-6784.000, -5328.000), Vector2(-6400.001, -3600.000), Vector2(-14080.002, -7920.001)]
    var to_world_actor_coords: Array[Vector2] = [Vector2(1280.000, 720.000), Vector2(0.000, -0.000), Vector2(-1280.000, -720.000), Vector2(-1280.000, 720.000), Vector2(1280.000, -720.000), Vector2(-14848.000, -11376.001), Vector2(-6784.000, -5328.000), Vector2(-6400.001, -3600.000), Vector2(-14080.002, -7920.001)]
    var to_world_viewport_coords: Array[Vector2] = [Vector2(1054.256, 171.769), Vector2(320.000, 180.000), Vector2(-414.256, 188.231), Vector2(-54.256, 811.769), Vector2(694.256, -451.769), Vector2(-8953.373, -1033.953), Vector2(-3949.558, -431.092), Vector2(-3351.282, 221.154), Vector2(-7756.820, 270.539)]
    var to_texture_coords: Array[Vector2] = [Vector2(-414.256, 188.231), Vector2(320.000, 180.000), Vector2(1054.256, 171.769), Vector2(694.256, -451.769), Vector2(-54.256, 811.769), Vector2(9593.373, 1393.953), Vector2(4589.558, 791.092), Vector2(3991.282, 138.846), Vector2(8396.820, 89.461)]
    var to_ui_coords: Array[Vector2] = [Vector2(-28.359, -32.287), Vector2(320.000, 180.000), Vector2(668.359, 392.287), Vector2(682.319, -7.469), Vector2(-42.319, 367.469), Vector2(4331.649, 3482.016), Vector2(2151.645, 1724.865), Vector2(2061.795, 1241.434), Vector2(4151.950, 2515.156)]
    var to_main_viewport_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(272.785, 186.484), Vector2(545.570, 372.969), Vector2(573.808, 50.202), Vector2(-28.238, 322.767), Vector2(3377.788, 3027.514), Vector2(1688.894, 1513.757), Vector2(1636.709, 1118.906), Vector2(3273.418, 2237.813)]
    var to_screen_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(818.354, 559.453), Vector2(1636.709, 1118.906), Vector2(1721.424, 150.605), Vector2(-84.715, 968.301), Vector2(10133.363, 9082.542), Vector2(5066.682, 4541.271), Vector2(4910.127, 3356.719), Vector2(9820.254, 6713.438)]

    for i in from.size():
        const from_type := Enums.CoordsType.UICanvas
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), to_world_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), to_world_actor_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), to_world_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), to_texture_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), to_ui_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), from[i], error_margin)  # to self
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), to_main_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), to_screen_coords[i], error_margin)


func test_transform_from_Main_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_coords: Array[Vector2] = [Vector2(1280.000, 720.000), Vector2(-206.535, 46.999), Vector2(-1693.070, -626.002), Vector2(-1553.621, 967.910), Vector2(1140.551, -873.912), Vector2(-17743.184, -11107.028), Vector2(-8231.592, -5193.514), Vector2(-7639.209, -3318.006), Vector2(-16558.420, -7356.013)]
    var to_world_actor_coords: Array[Vector2] = [Vector2(1280.000, 720.000), Vector2(-206.535, 46.999), Vector2(-1693.070, -626.002), Vector2(-1553.621, 967.910), Vector2(1140.551, -873.912), Vector2(-17743.184, -11107.028), Vector2(-8231.592, -5193.514), Vector2(-7639.209, -3318.006), Vector2(-16558.420, -7356.013)]
    var to_world_viewport_coords: Array[Vector2] = [Vector2(1054.256, 171.769), Vector2(242.318, 251.985), Vector2(-569.621, 332.201), Vector2(-110.760, 987.522), Vector2(595.395, -483.553), Vector2(-10139.781, -193.688), Vector2(-4542.763, -10.959), Vector2(-3817.376, 653.064), Vector2(-8689.010, 1134.358)]
    var to_texture_coords: Array[Vector2] = [Vector2(-414.256, 188.231), Vector2(397.682, 108.015), Vector2(1209.621, 27.799), Vector2(750.760, -627.522), Vector2(44.605, 843.553), Vector2(10779.781, 553.688), Vector2(5182.762, 370.959), Vector2(4457.376, -293.064), Vector2(9329.010, -774.358)]
    var to_ui_coords: Array[Vector2] = [Vector2(-28.359, -32.287), Vector2(377.792, 168.955), Vector2(783.942, 370.197), Vector2(760.682, -73.639), Vector2(-5.099, 411.549), Vector2(5137.985, 3435.414), Vector2(2554.813, 1701.563), Vector2(2408.544, 1175.164), Vector2(4845.448, 2382.614)]
    var to_ui_canvas_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(371.634, 168.250), Vector2(743.267, 336.500), Vector2(708.405, -61.977), Vector2(34.862, 398.478), Vector2(4755.796, 2956.757), Vector2(2377.898, 1478.378), Vector2(2229.802, 1009.501), Vector2(4459.604, 2019.003)]
    var to_screen_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(960.000, 540.000), Vector2(1920.000, 1080.000), Vector2(1920.000, 0.000), Vector2(0.000, 1080.000), Vector2(12096.000, 9072.000), Vector2(6048.000, 4536.000), Vector2(5760.000, 3240.000), Vector2(11520.000, 6480.000)]

    for i in from.size():
        const from_type := Enums.CoordsType.Main
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), to_world_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), to_world_actor_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), to_world_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), to_texture_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), to_ui_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), to_ui_canvas_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), from[i], error_margin)  # to self
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), to_screen_coords[i], error_margin)


func test_transform_from_Screen_coords() -> void:
    var ui := await _create_ui()

    var from: Array[Vector2] = [Vector2(0, 0), Vector2(320, 180), Vector2(640, 360), Vector2(640, 0), Vector2(0, 360), Vector2(4032, 3024), Vector2(4032, 3024) / 2, Vector2(1920, 1080), 2 * Vector2(1920, 1080)]
    var to_world_coords: Array[Vector2] = [Vector2(1280.000, 720.000), Vector2(784.489, 495.666), Vector2(288.977, 271.333), Vector2(335.460, 802.636), Vector2(1233.517, 188.696), Vector2(-5061.061, -3222.343), Vector2(-1890.530, -1251.171), Vector2(-1693.070, -626.002), Vector2(-4666.140, -1972.004)]
    var to_world_actor_coords: Array[Vector2] = [Vector2(1280.000, 720.000), Vector2(784.489, 495.666), Vector2(288.977, 271.333), Vector2(335.460, 802.636), Vector2(1233.517, 188.696), Vector2(-5061.061, -3222.343), Vector2(-1890.530, -1251.171), Vector2(-1693.070, -626.002), Vector2(-4666.140, -1972.004)]
    var to_world_viewport_coords: Array[Vector2] = [Vector2(1054.256, 171.769), Vector2(783.610, 198.508), Vector2(512.964, 225.246), Vector2(665.917, 443.687), Vector2(901.303, -46.671), Vector2(-2677.089, 49.950), Vector2(-811.417, 110.860), Vector2(-569.621, 332.201), Vector2(-2193.499, 492.632)]
    var to_texture_coords: Array[Vector2] = [Vector2(-414.256, 188.231), Vector2(-143.610, 161.492), Vector2(127.036, 134.754), Vector2(-25.918, -83.687), Vector2(-261.303, 406.671), Vector2(3317.089, 310.050), Vector2(1451.417, 249.140), Vector2(1209.621, 27.799), Vector2(2833.499, -132.632)]
    var to_ui_coords: Array[Vector2] = [Vector2(-28.359, -32.287), Vector2(107.024, 34.794), Vector2(242.408, 101.874), Vector2(234.655, -46.071), Vector2(-20.606, 115.658), Vector2(1693.756, 1123.613), Vector2(832.698, 545.663), Vector2(783.942, 370.197), Vector2(1596.243, 772.680)]
    var to_ui_canvas_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(123.878, 56.083), Vector2(247.756, 112.167), Vector2(236.135, -20.659), Vector2(11.621, 132.826), Vector2(1585.265, 985.586), Vector2(792.633, 492.793), Vector2(743.267, 336.500), Vector2(1486.535, 673.001)]
    var to_main_viewport_coords: Array[Vector2] = [Vector2(0.000, 0.000), Vector2(106.667, 60.000), Vector2(213.333, 120.000), Vector2(213.333, 0.000), Vector2(0.000, 120.000), Vector2(1344.000, 1008.000), Vector2(672.000, 504.000), Vector2(640.000, 360.000), Vector2(1280.000, 720.000)]

    for i in from.size():
        const from_type := Enums.CoordsType.Screen
        assert_almost_eq(ui.transform_to_world_coords(from_type, from[i]), to_world_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_actor_coords(from_type, from[i]), to_world_actor_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_world_viewport_coords(from_type, from[i]), to_world_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_texture_coords(from_type, from[i]), to_texture_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_coords(from_type, from[i]), to_ui_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_ui_canvas_coords(from_type, from[i]), to_ui_canvas_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_main_coords(from_type, from[i]), to_main_viewport_coords[i], error_margin)
        assert_almost_eq(ui.transform_to_screen_coords(from_type, from[i]), from[i], error_margin)  # to self
