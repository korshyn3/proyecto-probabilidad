# Tasks

## 1. Captura de nombres (`views/anova.erb`, `public/styles.css`)

- [x] 1.1 Agregar arriba de los grupos el campo `#factor` ("Qué se compara", placeholder "Grupo") y el selector `#articulo` (el/la), con la sugerencia por terminación hasta que el usuario lo cambie a mano; verificar en el navegador que al escribir "Gasolina" cambia a "la", y que tras elegir "el" a mano y escribir "Día" se queda en "el"
- [x] 1.2 Cambiar la `.dyn-label` de cada fila por un `<input class="dyn-name">` con placeholder `<Qué se compara> <n>`, actualizado por `renumerar()` y al escribir en `#factor`, con estilo `.dyn-row .dyn-name` del mismo ancho que la etiqueta; verificar en el navegador que los placeholders dicen "Grupo 1…3", que cambian a "Carro 1…3" al escribir "Carro" y que se renumeran al quitar una fila; y que regresión múltiple se sigue viendo igual

## 2. Textos y validación (`views/anova.erb`)

- [x] 2.1 Agregar `textos()` (singular, plural, artículo, nombres) y `esc()`; verificar desde la consola del navegador que el plural da carro→carros, gasolina→gasolinas, motor→motores, lápiz→lápices, que el campo vacío da "Grupo"/"grupos"/"el", y que `esc('<b>')` devuelve `&lt;b&gt;`
- [x] 2.2 En `calcular()`, cambiar el aviso de grupo vacío a "Faltan datos en <nombre>: escribe sus valores o quita la fila con ×" y agregar el rechazo de nombres propios repetidos (sin distinguir mayúsculas ni espacios), en ese orden; verificar en el navegador con el Grupo 2 vacío, con "FORD" vacío y con "Ford" / "FORD " repetidos

## 3. Resultados con los nombres (`views/anova.erb`)

- [x] 3.1 Usar los nombres en el resumen por grupo (encabezado = singular, filas = nombres escapados) y en las marcas del eje X de la gráfica; verificar en el navegador con "Carro", el primer grupo llamado "FORD" y los otros sin nombre, que el resumen y la gráfica muestran "FORD", "Carro 2", "Carro 3"
- [x] 3.2 Redactar la conclusión y las filas de la tabla ANOVA con plural, singular y artículo; verificar en el navegador con el ejemplo de la página (que rechaza H₀) que "Carro" da "por lo menos uno de los carros tiene una media diferente", que "Gasolina" da "una de las gasolinas", que con datos que no rechazan y "Aditivo" sale "las medias de los aditivos sean diferentes", y que la tabla dice "entre carros" / "dentro de cada carro"
- [x] 3.3 Verificar en el navegador que con "Qué se compara" vacío y sin nombres la página muestra "Grupo 1…" en el resumen y la gráfica, "entre grupos" en la tabla y "uno de los grupos" en la conclusión, y que `POST /calcular_anova` sigue respondiendo igual al ejemplo (F = 20.666667)
