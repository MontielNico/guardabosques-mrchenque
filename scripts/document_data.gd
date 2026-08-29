extends Resource
class_name DocumentData

## DocumentData
## Representa UN documento que un visitante entrega en la ventanilla
## (DNI, Pase Diario o Permiso de Actividad). Un VisitorProfile puede
## llevar varios (ej: DNI + Pase Diario a la vez).

enum DocType {
	DNI,
	PASE_DIARIO,
	PERMISO_ACTIVIDAD
}

## Actividades que un Permiso de Actividad puede autorizar dentro del parque.
enum Activity {
	NINGUNA,
	TRAVESIA_SENDERISMO,
	PESCA_DEPORTIVA,
	FOTOGRAFIA_PROFESIONAL,
	INVESTIGACION_CIENTIFICA,
	MANTENIMIENTO_PARQUE
}

@export var document_type: DocType = DocType.DNI
@export var holder_name: String = ""
@export var document_number: String = ""

## Fecha tal cual aparece impresa en el papel (solo flavor/narrativa).
@export var expiration_date_display: String = "" # Ej: "15/07/1978"

## Día de juego (1-5) hasta el cual el documento es válido para la LÓGICA real.
## -1 = no vence durante la partida.
@export var expires_on_day: int = -1

@export var authorized_activity: Activity = Activity.NINGUNA

## Firma / autoridad emisora. Clave para detectar falsificaciones
## (ej: un documento "firmado" por Silva después de su desaparición).
@export var signed_by: String = ""

## FLAG CENTRAL DE LORE. Marca documentación de origen desconocido/anómalo.
## El jugador no tiene forma "oficial" de saber qué significa hasta que
## la trama se lo revela — es la semilla de sospecha del misterio de Silva.
@export var has_black_seal: bool = false

# ============================================================
# NUEVO: Extensiones de Lore para el "Permiso de Actividad" único
# ============================================================

## NUEVO: Marca genérica de documento narrativamente anómalo (más amplia que
## has_black_seal, que queda como el caso puntual "sello negro"). Úsala para
## cualquier Permiso de Actividad que el guion necesite tratar como pista/
## misterio, sin necesidad de inventar un flag booleano nuevo por caso.
@export var is_anomalous_document: bool = false

## NUEVO: Objetos raros/lore asociados a ESTE documento puntual (ej: el
## Permiso de Actividad del "Hombre sin rostro" podría traer consigo una
## referencia a objetos que después aparecen en el baúl). VisitorProfile
## combina esto con sus propios hidden_items al armar el dict del baúl
## (ver VisitorProfile.to_legacy_dict), así el diseñador puede cargar el
## objeto raro donde le resulte más natural: en el documento o en el auto.
@export var hidden_items: Array[String] = []

## NUEVO: Caso puntual del Día 5 ("Hombre sin rostro"). Un documento vencido
## en 1980 pero firmado por un "Chenque" — el mismo apellido que el jugador.
## Bandera dedicada porque el peso narrativo de este dato es demasiado
## específico como para inferirlo de "signed_by" a mano en cada script de UI.
@export var signed_by_chenque: bool = false

func is_expired(current_day: int) -> bool:
	return expires_on_day != -1 and current_day > expires_on_day

## -------- Traducción de enums a texto para las Views (evita duplicar match en cada script) --------
static func type_display_name(t: DocType) -> String:
	match t:
		DocType.DNI:
			return "DNI"
		DocType.PASE_DIARIO:
			return "Pase de Ingreso Diario"
		DocType.PERMISO_ACTIVIDAD:
			return "Permiso de Actividad"
	return "Documento"

static func activity_display_name(a: Activity) -> String:
	match a:
		Activity.NINGUNA:
			return "Paseo"
		Activity.TRAVESIA_SENDERISMO:
			return "Travesía / Senderismo"
		Activity.PESCA_DEPORTIVA:
			return "Pesca Deportiva"
		Activity.FOTOGRAFIA_PROFESIONAL:
			return "Fotografía Profesional"
		Activity.INVESTIGACION_CIENTIFICA:
			return "Investigación Científica"
		Activity.MANTENIMIENTO_PARQUE:
			return "Mantenimiento del Parque"
	return "Paseo"
