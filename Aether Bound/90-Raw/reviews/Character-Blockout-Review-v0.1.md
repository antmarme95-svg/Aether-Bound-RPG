# Character Blockout Review v0.1 — humano base (C6)

> **Fuente RAW del director (Boris), 2026-07-10.** Depositado verbatim desde
> la sesión de la ventana C6/C4 (capturas r3 de `tmp_anatomy.gd`). No se edita.
> Checklist de aceptación viva: [[Task-Board]] §C6.

## Estado general

Resultado: **Needs Revision**

El modelo ya comunica un personaje humanoide estilizado y es funcional para
pruebas en Godot. Sin embargo, todavía se aleja considerablemente del concept
aprobado en los aspectos que definen la identidad visual del juego.

Los principales problemas no son técnicos sino de proporciones, silueta y
lenguaje visual. Si estas bases no se corrigen ahora, cualquier trabajo
posterior de rigging, animación, texturizado o equipamiento heredará estos
problemas.

## CRITICAL

### 1. La silueta no coincide con el concept

El personaje del concept tiene una silueta claramente atlética. El modelo
actual produce una lectura mucho más cercana a: cuerpo rectangular, hombros
estrechos, torso plano, piernas demasiado cilíndricas. A distancia el
personaje pierde personalidad.

Corrección requerida:
- Incrementar anchura de hombros aproximadamente un 10–15%.
- Reducir ligeramente la cintura.
- Dar mayor volumen al pecho.
- Marcar mejor el cambio entre tórax y pelvis.

### 2. La cabeza es demasiado grande

En el concept: cuerpo ≈ 7.5 cabezas. En el modelo: visualmente parece
alrededor de 6.5–7 cabezas. Eso hace que el personaje se vea más
caricaturesco de lo previsto.

Corrección requerida: reducir ligeramente el tamaño de la cabeza o
incrementar la longitud del cuerpo.

### 3. El cuello prácticamente no existe

El concept tiene: cuello largo, postura relajada, línea continua
cabeza-hombros. Actualmente: cabeza incrustada entre los hombros. Produce
una apariencia rígida.

Corrección requerida:
- aumentar longitud del cuello
- bajar ligeramente la línea de hombros

### 4. Brazos demasiado finos

El concept representa un atleta. No un personaje delgado. Actualmente
bíceps, tríceps y antebrazos son extremadamente estrechos.

Corrección requerida: dar más masa muscular sin llegar a un estilo heroico.

## HIGH

### 5. Las piernas son demasiado cilíndricas

Todo mantiene casi el mismo grosor. En el concept existen cuádriceps,
rodilla y gemelo claramente diferenciados.

Corrección requerida: introducir cambios de volumen.

### 6. Manos demasiado pequeñas

Comparando con el concept: las manos deberían llegar aproximadamente a media
pierna y tener mayor presencia visual. Actualmente parecen reducidas.

### 7. Los pies son muy pequeños

Esto afecta incluso a gameplay. Pies ligeramente mayores: mejor estabilidad
visual, mejor contacto con el suelo, mejor lectura durante animaciones.

### 8. El torso carece de planos anatómicos

Actualmente parece una caja. En el concept existen planos diferenciados para
pecho, abdomen, costillas, clavículas. No hace falta añadir detalle. Solo
modificar la geometría.

## MEDIUM

### 9. La cara perdió completamente el lenguaje del concept

El concept transmite: mandíbula marcada, nariz fina, mejillas altas, sonrisa
ligera, personalidad. El modelo actual es prácticamente un placeholder. Es
suficiente para un prototipo, pero no representa la identidad del personaje.

### 10. El peinado no conserva la forma original

En el concept: cabello corto con volumen hacia atrás. En el modelo: parece
un bloque colocado encima. Debe simplificarse respetando la dirección del
concept.

### 11. La ropa perdió las capas

El concept utiliza múltiples capas: tela, cinturones, pañuelo, faldón,
brazales. El modelo simplifica todo a planos muy básicos. Para un blockout
esto es aceptable, pero debería empezar a distinguir las masas principales.

### 12. Falta peso visual en los accesorios

Actualmente mochila, cinturón y hombreras se perciben demasiado planos. No
generan profundidad.

## LOW

### 13. Los brazos están excesivamente pegados al cuerpo

Convendría utilizar una postura más cercana a una A-Pose. Facilitará
skinning, rigging y lectura anatómica.

### 14. La postura es demasiado rígida

El concept transmite una ligera relajación. Actualmente parece un maniquí
completamente vertical.

### 15. La transición hombro-brazo necesita suavizarse

Actualmente el deltoides termina muy abruptamente.

## Dirección artística

Hay un aspecto que considero el más importante. El concept no intenta
parecer anime. Tampoco pretende parecer low poly. Busca algo similar a:
**Breath of the Wild, Dungeons of Hinterberg, Palia, Torchlight III.**

Es decir: anatomía estilizada, proporciones humanas, pocos polígonos,
siluetas muy limpias, mucho trabajo en formas grandes.

En este momento el personaje se acerca más a un placeholder funcional que a
un personaje perteneciente al universo artístico definido.

## Aspectos positivos

- La escala general del personaje respecto al mundo es consistente.
- La cantidad de geometría es adecuada para un primer blockout.
- La topología parece limpia para iterar.
- La implementación en Godot permite validar rápidamente proporciones en contexto.
- La mochila, la correa y el equipo comienzan a comunicar el rol de explorador.
- El estilo low-poly es compatible con la dirección técnica del proyecto.

## Prioridad de implementación

1. Corregir proporciones generales (cabeza, cuello, hombros, torso).
2. Mejorar la silueta atlética.
3. Remodelar brazos y piernas para reflejar la anatomía estilizada del concept.
4. Ajustar manos y pies.
5. Rehacer la cabeza y el peinado siguiendo el concept.
6. Recuperar las capas principales de la vestimenta.
7. Refinar accesorios y postura.

## Valoración general

Si el objetivo del sprint era validar la integración del personaje en Godot
y establecer un primer bloque de geometría, el avance es sólido. Sin embargo,
desde la perspectiva de dirección de arte, el modelo se encuentra
aproximadamente en un **60–65% de fidelidad** respecto al concept de
referencia. Las desviaciones principales están en la anatomía y la silueta,
no en el motor ni en la complejidad técnica del modelo. Corregir esos
fundamentos ahora reducirá retrabajo en las siguientes etapas de producción.
