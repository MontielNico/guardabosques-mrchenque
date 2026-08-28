extends Control
class_name DaySummaryScreen

# Pantalla de Resumen de Fin de Día (Sueldo, Gastos Familiares y Estado de Parcelas)

@onready var title_label: Label = $Panel/Margin/VBox/Header/TitleLabel
@onready var stats_label: Label = $Panel/Margin/VBox/Content/LeftCol/StatsBox/StatsLabel
@onready var finance_label: Label = $Panel/Margin/VBox/Content/LeftCol/FinanceBox/FinanceLabel
@onready var parcels_container: VBoxContainer = $Panel/Margin/VBox/Content/RightCol/ParcelsBox/VBox/ParcelsList
@onready var logs_container: VBoxContainer = $Panel/Margin/VBox/Content/RightCol/LogsBox/VBox/LogsScroll/LogsList
@onready var continue_btn: Button = $Panel/Margin/VBox/Footer/ContinueButton

var is_final_day: bool = false

func _ready() -> void:
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)

func display_summary(summary: Dictionary) -> void:
	SoundManager.play_sound("coin")
	var day = summary.get("day", 1)
	is_final_day = (day >= GameManager.MAX_DAYS)
	
	if title_label:
		title_label.text = "RESUMEN DEL DÍA %d - CIERRE DE JORNADA" % day
		
	if stats_label:
		stats_label.text = "• Aciertos y Decisiones Correctas: %d\n• Infracciones o Errores Cometidos: %d" % [
			summary.get("correct", 0),
			summary.get("mistakes", 0)
		]
		
	if finance_label:
		var base = summary.get("base_salary", 0.0)
		var bon = summary.get("bonuses", 0.0)
		var fin = summary.get("fines", 0.0)
		var gross = summary.get("gross_salary", 0.0)
		var exp_dict = summary.get("expenses_dict", {})
		var tot_exp = summary.get("total_expenses", 0.0)
		var net_change = summary.get("net_savings_change", 0.0)
		var savings = summary.get("final_family_savings", 0.0)
		
		var exp_lines = ""
		for item in exp_dict:
			exp_lines += "   - %s: -$%d\n" % [item, exp_dict[item]]
			
		finance_label.text = """[ BALANCE ECONÓMICO PERSONAL ]
Sueldo Base: +$%d
Bonos por Patrullajes Exitosos: +$%d
Multas por Errores: -$%d
----------------------------------------
Sueldo Neto de Jornada: +$%d

[ GASTOS DEL HOGAR Y FAMILIA ]
%sTotal Gastos Familiares: -$%d
----------------------------------------
Resultado Neto del Día: %s$%d
FONDO FAMILIAR ACUMULADO: $%d""" % [
			base, bon, fin, gross,
			exp_lines, tot_exp,
			("+" if net_change >= 0 else "-"), abs(net_change),
			savings
		]
		
	# Poblar barras de salud de las 4 parcelas
	for child in parcels_container.get_children():
		child.queue_free()
		
	var parcels = summary.get("parcels_health", {})
	for p_name in parcels:
		var p_val = parcels[p_name]
		var row = HBoxContainer.new()
		
		var name_lbl = Label.new()
		name_lbl.text = p_name
		name_lbl.custom_minimum_size = Vector2(180, 0)
		name_lbl.add_theme_font_size_override("font_size", 13)
		row.add_child(name_lbl)
		
		var bar = ProgressBar.new()
		bar.value = p_val
		bar.max_value = 100.0
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.custom_minimum_size = Vector2(120, 20)
		bar.show_percentage = true
		
		if p_val >= 75.0:
			bar.modulate = Color(0.3, 0.9, 0.4) # Verde
		elif p_val >= 40.0:
			bar.modulate = Color(0.95, 0.8, 0.2) # Amarillo
		else:
			bar.modulate = Color(0.95, 0.2, 0.2) # Rojo
			
		row.add_child(bar)
		parcels_container.add_child(row)
		
	# Poblar logs del día
	for child in logs_container.get_children():
		child.queue_free()
		
	var logs = summary.get("logs", [])
	if logs.is_empty():
		var l_lbl = Label.new()
		l_lbl.text = "Jornada tranquila sin incidentes mayores."
		logs_container.add_child(l_lbl)
	else:
		for log_msg in logs:
			var l_lbl = Label.new()
			l_lbl.text = "• " + log_msg
			l_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l_lbl.add_theme_font_size_override("font_size", 12)
			if "ERROR" in log_msg:
				l_lbl.modulate = Color(1.0, 0.4, 0.4)
			elif "PATRULLA" in log_msg:
				l_lbl.modulate = Color(0.4, 1.0, 0.6)
			logs_container.add_child(l_lbl)
			
	if continue_btn:
		if is_final_day:
			continue_btn.text = "🏆 VER EVALUACIÓN FINAL DE MR. CHENQUE"
		else:
			continue_btn.text = "➡️ COMENZAR DÍA %d" % (day + 1)

func _on_continue_pressed() -> void:
	SoundManager.play_sound("click")
	if is_final_day:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		GameManager.advance_to_next_day()
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")
