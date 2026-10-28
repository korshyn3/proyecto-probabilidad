# Spec Delta

## ADDED Requirements

### Requirement: Prueba LSD de Fisher solo al rechazar H₀
La página SHALL mostrar la sección "Prueba LSD de Fisher" únicamente cuando el ANOVA rechaza H₀. Cuando no se rechaza H₀, la sección MUST NOT mostrarse.

#### Scenario: ANOVA rechaza
- **WHEN** el usuario calcula el ejemplo de la página (F = 20.6667 > 3.8853)
- **THEN** aparece la sección "Prueba LSD de Fisher" después de la tabla ANOVA

#### Scenario: ANOVA no rechaza
- **WHEN** el usuario calcula datos con F menor o igual al valor crítico
- **THEN** la sección "Prueba LSD de Fisher" no aparece

### Requirement: Cálculos previos de la prueba LSD
Antes de las comparaciones, la sección SHALL mostrar la t crítica t(α/2, N − k) con sus grados de libertad, el CME de la tabla ANOVA y la fórmula LSD = t·√(CME·(1/nᵢ + 1/nⱼ)). Si todos los grupos tienen el mismo tamaño n, SHALL mostrarse esa fórmula con los valores sustituidos y un solo LSD; si no, SHALL mostrarse el LSD de cada par.

#### Scenario: Grupos del mismo tamaño
- **WHEN** se calcula el ejemplo de la página (3 grupos de 5, CME = 2.5, α = 0.05)
- **THEN** se muestra t(0.025, 12) = 2.1788, CME = 2.5 y LSD = 2.1788·√(2.5·(1/5 + 1/5)) = 2.1788

#### Scenario: Grupos de distinto tamaño
- **WHEN** los grupos tienen 4, 5 y 6 datos y el ANOVA rechaza H₀
- **THEN** se muestra la fórmula con 1/nᵢ + 1/nⱼ y cada par muestra su propio LSD

### Requirement: Comparación de cada par de medias
La sección SHALL incluir una comparación por cada par de grupos (i < j, en el orden de captura), presentada como una columna con: H₀: μᵢ = μⱼ y Hₐ: μᵢ ≠ μⱼ usando los nombres de los grupos; la comparación |x̄ᵢ − x̄ⱼ| frente al LSD con sus valores; la decisión; y la conclusión. Se rechaza H₀ del par cuando |x̄ᵢ − x̄ⱼ| > LSD.

#### Scenario: Par diferente
- **WHEN** en el ejemplo con "Carro" se comparan FORD (x̄ = 23) y Carro 2 (x̄ = 28)
- **THEN** la columna muestra "|23 − 28| = 5 > 2.1788", "Se rechaza H₀" y "FORD y Carro 2 son diferentes"

#### Scenario: Par no diferente
- **WHEN** en el ejemplo con "Carro" se comparan FORD (x̄ = 23) y Carro 3 (x̄ = 22)
- **THEN** la columna muestra "|23 − 22| = 1 ≤ 2.1788", "No se rechaza H₀" y que no hay evidencia de que FORD y Carro 3 sean diferentes

#### Scenario: Número de comparaciones
- **WHEN** hay k grupos
- **THEN** se muestran k·(k − 1)/2 columnas, en orden (1,2), (1,3)…, (2,3)…

#### Scenario: Diferencia igual al LSD
- **WHEN** |x̄ᵢ − x̄ⱼ| es exactamente igual al LSD
- **THEN** no se rechaza H₀ para ese par
