Armame un prototipo para un juego en 2D estilo Parper’s Please.

# Contexto:

La dinámica del juego se basa en dejar pasar o rechazar gente que quiere entrar al parque nacional “chalet huergo”, son 5 dias en los cuales debemos ejercer nuestro trabajo. En el medio de esto hay gente que quiere entrar y mr chenque deberia revisar sus permisos, sus pertenencias, cantidad de personas y además controlar epoca del año, riesgo de incendio y animales presentes para poder tomar las decisiones. Si dejamos pasar a alguien que no deberiamos va a haber un impacto no solo en el parque, sino que tambien en el sueldo del personaje principal, el cual debe mantener un fondo para poder mantener a su familia y resolver problemas que se presentan dia a dia. 

## Jugabilidad  
Llega el visitante y se presenta con un diálogo. Podemos asomarse a ver su auto para identificar algún elemento sospechoso como carbón, cañas de pescar, lentes de buceo, armas para cazar, etc. Podemos ver sus documentos, permisos, etc. Luego de la resvisión tenemos que decidir (Aceptar / Rechazar). Al final del dia se ven las consecuencias.

## Vistas

### Vista 1 - Vista principal
La primera vista es la más fundamental del juego y se divide en 5 ventanas (3 en la parte superior, 2 en la inferior).

- 1° Ventana Superior izquierda: Es la ventana de la oficina donde se ve el auto de donde viene el visitante, debe tener el fondo del parque.
- 2° Ventana Superior medio: Se ve la imagen de la cara de los visitantes (se encuentran en la carpeta /public).
- 3° Ventana Superior derecha: Se debe ver un mapa general del parque. Este mapa refleja el estado del parque dividido en 5 parcelas y en el caso de que el jugador deje pasar a alguien incorrectamente las parcelas deben verse afectadas (Arboles cortados, edificios, un animal muerto, etc)
- 4° Ventana Inferior izquierda: es el escritorio del jugador y se ven los documentos del visitante (Permiso de pesca, Permiso de fogón, Identificación, Permiso de Oficio)
- 5° Ventana Inferior derecha: Botones de decisión (Aceptar, Rechazar, Inspeccionar y Leer Reglas del Parque).

### Vista 2 - Vista de investigación
Esta ventana se dispara cuando el jugador decide investigar al visitante. Se conserva la vista principal con cambios en las siguientes ventanas:

- Ventana Superior Derecha: El mapa desaparece y se muestra el baúl abierto del auto del visitante con los objetos que porta.
- Ventana Superior Medio: Debe haber un boton para interrogar al visitante y que suelte un diálogo.
- Ventana Inferior Derecha: Desaparece el boton investigar y solo se puede aceptar o rechazar el paso al visitante (También se conserva la posibilidad de leer las reglas).
