extends Area2D

@export var bullet_scene: PackedScene
@export var big_bullet_scene: PackedScene

@export var fire_rate := 1.0        # Seconds between shots within a pattern.
@export var pattern_duration := 3.0 # Seconds before switching to the next pattern.

@export_group("Spread")
@export var spread_count := 5
@export var spread_angle_deg := 40.0 # Total width of the fan.

@export_group("Radial")
@export var radial_count := 10

@export_group("Volley")
@export var volley_count := 3
@export var volley_delay := 0.15

@export_group("Wave")
@export var wave_amplitude := 60.0
@export var wave_frequency := 6.0

var screen_size # Size of the game window.

var patterns: Array[Callable] = []
var pattern_index := 0
var fire_timer := 0.0
var pattern_timer := 0.0

func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x / 6, screen_size.y / 2)
	patterns = [_fire_aimed, _fire_spread, _fire_radial, _fire_volley, _fire_wave, _fire_big]
	pattern_timer = pattern_duration

func _physics_process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0.0:
		patterns[pattern_index].call()
		fire_timer = fire_rate

	pattern_timer -= delta
	if pattern_timer <= 0.0:
		pattern_index = (pattern_index + 1) % patterns.size()
		pattern_timer = pattern_duration

# Bullet Patterns

func _fire_aimed() -> void:
	_spawn_bullet(_aim_direction())

func _fire_spread() -> void:
	var base_dir = Vector2.RIGHT
	var half_angle = deg_to_rad(spread_angle_deg) / 2.0
	for i in spread_count:
		var t = 0.5 if spread_count <= 1 else float(i) / float(spread_count - 1)
		var angle = lerp(-half_angle, half_angle, t)
		_spawn_bullet(base_dir.rotated(angle))

func _fire_radial() -> void:
	for i in radial_count:
		var angle = TAU * i / radial_count
		_spawn_bullet(Vector2.RIGHT.rotated(angle))

func _fire_volley() -> void:
	for i in volley_count:
		_spawn_bullet(_aim_direction())
		if i < volley_count - 1:
			await get_tree().create_timer(volley_delay).timeout

func _fire_wave() -> void:
	_spawn_bullet(Vector2.RIGHT, wave_amplitude, wave_frequency)

func _fire_big() -> void:
	_spawn_bullet(_aim_direction(), 0.0, 6.0, big_bullet_scene)

# Helpers
func _spawn_bullet(dir: Vector2, amplitude := 0.0, frequency := 6.0, scene: PackedScene = null) -> void:
	var bullet = (scene if scene else bullet_scene).instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.launch($Marker2D.global_position, dir, amplitude, frequency)

func _aim_direction() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	var target = player.global_position if player else global_position + Vector2.RIGHT
	return (target - global_position).normalized()
