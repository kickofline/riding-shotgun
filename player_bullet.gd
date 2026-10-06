extends Area2D

@export var speed := 1200.0
@export var damage := 1
@export var length := 28.0
@export var thickness := 6.0
@export var color := Color(1.0, 0.0, 0.0, 1.0)

var direction := Vector2.LEFT


func launch(from: Vector2, dir: Vector2) -> void:
	global_position = from
	direction = dir.normalized()
	rotation = direction.angle()

func _draw() -> void:
	# Tracer streak pointing along +X (the node is rotated to the fire direction).
	draw_rect(Rect2(-length, -thickness / 2.0, length, thickness), color)

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
