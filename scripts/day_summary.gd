extends Control
class_name DaySummaryScreen

# Pantalla de Resumen de Fin de Día (Sueldo, Gastos Familiares, Estado de Parcelas y Descargo Personal de Mr. Chenque)

@onready var title_label: Label = $Margin/Panel/InnerMargin/VBox/Header/TitleLabel
@onready var stats_label: Label = $Margin/Panel/InnerMargin/VBox/Content/LeftCol/StatsBox/StatsLabel
@onready var finance_label: Label = $Margin/Panel/InnerMargin/VBox/Content/LeftCol/FinanceBox/FinanceLabel
@onready var parcels_container: VBoxContainer = $Margin/Panel/InnerMargin/VBox/Content/RightCol/ParcelsBox/VBox/ParcelsList
@onready var logs_container: VBoxContainer = $Margin/Panel/InnerMargin/VBox/Content/RightCol/LogsBox/VBox/LogsScroll/LogsList
@onready var descargo_box: PanelContainer = $Margin/Panel/InnerMargin/VBox/DescargoBox
@onready var descargo_header: Label = $Margin/Panel/InnerMargin/VBox/DescargoBox/InnerMargin/VBox/DescargoHeader
@onready var descargo_text: RichTextLabel = $Margin/Panel/InnerMargin/VBox/DescargoBox/InnerMargin/VBox/DescargoText
@onready var continue_btn: Button = $Margin/Panel/InnerMargin/VBox/Footer/ContinueButton

var is_final_day: bool = false

# Descargos diarios de Mr. Chenque por defecto (pueden ser modificados o insertados externamente)
var chenque_daily_descargos: Dictionary = {
	1: "Primer día terminado, fue más tranquilo de lo que esperaba. La mayoría de los visitantes tenía sus papeles en regla y no hubo ningún problema importante. Alguno que otro quiso hacerse el distraído con las normas, pero nada que no pudiera resolver. Supongo que esto es lo que significa ser guardabosques, revisar permisos. Hacer cumplir las reglas. Esperar.\n Aunque hay algo que me llamó la atención, durante la tarde el viento empezó a golpear contra la garita con bastante fuerza. Por momentos parecía que alguien caminaba alrededor del puesto, salí a mirar un par de veces pero no había nadie. Debe haber sido el viento.\n Mañana será otro día. Por ahora, no tengo de qué preocuparme.",
	2: "Segundo día terminado. La nota de Silva no me gustó, pensé que exageraba ya que después de todo, ayer no pasó nada y supongo que cada guardaparque termina viendo cosas donde no las hay. Pero hoy apareció el pescador y traía algo en el cajón. No sé exactamente qué era. Nunca había visto algo así, no parecía un pez normal y tampoco parecía completamente muerto.\n Decidí no dejarlo salir con eso, no discutió demasiado. Eso fue lo que más me llamó la atención. Se fue sin decir casi nada y desde entonces no puedo dejar de pensar en la nota\n 'Se alimentan de eso.'\n No sé qué quiso decir esa nota. Por ahora prefiero no sacar conclusiones.\n Mañana será otro día. Espero que las cosas vuelvan a la normalidad.",
	3: "Tercer día terminado. Hoy vino el agente. Ahora entiendo la nota de Silva, tenía la documentación incompleta. Le expliqué que no podía dejarlo pasar así, pero no pareció importarle demasiado. Dijo que Silva siempre lo dejaba entrar.\n Cuando le dije que las reglas habían cambiado, se quedó mirándome unos segundos.\n Después me dijo:\n 'Silva también pensó que podía decir que no.'\n Y se fue, no sé qué quiso decir con eso. Odio admitirlo, pero me asustó, no por lo que dijo, sino por la forma en que lo dijo. Como si supiera algo que yo no.\n Revisé dos veces la cerradura antes de irme, quizás estoy exagerando.\n Quizás debería dejar de leer las notas de Silva, pero si él desconfiaba de ese hombre... Creo que yo también debería hacerlo.",
	4: "No sé cómo escribir esto. Esas fotografías...fotografías mías. No de alguien parecido a mí. Mías!. Una de ellas está fechada en 1960. No había nacido. No debería existir.\n También encontré un mapa. Mostraba túneles debajo del parque, algunos conectados con los acantilados. No sabía que existían. Ahora no sé qué creer. Anoche sentí que la garita temblaba. Hoy encontré esos mapas y esas fotografías.\n Todo lo que encontré esta semana parece estar conectado. Silva sabía algo y el agente sabía algo. Y ahora empiezo a pensar que quizás yo también estoy involucrado en esto, aunque no tenga idea de cómo. Tengo miedo no quiero volver mañana.\n Pero tampoco quiero irme. Sé que si me voy, este parque podría perder todos sus animales y sus arboles. Necesito saber qué pasó con Silva y necesito saber quién sacó esas fotografías. Porque si esa foto realmente es de 1960... ¿Quién carajo soy yo?",
	5: "Quinto día. Se terminó la semana. La garita quedó en silencio absoluto tras el paso del Hombre Sin Rostro. El destino del parque y lo que habita en las entrañas del Cerro Chenque quedaron sellados. Cumplí mi deber hasta el último minuto." }

func _ready() -> void:
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)
		
	var summary = GameManager.last_day_summary
	if summary.is_empty():
		# Fallback para pruebas directas de la escena
		summary = {
			"day": GameManager.current_day,
			"base_salary": GameManager.base_salary_per_day,
			"bonuses": 0.0,
			"fines": 0.0,
			"gross_salary": GameManager.base_salary_per_day,
			"expenses_dict": GameManager.family_daily_expenses.get(GameManager.current_day, {"Alimentos": 8000, "Gas": 5000}),
			"total_expenses": 13000.0,
			"net_savings_change": 17000.0,
			"final_family_savings": GameManager.family_savings,
			"parcels_health": GameManager.parcels_health.duplicate(),
			"logs": ["Jornada operativa completada con éxito."],
			"correct": 4,
			"mistakes": 0
		}
	display_summary(summary)

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
Bonos por Infracciones Detectadas: +$%d
Multas por Errores: -$%d
----------------------------------------
Sueldo Neto de Jornada: +$%d

[ GASTOS DEL HOGAR Y FAMILIA ]
%sTotal Gastos Familiares: -$%d
----------------------------------------
Resultado Neto del Día: %s$%d
FONDO FAMILIAR ACUMULADO: $%d""" % [
			int(base), int(bon), int(fin), int(gross),
			exp_lines, int(tot_exp),
			("+" if net_change >= 0 else "-"), int(abs(net_change)),
			int(savings)
		]
		
	# Poblar barras de salud de las 5 parcelas
	if parcels_container:
		for child in parcels_container.get_children():
			child.queue_free()
			
		var parcels = summary.get("parcels_health", {})
		var icons = {
			"Chalet Histórico": "🏛️",
			"Bosque de Lengas": "🌲",
			"Costa y Pingüinera": "🐧",
			"Cerro Chenque y Acantilados": "⛰️",
			"Humedal y Laguna de Aves": "🦆"
		}
		
		for p_name in parcels:
			var p_val = parcels[p_name]
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)
			
			var name_lbl = Label.new()
			name_lbl.text = "%s %s" % [icons.get(p_name, "📍"), p_name]
			name_lbl.custom_minimum_size = Vector2(220, 0)
			name_lbl.add_theme_font_size_override("font_size", 11)
			row.add_child(name_lbl)
			
			var bar = ProgressBar.new()
			bar.value = p_val
			bar.max_value = 100.0
			bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			bar.custom_minimum_size = Vector2(100, 14)
			bar.show_percentage = true
			
			if p_val >= 75.0:
				bar.modulate = Color(0.3, 0.9, 0.4) # Verde
			elif p_val >= 40.0:
				bar.modulate = Color(0.95, 0.8, 0.2) # Amarillo
			else:
				bar.modulate = Color(0.95, 0.2, 0.2) # Rojo
				
			row.add_child(bar)
			parcels_container.add_child(row)
		
	# Poblar logs y eventos narrativos del día
	if logs_container:
		for child in logs_container.get_children():
			child.queue_free()
			
		var notes = summary.get("important_notes", [])
		var logs = summary.get("logs", [])
		
		# Si hay notas importantes del día (Bitácora de Silva, Pescador Raro, etc.)
		for note in notes:
			var n_lbl = Label.new()
			n_lbl.text = "★ " + note
			n_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			n_lbl.add_theme_font_size_override("font_size", 11)
			n_lbl.modulate = Color(1.0, 0.85, 0.4) # Dorado para eventos narrativos
			logs_container.add_child(n_lbl)
			
		if logs.is_empty() and notes.is_empty():
			var l_lbl = Label.new()
			l_lbl.text = "Jornada tranquila sin incidentes mayores."
			l_lbl.add_theme_font_size_override("font_size", 11)
			logs_container.add_child(l_lbl)
		else:
			for log_msg in logs:
				var l_lbl = Label.new()
				l_lbl.text = "• " + log_msg
				l_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				l_lbl.add_theme_font_size_override("font_size", 11)
				if "ERROR" in log_msg:
					l_lbl.modulate = Color(1.0, 0.4, 0.4)
				elif "CORRECTO" in log_msg:
					l_lbl.modulate = Color(0.4, 1.0, 0.6)
				elif "INQUIETUD" in log_msg or "AMENAZA" in log_msg:
					l_lbl.modulate = Color(1.0, 0.65, 0.3)
				elif "DECISIÓN FINAL" in log_msg or "Bitácora" in log_msg:
					l_lbl.modulate = Color(0.7, 0.5, 1.0)
				logs_container.add_child(l_lbl)
	
	# Poblar el Descargo / Reflexión de Mr. Chenque al finalizar el día
	if descargo_header:
		descargo_header.text = "📓 DESCARGO / REFLEXIÓN PERSONAL DE MR. CHENQUE (CIERRE DEL DÍA %d):" % day
	if descargo_text:
		var custom_descargo = summary.get("chenque_descargo", "")
		if custom_descargo.is_empty():
			custom_descargo = chenque_daily_descargos.get(day, "Jornada completada. Sin novedades en la bitácora personal de Mr. Chenque.")
		descargo_text.text = custom_descargo
			
	if continue_btn:
		if is_final_day:
			continue_btn.text = "🏆 VER EVALUACIÓN FINAL DE MR. CHENQUE"
		else:
			continue_btn.text = "➡️ COMENZAR DÍA %d" % (day + 1)

# Método público para insertar o actualizar el descargo dinámicamente
func set_chenque_descargo(text: String) -> void:
	if descargo_text:
		descargo_text.text = text

func get_chenque_descargo_for_day(day_num: int) -> String:
	return chenque_daily_descargos.get(day_num, "")

func _on_continue_pressed() -> void:
	SoundManager.play_sound("click")
	if is_final_day:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		GameManager.advance_to_next_day()
		GameManager.play_day_intro()
