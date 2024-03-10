# DraggableSprite2D
A simple Sprite2D which can be dragged with the mouse by clicking and holding with a mouse button.

## Usage
To use, just add a texture and ignore the warning in the editor. A collision shape is automatically generated on _ready.

You can also use a custom collision shape by adding it as a child.

All code is commented to explain the export values, but for reference:
- **input_method**: The mouse button to listen for to grab the sprite.
- **texture**: The Sprite2D texture. This updates live in the editor, as long as you swap editor tabs after changing it.
- **return_to_origin**: Whether the sprite should return to it's starting point once released.
- **grabbable**: Whether the sprite can be grabbed.
- **origin**: The position to return to when released, if return_to_origin is true. Note that this is set to the sprite's starting position on `_ready`, so it should only be updated at runtime and not set in the editor.
