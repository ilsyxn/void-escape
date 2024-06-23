extends Resource
class_name saveGame

@export var bonusItems : Array[int]
@export var finishedLevels : Array[int]
var unlockedLevels = [1,21,31]
@export var time : Array

var welt1_skins = [1, 21, 19, 22, 20, 18, 17, 12]
var welt3_skins = [3, 7, 5, 9, 6, 4, 2, 8]
var world1_player = welt1_skins[0]
var world3_player = welt3_skins[0]
var selectedSkinText = preload("res://assets/skins/character.png")

var three_stars = []
var two_stars = []
var one_star = []

func setSkin(id):
	world1_player = welt1_skins[id]
	world3_player = welt3_skins[id]

func getWorld3Player():
	return world3_player

func getWorld1Player():
	return world1_player

func bonusCollected(id : int):
	bonusItems.append(id)

func levelFinished(id : int):
	finishedLevels.append(id)

func removeBonus(id : int):
	for n in bonusItems.size():
		if bonusItems[n] == id:
			bonusItems.remove_at(n)

func bonusUnlocked() -> bool:
	for n in [1,2,3,4,5]:
		if !bonusItems.has(n):
			return false
	return true

func gameFinished() -> bool:
	for n in [1,2,3,4,5]:
		if !finishedLevels.has(n):
			return false
	return true


