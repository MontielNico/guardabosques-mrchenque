extends Control
class_name MainGame

# Controlador Principal del Puesto de Control en Chalet Huergo (5 Ventanas - Vista 1 y Vista 2)
#
# INTEGRACIÓN CON DayManager:
# MainGame ya NO arma ni recorre la cola de visitantes por su cuenta.
# Se suscribe a las señales de DayManager (Autoload) y reacciona:
#   DayManager.visitor_arrived    -> pintar al visitante en las 5 ventanas
#   DayManager.day_queue_completed -> cerrar el día (GameManager.finish_current_day)
# GameManager sigue intacto: economía familiar, parcelas, día actual (número).

const PatagoniaView = preload("res://scripts/patagonia_view.gd")
const DocumentView = preload("res://scripts/document_view.gd")
const ParkMapView = preload("res://scripts/park_map_view.gd")
const CarTrunkView = preload("res://scripts/car_trunk_view.gd")
const RulebookModal = preload("res://scripts/rulebook_modal.gd")

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

# 4° Ventana Inferior Izquierda: Escritorio y Documentos
@onready var document_view: DocumentView = $VBox/MainLayout/BottomRow/Window4_Desk/Margin/VBox/DocumentView

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

var current_day_config: DayConfig
var current_visitor_profile: VisitorProfile
var current_visitor: Dictionary = {} # adaptado vía VisitorProfile.to_legacy_dict()
var is_processing_decision: bool = false
var is_in_investigation_mode: bool = false

func _ready() -> void:
	# Conexión de botones
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

	# Conexión a la nueva fuente de verdad de la cola de visitantes.
	DayManager.visitor_arrived.connect(_on_visitor_arrived)
	DayManager.day_queue_completed.connect(_on_day_queue_completed)

	# NUEVO: hooks de la Matriz Narrativa. MainGame es hoy el único punto de
	# UI con acceso directo a dialog_text/patagonia_view, así que centralizamos
	# acá las reacciones mínimas. Si más adelante existe un EnvironmentController
	# o un sistema de eventos de historia dedicado, estas mismas señales de
	# DayManager sirven para engancharlo sin tocar nada de esta clase.
	DayManager.environment_flags_applied.connect(_on_environment_flags_applied)
	DayManager.OnLogbookFound.connect(_on_logbook_found)
	DayManager.npc_threat_issued.connect(_on_npc_threat_issued)
	DayManager.narrative_text_event.connect(_on_narrative_text_event)
	DayManager.EndGame_SilvaClue.connect(_on_endgame_silva_clue)
	DayManager.EndGame_FleePost.connect(_on_endgame_flee_post)

	start_day(GameManager.current_day)

func start_day(day_num: int) -> void:
	current_day_config = _get_day_config(day_num)
	is_processing_decision = false

	if day_badge:
		day_badge.text = "📅 DÍA %d / %d: %s" % [day_num, GameManager.MAX_DAYS, current_day_config.season_label.to_upper()]
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % int(GameManager.family_savings)
	if fire_badge_mini:
		fire_badge_mini.text = "🔥 RIESGO FUEGO: " + current_day_config.fire_risk_label
		fire_badge_mini.modulate = current_day_config.fire_risk_color

	_set_investigation_mode(false)

	# A partir de acá, DayManager arma la cola (weighted pool + pity + lore)
	# y avisa por señal cuándo hay un visitante listo. MainGame ya no itera nada.
	DayManager.start_day(current_day_config)

## Reemplaza al viejo _load_visitor(idx). Se dispara solo, vía señal, cada vez
## que hay un visitante nuevo listo para atender.
func _on_visitor_arrived(visitor: VisitorProfile, index: int, total: int) -> void:
	current_visitor_profile = visitor
	current_visitor = visitor.to_legacy_dict()
	is_processing_decision = false
	_set_investigation_mode(false)

	if visitor_counter_lbl:
		visitor_counter_lbl.text = "🚗 VEHÍCULO %d DE %d" % [index + 1, total]
	if feedback_lbl:
		feedback_lbl.text = ""

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

	# 4. Ventana 4: Cargar documentos en escritorio
	if document_view:
		document_view.load_document(visitor.to_legacy_document_dict(GameManager.current_day))

	_enable_decision_buttons(true)

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

	var decision_result = GameManager.record_decision(current_visitor, approved)

	# MODIFICADO: además de la economía (GameManager), le avisamos a
	# DayManager por si esta decisión tiene consecuencias de guion (Día 3
	# Trabajador del Ministerio, Día 5 Hombre sin rostro). Si el visitante
	# no tiene narrative_key, este llamado no hace nada.
	DayManager.report_decision(current_visitor_profile, approved)

	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % int(GameManager.family_savings)

	if approved:
		if patagonia_view:
			patagonia_view.open_barrier_and_pass()
		if dialog_text:
			dialog_text.text = '"Muchas gracias oficial Chenque, que tenga buena jornada."'
			dialog_text.modulate = Color(0.7, 1.0, 0.7)
	else:
		if patagonia_view:
			patagonia_view.reject_and_turn_back()
		if dialog_text:
			dialog_text.text = '"¡Qué barbaridad! Me voy a quejar formalmente..."'
			dialog_text.modulate = Color(1.0, 0.6, 0.6)

	if feedback_lbl:
		if decision_result.get("status") == "CORRECTO":
			feedback_lbl.text = "✔ DECISIÓN CORRECTA (+Bonus)"
			feedback_lbl.modulate = Color(0.25, 0.95, 0.35)
		else:
			feedback_lbl.text = "✖ ERROR EN REVISIÓN (Multa aplicada)"
			feedback_lbl.modulate = Color(0.95, 0.25, 0.25)

	# Actualizar mapa por si hubo impacto ecológico
	if park_map_view:
		park_map_view.update_map()

	# Esperar 2.2 segundos antes del siguiente auto
	await get_tree().create_timer(2.2).timeout

	# Antes: current_visitor_idx += 1; _load_visitor(current_visitor_idx)
	# Ahora: le pedimos el siguiente a DayManager. Si no queda nadie más,
	# DayManager emite day_queue_completed en vez de visitor_arrived.
	DayManager.request_next_visitor()

func _enable_decision_buttons(enabled: bool) -> void:
	if approve_btn:
		approve_btn.disabled = not enabled
	if reject_btn:
		reject_btn.disabled = not enabled
	if inspect_btn:
		inspect_btn.disabled = not enabled
	if back_to_map_btn:
		back_to_map_btn.disabled = not enabled

func _on_rulebook_pressed() -> void:
	if rulebook_modal:
		rulebook_modal.open_rulebook(current_day_config.to_legacy_day_info_dict())

func _end_day() -> void:
	# MODIFICADO: disparamos los hooks de fin de día ANTES de cambiar de
	# escena, para que cualquier estado que dejen (ej. GameManager.player_has_logbook,
	# o un forced_ending_key) ya esté resuelto cuando arranque day_summary.tscn.
	DayManager.fire_end_of_day_hooks(current_day_config.day_number)
	var summary = GameManager.finish_current_day()
	get_tree().change_scene_to_file("res://scenes/day_summary.tscn")

## Reemplaza al chequeo "if idx >= visitors_today.size()" que antes vivía
## adentro de _load_visitor(). Ahora es DayManager el que decide cuándo
## se acabó la cola, y solo nos avisa.
func _on_day_queue_completed(_day_number: int) -> void:
	_end_day()

## Resuelve qué DayConfig usar para un día dado. Prioridad:
##   1. Un .tres armado a mano en res://resources/days/day_N.tres (recomendado
##      para carga de contenido real desde el Inspector de Godot).
##   2. Los ejemplos por código en day_config_examples.gd (hoy solo cubren 1, 3 y 4).
##   3. Una config de emergencia con un visitante dummy, para que el día no
##      rompa el flujo mientras el contenido narrativo todavía no está listo.
func _get_day_config(day_num: int) -> DayConfig:
	var resource_path := "res://resources/days/day_%d.tres" % day_num
	if ResourceLoader.exists(resource_path):
		var loaded = load(resource_path)
		if loaded is DayConfig:
			return loaded

	match day_num:
		1:
			return DayConfigExamples.build_day_1()
		2: # NUEVO
			return DayConfigExamples.build_day_2()
		3:
			return DayConfigExamples.build_day_3()
		4:
			return DayConfigExamples.build_day_4()
		5: # NUEVO
			return DayConfigExamples.build_day_5()
		_:
			push_warning("MainGame: No hay DayConfig real para el Día %d todavía. Usando config de emergencia." % day_num)
			return _build_emergency_day_config(day_num)

# ============================================================
# NUEVO: Handlers de la Matriz Narrativa (hooks de DayManager)
# ============================================================

## NUEVO: Día 3 niebla / Día 4 marea alta -> hoy solo reacciona el fondo
## exterior (patagonia_view). Cuando exista un ParkMapView con variantes de
## marea, se engancha acá mismo con el mismo flags Dictionary.
func _on_environment_flags_applied(flags: Dictionary) -> void:
	if patagonia_view:
		patagonia_view.apply_environment_flags(flags)
	if flags.get("high_tide_anomalies", false):
		# Placeholder narrativo: el mapa/costa todavía no tiene arte de marea
		# alta anómala, pero dejamos el punto de enganche listo y documentado.
		push_warning("MainGame: high_tide_anomalies activo — falta arte de Marea Alta en ParkMapView.")

## NUEVO: Día 1, cierre de turno -> bitácora de Silva. El aviso real lo
## muestra day_summary.gd (la "pantalla de cierre" que pide el diseño);
## acá solo dejamos servida la bandera transitoria que esa pantalla consume.
func _on_logbook_found() -> void:
	GameManager.player_has_logbook = true
	GameManager.logbook_just_found = true

## NUEVO: Día 3, rechazaste al Trabajador del Ministerio -> amenaza inmediata.
func _on_npc_threat_issued(visitor: VisitorProfile) -> void:
	if dialog_text:
		dialog_text.text = '💀 "Esto no termina acá, oficial. Ellos van a saber su nombre."'
		dialog_text.modulate = Color(1.0, 0.3, 0.3)

## NUEVO: evento de texto genérico (hoy solo lo usa el "Inquietud y Miedo"
## del Día 3, pero sirve para cualquier evento de texto futuro sin agregar
## más señales a DayManager). Igual que la bitácora: el texto final se
## muestra en day_summary.gd, acá solo lo dejamos en cola.
func _on_narrative_text_event(_event_key: String, text: String) -> void:
	GameManager.pending_narrative_banner = text
	if feedback_lbl:
		# Flash instantáneo por si alcanza a verse antes del cambio de escena.
		feedback_lbl.text = "😨 " + text
		feedback_lbl.modulate = Color(0.8, 0.85, 1.0)

## NUEVO: Día 5 clímax — le decimos a GameManager qué final quedó forzado
## ANTES de que game_over.gd llame a get_game_ending().
func _on_endgame_silva_clue() -> void:
	GameManager.set_forced_ending("SILVA_CLUE")

func _on_endgame_flee_post() -> void:
	GameManager.set_forced_ending("FLEE_POST")

func _build_emergency_day_config(day_num: int) -> DayConfig:
	var dummy_doc := DocumentData.new()
	dummy_doc.document_type = DocumentData.DocType.DNI
	dummy_doc.holder_name = "Visitante de Prueba"

	var dummy_visitor := VisitorProfile.new()
	dummy_visitor.visitor_id = "placeholder_day_%d" % day_num
	dummy_visitor.visitor_name = "Visitante de Prueba"
	dummy_visitor.tier = VisitorProfile.VisitorTier.SIMPLE
	dummy_visitor.dialog_intro = "(Contenido del Día %d pendiente de cargar)" % day_num
	dummy_visitor.documents = [dummy_doc]
	dummy_visitor.should_be_approved = true

	var day := DayConfig.new()
	day.day_number = day_num
	day.total_visitors = 6
	day.season_label = "Sin definir"
	day.fire_risk_label = "MEDIO"
	day.fire_risk_color = Color.YELLOW
	day.simple_pool = [dummy_visitor]
	day.weight_simple = 1.0
	return day
