# Proposal

## Why

En la calculadora de ANOVA, los grupos vacíos se descartan en silencio antes de calcular, tanto en el navegador como en el servidor. Si el usuario deja vacío un grupo intermedio, los grupos siguientes se renumeran y el "Grupo i" de los resultados ya no es el "Grupo i" de la pantalla, lo que lleva a leer mal la tabla de resumen y la gráfica.

## What Changes

- Un grupo vacío deja de ignorarse: el cálculo se detiene y se muestra un error que indica el número del grupo vacío tal como aparece en pantalla (ej. "El Grupo 2 está vacío").
- El servidor aplica la misma regla: si recibe un grupo vacío, responde con un error que indica su número, en vez de quitarlo de la lista.
- Con eso, la numeración de los resultados (resumen por grupo y gráfica) siempre coincide con la de los campos de captura.
- Sin cambios en: el mínimo de 2 grupos, el mínimo de 2 datos por grupo, el formato de números (solo punto decimal) ni el contenido de los resultados.

## Capabilities

### New Capabilities
- `anova-un-factor`: calculadora de ANOVA de un factor: captura de datos por grupo, validación de los grupos y numeración de los grupos en los resultados.

### Modified Capabilities
<!-- Ninguna: el proyecto aún no tiene specs. -->

## Impact

- `views/anova.erb`: función `calcular()` (validación antes de enviar).
- `app.rb`: ruta `POST /calcular_anova` (lectura y validación de `grupos`).
- Sin dependencias nuevas ni cambios en otras calculadoras.
