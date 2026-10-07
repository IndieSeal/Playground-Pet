extends Node2D

var baseSpeed = 300
var speed = baseSpeed

var direction = Vector2(1, 0.2)

var screenSize = Vector2()
var windowSize = Vector2(200, 200)

## Idling
var idleMinTime = 1.0;
var idleMaxTime = 3.0;

var idleTimer = 0;
var isIdling = false;

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

var isDragging = false
var dragOffset = Vector2()

func _ready() -> void:
	screenSize = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("Walk")
	area.input_event.connect(on_area_input)

func _physics_process (delta: float) -> void:
	if isDragging:
		var mousePos = Vector2(DisplayServer.mouse_get_position())
		var newWindowPos = mousePos - dragOffset
		DisplayServer.window_set_position(Vector2i(newWindowPos))
		return
	
	if isIdling:
		idleTimer -= delta
		if idleTimer <= 0:
			isIdling = false
			speed = baseSpeed
			animated_sprite.play("Walk")
		else:
			return
	
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	DisplayServer.window_set_position (Vector2i (window_position))
	
	if window_position.x <= 0 or window_position.x >= screenSize.x - windowSize.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		try_idle()
	if window_position.y <= 0 or window_position.y >= screenSize.y - windowSize.y:
		direction.y *= -1
		try_idle()

func try_idle():
	if isIdling:
		return
	
	if randf() < 0.4:
		isIdling = true
		idleTimer = randf_range(idleMinTime, idleMaxTime)
		animated_sprite.play("Idle")
		speed = 0

func on_area_input(viewport, event, shapeIDX):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			isDragging = true
			var mousePos = Vector2(DisplayServer.mouse_get_position())
			var windowPos = Vector2(DisplayServer.window_get_position())
			dragOffset = mousePos - windowPos
		else:
			isDragging = false
			
