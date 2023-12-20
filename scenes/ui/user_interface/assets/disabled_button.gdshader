shader_type canvas_item;

uniform vec3 off_color : source_color;

void fragment() {
	COLOR.rgb = off_color;
}
