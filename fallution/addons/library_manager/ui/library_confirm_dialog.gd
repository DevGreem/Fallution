@tool
class_name LibraryConfirmDialog
extends ConfirmationDialog


## Creates and shows a confirmation dialog. The dialog frees itself once it
## is confirmed or canceled, so callers only need to connect to its signals.
## Set `danger` to true for destructive actions (the OK button is tinted red).
static func open(
	parent: Node,
	title: String,
	text: String,
	ok_text: String,
	cancel_text: String = "Cancel",
	danger: bool = false
) -> LibraryConfirmDialog:
	var dialog := LibraryConfirmDialog.new()
	dialog.title = title
	dialog.dialog_text = text
	dialog.dialog_autowrap = true
	dialog.min_size = Vector2i(460, 0)
	dialog.ok_button_text = ok_text
	dialog.cancel_button_text = cancel_text
	parent.add_child(dialog)
	dialog._style(danger)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()
	return dialog


func _style(danger: bool) -> void:
	if Engine.is_editor_hint():
		var editor_theme: Theme = EditorInterface.get_editor_theme()
		var icon_name := "Warning" if danger else "Info"
		if editor_theme.has_icon(icon_name, "EditorIcons"):
			get_ok_button().icon = editor_theme.get_icon(icon_name, "EditorIcons")
	if not danger:
		return
	get_ok_button().add_theme_color_override("font_color", Color(0.95, 0.45, 0.45))
	get_ok_button().add_theme_color_override("font_hover_color", Color(1, 0.58, 0.58))
	get_ok_button().add_theme_color_override("font_pressed_color", Color(0.85, 0.35, 0.35))
	get_ok_button().add_theme_color_override("font_focus_color", Color(1, 0.58, 0.58))
