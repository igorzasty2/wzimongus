extends Control

# Przesuwa scroll na szczyt listy twórców
func _on_visibility_changed():
	$RichTextLabel.get_v_scroll_bar().ratio = 0
