extends Node
class_name TurnManager

enum TurnState { PLAYER, ENEMY }

var current_turn: TurnState = TurnState.PLAYER
var player_action_used: bool = false

var board: Board

func _ready() -> void:
	board = get_parent() as Board
	
func start_player_turn() -> void:
	current_turn = TurnState.PLAYER
	player_action_used = false
	board.hud.update(board.player, board.enemy, current_turn)
	
func end_player_turn() -> void:
	current_turn = TurnState.ENEMY
	board.hud.update(board.player, board.enemy, current_turn)
	enemy_take_turn()
	
func enemy_take_turn() -> void:
	if board.enemy == null or not is_instance_valid(board.enemy) or not board.enemy.is_inside_tree():
		start_player_turn()
		return
		
	board.enemy.take_turn(board)
	
	start_player_turn()
	
