document.addEventListener('DOMContentLoaded', () => {
  const TICKETS_KEY = 'nx_support_tickets_v1';

  // Elements
  const form = document.getElementById('contactForm');
  const nameInput = document.getElementById('nameInput');
  const emailInput = document.getElementById('emailInput');
  const orderInput = document.getElementById('orderInput');
  const categorySel = document.getElementById('categorySel');
  const prioritySel = document.getElementById('prioritySel');
  const subjectInput = document.getElementById('subjectInput');
  const messageInput = document.getElementById('messageInput');
  const fileInput = document.getElementById('fileInput');
  const filePreview = document.getElementById('filePreview');
  const agreeChk = document.getElementById('agreeChk');
  const charCount = document.getElementById('charCount');
  const formAlert = document.getElementById('formAlert');

  const successCard = document.getElementById('successCard');
  const succId = document.getElementById('succId');
  const succSub = document.getElementById('succSub');
  const succPri = document.getElementById('succPri');
  const succSta = document.getElementById('succSta');
  const newTicketBtn = document.getElementById('newTicketBtn');

  // Helpers
  const escape = s => String(s||'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  function loadTickets(){ try { return JSON.parse(localStorage.getItem(TICKETS_KEY) || '[]'); } catch { return []; } }
  function saveTickets(arr){ localStorage.setItem(TICKETS_KEY, JSON.stringify(arr)); }

  // Live counters
  messageInput.addEventListener('input', () => {
    charCount.textContent = `${messageInput.value.length} / ${messageInput.maxLength}`;
  });

  // File preview
  fileInput.addEventListener('change', async () => {
    filePreview.innerHTML = '';
    const f = fileInput.files?.[0];
    if (!f){ filePreview.hidden = true; return; }
    if (f.size > 5 * 1024 * 1024){
      showAlert('Attachment is too large (max 5 MB).'); fileInput.value=''; filePreview.hidden=true; return;
    }
    let chip = document.createElement('div');
    chip.className = 'file-chip';
    if (f.type.startsWith('image/')){
      const url = await fileToDataUrl(f);
      const img = document.createElement('img'); img.src = url; chip.appendChild(img);
    } else {
      const icon = document.createElement('i'); icon.className='fa fa-file';
      chip.appendChild(icon);
    }
    chip.appendChild(document.createTextNode(' ' + f.name));
    filePreview.appendChild(chip);
    filePreview.hidden = false;
  });

  function fileToDataUrl(file){
    return new Promise((resolve,reject) => {
      const fr = new FileReader(); fr.onload = () => resolve(fr.result); fr.onerror = reject; fr.readAsDataURL(file);
    });
  }

  // Validation helpers
  function err(el, msg){
    const s = document.querySelector(`.err[data-for="${el.id}"]`);
    if (s){ s.textContent = msg || ''; s.classList.toggle('show', !!msg); }
    el.classList.toggle('invalid', !!msg);
  }
  function clearAllErrors(){
    document.querySelectorAll('.err').forEach(e => e.classList.remove('show'));
    document.querySelectorAll('.invalid').forEach(e => e.classList.remove('invalid'));
    formAlert.hidden = true; formAlert.textContent = '';
  }
  function showAlert(msg){
    formAlert.textContent = msg; formAlert.hidden = false;
  }

  // Submit
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    clearAllErrors();

    // Honeypot
    if (document.getElementById('company').value){ return; }

    // Validate
    let ok = true;
    if (!nameInput.value.trim()){ err(nameInput, 'Please enter your name.'); ok=false; }
    if (!emailInput.value.trim() || !/.+@.+\..+/.test(emailInput.value)){ err(emailInput, 'Enter a valid email.'); ok=false; }
    if (!categorySel.value){ err(categorySel, 'Please select a category.'); ok=false; }
    if (!subjectInput.value.trim()){ err(subjectInput, 'Please add a subject.'); ok=false; }
    if (!messageInput.value.trim()){ err(messageInput, 'Please describe the issue.'); ok=false; }
    if (!agreeChk.checked){ err(agreeChk, 'Please accept the privacy policy.'); ok=false; }
    if (!ok){ showAlert('Please fix the highlighted fields.'); return; }

    // Prepare ticket
    const tickets = loadTickets();
    const newId = nextTicketId(tickets);
    const now = new Date().toISOString();

    let attachment = '';
    const f = fileInput.files?.[0];
    if (f && f.size <= 5 * 1024 * 1024){
      try { attachment = await fileToDataUrl(f); } catch {}
    }

    const ticket = {
      id: newId,
      subject: subjectInput.value.trim(),
      customer: {
        name: nameInput.value.trim(),
        email: emailInput.value.trim(),
        phone: '' // optional; you can add a phone field later
      },
      created: now,
      status: 'Open',
      priority: prioritySel.value || 'Normal',
      category: categorySel.value || 'Other',
      messages: [
        {
          sender: 'customer',
          body: buildInitialBody(),
          time: now,
          attachment: attachment ? { name: f?.name || 'attachment', dataUrl: attachment, type: f?.type || '' } : null
        }
      ],
      notes: '',
      escalated: false,
      lastUpdated: now,
      assignedTo: 'Support Team',
      orderId: (orderInput.value || '').replace(/\D/g,'') || ''
    };

    tickets.push(ticket); saveTickets(tickets);

    // Success UI
    form.reset(); filePreview.hidden = true; charCount.textContent = '0 / 2000';
    document.querySelectorAll('.err').forEach(e => e.classList.remove('show'));
    document.querySelectorAll('.invalid').forEach(e => e.classList.remove('invalid'));
    form.closest('.surface').style.display = 'none';
    successCard.hidden = false;

    succId.textContent = `#${ticket.id}`;
    succSub.textContent = ticket.subject;
    succPri.textContent = ticket.priority;
    succSta.textContent = 'Open';
  });

  // Reset to create another
  newTicketBtn.addEventListener('click', () => {
    successCard.hidden = true;
    const formSurface = document.querySelector('.contact-form').closest('.surface');
    formSurface.style.display = '';
    form.reset(); filePreview.hidden = true; charCount.textContent = '0 / 2000';
    clearAllErrors();
  });

  function buildInitialBody(){
    const lines = [];
    if (orderInput.value.trim()) lines.push(`Order #: ${orderInput.value.trim()}`);
    lines.push(messageInput.value.trim());
    return lines.join('\n\n');
  }

  function nextTicketId(list){
    // Use a simple incremental generator starting at 9001 if empty
    const max = list.reduce((m,t)=> Math.max(m, Number(t.id)||0), 9000);
    return max + 1;
  }

  // Prefill from query params
  (function prefill(){
    const p = new URLSearchParams(location.search);
    if (p.get('email')) emailInput.value = p.get('email');
    if (p.get('order')) orderInput.value = p.get('order');
    if (p.get('subject')) subjectInput.value = p.get('subject');
    if (p.get('priority')) prioritySel.value = ['Normal','High','Urgent'].includes(p.get('priority')) ? p.get('priority') : 'Normal';
    if (p.get('category')) categorySel.value = p.get('category');
  })();
});
