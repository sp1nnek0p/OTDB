extends CanvasLayer

onready var question_textbox = get_node("Question")
onready var opt1 = get_node("opt1")
onready var opt2 = get_node("opt2")
onready var opt3 = get_node("opt3")
onready var opt4 = get_node("opt4")
onready var display_score = get_node("DisplayScore")
onready var popup_dialog = get_node("ConfirmationDialog")
onready var category = get_node("Category")
onready var difficulty = get_node("Difficulty")

var question_bank = []
var number = 0
var score_val = 0


func _ready():
	# Get 10 questions from the OpenTDB on Startup
	$HTTPRequest.request("https://opentdb.com/api.php?amount=10&type=multiple")
	pass # Replace with function body.


func next_question():

	if number < 10:
		display_score.text = 'Score : ' + str(score_val)
		category.text = 'Category : ' + question_bank[number][3]
		difficulty.text = 'Difficulty : ' + question_bank[number][4].capitalize()
		question_textbox.text = question_bank[number][0]
		opt1.text = question_bank[number][1][0]
		opt2.text = question_bank[number][1][1]
		opt3.text = question_bank[number][1][2]
		opt4.text = question_bank[number][1][3]
	else:
		question_textbox.text = 'You Got! ' + str(score_val) + '/100'
		popup_dialog.dialog_text = 'You final score is! ' + str(score_val) + '/100'
		popup_dialog.popup()


func check_answers(obj):
	# Check answers to keep the code DRY
	if obj.text == question_bank[number][2]:
		popup_dialog.dialog_text = "That was correct! it was infact : " + question_bank[number][2] 
		popup_dialog.popup()
		score_val += 10
		number += 1
		next_question()
	else:
		popup_dialog.dialog_text = "That was incorrect! the correct answer is : " + question_bank[number][2] 
		popup_dialog.popup()
		number += 1
		next_question()


func shuffle_list(list):
	# Shuffle the answers so they are never in the same order
	# Because I append the correct answer to the list for output
	var shuffled_list = []
	var index_list = range(list.size())
	for i in range(list.size()):
		randomize()
		var x = randi()%index_list.size()
		shuffled_list.append(list[x])
		index_list.remove(x)
		list.remove(x)
	return shuffled_list


# func _on_Button_pressed():
# 	# Get 10 questions from the OpenTDB
# 	$HTTPRequest.request("https://opentdb.com/api.php?amount=10&type=multiple")
	


func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	# Parse JSON data from the API call
	var json = JSON.parse(body.get_string_from_utf8())
	var json_data = json.result
	
	for result in json_data.results:
		# print(sanitize(result.question))
		var answers = []
		answers.append(result.correct_answer.xml_unescape())
		for answer in result.incorrect_answers:
			answers.append(answer.xml_unescape())
		var question = []
		question.append(result.question.xml_unescape())
		question.append(shuffle_list(answers))
		question.append(result.correct_answer.xml_unescape())
		question.append(result.category)
		question.append(result.difficulty)
		question_bank.append(question)
		next_question()


func _on_opt1_pressed():
	check_answers(opt1)


func _on_opt2_pressed():
	check_answers(opt2)


func _on_opt3_pressed():
	check_answers(opt3)


func _on_opt4_pressed():
	check_answers(opt4)

