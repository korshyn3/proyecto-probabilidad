# anova-un-factor Specification

## Purpose

Calculadora de ANOVA de un factor: recibe los datos de k grupos, valida la captura y presenta la prueba F con los resultados numerados por grupo.

## Requirements

### Requirement: Grupos vacíos rechazados con su número
El sistema SHALL rechazar el cálculo cuando algún grupo capturado esté vacío (sin datos o solo con espacios) y SHALL mostrar un error que identifique ese grupo: en la página, por su nombre (propio o "<Qué se compara> <número>"); en el servidor, por su número de posición. El sistema MUST NOT descartar grupos vacíos ni calcular con los grupos restantes. La regla aplica tanto en la página como en el servidor.

#### Scenario: Grupo intermedio vacío en la página
- **WHEN** el usuario tiene 3 grupos sin nombre, sin "Qué se compara", deja vacío el Grupo 2 y pulsa Calcular
- **THEN** no se muestran resultados y aparece el error "Faltan datos en Grupo 2: escribe sus valores o quita la fila con ×"

#### Scenario: Grupo con nombre vacío en la página
- **WHEN** el grupo llamado "FORD" no tiene datos y el usuario pulsa Calcular
- **THEN** aparece el error "Faltan datos en FORD: escribe sus valores o quita la fila con ×"

#### Scenario: Grupo con solo espacios
- **WHEN** un grupo contiene únicamente espacios o saltos de línea
- **THEN** se trata como vacío y se muestra el error con su nombre

#### Scenario: Petición al servidor con un grupo vacío
- **WHEN** el servidor recibe una lista de grupos donde el tercero no tiene datos
- **THEN** responde con estado de error y un mensaje que indica que el Grupo 3 está vacío

### Requirement: Numeración de resultados igual a la captura
El sistema SHALL numerar los grupos en los resultados (resumen por grupo y gráfica) con el mismo número que tienen en los campos de captura.

#### Scenario: Todos los grupos llenos
- **WHEN** el usuario llena los grupos 1, 2 y 3 y pulsa Calcular
- **THEN** la fila "Grupo 2" del resumen y la columna "Grupo 2" de la gráfica corresponden a los datos escritos en el campo Grupo 2

#### Scenario: Grupo quitado con ×
- **WHEN** el usuario quita el Grupo 2 con el botón × y calcula con los grupos restantes
- **THEN** los campos se renumeran como Grupo 1 y Grupo 2, y los resultados usan esa misma numeración

### Requirement: Orden de las validaciones de grupos
El sistema SHALL validar en este orden: al menos 2 grupos, ningún grupo vacío y al menos 2 datos por grupo; SHALL reportar el primer error encontrado.

#### Scenario: Grupo vacío no se reporta como falta de datos
- **WHEN** hay 3 grupos y el Grupo 2 está vacío
- **THEN** el error indica que el Grupo 2 está vacío, no que necesita al menos 2 datos

#### Scenario: Grupo con un solo dato
- **WHEN** todos los grupos tienen datos pero uno tiene un solo valor
- **THEN** el error indica que cada grupo necesita al menos 2 datos

### Requirement: Nombre de lo que se compara
La página SHALL ofrecer un campo opcional "Qué se compara" (sustantivo en singular) con un selector de artículo el/la. Si el campo está vacío, el sistema SHALL usar "Grupo" con artículo "el". El selector SHALL sugerirse según la terminación (-a → la, otro caso → el) mientras el usuario no lo cambie a mano. El plural SHALL formarse automáticamente.

#### Scenario: Campo vacío
- **WHEN** el usuario no escribe nada en "Qué se compara"
- **THEN** los grupos se llaman "Grupo 1", "Grupo 2"… y la conclusión habla de "los grupos"

#### Scenario: Artículo sugerido
- **WHEN** el usuario escribe "Gasolina"
- **THEN** el selector cambia a "la" y el plural es "gasolinas"

#### Scenario: Artículo cambiado a mano
- **WHEN** el usuario elige "el" en el selector y después escribe "Día"
- **THEN** el selector se queda en "el"

#### Scenario: Plural de palabra terminada en consonante
- **WHEN** el usuario escribe "Motor"
- **THEN** el plural es "motores"

### Requirement: Nombre de cada grupo
Cada grupo SHALL tener un campo de nombre opcional. Si está vacío, el nombre del grupo SHALL ser "<Qué se compara> <número de posición>". El nombre del grupo SHALL usarse en el resumen por grupo, en la gráfica y en los mensajes de error de ese grupo.

#### Scenario: Nombre propio
- **WHEN** "Qué se compara" es "Carro" y el primer grupo se llama "FORD"
- **THEN** la fila del resumen y la columna de la gráfica de ese grupo dicen "FORD"

#### Scenario: Nombre vacío
- **WHEN** "Qué se compara" es "Carro" y el segundo grupo no tiene nombre
- **THEN** ese grupo aparece como "Carro 2"

#### Scenario: Grupo quitado
- **WHEN** hay tres grupos sin nombre y el usuario quita el segundo con ×
- **THEN** los grupos restantes aparecen como "Carro 1" y "Carro 2"

### Requirement: Nombres de grupo repetidos rechazados
El sistema SHALL rechazar el cálculo cuando dos grupos tengan el mismo nombre (sin distinguir mayúsculas ni espacios al inicio o al final) y SHALL indicar el nombre repetido.

#### Scenario: Nombre repetido
- **WHEN** dos grupos se llaman "Ford" y "FORD "
- **THEN** no se muestran resultados y aparece un error que indica que el nombre "FORD" está repetido

### Requirement: Conclusión redactada con lo que se compara
La conclusión de la prueba SHALL usar el plural y el artículo de lo que se compara y SHALL mencionar la media. Al rechazar H₀: "por lo menos uno de los <plural> tiene una media diferente" (con "la": "una de las"). Al no rechazar, SHALL decir que no hay evidencia suficiente de que las medias de los <plural> sean diferentes.

#### Scenario: Rechazo con palabra masculina
- **WHEN** "Qué se compara" es "Carro" y F supera el valor crítico
- **THEN** la conclusión dice "Se rechaza H₀" y "por lo menos uno de los carros tiene una media diferente"

#### Scenario: Rechazo con palabra femenina
- **WHEN** "Qué se compara" es "Gasolina" con artículo "la" y F supera el valor crítico
- **THEN** la conclusión dice "por lo menos una de las gasolinas tiene una media diferente"

#### Scenario: No rechazo
- **WHEN** "Qué se compara" es "Aditivo" y F no supera el valor crítico
- **THEN** la conclusión dice "No se rechaza H₀" y que no hay evidencia suficiente de que las medias de los aditivos sean diferentes

### Requirement: Tabla ANOVA con lo que se compara
Las fuentes de variación de la tabla ANOVA SHALL nombrarse con lo que se compara: "Tratamientos (entre <plural>)" y "Error (dentro de cada <singular>)".

#### Scenario: Tabla con "Carro"
- **WHEN** "Qué se compara" es "Carro"
- **THEN** las filas dicen "Tratamientos (entre carros)" y "Error (dentro de cada carro)"

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
