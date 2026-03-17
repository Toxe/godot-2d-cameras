class_name World extends Node2D

@export var current_actor: Sprite2D
@export var actors: Array[Sprite2D]

@onready var helo: Sprite2D = $Helo
@onready var plane: Sprite2D = $Plane
@onready var king: Sprite2D = $KingPath2D/PathFollow2D/King
@onready var king_path_follow: PathFollow2D = $KingPath2D/PathFollow2D
@onready var priest: Sprite2D = $PriestPath2D/PathFollow2D/Priest
@onready var priest_path_follow: PathFollow2D = $PriestPath2D/PathFollow2D

@onready var world_actor_camera: CustomCamera = $KingPath2D/PathFollow2D/King/WorldActorCamera
@onready var world_camera: CustomCamera = $WorldCamera

var king_speed := 0.1
var priest_speed := 1.0


func _ready() -> void:
    var tween := create_tween()
    tween.tween_property(plane, "scale", Vector2(2.0, 2.0), 3.0).set_trans(Tween.TransitionType.TRANS_SINE)
    tween.tween_property(plane, "scale", Vector2(0.75, 0.75), 3.0).set_trans(Tween.TransitionType.TRANS_SINE)
    tween.set_loops()


func _process(delta: float) -> void:
    var movement := Input.get_vector("move_actor_left", "move_actor_right", "move_actor_up", "move_actor_down")
    var movement_speed := 0.1 if Input.is_physical_key_pressed(Key.KEY_SHIFT) else 1.0

    handle_helo_movement(movement, movement_speed, delta)
    handle_plane_movement(movement, movement_speed, delta)

    king_path_follow.progress_ratio += delta * king_speed
    priest_path_follow.progress += priest_speed

    queue_redraw()


func _draw() -> void:
    var rect := ($Background as Sprite2D).get_rect()
    DebugDraw.draw_axes(self , rect, "world center: %s" % [Format.format_position(rect.get_center(), Enums.CoordsType.World, true)], Color.WHEAT, Color.BLACK)


func handle_helo_movement(movement: Vector2, movement_speed: float, delta: float) -> void:
    if current_actor == helo && !movement.is_zero_approx():
        helo.position += 100.0 * delta * movement * movement_speed

        if movement.x > 0.5 && !helo.flip_h:
            helo.flip_h = true
        elif movement.x < -0.5 && helo.flip_h:
            helo.flip_h = false


func handle_plane_movement(movement: Vector2, movement_speed: float, delta: float) -> void:
    if current_actor == plane && !movement.is_zero_approx():
        plane.position.y += 100.0 * delta * movement.y * movement_speed

        if movement.x > 0.5 && !plane.flip_h:
            plane.flip_h = true
        elif movement.x < -0.5 && plane.flip_h:
            plane.flip_h = false

    if plane.flip_h:
        plane.position.x += 200.0 * delta
    else:
        plane.position.x -= 200.0 * delta
    plane.position.x = wrapf(plane.position.x, 0, 4032)


func next_actor() -> void:
    var next_index := wrapi(_get_actor_camera_index() + 1, 0, actors.size())
    _switch_to_actor(next_index)


func previous_actor() -> void:
    var previous_index := wrapi(_get_actor_camera_index() - 1, 0, actors.size())
    _switch_to_actor(previous_index)


func _get_actor_camera_index() -> int:
    return actors.find(current_actor)


func _switch_to_actor(index: int) -> void:
    assert(index >= 0 && index < actors.size())
    current_actor = actors[index]
    world_actor_camera.get_parent().remove_child(world_actor_camera)
    current_actor.add_child(world_actor_camera)
    world_actor_camera.recenter_camera()
