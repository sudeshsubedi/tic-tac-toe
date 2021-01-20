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
			var optimal_solution = optimal_move()
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
		if sum == 3:
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
		

func optimal_move():
	var best = -1000
	var a
	var b
	
	for i in range(3):
		for j in range(3):
			if minmax_board[i][j] == 0:
				minmax_board[i][j] = 1
				var move_score = minmax(0, true)
				minmax_board[i][j] = 0
				print([move_score, i, j])
				if move_score > best:
					best = move_score
					a = i
					b = j
	print(a, b)
	return [a, b]

func minmax(depth, isMax):
	var score = evaluation_function()
	print(depth, " iteration scpre value: ", score)
	if score == -10:
		return score#+depth
	if score == 10:
		return score#-depth
	if times_played >= 9:
		return 0
	if isMax:
		var max_best = -1000
		for i in range(3):
			for j in range(3):
				if minmax_board[i][j] == 0:
					minmax_board[i][j] = 1
					max_best = max(max_best, minmax(depth+1, false))
					print("max_best: ", max_best)
					minmax_board[i][j] = 0
		return max_best
	else:
		var min_best = 1000
		for i in range(3):
			for j in range(3):
				if minmax_board[i][j] == 0:
					minmax_board[i][j] = -1
					var temp = minmax(depth+1, true)
					print("max from min: ", temp)
					min_best = min(min_best, temp)
					print("best from min = ", min_best)
					minmax_board[i][j] = 0
		return min_best

func evaluation_function() -> int:
	for row in range(3):
		if minmax_board[row][0] == minmax_board[row][1] and minmax_board[row][1] == minmax_board[row][2]:
			if minmax_board[row][0] == -1:
				return -10
			elif minmax_board[row][0] == 1:
				return 10
	for col in range(3):
		if minmax_board[0][col] == minmax_board[1][col] and minmax_board[1][col] == minmax_board[2][col]:
			if minmax_board[0][col] == -1:
				return -10
			elif minmax_board[0][col] == 1:
				return 10
	if minmax_board[0][0] == minmax_board[1][1] and minmax_board[1][1] == minmax_board[2][2]:
		if minmax_board[0][0] == -1:
			return -10
		elif minmax_board[0][0] == 1:
			return 10
	
	if minmax_board[0][2] == minmax_board[1][1] and minmax_board[1][1] == minmax_board[2][0]:
		if minmax_board[0][2] == -1:
			return -10
		elif minmax_board[0][0] == 1:
			return 10
	return 0
	
