document.addEventListener('DOMContentLoaded', () => {
  const ORDERS_KEY = 'nx_admin_orders_v1';
  const DELIV_KEY  = 'nx_delivery_assignments_v1'; // optional (Delivery module)
  const SUB_KEY    = 'nx_track_subscriptions_v1';

  // Elements
  const lookupForm = document.getElementById('lookupForm');
  const orderIdInput = document.getElementById('orderIdInput');
  const emailInput = document.getElementById('emailInput');
  const lookupError = document.getElementById('lookupError');

  const resultWrap = document.getElementById('resultWrap');
  const sumOrder = document.getElementById('sumOrder');
  const sumDate = document.getElementById('sumDate');
  const sumTotal = document.getElementById('sumTotal');
  const sumPay = document.getElementById('sumPay');
  const sumStatus = document.getElementById('sumStatus');
  const sumTrack = document.getElementById('sumTrack');
  const etaBox = document.getElementById('etaBox');
  const etaText = document.getElementById('etaText');
  const alertBox = document.getElementById('alertBox');
  const alertText = document.getElementById('alertText');

  const addressBox = document.getElementById('addressBox');
  const itemsTbody = document.getElementById('itemsTbody');

  const mapEl = document.getElementById('map');
  const mapEmpty = document.getElementById('mapEmpty');

  const timeline = document.getElementById('timeline');

  const subForm = document.getElementById('subForm');
  const subEmail = document.getElementById('subEmail');
  const subMsg = document.getElementById('subMsg');

  // Helpers
  function loadJSON(key, fallback) { try { return JSON.parse(localStorage.getItem(key) || JSON.stringify(fallback)); } catch { return fallback; } }
  function saveJSON(key, value) { localStorage.setItem(key, JSON.stringify(value)); }
  const fmt = new Intl.NumberFormat(undefined, { style:'currency', currency:'USD' });
  const escape = s => String(s||'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

  // Seed demo orders if none exist (keeps in sync with PM orders page)
  function seedOrdersIfEmpty(list){
    if (list.length) return list;
    const names = ['Alex Johnson','Sam Lee','Jordan Chen','Taylor Patel','Jamie Rivera','Morgan Kim','Riley Brown','Casey Nguyen'];
    const out = [];
    for (let i=1;i<=12;i++){
      const id = 12000+i;
      const name = names[i%names.length];
      const email = `user${i}@nexus.demo`;
      const d = new Date(); d.setDate(d.getDate() - Math.floor(Math.random()*20));
      const total = +(Math.random()*240 + 20).toFixed(2);
      const paid = Math.random() > .2;
      const status = paid ? (Math.random()>.5 ? 'Shipped' : 'Paid') : 'Pending';
      out.push({
        id, customer:name, email, date:d.toISOString(), total, status,
        paymentStatus: paid ? 'paid' : 'unpaid',
        fulfillment: status==='Shipped' ? 'fulfilled' : 'unfulfilled',
        shipping:{ name, address1:'123 Demo St', city:'Demo City', zip:'10001', country:'US' },
        items:[
          { sku:`SKU-${id}-1`, title:'Sample Product A', qty:1, price:+(Math.random()*80+10).toFixed(2), image:'' },
          { sku:`SKU-${id}-2`, title:'Sample Product B', qty:1, price:+(Math.random()*80+10).toFixed(2), image:'' }
        ],
        notes:''
      });
    }
    saveJSON(ORDERS_KEY, out);
    return out;
  }

  let orders = seedOrdersIfEmpty(loadJSON(ORDERS_KEY, []));
  let assignments = loadJSON(DELIV_KEY, []); // may be empty

  // Lookup submit
  lookupForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const id = Number((orderIdInput.value || '').replace(/\D/g,''));
    const email = (emailInput.value || '').trim().toLowerCase();
    if (!id || !email){ return showError('Please enter a valid order number and email.'); }

    const order = orders.find(o => Number(o.id) === id && String(o.email || '').toLowerCase() === email);
    if (!order){ return showError('We could not find a matching order. Check the number and email and try again.'); }
    hideError();
    renderOrder(order);
  });

  function showError(msg){ lookupError.textContent = msg; lookupError.hidden = false; resultWrap.hidden = true; }
  function hideError(){ lookupError.hidden = true; }

  // Render order
  function renderOrder(o){
    resultWrap.hidden = false;

    sumOrder.textContent = `#${o.id}`;
    sumDate.textContent = new Date(o.date).toLocaleString();
    sumTotal.textContent = fmt.format(o.total);
    sumPay.textContent = o.paymentStatus === 'paid' ? 'Paid' : o.paymentStatus === 'refunded' ? 'Refunded' : 'Unpaid';
    sumStatus.textContent = o.status;
    sumStatus.className = 'badge ' + o.status;

    // Tracking number (fake for demo; hook to backend later)
    const trackNo = 'TRK-' + String(o.id).padStart(6,'0');
    sumTrack.textContent = trackNo;

    // Address
    const s = o.shipping || {};
    addressBox.innerHTML = `
      <div><strong>${escape(s.name || o.customer || '')}</strong></div>
      <div>${escape(s.address1 || '')}</div>
      <div>${escape(s.city || '')} ${escape(s.zip || '')}</div>
      <div>${escape(s.country || '')}</div>
    `;

    // Items table
    itemsTbody.innerHTML = (o.items||[]).map(it => `
      <tr>
        <td>${escape(it.title)}</td>
        <td class="hide-sm">${escape(it.sku)}</td>
        <td>${it.qty}</td>
        <td>${fmt.format(it.price)}</td>
        <td>${fmt.format(it.price * it.qty)}</td>
      </tr>
    `).join('');

    // Steps + ETA/alerts
    paintSteps(o);
    paintTimeline(o);
    paintMap(o);
  }

  function paintSteps(o){
    const steps = ['Placed','Paid','Shipped','Out for delivery','Delivered'];
    // base from order.status
    let idx = 0;
    if (o.status === 'Pending') idx = 0;
    if (o.status === 'Paid') idx = 1;
    if (o.status === 'Shipped') idx = 2;
    if (o.status === 'Cancelled') idx = 0;
    if (o.status === 'Refunded') idx = 2;

    // check delivery assignment for richer status
    const a = assignments.find(x => Number(x.orderId) === Number(o.id));
    if (a){
      if (a.status === 'Out for delivery') idx = Math.max(idx, 3);
      if (a.status === 'Delivered') idx = 4;
      if (a.status === 'Failed attempt') { idx = 3; showAlert('We tried to deliver your order but couldn’t complete it. Please contact support to reschedule.'); }
    } else {
      hideAlert();
    }

    document.querySelectorAll('.steps .step').forEach((el, i) => {
      el.classList.toggle('done', i < idx);
      el.classList.toggle('current', i === idx);
    });

    // ETA (simple heuristic)
    const placed = new Date(o.date);
    let eta = null;
    if (idx <= 1) {
      eta = addDays(placed, 5);
    } else if (idx === 2) {
      eta = addDays(placed, 3);
    } else if (idx === 3) {
      eta = addDays(placed, 1);
    }
    if (a && a.status === 'Delivered') eta = new Date(a.date || Date.now());
    if (eta){
      etaText.textContent = eta.toLocaleDateString();
      etaBox.hidden = false;
    } else {
      etaBox.hidden = true;
    }
  }

  function showAlert(msg){ alertText.textContent = msg; alertBox.hidden = false; }
  function hideAlert(){ alertBox.hidden = true; }

  function addDays(d, days){ const x = new Date(d); x.setDate(x.getDate()+days); return x; }

  // Timeline (synthetic for demo; use backend events later)
  function paintTimeline(o){
    const evts = [];
    const placed = new Date(o.date);
    evts.push({ t: placed, text:'Order placed' });
    if (o.paymentStatus === 'paid') evts.push({ t: addHours(placed, 1), text:'Payment confirmed' });
    if (o.status === 'Shipped') evts.push({ t: addHours(placed, 36), text:'Order shipped' });
    if (o.status === 'Refunded') evts.push({ t: addHours(placed, 40), text:'Refund processed' });
    if (o.status === 'Cancelled') evts.push({ t: addHours(placed, 8), text:'Order cancelled' });

    const a = assignments.find(x => Number(x.orderId) === Number(o.id));
    if (a){
      if (a.status === 'Out for delivery') evts.push({ t: addHours(placed, 60), text:'Out for delivery' });
      if (a.status === 'Delivered') evts.push({ t: addHours(placed, 66), text:'Delivered' });
      if (a.status === 'Failed attempt') evts.push({ t: addHours(placed, 66), text:'Delivery attempt failed' });
    }

    evts.sort((a,b)=> a.t - b.t);
    timeline.innerHTML = evts.map(e => `
      <div class="tline-row">
        <div class="t-dot"></div>
        <div class="t-body">
          <div class="t-text">${escape(e.text)}</div>
          <div class="t-time">${e.t.toLocaleString()}</div>
        </div>
      </div>
    `).join('');
  }
  function addHours(d, h){ const x=new Date(d); x.setHours(x.getHours()+h); return x; }

  // Map
  let map, marker;
  function paintMap(o){
    const a = assignments.find(x => Number(x.orderId) === Number(o.id));
    if (!a || !('L' in window)) { // no delivery or Leaflet not loaded
      mapEl.hidden = true; mapEmpty.hidden = false; return;
    }
    mapEmpty.hidden = true; mapEl.hidden = false;

    if (!map){
      map = L.map('map', { zoomControl:true });
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{ maxZoom:19, attribution:'&copy; OpenStreetMap'}).addTo(map);
    }
    const latlng = [a.lat || 6.9271, a.lng || 79.8612];
    if (marker){ marker.setLatLng(latlng); } else { marker = L.marker(latlng).addTo(map); }
    marker.bindPopup(`<strong>${escape(o.customer)}</strong><br/>${escape(o.shipping?.address1||'')}`).openPopup();
    map.setView(latlng, 13);
  }

  // Subscribe (demo)
  subForm.addEventListener('submit', e => {
    e.preventDefault();
    const email = (subEmail.value || '').trim();
    if (!email) { subMsg.textContent = 'Enter a valid email.'; return; }
    const idText = sumOrder.textContent || '';
    const id = Number(idText.replace(/\D/g,''));
    if (!id) { subMsg.textContent = 'Track an order first.'; return; }
    const subs = loadJSON(SUB_KEY, []);
    if (!subs.find(s => s.id===id && s.email===email)){
      subs.push({ id, email, time:new Date().toISOString() }); saveJSON(SUB_KEY, subs);
    }
    subMsg.textContent = 'Subscribed. We will email updates for this order.';
    subEmail.value = '';
  });

  // Autofill when opened with ?id=...&email=...
  (function initFromQuery(){
    const p = new URLSearchParams(location.search);
    const id = p.get('id'); const em = p.get('email');
    if (id) orderIdInput.value = id;
    if (em) emailInput.value = em;
    if (id && em) lookupForm.dispatchEvent(new Event('submit'));
  })();
});
