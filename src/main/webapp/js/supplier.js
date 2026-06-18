document.addEventListener('DOMContentLoaded', () => {


  // Elements
  const supGlobalSearch = document.getElementById('supGlobalSearch');
  const supGlobalForm = document.getElementById('supGlobalForm'); supGlobalForm?.addEventListener('submit', e => e.preventDefault());

  const lowThresholdEl = document.getElementById('lowThreshold');
  const kpiLow = document.getElementById('kpiLow');
  const kpiOut = document.getElementById('kpiOut');
  const kpiUpdates = document.getElementById('kpiUpdates');
  const kpiRequests = document.getElementById('kpiRequests');

  const chipBtns = [...document.querySelectorAll('.chip-group .chip')];
  const lowSearch = document.getElementById('lowSearch');
  const lowSort = document.getElementById('lowSort');
  const lowTbody = document.getElementById('lowTbody');

  const histSearch = document.getElementById('histSearch');
  const fromDate = document.getElementById('fromDate');
  const toDate = document.getElementById('toDate');
  const histTbody = document.getElementById('histTbody');

  const reqProduct = document.getElementById('reqProduct');
  const reqQty = document.getElementById('reqQty');
  const reqPriority = document.getElementById('reqPriority');
  const reqNote = document.getElementById('reqNote');
  const reqForm = document.getElementById('requestForm');
  const reqTbody = document.getElementById('reqTbody');

  // Data stores (shared + supplier-specific)
  const PRODUCTS_KEY = 'nx_admin_products_v1';
  const UPDATES_KEY  = 'nx_supplier_updates_v1';  // change history
  const REQUESTS_KEY = 'nx_supplier_requests_v1'; // restock requests

  const LOW_THRESHOLD = 5;

  // Loaders
  function loadProducts(){ try { return JSON.parse(localStorage.getItem(PRODUCTS_KEY) || '[]'); } catch { return []; } }
  function saveProducts(list){ localStorage.setItem(PRODUCTS_KEY, JSON.stringify(list)); }
  function loadUpdates(){ try { return JSON.parse(localStorage.getItem(UPDATES_KEY) || '[]'); } catch { return []; } }
  function saveUpdates(arr){ localStorage.setItem(UPDATES_KEY, JSON.stringify(arr)); }
  function loadRequests(){ try { return JSON.parse(localStorage.getItem(REQUESTS_KEY) || '[]'); } catch { return []; } }
  function saveRequests(arr){ localStorage.setItem(REQUESTS_KEY, JSON.stringify(arr)); }

  // State
  let products = seedProducts(loadProducts());
  let updates = loadUpdates();
  let requests = loadRequests();
  let invScope = 'low';
  let lowList = [];

  // Seed minimal products if empty (for first run demo)
  function seedProducts(list){
    if (list.length) return list;
    const cats = ['Phones','Laptops','Audio','Gaming','Accessories','Monitors'];
    const out = [];
    for (let i=1;i<=18;i++){
      out.push({
        id: 3000+i, title:`${cats[i%cats.length]} Sample ${i}`, sku:`SUP-${cats[i%cats.length].slice(0,3).toUpperCase()}-${1000+i}`,
        category: cats[i%cats.length], price:+(Math.random()*200+30).toFixed(2), stock: Math.floor(Math.random()*10),
        status: ['Active','Draft','Archived'][i%3], created: new Date().toISOString(), images:[]
      });
    }
    saveProducts(out); return out;
  }

  // Utils
  const escapeHtml = s => String(s||'').replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const fmtDateTime = iso => { const d = new Date(iso); return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'})}`; };

  // ----- KPIs -----
  function updateKpis(){
    const low = products.filter(p => p.stock > 0 && p.stock <= LOW_THRESHOLD);
    const out = products.filter(p => p.stock === 0);
    const since = new Date(); since.setDate(since.getDate()-7);
    const upd7 = updates.filter(u => new Date(u.time) >= since).length;
    const pending = requests.filter(r => r.status === 'pending').length;

    kpiLow.textContent = low.length;
    kpiOut.textContent = out.length;
    kpiUpdates.textContent = upd7;
    kpiRequests.textContent = pending;
    lowThresholdEl.textContent = LOW_THRESHOLD;
  }

  // ----- Low Stock Alerts -----
  chipBtns.forEach(b => b.addEventListener('click', () => {
    chipBtns.forEach(x => x.classList.remove('active')); b.classList.add('active');
    invScope = b.dataset.scope; buildLowList(); renderLowTable();
  }));
  lowSearch.addEventListener('input', renderLowTable);
  lowSort.addEventListener('change', renderLowTable);
  supGlobalSearch?.addEventListener('input', () => { lowSearch.value = supGlobalSearch.value; renderLowTable(); });

  function buildLowList(){
    const low = products.filter(p => p.stock > 0 && p.stock <= LOW_THRESHOLD);
    const out = products.filter(p => p.stock === 0);
    lowList = invScope === 'low' ? low : invScope === 'out' ? out : [...low, ...out];
  }
  function renderLowTable(){
    const term = (lowSearch.value || '').toLowerCase().trim();
    let list = lowList.filter(p => !term || [p.title, p.sku].join(' ').toLowerCase().includes(term));
    const [key, dir] = lowSort.value.split(':'); const mult = dir==='asc'?1:-1;
    list.sort((a,b)=> (a[key]>b[key]?1:a[key]<b[key]?-1:0)*mult);
    lowTbody.innerHTML = list.map(p => `
      <tr>
        <td>${escapeHtml(p.title)}</td>
        <td class="hide-sm">${escapeHtml(p.sku)}</td>
        <td>${p.stock}</td>
        <td><span class="badge ${p.status}">${p.status}</span></td>
        <td><button class="btn btn-ghost req-btn" data-id="${p.id}"><i class="fa fa-paper-plane"></i> Request</button></td>
      </tr>
    `).join('');
    // quick request wiring
    document.querySelectorAll('.req-btn').forEach(btn => btn.addEventListener('click', () => {
      const id = Number(btn.dataset.id);
      reqProduct.value = String(id);
      document.getElementById('reqQty').focus();
      window.scrollTo({ top: document.getElementById('requestForm').getBoundingClientRect().top + window.scrollY - 100, behavior: 'smooth' });
    }));
  }

  // ----- History -----
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

  // ----- Requests -----
  function populateReqProducts(){
    reqProduct.innerHTML = products
      .slice()
      .sort((a,b)=> a.title.localeCompare(b.title))
      .map(p => `<option value="${p.id}">${escapeHtml(p.title)} — [${escapeHtml(p.sku)}] (stock: ${p.stock})</option>`)
      .join('');
  }
  function renderRequests(){
    const rows = requests.slice().sort((a,b)=> new Date(b.time) - new Date(a.time));
    reqTbody.innerHTML = rows.map(r => `
      <tr>
        <td>${fmtDateTime(r.time)}</td>
        <td>${escapeHtml(r.title)}</td>
        <td class="hide-sm">${escapeHtml(r.sku)}</td>
        <td>${r.qty}</td>
        <td>${r.priority}</td>
        <td><span class="badge ${r.status==='pending'?'Draft':'Active'}">${r.status}</span></td>
      </tr>
    `).join('');
  }
  reqForm.addEventListener('submit', e => {
    e.preventDefault();
    const id = Number(reqProduct.value); const qty = Number(reqQty.value || 0);
    if (!id || !qty || qty < 1) return alert('Choose a product and enter a valid quantity.');
    const p = products.find(x => x.id === id); if (!p) return;
    const record = {
      id: 'REQ-' + (requests.length + 1),
      time: new Date().toISOString(),
      productId: p.id, sku: p.sku, title: p.title,
      qty, priority: reqPriority.value, note: reqNote.value.trim(), status: 'pending'
    };
    requests.push(record); saveRequests(requests);
    reqForm.reset(); populateReqProducts(); renderRequests(); updateKpis();
    alert('Restock request submitted.');
  });

  // ----- Init -----
  function init(){
    populateReqProducts();
    buildLowList(); renderLowTable();
    renderHistory();
    renderRequests();
    updateKpis();
  }
  init();
});
