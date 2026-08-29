extends Resource
class_name VisitorProfile

## VisitorProfile
## Unidad atómica que consume el VisitorSpawner. Define diálogo, documentos,
## la verdad de si debería pasar o no, y el impacto si el jugador se equivoca.

enum VisitorTier {
	SIMPLE,
	MEDIUM,
	COMPLEX,
	LORE_ANOMALY
}

@export var visitor_id: String = "" # único, ej: "day3_fotografo_nocturno"
@export var visitor_name: String = ""
@export var tier: VisitorTier = VisitorTier.SIMPLE

@export_multiline var dialog_intro: String = "Buenas tardes, oficial."
@export_multiline var dialog_interrogate: String = "No tengo nada que ocultar, oficial."

@export var documents: Array[DocumentData] = []

## Peso relativo DENTRO del pool de su propio tier (Weighted Random Pool).
## Más alto = más chance de ser elegido frente a otros del mismo tier.
@export_range(0.1, 10.0, 0.1) var spawn_weight: float = 1.0

@export_group("Resolución (ground truth)")
@export var should_be_approved: bool = true
@export var rejection_reasons: Array[String] = []
## { "Nombre Parcela": {"damage": float, "tag": String} } — mismo formato
## que ya consume GameManager.apply_parcel_damage().
@export var parcel_impact: Dictionary = {}

@export_group("Presentación (integración con Views existentes)")
@export var avatar_file: String = ""
@export var car_name: String = "Vehículo"

@export_group("Datos de mesa (Ventana 4 - document_view.gd)")
## Estos no son parte de ningún DocumentData puntual: son datos "del trámite"
## que document_view.gd muestra como casillas separadas.
@export var authorized_passengers: int = 1
@export var job_permit_label: String = "Ninguno (Particular)"
@export var fire_permit: bool = false
@export var fishing_permit: bool = false

@export_group("Baúl / Auto (Ventana 3 - car_trunk_view.gd)")
## NUEVO: pasajeros reales a bordo. -1 = "coincide con authorized_passengers"
## (caso normal, sin discrepancia). Poné un valor explícito solo cuando
## querés generar la discrepancia sospechosa que ya detecta car_trunk_view.
@export var actual_passengers: int = -1
## NUEVO: objetos "normales" que aparecen en el baúl al abrirlo.
@export var car_items: Array[String] = []
## NUEVO: objetos RAROS de lore que se agregan a la inspección del baúl
## (ej. Día 2: "Espécimen Marino Mutado", Día 4: "Foto de Mr. Chenque de
## 1920", "Mapa de túneles del Chenque"). Separado de car_items para que
## el diseñador identifique de un vistazo qué es flavor y qué es pista.
@export var hidden_items: Array[String] = []

@export_group("Narrativa / Matriz de Días")
## NUEVO: identificador estable usado por DayManager para reconocer visitantes
## "especiales" (inyecciones obligatorias) sin depender de comparar visitor_id
## a mano en cada lugar del código. Vacío = visitante sin peso narrativo especial.
## Valores usados por la matriz narrativa actual:
##   "day2_pescador_raro", "day3_trabajador_ministerio", "day5_hombre_sin_rostro"
@export var narrative_key: String = ""

func get_primary_document() -> DocumentData:
	return documents[0] if not documents.is_empty() else null

func get_document_by_type(doc_type: DocumentData.DocType) -> DocumentData:
	for d in documents:
		if d.document_type == doc_type:
			return d
	return null

## Adaptador de compatibilidad hacia atrás: arma el mismo Dictionary que hoy
## esperan main_game.gd / patagonia_view.gd / car_trunk_view.gd, para poder
## enchufar este sistema nuevo sin reescribir esas Views en medio de la jam.
func to_legacy_dict() -> Dictionary:
	return {
		"name": visitor_name,
		"car_name": car_name,
		"dialog_intro": dialog_intro,
		"dialog_interrogate": dialog_interrogate,
		"avatar_file": avatar_file,
		"should_pass": should_be_approved,
		"rejection_reasons": rejection_reasons,
		"parcel_impact": parcel_impact,
		# MODIFICADO: antes este dict no traía nada de baúl (car_trunk_view.gd
		# quedaba leyendo defaults vacíos). Ahora sí lo completamos, y de paso
		# mezclamos los hidden_items propios del visitante con los que puedan
		# venir cargados en cualquiera de sus DocumentData.
		"declared_passengers": authorized_passengers,
		"actual_passengers": actual_passengers if actual_passengers >= 0 else authorized_passengers,
		"car_items": car_items + get_all_hidden_items()
	}

## NUEVO: junta los hidden_items propios con los de cada DocumentData
## (un objeto raro puede haber sido definido "en el documento" en vez de
## "en el visitante" — ver DocumentData.hidden_items). Se usa para armar
## el baúl (Ventana 3) y también queda disponible para lógica de detección
## de lore en la UI de investigación si hace falta más adelante.
func get_all_hidden_items() -> Array[String]:
	var result: Array[String] = []
	result.append_array(hidden_items)
	for doc in documents:
		if doc and not doc.hidden_items.is_empty():
			result.append_array(doc.hidden_items)
	return result

## Adaptador exacto para document_view.gd (Ventana 4). Combina el/los
## DocumentData del visitante con los datos de mesa (pasajeros, permisos)
## en el mismo formato que antes armaba data_db.gd a mano.
##
## Prioridad para decidir cuál es "el" documento de ingreso a mostrar:
## Pase Diario > Permiso de Actividad > lo que haya (ej: solo DNI).
func to_legacy_document_dict(current_day: int) -> Dictionary:
	var entry_doc := get_document_by_type(DocumentData.DocType.PASE_DIARIO)
	if entry_doc == null:
		entry_doc = get_document_by_type(DocumentData.DocType.PERMISO_ACTIVIDAD)
	if entry_doc == null:
		entry_doc = get_primary_document()

	var dni_doc := get_document_by_type(DocumentData.DocType.DNI)
	if dni_doc == null:
		dni_doc = entry_doc

	var permiso_doc := get_document_by_type(DocumentData.DocType.PERMISO_ACTIVIDAD)

	if entry_doc == null:
		push_warning("VisitorProfile '%s' no tiene ningún DocumentData cargado." % visitor_id)
		return {}

	return {
		"type": DocumentData.type_display_name(entry_doc.document_type),
		"name": dni_doc.holder_name if dni_doc else visitor_name,
		"dni": dni_doc.document_number if dni_doc else "00.000.000",
		"date": entry_doc.expiration_date_display,
		"is_expired": entry_doc.is_expired(current_day),
		"purpose": DocumentData.activity_display_name(permiso_doc.authorized_activity) if permiso_doc else "Paseo",
		"passengers": authorized_passengers,
		"job_permit": job_permit_label,
		"fire_permit": fire_permit,
		"fishing_permit": fishing_permit
	}
