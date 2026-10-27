# Spec Delta

## ADDED Requirements

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

## MODIFIED Requirements

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
