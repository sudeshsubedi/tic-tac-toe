extends Node2D

enum turns{TICK, CIRCLE}
enum game_state{MENU, PLAY}

var state = game_state.MENU
var turn = turns.TICK

var times_played = 0
var board = []
var occupied_array = []
var minmax_board = []

func _setup_board():
	board.clear()
	minmax_board.clear()
	occupied_array.clear()
	for i in range(8):
		occupied_array.append([])
	var cell = "Grid/cell"
	var ith_name = ["Top", "Center", "Down"]
	var jth_name = ["Left", "Center", "Right"]	
	for i in range(3):
		board.append([])
		minmax_board.append([])
		for j in range(3):
			minmax_board[i].append(0)
			board[i].append(get_node("Grid/Cell{ith}{jth}".format({"ith":ith_name[i], "jth":jth_name[j]})))


func _input(event):
	if state == game_state.PLAY:
		if Input.is_action_just_pressed("cell_clicked"):
			_handle_turn(event.position)
			var optimal_solution = best_move(minmax_board)
			simulate_minmax_click(optimal_solution[0], optimal_solution[1])
	
	
	
func _handle_turn(pos:Vector2) -> void:
	var i = floor(pos.x/133)
	var j = floor(pos.y/133)
	var current_cell = board[j][i]
	if current_cell.is_occupied:
		return
	if turn == turns.TICK:
		current_cell.is_tick = true
		current_cell.is_occupied = true
		times_played += 1
		minmax_board[j][i] = -1
		_manage_tick(i, j)
		turn = turns.CIRCLE
	elif turn == turns.CIRCLE:
		current_cell.is_occupied = true
		current_cell.is_circle = true
		times_played += 1
		minmax_board[j][i] = 1
		_manage_tick(i, j)
		turn = turns.TICK
	current_cell.display()
	if times_played >= 5:
		_check_game_finished(i, j)

func _manage_tick(i, j):
	occupied_array[j].append(turn)
	occupied_array[i+3].append(turn)
	if i==j:
		occupied_array[6].append(turn)
	if i+j == 2:
		occupied_array[7].append(turn)

func _check_game_finished(i, j):
	for i in occupied_array:
		if i.size() <3:
			continue
		var sum = 0
		for elem in i:
			sum += elem
		if sum == 0:
			$EndScreen/Message.text = "Tick has won"
			state = game_state.MENU
			for a in range(3):
				for b in range(3):
					board[a][b].setup()
			$EndScreen.show()
			return
		if sum/i.size() == 1:
			$EndScreen/Message.text = "Circle has won"
			state = game_state.MENU
			for a in range(3):
				for b in range(3):
					board[a][b].setup()
			$EndScreen.show()
			return
	if times_played>=9:
		$EndScreen/Message.text = "Draw"
		state = game_state.MENU
		for i in range(3):
			for j in range(3):
				board[i][j].setup()
		$EndScreen.show()

func _on_ExitButton_pressed():
	get_tree().quit()


func _on_StartButton_pressed():
	_setup_board()
	state = game_state.PLAY
	$StartScreen.queue_free()


func _on_PlayAgainButton_pressed():
	_restart_game()
	
func _restart_game():
	_setup_board()
	turn = turns.TICK
	times_played = 0
	$EndScreen.hide()
	state = game_state.PLAY
	
	
func simulate_minmax_click(i, j):
	var cell = board[i][j]
	board[i][j].is_occupied = true
	cell.is_circle = true
	cell.display()
	times_played +=1
	_manage_tick(i, j)
	turn = turns.TICK
	minmax_board[i][j] = 1
	if times_played >= 5:
		_check_game_finished(i, j)
		



func game_finished(board):
	for i in range(3):
		for j in range(3):
			if board[i][j] == 0:
				return false
	return true

func eval(board):
	for row in board:
		var sum = row[0]+row[1]+row[2]
		if sum == -3:
			return -10
		elif sum == 3:
			return 10
	for col in range(3):
		if board[0][col] == board[1][col] and board[1][col] == board[2][col]:
			if board[0][col] == -1:
				return -10
			elif board[0][col] == 1:
				return 10

	if board[0][0] == board[1][1] and board[1][1] == board[2][2]:
		if board[0][0] == -1:
			return -10
		elif board[0][0] == 1:
			return 10

	if board[0][2] == board[1][1] and board[1][1] == board[2][0]:
		if board[0][2] == -1:
			return -10
		elif board[0][2] == 1:
			return 10
	return 0


func  minimax(board, depth, isMax):
	var score = eval(board)

	if score == -10:
		return score+depth
	elif score == 10:
		return score-depth

	if game_finished(board):
		return 0

	if isMax:
		var best = -1000

		for i in range(3):
			for j in range(3):

				if board[i][j] == 0:
					board[i][j] = 1
					best = max(best, minimax(board, depth+1, not isMax))
					board[i][j] = 0
		return best
	else:
		var best = 1000

		for i in range(3):
			for j in range(3):

				if board[i][j] == 0:
					board[i][j] = -1
					best = min(best, minimax(board, depth+1, not isMax))
					board[i][j] = 0
		return best


func best_move(board):
	var bestScore = -1000
	var bestMove = [-1, -1]

	for i in range(3):
		for j in range(3):
			if board[i][j] == 0:
				board[i][j] = 1
				var moveScore = minimax(board, 0, false)
				board[i][j] = 0

				if moveScore > bestScore:
					bestScore = moveScore
					bestMove = [i, j]
	return bestMove
