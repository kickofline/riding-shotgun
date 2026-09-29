extends Node2D
signal hit
signal health_changed(value: int)
signal died

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var max_health := 3
@export var bullet_scene: PackedScene
@export var fire_rate := 0.15 # Minimum seconds between shots; each click fires one shot.
@export var invincibility_time := 0.6 # Seconds of immunity + flash after a hit.
var health := max_health
var is_invincible := false
var screen_size # Size of the game window.
var _fire_cooldown := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x*2.5 / 3, screen_size.y / 2)
	health_changed.emit(health)

func take_damage(amount := 1) -> void:
	if health <= 0 or is_invincible:
		return
	health = max(health - amount, 0)
	hit.emit()
	health_changed.emit(health)
	_flash_damage()
	if health <= 0:
		died.emit()
	else:
		_start_invincibility()

func _shoot() -> void:
	var muzzle: Marker2D = $Muzzle
	var dir := (get_global_mouse_position() - muzzle.global_position).normalized()
	# Never fire backward (away from the dragon): keep the aim in the left half-plane.
	if dir.x > -0.1:
		dir = Vector2(-0.1, signf(dir.y) if dir.y != 0.0 else 0.0).normalized()
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.launch(muzzle.global_position, dir)

func _start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false

func _flash_damage() -> void:
	var sprite = $AnimatedSprite2D
	sprite.modulate = Color(1, 0.2, 0.2, 1)
	create_tween().tween_property(sprite, "modulate", Color(1, 1, 1, 1), invincibility_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stop()
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	_fire_cooldown -= delta
	if Input.is_action_just_pressed("shoot") and _fire_cooldown <= 0.0:
		_shoot()
		_fire_cooldown = fire_rate
