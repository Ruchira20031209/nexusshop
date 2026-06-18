document.addEventListener('DOMContentLoaded', () => {


  // Keys
  const TICKETS_KEY = 'nx_support_tickets_v1';
  const TPL_KEY = 'nx_support_templates_v1';

  // Elements
  const ticketTitle = document.getElementById('ticketTitle');
  const metaId = document.getElementById('metaId');
  const metaSubject = document.getElementById('metaSubject');
  const metaCreated = document.getElementById('metaCreated');
  const metaUpdated = document.getElementById('metaUpdated');

  const custName = document.getElementById('custName');
  const custEmail = document.getElementById('custEmail');
  const custPhone = document.getElementById('custPhone');

  const statusSel = document.getElementById('statusSel');
  const prioritySel = document.getElementById('prioritySel');
  const btnEscalate = document.getElementById('btnEscalate');
  const notesInput = document.getElementById('notesInput');

  const subjectLine = document.getElementById('subjectLine');
  const badgeStatus = document.getElementById('badgeStatus');
  const badgePriority = document.getElementById('badgePriority');

  const thread = document.getElementById('thread');
  const tplSelect = document.getElementById('tplSelect');
  const replyInput = document.getElementById('replyInput');
  const btnSend = document.getElementById('btnSend');
  const btnAttach = document.getElementById('btnAttach');

  // Load data
  let tickets = loadTickets();
  let templates = loadTemplates();

  function loadTickets(){ try { return JSON.parse(localStorage.getItem(TICKETS_KEY) || '[]'); } catch { return []; } }
  function saveTickets(){ localStorage.setItem(TICKETS_KEY, JSON.stringify(tickets)); }
  function loadTemplates(){ try { return JSON.parse(localStorage.getItem(TPL_KEY) || '[]'); } catch { return []; } }

  // Determine ticket
  const params = new URLSearchParams(location.search);
  const id = Number(params.get('id'));
  if (!id){ alert('Missing ticket id'); location.href='support-dashboard.html'; return; }
  let t = tickets.find(x => x.id === id);
  if (!t){ alert('Ticket not found'); location.href='support-dashboard.html'; return; }

  // Prefill template via ?tpl=ID
  const tplParam = params.get('tpl');
  if (tplParam){
    const tpl = templates.find(x => String(x.id) === tplParam);
    if (tpl) replyInput.value = personalize(tpl.body, t.customer);
  }

  // Render
  function render(){
    ticketTitle.textContent = `Ticket #${t.id}`;
    metaId.textContent = `#${t.id}`;
    metaSubject.textContent = t.subject;
    subjectLine.textContent = t.subject;
    metaCreated.textContent = new Date(t.created).toLocaleString();
    metaUpdated.textContent = new Date(t.lastUpdated).toLocaleString();

    custName.textContent = t.customer.name;
    custEmail.textContent = t.customer.email; custEmail.href = `mailto:${t.customer.email}`;
    custPhone.textContent = t.customer.phone; custPhone.href = `tel:${t.customer.phone.replace(/[^0-9+]/g,'')}`;

    statusSel.value = t.status;
    prioritySel.value = t.priority;
    badgeStatus.textContent = t.status;
    badgePriority.textContent = t.priority;

    notesInput.value = t.notes || '';

    // templates dropdown
    tplSelect.innerHTML = `<option value="">Insert template…</option>` + templates.map(tp => `<option value="${tp.id}">${escape(tp.title)}</option>`).join('');

    // thread
    thread.innerHTML = t.messages.map(m => `
      <div class="msg ${m.sender}">
        <div class="body">${formatBody(m.body)}</div>
        <div class="meta">${m.sender === 'agent' ? 'You' : t.customer.name} • ${new Date(m.time).toLocaleString()}</div>
      </div>
    `).join('');
    thread.scrollTop = thread.scrollHeight;
  }

  // Actions
  statusSel.addEventListener('change', () => { t.status = statusSel.value; touch(); render(); });
  prioritySel.addEventListener('change', () => { t.priority = prioritySel.value; touch(); render(); });

  btnEscalate.addEventListener('click', () => {
    if (t.status === 'Escalated'){ return alert('Already escalated.'); }
    t.status = 'Escalated'; t.priority = 'Urgent'; t.escalated = true;
    pushMessage({ sender:'agent', body:'[System] Ticket escalated to Tier 2 support.', time:new Date().toISOString() });
    touch(); render();
  });

  // notes (debounced save)
  let notesTimer;
  notesInput.addEventListener('input', () => {
    clearTimeout(notesTimer);
    notesTimer = setTimeout(() => { t.notes = notesInput.value; touch(false); }, 300);
  });

  // templates -> composer
  tplSelect.addEventListener('change', () => {
    const tplId = tplSelect.value; if (!tplId) return;
    const tpl = templates.find(x => String(x.id) === String(tplId)); if (!tpl) return;
    const insert = personalize(tpl.body, t.customer);
    if (!replyInput.value) replyInput.value = insert;
    else replyInput.value = replyInput.value.trimEnd() + '\n\n' + insert;
    replyInput.focus();
    tplSelect.value = '';
  });

  btnSend.addEventListener('click', () => {
    const text = replyInput.value.trim();
    if (!text) return alert('Write a reply first.');
    pushMessage({ sender:'agent', body:text, time:new Date().toISOString() });
    replyInput.value = '';
    t.status = (t.status === 'Open') ? 'Pending' : t.status; // common flow: reply sets Pending
    touch(); render();
  });

  btnAttach.addEventListener('click', () => alert('Attachment UI can be wired to your backend later.'));

  // Helpers
  function pushMessage(m){ t.messages.push(m); }
  function touch(updateTime=true){ if (updateTime) t.lastUpdated = new Date().toISOString(); persist(); }
  function persist(){ const idx = tickets.findIndex(x => x.id === t.id); if (idx>=0) tickets[idx]=t; saveTickets(); }
  function personalize(body, customer){
    return body
      .replaceAll('{firstName}', (customer.name||'').split(' ')[0] || 'there')
      .replaceAll('{name}', customer.name || '')
      .replaceAll('{email}', customer.email || '')
      .replaceAll('{orderId}', (t.subject.match(/\d+/)||[''])[0])
      .replaceAll('{tracking}', 'TRK-'+Math.floor(Math.random()*1e6));
  }
  function escape(s){ return String(s||'').replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
  function formatBody(s){
    // Escape then basic newlines → <br>
    return escape(s).replace(/\n/g,'<br/>');
  }

  // Init
  document.getElementById('ticketSearchForm')?.addEventListener('submit', e => e.preventDefault());
  render();
});
