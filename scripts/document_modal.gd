extends PanelContainer
class_name DocumentModal

# Modal interactivo para inspección detallada del documento.png del visitante

signal closed

@onready var doc_title: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/Header/DocTitle
@onready var name_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/Grid/NameVal
@onready var dni_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/Grid/DniVal
@onready var date_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/Grid/DateVal
@onready var purpose_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/Grid/PurposeVal
@onready var people_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/Grid/PeopleVal
@onready var job_permit_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/Grid/JobPermitVal
@onready var fire_permit_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/PermitsBox/FirePermitVal
@onready var fishing_permit_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/PermitsBox/FishingPermitVal
@onready var notes_val: Label = $Margin/VBox/Content/PaperPanel/Margin/VBox/NotesVal
@onready var close_btn: Button = $Margin/VBox/Header/CloseButton

func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)

func open_document(doc_data: Dictionary, visitor_data: Dictionary = {}) -> void:
	visible = true
	SoundManager.play_sound("paper")
	
	if doc_title:
		doc_title.text = "🏛️ " + doc_data.get("type", "Pase de Ingreso Diario").to_upper()
	if name_val:
		name_val.text = doc_data.get("name", "Desconocido")
	if dni_val:
		dni_val.text = doc_data.get("dni", "00.000.000")
	if date_val:
		var dt = doc_data.get("date", "28/11/2026")
		var expired = doc_data.get("is_expired", false)
		if expired:
			date_val.text = dt + " (⚠️ VENCIDO - NO AUTORIZADO)"
			date_val.modulate = Color(0.9, 0.15, 0.15)
		else:
			date_val.text = dt + " (Vigente y Autorizado)"
			date_val.modulate = Color(0.12, 0.55, 0.18)
	if purpose_val:
		purpose_val.text = doc_data.get("purpose", "Paseo y Recreación")
	if people_val:
		var decl = doc_data.get("passengers", 1)
		var actual = visitor_data.get("actual_passengers", decl)
		people_val.text = "%d persona(s) declarada(s) en documento" % decl
		if actual != decl:
			people_val.text += " (⚠️ Reales a bordo: %d)" % actual
	if job_permit_val:
		var job = doc_data.get("job_permit", "Ninguno (Particular)")
		job_permit_val.text = job
		if "Ninguno" in job:
			job_permit_val.modulate = Color(0.35, 0.3, 0.25)
		else:
			job_permit_val.modulate = Color(0.08, 0.35, 0.65)
		
	if fire_permit_val:
		var has_fire = doc_data.get("fire_permit", false)
		fire_permit_val.text = "HABILITADO PARA ENCENDER FUEGO ✔️" if has_fire else "PROHIBIDO ENCENDER FUEGO ❌"
		fire_permit_val.modulate = Color(0.1, 0.6, 0.2) if has_fire else Color(0.85, 0.15, 0.15)
		
	if fishing_permit_val:
		var has_fishing = doc_data.get("fishing_permit", false)
		fishing_permit_val.text = "HABILITADO PARA PESCA DEPORTIVA ✔️" if has_fishing else "PROHIBIDA LA PESCA DEPORTIVA ❌"
		fishing_permit_val.modulate = Color(0.1, 0.6, 0.2) if has_fishing else Color(0.85, 0.15, 0.15)
		
	if notes_val:
		var notes = "• Presentar este pase ante las autoridades del Parque Nacional Chalet Huergo.\n• Prohibido arrojar residuos o dañar la flora/fauna nativa de la costa y cerro."
		notes_val.text = notes

func _on_close_pressed() -> void:
	SoundManager.play_sound("click")
	visible = false
	closed.emit()
