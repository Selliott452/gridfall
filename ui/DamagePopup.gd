extends Node2D
class_name DamagePopup

@onready var label: Label = $Label
var settings: LabelSettings

func _ready() -> void:
	settings = LabelSettings.new()

	settings.font_size = 24                       
	settings.font_color = Color.WHITE             
	settings.outline_size = 4                     
	settings.outline_color = Color.WHITE          

	label.label_settings = settings

func show_value(amount: int, is_heal: bool = false) -> void:
	label.text = str(amount)

	settings.font_color = Color(0.3, 1.0, 0.3) if is_heal else Color(1.0, 0.4, 0.2)

	modulate = Color(1, 1, 1, 1)
	scale = Vector2.ONE * 1.2

	var x_drift := randf_range(-8.0, 8.0)          # sideways drift
	var y_lift := randf_range(20.0, 32.0)          # how high the popup floats
	var duration := randf_range(0.35, 0.45)        # float time variation
	var start_rot := randf_range(-0.12, 0.12)      # small tilt

	rotation = start_rot

	var tween := create_tween()

	tween.tween_property(self, "position", position + Vector2(x_drift, -y_lift), duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, duration)
	tween.parallel().tween_property(self, "rotation", 0.0, duration)

	tween.finished.connect(queue_free)
