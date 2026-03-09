class_name World extends Node2D

@export var current_actor: Sprite2D
@export var actors: Array[Sprite2D]

@onready var king: Sprite2D = $KingPath2D/PathFollow2D/King
@onready var king_path_follow: PathFollow2D = $KingPath2D/PathFollow2D
@onready var priest: Sprite2D = $PriestPath2D/PathFollow2D/Priest
@onready var priest_path_follow: PathFollow2D = $PriestPath2D/PathFollow2D

@onready var world_actor_camera: CustomCamera = $KingPath2D/PathFollow2D/King/WorldActorCamera
@onready var world_camera: CustomCamera = $WorldCamera

var king_speed := 0.1
var priest_speed := 1.0


func _process(delta: float) -> void:
    king_path_follow.progress_ratio += delta * king_speed
    priest_path_follow.progress += priest_speed

    queue_redraw()


func _draw() -> void:
    var rect := ($Background as Sprite2D).get_rect()
    DebugDraw.draw_axes(self , rect, "world center: %s" % [Format.format_position(rect.get_center(), Enums.CoordsType.World, true)], Color.WHEAT, Color.BLACK)


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
    world_actor_camera.position = Vector2.ZERO
    world_actor_camera.offset = Vector2.ZERO
