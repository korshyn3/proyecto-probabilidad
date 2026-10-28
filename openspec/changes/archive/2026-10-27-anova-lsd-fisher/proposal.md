# Proposal

## Why

Cuando el ANOVA rechaza H₀ solo se sabe que al menos una media es diferente, no cuáles. En clase el siguiente paso es la prueba LSD (diferencia mínima significativa) de Fisher, que compara las medias par por par. Hoy hay que hacerla a mano con los valores de la tabla ANOVA.

## What Changes

- Cuando el ANOVA rechaza H₀, aparece una sección "Prueba LSD de Fisher" con:
  - **Cálculos**: t crítica t(α/2, N − k), CME (de la tabla ANOVA) y el valor LSD, con su fórmula.
  - **Tabla de comparaciones** en el estilo de clase: una columna por cada par de grupos con H₀ / Hₐ, la comparación |x̄ᵢ − x̄ⱼ| frente a LSD, la decisión (se rechaza / no se rechaza H₀) y la conclusión con los nombres de los grupos.
- Si los grupos tienen tamaños distintos, el LSD se calcula para cada par.
- Cuando el ANOVA no rechaza H₀, la sección no aparece.
- El servidor agrega a la respuesta de `POST /calcular_anova` la t crítica y las comparaciones por par (cambio aditivo; los campos existentes no cambian).
- No se muestra p-valor en la prueba LSD; la decisión es por comparación con LSD, como en clase.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
- `anova-un-factor`: se agrega la prueba LSD de Fisher después de un rechazo de H₀ (cálculos, comparación por par y conclusión).

## Impact

- `app.rb` (`POST /calcular_anova`): cálculo de t crítica, LSD y comparaciones por par; campos nuevos en el JSON.
- `views/anova.erb`: nueva tarjeta de resultados y su render.
- `public/styles.css` (+ versión en `views/layout.erb`): estilo de la tabla por columnas.
- Sin dependencias nuevas: se usa `Estadistica.t_inv`, que ya existe.
