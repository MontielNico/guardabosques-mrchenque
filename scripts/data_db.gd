extends Node
class_name DataDB

# Base de Datos y Spawner de Visitantes para la Progresión de 5 Días
# Estructurado estrictamente según los parámetros de promt.txt

static func get_day_info(day_number: int) -> Dictionary:
	match day_number:
		1:
			return {
				"title": "Día 1: Lo Básico - Primavera en Chalet Huergo",
				"season": "Primavera",
				"weather": "Viento O/SO 50 km/h - Parcialmente nublado - 15°C",
				"fire_risk": "MEDIO",
				"fire_risk_color": Color(0.95, 0.75, 0.2),
				"protected_fauna": "Turistas y Vecinos en Senderos Históricos",
				"rules_summary": [
					"Visitantes autorizados hoy: ÚNICAMENTE Turistas y Vecinos locales.",
					"Documentos a revisar: DNI y Pase de Visita Diario.",
					"LÓGICA DE ERROR: Validar que el DNI no esté vencido.",
					"LÓGICA DE ERROR: Validar que el nombre coincida en ambos papeles (DNI vs Pase).",
					"Evento Final: Al culminar el turno, se entregará la Bitácora de Silva."
				]
			}
		2:
			return {
				"title": "Día 2: Validación Extendida - Más Papeles en la Mesa",
				"season": "Verano Seco",
				"weather": "Viento N 35 km/h - Clima seco y soleado - 27°C",
				"fire_risk": "ALTO",
				"fire_risk_color": Color(0.95, 0.45, 0.15),
				"protected_fauna": "Pingüinos en playa y Fauna de restinga",
				"rules_summary": [
					"Visitantes autorizados: Se suman Trabajadores (técnicos, guías, oficios).",
					"Documentos a revisar: DNI, Pase de Visita y Permiso de Actividad.",
					"LÓGICA DE ERROR: Validar DNI vigente y coincidencia de nombres en los 3 documentos.",
					"El reto de hoy es validar datos básicos con mayor cantidad de papeles en el escritorio.",
					"Evento Obligatorio: Atento a la llegada de un Pescador Raro de costa."
				]
			}
		3:
			return {
				"title": "Día 3: La Palabra vs El Papel y Niebla",
				"season": "Verano Tardío con Niebla",
				"weather": "Viento Calmo / Marítimo - Niebla Densa del Atlántico - 12°C",
				"fire_risk": "MEDIO",
				"fire_risk_color": Color(0.6, 0.8, 0.95),
				"protected_fauna": "Científicos, Acampantes y Aves Marinas",
				"rules_summary": [
					"Visitantes autorizados: Se suman Científicos y Acampantes.",
					"LÓGICA DE ERROR: VALIDACIÓN DE DIÁLOGOS (La palabra vs el papel).",
					"El diálogo del visitante debe coincidir con la Actividad Autorizada en su Permiso.",
					"NO SE INCLUYE mecánica de inspección de baúl: Priorizar la declaración oral.",
					"Evento Ambiental: Niebla costera activa en toda la seccional.",
					"Evento Obligatorio: Trabajador nocturno sin documentos válidos a medianoche (Decisión ramificada)."
				]
			}
		4:
			return {
				"title": "Día 4: Falsificaciones Múltiples y Marea Alta",
				"season": "Otoño Inicial - Pleamar",
				"weather": "Viento Sur 40 km/h - Marea Alta Anormal y Vibraciones - 10°C",
				"fire_risk": "BAJO",
				"fire_risk_color": Color(0.3, 0.75, 0.95),
				"protected_fauna": "Acantilados y Túneles bajo Chalet Huergo",
				"rules_summary": [
					"RITMO: Fila rápida con todos los casos mezclados.",
					"LÓGICA DE ERROR: Cruzar todos los datos visuales, DNI, nombres y diálogos.",
					"Evento Ambiental: Alerta de Marea Alta en la base del acantilado.",
					"Evento Obligatorio: Atento a documentos anómalos extraviados (Foto de 1920 y Mapa de Túneles)."
				]
			}
		5:
			return {
				"title": "Día 5: El Legado de Silva - Detección de Anomalías",
				"season": "Otoño Pleno - Clímax",
				"weather": "Viento SO 65 km/h - Silencio de Radio y Sirenas - 6°C",
				"fire_risk": "EXTREMO",
				"fire_risk_color": Color(0.9, 0.2, 0.2),
				"protected_fauna": "Toda la Reserva y Misterio Subterráneo",
				"rules_summary": [
					"LÓGICA DE ERROR: DETECCIÓN DE ANOMALÍAS ACTIVADA.",
					"RECHAZAR si el documento tiene SELLO NEGRO.",
					"RECHAZAR si el documento está FIRMADO POR SILVA.",
					"RECHAZAR si la fecha es ILÓGICA (ej. 1980 o 2099).",
					"Evento Final: El Hombre Sin Rostro con documento de 1980 (Decisión que define el destino)."
				]
			}
		_:
			return {}

static func get_visitors_for_day(day_number: int) -> Array[Dictionary]:
	match day_number:
		1:
			# DÍA 1: Lo Básico (Solo Turistas y Vecinos, DNI y Pase de Visita Diario, DNI vigente y nombre coincidente)
			return [
				{
					"name": "Nahuel Morales",
					"avatar_file": "fotografoSinParpadeo.jpg",
					"car_name": "Renault 12 Celeste",
					"car_color": Color(0.4, 0.6, 0.8),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Turista / Fotógrafo",
					"dialog_intro": "Buenas tardes oficial Chenque. Venimos a sacar unas fotos de los senderos y el mirador costero.",
					"dialog_interrogate": "Todo en regla oficial: DNI vigente y pase diario a mi nombre.",
					"stated_activity": "Turismo y Fotografía",
					"doc": {
						"name": "Nahuel Morales",
						"name_on_dni": "Nahuel Morales",
						"name_on_pass": "Nahuel Morales",
						"dni": "34.892.110",
						"dni_expiry": "28/11/2028",
						"is_dni_expired": false,
						"type": "Pase de Visita Diario",
						"date": "28/11/2026",
						"purpose": "Turismo y Fotografía",
						"authorized_activity": "Turismo y Fotografía",
						"passengers": 2,
						"job_permit": "Particular (Turista)",
						"signed_by": "Dirección Provincial de Turismo",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Cámara réflex", "Termo y mate patagónico"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Esteban Cruz",
					"avatar_file": "residenteKm3.jpg",
					"car_name": "Peugeot 504 Gris",
					"car_color": Color(0.6, 0.6, 0.65),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Vecino de Km 3",
					"dialog_intro": "Hola Don Chenque, soy vecino de Km 3, vengo a dar una vuelta por el mirador con la patrona.",
					"dialog_interrogate": "¿El documento? Sí, lo tengo en la billetera desde hace unos cuantos años...",
					"stated_activity": "Paseo Vecinal en Mirador",
					"doc": {
						"name": "Esteban Cruz",
						"name_on_dni": "Esteban Cruz",
						"name_on_pass": "Esteban Cruz",
						"dni": "26.778.112",
						"dni_expiry": "10/04/2023", # ⚠️ DNI VENCIDO
						"is_dni_expired": true,
						"type": "Pase de Visita Diario",
						"date": "28/11/2026",
						"purpose": "Paseo Vecinal",
						"authorized_activity": "Paseo Vecinal",
						"passengers": 2,
						"job_permit": "Vecino Residente",
						"signed_by": "Municipalidad de Comodoro",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Termo de café", "Bizcochos"],
					"should_pass": false,
					"rejection_reasons": ["El DNI se encuentra VENCIDO (Vencimiento: 10/04/2023)"],
					"parcel_impact": {
						"Chalet Histórico": {"damage": 15.0, "tag": "queja"}
					}
				},
				{
					"name": "Claudio Bariloche",
					"avatar_file": "padreDeFamiliaTurista.jpg",
					"car_name": "Chevrolet Spin Blanca",
					"car_color": Color(0.92, 0.92, 0.92),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"visitor_type": "Turista Familiar",
					"dialog_intro": "Hola Don Chenque. Venimos de vacaciones con la familia a conocer el parque y el chalet.",
					"dialog_interrogate": "Le entregué mi DNI y el pase que me sellaron en la entrada sur.",
					"stated_activity": "Turismo Familiar Cultural",
					"doc": {
						"name": "Claudio Bariloche",
						"name_on_dni": "Claudio Bariloche",
						"name_on_pass": "Carlos Bariloche", # ⚠️ NOMBRE NO COINCIDE EN PASE
						"dni": "30.551.340",
						"dni_expiry": "15/09/2027",
						"is_dni_expired": false,
						"type": "Pase de Visita Diario",
						"date": "28/11/2026",
						"purpose": "Turismo Familiar",
						"authorized_activity": "Turismo Familiar",
						"passengers": 4,
						"job_permit": "Particular (Turista)",
						"signed_by": "Puesto Sur Chalet",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Guía turística de Comodoro", "Canasta de sándwiches"],
					"should_pass": false,
					"rejection_reasons": ["El nombre no coincide entre el DNI ('Claudio Bariloche') y el Pase de Visita ('Carlos Bariloche')"],
					"parcel_impact": {
						"Bosque de Lengas": {"damage": 15.0, "tag": "irregularidad"}
					}
				},
				{
					"name": "Silvina Aonikenk",
					"avatar_file": "acampanteIndebido.jpg",
					"car_name": "Volkswagen Gol Blanco",
					"car_color": Color(0.95, 0.95, 0.98),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"visitor_type": "Vecina de Rada Tilly",
					"dialog_intro": "Buenas tardes oficial. Vengo sola a hacer una caminata tranquila por el sendero histórico.",
					"dialog_interrogate": "Tengo toda la documentación al día como siempre, Chenque.",
					"stated_activity": "Senderismo Histórico",
					"doc": {
						"name": "Silvina Aonikenk",
						"name_on_dni": "Silvina Aonikenk",
						"name_on_pass": "Silvina Aonikenk",
						"dni": "39.120.441",
						"dni_expiry": "05/06/2029",
						"is_dni_expired": false,
						"type": "Pase de Visita Diario",
						"date": "28/11/2026",
						"purpose": "Senderismo Histórico",
						"authorized_activity": "Senderismo Histórico",
						"passengers": 1,
						"job_permit": "Particular (Vecina)",
						"signed_by": "Administración de Parques",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Botella de agua", "Mochila de paseo"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]

		2:
			# DÍA 2: Validación Extendida (Se suman Trabajadores, DNI + Pase + Permiso de Actividad, Evento Obligatorio: Pescador Raro)
			return [
				{
					"name": "Juan Mantenimiento",
					"avatar_file": "tecnicoMantenimiento.jpg",
					"car_name": "Renault Kangoo Amarilla",
					"car_color": Color(0.9, 0.75, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Trabajador / Técnico",
					"dialog_intro": "Buenas Don Chenque. Venimos de la Cooperativa Eléctrica para reparar el transformador del Chalet.",
					"dialog_interrogate": "Aquí tiene DNI, Pase Diario y el Permiso de Actividad de la Cooperativa.",
					"stated_activity": "Mantenimiento Eléctrico Chalet Huergo",
					"doc": {
						"name": "Juan Mantenimiento",
						"name_on_dni": "Juan Mantenimiento",
						"name_on_pass": "Juan Mantenimiento",
						"name_on_permit": "Juan Mantenimiento",
						"dni": "27.550.119",
						"dni_expiry": "12/08/2028",
						"is_dni_expired": false,
						"type": "Permiso de Actividad de Oficio",
						"date": "28/11/2026",
						"purpose": "Reparación de Transformador",
						"authorized_activity": "Mantenimiento Eléctrico Chalet Huergo",
						"passengers": 2,
						"job_permit": "Técnico Electricista Habilitado",
						"signed_by": "Cooperativa Eléctrica SCPL",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Caja de herramientas aisladas", "Cascos de seguridad", "Tester digital"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Héctor Leiva",
					"avatar_file": "recolectorDeFlora.jpg",
					"car_name": "Camioneta Ranger Vieja",
					"car_color": Color(0.45, 0.35, 0.25),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Trabajador / Recolección",
					"dialog_intro": "Buenas paisano. Venimos a hacer mantenimiento y desmalezado en los senderos de lengas.",
					"dialog_interrogate": "Traigo todos los papeles de la cuadrilla, revise nomás.",
					"stated_activity": "Poda y Mantenimiento de Senderos",
					"doc": {
						"name": "Héctor Leiva",
						"name_on_dni": "Héctor Leiva",
						"name_on_pass": "Héctor Leiva",
						"name_on_permit": "Héctor Leiva",
						"dni": "21.908.761",
						"dni_expiry": "18/02/2022", # ⚠️ DNI VENCIDO
						"is_dni_expired": true,
						"type": "Permiso de Actividad de Cuadrilla",
						"date": "28/11/2026",
						"purpose": "Poda de Seguridad",
						"authorized_activity": "Poda y Mantenimiento de Senderos",
						"passengers": 2,
						"job_permit": "Operario Forestal Registrado",
						"signed_by": "Dirección de Recursos Forestales",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Machetes de mano", "Guantes de cuero", "Sogas de amarre"],
					"should_pass": false,
					"rejection_reasons": ["El DNI se encuentra VENCIDO (Vencimiento: 18/02/2022)"],
					"parcel_impact": {
						"Bosque de Lengas": {"damage": 20.0, "tag": "tala_irregular"}
					}
				},
				{
					"name": "Martina Almada",
					"avatar_file": "guiaAutorizada.jpg",
					"car_name": "Minibús Mercedes Blanco",
					"car_color": Color(0.9, 0.9, 0.95),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"visitor_type": "Trabajadora / Guía Turística",
					"dialog_intro": "Buen día Mr. Chenque. Traigo un grupo de turistas para el circuito histórico y acantilados.",
					"dialog_interrogate": "Tengo mi credencial de guía y el permiso de actividad correspondiente.",
					"stated_activity": "Excursión Guiada Oficial",
					"doc": {
						"name": "Martina Almada",
						"name_on_dni": "Martina Almada",
						"name_on_pass": "Martina Almada",
						"name_on_permit": "Marta Almada", # ⚠️ NOMBRE NO COINCIDE EN PERMISO DE ACTIVIDAD
						"dni": "32.114.770",
						"dni_expiry": "14/11/2027",
						"is_dni_expired": false,
						"type": "Permiso de Actividad Turística",
						"date": "28/11/2026",
						"purpose": "Excursión Guiada Oficial",
						"authorized_activity": "Excursión Guiada Oficial",
						"passengers": 4,
						"job_permit": "Guía Oficial de Turismo",
						"signed_by": "Secretaría de Turismo Chubut",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Megáfono", "Botiquín", "Folletos informativos"],
					"should_pass": false,
					"rejection_reasons": ["El nombre en el Permiso de Actividad ('Marta Almada') no coincide con el DNI ('Martina Almada')"],
					"parcel_impact": {
						"Chalet Histórico": {"damage": 20.0, "tag": "irregularidad"}
					}
				},
				{
					"name": "Lautaro Pejerrey",
					"avatar_file": "pescadorDeProfundidad.jpg",
					"car_name": "Fiat Duna Rojo",
					"car_color": Color(0.8, 0.25, 0.2),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"visitor_type": "Pescador Raro de Costa (Evento Narrativo)",
					"is_mandatory_event": true,
					"event_id": "rare_fisherman",
					"dialog_intro": "Buenas noches Mr. Chenque... vengo del lecho del acantilado. Algo picó hondo en la rompiente... no tiene escamas normales. Silva solía decir que las mareas bajas despiertan lo que duerme abajo...",
					"dialog_interrogate": "Tengo DNI, Pase y Permiso de Pesca Artesanal vigentes. No me demore, el mar está llamando...",
					"stated_activity": "Pesca Artesanal de Costa",
					"doc": {
						"name": "Lautaro Pejerrey",
						"name_on_dni": "Lautaro Pejerrey",
						"name_on_pass": "Lautaro Pejerrey",
						"name_on_permit": "Lautaro Pejerrey",
						"dni": "31.442.809",
						"dni_expiry": "20/10/2029",
						"is_dni_expired": false,
						"type": "Permiso de Actividad - Pesca Artesanal",
						"date": "28/11/2026",
						"purpose": "Pesca Artesanal de Costa",
						"authorized_activity": "Pesca Artesanal de Costa",
						"passengers": 1,
						"job_permit": "Pescador Costero Registrado",
						"signed_by": "Capitanía de Puerto Comodoro",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Caña de pescar pesada", "Conservadora cerrada herméticamente"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]

		3:
			# DÍA 3: La Palabra vs El Papel y Niebla (Se suman Científicos y Acampantes, Validación Diálogo vs Permiso, Sin Baúl, Niebla Activa, Evento: Trabajador Medianoche)
			return [
				{
					"name": "Dr. Fernando Caleta",
					"avatar_file": "investigadorDeLaboratorio.jpg",
					"car_name": "Toyota Hilux Verde",
					"car_color": Color(0.25, 0.45, 0.3),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Científico / Biólogo",
					"dialog_intro": "Buenas tardes guardaparque. Somos biólogos de la universidad para realizar el censo y anillado de aves marinas en la costa.",
					"dialog_interrogate": "Nuestro trabajo es el relevamiento ornitológico bajo el protocolo científico aprobado.",
					"stated_activity": "Investigación y Censo de Aves Marinas",
					"doc": {
						"name": "Dr. Fernando Caleta",
						"name_on_dni": "Dr. Fernando Caleta",
						"name_on_pass": "Dr. Fernando Caleta",
						"name_on_permit": "Dr. Fernando Caleta",
						"dni": "22.650.980",
						"dni_expiry": "28/11/2027",
						"is_dni_expired": false,
						"type": "Permiso de Actividad Científica",
						"date": "28/11/2026",
						"purpose": "Censo de Aves y Pingüinos",
						"authorized_activity": "Investigación y Censo de Aves Marinas",
						"passengers": 2,
						"job_permit": "Investigador Conicet / UNPSJB",
						"signed_by": "Ministerio de Ciencia y Tecnología",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Planillas de conteo", "Binoculares de largo alcance"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Valeria Fontana",
					"avatar_file": "historiadora.jpg",
					"car_name": "Honda Fit Gris",
					"car_color": Color(0.7, 0.72, 0.75),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Científica / Historiadora",
					"dialog_intro": "Hola Don Chenque. Vengo a pescar pejerreyes con redes a la orilla del acantilado.", # ⚠️ DIÁLOGO NO COINCIDE CON PERMISO
					"dialog_interrogate": "¿El papel? Dice investigación de museo, pero en realidad venimos a tirar redes a la costa...",
					"stated_activity": "Pesca con Redes en Costa",
					"doc": {
						"name": "Valeria Fontana",
						"name_on_dni": "Valeria Fontana",
						"name_on_pass": "Valeria Fontana",
						"name_on_permit": "Valeria Fontana",
						"dni": "36.430.198",
						"dni_expiry": "28/11/2028",
						"is_dni_expired": false,
						"type": "Permiso de Actividad Científica",
						"date": "28/11/2026",
						"purpose": "Relevamiento de Archivo Histórico",
						"authorized_activity": "Investigación de Archivo y Patrimonio Chalet Huergo", # CONTRADICCIÓN
						"passengers": 2,
						"job_permit": "Investigadora de Patrimonio",
						"signed_by": "Comisión Nacional de Monumentos",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Carpetas de notas", "Grabador de voz"],
					"should_pass": false,
					"rejection_reasons": ["El diálogo del visitante ('Pesca con redes en costa') contradice la Actividad Autorizada en su Permiso ('Investigación de Archivo y Patrimonio')"],
					"parcel_impact": {
						"Costa y Pingüinera": {"damage": 30.0, "tag": "pesca_furtiva"}
					}
				},
				{
					"name": "Lucía Aventura",
					"avatar_file": "deportistaLocal.jpg",
					"car_name": "Ford Ka Rojo",
					"car_color": Color(0.85, 0.2, 0.2),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"visitor_type": "Acampante Habilitada",
					"dialog_intro": "Hola Mr. Chenque. Vengo a armar mi carpa en la zona de acampe y recorrer los senderos bajo la niebla.",
					"dialog_interrogate": "Tengo el permiso municipal de acampe y trekking en senderos habilitados.",
					"stated_activity": "Acampe y Trekking en Senderos Habilitados",
					"doc": {
						"name": "Lucía Aventura",
						"name_on_dni": "Lucía Aventura",
						"name_on_pass": "Lucía Aventura",
						"name_on_permit": "Lucía Aventura",
						"dni": "38.221.905",
						"dni_expiry": "28/11/2028",
						"is_dni_expired": false,
						"type": "Permiso de Actividad de Acampe",
						"date": "28/11/2026",
						"purpose": "Acampe y Trekking",
						"authorized_activity": "Acampe y Trekking en Senderos Habilitados",
						"passengers": 1,
						"job_permit": "Acampante Registrada",
						"signed_by": "Administración de Parques",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Mochila técnica", "Carpa reglamentaria", "Bolsa de dormir"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Marcos Acampante Indebido",
					"avatar_file": "acampanteIndebido.jpg",
					"car_name": "Chevrolet Corsa Verde",
					"car_color": Color(0.3, 0.5, 0.35),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Acampante Irregular",
					"dialog_intro": "Buenas tardes. Traigo carpas grandes para armar campamento nocturno y hacer fogatas en los cañadones.", # ⚠️ DIÁLOGO NO COINCIDE
					"dialog_interrogate": "¿El papel dice solo senderismo diurno? Bueno oficial, pero ya que estamos nos quedamos a pasar la noche con fuego...",
					"stated_activity": "Acampe Nocturno y Fogatas",
					"doc": {
						"name": "Marcos Acampante",
						"name_on_dni": "Marcos Acampante",
						"name_on_pass": "Marcos Acampante",
						"name_on_permit": "Marcos Acampante",
						"dni": "35.109.870",
						"dni_expiry": "28/11/2027",
						"is_dni_expired": false,
						"type": "Permiso de Actividad Diurna",
						"date": "28/11/2026",
						"purpose": "Senderismo Diurno Sin Acampe",
						"authorized_activity": "Senderismo Diurno Sin Acampe", # CONTRADICCIÓN
						"passengers": 2,
						"job_permit": "Particular (Visitante)",
						"signed_by": "Puesto Norte Chalet",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Carpa", "Bidón de combustible"],
					"should_pass": false,
					"rejection_reasons": ["El diálogo del visitante ('Acampe nocturno y fogatas') contradice la Actividad Autorizada ('Senderismo Diurno Sin Acampe')"],
					"parcel_impact": {
						"Bosque de Lengas": {"damage": 35.0, "tag": "incendio"}
					}
				},
				{
					"name": "Trabajador de Medianoche",
					"avatar_file": "conductorPeligroso.jpg",
					"car_name": "Camión Blindado Negro",
					"car_color": Color(0.12, 0.12, 0.15),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"visitor_type": "Trabajador Nocturno (Evento Obligatorio)",
					"is_mandatory_event": true,
					"event_id": "day3_midnight_worker",
					"dialog_intro": "Silva siempre nos dejaba pasar a la medianoche sin mirar tanto papel, Chenque. Abrí la barrera y no hagas preguntas.",
					"dialog_interrogate": "¿Documentos? No me hagas perder el tiempo en la niebla. Mirá cómo terminó Silva cuando quiso ser exigente...",
					"stated_activity": "Transporte Pesado No Autorizado",
					"doc": {
						"name": "Conductor No Registrado",
						"name_on_dni": "---",
						"name_on_pass": "INVÁLIDO / NO REGISTRADO",
						"name_on_permit": "SIN PERMISO DE ACTIVIDAD",
						"dni": "00.000.000",
						"dni_expiry": "EXPIRADO",
						"is_dni_expired": true,
						"type": "DOCUMENTO INVÁLIDO",
						"date": "00/00/0000",
						"purpose": "Tránsito Nocturno No Declarado",
						"authorized_activity": "NINGUNA ACTIVIDAD AUTORIZADA",
						"passengers": 1,
						"job_permit": "Sin Acreditación Oficial",
						"signed_by": "Desconocido",
						"stamp": "Sin Sello"
					},
					"car_items": ["Carga pesada sellada"],
					"should_pass": false,
					"rejection_reasons": ["Trabajador nocturno sin documentación válida ni permiso de actividad habilitado"],
					"parcel_impact": {
						"Cerro Chenque y Acantilados": {"damage": 40.0, "tag": "usurpacion"}
					}
				}
			]

		4:
			# DÍA 4: Falsificaciones Múltiples (Fila rápida con todos los casos mezclados, cruzar visuales y diálogos, Marea Alta, Evento: Foto 1920 y Mapa Túneles)
			return [
				{
					"name": "Aníbal Trelew",
					"avatar_file": "personajeRepetido.jpg",
					"car_name": "Toyota Corolla Gris",
					"car_color": Color(0.65, 0.68, 0.7),
					"declared_passengers": 3,
					"actual_passengers": 3,
					"visitor_type": "Vecino Familiar",
					"dialog_intro": "Buenas tardes Don Chenque. Venimos con la familia a pasar la tarde a los miradores frente al mar crecido.",
					"dialog_interrogate": "Todo en orden oficial: DNI, pase y permiso familiar coinciden perfectamente.",
					"stated_activity": "Visita Familiar a Miradores",
					"doc": {
						"name": "Aníbal Trelew",
						"name_on_dni": "Aníbal Trelew",
						"name_on_pass": "Aníbal Trelew",
						"name_on_permit": "Aníbal Trelew",
						"dni": "31.220.884",
						"dni_expiry": "28/11/2029",
						"is_dni_expired": false,
						"type": "Pase de Visita Familiar",
						"date": "28/11/2026",
						"purpose": "Visita Familiar a Miradores",
						"authorized_activity": "Visita Familiar a Miradores",
						"passengers": 3,
						"job_permit": "Particular (Vecino)",
						"signed_by": "Dirección de Parques",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Mantas de abrigo", "Termos de mate"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Mauro 'El Trampero' Solís",
					"avatar_file": "cazadorFurtivo.jpg",
					"car_name": "Jeep Ika Negro",
					"car_color": Color(0.2, 0.2, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Cazador Furtivo",
					"dialog_intro": "Venimos a cazar zorros y guanacos en los cañadones con trampas y carabinas.", # ⚠️ DIÁLOGO CONTRADICE PERMISO
					"dialog_interrogate": "¿El permiso dice paseo en 4x4? Sí bueno, pero nosotros cazamos.",
					"stated_activity": "Caza Furtiva de Fauna",
					"doc": {
						"name": "Mauro Solís",
						"name_on_dni": "Mauro Solís",
						"name_on_pass": "Mauro Solís",
						"name_on_permit": "Mauro Solís",
						"dni": "25.667.890",
						"dni_expiry": "28/11/2028",
						"is_dni_expired": false,
						"type": "Permiso de Actividad Recreativa",
						"date": "28/11/2026",
						"purpose": "Paseo Turístico en 4x4",
						"authorized_activity": "Paseo Turístico en 4x4", # CONTRADICCIÓN
						"passengers": 2,
						"job_permit": "Particular",
						"signed_by": "Puesto Norte Chalet",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Trampas cepo", "Rifle mira telescópica"],
					"should_pass": false,
					"rejection_reasons": ["El diálogo del visitante ('Caza con trampas') contradice la Actividad Autorizada ('Paseo Turístico en 4x4')"],
					"parcel_impact": {
						"Cerro Chenque y Acantilados": {"damage": 45.0, "tag": "caza"}
					}
				},
				{
					"name": "Elena Costa",
					"avatar_file": "historiadora.jpg",
					"car_name": "Honda Fit Azul",
					"car_color": Color(0.3, 0.5, 0.75),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Turista / Portadora de Claves (Evento Obligatorio)",
					"is_mandatory_event": true,
					"event_id": "day4_clues",
					"dialog_intro": "Buenas tardes oficial. Venimos a recorrer la costa... ¡Uy, disculpe! Esos papeles viejos y fotos se me mezclaron de una caja que hallé en las rocas...",
					"dialog_interrogate": "Mi documentación está impecable. Esos anexos de 1920 y mapas manuscritos estaban tirados cerca de la rompiente...",
					"stated_activity": "Turismo Costero y Miradores",
					"doc": {
						"name": "Elena Costa",
						"name_on_dni": "Elena Costa",
						"name_on_pass": "Elena Costa",
						"name_on_permit": "Elena Costa",
						"dni": "33.910.450",
						"dni_expiry": "28/11/2028",
						"is_dni_expired": false,
						"type": "Pase de Visita Turística",
						"date": "28/11/2026",
						"purpose": "Turismo Costero",
						"authorized_activity": "Turismo Costero y Miradores",
						"passengers": 2,
						"job_permit": "Particular (Turista)",
						"signed_by": "Dirección Provincial de Turismo",
						"stamp": "Sello Oficial Verde",
						"has_photo_1920": true, # 📷 DOCUMENTO EXTRA NARRATIVO
						"has_tunnel_map": true # 🗺️ DOCUMENTO EXTRA NARRATIVO
					},
					"car_items": ["Fotografía en sepia de 1920", "Mapa de galerías subterráneas"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Gastón Méndez",
					"avatar_file": "conductorPeligroso.jpg",
					"car_name": "Volkswagen Senda Azul",
					"car_color": Color(0.2, 0.3, 0.6),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Conductor Irregular",
					"dialog_intro": "¡Buenas jefe! Venimos a dar unas vueltas por el mirador del cerro.",
					"dialog_interrogate": "¿La fecha de vencimiento? Ah... pensé que duraba 5 años más...",
					"stated_activity": "Turismo en Mirador",
					"doc": {
						"name": "Gastón Méndez",
						"name_on_dni": "Gastón Méndez",
						"name_on_pass": "Gastón Méndez",
						"name_on_permit": "Gastón Méndez",
						"dni": "29.800.123",
						"dni_expiry": "14/10/2024", # ⚠️ DNI VENCIDO
						"is_dni_expired": true,
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Turismo en Mirador",
						"authorized_activity": "Turismo en Mirador",
						"passengers": 2,
						"job_permit": "Particular",
						"signed_by": "Puesto Sur",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Botellas de gaseosa"],
					"should_pass": false,
					"rejection_reasons": ["El DNI se encuentra VENCIDO (Vencimiento: 14/10/2024)"],
					"parcel_impact": {
						"Cerro Chenque y Acantilados": {"damage": 25.0, "tag": "infraccion"}
					}
				},
				{
					"name": "Mariano 'Doppelgänger'",
					"avatar_file": "personajeRepetidoConDopelganger.jpg",
					"car_name": "Volkswagen Saveiro Negra",
					"car_color": Color(0.15, 0.15, 0.18),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Suplantador de Identidad",
					"dialog_intro": "Hola Chenque. Vengo a pescar a la playa... Me llamo Mariano pero el DNI me lo prestó un amigo...", # ⚠️ NOMBRE NO COINCIDE / SUPLANTACIÓN
					"dialog_interrogate": "¿Qué tiene de malo usar el DNI de Nahuel Morales? Si los dos somos de Comodoro...",
					"stated_activity": "Pesca en Playa",
					"doc": {
						"name": "Nahuel Morales (Suplantación)",
						"name_on_dni": "Nahuel Morales",
						"name_on_pass": "Mariano Gómez", # ⚠️ DISCREPANCIA TOTAL
						"name_on_permit": "Mariano Gómez",
						"dni": "34.892.110",
						"dni_expiry": "28/11/2028",
						"is_dni_expired": false,
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Pesca en Playa",
						"authorized_activity": "Pesca en Playa",
						"passengers": 2,
						"job_permit": "Particular",
						"signed_by": "Puesto Norte",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Caña de pescar", "Arpón no reglamentario"],
					"should_pass": false,
					"rejection_reasons": ["Discrepancia de identidad: DNI ajeno a nombre de 'Nahuel Morales' con pase a nombre de 'Mariano Gómez'"],
					"parcel_impact": {
						"Costa y Pingüinera": {"damage": 30.0, "tag": "pesca_furtiva"}
					}
				},
				{
					"name": "Martina Almada",
					"avatar_file": "guiaAutorizada.jpg",
					"car_name": "Minibús Mercedes Blanco",
					"car_color": Color(0.9, 0.9, 0.95),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"visitor_type": "Guía Oficial de Turismo",
					"dialog_intro": "Buenas tardes Mr. Chenque. Traigo el contingente turístico para la visita guiada reglamentaria del chalet.",
					"dialog_interrogate": "Todo debidamente corregido y verificado: DNI, pase y credencial oficial.",
					"stated_activity": "Excursión Guiada Oficial de Turismo",
					"doc": {
						"name": "Martina Almada",
						"name_on_dni": "Martina Almada",
						"name_on_pass": "Martina Almada",
						"name_on_permit": "Martina Almada",
						"dni": "32.114.770",
						"dni_expiry": "14/11/2027",
						"is_dni_expired": false,
						"type": "Permiso de Actividad Turística",
						"date": "28/11/2026",
						"purpose": "Excursión Guiada Oficial",
						"authorized_activity": "Excursión Guiada Oficial de Turismo",
						"passengers": 4,
						"job_permit": "Guía Oficial de Turismo Habilitada",
						"signed_by": "Secretaría de Turismo Chubut",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Megáfono", "Botiquín reglamentario"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]

		5:
			# DÍA 5: El Legado de Silva (Detección de Anomalías: Sello Negro, Firma de Silva, Fecha ilógica 1980/2099; Evento Final: Hombre sin rostro con doc de 1980)
			return [
				{
					"name": "Falso Inspector Valenzuela",
					"avatar_file": "falsoAgenteDelMinisterio.jpg",
					"car_name": "Ford Ranger Oficial Trucha",
					"car_color": Color(0.85, 0.85, 0.85),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"visitor_type": "Falso Inspector (Anomalía: Sello Negro)",
					"dialog_intro": "Guardaparque Chenque, vengo del Ministerio Nacional a auditar las cajas fuertes del Chalet Huergo.",
					"dialog_interrogate": "Mire el sello negro en mi orden ministerial y ábrame la barrera de inmediato.",
					"stated_activity": "Auditoría de Fondos y Museo",
					"doc": {
						"name": "Inspector Valenzuela",
						"name_on_dni": "Inspector Valenzuela",
						"name_on_pass": "Inspector Valenzuela",
						"name_on_permit": "Inspector Valenzuela",
						"dni": "18.300.999",
						"dni_expiry": "28/11/2026",
						"is_dni_expired": false,
						"type": "Orden Ministerial de Auditoría",
						"date": "28/11/2026",
						"purpose": "Auditoría de Fondos y Museo",
						"authorized_activity": "Auditoría de Fondos y Museo",
						"passengers": 1,
						"job_permit": "Credencial Ministerial",
						"signed_by": "Ministerio Nacional",
						"stamp": "SELLO NEGRO DE CLAUSURA ⬛", # ⚠️ ANOMALÍA: SELLO NEGRO
						"has_black_seal": true
					},
					"car_items": ["Ganzúas y palancas", "Bolsas de arpillera vacías"],
					"should_pass": false,
					"rejection_reasons": ["Anomalía detectada: Documento portador de SELLO NEGRO (Acceso estrictamente prohibido)"],
					"parcel_impact": {
						"Chalet Histórico": {"damage": 50.0, "tag": "usurpacion"}
					}
				},
				{
					"name": "Rubén Silva (Ex Empleado)",
					"avatar_file": "exEmpleadoSilva.jpg",
					"car_name": "Camión F-350 Rojo",
					"car_color": Color(0.75, 0.2, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Ex Empleado (Anomalía: Firma de Silva)",
					"dialog_intro": "Hola Chenque, soy Silva, trabajé acá antes. Vengo a descargar unos materiales para las cuevas.",
					"dialog_interrogate": "Tengo el pase firmado de puño y letra por el Guardabosques Silva de anoche.",
					"stated_activity": "Descarga de Materiales en Cañadones",
					"doc": {
						"name": "Rubén Silva",
						"name_on_dni": "Rubén Silva",
						"name_on_pass": "Rubén Silva",
						"name_on_permit": "Rubén Silva",
						"dni": "23.401.999",
						"dni_expiry": "28/11/2026",
						"is_dni_expired": false,
						"type": "Permiso Especial de Descarga",
						"date": "28/11/2026",
						"purpose": "Descarga de Materiales",
						"authorized_activity": "Descarga de Materiales en Cañadones",
						"passengers": 2,
						"job_permit": "Transportista",
						"signed_by": "Firmado: Guardabosques Silva ✍️", # ⚠️ ANOMALÍA: FIRMADO POR SILVA
						"signed_by_silva": true,
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Chapas de zinc", "Rollos de alambre de púa"],
					"should_pass": false,
					"rejection_reasons": ["Anomalía detectada: Documento firmado por el desaparecido Guardabosques Silva"],
					"parcel_impact": {
						"Humedal y Laguna de Aves": {"damage": 40.0, "tag": "usurpacion"}
					}
				},
				{
					"name": "Marcos Anormal",
					"avatar_file": "observadorDeAvesAnormal.jpg",
					"car_name": "Furgón Gris Oscuro",
					"car_color": Color(0.35, 0.35, 0.4),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"visitor_type": "Turista Anómalo (Anomalía: Fecha Ilógica 2099)",
					"dialog_intro": "Buenas. Solo vengo a observar las aves del próximo siglo... el pase tiene la fecha de mi época.",
					"dialog_interrogate": "¿El año 2099? Para nosotros ya es historia común oficial...",
					"stated_activity": "Avistaje Ornitológico Futuro",
					"doc": {
						"name": "Marcos Anormal",
						"name_on_dni": "Marcos Anormal",
						"name_on_pass": "Marcos Anormal",
						"name_on_permit": "Marcos Anormal",
						"dni": "37.662.110",
						"dni_expiry": "28/11/2099",
						"is_dni_expired": false,
						"type": "Pase de Ingreso Temporal",
						"date": "15/08/2099", # ⚠️ ANOMALÍA: FECHA ILÓGICA 2099
						"illogical_date": true,
						"purpose": "Avistaje de Aves",
						"authorized_activity": "Avistaje Ornitológico Futuro",
						"passengers": 1,
						"job_permit": "Particular",
						"signed_by": "Dirección Temporal de Parques",
						"stamp": "Sello Oficial Verde"
					},
					"car_items": ["Dispositivos ópticos anómalos"],
					"should_pass": false,
					"rejection_reasons": ["Anomalía detectada: Fecha ilógica e imposible en el documento (15/08/2099)"],
					"parcel_impact": {
						"Costa y Pingüinera": {"damage": 40.0, "tag": "anomalia"}
					}
				},
				{
					"name": "Juan Mantenimiento",
					"avatar_file": "tecnicoMantenimiento.jpg",
					"car_name": "Renault Kangoo Amarilla",
					"car_color": Color(0.9, 0.75, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"visitor_type": "Técnico Oficial Legítimo",
					"dialog_intro": "Buenas Don Chenque. Venimos a hacer la última revisión del tendido eléctrico del Chalet antes del temporal.",
					"dialog_interrogate": "Toda la documentación está en orden: fecha actual 2026, firma de la Cooperativa y sello verde oficial.",
					"stated_activity": "Reparación Eléctrica Chalet Huergo",
					"doc": {
						"name": "Juan Mantenimiento",
						"name_on_dni": "Juan Mantenimiento",
						"name_on_pass": "Juan Mantenimiento",
						"name_on_permit": "Juan Mantenimiento",
						"dni": "27.550.119",
						"dni_expiry": "28/11/2028",
						"is_dni_expired": false,
						"type": "Orden de Servicio Cooperativa",
						"date": "28/11/2026",
						"purpose": "Reparación Eléctrica Chalet Huergo",
						"authorized_activity": "Reparación Eléctrica Chalet Huergo",
						"passengers": 2,
						"job_permit": "Técnico Electricista Oficial",
						"signed_by": "Cooperativa SCPL",
						"stamp": "Sello Oficial Verde",
						"has_black_seal": false,
						"signed_by_silva": false,
						"illogical_date": false
					},
					"car_items": ["Tester digital", "Cascos de seguridad", "Caja de fusibles"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "El Hombre Sin Rostro",
					"avatar_file": "personajeRepetidoConDopelganger.jpg",
					"car_name": "Vehículo Espectral Oscuro",
					"car_color": Color(0.08, 0.08, 0.1),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"visitor_type": "El Hombre Sin Rostro (Evento Final / Clímax)",
					"is_mandatory_event": true,
					"event_id": "day5_faceless_man",
					"dialog_intro": "La marea ya cubrió los túneles, Chenque. Silva te dejó la bitácora porque sabía que tú eras el único que podía cerrar la barrera... o unirte a lo que vigila bajo el cerro. ¿Qué vas a sellar?",
					"dialog_interrogate": "Mi permiso data de 1980 y lleva la firma que conoces bien. La decisión final está en tu escritorio...",
					"stated_activity": "Clausura Definitiva o Apertura de Túneles",
					"doc": {
						"name": "El Hombre Sin Rostro",
						"name_on_dni": "Expediente 1980",
						"name_on_pass": "El Hombre Sin Rostro",
						"name_on_permit": "El Hombre Sin Rostro",
						"dni": "00.198.000",
						"dni_expiry": "12/03/1980",
						"is_dni_expired": true,
						"type": "Expediente Histórico 1980",
						"date": "12/03/1980", # ⚠️ ANOMALÍA: FECHA ILÓGICA 1980
						"illogical_date": true,
						"purpose": "Acceso a Túneles Subterráneos",
						"authorized_activity": "Clausura Definitiva o Apertura de Túneles",
						"passengers": 1,
						"job_permit": "Guardabosques Predecesor",
						"signed_by": "Firmado: Guardabosques Silva ✍️",
						"signed_by_silva": true,
						"stamp": "Sello Histórico 1980"
					},
					"car_items": ["Llave maestra de los túneles del Chalet"],
					"should_pass": false,
					"rejection_reasons": ["Anomalía definitiva: Documento de 1980 firmado por Silva para acceso a los túneles"],
					"parcel_impact": {
						"Chalet Histórico": {"damage": 30.0, "tag": "misterio"}
					}
				}
			]
		_:
			return []
