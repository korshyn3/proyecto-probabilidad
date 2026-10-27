# Tasks

## 1. Servidor (`app.rb`, `POST /calcular_anova`)

- [x] 1.1 Quitar `.reject(&:empty?)` al leer `grupos` y, después de validar que hay al menos 2 grupos, lanzar `"El Grupo N está vacío"` para el primer grupo sin datos; verificar con `curl -s -X POST localhost:4567/calcular_anova -F 'grupos=["1 2","","3 4"]'` que la respuesta es `status: error` con "El Grupo 2 está vacío"
- [x] 1.2 Confirmar que el orden de las validaciones es: ≥ 2 grupos, ningún grupo vacío, ≥ 2 datos por grupo; verificar con `curl` que `["1 2","5","3 4"]` responde "Cada grupo necesita al menos 2 datos" y que `["1 2",""]` responde "El Grupo 2 está vacío"
- [x] 1.3 Verificar que el ejemplo de la página (`["23, 25, 21, 22, 24","27, 29, 26, 28, 30","22, 20, 24, 21, 23"]`) sigue dando F = 20.666667 y F crítica = 3.885294

## 2. Página (`views/anova.erb`, `calcular()`)

- [x] 2.1 Reemplazar `.filter(v => v)` por una revisión de todos los textarea que, al encontrar el primero vacío (incluso solo con espacios), llame a `mostrarError('El Grupo N está vacío: llénalo o quítalo con ×')` sin enviar la petición; verificar en el navegador que con el Grupo 2 vacío aparece ese mensaje y no se muestran resultados
- [x] 2.2 Verificar en el navegador que con los 3 grupos llenos la fila "Grupo 2" del resumen y la columna "Grupo 2" de la gráfica tienen los datos del campo Grupo 2
- [x] 2.3 Verificar en el navegador que al quitar el Grupo 2 con × los campos se renumeran como Grupo 1 y Grupo 2 y los resultados usan esa numeración
