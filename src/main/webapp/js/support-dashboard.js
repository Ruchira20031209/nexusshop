document.addEventListener('DOMContentLoaded', () => {


  // Keys
  const TICKETS_KEY = 'nx_support_tickets_v1';
  const TPL_KEY = 'nx_support_templates_v1';

  // Elements
  const kpiOpen = document.getElementById('kpiOpen');
  const kpiUrgent = document.getElementById('kpiUrgent');
  const kpiPending = document.getElementById('kpiPending');
  const kpiResolved7d = document.getElementById('kpiResolved7d');

  const urgentSearch = document.getElementById('urgentSearch');
  const urgentSort = document.getElementById('urgentSort');
  const urgentTbody = document.getElementById('urgentTbody');

  const tplGrid = document.getElementById('tplGrid');
  const addTplBtn = document.getElementById('addTplBtn');
  const tplModal = document.getElementById('tplModal');
  const tplForm = document.getElementById('tplForm');
  const tplName = document.getElementById('tplName');
  const tplBody = document.getElementById('tplBody');

  const insertModal = document.getElementById('insertModal');
  const insertForm = document.getElementById('insertForm');
  const insertTicket = document.getElementById('insertTicket');

  // Data
  let tickets = seedTicketsIfEmpty(loadTickets());
  let templates = seedTemplatesIfEmpty(loadTemplates());
  let editingTplId = null;

  function loadTickets(){ try { return JSON.parse(localStorage.getItem(TICKETS_KEY) || '[]'); } catch { return []; } }
  function saveTickets(){ localStorage.setItem(TICKETS_KEY, JSON.stringify(tickets)); }
  function loadTemplates(){ try { return JSON.parse(localStorage.getItem(TPL_KEY) || '[]'); } catch { return []; } }
  function saveTemplates(){ localStorage.setItem(TPL_KEY, JSON.stringify(templates)); }

  // Seeders
  function seedTicketsIfEmpty(list){
    if (list.length) return list;
    const names = ['Alex','Nimal','Hasini','Jordan','Ishara','Kavindu','Ruwan','Sanjana','Anjali','Kasun'];
    const subjects = ['Order not received','Payment failed','Warranty claim','Wrong item delivered','Refund status','Account login issue','Coupon not working','Shipping delay','Damaged product','Request invoice copy'];
    const out = [];
    for (let i=1;i<=18;i++){
      out.push({
        id: 8000 + i,
        subject: subjects[i % subjects.length],
        customer: { name: `${names[i%names.length]} Perera`, email: `user${i}@demo.test`, phone: '+94 7' + String(Math.floor(Math.random()*1e8)).padStart(8,'0') },
        created: new Date(Date.now() - Math.random()*10*86400000).toISOString(),
        status: ['Open','Open','Pending','Resolved'][i%4],
        priority: ['Normal','High','Urgent','Normal'][i%4],
        messages: [
          { sender:'customer', body:`Hello, ${subjects[i % subjects.length].toLowerCase()}.`, time:new Date(Date.now() - Math.random()*9*86400000).toISOString() },
          { sender:'agent', body:'Thanks for reaching out — looking into this for you.', time:new Date(Date.now() - Math.random()*8*86400000).toISOString() }
        ],
        notes: '',
        escalated: false,
        lastUpdated: new Date().toISOString(),
        assignedTo: 'Support Agent'
      });
    }
    localStorage.setItem(TICKETS_KEY, JSON.stringify(out));
    return out;
  }

  function seedTemplatesIfEmpty(list){
    if (list.length) return list;
    const demo = [
      { id: 'TPL-1', title:'Order Shipped', body:'Hello {firstName}, your order #{orderId} has shipped! Tracking: {tracking}.' },
      { id: 'TPL-2', title:'Refund Initiated', body:'Hi {firstName}, we have initiated a refund for order #{orderId}. It may take 3–5 business days.' },
      { id: 'TPL-3', title:'We’re On It', body:'Hey {firstName}, we are checking with our warehouse team and will update you within 24 hours.' },
    ];
    localStorage.setItem(TPL_KEY, JSON.stringify(demo));
    return demo;
  }

  // KPIs
  function updateKpis(){
    const open = tickets.filter(t => ['Open','Pending','Escalated'].includes(t.status)).length;
    const urgent = tickets.filter(t => ['High','Urgent'].includes(t.priority) && !['Resolved','Closed'].includes(t.status)).length;
    const pending = tickets.filter(t => t.status === 'Pending').length;
    const sevenDaysAgo = new Date(); sevenDaysAgo.setDate(sevenDaysAgo.getDate()-7);
    const resolved7 = tickets.filter(t => t.status === 'Resolved' && new Date(t.lastUpdated) >= sevenDaysAgo).length;

    kpiOpen.textContent = open;
    kpiUrgent.textContent = urgent;
    kpiPending.textContent = pending;
    kpiResolved7d.textContent = resolved7;
  }

  // Urgent table
  urgentSearch.addEventListener('input', renderUrgent);
  urgentSort.addEventListener('change', renderUrgent);

  function renderUrgent(){
    const term = (urgentSearch.value || '').toLowerCase().trim();
    const list = tickets
      .filter(t => ['High','Urgent'].includes(t.priority) && !['Resolved','Closed'].includes(t.status))
      .filter(t => !term || [t.subject, t.customer.name, t.customer.email].join(' ').toLowerCase().includes(term))
      .map(t => ({...t, age: Date.now() - new Date(t.created).getTime()}));

    const [key,dir] = urgentSort.value.split(':');
    const mult = dir==='asc'?1:-1;
    list.sort((a,b) => {
      const A = key==='priority' ? (a.priority==='Urgent'?2:1) : a.age;
      const B = key==='priority' ? (b.priority==='Urgent'?2:1) : b.age;
      return (A>B?1:A<B?-1:0)*mult;
    });

    urgentTbody.innerHTML = list.map(t => `
      <tr>
        <td>#${t.id}</td>
        <td>${escape(t.subject)}</td>
        <td>${escape(t.customer.name)}</td>
        <td class="hide-sm">${escape(t.customer.email)}</td>
        <td><span class="badge ${t.priority==='Urgent'?'urgent':'high'}">${t.priority}</span></td>
        <td>${fmtAge(t.age)}</td>
        <td><a class="btn btn-ghost" href="ticket-management.html?id=${t.id}"><i class="fa fa-arrow-up-right-from-square"></i> Open</a></td>
      </tr>
    `).join('');
  }

  // Templates grid
  function renderTemplates(){
    tplGrid.innerHTML = templates.map(t => `
      <div class="tpl" data-id="${t.id}">
        <div class="title">${escape(t.title)}</div>
        <div class="body">${escape(t.body)}</div>
        <div class="actions">
          <button class="btn btn-ghost" data-act="copy"><i class="fa fa-copy"></i> Copy</button>
          <button class="btn btn-ghost" data-act="insert"><i class="fa fa-sign-in-alt"></i> Insert…</button>
          <button class="btn btn-ghost" data-act="edit"><i class="fa fa-pen"></i> Edit</button>
          <button class="btn btn-ghost" data-act="delete"><i class="fa fa-trash"></i> Delete</button>
        </div>
      </div>
    `).join('');
  }

  tplGrid.addEventListener('click', e => {
    const btn = e.target.closest('button'); if (!btn) return;
    const card = btn.closest('.tpl'); if (!card) return;
    const id = card.dataset.id;
    const tpl = templates.find(x => x.id === id); if (!tpl) return;
    const act = btn.dataset.act;

    if (act === 'copy'){
      navigator.clipboard?.writeText(tpl.body);
      alert('Copied template to clipboard.');
    }
    if (act === 'edit'){
      editingTplId = id;
      tplName.value = tpl.title; tplBody.value = tpl.body;
      openModal(tplModal);
    }
    if (act === 'delete'){
      if (!confirm('Delete this template?')) return;
      templates = templates.filter(x => x.id !== id); saveTemplates(); renderTemplates();
    }
    if (act === 'insert'){
      // Build ticket list (open ones)
      const openTickets = tickets.filter(t => !['Resolved','Closed'].includes(t.status));
      insertTicket.innerHTML = openTickets.map(t => `<option value="${t.id}">#${t.id} — ${escape(t.subject)}</option>`).join('');
      insertForm.onsubmit = (ev) => {
        ev.preventDefault();
        const tid = insertTicket.value;
        // pass template via query param
        location.href = `ticket-management.html?id=${tid}&tpl=${encodeURIComponent(id)}`;
      };
      openModal(insertModal);
    }
  });

  // Add template
  addTplBtn.addEventListener('click', () => {
    editingTplId = null;
    tplForm.reset();
    openModal(tplModal);
  });
  tplForm.addEventListener('submit', e => {
    e.preventDefault();
    const title = tplName.value.trim();
    const body = tplBody.value.trim();
    if (!title || !body) return alert('Please fill all fields.');
    if (editingTplId){
      const t = templates.find(x => x.id === editingTplId);
      t.title = title; t.body = body;
    } else {
      templates.push({ id: 'TPL-' + (Date.now()), title, body });
    }
    saveTemplates(); closeModal(tplModal); renderTemplates();
  });

  // Modal helpers
  function openModal(el){ el.setAttribute('aria-hidden','false'); }
  function closeModal(el){ el.setAttribute('aria-hidden','true'); }
  document.querySelectorAll('.modal [data-close]').forEach(b => b.addEventListener('click', e => closeModal(b.closest('.modal'))));
  document.querySelectorAll('.modal').forEach(m => m.addEventListener('click', e => { if (e.target.hasAttribute('data-close')) closeModal(m); }));

  // Utils
  const escape = s => String(s||'').replace(/[&<>"']/g,c=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  function fmtAge(ms){
    const d = Math.floor(ms/86400000), h = Math.floor((ms%86400000)/3600000);
    if (d>0) return `${d}d ${h}h`;
    const m = Math.floor((ms%3600000)/60000); return `${h}h ${m}m`;
  }

  // Init
  document.getElementById('globalSearchForm')?.addEventListener('submit', e => e.preventDefault());
  function init(){
    updateKpis();
    renderUrgent();
    renderTemplates();
  }
  init();
});
