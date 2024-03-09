@tool
extends Area2D

var sprite := Sprite2D.new()
var collider : CollisionShape2D

var is_grabbed := false :
	set(x):
		is_grabbed = x
		## Emit signal if currently grabbed or not
		if x:
			grabbed.emit()
		else:
			released.emit()
## Helps a bit to make the dragging less choppy
var grabbed_offset := Vector2.ZERO
## Store for the original position
var origin := Vector2.ZERO

signal grabbed
signal released

## Sprite texture
## This is a bit crap, since it can't be resized as nicely as a normal sprite2d
@export var texture : Texture2D : 
	set(x):
		texture = x
		sprite.texture = texture
		## Update the default collider with the shape and size of the sprite, if it exists
		if collider and collider.shape:
			collider.shape.size = Vector2(texture.get_width(), texture.get_height())
## Whether or not the sprite should return to it's starting position when released
@export var return_to_origin := false
## Whether or not it should be possible to grab the sprite
@export var grabbable := true

func _ready():
	## Check if we need to instantiate a collider 
	var children = get_children()
	var needs_collider = true
	for i in children:
		## If a collision shape is a child, we don't need a collider
		if i is CollisionShape2D or i is CollisionPolygon2D:
			needs_collider = false
	
	## Otherwise, create a new collider from the size and shape of the sprite
	if needs_collider:
		collider = CollisionShape2D.new()
		collider.shape = RectangleShape2D.new()
		collider.shape.size = Vector2(texture.get_width() if texture else 0, texture.get_height() if texture else 0)
		add_child(collider)
	
	## Set the starting origin if necessary
	if return_to_origin:
		origin = position
	
	add_child(sprite)
	input_event.connect(_on_input_event)

## Mouse button pressed tracker, used to essentially replicate the behavior of 'is_action_just_released'
var mb_pressed = false

func _process(delta):
	# If the left mouse button is down and the object is and can be grabbed, update it's position
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_grabbed and grabbable:
		position = get_global_mouse_position() + grabbed_offset
		mb_pressed = true
	# Otherwise, if the mouse button was pressed on the previous frame but now isn't, the object is released
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mb_pressed:
		if return_to_origin:
			position = origin
		mb_pressed = false

func _on_input_event(viewport, event, shape_idx):
	## Detect when mouse button is clicked inside the area2d
	if event is InputEventMouseButton and grabbable:
		is_grabbed = event.is_pressed()
		## Helps a bit to make the dragging less choppy
		grabbed_offset = position - get_global_mouse_position()
