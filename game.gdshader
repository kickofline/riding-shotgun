shader_type canvas_item;

// Scroll position (0..1 of the texture width), advanced by road.gd so it stops when the tree is paused.
uniform float scroll = 0.0;

void fragment() {
	vec2 uv = UV;
	uv.x += scroll;
	uv.x = fract(uv.x);
    COLOR = texture(TEXTURE, uv);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
