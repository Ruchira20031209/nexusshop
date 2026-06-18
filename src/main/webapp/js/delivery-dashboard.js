document.addEventListener('DOMContentLoaded', () => {


  // Keys
  const ASSIGN_KEY = 'nx_delivery_assignments_v1';
  const VEHICLE_KEY = 'nx_delivery_vehicle_v1';

  // Elements
  const todayLabel = document.getElementById('todayLabel');
  const kpiStops = document.getElementById('kpiStops');
  const kpiPriority = document.getElementById('kpiPriority');
  const kpiDone = document.getElementById('kpiDone');

  const showRoute = document.getElementById('showRoute');
  const showCompleted = document.getElementById('showCompleted');
  const fitBtn = document.getElementById('fitBtn');

  const searchInput = document.getElementById('searchInput');
  const priorityFilter = document.getElementById('priorityFilter');
  const statusFilter = document.getElementById('statusFilter');
  const sortSelect = document.getElementById('sortSelect');
  const assignTbody = document.getElementById('assignTbody');

  // State
  let assignments = seedAssignmentsIfEmpty(loadAssignments());
  let vehicle = seedVehicleIfEmpty(loadVehicle());
  let today = new Date(); today.setHours(0,0,0,0);
  const todayISO = today.toISOString().slice(0,10);

  // Map
  const map = L.map('map', { zoomControl: true });
  const tiles = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19, attribution: '&copy; OpenStreetMap'
  }).addTo(map);
  let markersLayer = L.layerGroup().addTo(map);
  let routeLine = null;

  // Utils
  function loadAssignments(){ try { return JSON.parse(localStorage.getItem(ASSIGN_KEY) || '[]'); } catch { return []; } }
  function saveAssignments(){ localStorage.setItem(ASSIGN_KEY, JSON.stringify(assignments)); }
  function loadVehicle(){ try { return JSON.parse(localStorage.getItem(VEHICLE_KEY) || '{}'); } catch { return {}; } }
  function saveVehicle(){ localStorage.setItem(VEHICLE_KEY, JSON.stringify(vehicle)); }
  function fmtPhone(p){ return p.replace(/[^0-9+]/g,''); }
  const escapeHtml = s => String(s||'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

  // Seeding (Colombo-ish coords; priority highlighted)
  function seedAssignmentsIfEmpty(list){
    if (list.length) return list;
    const base = { lat: 6.9271, lng: 79.8612 }; // Colombo
    const mk = (i, seq, prio='Normal', status='Assigned') => ({
      id: 5000+i,
      orderId: 10000+i,
      date: todayISO,
      customer: ['Nimal','Kavindu','Sanjana','Ishara','Hasini','Dinuka','Anjali','Kasun','Ruwan','Tharushi'][i%10] + ' Perera',
      phone: '+94 7' + Math.floor(Math.random()*100000000).toString().padStart(8,'0'),
      address: `Stop ${seq}, Colombo`,
      lat: base.lat + (Math.random()-.5)*0.12,
      lng: base.lng + (Math.random()-.5)*0.12,
      priority: prio,
      status,
      seq,
      note: ''
    });
    const out = [
      mk(1, 1, 'High'), mk(2, 2), mk(3, 3), mk(4, 4, 'High'),
      mk(5, 5), mk(6, 6), mk(7, 7, 'High'), mk(8, 8)
    ];
    localStorage.setItem(ASSIGN_KEY, JSON.stringify(out));
    return out;
  }
  function seedVehicleIfEmpty(v){
    if (v && v.plate) return v;
    v = {
      driver: 'Dileepa Jayasuriya',
      model: 'Toyota HiAce',
      plate: 'WP ABC-1234',
      capacity: '120 parcels',
      fuel: '68%',
      odometer: '82,415 km',
      nextService: new Date(Date.now()+20*86400000).toISOString().slice(0,10)
    };
    localStorage.setItem(VEHICLE_KEY, JSON.stringify(v));
    return v;
  }

  // KPIs + vehicle render
  function updateKpis(){
    const todayList = assignments.filter(a => a.date === todayISO);
    const priority = todayList.filter(a => a.priority === 'High').length;
    const done = todayList.filter(a => a.status === 'Delivered').length;
    kpiStops.textContent = todayList.length;
    kpiPriority.textContent = priority;
    kpiDone.textContent = done;
    todayLabel.textContent = new Date().toLocaleDateString();
    document.getElementById('vehDriver').textContent = vehicle.driver;
    document.getElementById('vehModel').textContent = vehicle.model;
    document.getElementById('vehPlate').textContent = vehicle.plate;
    document.getElementById('vehCap').textContent = vehicle.capacity;
    document.getElementById('vehFuel').textContent = vehicle.fuel;
    document.getElementById('vehOdo').textContent = vehicle.odometer;
    document.getElementById('vehService').textContent = vehicle.nextService;
  }

  // Map plot
  function plotMap(){
    markersLayer.clearLayers();
    const showDone = showCompleted.checked;
    const pts = todaysFiltered();
    const coords = [];

    pts.forEach(a => {
      if (!showDone && a.status === 'Delivered') return;
      const color = a.priority === 'High' ? '#e11d48' : '#2563eb';
      const m = L.circleMarker([a.lat, a.lng], { radius: 9, color, weight: 2, fillColor: color, fillOpacity: .25 });
      m.bindPopup(`
        <div style="min-width:220px">
          <strong>#${a.seq} • ${escapeHtml(a.customer)}</strong><br/>
          <span class="muted">${escapeHtml(a.address)}</span><br/>
          <span class="badge ${a.priority}">${a.priority}</span> • <span class="status ${a.status}">${a.status}</span><br/>
          <a href="delivery-details.html?id=${a.id}">Open details</a>
        </div>
      `);
      m.addTo(markersLayer);
      coords.push([a.lat, a.lng]);
    });

    // Route line
    if (routeLine){ map.removeLayer(routeLine); routeLine = null; }
    if (showRoute.checked && coords.length >= 2){
      routeLine = L.polyline(coords, { color:'#10b981', weight:3, opacity:.8, dashArray:'6 6' }).addTo(map);
    }

    if (coords.length){
      const bounds = L.latLngBounds(coords);
      map.fitBounds(bounds.pad(0.2));
    } else {
      map.setView([6.9271, 79.8612], 12);
    }
  }

  // Table render
  function todaysFiltered(){
    let list = assignments.filter(a => a.date === todayISO);
    const term = (document.getElementById('globalSearch')?.value || searchInput.value || '').toLowerCase().trim();
    if (term){
      list = list.filter(a => [a.orderId, a.customer, a.address].join(' ').toLowerCase().includes(term));
    }
    if (priorityFilter.value){ list = list.filter(a => a.priority === priorityFilter.value); }
    if (statusFilter.value){ list = list.filter(a => a.status === statusFilter.value); }
    const [key, dir] = sortSelect.value.split(':');
    const mult = dir==='asc'?1:-1;
    list.sort((a,b) => {
      const A = (key==='priority') ? (a.priority==='High'?2:1) : a[key];
      const B = (key==='priority') ? (b.priority==='High'?2:1) : b[key];
      return (A>B?1:A<B?-1:0)*mult;
    });
    return list;
  }

  function renderTable(){
    const rows = todaysFiltered();
    assignTbody.innerHTML = rows.map(a => `
      <tr>
        <td>${a.seq}</td>
        <td>#${a.orderId}</td>
        <td>${escapeHtml(a.customer)}</td>
        <td class="hide-sm"><a href="tel:${fmtPhone(a.phone)}">${escapeHtml(a.phone)}</a></td>
        <td>${escapeHtml(a.address)}</td>
        <td><span class="badge ${a.priority}">${a.priority}</span></td>
        <td><span class="status ${a.status}">${a.status}</span></td>
        <td><a class="btn btn-ghost" href="delivery-details.html?id=${a.id}"><i class="fa fa-arrow-up-right-from-square"></i> View</a></td>
      </tr>
    `).join('');
  }

  // Events
  [searchInput, priorityFilter, statusFilter, sortSelect].forEach(el => el.addEventListener('input', () => { renderTable(); plotMap(); updateKpis(); }));
  document.getElementById('globalSearchForm')?.addEventListener('submit', e => e.preventDefault());
  document.getElementById('globalSearch')?.addEventListener('input', () => { searchInput.value = document.getElementById('globalSearch').value; renderTable(); plotMap(); });
  showRoute.addEventListener('change', plotMap);
  showCompleted.addEventListener('change', plotMap);
  fitBtn.addEventListener('click', plotMap);

  // Init
  (function init(){
    updateKpis();
    plotMap();
    renderTable();
  })();
});
