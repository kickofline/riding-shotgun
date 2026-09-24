extends Area2D

const HITBOX_PER_SIZE := 48.0 # CollisionShape2D size (px) per 1.0 of `size` at scale 1.0.

@export var speed = 250
@export var damage := 1
@export var size := 0.75 # Uniform scale applied to the sprite and its hitbox.

var direction := Vector2.DOWN
var wave_amplitude := 0.0   # 0 = straight line; >0 = sideways wobble in pixels.
var wave_frequency := 6.0   # Radians/sec the wobble oscillates at.

var _origin := Vector2.ZERO
var _elapsed := 0.0


func launch(from: Vector2, dir: Vector2, amplitude := 0.0, frequency := 6.0) -> void:
	global_position = from
	_origin = from
	direction = dir.normalized()
	wave_amplitude = amplitude
	wave_frequency = frequency
	#
	rotation = direction.angle()

func _ready() -> void:
	$AnimatedSprite2D.scale = Vector2.ONE * size
	var shape := $CollisionShape2D.shape as RectangleShape2D
	if shape:
		shape = shape.duplicate()
		shape.size = Vector2.ONE * size * HITBOX_PER_SIZE
		$CollisionShape2D.shape = shape

func _process(delta: float) -> void:
	_elapsed += delta
	var travel = direction * speed * _elapsed
	if wave_amplitude != 0.0:
	
		var sideways = direction.orthogonal()
		travel += sideways * sin(_elapsed * wave_frequency) * wave_amplitude
	position = _origin + travel

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
