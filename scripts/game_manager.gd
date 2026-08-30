extends Node

# GameManager / DayManager - Autoload Singleton de Estado Global y Progresión de 5 Días

signal day_started(day_num: int)
signal day_ended(day_summary: Dictionary)
signal parcel_health_changed(parcel_name: String, new_health: float)
signal family_funds_changed(new_amount: float)
signal narrative_event_triggered(event_id: String, event_data: Dictionary)

var current_day: int = 1
const MAX_DAYS: int = 5

# Variables Ambientales por Día
var fog_active: bool = false # Día 3: Niebla espesa del Atlántico
var high_tide_active: bool = false # Día 4: Marea alta y vibración en acantilados
var anomalies_active: bool = false # Día 5: Detección de anomalías de Silva

# Variables Narrativas y Eventos Obligatorios
var silva_logbook_unlocked: bool = false # Día 1 Evento Final
var rare_fisherman_met: bool = false # Día 2 Evento Obligatorio
var day3_worker_decision: String = "" # Día 3: "approved_unease" o "rejected_threat"
var photo_1920_discovered: bool = false # Día 4 Evento Obligatorio
var tunnels_map_discovered: bool = false # Día 4 Evento Obligatorio
var day5_final_choice: String = "" # Día 5: "embrace_mystery" o "protect_park"

# Estado de la pantalla de introducción / briefing diario
var intro_mode: String = "prologue" # "prologue", "morning", "day", "custom"
var custom_intro_pages: Array[Dictionary] = []
var custom_morning_texts: Dictionary = {}
var custom_next_scene: String = "res://scenes/main_game.tscn"

var family_savings: float = 12000.0 # Ahorro inicial de la familia de Mr. Chenque
var base_salary_per_day: float = 30000.0
var fine_per_mistake: float = 8000.0
var bonus_per_infractor_caught: float = 2000.0

# Estadísticas del día actual
var today_correct: int = 0
var today_mistakes: int = 0
var today_bonuses: float = 0.0
var today_fines: float = 0.0
var today_logs: Array[String] = []
var today_visitors_seen: int = 0
var today_visitors_passed: int = 0
var today_visitors_rejected: int = 0
var today_harmful_visits: int = 0
var today_found_objects: Array[String] = []
var today_important_notes: Array[String] = []
var last_day_summary: Dictionary = {}

# Salud de las 5 parcelas del Parque Nacional Chalet Huergo (0 a 100)
var parcels_health: Dictionary = {
	"Chalet Histórico": 100.0,
	"Bosque de Lengas": 100.0,
	"Costa y Pingüinera": 100.0,
	"Cerro Chenque y Acantilados": 100.0,
	"Humedal y Laguna de Aves": 100.0
}

# Tipos de daños visuales acumulados en cada parcela
var parcels_damage_tags: Dictionary = {
	"Chalet Histórico": [],
	"Bosque de Lengas": [],
	"Costa y Pingüinera": [],
	"Cerro Chenque y Acantilados": [],
	"Humedal y Laguna de Aves": []
}

# Gastos familiares diarios
var family_daily_expenses: Dictionary = {
	1: {"Alimentos y Despensa": 8000, "Calefacción a Gas Patagónico": 5000, "Medicamentos": 2000},
	2: {"Alimentos y Despensa": 8500, "Reparación Ventana por Viento": 7000, "Luz y Agua": 3000},
	3: {"Alimentos y Despensa": 9000, "Calefacción por Niebla y Frío": 8000, "Ropa Térmica Hijos": 5000},
	4: {"Alimentos y Despensa": 9500, "Útiles Escolares": 6000, "Mantenimiento Casa": 4000},
	5: {"Alimentos y Despensa": 10000, "Impuestos Municipales Comodoro": 9000, "Ahorro Médico": 5000}
}

# Historial general
var total_infractors_stopped: int = 0
var total_mistakes_made: int = 0

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	current_day = 1
	family_savings = 12000.0
	fog_active = false
	high_tide_active = false
	anomalies_active = false
	silva_logbook_unlocked = false
	rare_fisherman_met = false
	day3_worker_decision = ""
	photo_1920_discovered = false
	tunnels_map_discovered = false
	day5_final_choice = ""
	
	parcels_health = {
		"Chalet Histórico": 100.0,
		"Bosque de Lengas": 100.0,
		"Costa y Pingüinera": 100.0,
		"Cerro Chenque y Acantilados": 100.0,
		"Humedal y Laguna de Aves": 100.0
	}
	parcels_damage_tags = {
		"Chalet Histórico": [],
		"Bosque de Lengas": [],
		"Costa y Pingüinera": [],
		"Cerro Chenque y Acantilados": [],
		"Humedal y Laguna de Aves": []
	}
	total_infractors_stopped = 0
	total_mistakes_made = 0
	_reset_today_stats()

func _reset_today_stats() -> void:
	today_correct = 0
	today_mistakes = 0
	today_bonuses = 0.0
	today_fines = 0.0
	today_logs.clear()
	today_visitors_seen = 0
	today_visitors_passed = 0
	today_visitors_rejected = 0
	today_harmful_visits = 0
	today_found_objects.clear()
	today_important_notes.clear()

func setup_day_parameters(day_num: int) -> void:
	current_day = day_num
	match day_num:
		1:
			fog_active = false
			high_tide_active = false
			anomalies_active = false
		2:
			fog_active = false
			high_tide_active = false
			anomalies_active = false
		3:
			fog_active = true # Evento Ambiental Día 3: Niebla
			high_tide_active = false
			anomalies_active = false
		4:
			fog_active = false
			high_tide_active = true # Evento Ambiental Día 4: Marea Alta
			anomalies_active = false
		5:
			fog_active = false
			high_tide_active = false
			anomalies_active = true # Lógica de Error Día 5: Detección de Anomalías

func _track_object_found(item_name: String) -> void:
	if item_name.is_empty():
		return
	item_name = item_name.strip_edges()
	if item_name.is_empty():
		return
	if not today_found_objects.has(item_name):
		today_found_objects.append(item_name)

func record_decision(visitor: Dictionary, approved: bool) -> Dictionary:
	var should_pass = visitor.get("should_pass", true)
	var is_correct = (approved == should_pass)
	var result_info = {}
	var vis_name = visitor.get("name", "Visitante")
	var event_id = visitor.get("event_id", "")
	today_visitors_seen += 1
	
	for item in visitor.get("car_items", []):
		_track_object_found(str(item))
		
	# Manejo de Eventos Narrativos Especiales
	if event_id == "rare_fisherman":
		rare_fisherman_met = true
		var confiscated = not approved
		var outcome = "no confiscado" if not confiscated else "confiscado"
		today_important_notes.append("🐟 Pescador en veda: 'El pescado anómalo sale con la marea, pero la inspección quedó registrada.'")
		today_logs.append("🧪 INSPECCIÓN NARRATIVA: %s el pescado anómalo del pescador en veda. No hay consecuencia operativa." % outcome)
		result_info["status"] = "NARRATIVE"
		result_info["confiscated"] = confiscated
		return result_info
	elif event_id == "day3_midnight_worker":
		if approved:
			day3_worker_decision = "approved_unease"
			today_logs.append("⚠️ INQUIETUD: Dejaste entrar al camión nocturno sin documentos. La niebla se cerró tras él.")
			today_important_notes.append("🌫️ Inquietud a medianoche: Camión misterioso ingresó en la niebla sin registro.")
		else:
			day3_worker_decision = "rejected_threat"
			today_logs.append("⚠️ AMENAZA: Rechazaste al trabajador de medianoche. Advirtió: 'Silva pensó que podía decir que no. Mirá cómo terminó.'")
			today_important_notes.append("⚡ Amenaza en la niebla: El conductor advirtió sobre el destino de Silva.")
	elif event_id == "day4_clues":
		photo_1920_discovered = true
		tunnels_map_discovered = true
		today_important_notes.append("📷 Hallazgo: Fotografía de 1920 y Mapa de túneles secretos bajo Chalet Huergo recuperados.")
	elif event_id == "day5_faceless_man":
		if approved:
			day5_final_choice = "embrace_mystery"
			today_logs.append("🌌 DECISIÓN FINAL: Autorizaste el ingreso hacia los túneles y el legado de Silva.")
			today_important_notes.append("🚪 Cruzaste la barrera hacia lo desconocido bajo el Cerro Chenque.")
		else:
			day5_final_choice = "protect_park"
			today_logs.append("🛡️ DECISIÓN FINAL: Clausuraste la garita y protegiste el parque y tu familia.")
			today_important_notes.append("🔒 Sello definitivo: Garita resguardada y parque protegido.")
	
	if is_correct:
		today_correct += 1
		if not approved:
			today_visitors_rejected += 1
			total_infractors_stopped += 1
			today_bonuses += bonus_per_infractor_caught
			var reasons = visitor.get("rejection_reasons", [])
			var r_str = ", ".join(reasons) if not reasons.is_empty() else "Infracción detectada"
			today_logs.append("✔ RECHAZO CORRECTO a %s (%s). Bonus: +$%d" % [vis_name, r_str, int(bonus_per_infractor_caught)])
			today_important_notes.append("✅ %s fue rechazado por: %s" % [vis_name, r_str])
		else:
			today_visitors_passed += 1
			today_logs.append("✔ INGRESO AUTORIZADO a %s: Documentación y actividad en regla." % vis_name)
		result_info["status"] = "CORRECTO"
	else:
		today_mistakes += 1
		total_mistakes_made += 1
		today_fines += fine_per_mistake
		if approved and not should_pass:
			today_visitors_passed += 1
			today_harmful_visits += 1
			var reasons = visitor.get("rejection_reasons", ["Infracción no detectada"])
			var reason_str = ", ".join(reasons)
			today_logs.append("✖ ERROR GRAVE: Dejaste entrar a %s (%s). Multa: -$%d" % [vis_name, reason_str, int(fine_per_mistake)])
			today_important_notes.append("⚠️ %s entró indebidamente: %s" % [vis_name, reason_str])
			
			var impacts = visitor.get("parcel_impact", {})
			for parcel in impacts:
				var imp_data = impacts[parcel]
				if imp_data is Dictionary:
					var dmg = imp_data.get("damage", 25.0)
					var tag = imp_data.get("tag", "daño")
					apply_parcel_damage(parcel, dmg, tag)
				elif imp_data is float or imp_data is int:
					apply_parcel_damage(parcel, abs(float(imp_data)), "daño")
		else:
			today_visitors_rejected += 1
			today_logs.append("✖ ERROR: Denegaste el paso injustamente a %s. Queja ciudadana y multa: -$%d" % [vis_name, int(fine_per_mistake)])
			today_important_notes.append("⚠️ %s fue rechazado en un caso legítimo y generó queja" % vis_name)
		result_info["status"] = "ERROR"
	
	return result_info

func apply_parcel_damage(parcel_name: String, damage: float, damage_tag: String = "") -> void:
	if parcels_health.has(parcel_name):
		parcels_health[parcel_name] = maxf(0.0, parcels_health[parcel_name] - damage)
		if not damage_tag.is_empty() and parcels_damage_tags.has(parcel_name):
			if not damage_tag in parcels_damage_tags[parcel_name]:
				parcels_damage_tags[parcel_name].append(damage_tag)
		parcel_health_changed.emit(parcel_name, parcels_health[parcel_name])

func trigger_silva_logbook_event() -> void:
	silva_logbook_unlocked = true
	today_important_notes.append("📖 EVENTO FINAL DÍA 1: Bitácora de Silva encontrada en el escritorio ('Marcas en las rocas a las 3:00 AM').")
	today_logs.append("📖 Bitácora de Silva recibida al cierre de turno.")

func finish_current_day() -> Dictionary:
	# Disparar Evento Final del Día 1 si corresponde
	if current_day == 1 and not silva_logbook_unlocked:
		trigger_silva_logbook_event()
		
	var expenses_dict = family_daily_expenses.get(current_day, {"Gastos Generales": 12000})
	var total_expenses: float = 0.0
	for item in expenses_dict:
		total_expenses += expenses_dict[item]
	
	var gross_salary = base_salary_per_day + today_bonuses - today_fines
	gross_salary = maxf(0.0, gross_salary)
	
	var net_savings_change = gross_salary - total_expenses
	family_savings += net_savings_change
	family_funds_changed.emit(family_savings)
	
	var summary = {
		"day": current_day,
		"base_salary": base_salary_per_day,
		"bonuses": today_bonuses,
		"fines": today_fines,
		"gross_salary": gross_salary,
		"expenses_dict": expenses_dict,
		"total_expenses": total_expenses,
		"net_savings_change": net_savings_change,
		"final_family_savings": family_savings,
		"parcels_health": parcels_health.duplicate(),
		"parcels_damage_tags": parcels_damage_tags.duplicate(),
		"logs": today_logs.duplicate(),
		"correct": today_correct,
		"mistakes": today_mistakes,
		"visitors_seen": today_visitors_seen,
		"visitors_passed": today_visitors_passed,
		"visitors_rejected": today_visitors_rejected,
		"harmful_visits": today_harmful_visits,
		"objects_found": today_found_objects.duplicate(),
		"important_notes": today_important_notes.duplicate(),
		"silva_logbook_unlocked": silva_logbook_unlocked,
		"fog_active": fog_active,
		"high_tide_active": high_tide_active,
		"anomalies_active": anomalies_active,
		"day3_worker_decision": day3_worker_decision,
		"photo_1920_discovered": photo_1920_discovered,
		"tunnels_map_discovered": tunnels_map_discovered,
		"day5_final_choice": day5_final_choice
	}
	
	last_day_summary = summary
	day_ended.emit(summary)
	return summary

func advance_to_next_day() -> bool:
	if current_day < MAX_DAYS:
		current_day += 1
		_reset_today_stats()
		setup_day_parameters(current_day)
		day_started.emit(current_day)
		return true
	return false

func get_average_parcel_health() -> float:
	var sum = 0.0
	for p in parcels_health:
		sum += parcels_health[p]
	return sum / float(parcels_health.size())

func get_game_ending() -> Dictionary:
	var avg_health = get_average_parcel_health()
	var funds = family_savings
	
	if day5_final_choice == "embrace_mystery":
		return {
			"title": "FINAL OCULTO: EL SUCESOR DE LAS PROFUNDIDADES",
			"rating": "MISTERIO REVELADO (Rango Secreto)",
			"color": Color(0.6, 0.4, 0.95),
			"description": "Mr. Chenque autorizó el pase de 1980 y descendió por los túneles secretos del Chalet Huergo. Descubriste qué habitaba bajo el Cerro Chenque y tomaste el lugar que Silva dejó vacante. Tu familia recibió una misteriosa compensación anónima que los salvó para siempre del frío patagónico.",
			"icon": "🌌🗝️🌊"
		}
	elif avg_health >= 80.0 and funds >= 30000.0:
		return {
			"title": "FINAL PERFECTO: HÉROE DE LA PATAGONIA",
			"rating": "SOBRESALIENTE (Rango S)",
			"color": Color(0.2, 0.85, 0.3),
			"description": "Mr. Chenque ha logrado el equilibrio legendario. El Parque Nacional Chalet Huergo, el Cerro Chenque, sus costas y humedales están intactos. Detectaste todas las anomalías y protegiste la superficie. Tu familia goza de estabilidad económica para pasar el crudo invierno patagónico con orgullo y bienestar.",
			"icon": "🌲🎖️🏡"
		}
	elif avg_health >= 65.0 and funds >= 20000.0:
		return {
			"title": "FINAL HONORABLE: DEFENSOR DEL PARQUE",
			"rating": "BUENO (Rango B)",
			"color": Color(0.3, 0.7, 0.9),
			"description": "Tu compromiso con la naturaleza patagónica fue ejemplar. Las 5 parcelas del parque sobrevivieron en gran estado y la garita se mantuvo firme ante los misterios de Silva. Aunque los gastos del hogar ajustaron el presupuesto familiar, eres un verdadero guardaparques.",
			"icon": "🌲🛡️🥖"
		}
	elif avg_health < 50.0 and funds >= 25000.0:
		return {
			"title": "FINAL AMARGO: DESASTRE ECOLÓGICO",
			"rating": "NEGLIGENTE (Rango C)",
			"color": Color(0.9, 0.5, 0.2),
			"description": "Mantuviste las finanzas familiares, pero a un costo trágico para Chalet Huergo. Las anomalías y filtraciones de infractores dañaron parcelas históricas y arruinaron el santuario natural.",
			"icon": "🔥💰📉"
		}
	else:
		return {
			"title": "FINAL TRÁGICO: DESTITUCIÓN Y BANCARROTA",
			"rating": "DESASTROSO (Rango F)",
			"color": Color(0.9, 0.2, 0.2),
			"description": "Las constantes multas y el daño ambiental acumulado colmaron la paciencia de la Administración de Parques Nacionales. Mr. Chenque ha sido destituido de su cargo, sin ahorros suficientes para su familia.",
			"icon": "⚠️❄️🏚️"
		}

func play_prologue() -> void:
	reset_game()
	intro_mode = "prologue"
	get_tree().change_scene_to_file("res://scenes/game_intro.tscn")

func play_day_start_intro(day_num: int = -1) -> void:
	if day_num > 0:
		current_day = day_num
	setup_day_parameters(current_day)
	if current_day <= 1:
		play_day_briefing(1)
		return
	intro_mode = "morning"
	get_tree().change_scene_to_file("res://scenes/day_start_intro.tscn")

func play_day_briefing(day_num: int = -1) -> void:
	if day_num > 0:
		current_day = day_num
	setup_day_parameters(current_day)
	intro_mode = "day"
	get_tree().change_scene_to_file("res://scenes/day_intro.tscn")

func play_day_intro(day_num: int = -1) -> void:
	var target = day_num if day_num > 0 else current_day
	if target <= 1:
		play_day_briefing(1)
	else:
		play_day_start_intro(target)

func set_custom_morning_text(day_num: int, text: String) -> void:
	custom_morning_texts[day_num] = text

func play_custom_intro(pages_array: Array[Dictionary], next_scene: String = "res://scenes/main_game.tscn") -> void:
	intro_mode = "custom"
	custom_intro_pages = pages_array
	custom_next_scene = next_scene
	get_tree().change_scene_to_file("res://scenes/day_intro.tscn")
