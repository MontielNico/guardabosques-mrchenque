extends Control
class_name DaySummaryScreen

# Pantalla de Resumen de Fin de Día con bitácora cinematográfica y notas desbloqueables.

@onready var title_label: Label = $Panel/Margin/VBox/Header/TitleLabel
@onready var stats_label: Label = $Panel/Margin/VBox/Content/LeftCol/StatsBox/StatsLabel
@onready var finance_label: Label = $Panel/Margin/VBox/Content/LeftCol/FinanceBox/FinanceLabel
@onready var parcels_container: VBoxContainer = $Panel/Margin/VBox/Content/RightCol/ParcelsBox/VBox/ParcelsList
@onready var logs_container: VBoxContainer = $Panel/Margin/VBox/Content/RightCol/LogsBox/VBox/LogsScroll/LogsList
@onready var continue_btn: Button = $Panel/Margin/VBox/Footer/ContinueButton

var is_final_day: bool = false
var story_label: RichTextLabel
var notes_container: VBoxContainer
var evidence_container: VBoxContainer
var summary_data: Dictionary = {}
var typewriter_active: bool = false

func _ready() -> void:
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)
	
	_build_cinematic_panels()
	
	var data = GameManager.last_day_summary if not GameManager.last_day_summary.is_empty() else GameManager.finish_current_day()
	display_summary(data)

func _build_cinematic_panels() -> void:
	var vbox: VBoxContainer = $Panel/Margin/VBox
	if not vbox:
		return
	
	if story_label == null:
		var story_panel = PanelContainer.new()
		story_panel.name = "StoryPanel"
		story_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var story_style = StyleBoxFlat.new()
		story_style.bg_color = Color(0.08, 0.12, 0.16, 0.95)
		story_style.corner_radius_top_left = 10
		story_style.corner_radius_top_right = 10
		story_style.corner_radius_bottom_right = 10
		story_style.corner_radius_bottom_left = 10
		story_style.border_width_left = 1
		story_style.border_width_right = 1
		story_style.border_width_top = 1
		story_style.border_width_bottom = 1
		story_style.border_color = Color(0.38, 0.72, 0.62, 0.8)
		story_panel.add_theme_stylebox_override("panel", story_style)
		
		var story_margin = MarginContainer.new()
		story_margin.add_theme_constant_override("margin_left", 16)
		story_margin.add_theme_constant_override("margin_top", 12)
		story_margin.add_theme_constant_override("margin_right", 16)
		story_margin.add_theme_constant_override("margin_bottom", 12)
		story_panel.add_child(story_margin)
		
		story_label = RichTextLabel.new()
		story_label.name = "StoryLabel"
		story_label.bbcode_enabled = true
		story_label.fit_content = true
		story_label.scroll_active = false
		story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		story_label.custom_minimum_size = Vector2(0, 150)
		story_label.add_theme_font_size_override("normal_font_size", 14)
		story_label.add_theme_color_override("default_color", Color(0.9, 0.95, 0.8))
		story_margin.add_child(story_label)
		vbox.add_child(story_panel)
		vbox.move_child(story_panel, vbox.get_child_count() - 2)
	
	if notes_container == null:
		notes_container = VBoxContainer.new()
		notes_container.name = "NotesContainer"
		notes_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		notes_container.custom_minimum_size = Vector2(0, 120)
		vbox.add_child(notes_container)
		vbox.move_child(notes_container, vbox.get_child_count() - 2)
	
	if evidence_container == null:
		evidence_container = VBoxContainer.new()
		evidence_container.name = "EvidenceContainer"
		evidence_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		evidence_container.custom_minimum_size = Vector2(0, 90)
		vbox.add_child(evidence_container)
		vbox.move_child(evidence_container, vbox.get_child_count() - 2)

func _clear_children(node: Node) -> void:
	if not node:
		return
	for child in node.get_children():
		child.queue_free()

func display_summary(summary: Dictionary) -> void:
	summary_data = summary
	SoundManager.play_sound("coin")
	var day = summary.get("day", 1)
	is_final_day = (day >= GameManager.MAX_DAYS)
	
	if title_label:
		title_label.text = "RESUMEN DEL DÍA %d - CIERRE DE JORNADA" % day
	
	var correct = summary.get("correct", 0)
	var mistakes = summary.get("mistakes", 0)
	var visitors_seen = summary.get("visitors_seen", 0)
	var visitors_passed = summary.get("visitors_passed", 0)
	var visitors_rejected = summary.get("visitors_rejected", 0)
	var harmful_visits = summary.get("harmful_visits", 0)
	var objects_found = summary.get("objects_found", [])
	var important_notes = summary.get("important_notes", [])
	
	if stats_label:
		stats_label.text = "• Visitantes revisados: %d\n• Ingresos correctos: %d\n• Error en la revisión: %d\n• Amenazas que pasaron: %d" % [
			visitors_seen,
			correct,
			mistakes,
			harmful_visits
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
Bonos por patrullaje: +$%d
Multas por errores: -$%d
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
	
	# Estado de parcelas
	if parcels_container:
		_clear_children(parcels_container)
		var parcels = summary.get("parcels_health", {})
		for p_name in parcels:
			var p_val = parcels[p_name]
			var row = HBoxContainer.new()
			var name_lbl = Label.new(); name_lbl.text = p_name; name_lbl.custom_minimum_size = Vector2(180, 0); name_lbl.add_theme_font_size_override("font_size", 13)
			var bar = ProgressBar.new(); bar.value = p_val; bar.max_value = 100.0; bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL; bar.custom_minimum_size = Vector2(120, 20); bar.show_percentage = true
			if p_val >= 75.0:
				bar.modulate = Color(0.3, 0.9, 0.4)
			elif p_val >= 40.0:
				bar.modulate = Color(0.95, 0.8, 0.2)
			else:
				bar.modulate = Color(0.95, 0.2, 0.2)
			row.add_child(name_lbl); row.add_child(bar); parcels_container.add_child(row)
	
	# Bitácora principal cinematográfica
	var final_log = _build_cinematic_log(summary)
	if story_label:
		story_label.text = ""
		_typewriter_story(final_log)
	
	# Notas importantes desbloqueadas
	if notes_container:
		_clear_children(notes_container)
		var notes_title = Label.new()
		notes_title.text = "🧾 NOTAS IMPORTANTES DEL DÍA"
		notes_title.add_theme_font_size_override("font_size", 13)
		notes_title.modulate = Color(0.9, 0.85, 0.5)
		notes_container.add_child(notes_title)
		if important_notes.is_empty():
			var empty_note = Label.new(); empty_note.text = "Sin notas relevantes grabadas en el archivo del día."; empty_note.modulate = Color(0.7, 0.8, 0.85); notes_container.add_child(empty_note)
		else:
			for i in range(important_notes.size()):
				var card = _make_note_card(important_notes[i], i)
				notes_container.add_child(card)
	
	# Evidencia de objetos hallados
	if evidence_container:
		_clear_children(evidence_container)
		var object_title = Label.new(); object_title.text = "📦 OBJETOS Y EVIDENCIAS RECOGIDAS"; object_title.add_theme_font_size_override("font_size", 13); object_title.modulate = Color(0.7, 0.9, 0.8); evidence_container.add_child(object_title)
		if objects_found.is_empty():
			var empty_obj = Label.new(); empty_obj.text = "No se encontraron elementos sospechosos durante la jornada."; empty_obj.modulate = Color(0.7, 0.8, 0.85); evidence_container.add_child(empty_obj)
		else:
			var row = HBoxContainer.new(); row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			for item in objects_found:
				var badge = PanelContainer.new(); badge.custom_minimum_size = Vector2(180, 32); badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				var style = StyleBoxFlat.new(); style.bg_color = Color(0.14, 0.28, 0.24, 0.8); style.corner_radius_top_left = 8; style.corner_radius_top_right = 8; style.corner_radius_bottom_right = 8; style.corner_radius_bottom_left = 8; badge.add_theme_stylebox_override("panel", style)
				var label = Label.new(); label.text = "• " + str(item); label.add_theme_font_size_override("font_size", 12); label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; badge.add_child(label)
				row.add_child(badge)
			evidence_container.add_child(row)
	
	# Logs del día bajo la vista tradicional
	if logs_container:
		_clear_children(logs_container)
		var logs = summary.get("logs", [])
		if logs.is_empty():
			var l_lbl = Label.new(); l_lbl.text = "Jornada tranquila sin incidentes mayores."; logs_container.add_child(l_lbl)
		else:
			for log_msg in logs:
				var l_lbl = Label.new(); l_lbl.text = "• " + log_msg; l_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; l_lbl.add_theme_font_size_override("font_size", 12)
				if "ERROR" in log_msg: l_lbl.modulate = Color(1.0, 0.4, 0.4)
				elif "RECHAZO" in log_msg or "INGRESO" in log_msg: l_lbl.modulate = Color(0.4, 1.0, 0.6)
				logs_container.add_child(l_lbl)
	
	if continue_btn:
		if is_final_day:
			continue_btn.text = "🏆 VER EVALUACIÓN FINAL DE MR. CHENQUE"
		else:
			continue_btn.text = "➡️ COMENZAR DÍA %d" % (day + 1)

func _make_note_card(note_text: String, idx: int) -> PanelContainer:
	var card = PanelContainer.new()
	var style = StyleBoxFlat.new(); style.bg_color = Color(0.12, 0.18, 0.2, 0.92); style.corner_radius_top_left = 8; style.corner_radius_top_right = 8; style.corner_radius_bottom_right = 8; style.corner_radius_bottom_left = 8; style.border_width_left = 1; style.border_width_right = 1; style.border_width_top = 1; style.border_width_bottom = 1; style.border_color = Color(0.6, 0.75, 0.9, 0.8); card.add_theme_stylebox_override("panel", style)
	var margin = MarginContainer.new(); margin.add_theme_constant_override("margin_left", 10); margin.add_theme_constant_override("margin_top", 8); margin.add_theme_constant_override("margin_right", 10); margin.add_theme_constant_override("margin_bottom", 8)
	var label = Label.new(); label.text = "%d. %s" % [idx + 1, note_text]; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.add_theme_font_size_override("font_size", 12)
	if "⚠️" in note_text:
		label.modulate = Color(1.0, 0.7, 0.4)
	elif "✅" in note_text:
		label.modulate = Color(0.6, 1.0, 0.7)
	margin.add_child(label); card.add_child(margin); return card

func _build_cinematic_log(summary: Dictionary) -> String:
	var day = summary.get("day", 1)
	var visitors_seen = summary.get("visitors_seen", 0)
	var visitors_passed = summary.get("visitors_passed", 0)
	var visitors_rejected = summary.get("visitors_rejected", 0)
	var harmful_visits = summary.get("harmful_visits", 0)
	var mistakes = summary.get("mistakes", 0)
	var correct = summary.get("correct", 0)
	var objects = summary.get("objects_found", [])
	var damage_count = 0
	var parcel_info = summary.get("parcels_damage_tags", {})
	for parcel in parcel_info:
		damage_count += int(parcel_info[parcel].size())
	var object_text = "ningún objeto sospechoso."
	if not objects.is_empty():
		object_text = ", ".join(objects)
	return "[b]BITÁCORA DE CONTROL - DÍA %d[/b]\n" % day + \
		"Se revisaron %d vehículos. %d pasaron con documentación válida, %d fueron rechazados y %d decisiones dejaron daño al parque.\n" % [visitors_seen, visitors_passed, visitors_rejected, harmful_visits] + \
		"El balance operativo mostró %d decisiones correctas y %d errores de valoración.\n" % [correct, mistakes] + \
		"Se detectaron %d señales de deterioro en las parcelas y se registraron los siguientes elementos: %s\n" % [damage_count, object_text] + \
		"Los apuntes del turno quedan archivados como evidencia y se desbloquean en esta misma pantalla para revisión posterior."

func _typewriter_story(full_text: String) -> void:
	if not story_label:
		return
	if typewriter_active:
		return
	typewriter_active = true
	var current = ""
	story_label.text = ""
	for i in range(full_text.length()):
		current += full_text[i]
		story_label.text = "[color=#dfe9cc]" + current + "[/color]"
		await get_tree().create_timer(0.02).timeout
	story_label.text = "[color=#dfe9cc]" + full_text + "[/color]"
	typewriter_active = false

func _on_continue_pressed() -> void:
	SoundManager.play_sound("click")
	if is_final_day:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		GameManager.advance_to_next_day()
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")
