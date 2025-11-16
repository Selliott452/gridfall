extends Node
class_name CardSystem

signal active_card_changed(card: CardAction)

var board: Board
@onready var hand_ui: HandUI = $"../UI/RootUI/CardBar"

func _ready() -> void:
	board = get_parent() as Board
	hand_ui = $"../UI/RootUI/CardBar"
	if hand_ui != null:
		hand_ui.active_slot_changed.connect(_on_hand_active_slot_changed)
	
func _on_hand_active_slot_changed() -> void:
	active_card_changed.emit(get_active_card())
	
func set_starting_hand(cards: Array[CardAction]) -> void:
	hand_ui.set_hand(cards)
	
func get_active_card() -> CardAction:
	return hand_ui.get_active_card()
	
func handle_number_key(keycode: int) -> void:
	hand_ui.handle_number_key(keycode)
