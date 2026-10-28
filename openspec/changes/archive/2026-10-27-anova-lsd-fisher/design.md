# Design

## Context

`POST /calcular_anova` ya calcula `cmw` (CME), `gl_w` (N − k), las medias y los nᵢ de cada grupo, y `Estadistica.t_inv` existe (se usa en regresión). Los nombres de los grupos solo existen en la página (`textos()`), así que las frases con nombres se arman en el cliente. Ver proposal.md (Why) y la spec delta para el comportamiento.

El formato de la tabla sigue el que usan en clase (cuaderno): una columna por par, con los renglones H₀/Hₐ, |x̄ᵢ − x̄ⱼ| frente a LSD, decisión y conclusión.

## Goals / Non-Goals

**Goals:**
- Números calculados en el servidor y textos en el cliente, como en el resto de la página.
- Tabla legible en celular aunque haya muchos pares (k = 5 → 10 columnas).

**Non-Goals:**
- Otras pruebas post-hoc (Tukey, Bonferroni) y agrupación con letras.
- p-valores por par.
- Mostrar la sección cuando no se rechaza H₀.

## Decisions

**1. Cálculo en el servidor, siempre.**
`POST /calcular_anova` agrega:
```
lsd: {
  t: num(t), gl: gl_w, alfa_2: alfa / 2,
  mismo_n: true|false, lsd: num(valor) | nil,   # lsd común solo si todos los nᵢ son iguales
  pares: [{ i:, j:, dif: num(|x̄ᵢ − x̄ⱼ|), lsd: num(lsdᵢⱼ), rechaza: dif > lsdᵢⱼ }, ...]
}
```
con `t = Estadistica.t_inv(1 − α/2, N − k)` y `lsdᵢⱼ = t·√(CME·(1/nᵢ + 1/nⱼ))`, pares en orden i < j. La decisión `rechaza` se toma con los valores sin redondear, igual que la del ANOVA. Se calcula siempre (es barato) y la página decide si lo muestra con `d.rechaza`. Alternativa: calcularlo en el cliente con las medias del JSON; se descarta porque el cliente no tiene la t inversa y duplicaría la estadística que vive en `lib/estadistica.rb`.

**2. Ubicación: una tarjeta nueva después de "Tabla ANOVA".**
Sigue el orden del razonamiento (F → se rechaza → ¿cuáles?) y queda antes de la gráfica, que ayuda a comprobar visualmente los pares. Se oculta (`display: none`) cuando `!d.rechaza`.

**3. Cálculos previos con KaTeX.**
Tres líneas con `tex()` de `public/app.js` (con texto de respaldo):
- `t_{α/2,\,N-k} = t_{0.025,\,12} = 2.1788`
- `CME = 2.5`
- Siempre la fórmula con 1/nᵢ + 1/nⱼ (la que se usa en clase). Si `mismo_n`: `LSD = t\sqrt{CME(1/n_i + 1/n_j)} = 2.1788\sqrt{2.5(1/5 + 1/5)} = 2.1788`. Si no: `LSD_{ij} = t\sqrt{CME(1/n_i + 1/n_j)}` y el valor va en cada columna.

**4. Tabla por columnas en una sola fila.**
Como en el cuaderno, todas las columnas van en una fila: `.lsd-grid { display: flex; overflow-x: auto; }` con columnas `flex: 1 0 auto; min-width: 13rem` y bordes verticales entre ellas. Si caben, se reparten el ancho; si no (muchos pares o pantalla angosta), la tabla tiene scroll horizontal propio y la página no se desborda. El texto de la conclusión no ensancha la columna (se ajusta al ancho de las fórmulas). Contenido de cada columna:
1. **KaTeX:** `H_0: \mu_{\text{FORD}} = \mu_{\text{Carro 2}}` y `H_a: \mu_{\text{FORD}} \neq \mu_{\text{Carro 2}}` (μ con el nombre como subíndice).
2. **KaTeX:** `|\bar{x}_{\text{FORD}} - \bar{x}_{\text{Carro 2}}| = |23 - 28| = 5 > 2.1788` (o `\le`); con nᵢ distintos el LSD es el del par.
3. Texto: `Se rechaza H₀` (resaltado) o `No se rechaza H₀`.
4. Texto (nombres escapados con `esc()`): `FORD y Carro 2 son diferentes` o `No hay evidencia de que FORD y Carro 3 sean diferentes`.

Las fórmulas de los renglones 1 y 2 se dibujan con `tex()` igual que los cálculos previos, para que toda la sección tenga el mismo estilo matemático. Cada elemento lleva un texto de respaldo legible (`H₀: μ(FORD) = μ(Carro 2)`, `|23 − 28| = 5 > 2.1788`) por si KaTeX no carga.

**6. Nombres dentro de LaTeX.**
Los nombres son texto libre, así que se agrega `texNombre(s)`, que escapa para el modo `\text{}` de KaTeX: `\` → `\textbackslash{}`, `{ } $ & # _ %` → con `\` delante, `^` → `\textasciicircum{}` y `~` → `\textasciitilde{}`. Con `throwOnError: false` (ya configurado en `tex()`), un nombre raro nunca rompe la página. Alternativa: subíndices HTML (`μ<sub>FORD</sub>`); se descarta porque se vería con la letra de la página y no con la de las fórmulas.

**5. Versión del CSS.** Se sube `styles.css?v=14` a `v=15` en `views/layout.erb`, como en cada cambio de estilos.

## Risks / Trade-offs

- [Con muchos grupos la fila es muy larga (k = 8 → 28 columnas)] → Scroll horizontal dentro de la tabla; es el mismo formato que en el cuaderno.
- [Redondeo: la tabla muestra 4 decimales y una diferencia puede verse igual al LSD sin serlo] → La decisión usa los valores exactos; el texto muestra el signo (>, ≤) que corresponde a la decisión real.
- [LSD de Fisher no controla el error de comparaciones múltiples] → Es la prueba que se enseña en el curso; está fuera del alcance agregar otras.
