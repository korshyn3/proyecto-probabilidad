// Funciones compartidas por las calculadoras

// Número con hasta 6 decimales, sin ceros de sobra. null = infinito (JSON no tiene ∞)
function fmt(n, dec = 6) {
  if (n === null || n === undefined) return '∞';
  return parseFloat(Number(n).toFixed(dec)).toString();
}

// p-valor: los muy pequeños se muestran como "< 0.0001"
function fmtP(p) {
  if (p === null || p === undefined) return '—';
  return p < 0.0001 ? '< 0.0001' : fmt(p, 4);
}

// Celda de resultado: símbolo (sin mayúsculas) + nombre + valor
function celda(sym, nombre, valor, featured = false) {
  return `
    <div class="stat-cell${featured ? ' featured' : ''}">
      <div class="sc-label"><span class="sc-sym">${sym}</span>${nombre}</div>
      <div class="sc-value">${valor}</div>
    </div>`;
}

// Grupo con título y celdas apiladas (usar dentro de .res-split)
function grupoRes(titulo, celdas, nota = '') {
  return `
    <div class="res-group">
      <div class="res-title">${titulo}${nota ? ` <span class="res-note">${nota}</span>` : ''}</div>
      <div class="stats-grid res-cells">${celdas.join('')}</div>
    </div>`;
}

// Recuadro de conclusión de una prueba de hipótesis
function conclusion(rechaza, titulo, texto) {
  return `
    <div class="decision ${rechaza ? 'decision-si' : 'decision-no'}">
      <div class="decision-title">${titulo}</div>
      <div class="decision-text">${texto}</div>
    </div>`;
}

function mostrarError(msg) {
  const box = document.getElementById('errorBox');
  box.textContent = '✕  ' + msg;
  box.style.display = 'block';
}

// POST al servidor; muestra el spinner en el botón mientras responde.
// Devuelve los datos o null si hubo error (el error ya se muestra).
async function enviar(ruta, campos, btn) {
  document.getElementById('errorBox').style.display = 'none';
  document.getElementById('results').style.display = 'none';
  const texto = btn.textContent;
  btn.innerHTML = '<span class="spinner"></span>';
  btn.disabled = true;
  try {
    const fd = new FormData();
    Object.entries(campos).forEach(([k, v]) => fd.append(k, v));
    const res = await fetch(ruta, { method: 'POST', body: fd });
    const data = await res.json();
    if (data.status === 'error') { mostrarError(data.mensaje); return null; }
    return data;
  } catch (e) {
    mostrarError('Error de conexión con el servidor.');
    return null;
  } finally {
    btn.textContent = texto;
    btn.disabled = false;
  }
}

// Enter en un campo = Calcular (en los textarea no mete salto de línea)
function enterCalcula(ids, fn) {
  ids.forEach(id => {
    const el = document.getElementById(id);
    if (el) el.addEventListener('keydown', e => {
      if (e.key === 'Enter') { e.preventDefault(); fn(); }
    });
  });
}

// ── Íconos: mini campana con el área sombreada de cada tipo ──────────────────
const AREAS_ICONO = {
  left:    [[-4, 0.5]],
  right:   [[0.5, 4]],
  between: [[-0.8, 1.1]],
  tails:   [[-4, -1.2], [1.2, 4]],
  center:  [[-1, 1]],
};

function iconoCampana(tipo) {
  const W = 64, H = 26;
  const px = z => (W / 2 + z * W / 8).toFixed(1);
  const py = z => (H - 1 - (H - 4) * Math.exp(-z * z / 2)).toFixed(1);
  const tramo = (a, b) => {
    const pts = [];
    for (let z = a; z < b; z += 0.1) pts.push(`${px(z)},${py(z)}`);
    pts.push(`${px(b)},${py(b)}`);
    return pts.join(' L');
  };
  const areas = AREAS_ICONO[tipo].map(([a, b]) =>
    `<path d="M${px(a)},${H - 1} L${tramo(a, b)} L${px(b)},${H - 1} Z" fill="currentColor" fill-opacity="0.35"/>`
  ).join('');
  return `<svg class="mode-icon" viewBox="0 0 ${W} ${H}" aria-hidden="true">
    ${areas}
    <path d="M${tramo(-4, 4)}" fill="none" stroke="currentColor" stroke-width="1.3"/>
    <line x1="0" y1="${H - 1}" x2="${W}" y2="${H - 1}" stroke="currentColor" stroke-width="1"/>
  </svg>`;
}

function ponerIconos() {
  document.querySelectorAll('[data-icon]').forEach(b => {
    b.classList.add('has-icon');
    b.innerHTML = iconoCampana(b.dataset.icon) + `<span>${b.innerHTML}</span>`;
  });
}

// Opciones comunes de Chart.js para que todas las gráficas se vean iguales
const FUENTE_GRAFICA = { family: "'IBM Plex Mono', monospace", size: 11 };
const COLOR_ACENTO = '#1a3a6b';
const COLORES_SERIE = ['#1a3a6b', '#2f7d5b', '#b5651d', '#7a1a5c', '#4a6fa5', '#8a7a1a', '#5c1a7a', '#1a6f7a'];

function ejesGrafica(tituloX, tituloY) {
  const eje = titulo => ({
    type: 'linear',
    title: { display: !!titulo, text: titulo, font: FUENTE_GRAFICA },
    ticks: { font: FUENTE_GRAFICA },
    grid: { color: 'rgba(0,0,0,0.06)' },
  });
  return { x: eje(tituloX), y: eje(tituloY) };
}

// Los textarea empiezan de una línea y crecen conforme se escribe
function ajustarAltura(t) {
  t.style.height = 'auto';
  t.style.height = (t.scrollHeight + t.offsetHeight - t.clientHeight) + 'px';
}

document.addEventListener('input', e => {
  if (e.target.tagName === 'TEXTAREA') ajustarAltura(e.target);
});
window.addEventListener('resize', () => document.querySelectorAll('textarea').forEach(ajustarAltura));

// Dibuja LaTeX en un elemento; si KaTeX no cargó, deja el texto de respaldo
function tex(el, latex, respaldo) {
  if (window.katex) katex.render('\\displaystyle ' + latex, el, { throwOnError: false });
  else el.textContent = respaldo || latex;
}
