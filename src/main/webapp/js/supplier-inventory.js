document.addEventListener('DOMContentLoaded', () => {


  // Elements
  const invGlobal = document.getElementById('invGlobal');
  const invGlobalForm = document.getElementById('invGlobalForm'); invGlobalForm?.addEventListener('submit', e => e.preventDefault());

  const searchInput = document.getElementById('searchInput');
  const statusFilter = document.getElementById('statusFilter');
  const sortSelect = document.getElementById('sortSelect');
  const prodTbody = document.getElementById('prodTbody');
  const pageSizeSel = document.getElementById('pageSize');
  const pagination = document.getElementById('pagination');

  const batchTbody = document.getElementById('batchTbody');
  const clearBatch = document.getElementById('clearBatch');
  const applyBatch = document.getElementById('applyBatch');

  const histSearch = document.getElementById('histSearch');
  const fromDate = document.getElementById('fromDate');
  const toDate = document.getElementById('toDate');
  const histTbody = document.getElementById('histTbody');

  // Data stores
  const PRODUCTS_KEY = 'nx_admin_products_v1';
  const UPDATES_KEY  = 'nx_supplier_updates_v1';

  // Load/save
  function loadProducts(){ try { return JSON.parse(localStorage.getItem(PRODUCTS_KEY) || '[]'); } catch { return []; } }
  function saveProducts(list){ localStorage.setItem(PRODUCTS_KEY, JSON.stringify(list)); }
  function loadUpdates(){ try { return JSON.parse(localStorage.getItem(UPDATES_KEY) || '[]'); } catch { return []; } }
  function saveUpdates(arr){ localStorage.setItem(UPDATES_KEY, JSON.stringify(arr)); }

  // State
  let products = seedProducts(loadProducts());
  let updates = loadUpdates();
  let filtered = [];
  let page = 1;
  let batch = []; // { id, title, sku, prev, next }

  // Seed (if empty)
  function seedProducts(list){
    if (list.length) return list;
    const cats = ['Phones','Laptops','Audio','Gaming','Accessories','Monitors'];
    const out = [];
    for (let i=1;i<=20;i++){
      out.push({ id:3000+i, title:`${cats[i%cats.length]} Sample ${i}`, sku:`SUP-${cats[i%cats.length].slice(0,3).toUpperCase()}-${1000+i}`, category: cats[i%cats.length], price:+(Math.random()*200+30).toFixed(2), stock: Math.floor(Math.random()*15), status:['Active','Draft','Archived'][i%3], created:new Date().toISOString(), images:[] });
    }
    saveProducts(out); return out;
  }

  // Utils
  const escapeHtml = s => String(s||'').replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const fmtDateTime = iso => { const d=new Date(iso); return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'})}`; };

  // Filtering
  [searchInput, statusFilter, sortSelect].forEach(el => el.addEventListener('input', applyFilters));
  invGlobal?.addEventListener('input', () => { searchInput.value = invGlobal.value; applyFilters(); });

  function applyFilters(){
    const term = (searchInput.value || '').toLowerCase().trim();
    const st = statusFilter.value;
    const [key, dir] = sortSelect.value.split(':');
    filtered = products.filter(p => (!term || [p.title, p.sku].join(' ').toLowerCase().includes(term)) && (!st || p.status===st));
    const mult = dir==='asc'?1:-1;
    filtered.sort((a,b)=> (a[key]>b[key]?1:a[key]<b[key]?-1:0)*mult);
    page = 1; renderTable();
  }

  // Table
  pageSizeSel.addEventListener('change', renderTable);
  pagination.addEventListener('click', e => {
    const p = e.target.dataset.page; if (!p) return; page = Number(p); renderTable();
  });

  function renderTable(){
    const size = Number(pageSizeSel.value);
    const pages = Math.max(1, Math.ceil(filtered.length / size));
    if (page > pages) page = pages;
    const rows = filtered.slice((page-1)*size, page*size);
    prodTbody.innerHTML = rows.map(p => `
      <tr>
        <td>${escapeHtml(p.title)}</td>
        <td class="hide-sm">${escapeHtml(p.sku)}</td>
        <td>${p.stock}</td>
        <td><input class="newqty" data-id="${p.id}" type="number" min="0" step="1" placeholder="${p.stock}" style="width:90px"/></td>
        <td><button class="btn btn-ghost add-btn" data-id="${p.id}"><i class="fa fa-plus"></i> Add</button></td>
        <td><button class="btn btn-primary update-btn" data-id="${p.id}"><i class="fa fa-check"></i> Update</button></td>
      </tr>
    `).join('');

    // Wire per-row buttons
    document.querySelectorAll('.add-btn').forEach(b => b.addEventListener('click', () => addToBatch(Number(b.dataset.id))));
    document.querySelectorAll('.update-btn').forEach(b => b.addEventListener('click', () => updateSingle(Number(b.dataset.id))));
  }

  // Batch cart
  clearBatch.addEventListener('click', () => { batch = []; renderBatch(); });
  applyBatch.addEventListener('click', applyBatchUpdates);

  function addToBatch(id){
    const p = products.find(x=>x.id===id); if (!p) return;
    const input = document.querySelector(`.newqty[data-id="${id}"]`);
    const next = Number(input?.value || NaN);
    if (!Number.isFinite(next) || next < 0) return alert('Enter a valid new quantity.');
    const existing = batch.find(x => x.id === id);
    if (existing){ existing.next = next; existing.delta = next - existing.prev; }
    else batch.push({ id, title: p.title, sku: p.sku, prev: p.stock, next, delta: next - p.stock });
    renderBatch();
  }
  function removeFromBatch(id){ batch = batch.filter(x => x.id !== id); renderBatch(); }
  function renderBatch(){
    batchTbody.innerHTML = batch.map(b => `
      <tr>
        <td>${escapeHtml(b.title)}</td>
        <td class="hide-sm">${escapeHtml(b.sku)}</td>
        <td>${b.prev}</td>
        <td>${b.next}</td>
        <td>${b.delta>=0?`+${b.delta}`:b.delta}</td>
        <td><button class="btn btn-ghost" data-remove="${b.id}"><i class="fa fa-xmark"></i></button></td>
      </tr>
    `).join('');
    batchTbody.querySelectorAll('[data-remove]').forEach(btn => btn.addEventListener('click', () => removeFromBatch(Number(btn.dataset.remove))));
  }

  // Single update
  function updateSingle(id){
    const p = products.find(x=>x.id===id); if (!p) return;
    const input = document.querySelector(`.newqty[data-id="${id}"]`);
    const next = Number(input?.value || NaN);
    if (!Number.isFinite(next) || next < 0) return alert('Enter a valid new quantity.');
    if (next === p.stock) return alert('No change.');
    const prev = p.stock; p.stock = next; saveProducts(products);
    logUpdate([{ id:p.id, title:p.title, sku:p.sku, prev, next }], 'single-'+Date.now(), '');
    applyFilters(); renderHistory();
    alert('Stock updated.');
  }

  // Apply batch
  function applyBatchUpdates(){
    if (!batch.length) return alert('Batch is empty.');
    const batchId = 'BATCH-' + Date.now();
    // Apply
    batch.forEach(bi => {
      const p = products.find(x=>x.id===bi.id);
      if (p){ p.stock = bi.next; }
    });
    saveProducts(products);
    // Log
    logUpdate(batch.map(bi => ({ id:bi.id, title:bi.title, sku:bi.sku, prev:bi.prev, next:bi.next })), batchId, '');
    // Reset
    batch = []; renderBatch(); applyFilters(); renderHistory();
    alert('Batch applied.');
  }

  function logUpdate(items, batchId, note){
    let arr = loadUpdates();
    const now = new Date().toISOString();
    items.forEach(it => {
      arr.push({
        id: 'UPD-' + (arr.length + 1),
        time: now, productId: it.id, sku: it.sku, title: it.title,
        prev: it.prev, next: it.next, delta: it.next - it.prev,
        batchId, note, who: 'supplier'
      });
    });
    saveUpdates(arr);
    updates = arr;
  }

  // History log
  [histSearch, fromDate, toDate].forEach(el => el.addEventListener('input', renderHistory));
  function renderHistory(){
    const term = (histSearch.value || '').toLowerCase().trim();
    const from = fromDate.value ? new Date(fromDate.value) : null;
    const to = toDate.value ? new Date(toDate.value + 'T23:59:59') : null;
    const list = updates
      .filter(u => (!term || [u.title, u.sku].join(' ').toLowerCase().includes(term)))
      .filter(u => (!from || new Date(u.time) >= from) && (!to || new Date(u.time) <= to))
      .sort((a,b)=> new Date(b.time) - new Date(a.time));
    histTbody.innerHTML = list.map(u => `
      <tr>
        <td>${fmtDateTime(u.time)}</td>
        <td>${escapeHtml(u.title)}</td>
        <td class="hide-sm">${escapeHtml(u.sku)}</td>
        <td>${u.prev} → <strong>${u.next}</strong> ${u.delta>=0?`(+${u.delta})`:`(${u.delta})`}</td>
        <td class="hide-sm">${u.batchId || '—'}</td>
        <td>${escapeHtml(u.note || '')}</td>
      </tr>
    `).join('');
  }

  // Pagination helper
  function renderPagination(total, size){
    const pages = Math.max(1, Math.ceil(total / size));
    let html = '';
    const btn = (p, label=p) => `<button data-page="${p}" class="${p===page?'active':''}">${label}</button>`;
    if (pages > 1){
      html += btn(Math.max(1, page-1), '‹');
      for (let i=1;i<=pages;i++){
        if (i===1 || i===pages || Math.abs(i-page)<=2) html += btn(i);
        else if (!html.endsWith('…')) html += '<span>…</span>';
      }
      html += btn(Math.min(pages, page+1), '›');
    }
    pagination.innerHTML = html;
  }

  // Override renderTable to include pagination painting
  const _renderTable = renderTable;
  renderTable = function(){
    const size = Number(pageSizeSel.value);
    const total = filtered.length;
    const pages = Math.max(1, Math.ceil(total / size));
    if (page > pages) page = pages;
    const rows = filtered.slice((page-1)*size, page*size);
    prodTbody.innerHTML = rows.map(p => `
      <tr>
        <td>${escapeHtml(p.title)}</td>
        <td class="hide-sm">${escapeHtml(p.sku)}</td>
        <td>${p.stock}</td>
        <td><input class="newqty" data-id="${p.id}" type="number" min="0" step="1" placeholder="${p.stock}" style="width:90px"/></td>
        <td><button class="btn btn-ghost add-btn" data-id="${p.id}"><i class="fa fa-plus"></i> Add</button></td>
        <td><button class="btn btn-primary update-btn" data-id="${p.id}"><i class="fa fa-check"></i> Update</button></td>
      </tr>
    `).join('');
    renderPagination(total, size);
    document.querySelectorAll('.add-btn').forEach(b => b.addEventListener('click', () => addToBatch(Number(b.dataset.id))));
    document.querySelectorAll('.update-btn').forEach(b => b.addEventListener('click', () => updateSingle(Number(b.dataset.id))));
  };

  pagination.addEventListener('click', e => { const p=e.target.dataset.page; if (!p) return; page = Number(p); renderTable(); });

  // Init
  (function init(){
    applyFilters();
    renderBatch();
    renderHistory();
  })();
});
