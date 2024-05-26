extends Resource
class_name saveGame

@export var bonusItems : Array[int]
@export var finishedLevels : Array[int]
var unlockedLevels = [1]
@export var time : Array


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


