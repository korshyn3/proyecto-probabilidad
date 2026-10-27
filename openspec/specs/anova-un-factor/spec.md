# anova-un-factor Specification

## Purpose

Calculadora de ANOVA de un factor: recibe los datos de k grupos, valida la captura y presenta la prueba F con los resultados numerados por grupo.

## Requirements

### Requirement: Grupos vacíos rechazados con su número
El sistema SHALL rechazar el cálculo cuando algún grupo capturado esté vacío (sin datos o solo con espacios) y SHALL mostrar un error que indique el número de ese grupo tal como aparece en pantalla. El sistema MUST NOT descartar grupos vacíos ni calcular con los grupos restantes. La regla aplica tanto en la página como en el servidor.

#### Scenario: Grupo intermedio vacío en la página
- **WHEN** el usuario tiene 3 grupos, deja vacío el Grupo 2 y pulsa Calcular
- **THEN** no se muestran resultados y aparece el error "El Grupo 2 está vacío: llénalo o quítalo con ×"

#### Scenario: Grupo con solo espacios
- **WHEN** un grupo contiene únicamente espacios o saltos de línea
- **THEN** se trata como vacío y se muestra el error con su número

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
