extends Control
class_name HandUI

signal active_slot_changed

@onready var card_row: HBoxContainer = $CardRow

var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat
var style_pressed: StyleBoxFlat
var style_active: StyleBoxFlat

var hand: Array[CardAction] = []
var active_card_index: int = 0

func _ready() -> void:
	_create_styles()

func set_hand(cards: Array[CardAction]) -> void:
	hand = cards.duplicate()
	if hand.is_empty():
		active_card_index = -1
	else:
		active_card_index = 0
	_print_hand()
	_refresh_card_ui()
	
func get_active_card() -> CardAction:
	if active_card_index < 0 or active_card_index >= hand.size():
		return null
	return hand[active_card_index]
	
func select_slot(index: int) -> void:
	if index < 0 or index >= hand.size():
		print("No card in slot ", index)
		return
	active_card_index = index
	_print_hand()
	_refresh_card_ui()
	active_slot_changed.emit()
	
func handle_number_key(keycode: int) -> void:
	match keycode:
		KEY_1:
			select_slot(0)
		KEY_2:
			select_slot(1)
		KEY_3:
			select_slot(2)
		_:
			pass

func _create_styles() -> void:
	style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.13, 0.13, 0.13)
	style_normal.border_color = Color(0.25, 0.25, 0.25)
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(4)
	style_normal.set_content_margin_all(6)

	style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.18, 0.18, 0.18)

	style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.10, 0.10, 0.10)

	style_active = style_normal.duplicate()
	style_active.bg_color = Color(0.28, 0.38, 0.55)

func _clear_card_row() -> void:
	for child in card_row.get_children():
		child.queue_free()

func _highlight_active_card() -> void:
	for i in range(card_row.get_children().size()):
		var btn = card_row.get_child(i)
		if i == active_card_index:
			btn.add_theme_stylebox_override("normal", style_active)
			btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			btn.add_theme_stylebox_override("normal", style_normal)
			btn.remove_theme_color_override("font_color")

func _refresh_card_ui() -> void:
	_clear_card_row()
	
	for i in range(hand.size()):
		var card: CardAction = hand[i]
		var button := Button.new()
		
		button.add_theme_stylebox_override("normal", style_normal)
		button.add_theme_stylebox_override("hover", style_hover)
		button.add_theme_stylebox_override("pressed", style_pressed)

		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_constant_override("hseparation", 10)

		# Sizing hints
		button.custom_minimum_size = Vector2(130, 60)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.text = "%d: %s (%d)" % [i + 1, card.name, card.cost]
		# Tooltip shows what the card does
		button.tooltip_text = card.description
		button.disabled = false
		
		# Highlight active card
		if i == active_card_index:
			# Use the active style for all states
			button.add_theme_stylebox_override("normal", style_active)
			button.add_theme_stylebox_override("hover", style_active)
			button.add_theme_stylebox_override("pressed", style_active)
			button.add_theme_color_override("font_color", Color.WHITE)
		else:
			# Use normal set for non-active cards
			button.add_theme_stylebox_override("normal", style_normal)
			button.add_theme_stylebox_override("hover", style_hover)
			button.add_theme_stylebox_override("pressed", style_pressed)
			button.remove_theme_color_override("font_color")
			
		var idx := i
		button.pressed.connect(
			func():
				select_slot(idx)
		)
		
		card_row.add_child(button)
		
func _print_hand() -> void:
	print("--- Hand ---")
	for i in range(hand.size()):
		var card := hand[i]
		var marker := " "
		if i == active_card_index:
			marker = ">"
		print(marker, "Slot ", i, " - ", card.name)
