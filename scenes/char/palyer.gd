extends CharacterBody2D
## 玩家角色脚本 - 包含完整的换装系统
##
## ============ 换装原理 ============
## 我们使用"分层渲染"技术来实现换装：
##
## 角色由多个 Sprite 层组成，从后到前依次是：
##   [BodySprite]     <- 身体层（底层）：显示角色的身体和衣服
##   [ArmorSprite]    <- 盔甲层（中间层）：显示盔甲、衣服等覆盖物
##   [WeaponSprite]   <- 武器层（顶层）：显示武器、盾牌等
##
## 换装原理：
##   - 每个层可以显示或隐藏（visible 属性）
##   - 每个层可以替换纹理（texture 属性）
##   - 通过组合不同层的显示/隐藏和纹理，就能实现不同的外观组合
##
## 这样做的好处：
##   1. 代码简单，容易理解
##   2. 不需要骨骼动画知识
##   3. 可以自由组合任意装备
##   4. 性能好，只是一堆 Sprite
##
## 缺点：
##   - 装备必须是独立的 Sprite，不能完美适配所有体型
##   - 对于复杂动画需要更多工作
##
## ============ 扩展换装系统的方法 ============
## 如果你想添加更多装备类型（如帽子、披风、盾牌）：
##   1. 在 palyer.tscn 中添加新的 Sprite 节点
##   2. 在 available_equipment 字典中添加新的装备类型
##   3. 在 _apply_equipment() 方法中处理新的装备层

# ==================== 导出变量 ====================
@export_group("移动设置")
@export var speed: float = 200.0  # 移动速度（像素/秒）

# ==================== 节点引用 ====================
# 各层 Sprite，用于换装
@onready var body_sprite: AnimatedSprite2D = $BodySprite      # 身体/底层
@onready var armor_sprite: Sprite2D = $ArmorSprite            # 盔甲/中层
@onready var weapon_sprite: Sprite2D = $WeaponSprite         # 武器/顶层

# ==================== 换装系统数据 ====================
# 存储所有可用装备的数据
# 结构：装备类型 -> 装备ID -> SpriteFrames 或 Texture
# 对于身体用 SpriteFrames（支持动画），对于盔甲/武器用 Texture

var available_equipment: Dictionary = {
	"body": {},      # 身体类型：不同职业的身体贴图（SpriteFrames）
	"armor": {},     # 盔甲类型：纹理
	"weapon": {},    # 武器类型：纹理
}

# 当前穿戴的装备ID
var current_equipment: Dictionary = {
	"body": "warrior_idle",
	"armor": "none",
	"weapon": "none",
}

# ==================== 状态机相关 ====================
var is_moving: bool = false
var facing_direction: Vector2 = Vector2.DOWN  # 朝向（用于动画方向）

# 动画映射：不同身体类型有不同的动画名称
var animation_mappings: Dictionary = {
	"warrior_idle": "idle",
	"warrior_run": "walk",
}

# ==================== 内置回调 ====================

func _ready() -> void:
	_setup_equipment_system()


func _physics_process(delta: float) -> void:
	# 获取输入方向
	var input_direction = _get_input_direction()

	# 更新移动状态
	is_moving = input_direction != Vector2.ZERO

	if is_moving:
		velocity = input_direction * speed
		_update_facing_direction(input_direction)
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_update_animation()


# ==================== 换装系统核心方法 ====================

## 初始化换装系统 - 加载所有装备数据
func _setup_equipment_system() -> void:
	# 创建战士的 SpriteFrames（待机动画）
	var warrior_idle_frames = _create_warrior_idle_frames()
	available_equipment["body"]["warrior_idle"] = warrior_idle_frames

	# 创建战士的跑步 SpriteFrames
	var warrior_run_frames = _create_warrior_run_frames()
	available_equipment["body"]["warrior_run"] = warrior_run_frames

	# 创建弓箭手的 SpriteFrames（待机）
	var archer_idle_frames = _create_archer_idle_frames()
	available_equipment["body"]["archer_idle"] = archer_idle_frames

	# 创建弓箭手的跑步 SpriteFrames
	var archer_run_frames = _create_archer_run_frames()
	available_equipment["body"]["archer_run"] = archer_run_frames

	# 应用初始装备
	_apply_equipment()

	print("换装系统初始化完成！")


## 创建战士待机动画的 SpriteFrames
func _create_warrior_idle_frames() -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.add_animation("idle")

	# 从大图中裁剪出 8 帧idle动画
	var base_texture = load("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Warrior/Warrior_Idle.png")

	for i in range(8):
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = base_texture
		atlas_tex.region = Rect2(i * 192, 0, 192, 192)
		frames.add_frame("idle", atlas_tex)

	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 10.0)

	return frames


## 创建战士跑步动画的 SpriteFrames
func _create_warrior_run_frames() -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.add_animation("walk")

	var base_texture = load("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Warrior/Warrior_Run.png")

	for i in range(8):
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = base_texture
		atlas_tex.region = Rect2(i * 192, 0,  192, 192)
		frames.add_frame("walk", atlas_tex)

	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 12.0)

	return frames


## 创建弓箭手待机动画的 SpriteFrames
func _create_archer_idle_frames() -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.add_animation("idle")

	var base_texture = load("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Archer/Archer_Idle.png")

	for i in range(8):
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = base_texture
		atlas_tex.region = Rect2(i * 192, 0, 192, 192)
		frames.add_frame("idle", atlas_tex)

	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 10.0)

	return frames


## 创建弓箭手跑步动画的 SpriteFrames
func _create_archer_run_frames() -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.add_animation("walk")

	var base_texture = load("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Archer/Archer_Run.png")

	for i in range(8):
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = base_texture
		atlas_tex.region = Rect2(i * 192, 0, 192, 192)
		frames.add_frame("walk", atlas_tex)

	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 12.0)

	return frames


## ============ 核心换装方法 ============

## 换装 - 给外部调用的接口
## equipment_slot: 装备槽位类型 ("body", "armor", "weapon")
## equipment_id: 装备ID（必须是 available_equipment 中定义的）
func equip(equipment_slot: String, equipment_id: String) -> void:
	# 验证装备类型
	if not available_equipment.has(equipment_slot):
		push_error("换装失败：未知的装备槽位: " + equipment_slot)
		return

	# 验证装备ID
	if not available_equipment[equipment_slot].has(equipment_id):
		push_error("换装失败：装备槽位 '" + equipment_slot + "' 中没有 '" + equipment_id + "'")
		return

	# 更新当前装备记录
	current_equipment[equipment_slot] = equipment_id

	# 应用装备到场景
	_apply_equipment()

	print("换装: ", equipment_slot, " -> ", equipment_id)


## 应用装备 - 根据 current_equipment 更新所有 Sprite 层
func _apply_equipment() -> void:
	# ----- 身体层 -----
	var body_id = current_equipment["body"]
	var body_data = available_equipment["body"].get(body_id)

	if body_data != null and body_data is SpriteFrames:
		body_sprite.sprite_frames = body_data
		body_sprite.visible = true
	else:
		body_sprite.visible = false

	# ----- 盔甲层 -----
	var armor_id = current_equipment["armor"]
	if armor_id == "none":
		# 无盔甲，设置为透明
		armor_sprite.modulate = Color(1, 1, 1, 0)
	else:
		# 有盔甲（这里简化处理，实际应该加载对应纹理）
		armor_sprite.modulate = Color(1, 1, 1, 0)  # TODO: 加载盔甲纹理

	# ----- 武器层 -----
	var weapon_id = current_equipment["weapon"]
	if weapon_id == "none":
		weapon_sprite.modulate = Color(1, 1, 1, 0)
	else:
		# TODO: 加载武器纹理
		weapon_sprite.modulate = Color(1, 1, 1, 0)

	# 更新动画（因为换了身体类型，动画名称可能不同）
	_update_animation()


## 获取当前装备状态
func get_current_equipment() -> Dictionary:
	return current_equipment.duplicate()


# ==================== 移动和动画系统 ====================

func _get_input_direction() -> Vector2:
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("walk_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("walk_down"):
		input_vector.y += 1
	if Input.is_action_pressed("walk_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("walk_right"):
		input_vector.x += 1

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	return input_vector


func _update_facing_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		facing_direction = direction


## 更新动画 - 根据当前状态播放对应的动画
func _update_animation() -> void:
	# 根据移动状态选择待机或行走动画
	var animation_suffix = "idle" if not is_moving else "walk"
	var body_id = current_equipment["body"]

	# 检查是否有针对这个身体的特定动画
	# 例如 warrior_idle, warrior_walk 或者 archer_idle, archer_walk
	var full_animation_name = body_id.replace("_idle", "_" + animation_suffix).replace("_run", "_" + animation_suffix)

	# 尝试播放动画
	if body_sprite.sprite_frames.has_animation(full_animation_name):
		body_sprite.play(full_animation_name)
	elif body_sprite.sprite_frames.has_animation(animation_suffix):
		# 退回到通用动画名
		body_sprite.play(animation_suffix)
	else:
		# 尝试播放任何可用动画
		var anims = body_sprite.sprite_frames.get_animation_names()
		if anims.size() > 0:
			body_sprite.play(anims[0])


# ==================== 调试方法 ====================

## 切换身体类型（测试用）
func switch_body_type() -> void:
	if current_equipment["body"] == "warrior_idle":
		equip("body", "archer_idle")
	else:
		equip("body", "warrior_idle")


## 切换盔甲（测试用）
func toggle_armor() -> void:
	if current_equipment["armor"] == "none":
		equip("armor", "heavy")  # TODO: 实现真正的盔甲贴图
	else:
		equip("armor", "none")


## 切换武器（测试用）
func toggle_weapon() -> void:
	if current_equipment["weapon"] == "none":
		equip("weapon", "sword")  # TODO: 实现真正的武器贴图
	else:
		equip("weapon", "none")


## 按键测试换装
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			# 切换身体类型（战士/弓箭手）
			KEY_Q:
				switch_body_type()
				print("按 Q 切换身体类型")

			# 切换盔甲（有/无）
			KEY_E:
				toggle_armor()
				print("按 E 切换盔甲")

			# 切换武器（有/无）
			KEY_R:
				toggle_weapon()
				print("按 R 切换武器")

			# 打印当前装备状态
			KEY_P:
				debug_print_equipment()


func debug_print_equipment() -> void:
	print("========== 当前装备 ==========")
	print("  身体: ", current_equipment["body"])
	print("  盔甲: ", current_equipment["armor"])
	print("  武器: ", current_equipment["weapon"])
	print("================================")
