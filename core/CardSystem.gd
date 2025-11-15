extends Node
class_name CardSystem

var board: Board
@onready var hand_ui: HandUI = $"../UI/RootUI/CardBar"

func _ready() -> void:
	board = get_parent() as Board
	
func set_starting_hand(cards: Array[CardAction]) -> void:
	hand_ui.set_hand(cards)
	
func get_active_card() -> CardAction:
	return hand_ui.get_active_card()
	
func handle_number_key(keycode: int) -> void:
	hand_ui.handle_number_key(keycode)
