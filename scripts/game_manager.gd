extends Node

# GameManager - Autoload Singleton de Estado Global

signal day_started(day_num: int)
signal day_ended(day_summary: Dictionary)
signal parcel_health_changed(parcel_name: String, new_health: float)
signal family_funds_changed(new_amount: float)

var current_day: int = 1
const MAX_DAYS: int = 5

var family_savings: float = 12000.0 # Ahorro inicial de la familia de Mr. Chenque
var base_salary_per_day: float = 28000.0
var fine_per_mistake: float = 9000.0

# Estadísticas del día actual
var today_correct: int = 0
var today_mistakes: int = 0
var today_bonuses: float = 0.0
var today_fines: float = 0.0
var today_logs: Array[String] = []

# Salud de las 4 parcelas del Parque Nacional Chalet Huergo (0 a 100)
var parcels_health: Dictionary = {
	"Chalet Histórico": 100.0,
	"Bosque de Lengas": 100.0,
	"Costa y Pingüinera": 100.0,
	"Cerro Chenque y Acantilados": 100.0
}

# Gastos familiares diarios
var family_daily_expenses: Dictionary = {
	1: {"Alimentos y Despensa": 8000, "Calefacción a Gas Patagónico": 5000, "Medicamentos": 2000},
	2: {"Alimentos y Despensa": 8500, "Reparación Ventana por Viento": 7000, "Luz y Agua": 3000},
	3: {"Alimentos y Despensa": 9000, "Calefacción por Temporal": 8000, "Ropa Térmica Hijos": 5000},
	4: {"Alimentos y Despensa": 9500, "Útiles Escolares": 6000, "Mantenimiento Casa": 4000},
	5: {"Alimentos y Despensa": 10000, "Impuestos Municipales Comodoro": 9000, "Ahorro Médico": 5000}
}

# Historial general
var total_patrols_done: int = 0
var total_infractors_stopped: int = 0

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	current_day = 1
	family_savings = 12000.0
	parcels_health = {
		"Chalet Histórico": 100.0,
		"Bosque de Lengas": 100.0,
		"Costa y Pingüinera": 100.0,
		"Cerro Chenque y Acantilados": 100.0
	}
	total_patrols_done = 0
	total_infractors_stopped = 0
	_reset_today_stats()

func _reset_today_stats() -> void:
	today_correct = 0
	today_mistakes = 0
	today_bonuses = 0.0
	today_fines = 0.0
	today_logs.clear()

func record_decision(visitor: Dictionary, approved: bool) -> Dictionary:
	var should_pass = visitor.get("should_pass", true)
	var is_correct = (approved == should_pass)
	var result_info = {}
	
	if is_correct:
		today_correct += 1
		if not approved:
			total_infractors_stopped += 1
			today_logs.append("Rechazo justificado a %s: Infractor detenido correctamente." % visitor.get("name", ""))
		else:
			today_logs.append("Ingreso autorizado a %s: Todo en regla." % visitor.get("name", ""))
		result_info["status"] = "CORRECTO"
	else:
		today_mistakes += 1
		today_fines += fine_per_mistake
		if approved and not should_pass:
			# Dejó pasar a alguien indebido -> Impacto negativo en el parque
			var reasons = visitor.get("rejection_reasons", ["Infracción no detectada"])
			var reason_str = ", ".join(reasons)
			today_logs.append("ERROR GRAVE: Dejaste entrar a %s (%s). Multa aplicada." % [visitor.get("name", ""), reason_str])
			
			var impacts = visitor.get("parcel_impact", {})
			for parcel in impacts:
				apply_parcel_damage(parcel, abs(impacts[parcel]))
		else:
			# Rechazó a alguien que cumplía
			today_logs.append("ERROR: Denegaste el paso injustamente a %s. Queja ministerial y multa aplicada." % visitor.get("name", ""))
		result_info["status"] = "ERROR"
	
	return result_info

func apply_parcel_damage(parcel_name: String, damage: float) -> void:
	if parcels_health.has(parcel_name):
		parcels_health[parcel_name] = maxf(0.0, parcels_health[parcel_name] - damage)
		parcel_health_changed.emit(parcel_name, parcels_health[parcel_name])

func resolve_patrol_event(event_data: Dictionary, went_to_patrol: bool) -> Dictionary:
	var res = {}
	var parcel = event_data.get("parcel", "Bosque de Lengas")
	var reward = event_data.get("reward", 15000)
	var damage = event_data.get("damage_if_ignored", 35)
	
	if went_to_patrol:
		total_patrols_done += 1
		today_bonuses += reward
		today_logs.append("PATRULLA EXITOSA: Interviniste en %s. Amenaza neutralizada. Bonus: +$%d" % [parcel, reward])
		res["success"] = true
		res["message"] = "¡Intervención exitosa! Frenaste la actividad sospechosa en %s y recibes un bonus de $%d." % [parcel, reward]
	else:
		apply_parcel_damage(parcel, damage)
		today_logs.append("ALERTA DESATENDIDA: No patrullaste %s. La parcela sufrió un daño ecológico de -%d%%." % [parcel, damage])
		res["success"] = false
		res["message"] = "Permaneciste en la garita. La parcela '%s' sufrió daños ecológicos (-%d%% de salud)." % [parcel, damage]
	
	return res

func finish_current_day() -> Dictionary:
	var expenses_dict = family_daily_expenses.get(current_day, {"Gastos Generales": 12000})
	var total_expenses: float = 0.0
	for item in expenses_dict:
		total_expenses += expenses_dict[item]
	
	var gross_salary = base_salary_per_day + today_bonuses - today_fines
	gross_salary = maxf(0.0, gross_salary) # El sueldo no puede ser negativo
	
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
		"logs": today_logs.duplicate(),
		"correct": today_correct,
		"mistakes": today_mistakes
	}
	
	day_ended.emit(summary)
	return summary

func advance_to_next_day() -> bool:
	if current_day < MAX_DAYS:
		current_day += 1
		_reset_today_stats()
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
	
	if avg_health >= 75.0 and funds >= 30000.0:
		return {
			"title": "FINAL PERFECTO: HÉROE DE LA PATAGONIA",
			"rating": "SOBRESALIENTE (Rango S)",
			"color": Color(0.2, 0.85, 0.3),
			"description": "Mr. Chenque ha logrado el equilibrio legendario. El Parque Nacional Chalet Huergo y el Cerro Chenque están intactos, su fauna protegida florece y tu familia goza de estabilidad económica para pasar el crudo invierno patagónico con orgullo y bienestar.",
			"icon": "🌲🎖️🏡"
		}
	elif avg_health >= 70.0 and funds < 30000.0:
		return {
			"title": "FINAL HONORABLE: DEFENSOR DEL PARQUE",
			"rating": "BUENO (Rango B)",
			"color": Color(0.3, 0.7, 0.9),
			"description": "Tu compromiso con la naturaleza patagónica fue inquebrantable. El parque sobrevivió en excelente estado, aunque los gastos familiares ajustaron el presupuesto familiar al límite. Eres un verdadero servidor público.",
			"icon": "🌲🛡️🥖"
		}
	elif avg_health < 50.0 and funds >= 35000.0:
		return {
			"title": "FINAL AMARGO: DESASTRE ECOLÓGICO",
			"rating": "REGULAR / NEGLIGENTE (Rango C)",
			"color": Color(0.9, 0.5, 0.2),
			"description": "Tu billetera está llena gracias a los bonos, pero a un costo trágico. Incendios, tala furtiva y usurpaciones arrasaron varias parcelas históricas de Chalet Huergo. La comunidad y las aves sufren las consecuencias.",
			"icon": "🔥💰📉"
		}
	else:
		return {
			"title": "FINAL TRÁGICO: DESTITUCIÓN Y BANCARROTA",
			"rating": "DESASTROSO (Rango F)",
			"color": Color(0.9, 0.2, 0.2),
			"description": "Las constantes multas y el daño ambiental acumulado colmaron la paciencia de la Administración Nacional de Parques. Mr. Chenque ha sido cesado de su cargo, sin ahorros suficientes para su familia.",
			"icon": "⚠️❄️🏚️"
		}
