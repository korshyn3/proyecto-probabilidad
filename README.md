# 📊 Estadística — Calculadora de Varianza

Proyecto web en Ruby (Sinatra) para la materia de Probabilidad y Estadística.

## Instalación y uso

### 1. Instalar Sinatra (solo la primera vez)
```bash
gem install sinatra
```

### 2. Correr la app
```bash
ruby app.rb
```

### 3. Abrir en el navegador
Ir a: **http://localhost:4567**

---

## Funcionalidades actuales
- ✅ Cálculo de **varianza poblacional** (σ²)
- ✅ Cálculo de **varianza muestral** (s²)
- ✅ Desviación estándar poblacional y muestral
- ✅ Media aritmética
- ✅ Tabla paso a paso con cada (xᵢ − x̄)²

## Estructura del proyecto
```
estadistica_app/
├── app.rb           ← Servidor principal (Sinatra)
├── Gemfile          ← Dependencias
├── views/
│   └── index.erb    ← Página HTML
└── README.md
```
