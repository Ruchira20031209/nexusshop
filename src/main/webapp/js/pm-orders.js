document.addEventListener('DOMContentLoaded', () => {


  // Elements
  const globalSearch = document.getElementById('globalSearch');
  const globalSearchForm = document.getElementById('globalSearchForm');
  globalSearchForm?.addEventListener('submit', e => e.preventDefault());

  const searchInput = document.getElementById('searchInput');
  const statusFilter = document.getElementById('statusFilter');
  const paymentFilter = document.getElementById('paymentFilter');
  const fromDate = document.getElementById('fromDate');
  const toDate = document.getElementById('toDate');
  const sortSelect = document.getElementById('sortSelect');
  const clearFilters = document.getElementById('clearFilters');

  const tbody = document.getElementById('ordersTbody');
  const pagination = document.getElementById('pagination');
  const pageSizeSel = document.getElementById('pageSize');
  const resultMeta = document.getElementById('resultMeta');
  const selectAll = document.getElementById('selectAll');
  const bulkShip = document.getElementById('bulkShip');
  const bulkCancel = document.getElementById('bulkCancel');
  const bulkRefund = document.getElementById('bulkRefund');
  const exportBtn = document.getElementById('exportBtn');

  // Drawer
  const drawer = document.getElementById('orderDrawer');
  const drawerBody = document.getElementById('drawerBody');
  const drawerTitle = document.getElementById('drawerTitle');
  const drawerShip = document.getElementById('drawerShip');
  const drawerRefund = document.getElementById('drawerRefund');
  const drawerCancel = document.getElementById('drawerCancel');
  drawer.addEventListener('click', e => { if (e.target.hasAttribute('data-close')) closeDrawer(); });
  document.querySelectorAll('#orderDrawer [data-close]').forEach(b => b.addEventListener('click', closeDrawer));

  // Data (shared with admin)
  const KEY = 'nx_admin_orders_v1';
  let orders = seedIfEmpty(load());
  let filtered = [];
  let page = 1;
  let currentViewingId = null;

  function load(){ try { return JSON.parse(localStorage.getItem(KEY) || '[]'); } catch { return []; } }
  function persist(){ localStorage.setItem(KEY, JSON.stringify(orders)); }

  function seedIfEmpty(list){
    if (list.length) return list;
    const first = ['Alex','Sam','Jordan','Taylor','Jamie','Morgan','Riley','Casey','Avery','Harper','Elliot','Parker'];
    const last = ['Johnson','Lee','Chen','Patel','Rivera','Kim','Brown','Nguyen','Clark','Diaz','Shah','Park','Flores','Li','Gomez','Ahmed'];
    const out = [];
    for (let i=1;i<=140;i++){
      const id = 1000 + i;
      const name = `${first[i%first.length]} ${last[i%last.length]}`;
      const email = `${name.toLowerCase().replace(/[^a-z]/g,'.')}${id}@nexus.demo`;
      const d = new Date(); d.setDate(d.getDate() - Math.floor(Math.random()*180));
      const total = +(Math.random()*400 + 25).toFixed(2);
      const itemsCount = Math.floor(Math.random()*3)+1;
      const items = Array.from({length:itemsCount}, (_,k)=>({
        sku: `SKU-${id}-${k+1}`,
        title: `Sample Product ${k+1}`,
        qty: Math.floor(Math.random()*2)+1,
        price: +(Math.random()*120 + 10).toFixed(2),
        image: 'images/products/placeholder.png'
      }));
      const paid = Math.random() > .2;
      const refunded = Math.random() > .88;
      const status = refunded ? 'Refunded' : (paid ? (Math.random()>.5?'Shipped':'Paid') : 'Pending');
      out.push({
        id, customer: name, email, date: d.toISOString(), total, status,
        paymentStatus: refunded ? 'refunded' : (paid ? 'paid' : 'unpaid'),
        fulfillment: status==='Shipped' ? 'fulfilled' : (Math.random()>.7?'partial':'unfulfilled'),
        shipping: { name, address1:'123 Demo St', city:'Demo City', zip:'10001', country:'US' },
        items, notes: ''
      });
    }
    localStorage.setItem(KEY, JSON.stringify(out));
    return out;
  }

  // Helpers
  const fmt = new Intl.NumberFormat(undefined, { style:'currency', currency:'USD' });
  const escapeHtml = s => String(s||'').replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  function fmtDate(iso){ const d=new Date(iso); return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'})}`; }
  function withinRange(iso, from, to){
    const d = new Date(iso);
    if (from && d < new Date(from)) return false;
    if (to){ const t = new Date(to); t.setHours(23,59,59,999); if (d > t) return false; }
    return true;
  }
  function sortBy(arr, key, dir='asc'){ const m=dir==='asc'?1:-1; return [...arr].sort((a,b)=> (a[key]>b[key]?1:a[key]<b[key]?-1:0)*m); }
  function chunk(arr, size, p){ const s=(p-1)*size; return arr.slice(s, s+size); }

  // Filtering
  function applyFilters(){
    const term = (searchInput.value || globalSearch.value || '').toLowerCase().trim();
    const st = statusFilter.value; const pay = paymentFilter.value;
    const from = fromDate.value; const to = toDate.value;
    filtered = orders.filter(o => {
      const textHit = !term || [o.id,o.customer,o.email].join(' ').toLowerCase().includes(term);
      const stHit = !st || o.status === st;
      const payHit = !pay || o.paymentStatus === pay;
      const dateHit = withinRange(o.date, from, to);
      return textHit && stHit && payHit && dateHit;
    });
    const [key, dir] = sortSelect.value.split(':');
    filtered = sortBy(filtered, key, dir);
    page = 1; renderTable();
  }

  // Table rendering
  function rowHtml(o){
    const badge = `<span class="badge ${o.status}">${o.status}</span>`;
    const pay = o.paymentStatus === 'paid' ? 'Paid' : (o.paymentStatus==='refunded' ? 'Refunded' : 'Unpaid');
    const ff = o.fulfillment.charAt(0).toUpperCase() + o.fulfillment.slice(1);
    return `
      <tr>
        <td><input type="checkbox" class="row-check" data-id="${o.id}"/></td>
        <td>#${o.id}</td>
        <td>${escapeHtml(o.customer)}</td>
        <td class="hide-sm">${escapeHtml(o.email)}</td>
        <td>${fmtDate(o.date)}</td>
        <td>${fmt.format(o.total)}</td>
        <td>${badge}</td>
        <td class="hide-md">${pay}</td>
        <td class="hide-md">${ff}</td>
        <td class="row-actions">
          <button class="icon-btn" data-action="view" data-id="${o.id}" title="View"><i class="fa fa-eye"></i></button>
          <button class="icon-btn" data-action="ship" data-id="${o.id}" title="Ship"><i class="fa fa-truck"></i></button>
          <button class="icon-btn" data-action="refund" data-id="${o.id}" title="Refund"><i class="fa fa-rotate-left"></i></button>
          <button class="icon-btn" data-action="cancel" data-id="${o.id}" title="Cancel"><i class="fa fa-xmark"></i></button>
        </td>
      </tr>
    `;
  }
  function renderTable(){
    const size = Number(pageSizeSel.value);
    const total = filtered.length;
    const pages = Math.max(1, Math.ceil(total / size));
    if (page > pages) page = pages;
    tbody.innerHTML = filtered.slice((page-1)*size, (page)*size).map(rowHtml).join('');
    // pagination
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
    resultMeta.textContent = `${total.toLocaleString()} order${total===1?'':'s'}`;
    selectAll.checked = false;
  }

  // Events
  [searchInput,statusFilter,paymentFilter,fromDate,toDate,sortSelect].forEach(el => el.addEventListener('input', applyFilters));
  globalSearch?.addEventListener('input', () => { searchInput.value = globalSearch.value; applyFilters(); });
  clearFilters.addEventListener('click', () => {
    searchInput.value=''; statusFilter.value=''; paymentFilter.value=''; fromDate.value=''; toDate.value='';
    sortSelect.value='date:desc'; applyFilters();
  });
  pageSizeSel.addEventListener('change', renderTable);
  pagination.addEventListener('click', e => { const p = e.target.dataset.page; if (!p) return; page = Number(p); renderTable(); });

  document.querySelector('#ordersTable thead').addEventListener('click', e => {
    const th = e.target.closest('th[data-sort]'); if (!th) return;
    const key = th.dataset.sort; const [curKey, curDir] = sortSelect.value.split(':');
    sortSelect.value = `${key}:${(curKey===key && curDir==='asc') ? 'desc' : 'asc'}`; applyFilters();
  });

  // Row actions
  tbody.addEventListener('click', e => {
    const btn = e.target.closest('.icon-btn'); if (!btn) return;
    const id = Number(btn.dataset.id);
    const action = btn.dataset.action;
    if (action === 'view') openDrawer(id);
    if (action === 'ship') updateStatus([id], 'Shipped');
    if (action === 'refund') refundOrders([id]);
    if (action === 'cancel') updateStatus([id], 'Cancelled');
  });

  // Bulk
  selectAll.addEventListener('change', () => document.querySelectorAll('.row-check').forEach(cb => cb.checked = selectAll.checked));
  const selectedIds = () => [...document.querySelectorAll('.row-check:checked')].map(cb => Number(cb.dataset.id));
  bulkShip.addEventListener('click', () => updateStatus(selectedIds(), 'Shipped'));
  bulkCancel.addEventListener('click', () => updateStatus(selectedIds(), 'Cancelled'));
  bulkRefund.addEventListener('click', () => refundOrders(selectedIds()));

  function updateStatus(ids, status){
    if (!ids.length) return;
    orders.forEach(o => { if (ids.includes(o.id)) { o.status = status; if (status==='Shipped') o.fulfillment='fulfilled'; } });
    persist(); applyFilters();
    if (currentViewingId && ids.includes(currentViewingId)) openDrawer(currentViewingId);
  }
  function refundOrders(ids){
    if (!ids.length) return;
    if (!confirm(`Mark ${ids.length} order(s) as refunded?`)) return;
    orders.forEach(o => { if (ids.includes(o.id)) { o.status='Refunded'; o.paymentStatus='refunded'; } });
    persist(); applyFilters();
    if (currentViewingId && ids.includes(currentViewingId)) openDrawer(currentViewingId);
  }

  // Export
  exportBtn.addEventListener('click', () => {
    const rows = filtered.length ? filtered : orders;
    const head = ['id','customer','email','date','total','status','paymentStatus','fulfillment'];
    const lines = [head.join(',')];
    rows.forEach(o => lines.push([o.id, `"${o.customer}"`, `"${o.email}"`, new Date(o.date).toISOString(), o.total, o.status, o.paymentStatus, o.fulfillment].join(',')));
    const blob = new Blob([lines.join('\n')], {type:'text/csv;charset=utf-8;'});
    const url = URL.createObjectURL(blob); const a = Object.assign(document.createElement('a'), { href:url, download:'pm-orders.csv' });
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  });

  // Drawer
  function openDrawer(id){
    const o = orders.find(x=>x.id===id); if (!o) return;
    currentViewingId = id;
    drawerTitle.textContent = `Order #${o.id}`;
    drawerBody.innerHTML = `
      <div class="summary">
        <div><strong>Customer:</strong> ${escapeHtml(o.customer)} <span class="muted">(${escapeHtml(o.email)})</span></div>
        <div><strong>Date:</strong> ${fmtDate(o.date)}</div>
        <div><strong>Status:</strong> <span class="badge ${o.status}">${o.status}</span></div>
        <div><strong>Payment:</strong> ${o.paymentStatus}</div>
        <div><strong>Fulfillment:</strong> ${o.fulfillment}</div>
        <div class="muted">${escapeHtml(o.shipping.address1)}, ${escapeHtml(o.shipping.city)} ${escapeHtml(o.shipping.zip)}, ${escapeHtml(o.shipping.country)}</div>
      </div>
      <div class="items">
        ${o.items.map(it => `
          <div class="item-row" style="display:grid;grid-template-columns:52px 1fr auto;gap:.6rem;align-items:center;padding:.5rem 0;border-top:1px dashed rgba(0,0,0,.08);">
            <img src="${it.image}" alt="" style="width:52px;height:52px;border-radius:8px;object-fit:cover;background:#f6f6f9;"/>
            <div><div style="font-weight:700">${escapeHtml(it.title)}</div><div class="muted">SKU: ${escapeHtml(it.sku)} • Qty: ${it.qty}</div></div>
            <div>${fmt.format(it.price * it.qty)}</div>
          </div>
        `).join('')}
      </div>
      <div class="totals" style="display:grid;gap:.25rem;margin-top:.8rem;">
        <div class="line" style="display:flex;justify-content:space-between;"><span>Subtotal</span><span>${fmt.format(o.items.reduce((s,it)=> s+it.price*it.qty,0))}</span></div>
        <div class="line" style="display:flex;justify-content:space-between;"><span>Shipping</span><span>${fmt.format(10)}</span></div>
        <div class="line" style="display:flex;justify-content:space-between;"><span>Tax</span><span>${fmt.format(0.07*(o.items.reduce((s,it)=> s+it.price*it.qty,0)+10))}</span></div>
        <div class="line" style="display:flex;justify-content:space-between;font-weight:800;"><span>Total</span><span>${fmt.format(o.total)}</span></div>
      </div>
      <div class="form-row" style="margin-top:.8rem;">
        <label for="orderNotes"><strong>Internal Notes</strong></label>
        <textarea id="orderNotes" rows="3" class="input" style="width:100%;">${escapeHtml(o.notes || '')}</textarea>
      </div>
    `;
    drawer.setAttribute('aria-hidden','false');
    drawerShip.onclick = () => updateStatus([o.id],'Shipped');
    drawerRefund.onclick = () => refundOrders([o.id]);
    drawerCancel.onclick = () => updateStatus([o.id],'Cancelled');
    const notesEl = document.getElementById('orderNotes'); let t; notesEl.oninput = () => { clearTimeout(t); t=setTimeout(()=>{ o.notes=notesEl.value; persist(); }, 300); };
  }
  function closeDrawer(){ drawer.setAttribute('aria-hidden','true'); currentViewingId = null; }

  // Init
  applyFilters();
});
