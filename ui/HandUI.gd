extends Control
class_name HandUI

@onready var card_row: HBoxContainer = $CardRow

var hand: Array[CardAction] = []
var active_card_index: int = 0

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
			
func _clear_card_row() -> void:
	for child in card_row.get_children():
		child.queue_free()
		
func _refresh_card_ui() -> void:
	_clear_card_row()
	
	for i in range(hand.size()):
		var card: CardAction = hand[i]
		var button := Button.new()
		button.text = "%d: %s" % [i + 1, card.name]
		
		# Highlight active card
		if i == active_card_index:
			button.add_theme_color_override("font_color", Color(1,1,0))
			button.add_theme_color_override("font_color_hover", Color(1,1,0))
		else:
			button.add_theme_color_override("font_color", Color(1,1,1))
			
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
