document.addEventListener('DOMContentLoaded', () => {
  // Shell + theme
  const sidebar = document.getElementById('sidebar');
  document.querySelector('.sidebar-toggle')?.addEventListener('click', () => sidebar.classList.toggle('open'));
  [document.getElementById('themeToggle'), document.getElementById('themeToggle2')].forEach(b => {
    b?.addEventListener('click', () => {
      document.documentElement.classList.toggle('dark');
      localStorage.setItem('nx_theme', document.documentElement.classList.contains('dark') ? 'dark' : 'light');
    });
  });
  if (localStorage.getItem('nx_theme') === 'dark') document.documentElement.classList.add('dark');

  // Elements
  const envSelect = document.getElementById('envSelect');
  const serviceSelect = document.getElementById('serviceSelect');
  const rangeSelect = document.getElementById('rangeSelect');
  const liveToggle = document.getElementById('liveToggle');
  const refreshBtn = document.getElementById('refreshBtn');
  const exportMetricsBtn = document.getElementById('exportMetricsBtn');

  const kpiUptime = document.getElementById('kpiUptime');
  const uptimeSub = document.getElementById('uptimeSub');
  const kpiRpm = document.getElementById('kpiRpm');
  const kpiRpmTrend = document.getElementById('kpiRpmTrend');
  const kpiErr = document.getElementById('kpiErr');
  const kpiErrTrend = document.getElementById('kpiErrTrend');
  const kpiP95 = document.getElementById('kpiP95');
  const kpiApdex = document.getElementById('kpiApdex');
  const kpiCache = document.getElementById('kpiCache');

  const alertSearch = document.getElementById('alertSearch');
  const severityFilter = document.getElementById('severityFilter');
  const statusFilter = document.getElementById('statusFilter');
  const pageSizeSel = document.getElementById('pageSize');
  const alertsTbody = document.getElementById('alertsTbody');
  const pagination = document.getElementById('pagination');
  const exportAlertsBtn = document.getElementById('exportAlertsBtn');

  // Charts
  const trafficCtx = document.getElementById('trafficChart').getContext('2d');
  const latencyCtx = document.getElementById('latencyChart').getContext('2d');
  const systemCtx  = document.getElementById('systemChart').getContext('2d');
  const dbCacheCtx = document.getElementById('dbCacheChart').getContext('2d');
  const queueCtx   = document.getElementById('queueChart').getContext('2d');

  // State
  const METRICS_KEY = 'nx_sys_metrics_v1';
  const ALERTS_KEY  = 'nx_sys_alerts_v1';
  let metrics = loadMetrics() || seedMetrics();
  let alerts  = loadAlerts()  || seedAlerts();
  let series = []; // currently visible time window
  let timer = null;
  let page = 1, filteredAlerts = [], sortAlerts = { key:'time', dir:'desc' };

  // Seeders / Storage
  function loadMetrics(){ try{ return JSON.parse(localStorage.getItem(METRICS_KEY) || ''); }catch{ return null; } }
  function saveMetrics(){ localStorage.setItem(METRICS_KEY, JSON.stringify(metrics)); }
  function seedMetrics(){
    const envs = ['prod','staging','dev'];
    const services = ['all','core','payments','search','media'];
    const out = {};
    const now = Date.now();
    envs.forEach(env => {
      out[env] = {};
      services.forEach(svc => {
        out[env][svc] = { points: [] };
        // generate 7 days of minute-resolution-ish samples (sampled every 2 minutes for size)
        let t = now - 7*24*60*60*1000;
        while (t <= now){
          const rpm = rnd(800, 2000) * (svc==='all'?1:0.25) * (env==='prod'?1:(env==='staging'?0.2:0.05));
          const err = Math.max(0, Math.round(rpm * rnd(0.002, 0.02)));
          const p50 = rnd(80, 160), p95 = p50 * rnd(2.1, 3.3), p99 = p50 * rnd(3.2, 5.2);
          const cpu = rnd(20, 85), mem = rnd(35, 90);
          const dbq = rnd(200, 1200) * (svc==='core'?1:0.4), cacheHit = rnd(80, 98);
          const queue = rnd(0, 120) * (svc==='media' ? 1.3 : 1);
          out[env][svc].points.push({
            t, rpm: Math.round(rpm), err, p50: Math.round(p50), p95: Math.round(p95), p99: Math.round(p99),
            cpu: Math.round(cpu), mem: Math.round(mem), dbq: Math.round(dbq), cache: Math.round(cacheHit),
            queue: Math.round(queue)
          });
          t += 120000; // every 2 minutes
        }
      });
    });
    localStorage.setItem(METRICS_KEY, JSON.stringify(out));
    return out;
  }
  function loadAlerts(){ try{ return JSON.parse(localStorage.getItem(ALERTS_KEY) || ''); }catch{ return null; } }
  function saveAlerts(){ localStorage.setItem(ALERTS_KEY, JSON.stringify(alerts)); }
  function seedAlerts(){
    const svcs = ['core','payments','search','media'];
    const sevs = ['critical','warning','info'];
    const statuses = ['open','ack','resolved'];
    const out = [];
    for (let i=0;i<120;i++){
      const sev = sevs[Math.floor(Math.random()*sevs.length)];
      const status = statuses[Math.floor(Math.random()*statuses.length)];
      const svc = svcs[Math.floor(Math.random()*svcs.length)];
      const time = Date.now() - Math.floor(Math.random()*5*24*60*60*1000);
      const title = sev==='critical' ? 'Error spike' : (sev==='warning' ? 'Elevated latency' : 'Deploy complete');
      out.push({ id: 9000+i, time, severity:sev, status, service:svc, title });
    }
    localStorage.setItem(ALERTS_KEY, JSON.stringify(out));
    return out;
  }
  function rnd(min, max){ return min + Math.random()*(max-min); }

  // Build visible series for selected env/service/range
  function buildSeries(){
    const env = envSelect.value, svc = serviceSelect.value, minutes = Number(rangeSelect.value);
    const allPts = metrics[env][svc].points;
    const cutoff = Date.now() - minutes*60*1000;
    const pts = allPts.filter(p => p.t >= cutoff);
    // If range is small, add a few more recent points by extrapolating from last to simulate "live"
    series = pts;
  }

  // KPIs
  function updateKpis(){
    if (!series.length) return;
    const last = series[series.length-1];
    const prev = series[Math.max(0, series.length-6)]; // ~5 steps back
    const uptime = 99.90 + Math.random()*0.09; // mock 99.90–99.99
    const incidents = Math.floor(Math.random()*3);
    const errRate = last.rpm ? (last.err / last.rpm) * 100 : 0;
    const prevErr = prev.rpm ? (prev.err/prev.rpm)*100 : 0;
    const rpmTrend = trendPct(last.rpm, prev.rpm);
    const errTrend = trendPct(errRate, prevErr);
    const apdex = calcApdex(series, 500);

    kpiUptime.textContent = uptime.toFixed(3) + '%';
    uptimeSub.textContent = `Incidents: ${incidents}`;
    kpiRpm.textContent = last.rpm.toLocaleString();
    setTrend(kpiRpmTrend, rpmTrend);
    kpiErr.textContent = errRate.toFixed(2) + '%';
    setTrend(kpiErrTrend, errTrend);
    kpiP95.textContent = last.p95.toFixed(0);
    kpiApdex.textContent = apdex.toFixed(2);
    kpiCache.textContent = last.cache.toFixed(0) + '%';
  }
  function trendPct(cur, prev){ return prev ? ((cur - prev) / prev) * 100 : 0; }
  function setTrend(el, pct){
    el.classList.toggle('up', pct >= 0);
    el.classList.toggle('down', pct < 0);
    el.querySelector('i').className = pct >= 0 ? 'fa fa-arrow-trend-up' : 'fa fa-arrow-trend-down';
    el.querySelector('span').textContent = `${pct>=0?'+':''}${pct.toFixed(1)}%`;
  }
  function calcApdex(points, T){
    let sat=0, tol=0, total=points.length;
    points.forEach(p => {
      if (p.p95 <= T) sat++;
      else if (p.p95 <= 4*T) tol++;
    });
    return total ? (sat + tol/2)/total : 0;
  }

  // Charts
  let trafficChart, latencyChart, systemChart, dbCacheChart, queueChart;
  function renderCharts(){
    const labels = series.map(p => new Date(p.t).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}));
    const rpm = series.map(p => p.rpm);
    const err = series.map(p => p.err);
    const p50 = series.map(p => p.p50);
    const p95 = series.map(p => p.p95);
    const p99 = series.map(p => p.p99);
    const cpu = series.map(p => p.cpu);
    const mem = series.map(p => p.mem);
    const dbq = series.map(p => p.dbq);
    const cache = series.map(p => p.cache);
    const qd = series.map(p => p.queue);

    trafficChart?.destroy();
    trafficChart = new Chart(trafficCtx, {
      type: 'line',
      data: { labels, datasets: [
        { label: 'Requests / min', data: rpm, fill:true, tension:.35 },
        { label: 'Errors / min', data: err, fill:true, tension:.35 }
      ]},
      options: { plugins:{ legend:{ position:'bottom' } }, scales:{ y:{ beginAtZero:true } }, interaction: { mode:'index' } }
    });

    latencyChart?.destroy();
    latencyChart = new Chart(latencyCtx, {
      type: 'line',
      data: { labels, datasets: [
        { label: 'p50 (ms)', data: p50, tension:.35 },
        { label: 'p95 (ms)', data: p95, tension:.35 },
        { label: 'p99 (ms)', data: p99, tension:.35 }
      ]},
      options: { plugins:{ legend:{ position:'bottom' } }, scales:{ y:{ beginAtZero:true } }, interaction: { mode:'index' } }
    });

    systemChart?.destroy();
    systemChart = new Chart(systemCtx, {
      type: 'line',
      data: { labels, datasets: [
        { label:'CPU %', data: cpu, tension:.35, fill:true },
        { label:'Memory %', data: mem, tension:.35, fill:true }
      ]},
      options: { plugins:{ legend:{ position:'bottom' } }, scales:{ y:{ min:0, max:100 } } }
    });

    dbCacheChart?.destroy();
    dbCacheChart = new Chart(dbCacheCtx, {
      type: 'bar',
      data: { labels, datasets: [
        { label:'DB QPS', data: dbq, yAxisID:'y' },
        { label:'Cache Hit %', data: cache, type:'line', yAxisID:'y1', tension:.35 }
      ]},
      options: { plugins:{ legend:{ position:'bottom' } },
        scales:{ y:{ beginAtZero:true }, y1:{ beginAtZero:true, min:0, max:100, position:'right', grid:{ drawOnChartArea:false } } }
    });

    queueChart?.destroy();
    queueChart = new Chart(queueCtx, {
      type: 'bar',
      data: { labels, datasets: [{ label:'Queue Depth', data: qd }] },
      options: { plugins:{ legend:{ position:'bottom' } }, scales:{ y:{ beginAtZero:true } } }
    });
  }

  // Live tick (adds a new point every 15s when Live is on)
  function startLive(){
    stopLive();
    timer = setInterval(() => {
      if (!liveToggle.checked) return;
      pushPoint();
      buildSeries(); updateKpis(); renderCharts();
    }, 15000);
  }
  function stopLive(){ if (timer) { clearInterval(timer); timer = null; } }

  function pushPoint(){
    const env = envSelect.value, svc = serviceSelect.value;
    const arr = metrics[env][svc].points;
    const last = arr[arr.length-1];
    const t = Date.now();
    // random walk around last values
    const rpm = clamp(Math.round((last?.rpm ?? 1200) * rnd(0.95, 1.05)), 0, 100000);
    const err = clamp(Math.round(rpm * rnd(0.003, 0.02)), 0, rpm);
    const p50 = clamp(Math.round((last?.p50 ?? 120) * rnd(0.92, 1.08)), 50, 600);
    const p95 = clamp(Math.round(p50 * rnd(2.1, 3.2)), 100, 2000);
    const p99 = clamp(Math.round(p50 * rnd(3.0, 5.0)), 150, 4000);
    const cpu = clamp(Math.round((last?.cpu ?? 60) * rnd(0.92, 1.08)), 5, 98);
    const mem = clamp(Math.round((last?.mem ?? 70) * rnd(0.96, 1.04)), 20, 99);
    const dbq = clamp(Math.round((last?.dbq ?? 600) * rnd(0.9, 1.1)), 0, 5000);
    const cache = clamp(Math.round((last?.cache ?? 90) * rnd(0.98, 1.02)), 50, 100);
    const queue = clamp(Math.round((last?.queue ?? 40) * rnd(0.8, 1.2)), 0, 1000);
    arr.push({ t, rpm, err, p50, p95, p99, cpu, mem, dbq, cache, queue });
    // keep 8 days max
    while (arr.length > 8*24*30) arr.shift();
    saveMetrics();
  }
  function clamp(n, min, max){ return Math.max(min, Math.min(max, n)); }

  // Alerts table
  function applyAlertFilters(){
    const term = (alertSearch.value || '').toLowerCase().trim();
    const sev = severityFilter.value;
    const st = statusFilter.value;
    filteredAlerts = alerts.filter(a => {
      const textHit = !term || [a.title, a.service, a.severity, a.status].join(' ').toLowerCase().includes(term);
      const sevHit = !sev || a.severity === sev;
      const stHit  = !st || a.status === st;
      return textHit && sevHit && stHit;
    });
    sortAndRenderAlerts();
  }
  function sortAndRenderAlerts(){
    const m = sortAlerts.dir === 'asc' ? 1 : -1;
    filteredAlerts = [...filteredAlerts].sort((a,b) => (a[sortAlerts.key] > b[sortAlerts.key] ? 1 : a[sortAlerts.key] < b[sortAlerts.key] ? -1 : 0) * m);
    renderAlerts();
  }
  function renderAlerts(){
    const size = Number(pageSizeSel.value);
    const pages = Math.max(1, Math.ceil(filteredAlerts.length / size));
    if (page > pages) page = pages;
    const slice = filteredAlerts.slice((page-1)*size, (page)*size);
    alertsTbody.innerHTML = slice.map(rowHtml).join('');
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
  }
  function rowHtml(a){
    const when = new Date(a.time).toLocaleString();
    return `
      <tr>
        <td>${when}</td>
        <td><span class="badge ${a.severity}">${a.severity}</span></td>
        <td>${escapeHtml(a.service)}</td>
        <td>${escapeHtml(a.title)}</td>
        <td><span class="status ${a.status}">${a.status}</span></td>
        <td class="row-actions">
          <button class="icon-mini" data-action="ack" data-id="${a.id}" title="Acknowledge"><i class="fa fa-hand"></i></button>
          <button class="icon-mini" data-action="resolve" data-id="${a.id}" title="Resolve"><i class="fa fa-check"></i></button>
          <button class="icon-mini" data-action="delete" data-id="${a.id}" title="Delete"><i class="fa fa-trash"></i></button>
        </td>
      </tr>
    `;
  }
  function escapeHtml(s=''){ return s.replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }

  // Alerts events
  document.querySelector('#alertsTable thead').addEventListener('click', e => {
    const th = e.target.closest('th[data-sort]'); if (!th) return;
    const key = th.dataset.sort;
    sortAlerts.dir = (sortAlerts.key === key && sortAlerts.dir === 'asc') ? 'desc' : 'asc';
    sortAlerts.key = key; sortAndRenderAlerts();
  });
  pagination.addEventListener('click', e => {
    const p = e.target.dataset.page; if (!p) return; page = Number(p); renderAlerts();
  });
  [alertSearch, severityFilter, statusFilter].forEach(el => el.addEventListener('input', applyAlertFilters));
  alertsTbody.addEventListener('click', e => {
    const btn = e.target.closest('.icon-mini'); if (!btn) return;
    const id = Number(btn.dataset.id), action = btn.dataset.action;
    const a = alerts.find(x=>x.id===id); if (!a) return;
    if (action === 'ack') a.status = 'ack';
    if (action === 'resolve') a.status = 'resolved';
    if (action === 'delete') { alerts = alerts.filter(x=>x.id!==id); }
    saveAlerts(); applyAlertFilters();
  });

  // Metrics export
  exportMetricsBtn.addEventListener('click', () => {
    const head = ['time','rpm','err','p50','p95','p99','cpu','mem','dbq','cache','queue'];
    const lines = [head.join(',')];
    series.forEach(p => lines.push([new Date(p.t).toISOString(), p.rpm, p.err, p.p50, p.p95, p.p99, p.cpu, p.mem, p.dbq, p.cache, p.queue].join(',')));
    downloadCsv(lines.join('\n'), 'system-metrics.csv');
  });
  exportAlertsBtn.addEventListener('click', () => {
    const head = ['id','time','severity','service','title','status'];
    const lines = [head.join(',')];
    (filteredAlerts.length ? filteredAlerts : alerts).forEach(a => lines.push([a.id, new Date(a.time).toISOString(), a.severity, a.service, `"${a.title.replace(/"/g,'""')}"`, a.status].join(',')));
    downloadCsv(lines.join('\n'), 'system-alerts.csv');
  });
  function downloadCsv(text, name){
    const blob = new Blob([text], {type:'text/csv;charset=utf-8;'});
    const url = URL.createObjectURL(blob);
    const a = Object.assign(document.createElement('a'), { href:url, download:name });
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  }

  // Filter changes
  [envSelect, serviceSelect, rangeSelect].forEach(el => el.addEventListener('change', refreshAll));
  refreshBtn.addEventListener('click', refreshAll);
  liveToggle.addEventListener('change', () => { if (liveToggle.checked) startLive(); else stopLive(); });

  function refreshAll(){
    buildSeries(); updateKpis(); renderCharts(); applyAlertFilters();
  }

  // Init
  (function init(){
    buildSeries(); updateKpis(); renderCharts(); applyAlertFilters(); startLive();
  })();
});
