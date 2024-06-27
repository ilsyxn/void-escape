extends GridContainer

class_name Highscore

@export var sort_by := "score"
@export var name_column := "name"
@export var length := 1000
@export var file_name := "user://highscore.save"
@export var column_names := ["name", "score"]
@export var show_place_numbers := true
@export var max_shown_scores := 10

var highscore := []
var latest_name := ""

func _ready():
	_load()
	_update_highscore()

func get_minimum_score():
	if len(highscore) < length:
		return INF
	return highscore[-1][sort_by]

func add_entry(new_entry: Dictionary) -> int:
	latest_name = new_entry[name_column]
	var result = -1
	for i in range(len(highscore)):
		var entry = highscore[i]
		if new_entry[sort_by] < entry[sort_by]:
			highscore.insert(i, new_entry)
			result = i + 1
			break

	if result == -1 and len(highscore) < length:
		highscore.append(new_entry)
		result = len(highscore)

	if len(highscore) > length:
		highscore.pop_back()

	_update_highscore()
	_save()
	return result

func _create_label(text, ratio:=1.0) -> Label:
	var label = Label.new()
	label.text = str(text)
	label.theme_type_variation = "HighscoreLabel"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_stretch_ratio = ratio
	return label

func _update_highscore():
	for label in get_children():
		remove_child(label)
		label.queue_free()

	var place = 0
	for entry in highscore:
		place += 1
		if show_place_numbers:
			add_child(_create_label(str(place) + ".", 0.1))
		for col in column_names:
			add_child(_create_label(entry[col]))

func _load():
	if FileAccess.file_exists(file_name):
		var highscore_file = FileAccess.open(file_name, FileAccess.READ)
		var data = JSON.parse_string(highscore_file.get_as_text())
		highscore = data["list"]
		if "latest_name" in data:
			latest_name = data["latest_name"]

func _save():
	var highscore_file = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify({"list": highscore, "latest_name": latest_name})
	highscore_file.store_string(json_string)
	highscore_file.close()

func _update_shown_scores(level):
	var columns = len(column_names)
	if show_place_numbers:
		columns += 1

	for label in get_children():
		remove_child(label)
		label.queue_free()

	var place = 0
	var shown_scores = 0
	var latest_entry_index = -1

	# Find the index of the latest entry
	for i in range(len(highscore)):
		if highscore[i][name_column] == latest_name:
			latest_entry_index = i
			break

	var latest_entry_shown = false

	for i in range(len(highscore)):
		var entry = highscore[i]
		if entry["level_id"] == level:
			place += 1
			if shown_scores < max_shown_scores:
				if show_place_numbers:
					add_child(_create_label(str(place) + ".", 0.1))
				for col in column_names:
					add_child(_create_label(entry[col]))
				shown_scores += 1
				if i == latest_entry_index:
					latest_entry_shown = true
			elif i == latest_entry_index:
				add_child(_create_label("..."))
				# Show the latest entry even if it's beyond max_shown_scores
				if show_place_numbers:
					add_child(_create_label(str(place) + ".", 0.1))
				for col in column_names:
					add_child(_create_label(entry[col]))
				latest_entry_shown = true

