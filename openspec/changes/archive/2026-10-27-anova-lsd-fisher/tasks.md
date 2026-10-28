# Tasks

## 1. Cálculo en el servidor (`app.rb`, `POST /calcular_anova`)

- [x] 1.1 Calcular `t = Estadistica.t_inv(1 − α/2, N − k)`, el LSD de cada par (i < j) y su decisión `dif > lsd` con valores sin redondear, y devolver `lsd: { t, gl, alfa_2, mismo_n, lsd, pares: [{ i, j, dif, lsd, rechaza }] }`; verificar con `curl` sobre el ejemplo de la página que `t` = 2.178813, `lsd` = 2.178813, `mismo_n` = true y los pares (1,2), (1,3), (2,3) tienen `dif` 5, 1, 6 y `rechaza` true, false, true
- [x] 1.2 Verificar con `curl` usando grupos de 4, 5 y 6 datos que `mismo_n` = false, `lsd` = null y cada par trae su propio LSD igual a t·√(CME·(1/nᵢ + 1/nⱼ)); y que los campos existentes de la respuesta (F, F crítica, tabla) no cambian

## 2. Sección en la página (`views/anova.erb`, `public/styles.css`, `views/layout.erb`)

- [x] 2.1 Agregar la tarjeta "Prueba LSD de Fisher" después de "Tabla ANOVA", visible solo si `d.rechaza`, con los cálculos de t, CME y LSD con `tex()` (un LSD común si `mismo_n`, fórmula con 1/nᵢ + 1/nⱼ si no); verificar en el navegador que con el ejemplo aparece con t(0.025, 12) = 2.1788, CME = 2.5 y LSD = 2.1788, y que con datos que no rechazan la tarjeta no aparece
- [x] 2.2 Agregar `texNombre()` para escapar nombres dentro de `\text{}`; verificar desde la consola del navegador que `texNombre('A_1 & {x} 50% $')` se dibuja con `tex()` sin error de KaTeX y muestra el texto tal cual
- [x] 2.3 Agregar la tabla por columnas (`.lsd-grid`) con H₀/Hₐ y la comparación |x̄ᵢ − x̄ⱼ| dibujadas con KaTeX (μ con el nombre como subíndice), la decisión y la conclusión en texto con nombres escapados, y subir `styles.css` a `v=15`; verificar en el navegador con "Carro" y el primer grupo "FORD" que hay 3 columnas, que las fórmulas se ven con KaTeX (elementos `.katex` sin `.katex-error`), que FORD–Carro 2 muestra 5 > 2.1788, "Se rechaza H₀" y "FORD y Carro 2 son diferentes", y que FORD–Carro 3 muestra ≤, "No se rechaza H₀" y "No hay evidencia de que FORD y Carro 3 sean diferentes"; revisar en captura que μ lleva el nombre como subíndice
- [x] 2.4 Verificar en el navegador con 5 grupos que hay 10 columnas en orden (1,2), (1,3)…(4,5), con grupos de distinto tamaño que cada columna muestra su LSD, y revisar con capturas a 1100 px y a 400 px de ancho que todas las columnas quedan en una sola fila, con scroll horizontal dentro de la tabla cuando no caben y sin desbordar la página
