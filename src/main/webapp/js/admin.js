/* Admin Dashboard – storage-first mock; swap to backend calls later */
document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const sidebar = document.getElementById('sidebar');
  const toggleBtn = document.querySelector('.sidebar-toggle');
  const rangeSelect = document.getElementById('rangeSelect');
  const exportBtn = document.getElementById('exportBtn');
  const globalSearch = document.getElementById('globalSearch');
  const notifDot = document.getElementById('notifDot');

  const kpiRevenue = document.getElementById('kpiRevenue');
  const kpiOrders = document.getElementById('kpiOrders');
  const kpiCustomers = document.getElementById('kpiCustomers');
  const kpiConversion = document.getElementById('kpiConversion');
  const kpiRevenueTrend = document.getElementById('kpiRevenueTrend');
  const kpiOrdersTrend = document.getElementById('kpiOrdersTrend');
  const kpiCustomersTrend = document.getElementById('kpiCustomersTrend');
  const kpiConversionTrend = document.getElementById('kpiConversionTrend');

  const salesCanvas = document.getElementById('salesChart');
  const catCanvas = document.getElementById('categoryChart');
  const salesLegend = document.getElementById('salesLegend');

  const orderSearch = document.getElementById('orderSearch');
  const statusFilter = document.getElementById('statusFilter');
  const tbody = document.getElementById('ordersTbody');
  const selectAll = document.getElementById('selectAll');
  const bulkShip = document.getElementById('bulkShip');
  const bulkCancel = document.getElementById('bulkCancel');
  const pagination = document.getElementById('pagination');
  const themeToggle = document.getElementById('themeToggle');

  const STATE_KEY = 'nx_admin_state_v1';


  // --- Layout & theme
  toggleBtn.addEventListener('click', () => sidebar.classList.toggle('open'));
  themeToggle.addEventListener('click', () => {
    document.documentElement.classList.toggle('dark');
    localStorage.setItem('nx_theme', document.documentElement.classList.contains('dark') ? 'dark' : 'light');
  });
  // Apply saved theme
  if (localStorage.getItem('nx_theme') === 'dark') document.documentElement.classList.add('dark');

  // --- Fake data generation (replace with API)
  function getState() {
    const raw = localStorage.getItem(STATE_KEY);
    if (raw) return JSON.parse(raw);

    const today = new Date();
    const orders = [];
    const statuses = ['Paid','Pending','Shipped','Cancelled'];
    const names = ['Alex', 'Sam', 'Jordan', 'Taylor', 'Jamie', 'Morgan', 'Riley', 'Casey', 'Avery', 'Harper'];
    for (let i = 1; i <= 185; i++){
      const d = new Date(today); d.setDate(d.getDate() - Math.floor(Math.random() * 120));
      const total = +(Math.random()*400 + 30).toFixed(2);
      orders.push({
        id: 1000 + i,
        customer: names[Math.floor(Math.random()*names.length)] + ' ' + String.fromCharCode(65 + i%26) + '.',
        date: d.toISOString(),
        total,
        status: statuses[Math.floor(Math.random()*statuses.length)]
      });
    }
    const customers = 1200 + Math.floor(Math.random()*800);
    const visitors = 40000 + Math.floor(Math.random()*30000);

    const state = { orders, customers, visitors, notifications: Math.random() > .5 };
    localStorage.setItem(STATE_KEY, JSON.stringify(state));
    return state;
  }
  let state = getState();
  notifDot.style.display = state.notifications ? 'block' : 'none';

  // --- Helpers
  const fmt = new Intl.NumberFormat(undefined, { style:'currency', currency:'USD' });
  function withinDays(dateISO, days){
    const d = new Date(dateISO);
    const from = new Date(); from.setDate(from.getDate() - days);
    return d >= from;
  }
  function chunk(arr, size, page){
    const start = (page-1)*size; return arr.slice(start, start + size);
  }
  function sortBy(arr, key, dir='asc'){
    const m = dir === 'asc' ? 1 : -1;
    return [...arr].sort((a,b)=> (a[key] > b[key] ? 1 : a[key] < b[key] ? -1 : 0) * m);
  }
  function percent(a, b){ return b ? ((a - b) / b) * 100 : 0; }

  // --- KPIs + charts
  let salesChart, categoryChart, currentSort = { key:'date', dir:'desc' }, page = 1, pageSize = 8;

  function compute(rangeDays){
    const orders = state.orders.filter(o => withinDays(o.date, rangeDays));
    const revenue = orders.reduce((s,o)=> s + o.total, 0);
    const ordersCount = orders.length;

    // last period for trend
    const prevOrders = state.orders.filter(o => withinDays(o.date, rangeDays*2) && !withinDays(o.date, rangeDays));
    const prevRevenue = prevOrders.reduce((s,o)=> s+o.total,0);
    const prevCount = prevOrders.length;

    // naive conversion estimate
    const visitors = Math.max(1, Math.floor(state.visitors * (rangeDays/30)));
    const customers = Math.max(1, Math.floor(state.customers * (rangeDays/30)));
    const conversion = (customers / visitors) * 100;

    return { orders, revenue, ordersCount, visitors, customers, conversion, prevRevenue, prevCount };
  }

  function updateKpis(rangeDays){
    const { revenue, ordersCount, customers, conversion, prevRevenue, prevCount } = compute(rangeDays);
    const revPct = percent(revenue, prevRevenue);
    const ordPct = percent(ordersCount, prevCount);
    const custPct = percent(customers, customers * 0.9); // mock trend
    const convPct = percent(conversion, conversion * 0.92); // mock trend

    kpiRevenue.textContent = fmt.format(revenue);
    kpiOrders.textContent = ordersCount.toLocaleString();
    kpiCustomers.textContent = customers.toLocaleString();
    kpiConversion.textContent = `${conversion.toFixed(2)}%`;

    setTrend(kpiRevenueTrend, revPct);
    setTrend(kpiOrdersTrend, ordPct);
    setTrend(kpiCustomersTrend, custPct);
    setTrend(kpiConversionTrend, convPct);
  }

  function setTrend(el, pct){
    el.classList.toggle('up', pct >= 0);
    el.classList.toggle('down', pct < 0);
    el.querySelector('i').className = pct >= 0 ? 'fa fa-arrow-trend-up' : 'fa fa-arrow-trend-down';
    el.querySelector('span').textContent = `${pct>=0?'+':''}${pct.toFixed(1)}%`;
  }

  function buildSalesData(rangeDays){
    const map = new Map();
    const today = new Date();
    for (let i = rangeDays-1; i >= 0; i--){
      const key = new Date(today.getFullYear(), today.getMonth(), today.getDate() - i).toISOString().slice(0,10);
      map.set(key, 0);
    }
    state.orders.forEach(o => {
      const key = o.date.slice(0,10);
      if (map.has(key)) map.set(key, map.get(key) + o.total);
    });
    return { labels: [...map.keys()], data: [...map.values()] };
  }

  function renderCharts(rangeDays){
    const { labels, data } = buildSalesData(rangeDays);
    salesChart?.destroy();
    salesChart = new Chart(salesCanvas.getContext('2d'), {
      type: 'line',
      data: {
        labels,
        datasets: [{
          label: 'Revenue',
          data,
          fill: true,
          tension: .35
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { display:false } },
        scales: { y: { ticks: { callback: v => '$' + v } } }
      }
    });

    // legend
    salesLegend.innerHTML = `<span><span class="dot" style="background: ${salesChart.data.datasets[0].borderColor || '#3b82f6'}"></span>Revenue</span>`;

    // Category chart (mock aggregate)
    const cats = ['Phones','Laptops','Audio','Gaming','Accessories','Monitors'];
    const totals = cats.map(() => Math.floor(Math.random()*5000 + 1000));
    categoryChart?.destroy();
    categoryChart = new Chart(catCanvas.getContext('2d'), {
      type: 'doughnut',
      data: { labels: cats, datasets: [{ data: totals }] },
      options: { plugins: { legend: { position:'bottom' } } }
    });
  }

  // --- Orders table
  let filtered = [];
  function applyFilters(){
    const term = orderSearch.value.toLowerCase().trim();
    const st = statusFilter.value;
    filtered = state.orders.filter(o => {
      const matchTerm = !term || [o.id, o.customer, o.total, new Date(o.date).toLocaleDateString()].join(' ').toLowerCase().includes(term);
      const matchStatus = !st || o.status === st;
      return matchTerm && matchStatus;
    });
    sortAndRender();
  }

  function sortAndRender(){
    filtered = sortBy(filtered, currentSort.key, currentSort.dir);
    renderTable();
  }

  function renderTable(){
    const pages = Math.max(1, Math.ceil(filtered.length / pageSize));
    if (page > pages) page = pages;
    const rows = chunk(filtered, pageSize, page);
    tbody.innerHTML = rows.map(rowHtml).join('');
    renderPagination(pages);
    selectAll.checked = false;
  }

  function rowHtml(o){
    const d = new Date(o.date);
    return `
      <tr>
        <td><input type="checkbox" data-id="${o.id}" class="row-check"/></td>
        <td>#${o.id}</td>
        <td>${escapeHtml(o.customer)}</td>
        <td>${d.toLocaleDateString()} ${d.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}</td>
        <td>${fmt.format(o.total)}</td>
        <td><span class="status ${o.status}">${o.status}</span></td>
        <td class="row-actions">
          <button class="icon-mini" data-action="view" data-id="${o.id}" title="View"><i class="fa fa-eye"></i></button>
          <button class="icon-mini" data-action="ship" data-id="${o.id}" title="Mark shipped"><i class="fa fa-truck"></i></button>
          <button class="icon-mini" data-action="cancel" data-id="${o.id}" title="Cancel"><i class="fa fa-xmark"></i></button>
        </td>
      </tr>
    `;
  }

  function renderPagination(pages){
    const btn = (p, label=p) => `<button data-page="${p}" class="${p===page?'active':''}">${label}</button>`;
    let html = '';
    if (pages > 1){
      html += btn(Math.max(1, page-1), '‹');
      for (let i=1;i<=pages;i++){ if (i===1 || i===pages || Math.abs(i-page)<=2) html += btn(i); else if (!html.endsWith('…')) html += '<span>…</span>'; }
      html += btn(Math.min(pages, page+1), '›');
    }
    pagination.innerHTML = html;
  }

  // --- Events
  rangeSelect.addEventListener('change', () => {
    const days = +rangeSelect.value;
    updateKpis(days);
    renderCharts(days);
  });

  exportBtn.addEventListener('click', () => {
    const csv = toCsv(filtered.length ? filtered : state.orders);
    const blob = new Blob([csv], {type:'text/csv;charset=utf-8;'});
    const url = URL.createObjectURL(blob);
    const a = Object.assign(document.createElement('a'), { href:url, download:'orders-export.csv' });
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  });

  globalSearch.addEventListener('input', e => {
    orderSearch.value = e.target.value;
    applyFilters();
  });

  orderSearch.addEventListener('input', applyFilters);
  statusFilter.addEventListener('change', applyFilters);

  document.querySelector('#ordersTable thead').addEventListener('click', e => {
    const th = e.target.closest('th[data-sort]');
    if (!th) return;
    const key = th.dataset.sort;
    currentSort.dir = currentSort.key === key && currentSort.dir === 'asc' ? 'desc' : 'asc';
    currentSort.key = key;
    sortAndRender();
  });

  selectAll.addEventListener('change', () => {
    document.querySelectorAll('.row-check').forEach(cb => cb.checked = selectAll.checked);
  });

  tbody.addEventListener('click', e => {
    const btn = e.target.closest('.icon-mini');
    if (!btn) return;
    const id = Number(btn.dataset.id);
    const action = btn.dataset.action;
    if (action === 'view') alert('Open order #' + id + ' details (hook to /admin/orders/:id)');
    if (action === 'ship') updateStatus(id, 'Shipped');
    if (action === 'cancel') updateStatus(id, 'Cancelled');
  });

  pagination.addEventListener('click', e => {
    const p = e.target.dataset.page;
    if (!p) return;
    page = Number(p);
    renderTable();
  });

  bulkShip.addEventListener('click', () => bulkUpdate('Shipped'));
  bulkCancel.addEventListener('click', () => bulkUpdate('Cancelled'));

  // --- Mutations
  function updateStatus(id, status){
    const o = state.orders.find(x => x.id === id);
    if (!o) return;
    o.status = status;
    persist(); applyFilters();
  }
  function bulkUpdate(status){
    const ids = [...document.querySelectorAll('.row-check:checked')].map(cb => Number(cb.dataset.id));
    state.orders.forEach(o => { if (ids.includes(o.id)) o.status = status; });
    persist(); applyFilters();
  }
  function persist(){ localStorage.setItem(STATE_KEY, JSON.stringify(state)); }

  // --- CSV
  function toCsv(rows){
    const head = ['id','customer','date','total','status'];
    const lines = [head.join(',')];
    rows.forEach(o => lines.push([o.id, `"${o.customer}"`, new Date(o.date).toISOString(), o.total, o.status].join(',')));
    return lines.join('\n');
  }

  function escapeHtml(s=''){ return s.replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }

  // --- Init
  (function init(){
    const days = +rangeSelect.value;
    applyFilters();
    updateKpis(days);
    renderCharts(days);
  })();
});
