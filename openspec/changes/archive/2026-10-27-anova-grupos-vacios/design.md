# Design

## Context

Hoy hay dos filtros que eliminan grupos vacíos:

- `views/anova.erb`, `calcular()`: `.map(t => t.value.trim()).filter(v => v)`
- `app.rb`, `POST /calcular_anova`: `.map { |g| parse_lista(g) }.reject(&:empty?)`

Los grupos se numeran por su posición en la lista resultante (`renderResults` usa `Grupo ${i + 1}`), así que cualquier hueco renumera los grupos siguientes. Ver proposal.md (Why).

## Goals / Non-Goals

**Goals:**
- Que la posición de cada grupo en la lista enviada sea la misma que en pantalla, sin huecos.
- Mensajes de error con el número de grupo que ve el usuario.

**Non-Goals:**
- Cambiar la forma de mostrar los resultados (siguen numerándose por posición).
- Nombres personalizados para los grupos.
- Otros cambios de validación (mínimos, formato de números).

## Decisions

**1. Rechazar en lugar de saltar los grupos vacíos.**
Alternativa considerada: seguir saltándolos, pero enviar también el número original de cada grupo para etiquetar los resultados. Se descarta porque añade un campo al JSON y cambia el render para un caso que casi siempre es un descuido; el usuario ya tiene el botón × para quitar un grupo que no quiere.

**2. Validar en ambos lados.**
- Cliente: se recorren todos los textarea; en el primero vacío (solo espacios cuenta como vacío) se llama a `mostrarError('El Grupo N está vacío: llénalo o quítalo con ×')` sin enviar la petición. Así el error aparece al instante.
- Servidor: se elimina `.reject(&:empty?)` y se lanza `raise "El Grupo #{i + 1} está vacío"` si algún grupo queda sin datos tras `parse_lista`. Garantiza la regla aunque la petición no venga de la página.

**3. Orden de las validaciones.**
Primero el conteo de grupos (≥ 2), luego los grupos vacíos y después el mínimo de datos por grupo. Así un grupo vacío no se reporta como "necesita al menos 2 datos".

## Risks / Trade-offs

- [Un usuario que antes dejaba una fila vacía a propósito ahora ve un error] → El mensaje dice cómo resolverlo (llenarlo o quitarlo con ×).
- [Mensajes duplicados entre cliente y servidor] → Ambos usan el mismo texto base con el número de grupo; el del servidor solo se ve si falla la validación del cliente.
