extends Node
class_name TurnManager

enum TurnState { PLAYER, ENEMY }

@export var max_stamina: int = 3
var current_stamina: int = 0

var current_turn: TurnState = TurnState.PLAYER
var player_action_used: bool = false

var board: Board

func _ready() -> void:
	board = get_parent() as Board
	
func start_player_turn() -> void:
	current_turn = TurnState.PLAYER
	current_stamina = max_stamina
	board.hud.set_end_turn_enabled(true)
	board.hud.update(board.player, board.enemy, current_turn, current_stamina, max_stamina)
	board.update_tile_highlighting()
	
func end_player_turn() -> void:
	current_turn = TurnState.ENEMY
	board.hud.set_end_turn_enabled(false)
	board.hud.update(board.player, board.enemy, current_turn, current_stamina, max_stamina)
	board.grid.clear_highlight_cells()
	enemy_take_turn()
	
func enemy_take_turn() -> void:
	if board.enemy == null or not is_instance_valid(board.enemy) or not board.enemy.is_inside_tree():
		start_player_turn()
		return
		
	board.enemy.take_turn(board)
	
	start_player_turn()
	
