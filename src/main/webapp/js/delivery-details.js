document.addEventListener('DOMContentLoaded', () => {
 

  // Keys
  const ASSIGN_KEY = 'nx_delivery_assignments_v1';
  const ISSUES_KEY = 'nx_delivery_issues_v1';

  // Elements
  const sumOrder = document.getElementById('sumOrder');
  const sumCustomer = document.getElementById('sumCustomer');
  const sumPhone = document.getElementById('sumPhone');
  const sumAddress = document.getElementById('sumAddress');
  const sumPriority = document.getElementById('sumPriority');
  const sumStatus = document.getElementById('sumStatus');
  const timeline = document.getElementById('timeline');

  const btnOut = document.getElementById('btnOut');
  const btnDelivered = document.getElementById('btnDelivered');
  const btnFailed = document.getElementById('btnFailed');
  const navLink = document.getElementById('navLink');

  const issueForm = document.getElementById('issueForm');
  const issueType = document.getElementById('issueType');
  const issueDesc = document.getElementById('issueDesc');
  const issuePhoto = document.getElementById('issuePhoto');

  // Data
  let assignments = loadAssignments();
  function loadAssignments(){ try { return JSON.parse(localStorage.getItem(ASSIGN_KEY) || '[]'); } catch { return []; } }
  function saveAssignments(){ localStorage.setItem(ASSIGN_KEY, JSON.stringify(assignments)); }
  function loadIssues(){ try { return JSON.parse(localStorage.getItem(ISSUES_KEY) || '[]'); } catch { return []; } }
  function saveIssues(list){ localStorage.setItem(ISSUES_KEY, JSON.stringify(list)); }

  // Params
  const params = new URLSearchParams(location.search);
  const id = Number(params.get('id'));
  let a = assignments.find(x => x.id === id);
  if (!a){ alert('Assignment not found'); location.href='delivery-dashboard.html'; return; }

  // Fill summary
  sumOrder.textContent = `#${a.orderId}`;
  sumCustomer.textContent = a.customer;
  sumPhone.textContent = a.phone;
  sumPhone.href = `tel:${a.phone.replace(/[^0-9+]/g,'')}`;
  sumAddress.textContent = a.address;
  sumPriority.textContent = a.priority;
  sumPriority.classList.add(a.priority);
  setStatus(a.status);

  // Map
  const map = L.map('map', { zoomControl:true }).setView([a.lat, a.lng], 14);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution:'&copy; OpenStreetMap' }).addTo(map);
  const marker = L.marker([a.lat, a.lng]).addTo(map).bindPopup(`<strong>${a.customer}</strong><br/>${a.address}`).openPopup();

  // Nav link
  navLink.href = `https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(a.lat + ',' + a.lng)}&destination_place_id=&travelmode=driving`;

  // Timeline render
  function pushTimeline(msg){
    const time = new Date().toLocaleString();
    const div = document.createElement('div');
    div.textContent = `${time} — ${msg}`;
    timeline.prepend(div);
  }

  function setStatus(status){
    a.status = status;
    sumStatus.textContent = status;
    sumStatus.className = 'status ' + status;
    saveAssignments();
  }

  // Buttons
  btnOut.addEventListener('click', () => {
    if (a.status === 'Delivered') return alert('Already delivered.');
    setStatus('Out for delivery'); pushTimeline('Marked Out for delivery');
  });
  btnDelivered.addEventListener('click', () => {
    setStatus('Delivered'); pushTimeline('Marked Delivered');
  });
  btnFailed.addEventListener('click', () => {
    // focus issue form
    document.getElementById('issueType').focus();
    window.scrollTo({ top: issueForm.getBoundingClientRect().top + window.scrollY - 90, behavior:'smooth' });
  });

  // Issue form
  issueForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!issueType.value){ return alert('Select an issue type.'); }
    let photoDataUrl = '';
    const file = issuePhoto.files?.[0];
    if (file){
      photoDataUrl = await fileToDataUrl(file);
    }
    const issues = loadIssues();
    const record = {
      id: 'ISS-' + (issues.length + 1),
      time: new Date().toISOString(),
      assignmentId: a.id,
      orderId: a.orderId,
      type: issueType.value,
      desc: issueDesc.value.trim(),
      photo: photoDataUrl
    };
    issues.push(record); saveIssues(issues);
    setStatus('Failed attempt');
    pushTimeline(`Issue reported: ${record.type}${record.desc?` — ${record.desc}`:''}`);
    issueForm.reset();
    alert('Issue submitted and status set to "Failed attempt".');
  });

  function fileToDataUrl(file){
    return new Promise((resolve,reject) => {
      const fr = new FileReader(); fr.onload = () => resolve(fr.result); fr.onerror = reject; fr.readAsDataURL(file);
    });
  }
});
