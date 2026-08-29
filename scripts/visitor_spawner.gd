extends RefCounted
class_name VisitorSpawner

## VisitorSpawner
## Lógica PURA de armado de la cola de visitantes de un día. No es un Node,
## no toca el árbol de escena, no sabe nada de UI: recibe un DayConfig y
## devuelve un Array[VisitorProfile] ya resuelto.
##
## Orden de prioridad al resolver cada slot de la cola:
##   1. Inyección narrativa obligatoria (forced_lore_events) -> gana siempre.
##   2. Warm-up: índice 0 sin evento forzado -> Simple sí o sí.
##   3. Pity system: 2 Medium/Complex seguidos -> el siguiente se fuerza a Simple.
##   4. Resto -> Weighted Random Pool según DayConfig.get_tier_weights().

var _rng := RandomNumberGenerator.new()

func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()

func generate_queue(day_config: DayConfig) -> Array[VisitorProfile]:
	var queue: Array[VisitorProfile] = []
	queue.resize(day_config.total_visitors)

	# --- 1. Inyección determinista: se ubican primero, prioridad absoluta ---
	for event in day_config.forced_lore_events:
		if event.spawn_index >= 0 and event.spawn_index < queue.size():
			queue[event.spawn_index] = event.visitor
		else:
			push_warning(
				"VisitorSpawner: forced_lore_event con índice fuera de rango (%d) en Día %d"
				% [event.spawn_index, day_config.day_number]
			)

	# --- 2. Warm-up: índice 0 SIEMPRE Simple, salvo que un lore event ya lo haya ocupado ---
	if queue[0] == null:
		queue[0] = _pick_from_pool(day_config.simple_pool)

	# --- 3 y 4. Relleno del resto con pity system + weighted pool ---
	var consecutive_hard: int = 1 if _is_hard_tier(queue[0].tier) else 0

	for i in range(1, queue.size()):
		if queue[i] != null:
			# Slot ya ocupado por un forced_lore_event: solo actualizamos el contador de pity,
			# no lo pisamos.
			consecutive_hard = consecutive_hard + 1 if _is_hard_tier(queue[i].tier) else 0
			continue

		var must_force_simple := consecutive_hard >= day_config.max_consecutive_hard
		var chosen_tier: VisitorProfile.VisitorTier

		if must_force_simple:
			chosen_tier = VisitorProfile.VisitorTier.SIMPLE
		else:
			chosen_tier = _pick_weighted_tier(day_config.get_tier_weights())

		var pool := _get_pool_for_tier(day_config, chosen_tier)
		if pool.is_empty():
			# Red de seguridad: si el tier elegido no tiene pool cargado ese día
			# (mala config de diseño), no rompemos el juego: caemos a Simple.
			pool = day_config.simple_pool
			chosen_tier = VisitorProfile.VisitorTier.SIMPLE

		var visitor := _pick_from_pool(pool, queue[i - 1])
		queue[i] = visitor

		consecutive_hard = consecutive_hard + 1 if _is_hard_tier(visitor.tier) else 0

	# --- 5. NUEVO: Inyección determinista de OBJETOS de lore (Día 4) ---
	# A diferencia del paso 1 (que inyecta visitantes ENTEROS), esto reparte
	# strings sueltos dentro del hidden_items de visitantes que ya salieron
	# del pool random, garantizando que aparezcan en algún baúl del día sin
	# necesitar un VisitorProfile dedicado para cada objeto.
	_inject_forced_hidden_items(queue, day_config)

	return queue

## NUEVO: reparte day_config.forced_hidden_items entre slots de la cola que
## NO estén ocupados por un forced_lore_event (esos visitantes ya tienen su
## propio peso narrativo; no les pisamos el baúl). Determinista: mismo
## DayConfig -> mismos slots elegidos siempre, sin usar _rng.
##
## Importante: duplicamos el VisitorProfile del slot antes de tocarlo. Los
## VisitorProfile son Resources que pueden estar compartidos (el mismo
## .tres puede reaparecer en varios slots/días); mutar hidden_items directo
## sobre el original ensuciaría ese Resource para siempre.
func _inject_forced_hidden_items(queue: Array[VisitorProfile], day_config: DayConfig) -> void:
	if day_config.forced_hidden_items.is_empty():
		return

	var forced_slots := {}
	for event in day_config.forced_lore_events:
		forced_slots[event.spawn_index] = true

	var candidate_slots: Array[int] = []
	for i in range(queue.size()):
		if not forced_slots.has(i) and queue[i] != null:
			candidate_slots.append(i)

	if candidate_slots.is_empty():
		push_warning(
			"VisitorSpawner: no hay slots libres para forced_hidden_items en Día %d."
			% day_config.day_number
		)
		return

	for i in range(day_config.forced_hidden_items.size()):
		var item := day_config.forced_hidden_items[i]
		var slot := candidate_slots[i % candidate_slots.size()]

		var patched := queue[slot].duplicate() as VisitorProfile
		patched.hidden_items = patched.hidden_items.duplicate()
		patched.hidden_items.append(item)
		queue[slot] = patched

func _is_hard_tier(tier: VisitorProfile.VisitorTier) -> bool:
	return tier == VisitorProfile.VisitorTier.MEDIUM or tier == VisitorProfile.VisitorTier.COMPLEX

func _get_pool_for_tier(day_config: DayConfig, tier: VisitorProfile.VisitorTier) -> Array[VisitorProfile]:
	match tier:
		VisitorProfile.VisitorTier.SIMPLE:
			return day_config.simple_pool
		VisitorProfile.VisitorTier.MEDIUM:
			return day_config.medium_pool
		VisitorProfile.VisitorTier.COMPLEX:
			return day_config.complex_pool
		_:
			return day_config.simple_pool

## Ruleta ponderada sobre los TIERS habilitados ese día.
func _pick_weighted_tier(weights: Dictionary) -> VisitorProfile.VisitorTier:
	var total_weight := 0.0
	for w in weights.values():
		total_weight += w

	if total_weight <= 0.0:
		return VisitorProfile.VisitorTier.SIMPLE

	var roll := _rng.randf_range(0.0, total_weight)
	var accum := 0.0
	for tier in weights.keys():
		accum += weights[tier]
		if roll <= accum:
			return tier

	return VisitorProfile.VisitorTier.SIMPLE

## Ruleta ponderada DENTRO de un pool, usando spawn_weight de cada VisitorProfile.
## Evita (hasta 3 intentos) repetir el mismo visitante que salió justo antes.
func _pick_from_pool(pool: Array[VisitorProfile], avoid: VisitorProfile = null) -> VisitorProfile:
	if pool.is_empty():
		push_error("VisitorSpawner: intenté elegir de un pool vacío.")
		return null

	if pool.size() == 1:
		return pool[0]

	var total_weight := 0.0
	for v in pool:
		total_weight += v.spawn_weight

	for attempt in range(3):
		var roll := _rng.randf_range(0.0, total_weight)
		var accum := 0.0
		for v in pool:
			accum += v.spawn_weight
			if roll <= accum:
				if v != avoid or attempt == 2:
					return v
				break

	return pool[_rng.randi() % pool.size()]
