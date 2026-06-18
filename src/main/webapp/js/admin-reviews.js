document.addEventListener('DOMContentLoaded', () => {
  // Shell + theme
  const sidebar = document.getElementById('sidebar');
  document.querySelector('.sidebar-toggle')?.addEventListener('click', () => sidebar.classList.toggle('open'));
  [document.getElementById('themeToggle'), document.getElementById('themeToggle2')].forEach(btn => {
    btn?.addEventListener('click', () => {
      document.documentElement.classList.toggle('dark');
      localStorage.setItem('nx_theme', document.documentElement.classList.contains('dark') ? 'dark' : 'light');
    });
  });
  if (localStorage.getItem('nx_theme') === 'dark') document.documentElement.classList.add('dark');

  // Elements
  const globalSearch = document.getElementById('globalSearch');
  const reviewSearch = document.getElementById('reviewSearch');
  const ratingFilter = document.getElementById('ratingFilter');
  const verifiedFilter = document.getElementById('verifiedFilter');
  const photosFilter = document.getElementById('photosFilter');
  const fromDate = document.getElementById('fromDate');
  const toDate = document.getElementById('toDate');
  const sortSelect = document.getElementById('sortSelect');
  const clearFilters = document.getElementById('clearFilters');

  const chipButtons = [...document.querySelectorAll('.filter-chip')];
  const chipAll = document.getElementById('chipAll');
  const chipPending = document.getElementById('chipPending');
  const chipApproved = document.getElementById('chipApproved');
  const chipRejected = document.getElementById('chipRejected');
  const chipFlagged = document.getElementById('chipFlagged');

  const pageSizeSel = document.getElementById('pageSize');
  const tbody = document.getElementById('reviewsTbody');
  const pagination = document.getElementById('pagination');
  const selectAll = document.getElementById('selectAll');
  const bulkApprove = document.getElementById('bulkApprove');
  const bulkReject = document.getElementById('bulkReject');
  const bulkDelete = document.getElementById('bulkDelete');
  const exportBtn = document.getElementById('exportBtn');
  const resultMeta = document.getElementById('resultMeta');

  // Drawer
  const drawer = document.getElementById('reviewDrawer');
  const drawerBody = document.getElementById('drawerBody');
  const drawerTitle = document.getElementById('drawerTitle');
  const drawerApprove = document.getElementById('drawerApprove');
  const drawerReject = document.getElementById('drawerReject');
  const drawerFlag = document.getElementById('drawerFlag');
  const drawerDelete = document.getElementById('drawerDelete');
  drawer.addEventListener('click', e => { if (e.target.hasAttribute('data-close')) closeDrawer(); });
  document.querySelectorAll('#reviewDrawer [data-close]').forEach(b => b.addEventListener('click', closeDrawer));

  // State (replace with backend later)
  const KEY = 'nx_admin_reviews_v1';
  let reviews = seedIfEmpty(load());
  let filtered = [];
  let page = 1;
  let statusScope = 'Pending'; // default chip
  let currentViewingId = null;

  // Storage
  function load(){ try { return JSON.parse(localStorage.getItem(KEY) || '[]'); } catch { return []; } }
  function persist(){ localStorage.setItem(KEY, JSON.stringify(reviews)); }
  function seedIfEmpty(list){
    if (list.length) return list;
    const statuses = ['Pending','Approved','Rejected'];
    const products = [
      { id: 2001, title: 'Phone X Pro', image: 'images/products/placeholder.png' },
      { id: 2002, title: 'Laptop A15', image: 'images/products/placeholder.png' },
      { id: 2003, title: 'Noise Cancelling Headphones', image: 'images/products/placeholder.png' },
      { id: 2004, title: 'Gaming Mouse G7', image: 'images/products/placeholder.png' },
      { id: 2005, title: '4K Monitor 27"', image: 'images/products/placeholder.png' },
    ];
    const first = ['Alex','Sam','Jordan','Taylor','Jamie','Morgan','Riley','Casey','Avery','Harper','Elliot','Parker','Rowan','Dakota','Quinn','Jules'];
    const last = ['Johnson','Lee','Chen','Patel','Rivera','Kim','Brown','Nguyen','Clark','Diaz','Shah','Park','Flores','Li','Gomez','Ahmed'];
    const words = ['amazing','solid','great','decent','okay','mediocre','poor','excellent','fast','slick','heavy','light','battery','screen','sound','build'];
    const out = [];
    for (let i=1; i<=180; i++){
      const p = products[i % products.length];
      const rating = Math.floor(Math.random()*5)+1;
      const author = `${first[i%first.length]} ${last[i%last.length]}`;
      const email = `${author.toLowerCase().replace(/[^a-z]/g,'.')}${i}@nexus.demo`;
      const d = new Date(); d.setDate(d.getDate() - Math.floor(Math.random()*240));
      const status = statuses[Math.floor(Math.random()*statuses.length)];
      const flagged = Math.random() > .85;
      const headline = `${['Excellent','Good','Okay','Bad','Terrible'][5-rating]} ${p.title}`;
      const body = Array.from({length: 16 + Math.floor(Math.random()*80)}, () => words[Math.floor(Math.random()*words.length)]).join(' ') + '.';
      const photos = Math.random() > .7 ? ['images/products/placeholder.png'] : [];
      out.push({
        id: 7000 + i,
        productId: p.id,
        productTitle: p.title,
        productImage: p.image,
        rating,
        headline,
        body,
        pros: Math.random()>.5 ? 'Battery life, camera' : '',
        cons: Math.random()>.6 ? 'Price, weight' : '',
        author,
        email,
        verified: Math.random() > .45,
        helpful: Math.floor(Math.random()*120),
        photos,
        status,
        flagged,
        date: d.toISOString(),
        response: '',
        notes: ''
      });
    }
    localStorage.setItem(KEY, JSON.stringify(out));
    return out;
  }

  // Helpers
  const fmtDate = iso => { const d = new Date(iso); return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}`; };
  const escapeHtml = s => String(s||'').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const starHtml = n => '★★★★★☆☆☆☆☆'.slice(5 - Math.max(0, Math.min(5, n)), 10 - Math.max(0, Math.min(5, n))).replace(/★/g,'<i class="fa fa-star"></i>').replace(/☆/g,'<i class="fa-regular fa-star"></i>');
  function withinRange(iso, from, to){
    const d = new Date(iso);
    if (from && d < new Date(from)) return false;
    if (to){ const t = new Date(to); t.setHours(23,59,59,999); if (d > t) return false; }
    return true;
  }
  function sortBy(arr, key, dir='asc'){ const m = dir==='asc'?1:-1; return [...arr].sort((a,b)=> (a[key]>b[key]?1:a[key]<b[key]?-1:0)*m); }
  function chunk(arr, size, p){ const s=(p-1)*size; return arr.slice(s, s+size); }

  // Counters for chips
  function updateChipCounts(){
    chipAll.textContent = reviews.length;
    chipPending.textContent = reviews.filter(r => r.status==='Pending').length;
    chipApproved.textContent = reviews.filter(r => r.status==='Approved').length;
    chipRejected.textContent = reviews.filter(r => r.status==='Rejected').length;
    chipFlagged.textContent = reviews.filter(r => r.flagged).length;
  }

  // Filtering
  function applyFilters(){
    const term = (reviewSearch.value || globalSearch.value || '').toLowerCase().trim();
    const rf = ratingFilter.value;
    const vf = verifiedFilter.value;
    const pf = photosFilter.value;
    const from = fromDate.value;
    const to = toDate.value;

    filtered = reviews.filter(r => {
      const statusHit = statusScope === '' ? true :
                        statusScope === 'Flagged' ? !!r.flagged : r.status === statusScope;
      const textHit = !term || [r.id, r.productTitle, r.headline, r.author, r.email].join(' ').toLowerCase().includes(term);
      const ratingHit = !rf || r.rating >= Number(rf);
      const verifiedHit = !vf || r.verified;
      const photosHit = !pf || (r.photos && r.photos.length);
      const dateHit = withinRange(r.date, from, to);
      return statusHit && textHit && ratingHit && verifiedHit && photosHit && dateHit;
    });

    const [key, dir] = sortSelect.value.split(':');
    filtered = sortBy(filtered, key, dir);
    page = 1;
    renderTable();
    updateChipCounts();
  }

  // Table rendering
  function rowHtml(r){
    const badge = `<span class="badge ${r.flagged ? 'Flagged' : r.status}">${r.flagged ? 'Flagged' : r.status}</span>`;
    return `
      <tr>
        <td><input type="checkbox" class="row-check" data-id="${r.id}"/></td>
        <td>#${r.id}</td>
        <td>
          <div class="product-cell">
            <img src="${r.productImage}" alt=""/>
            <div class="product-meta">
              <div style="font-weight:700">${escapeHtml(r.productTitle)}</div>
              <div class="snippet">${escapeHtml(r.headline || r.body)}</div>
            </div>
          </div>
        </td>
        <td><div class="stars" title="${r.rating} stars">${starHtml(r.rating)}</div><div class="dim">${r.verified ? 'Verified' : ''}${r.photos?.length ? (r.verified ? ' • ' : '') + 'Photos' : ''}</div></td>
        <td>${escapeHtml(r.author)}</td>
        <td class="dim">${escapeHtml(r.email)}</td>
        <td>${fmtDate(r.date)}</td>
        <td>${badge}</td>
        <td class="dim">${r.helpful} helpful</td>
        <td class="row-actions">
          <button class="icon-mini" data-action="view" data-id="${r.id}" title="View"><i class="fa fa-eye"></i></button>
          <button class="icon-mini" data-action="approve" data-id="${r.id}" title="Approve"><i class="fa fa-check"></i></button>
          <button class="icon-mini" data-action="reject" data-id="${r.id}" title="Reject"><i class="fa fa-ban"></i></button>
          <button class="icon-mini" data-action="flag" data-id="${r.id}" title="Toggle flag"><i class="fa fa-flag"></i></button>
          <button class="icon-mini" data-action="delete" data-id="${r.id}" title="Delete"><i class="fa fa-trash"></i></button>
        </td>
      </tr>
    `;
  }

  function renderTable(){
    const pageSize = Number(pageSizeSel.value);
    const total = filtered.length;
    const pages = Math.max(1, Math.ceil(total / pageSize));
    if (page > pages) page = pages;

    const rows = chunk(filtered, pageSize, page);
    tbody.innerHTML = rows.map(rowHtml).join('');
    renderPagination(pages);

    resultMeta.textContent = `${total.toLocaleString()} review${total===1?'':'s'}`;
    selectAll.checked = false;
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

  // Sorting via header click
  document.querySelector('#reviewsTable thead').addEventListener('click', e => {
    const th = e.target.closest('th[data-sort]'); if (!th) return;
    const key = th.dataset.sort;
    let [curKey, curDir] = sortSelect.value.split(':');
    const dir = (curKey === key && curDir === 'asc') ? 'desc' : 'asc';
    sortSelect.value = `${key}:${dir}`; applyFilters();
  });

  // Events: chips
  chipButtons.forEach(btn => btn.addEventListener('click', () => {
    chipButtons.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    statusScope = btn.dataset.status;
    applyFilters();
  }));

  // Events: filters/search
  [reviewSearch, ratingFilter, verifiedFilter, photosFilter, fromDate, toDate, sortSelect].forEach(el => el.addEventListener('input', applyFilters));
  globalSearch.addEventListener('input', () => { reviewSearch.value = globalSearch.value; applyFilters(); });
  clearFilters.addEventListener('click', () => {
    reviewSearch.value=''; ratingFilter.value=''; verifiedFilter.value=''; photosFilter.value='';
    fromDate.value=''; toDate.value=''; sortSelect.value='date:desc'; applyFilters();
  });

  // Pagination
  pageSizeSel.addEventListener('change', renderTable);
  pagination.addEventListener('click', e => { const p=e.target.dataset.page; if (!p) return; page = Number(p); renderTable(); });

  // Row actions
  tbody.addEventListener('click', e => {
    const btn = e.target.closest('.icon-mini'); if (!btn) return;
    const id = Number(btn.dataset.id), action = btn.dataset.action;
    if (action === 'view') openDrawer(id);
    if (action === 'approve') updateStatus([id], 'Approved');
    if (action === 'reject') updateStatus([id], 'Rejected');
    if (action === 'flag') toggleFlag([id]);
    if (action === 'delete') deleteReviews([id]);
  });

  // Bulk actions
  selectAll.addEventListener('change', () => document.querySelectorAll('.row-check').forEach(cb => cb.checked = selectAll.checked));
  bulkApprove.addEventListener('click', () => updateStatus(selectedIds(), 'Approved'));
  bulkReject.addEventListener('click', () => updateStatus(selectedIds(), 'Rejected'));
  bulkDelete.addEventListener('click', () => deleteReviews(selectedIds()));
  function selectedIds(){ return [...document.querySelectorAll('.row-check:checked')].map(cb => Number(cb.dataset.id)); }

  function updateStatus(ids, status){
    if (!ids.length) return;
    reviews.forEach(r => { if (ids.includes(r.id)) { r.status = status; if (status!=='Rejected') r.flagged = false; } });
    persist(); applyFilters(); if (currentViewingId && ids.includes(currentViewingId)) openDrawer(currentViewingId);
  }
  function toggleFlag(ids){
    if (!ids.length) return;
    reviews.forEach(r => { if (ids.includes(r.id)) r.flagged = !r.flagged; });
    persist(); applyFilters(); if (currentViewingId && ids.includes(currentViewingId)) openDrawer(currentViewingId);
  }
  function deleteReviews(ids){
    if (!ids.length) return;
    if (!confirm(`Delete ${ids.length} review(s)? This cannot be undone.`)) return;
    reviews = reviews.filter(r => !ids.includes(r.id));
    persist(); applyFilters(); if (ids.includes(currentViewingId)) closeDrawer();
  }

  // Export
  exportBtn.addEventListener('click', () => {
    const rows = filtered.length ? filtered : reviews;
    const head = ['id','productId','productTitle','rating','headline','author','email','verified','helpful','status','flagged','date'];
    const lines = [head.join(',')];
    rows.forEach(r => lines.push([r.id, r.productId, `"${r.productTitle}"`, r.rating, `"${(r.headline||'').replace(/"/g,'""')}"`, `"${r.author}"`, `"${r.email}"`, r.verified, r.helpful, r.status, r.flagged, new Date(r.date).toISOString()].join(',')));
    const blob = new Blob([lines.join('\n')], {type:'text/csv;charset=utf-8;'});
    const url = URL.createObjectURL(blob);
    const a = Object.assign(document.createElement('a'), { href:url, download:'reviews-export.csv' });
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  });

  // Drawer rendering
  function openDrawer(id){
    const r = reviews.find(x=>x.id===id); if (!r) return;
    currentViewingId = id;
    drawerTitle.textContent = `Review #${r.id}`;
    drawerBody.innerHTML = `
      <div class="r-header">
        <div>
          <h3 class="r-title">${escapeHtml(r.productTitle)}</h3>
          <div class="r-meta">${fmtDate(r.date)} • <span class="stars">${starHtml(r.rating)}</span> ${r.verified ? ' • Verified Purchase' : ''}</div>
          <div class="r-meta">by <strong>${escapeHtml(r.author)}</strong> <span class="dim">(${escapeHtml(r.email)})</span></div>
          <div style="margin-top:.35rem;">${r.flagged ? '<span class="badge Flagged">Flagged</span> ' : ''}<span class="badge '+r.status+'">${r.status}</span></div>
        </div>
        <img src="${r.productImage}" alt="" style="width:64px;height:64px;border-radius:10px;object-fit:cover;background:#f6f6f9;"/>
      </div>

      ${r.headline ? `<div class="r-box"><div class="r-label">Title</div><div>${escapeHtml(r.headline)}</div></div>` : ''}
      <div class="r-box"><div class="r-label">Review</div><div>${escapeHtml(r.body)}</div></div>
      ${(r.pros||r.cons) ? `<div class="r-box"><div class="r-label">Pros & Cons</div><div>${escapeHtml(r.pros || '—')} / ${escapeHtml(r.cons || '—')}</div></div>` : ''}

      ${r.photos?.length ? `<div class="r-label">Photos</div><div class="r-photos">${r.photos.map(src=>`<img src="${src}" alt=""/>`).join('')}</div>` : ''}

      <div class="r-box response-box">
        <div class="r-label">Admin Response</div>
        <textarea id="adminResponse" rows="3" placeholder="Write a public response...">${escapeHtml(r.response || '')}</textarea>
      </div>

      <div class="r-box">
        <div class="r-label">Internal Notes</div>
        <textarea id="modNotes" rows="3" placeholder="Notes visible to your team...">${escapeHtml(r.notes || '')}</textarea>
      </div>
    `;
    drawer.setAttribute('aria-hidden','false');

    // Wire drawer buttons
    drawerApprove.onclick = () => updateStatus([r.id],'Approved');
    drawerReject.onclick = () => updateStatus([r.id],'Rejected');
    drawerFlag.onclick = () => toggleFlag([r.id]);
    drawerDelete.onclick = () => deleteReviews([r.id]);

    // Save response/notes debounced
    const responseEl = document.getElementById('adminResponse');
    const notesEl = document.getElementById('modNotes');
    let t1,t2;
    responseEl.oninput = () => { clearTimeout(t1); t1 = setTimeout(()=>{ r.response = responseEl.value; persist(); }, 300); };
    notesEl.oninput = () => { clearTimeout(t2); t2 = setTimeout(()=>{ r.notes = notesEl.value; persist(); }, 300); };
  }
  function closeDrawer(){ drawer.setAttribute('aria-hidden','true'); currentViewingId = null; }

  // Init
  (function init(){
    updateChipCounts();
    applyFilters();
  })();
});
