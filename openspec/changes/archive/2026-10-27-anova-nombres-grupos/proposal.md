# Proposal

## Why

En la calculadora de ANOVA todo se llama "Grupo 1, Grupo 2…", aunque los ejercicios de clase comparan cosas concretas (carros, gasolinas, aditivos) con niveles con nombre propio (FORD, LAMBORGHINI). Leer los resultados y la conclusión en los términos del problema facilita interpretarlos y copiarlos a la tarea.

## What Changes

- Nuevo campo "Qué se compara" (en singular, ej. "Carro") con un selector **el / la**. Si queda vacío, se usa "Grupo" (comportamiento actual).
- El selector el/la se sugiere solo según la terminación de la palabra (-a → la) y el usuario lo puede cambiar.
- El plural se forma automáticamente (carro → carros, motor → motores).
- Cada grupo tiene un campo de nombre opcional (ej. FORD). Si queda vacío, el grupo se llama "<Qué se compara> <número>" (ej. "Carro 2"), como hoy con "Grupo 2".
- Los nombres se usan en el resumen por grupo, la gráfica, la tabla ANOVA ("entre carros") y la conclusión.
- La conclusión se redacta con el nombre y menciona la media: "Se rechaza H₀: por lo menos uno de los carros tiene una media diferente." / "…una de las gasolinas…".
- Dos grupos con el mismo nombre se rechazan con un error.
- El aviso de grupo vacío usa el nombre del grupo en lugar de "Grupo N".
- El servidor no cambia: los nombres son solo de presentación.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
- `anova-un-factor`: se agregan los nombres de lo que se compara y de cada grupo, la conclusión redactada con ellos y el rechazo de nombres repetidos; cambia el texto del aviso de grupo vacío en la página.

## Impact

- `views/anova.erb`: captura (campo "Qué se compara", selector el/la, nombre por grupo), validación en `calcular()` y textos de `renderResults()` y `graficar()`.
- `public/styles.css`: estilos del campo de nombre dentro de `.dyn-row`, si hacen falta.
- `app.rb` (`POST /calcular_anova`): sin cambios.
