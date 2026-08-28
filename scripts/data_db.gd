extends Node
class_name DataDB

# Base de Datos de Reglas, Clima, Visitantes y Eventos de Emergencia (5 Días)

static func get_day_info(day_number: int) -> Dictionary:
	match day_number:
		1:
			return {
				"title": "Día 1: Primavera Ventosa en la Costa",
				"season": "Primavera",
				"weather": "Viento O/SO 55 km/h - Parcialmente nublado - 14°C",
				"fire_risk": "MEDIO",
				"fire_risk_color": Color(0.95, 0.75, 0.2),
				"protected_fauna": "Pingüinos de Magallanes (Anidación en Costa) y Aves Marinas",
				"rules_summary": [
					"Todo visitante debe portar 'Pase de Ingreso Diario' con fecha de hoy vigente.",
					"Fuego permitido SOLO en fogones designados con 'Permiso de Fuego'. Si no tiene permiso, carbón/leña está prohibido.",
					"Prohibido acampar sin 'Permiso de Acampe'.",
					"Cantidad de personas en el auto debe coincidir con el permiso."
				],
				"events": [
					{
						"trigger_at_visitor": 2,
						"title": "¡ALERTA RADIAL: Humo en Parcela Bosque de Lengas!",
						"description": "Se divisa humo no controlado cerca de las lengas centenarias. Si vas a patrullar de inmediato podrás extinguirlo a tiempo y asegurar la zona.",
						"parcel": "Bosque de Lengas",
						"reward": 12000,
						"damage_if_ignored": 35
					}
				]
			}
		2:
			return {
				"title": "Día 2: Verano Seco y Temporada de Pesca",
				"season": "Verano",
				"weather": "Viento N 30 km/h - Seco y Soleado - 26°C",
				"fire_risk": "ALTO",
				"fire_risk_color": Color(0.95, 0.45, 0.15),
				"protected_fauna": "Guanacos en laderas del cerro y Pingüinos en playa",
				"rules_summary": [
					"ALERTA POR SEQUÍA: PROHIBIDO TODO TIPO DE CARBÓN O FUEGO (Incluso con permiso previo).",
					"Pesca permitida ÚNICAMENTE con 'Permiso de Pesca Provincial'. Cañas/anzuelos sin permiso = RECHAZO.",
					"Mascotas/Perros estrictamente con 'Certificado de Correa' para no espantar guanacos.",
					"Comprobar fecha de vencimiento del documento."
				],
				"events": [
					{
						"trigger_at_visitor": 1,
						"title": "¡ALERTA RADIAL: Pescadores Furtivos en Playa!",
						"description": "Se reportan personas ingresando con redes ilegales cerca de la colonia de pingüinos.",
						"parcel": "Costa y Pingüinera",
						"reward": 15000,
						"damage_if_ignored": 30
					}
				]
			}
		3:
			return {
				"title": "Día 3: Alerta Roja por Viento Extremo",
				"season": "Verano Tardío",
				"weather": "Viento O/NO 90 km/h (Temporal Patagónico) - Muy Seco - 29°C",
				"fire_risk": "EXTREMO",
				"fire_risk_color": Color(0.9, 0.15, 0.15),
				"protected_fauna": "Zorros Colorados y Petreles Gigantes",
				"rules_summary": [
					"PELIGRO MÁXIMO DE INCENDIO: Prohibido carbón, leña, bidones de combustible sueltos o motosierras.",
					"Prohibido el ingreso de más de 4 personas por vehículo por capacidad de evacuación de emergencia.",
					"Revisar que el sello del pase no esté adulterado o falsificado.",
					"Cualquier sospecha de tala o fogón = RECHAZO INMEDIATO."
				],
				"events": [
					{
						"trigger_at_visitor": 2,
						"title": "¡ALERTA RADIAL: Tala Ilegal en Parcela Bosque!",
						"description": "Guardas auxiliares oyen motosierras talando coihues protegidos en el sector norte.",
						"reward": 18000,
						"parcel": "Bosque de Lengas",
						"damage_if_ignored": 40
					}
				]
			}
		4:
			return {
				"title": "Día 4: Preservación de Acantilados y Chalet Histórico",
				"season": "Otoño Inicial",
				"weather": "Viento S 40 km/h - Nublado con lloviznas intermitentes - 11°C",
				"fire_risk": "BAJO",
				"fire_risk_color": Color(0.2, 0.75, 0.3),
				"protected_fauna": "Árboles Históricos del Chalet y Aves de Acantilado",
				"rules_summary": [
					"PROHIBICIÓN TOTAL DE CAZA: Rifles, gomeras, trampas o arpones = RECHAZO INMEDIATO.",
					"Vehículos con materiales de construcción (chapas, alambre, postes) deben ser RECHAZADOS (Riesgo de usurpación).",
					"Los visitantes al 'Chalet Histórico' no pueden ingresar con mascotas ni herramientas cortantes.",
					"Verificar concordancia entre motivo de visita y objetos del baúl."
				],
				"events": [
					{
						"trigger_at_visitor": 1,
						"title": "¡ALERTA RADIAL: Intento de Usurpación en Acantilados!",
						"description": "Se observa un camión intentando delimitar parcelas con alambres en el Cerro Chenque.",
						"parcel": "Cerro Chenque y Acantilados",
						"reward": 20000,
						"damage_if_ignored": 45
					}
				]
			}
		5:
			return {
				"title": "Día 5: Día del Guardaparques - Inspección General",
				"season": "Otoño Pleno",
				"weather": "Viento SO 60 km/h - Helada matinal y cielo despejado - 7°C",
				"fire_risk": "MEDIO",
				"fire_risk_color": Color(0.95, 0.75, 0.2),
				"protected_fauna": "Toda la Reserva Natural Chalet Huergo y Chenque",
				"rules_summary": [
					"APLICAR TODAS LAS NORMATIVAS VIGENTES.",
					"Carbón/Leña: Solo con Permiso de Fuego explícito.",
					"Pesca: Solo con Permiso de Pesca Provincial.",
					"Prohibida la caza, tala, usurpación y desmonte.",
					"Revisar cuidadosamente identidad, fecha y cantidad de pasajeros."
				],
				"events": [
					{
						"trigger_at_visitor": 2,
						"title": "¡ALERTA RADIAL: Vandalismo en el Chalet Histórico!",
						"description": "Sujetos intentan forzar las puertas del museo del Chalet Huergo.",
						"parcel": "Chalet Histórico",
						"reward": 25000,
						"damage_if_ignored": 50
					}
				]
			}
		_:
			return {}

static func get_visitors_for_day(day_number: int) -> Array[Dictionary]:
	match day_number:
		1:
			return [
				{
					"name": "Nahuel Morales",
					"avatar_seed": 1,
					"car_name": "Renault 12 Celeste",
					"car_color": Color(0.4, 0.6, 0.8),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas tardes oficial. Venimos a sacar unas fotos de los senderos y el mirador costero.",
					"dialog_interrogate": "¿Alguna duda? Todo en orden, solo traemos un termo y la cámara de fotos.",
					"doc": {
						"name": "Nahuel Morales",
						"dni": "34.892.110",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Turismo y Fotografía",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Cámara de fotos", "Termo y mate", "Mochila con abrigos"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Rodrigo 'El Asador' Vega",
					"avatar_seed": 2,
					"car_name": "Ford F-100 Oxidada",
					"car_color": Color(0.7, 0.35, 0.2),
					"declared_passengers": 3,
					"actual_passengers": 3,
					"dialog_intro": "¡Hola compadre! Venimos a tirar una carnecita al pasto con los muchachos.",
					"dialog_interrogate": "¿Permiso de fuego? ¿Para qué? Traje dos bolsas de quebracho y una parrilla portátil.",
					"doc": {
						"name": "Rodrigo Vega",
						"dni": "28.331.405",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Paseo Familiar",
						"passengers": 3,
						"fire_permit": false, # NO TIENE PERMISO DE FUEGO
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Bolsa de carbón 10kg", "Parrilla portátil", "Bidón de leña"],
					"should_pass": false,
					"rejection_reasons": ["Trae carbón y leña sin Permiso de Fuego"],
					"parcel_impact": {"Bosque de Lengas": -25}
				},
				{
					"name": "Silvina Aonikenk",
					"avatar_seed": 3,
					"car_name": "Volkswagen Gol Blanco",
					"car_color": Color(0.9, 0.9, 0.92),
					"declared_passengers": 1,
					"actual_passengers": 3, # Viajan 3 y declaró 1
					"dialog_intro": "Buenas. Vengo yo sola a hacer una caminata tranquila por la costa.",
					"dialog_interrogate": "Eh... los que van atrás son unos amigos que levanté en la ruta, ¿no pueden pasar?",
					"doc": {
						"name": "Silvina Aonikenk",
						"dni": "39.120.441",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Trekking Individual",
						"passengers": 1,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Botella de agua", "Bastones de trekking", "Gente escondida en el asiento trasero"],
					"should_pass": false,
					"rejection_reasons": ["Discrepancia grave de pasajeros: viajan 3 personas con pase de 1"],
					"parcel_impact": {"Costa y Pingüinera": -20}
				},
				{
					"name": "Dr. Fernando Caleta",
					"avatar_seed": 4,
					"car_name": "Toyota Hilux Verde",
					"car_color": Color(0.25, 0.45, 0.3),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas tardes, guardaparque. Somos biólogos de la universidad para censo de fauna.",
					"dialog_interrogate": "Tenemos el pase científico y la autorización con fogón habilitado en base.",
					"doc": {
						"name": "Dr. Fernando Caleta",
						"dni": "22.650.980",
						"type": "Pase Científico / Oficial",
						"date": "28/11/2026",
						"purpose": "Investigación y Censo de Aves",
						"passengers": 2,
						"fire_permit": true,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Binoculares", "Planillas de conteo", "Termo de café"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		2:
			return [
				{
					"name": "Lautaro Pejerrey",
					"avatar_seed": 5,
					"car_name": "Fiat Duna Rojo",
					"car_color": Color(0.8, 0.25, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "¡Qué tal jefe! Un hermoso día para probar suerte en la costa con las cañas.",
					"dialog_interrogate": "Tengo el carnet de pesca provincial al día y los anzuelos reglamentarios.",
					"doc": {
						"name": "Lautaro Pejerrey",
						"dni": "31.442.809",
						"type": "Permiso de Pesca Provincial",
						"date": "28/11/2026",
						"purpose": "Pesca Deportiva de Costa",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": true, # TIENE PERMISO
						"is_expired": false
					},
					"car_items": ["2 Cañas de pescar telescópicas", "Caja de señuelos", "Conservadora con hielo"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Esteban 'Parrillita' Cruz",
					"avatar_seed": 6,
					"car_name": "Peugeot 504 Gris",
					"car_color": Color(0.6, 0.6, 0.65),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"dialog_intro": "Hola Don Chenque. Traemos un costillar de cordero y dos bolsas de carbón.",
					"dialog_interrogate": "¿Pero cómo que no se puede fuego si tengo el permiso del año pasado?",
					"doc": {
						"name": "Esteban Cruz",
						"dni": "26.778.112",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Asado",
						"passengers": 4,
						"fire_permit": true, # Aunque tenga permiso, HOY HAY ALERTA ALTA (PROHIBIDO FUEGO)
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Bolsas de carbón", "Parrilla con grasa", "Bidón de alcohol de quemar"],
					"should_pass": false,
					"rejection_reasons": ["Riesgo ALTO de incendio: Fuego estrictamente prohibido hoy"],
					"parcel_impact": {"Bosque de Lengas": -35, "Chalet Histórico": -20}
				},
				{
					"name": "Marcos Furtivo",
					"avatar_seed": 7,
					"car_name": "Chevrolet Corsa Verde",
					"car_color": Color(0.3, 0.5, 0.35),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas. Solo venimos a tomar mate y ver las olas.",
					"dialog_interrogate": "¿Esas cañas en el baúl? No son mías... me las prestaron recién...",
					"doc": {
						"name": "Marcos Furtivo",
						"dni": "35.109.870",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Paseo",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false, # NO TIENE PERMISO DE PESCA
						"is_expired": false
					},
					"car_items": ["3 Cañas de pescar escondidas", "Redes agalleras ilegales", "Cuchillo de filetear"],
					"should_pass": false,
					"rejection_reasons": ["Lleva redes y cañas sin Permiso de Pesca Provincial"],
					"parcel_impact": {"Costa y Pingüinera": -30}
				},
				{
					"name": "Familia Bariloche",
					"avatar_seed": 8,
					"car_name": "Chevrolet Spin Blanca",
					"car_color": Color(0.95, 0.95, 0.95),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"dialog_intro": "Hola oficial Chenque, venimos de vacaciones a conocer el Chalet Huergo.",
					"dialog_interrogate": "Llevamos un perro con correa reglamentaria y su libreta sanitaria como exige el reglamento.",
					"doc": {
						"name": "Claudio Bariloche",
						"dni": "30.551.340",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Turismo Cultural",
						"passengers": 4,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Guía turística de Comodoro", "Perro con correa y bozal", "Canasta de sándwiches"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		3:
			return [
				{
					"name": "Héctor 'Hacha' Leiva",
					"avatar_seed": 9,
					"car_name": "Camioneta Ranger Vieja",
					"car_color": Color(0.45, 0.35, 0.25),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas. Vamos a juntar unas ramas secas caídas al fondo del bosque.",
					"dialog_interrogate": "¿La motosierra? Para ramas caídas nada más, no desconfíe paisano.",
					"doc": {
						"name": "Héctor Leiva",
						"dni": "21.908.761",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Recolección",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Motosierra Stihl a nafta", "Hacha grande de tala", "Cadenas de arrastre", "Bidón de combustible 20L"],
					"should_pass": false,
					"rejection_reasons": ["Riesgo EXTREMO: Prohibidas motosierras, combustible y hachas (Tala/Incendio)"],
					"parcel_impact": {"Bosque de Lengas": -45}
				},
				{
					"name": "Valeria Fontana",
					"avatar_seed": 10,
					"car_name": "Honda Fit Gris",
					"car_color": Color(0.7, 0.72, 0.75),
					"declared_passengers": 3,
					"actual_passengers": 3,
					"dialog_intro": "Hola guardaparque. Venimos a recorrer el jardín botánico del Chalet.",
					"dialog_interrogate": "Solo traemos nuestras viandas frías y cámaras. Ningún elemento inflamable.",
					"doc": {
						"name": "Valeria Fontana",
						"dni": "36.430.198",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Paseo Botánico",
						"passengers": 3,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Sándwiches de miga", "Botellas de jugo", "Cámaras réflex"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Gastón Expirado",
					"avatar_seed": 11,
					"car_name": "Volkswagen Senda Azul",
					"car_color": Color(0.2, 0.3, 0.6),
					"declared_passengers": 5, # 5 personas con alerta de max 4
					"actual_passengers": 5,
					"dialog_intro": "Buenas tardes oficial, apúrese que se nos hace tarde para subir al mirador.",
					"dialog_interrogate": "¿La fecha? Ah, es el pase del mes pasado... pensé que servía igual...",
					"doc": {
						"name": "Gastón Méndez",
						"dni": "29.800.123",
						"type": "Pase de Ingreso Diario",
						"date": "14/10/2026", # EXPIRADO
						"purpose": "Turismo",
						"passengers": 5,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": true
					},
					"car_items": ["Mochilas de trekking", "5 pasajeros apretados"],
					"should_pass": false,
					"rejection_reasons": ["Pase de ingreso vencido", "Supera el límite de 4 personas en alerta roja"],
					"parcel_impact": {"Cerro Chenque y Acantilados": -20}
				}
			]
		4:
			return [
				{
					"name": "Mauro 'El Trampero' Solís",
					"avatar_seed": 12,
					"car_name": "Jeep Ika Negro",
					"car_color": Color(0.2, 0.2, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas. Venimos a dar una vuelta por los cañadones del Chenque.",
					"dialog_interrogate": "¿Ese bulto en la manta? Son herramientas de mecánica nomás...",
					"doc": {
						"name": "Mauro Solís",
						"dni": "25.667.890",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Recorrido en 4x4",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Rifle calibre .22 con mira telescópica", "Trampas de zorro", "Gomera profesional"],
					"should_pass": false,
					"rejection_reasons": ["Prohibición estricta de armas de caza y trampas de fauna"],
					"parcel_impact": {"Cerro Chenque y Acantilados": -40, "Bosque de Lengas": -20}
				},
				{
					"name": "Esteban Corralón",
					"avatar_seed": 13,
					"car_name": "Camión F-350 Rojo",
					"car_color": Color(0.75, 0.2, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Vengo a descargar unas cositas acá al borde del parque.",
					"dialog_interrogate": "¿Permiso de obra municipal? No tengo, pero un amigo me dijo que podía ocupar ahí.",
					"doc": {
						"name": "Esteban Corralón",
						"dni": "32.401.999",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Carga y Descarga",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["10 Chapas de zinc", "Rollos de alambre de púa", "Postes de quebracho para delimitar"],
					"should_pass": false,
					"rejection_reasons": ["Materiales de usurpación de tierras sin permiso de catastro"],
					"parcel_impact": {"Cerro Chenque y Acantilados": -50}
				},
				{
					"name": "Elena Patrimonio",
					"avatar_seed": 14,
					"car_name": "Citroën C3 Bordo",
					"car_color": Color(0.5, 0.15, 0.25),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buen día señor Chenque. Venimos a la visita guiada del museo histórico.",
					"dialog_interrogate": "Traemos los pases de la comisión de patrimonio y las acreditaciones correspondientes.",
					"doc": {
						"name": "Elena Patrimonio",
						"dni": "27.819.002",
						"type": "Pase Oficial de Patrimonio",
						"date": "28/11/2026",
						"purpose": "Visita Museo Chalet Huergo",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Cuaderno de notas", "Grabador de voz", "Cámara fotográfica"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		5:
			return [
				{
					"name": "Inspector General Quintana",
					"avatar_seed": 15,
					"car_name": "Ford Ranger Oficial",
					"car_color": Color(0.9, 0.9, 0.9),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"dialog_intro": "Guardaparque Chenque, vengo de la Administración Central a supervisar el estado del parque.",
					"dialog_interrogate": "Toda mi credencial ministerial está en regla. Proceda según el protocolo.",
					"doc": {
						"name": "Inspector Quintana",
						"dni": "18.300.999",
						"type": "Credencial de Inspección Parques",
						"date": "28/11/2026",
						"purpose": "Inspección General",
						"passengers": 1,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Planillas oficiales de evaluación", "Radio troncal"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Mariano 'Piraña' Gómez",
					"avatar_seed": 16,
					"car_name": "Volkswagen Saveiro Negra",
					"car_color": Color(0.15, 0.15, 0.18),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Permiso guardabosques. Vamos a hacer pesca y asado en la restinga.",
					"dialog_interrogate": "Tengo el pase sellado... ¿qué falta?",
					"doc": {
						"name": "Mariano Gómez",
						"dni": "33.910.450",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Pesca y Asado",
						"passengers": 2,
						"fire_permit": false, # NO TIENE PERMISO FUEGO NI PESCA
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Carbón", "Arpón de buceo ilegal", "Parrilla oxidada"],
					"should_pass": false,
					"rejection_reasons": ["No posee Permiso de Pesca ni Permiso de Fuego"],
					"parcel_impact": {"Costa y Pingüinera": -25, "Chalet Histórico": -20}
				},
				{
					"name": "Familia Chubutense",
					"avatar_seed": 17,
					"car_name": "Toyota Corolla Gris",
					"car_color": Color(0.65, 0.68, 0.7),
					"declared_passengers": 3,
					"actual_passengers": 3,
					"dialog_intro": "Buenas tardes Mr. Chenque, una tarde hermosa para caminar por los miradores.",
					"dialog_interrogate": "Todo en regla como siempre, disfrutando el parque de nuestra querida Patagonia.",
					"doc": {
						"name": "Aníbal Trelew",
						"dni": "31.220.884",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Paseo Familiar",
						"passengers": 3,
						"fire_permit": false,
						"fishing_permit": false,
						"is_expired": false
					},
					"car_items": ["Termos de mate", "Bizcochitos de grasa", "Mantas de abrigo"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		_:
			return []
