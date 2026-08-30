extends Control
class_name MainGame

# Controlador Principal del Puesto de Control en Chalet Huergo (5 Ventanas - Vista 1 y Vista 2)
# Gestiona la lógica de decisiones, progresión de 5 días, eventos y ramificaciones narrativas

const PatagoniaView = preload("res://scripts/patagonia_view.gd")
const DocumentView = preload("res://scripts/document_view.gd")
const ParkMapView = preload("res://scripts/park_map_view.gd")
const CarTrunkView = preload("res://scripts/car_trunk_view.gd")
const RulebookModal = preload("res://scripts/rulebook_modal.gd")
const DocumentModal = preload("res://scripts/document_modal.gd")
const DataDB = preload("res://scripts/data_db.gd")

# Top HUD
@onready var day_badge: Label = $VBox/TopHUD/DayBadge
@onready var visitor_counter_lbl: Label = $VBox/TopHUD/VisitorCounter
@onready var funds_badge: Label = $VBox/TopHUD/FundsBadge
@onready var view_mode_badge: Label = $VBox/TopHUD/ViewModeBadge

# 1° Ventana Superior Izquierda: Oficina y Auto
@onready var patagonia_view: PatagoniaView = $VBox/MainLayout/TopRow/Window1_Office/VBox/PatagoniaView

# 2° Ventana Superior Centro: Visitante, Cara (/public), Diálogo e Interrogatorio
@onready var visitor_avatar_rect: TextureRect = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/ProfileHBox/AvatarContainer/AvatarTexture
@onready var visitor_name_lbl: Label = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/ProfileHBox/InfoVBox/VisitorName
@onready var visitor_car_lbl: Label = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/ProfileHBox/InfoVBox/VisitorCar
@onready var dialog_text: Label = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/DialogScroll/DialogText
@onready var interrogate_btn: Button = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/InterrogateBtn

# 3° Ventana Superior Derecha: Mapa del Parque (Vista 1) o Baúl del Auto (Vista 2)
@onready var park_map_view: ParkMapView = $VBox/MainLayout/TopRow/Window3_MapAndTrunk/ParkMapView
@onready var car_trunk_view: CarTrunkView = $VBox/MainLayout/TopRow/Window3_MapAndTrunk/CarTrunkView

# 4° Ventana Inferior Izquierda: Escritorio de Mr. Chenque y Documento sobre la mesa
@onready var document_view: DocumentView = $VBox/MainLayout/BottomRow/Window4_Desk/DocumentView

# 5° Ventana Inferior Derecha: Decisiones y Reglamento
@onready var approve_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/ApproveBtn
@onready var reject_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/RejectBtn
@onready var inspect_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/InspectBtn
@onready var back_to_map_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/BackToMapBtn
@onready var rulebook_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/RulebookBtn
@onready var feedback_lbl: Label = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/FeedbackLabel
@onready var fire_badge_mini: Label = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/InfoMini/FireBadgeMini

# Modales
@onready var rulebook_modal: RulebookModal = $Modals/RulebookModal
@onready var document_modal: DocumentModal = $Modals/DocumentModal

var day_info: Dictionary = {}
var visitors_today: Array[Dictionary] = []
var current_visitor_idx: int = 0
var current_visitor: Dictionary = {}
var is_processing_decision: bool = false
var is_in_investigation_mode: bool = false
var mandatory_inspection_required: bool = false
var last_collapsed_parcel_name: String = "" # Guarda el nombre de la parcela que acaba de colapsar en esta decisión

func _ready() -> void:
	# Conexión de botones y señales
	if approve_btn:
		approve_btn.pressed.connect(_on_approve_pressed)
	if reject_btn:
		reject_btn.pressed.connect(_on_reject_pressed)
	if inspect_btn:
		inspect_btn.pressed.connect(_on_inspect_pressed)
	if back_to_map_btn:
		back_to_map_btn.pressed.connect(_on_back_to_map_pressed)
	if rulebook_btn:
		rulebook_btn.pressed.connect(_on_rulebook_pressed)
	if interrogate_btn:
		interrogate_btn.pressed.connect(_on_interrogate_pressed)
	if document_view:
		document_view.document_clicked.connect(_on_document_preview_clicked)
	if not GameManager.parcel_collapsed.is_connected(_on_parcel_collapsed):
		GameManager.parcel_collapsed.connect(_on_parcel_collapsed)
		
	start_day(GameManager.current_day)

func _on_parcel_collapsed(parcel_name: String) -> void:
	# Reacción inmediata y visible al colapso de una parcela (0% de conservación)
	SoundManager.play_sound("alarm")
	last_collapsed_parcel_name = parcel_name
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % int(GameManager.family_savings)
	if park_map_view:
		park_map_view.update_map()

func start_day(day_num: int) -> void:
	GameManager.setup_day_parameters(day_num)
	day_info = DataDB.get_day_info(day_num)
	visitors_today = DataDB.get_visitors_for_day(day_num)
	current_visitor_idx = 0
	is_processing_decision = false
	
	var env_tag = ""
	if GameManager.fog_active:
		env_tag = " | 🌫️ NIEBLA ACTIVA"
	elif GameManager.high_tide_active:
		env_tag = " | 🌊 MAREA ALTA"
	elif GameManager.anomalies_active:
		env_tag = " | 🚨 DETECCIÓN DE ANOMALÍAS"
		
	if day_badge:
		var day_dates = ["31/08", "01/09", "02/09", "03/09", "04/09"]
		var day_date = day_dates[day_num - 1] if day_num >= 1 and day_num <= day_dates.size() else ""
		day_badge.text = "📅 DÍA %d / %d: %s | %s%s" % [day_num, GameManager.MAX_DAYS, day_info.get("season", "").to_upper(), day_date, env_tag]
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % int(GameManager.family_savings)
	if fire_badge_mini:
		var risk = day_info.get("fire_risk", "MEDIO")
		fire_badge_mini.text = "🔥 RIESGO FUEGO: " + risk
		fire_badge_mini.modulate = day_info.get("fire_risk_color", Color.YELLOW)
		
	# Día 3: Regla estricta: NO incluir mecánica de inspección de baúl (evaluar palabra vs papel)
	if inspect_btn and day_num == 3:
		inspect_btn.tooltip_text = "Día 3: Validación por diálogo y permiso (Inspección no requerida)"
		
	_set_investigation_mode(false)
	_load_visitor(current_visitor_idx)

func _load_visitor(idx: int) -> void:
	if idx >= visitors_today.size():
		_end_day()
		return
		
	current_visitor = visitors_today[idx]
	is_processing_decision = false
	mandatory_inspection_required = current_visitor.get("event_id", "") == "rare_fisherman"
	_set_investigation_mode(false)
	
	if visitor_counter_lbl:
		visitor_counter_lbl.text = "🚗 VEHÍCULO %d DE %d" % [idx + 1, visitors_today.size()]
	if feedback_lbl:
		feedback_lbl.text = ""
	
	if mandatory_inspection_required:
		if feedback_lbl:
			feedback_lbl.text = "🔎 INSPECCIÓN OBLIGATORIA: Revisa el pescado anómalo antes de decidir."
			feedback_lbl.modulate = Color(1.0, 0.8, 0.32)
			feedback_lbl.visible = true
		_enable_decision_buttons(false)
		
	# 1. Ventana 1: Auto y exterior
	if patagonia_view:
		patagonia_view.set_visitor(current_visitor)
	SoundManager.play_sound("car_engine")
	
	# 2. Ventana 2: Avatar del visitante desde /public, diálogo y datos
	_load_visitor_avatar(current_visitor.get("avatar_file", ""))
	if visitor_name_lbl:
		visitor_name_lbl.text = current_visitor.get("name", "Visitante")
	if visitor_car_lbl:
		visitor_car_lbl.text = "🚗 " + current_visitor.get("car_name", "Vehículo")
	if dialog_text:
		dialog_text.text = '"' + current_visitor.get("dialog_intro", "Buenas tardes oficial.") + '"'
		dialog_text.modulate = Color(0.92, 0.94, 0.96)
		
	# 3. Ventana 3: Actualizar datos de baúl y mapa
	if park_map_view:
		park_map_view.update_map()
	if car_trunk_view:
		car_trunk_view.set_visitor(current_visitor)
		
	# 4. Ventana 4: Cargar documentos en escritorio de madera
	if document_view:
		var doc_data = current_visitor.get("doc", {})
		document_view.load_document(doc_data, current_visitor)
		
	# Si el modal de detalle del documento estaba abierto, actualizarlo con el nuevo visitante
	if document_modal and document_modal.visible:
		var doc_data = current_visitor.get("doc", {})
		document_modal.open_document(doc_data, current_visitor)
		
	_enable_decision_buttons(true)

func _on_document_preview_clicked(doc_data: Dictionary) -> void:
	if document_modal:
		document_modal.open_document(doc_data, current_visitor)

func _load_visitor_avatar(avatar_filename: String) -> void:
	if not visitor_avatar_rect or avatar_filename.is_empty():
		return
		
	var possible_paths = [
		"res://public/" + avatar_filename,
		"res://public/" + avatar_filename.replace("Leña", "Lena").replace("leña", "lena"),
		"res://public/" + avatar_filename.replace("Lena", "Leña").replace("lena", "leña")
	]
	
	var loaded_tex: Texture2D = null
	for p in possible_paths:
		if ResourceLoader.exists(p):
			var res = load(p)
			if res is Texture2D:
				loaded_tex = res
				break
		if FileAccess.file_exists(p):
			var img = Image.load_from_file(p)
			if img:
				loaded_tex = ImageTexture.create_from_image(img)
				break
				
	if loaded_tex:
		visitor_avatar_rect.texture = loaded_tex
	else:
		push_warning("No se pudo cargar la imagen de avatar: " + avatar_filename)

func _set_investigation_mode(enabled: bool) -> void:
	is_in_investigation_mode = enabled
	
	# Ventana 2: Botón de interrogar visible solo en investigación
	if interrogate_btn:
		interrogate_btn.visible = enabled
		if enabled:
			interrogate_btn.modulate = Color(1.0, 0.9, 0.4)
			
	# Ventana 3: Alternar entre Mapa (Vista 1) y Baúl (Vista 2)
	if park_map_view:
		park_map_view.visible = not enabled
		if not enabled:
			park_map_view.update_map()
	if car_trunk_view:
		car_trunk_view.visible = enabled
		if enabled:
			car_trunk_view.set_visitor(current_visitor)
			
	# Ventana 5: Botones
	if inspect_btn:
		inspect_btn.visible = not enabled
	if back_to_map_btn:
		back_to_map_btn.visible = enabled
		
	if view_mode_badge:
		if enabled:
			view_mode_badge.text = "🔍 VISTA 2: INVESTIGACIÓN EN CURSO"
			view_mode_badge.modulate = Color(1.0, 0.75, 0.3)
		else:
			view_mode_badge.text = "📋 VISTA 1: CONTROL PRINCIPAL"
			view_mode_badge.modulate = Color(0.6, 0.9, 1.0)

func _on_inspect_pressed() -> void:
	SoundManager.play_sound("paper")
	_set_investigation_mode(true)
	if mandatory_inspection_required:
		mandatory_inspection_required = false
		if feedback_lbl:
			feedback_lbl.text = "✅ Pescado anómalo inspeccionado: ahora puedes decidir si confiscarlo o no."
			feedback_lbl.modulate = Color(0.7, 1.0, 0.7)
			feedback_lbl.visible = true
		_enable_decision_buttons(true)

func _on_back_to_map_pressed() -> void:
	SoundManager.play_sound("click")
	_set_investigation_mode(false)

func _on_interrogate_pressed() -> void:
	SoundManager.play_sound("paper")
	if dialog_text and not current_visitor.is_empty():
		var inter_dialog = current_visitor.get("dialog_interrogate", "No tengo nada que ocultar oficial.")
		dialog_text.text = '💬 "' + inter_dialog + '"'
		dialog_text.modulate = Color(1.0, 0.95, 0.7)

func _on_approve_pressed() -> void:
	if is_processing_decision:
		return
	_make_decision(true)

func _on_reject_pressed() -> void:
	if is_processing_decision:
		return
	_make_decision(false)

func _make_decision(approved: bool) -> void:
	is_processing_decision = true
	_enable_decision_buttons(false)
	
	if document_view:
		document_view.apply_stamp(approved)
	if document_modal and document_modal.visible:
		document_modal.apply_stamp(approved)
		
	var event_id = current_visitor.get("event_id", "")
	var decision_result = GameManager.record_decision(current_visitor, approved)
	
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % int(GameManager.family_savings)
	
	if event_id == "rare_fisherman":
		if dialog_text:
			if approved:
				dialog_text.text = '"No confiscaste el pescado anómalo. El pescador se marcha sin discutir y la marea vuelve a cerrar la costa."'
				dialog_text.modulate = Color(0.8, 0.95, 0.8)
			else:
				dialog_text.text = '"Confiscaste el pescado anómalo. El pescador se va en silencio y el acantilado sigue respirando bajo la niebla."'
				dialog_text.modulate = Color(1.0, 0.82, 0.52)
		if feedback_lbl:
			feedback_lbl.text = "⚖️ INSPECCIÓN NARRATIVA • SIN CONSECUENCIA"
			feedback_lbl.modulate = Color(0.8, 0.85, 1.0)
			feedback_lbl.visible = true
			feedback_lbl.scale = Vector2(1.08, 1.08)
			feedback_lbl.pivot_offset = feedback_lbl.size * 0.5
			var feed_tween = create_tween()
			feed_tween.set_parallel(true)
			feed_tween.tween_property(feedback_lbl, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			feed_tween.tween_property(feedback_lbl, "modulate:a", 1.0, 0.12)
			feed_tween.tween_property(feedback_lbl, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_QUAD)
		await get_tree().create_timer(2.2).timeout
		current_visitor_idx += 1
		_load_visitor(current_visitor_idx)
		return
		
	if approved:
		if patagonia_view:
			patagonia_view.open_barrier_and_pass()
		if dialog_text:
			if event_id == "day3_midnight_worker":
				dialog_text.text = '"...El camión avanza en la niebla sin luces traseras. Un escalofrío te recorre la espalda..."'
				dialog_text.modulate = Color(1.0, 0.85, 0.3)
			elif event_id == "day5_faceless_man":
				dialog_text.text = '"Sellaste la entrada hacia los túneles. El legado de Silva continuará contigo bajo el cerro..."'
				dialog_text.modulate = Color(0.7, 0.5, 1.0)
			else:
				dialog_text.text = '"Muchas gracias oficial Chenque, que tenga buena jornada."'
				dialog_text.modulate = Color(0.7, 1.0, 0.7)
	else:
		if patagonia_view:
			patagonia_view.reject_and_turn_back()
		if dialog_text:
			if event_id == "day3_midnight_worker":
				dialog_text.text = '"Silva pensó que podía decir que no en plena niebla. Mirá cómo terminó... Te vas a arrepentir, Chenque."'
				dialog_text.modulate = Color(1.0, 0.3, 0.3)
			elif event_id == "day5_faceless_man":
				dialog_text.text = '"Clausuraste la garita. La barrera permanece baja, salvando la superficie del Parque Chalet Huergo."'
				dialog_text.modulate = Color(0.4, 0.9, 1.0)
			else:
				dialog_text.text = '"¡Qué barbaridad! Me voy a quejar formalmente..."'
				dialog_text.modulate = Color(1.0, 0.6, 0.6)
			
	if feedback_lbl:
		if decision_result.get("status") == "CORRECTO":
			feedback_lbl.text = "✔ SELLO CORRECTO • BONO APLICADO"
			feedback_lbl.modulate = Color(0.22, 0.9, 0.38)
		else:
			feedback_lbl.text = "✖ INCONSISTENCIA DETECTADA • MULTA"
			feedback_lbl.modulate = Color(0.96, 0.32, 0.32)
		feedback_lbl.visible = true
		feedback_lbl.scale = Vector2(1.08, 1.08)
		feedback_lbl.pivot_offset = feedback_lbl.size * 0.5
		var feed_tween = create_tween()
		feed_tween.set_parallel(true)
		feed_tween.tween_property(feedback_lbl, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		feed_tween.tween_property(feedback_lbl, "modulate:a", 1.0, 0.12)
		feed_tween.tween_property(feedback_lbl, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_QUAD)
	
	# Actualizar mapa por si hubo impacto ecológico
	if park_map_view:
		park_map_view.update_map()

	# Si esta decisión provocó el colapso de una parcela, mostrarlo en primer plano
	if last_collapsed_parcel_name != "":
		if dialog_text:
			dialog_text.text = "💀 ¡%s ha colapsado por completo! La Administración de Parques Nacionales aplicó una multa de emergencia de -$%d." % [last_collapsed_parcel_name, int(GameManager.parcel_collapse_penalty)]
			dialog_text.modulate = Color(1.0, 0.25, 0.25)
		if feedback_lbl:
			feedback_lbl.text = "💀 COLAPSO ECOLÓGICO • MULTA DE EMERGENCIA"
			feedback_lbl.modulate = Color(1.0, 0.2, 0.2)
		last_collapsed_parcel_name = ""

	# Esperar 2.2 segundos antes del siguiente auto
	await get_tree().create_timer(2.2).timeout
	current_visitor_idx += 1
	_load_visitor(current_visitor_idx)

func _enable_decision_buttons(enabled: bool) -> void:
	var final_enabled = enabled
	if current_visitor.get("event_id", "") == "rare_fisherman" and mandatory_inspection_required:
		final_enabled = false
	if approve_btn:
		approve_btn.disabled = not final_enabled
	if reject_btn:
		reject_btn.disabled = not final_enabled
	if inspect_btn:
		inspect_btn.disabled = not enabled
	if back_to_map_btn:
		back_to_map_btn.disabled = not enabled

func _on_rulebook_pressed() -> void:
	if rulebook_modal:
		rulebook_modal.open_rulebook(day_info)

func _end_day() -> void:
	var summary = GameManager.finish_current_day()
	get_tree().change_scene_to_file("res://scenes/day_summary.tscn")
