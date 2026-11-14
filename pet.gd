extends Node2D

var speed = 150
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200,200)
var idle_or_not
var idle_time
var is_idle = false
var is_dragging = false
var drag_offset = Vector2()

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var window_position = Vector2(DisplayServer.window_get_position())

func _ready() -> void:
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walk")


func _physics_process(delta: float) -> void:
	
	if is_dragging == true:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		animated_sprite.play("default")
		return
		
	window_position = Vector2(DisplayServer.window_get_position())
	gravity()
	
	if is_idle == false:
		maybe_idle()
	elif is_idle == true:
		if $AnimatedSprite2D.animation != "love":
			idle_time -= 1 * delta 
			animated_sprite.play("idle")
			if idle_time <= 0:
				is_idle = false
				animated_sprite.play("walk")
			window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)   # add
			gravity()
			DisplayServer.window_set_position(Vector2i(window_position))     
			return
	
	window_position.x += direction.x * speed * delta
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		


func maybe_idle():
	idle_or_not = randi_range(1,1000)
	if idle_or_not >= 995:
		is_idle = true
		idle_time = randi_range(5,10)

func gravity():
	window_position.y += 3

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		$AnimatedSprite2D.play("love")
		await get_tree().create_timer(1).timeout
		$AnimatedSprite2D.play("default")
