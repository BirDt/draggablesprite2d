@tool
class_name DraggableSprite2D extends Area2D
## A draggable sprite that can be dragged using the left mouse button.


## Emitted when the sprite is grabbed
signal grabbed
## Emitted when the sprite is released
signal released


## Whether or not it should be possible to grab the sprite
@export var grabbable := true
## The input button that will be used to grab the sprite
@export var input_method: MouseButton = MOUSE_BUTTON_LEFT
## The texture that will be displayed by the sprite. [br]
## Note: The texture can't be rezised as nicley as a Sprite2D.
@export var texture : Texture2D : 
	set(value):
		texture = value
		sprite.texture = texture
		# Update the default_collider with the shape and size of the sprite, if it exists
		update_default_collider()
## Whether or not the sprite should return to it's starting position when released
@export var return_to_origin := false
## The position the sprite will return to when released
@export var origin := Vector2.ZERO


## The Sprite node that will be used to display the texture
var sprite := Sprite2D.new()
## The default collider. It is automatically created and updated to match the size of the sprite
var default_collider : CollisionShape2D
## Whether or not the sprite is currently grabbed
var is_grabbed := false :
	set(value):
		is_grabbed = value
		if is_grabbed:
			grabbed.emit()
		else:
			released.emit()


# Helps a bit to make the dragging less choppy
var grabbed_offset := Vector2.ZERO
# Mouse button pressed tracker, used to essentially replicate the behavior of 'is_action_just_released'
var mb_pressed = false


func _ready() -> void:
	# Connect signals
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	input_event.connect(_on_input_event)

	add_child(sprite)

	default_collider = CollisionShape2D.new()
	default_collider.shape = RectangleShape2D.new()

	update_default_collider()
	
	add_child(default_collider)
	if has_custom_collider():
		toggle_default_collider(false)
	
	# Set the starting origin if necessary
	if return_to_origin:
		origin = position


func _process(delta) -> void:
	# If the input_method is down and the object is and can be grabbed, update it's position
	if Input.is_mouse_button_pressed(input_method) and is_grabbed and grabbable:
		position = get_global_mouse_position() + grabbed_offset
		mb_pressed = true
	# Otherwise, if the mouse button was pressed on the previous frame but now isn't, the object is released
	if not Input.is_mouse_button_pressed(input_method) and mb_pressed:
		if return_to_origin:
			position = origin
		mb_pressed = false


## Returns true if the sprite has a custom collider
func has_custom_collider() -> bool:
	var children = get_children()
	children.erase(default_collider)
	for child in children:
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return true
	
	return false


## Shortcut to toggle on or off the default collider functionality
func toggle_default_collider(on: bool) -> void:
	default_collider.visible = on
	default_collider.disabled = not on


## Updates the default collider to match the size of the sprite
func update_default_collider() -> void:
		if default_collider and default_collider.shape:
			if not texture:
				default_collider.shape.size = Vector2(0, 0)
				return
			default_collider.shape.size = Vector2(texture.get_width(), texture.get_height())


func _on_input_event(viewport, event, shape_idx) -> void:
	# Detect when mouse button is clicked inside the area2d
	if event is InputEventMouseButton and grabbable:
		is_grabbed = event.is_pressed()
		# Helps a bit to make the dragging less choppy
		grabbed_offset = position - get_global_mouse_position()

func _on_child_entered_tree(child) -> void:
	if (child is CollisionShape2D or child is CollisionPolygon2D) and child != default_collider:
		toggle_default_collider(false)


func _on_child_exiting_tree(child) -> void:
	if (child is CollisionShape2D or child is CollisionPolygon2D) and child != default_collider:
		toggle_default_collider(true)
