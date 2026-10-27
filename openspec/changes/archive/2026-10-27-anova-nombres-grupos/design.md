# Design

## Context

Hoy `views/anova.erb` genera "Grupo ${i + 1}" en cuatro lugares: la etiqueta `.dyn-label` de cada fila (`renumerar()`), el resumen (`renderResults()`), las marcas del eje X (`graficar()`) y el aviso de grupo vacío (`calcular()`). La conclusión y la tabla ANOVA usan textos fijos ("al menos una media es diferente", "entre grupos"). El servidor solo recibe `grupos` y `alfa` y no sabe de nombres. Ver proposal.md (Why) y la spec delta para el comportamiento.

## Goals / Non-Goals

**Goals:**
- Un solo lugar que calcule los textos (singular, plural, artículo, nombre de cada grupo) y que usen todas las partes de la página.
- Con "Qué se compara" vacío y sin nombres, la página se ve exactamente como hoy, salvo los textos de la conclusión y del aviso de grupo vacío.

**Non-Goals:**
- Guardar los nombres entre visitas.
- Cambiar el contrato de `POST /calcular_anova`.
- Concordancia de género fuera de la conclusión (los mensajes se redactan de forma neutra).

## Decisions

**1. Nombres solo en el cliente.**
Se calculan en la página y no se envían al servidor. `renderResults(d)` ya recibe los grupos en el mismo orden en que se capturaron (garantizado por el cambio anterior), así que basta con indexar por posición. Alternativa: mandar los nombres y que el servidor los devuelva; se descarta porque solo sirven para mostrar y obligaría a validarlos también en Ruby.

**2. Un objeto `textos()` que se lee al calcular.**
`textos()` lee los campos y devuelve `{ singular, plural, art: 'el'|'la', nombres: [...] }`:
- `singular`: el campo recortado, o "Grupo" si está vacío.
- `plural`: si termina en vocal (con o sin acento) → +s; en "z" → cambia z por "ces"; en "s" o "x" → igual; en otra consonante → +es.
- `nombres[i]`: el nombre propio recortado, o `${singular} ${i + 1}`.
- En las frases se usa `plural` y `singular` con la primera letra en minúscula ("los carros"). En etiquetas y encabezados se usan tal como se escribieron, con la primera letra en mayúscula.

Se llama una vez en `calcular()`, y su resultado se guarda para `renderResults()` y `graficar()`. Así, si el usuario cambia un nombre después de calcular, los resultados no cambian hasta que vuelve a calcular, igual que con los datos.

**3. Captura.**
- Arriba de los grupos: `<label class="mini-field">Qué se compara <input id="factor" placeholder="Grupo"> <select id="articulo">el/la</select></label>`.
- El selector se sugiere en el evento `input` del campo (termina en "a" → la; si no → el) hasta que el usuario lo cambie a mano; desde entonces se respeta su elección (bandera `articuloManual`).
- En cada `.dyn-row`, la etiqueta `.dyn-label` se cambia por un `<input class="dyn-name">` cuyo placeholder es el nombre por defecto (`Grupo 2`, `Carro 2`). `renumerar()` y el `input` del campo "Qué se compara" actualizan los placeholders.
- La rejilla de `.dyn-row` es compartida con regresión múltiple; se agrega una regla `.dyn-row .dyn-name` con el mismo ancho que `.dyn-label` en lugar de cambiar la rejilla.

**4. Validación en `calcular()`, en este orden:** grupo vacío (con su nombre), nombres repetidos (comparando con `trim().toLowerCase()` solo entre nombres propios no vacíos) y después el envío al servidor. Los nombres por defecto no pueden chocar entre sí, porque llevan números distintos.

**5. Escapar los nombres.**
Los textos se insertan con `innerHTML`, así que se agrega una función `esc()` en la vista que reemplaza `& < > " '`. La gráfica (Chart.js) dibuja texto en el canvas y no necesita escaparlos.

**6. Redacción.**
- Rechazo: `por lo menos ${art === 'la' ? 'una de las' : 'uno de los'} ${plural} tiene una media diferente.`
- No rechazo: `No hay evidencia suficiente para decir que las medias de ${art === 'la' ? 'las' : 'los'} ${plural} sean diferentes.`
- Tabla ANOVA: `Tratamientos (entre ${plural})` y `Error (dentro de cada ${singular})`.
- Aviso de grupo vacío: `Faltan datos en ${nombre}: escribe sus valores o quita la fila con ×`.

## Risks / Trade-offs

- [Plural automático incorrecto en palabras irregulares (ej. "Análisis", "Régimen")] → El usuario puede escribir otra palabra; el caso es raro en los ejercicios y la conclusión sigue siendo entendible.
- [Sugerencia de artículo incorrecta (ej. "Día", "Problema")] → El selector queda visible y editable; una vez cambiado a mano, ya no se sobrescribe.
- [Nombres largos desbordan el eje X de la gráfica] → Chart.js rota las etiquetas automáticamente; no se agrega lógica extra.
- [La spec actual promete "El Grupo N está vacío" en la página] → Se modifica esa regla en esta spec delta; el mensaje del servidor no cambia.
