extends Node

const MAX_LEVEL: int = 5
const LEVEL_THRESHOLDS: Array[int] = [
	400, # 1 -> 2
	900, # 2 -> 3
	2500, # 3 -> 4
	6000 # 4 -> 5
]
