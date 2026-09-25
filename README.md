# 📊 Aproxima2 — Calculadoras de Probabilidad y Estadística

Proyecto web en Ruby (Sinatra) para la materia de Probabilidad y Estadística.

## Módulos

| Sección | Página | Qué hace |
|---|---|---|
| Descriptiva | Varianza | σ², s², σ, s de un conjunto de datos |
| Descriptiva | Valor esperado | E[X], E[X²], Var(X), σ(X) de una variable discreta |
| Distribuciones | Normal | Probabilidades bajo N(0,1) y valor crítico k dado p |
| Distribuciones | t-Student | Probabilidades bajo t(ν), valor crítico t dado p y comparación con la normal |
| Inferencia | Tamaño de muestra | n para estimar una media o proporción (y E dado n), con corrección por población finita |
| Inferencia | ANOVA | ANOVA de un factor: tabla ANOVA, prueba F y p-valor |
| Regresión | Simple | Recta de mínimos cuadrados, r, R², prueba de la pendiente, gráficas de dispersión y residuos |
| Regresión | Múltiple | Varias variables x, R² ajustado, prueba F global y t por coeficiente |
| — | Problemas | Problemas resueltos |

## Requisitos

- **Ruby 3.4 o superior** (probado con 4.0).
  En Windows, instala **Ruby+Devkit** desde [rubyinstaller.org](https://rubyinstaller.org/downloads/) y al final corre `ridk install` → opción 3 (algunas gemas compilan código nativo).
- **Bundler** (viene con Ruby).

## Instalación y uso

### 1. Instalar dependencias (solo la primera vez)
```bash
bundle install
```

### 2. Correr la app
```bash
bundle exec ruby app.rb
```

### 3. Abrir en el navegador
Ir a: **http://localhost:4567**

En modo desarrollo los cambios en `app.rb` y `lib/` se recargan solos; los de `views/` y `public/` solo necesitan recargar la página.

> Las fórmulas (KaTeX) y las gráficas (Chart.js) se cargan desde un CDN, así que se necesita internet. Sin conexión las fórmulas se ven en texto lineal y las páginas con gráficas (normal, t-Student, ANOVA, regresión) no muestran resultados.

---

## Estructura del proyecto
```
proyecto-probabilidad/
├── app.rb               ← Servidor (rutas y cálculos)
├── config.ru            ← Arranque para servidores Rack
├── Gemfile              ← Dependencias
├── lib/
│   └── estadistica.rb   ← Distribuciones normal, t y F; álgebra de matrices
├── public/
│   ├── app.js           ← Funciones de JavaScript compartidas por las páginas
│   ├── styles.css       ← Estilos generales
│   ├── homeStyle.css    ← Estilos de la página de inicio
│   └── images/
└── views/
    ├── layout.erb       ← Plantilla común (menú, KaTeX)
    ├── home.erb         ← Inicio
    ├── varianza.erb
    ├── valor_esperado.erb
    ├── normal.erb
    ├── tstudent.erb
    ├── tamano_muestra.erb
    ├── anova.erb
    ├── regresion.erb
    ├── regresion_multiple.erb
    ├── problemas.erb
    └── acerca.erb
```
