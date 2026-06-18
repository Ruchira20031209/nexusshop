document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const sidebar = document.getElementById('sidebar');
  const toggleBtn = document.querySelector('.sidebar-toggle');
  const themeToggle = document.getElementById('themeToggle');

  const globalSearch = document.getElementById('globalSearch');
  const userSearch = document.getElementById('userSearch');
  const roleFilter = document.getElementById('roleFilter');
  const statusFilter = document.getElementById('statusFilter');
  const sortSelect = document.getElementById('sortSelect');
  const usersTbody = document.getElementById('usersTbody');
  const resultMeta = document.getElementById('resultMeta');
  const selectAll = document.getElementById('selectAll');
  const bulkActivate = document.getElementById('bulkActivate');
  const bulkSuspend = document.getElementById('bulkSuspend');
  const bulkDelete = document.getElementById('bulkDelete');
  const pagination = document.getElementById('pagination');
  const pageSizeSel = document.getElementById('pageSize');
  const exportBtn = document.getElementById('exportBtn');
  const inviteBtn = document.getElementById('inviteBtn');

  // Modal elements
  const modal = document.getElementById('userModal');
  const userForm = document.getElementById('userForm');
  const userId = document.getElementById('userId');
  const fullName = document.getElementById('fullName');
  const email = document.getElementById('email');
  const role = document.getElementById('role');
  const status = document.getElementById('status');
  const permChips = document.getElementById('permChips');

  // Local state (replace with API later)
  const KEY = 'nx_admin_users_v1';
  let users = seedIfEmpty(load());
  let filtered = [];
  let page = 1;

  // Layout + theme
  toggleBtn.addEventListener('click', () => sidebar.classList.toggle('open'));
  themeToggle?.addEventListener('click', () => {
    document.documentElement.classList.toggle('dark');
    localStorage.setItem('nx_theme', document.documentElement.classList.contains('dark') ? 'dark' : 'light');
  });
  if (localStorage.getItem('nx_theme') === 'dark') document.documentElement.classList.add('dark');

  // Seeders / Storage
  function load(){ try{ return JSON.parse(localStorage.getItem(KEY) || '[]'); }catch{ return []; } }
  function persist(){ localStorage.setItem(KEY, JSON.stringify(users)); }
  function seedIfEmpty(arr){
    if (arr.length) return arr;
    const roles = ['Admin','Manager','Support','Customer'];
    const statuses = ['Active','Suspended','Invited'];
    const names = ['Alex Johnson','Sam Lee','Jordan Chen','Taylor Patel','Jamie Rivera','Morgan Kim','Riley Brown','Casey Nguyen','Avery Clark','Harper Diaz','Elliot Shah','Dakota Park','Quinn Flores','Rowan Li','Parker Gomez','Jules Ahmed'];
    const out = [];
    for (let i=1; i<=120; i++){
      const name = names[i % names.length];
      const mail = `${name.toLowerCase().replace(/[^a-z]/g,'.')}${i}@nexus.demo`;
      const created = new Date(); created.setDate(created.getDate() - Math.floor(Math.random()*400));
      const lastSeen = new Date(created); lastSeen.setDate(created.getDate() + Math.floor(Math.random()*380));
      out.push({
        id: 5000 + i,
        name,
        email: mail,
        role: roles[Math.floor(Math.random()*roles.length)],
        status: statuses[Math.floor(Math.random()*statuses.length)],
        created: created.toISOString(),
        lastSeen: lastSeen.toISOString(),
        perms: []
      });
    }
    localStorage.setItem(KEY, JSON.stringify(out));
    return out;
  }

  // Helpers
  function fmtDate(iso){
    const d = new Date(iso);
    return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}`;
  }
  const escapeHtml = (s='') => s.replace(/[&<>"']/g, c=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]));
  function sortBy(arr, key, dir='asc'){
    const m = dir==='asc'?1:-1;
    return [...arr].sort((a,b)=> (a[key] > b[key] ? 1 : a[key] < b[key] ? -1 : 0) * m);
  }
  function chunk(arr, size, p){ const s=(p-1)*size; return arr.slice(s, s+size); }

  // Filtering + sorting
  function applyFilters(){
    const term = (userSearch.value || globalSearch.value || '').toLowerCase().trim();
    const r = roleFilter.value;
    const s = statusFilter.value;

    filtered = users.filter(u => {
      const matchTerm = !term || [u.id, u.name, u.email].join(' ').toLowerCase().includes(term);
      const matchRole = !r || u.role === r;
      const matchStatus = !s || u.status === s;
      return matchTerm && matchRole && matchStatus;
    });

    const [key, dir] = sortSelect.value.split(':');
    filtered = sortBy(filtered, key, dir);
    page = 1;
    renderTable();
  }

  // Render
  function renderTable(){
    const pageSize = Number(pageSizeSel.value);
    const total = filtered.length;
    const pages = Math.max(1, Math.ceil(total / pageSize));
    if (page > pages) page = pages;

    const rows = chunk(filtered, pageSize, page);
    usersTbody.innerHTML = rows.map(rowHtml).join('');
    renderPagination(pages);

    resultMeta.textContent = `${total.toLocaleString()} user${total===1?'':'s'}`;
    selectAll.checked = false;
  }

  function rowHtml(u){
    return `
      <tr>
        <td><input type="checkbox" class="row-check" data-id="${u.id}"/></td>
        <td>#${u.id}</td>
        <td>${escapeHtml(u.name)}</td>
        <td>${escapeHtml(u.email)}</td>
        <td>${escapeHtml(u.role)}</td>
        <td><span class="badge ${u.status}">${u.status}</span></td>
        <td>${fmtDate(u.created)}</td>
        <td>${fmtDate(u.lastSeen)}</td>
        <td class="row-actions">
          <button class="icon-mini" data-action="edit" data-id="${u.id}" title="Edit"><i class="fa fa-pen"></i></button>
          <button class="icon-mini" data-action="reset" data-id="${u.id}" title="Send password reset"><i class="fa fa-key"></i></button>
          <button class="icon-mini" data-action="more" data-id="${u.id}" title="More"><i class="fa fa-ellipsis"></i></button>
        </td>
      </tr>
    `;
  }

  function renderPagination(pages){
    const btn = (p, label=p) => `<button data-page="${p}" class="${p===page?'active':''}">${label}</button>`;
    let html = '';
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

  // Events — filters/search/sort
  [userSearch, roleFilter, statusFilter, sortSelect].forEach(el => el.addEventListener('input', applyFilters));
  globalSearch.addEventListener('input', () => { userSearch.value = globalSearch.value; applyFilters(); });
  pageSizeSel.addEventListener('change', () => renderTable());

  document.querySelector('#usersTable thead').addEventListener('click', e => {
    const th = e.target.closest('th[data-sort]'); if (!th) return;
    const key = th.dataset.sort;
    let [curKey, curDir] = sortSelect.value.split(':');
    let dir = (curKey === key && curDir === 'asc') ? 'desc' : 'asc';
    sortSelect.value = `${key}:${dir}`;
    applyFilters();
  });

  pagination.addEventListener('click', e => {
    const p = e.target.dataset.page; if (!p) return;
    page = Number(p); renderTable();
  });

  // Row actions
  usersTbody.addEventListener('click', e => {
    const btn = e.target.closest('.icon-mini'); if (!btn) return;
    const id = Number(btn.dataset.id);
    const action = btn.dataset.action;
    if (action === 'edit') openModal(id);
    if (action === 'reset') alert('Password reset link sent to user #' + id + ' (wire to backend)');
    if (action === 'more') {
      const u = users.find(x=>x.id===id);
      alert(`User #${id}\nName: ${u.name}\nEmail: ${u.email}\nRole: ${u.role}\nStatus: ${u.status}`);
    }
  });

  // Bulk
  selectAll.addEventListener('change', () => {
    document.querySelectorAll('.row-check').forEach(cb => cb.checked = selectAll.checked);
  });
  bulkActivate.addEventListener('click', ()=> bulkStatus('Active'));
  bulkSuspend.addEventListener('click', ()=> bulkStatus('Suspended'));
  bulkDelete.addEventListener('click', ()=> bulkDeleteUsers());

  function selectedIds(){ return [...document.querySelectorAll('.row-check:checked')].map(cb=>Number(cb.dataset.id)); }
  function bulkStatus(s){
    const ids = selectedIds(); if (!ids.length) return;
    users.forEach(u => { if (ids.includes(u.id)) u.status = s; });
    persist(); applyFilters();
  }
  function bulkDeleteUsers(){
    const ids = selectedIds(); if (!ids.length) return;
    if (!confirm(`Delete ${ids.length} user(s)? This cannot be undone.`)) return;
    users = users.filter(u => !ids.includes(u.id));
    persist(); applyFilters();
  }

  // Export
  exportBtn.addEventListener('click', () => {
    const rows = filtered.length ? filtered : users;
    const head = ['id','name','email','role','status','created','lastSeen'];
    const csv = [head.join(',')].concat(rows.map(u => [
      u.id, `"${u.name}"`, `"${u.email}"`, u.role, u.status, u.created, u.lastSeen
    ].join(','))).join('\n');
    const blob = new Blob([csv], {type:'text/csv;charset=utf-8;'});
    const url = URL.createObjectURL(blob);
    const a = Object.assign(document.createElement('a'), { href:url, download:'users-export.csv' });
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  });

  // Modal logic
  inviteBtn.addEventListener('click', ()=> openModal());
  modal.addEventListener('click', e => { if (e.target.hasAttribute('data-close')) closeModal(); });
  document.querySelectorAll('#userModal [data-close]').forEach(b => b.addEventListener('click', closeModal));

  function openModal(id){
    const editing = !!id;
    userForm.reset();
    userId.value = editing ? id : '';
    document.getElementById('userModalTitle').textContent = editing ? 'Edit User' : 'Add User';
    [...permChips.querySelectorAll('.chip')].forEach(c => c.classList.remove('active'));

    if (editing){
      const u = users.find(x => x.id === id);
      fullName.value = u.name;
      email.value = u.email;
      role.value = u.role;
      status.value = u.status;
      (u.perms || []).forEach(p => permChips.querySelector(`.chip[data-perm="${p}"]`)?.classList.add('active'));
    }
    modal.setAttribute('aria-hidden','false');
  }
  function closeModal(){ modal.setAttribute('aria-hidden','true'); }

  // Toggle permission chips
  permChips.addEventListener('click', e => {
    const chip = e.target.closest('.chip'); if (!chip) return;
    chip.classList.toggle('active');
  });

  // Save user
  userForm.addEventListener('submit', e => {
    e.preventDefault();
    const name = fullName.value.trim();
    const mail = email.value.trim();
    const r = role.value;
    const s = status.value;
    if (!name) return alert('Name is required');
    if (!/^\S+@\S+\.\S+$/.test(mail)) return alert('Valid email is required');
    if (!r || !s) return alert('Role and Status are required');

    const perms = [...permChips.querySelectorAll('.chip.active')].map(c => c.dataset.perm);

    if (userId.value){
      const id = Number(userId.value);
      const u = users.find(x => x.id === id);
      Object.assign(u, { name, email: mail, role: r, status: s, perms });
    } else {
      const id = (users[users.length-1]?.id || 5000) + 1;
      const now = new Date().toISOString();
      users.push({ id, name, email: mail, role: r, status: s, created: now, lastSeen: now, perms });
    }

    persist(); closeModal(); applyFilters();
  });

  // Init
  (function init(){
    applyFilters();
  })();
});
