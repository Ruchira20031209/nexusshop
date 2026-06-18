document.addEventListener('DOMContentLoaded', () => {
  // Shell controls
  const sidebar = document.getElementById('sidebar');
  document.querySelector('.sidebar-toggle')?.addEventListener('click', () => sidebar.classList.toggle('open'));
  const themeToggles = [document.getElementById('themeToggle'), document.getElementById('themeToggle2')].filter(Boolean);
  themeToggles.forEach(btn => btn.addEventListener('click', () => {
    document.documentElement.classList.toggle('dark');
    localStorage.setItem('nx_theme', document.documentElement.classList.contains('dark') ? 'dark' : 'light');
  }));
  if (localStorage.getItem('nx_theme') === 'dark') document.documentElement.classList.add('dark');

  // Elements
  const globalSearch = document.getElementById('globalSearch');
  const productSearch = document.getElementById('productSearch');
  const categoryFilter = document.getElementById('categoryFilter');
  const statusFilter = document.getElementById('statusFilter');
  const stockFilter = document.getElementById('stockFilter');
  const sortSelect = document.getElementById('sortSelect');
  const pageSizeSel = document.getElementById('pageSize');
  const resultMeta = document.getElementById('resultMeta');

  const tbody = document.getElementById('productsTbody');
  const pagination = document.getElementById('pagination');
  const selectAll = document.getElementById('selectAll');
  const bulkActivate = document.getElementById('bulkActivate');
  const bulkArchive = document.getElementById('bulkArchive');
  const bulkDelete = document.getElementById('bulkDelete');
  const exportBtn = document.getElementById('exportBtn');
  const addProductBtn = document.getElementById('addProductBtn');

  // Modal + form
  const modal = document.getElementById('productModal');
  const productForm = document.getElementById('productForm');
  const productId = document.getElementById('productId');
  const title = document.getElementById('title');
  const sku = document.getElementById('sku');
  const category = document.getElementById('category');
  const status = document.getElementById('status');
  const visibility = document.getElementById('visibility');
  const price = document.getElementById('price');
  const compareAt = document.getElementById('compareAt');
  const cost = document.getElementById('cost');
  const stock = document.getElementById('stock');
  const barcode = document.getElementById('barcode');
  const tags = document.getElementById('tags');
  const description = document.getElementById('description');
  const variantsWrap = document.getElementById('variantsWrap');
  const addVariant = document.getElementById('addVariant');
  const images = document.getElementById('images');
  const imageStrip = document.getElementById('imageStrip');

  // State
  const KEY = 'nx_admin_products_v1';
  let products = seedIfEmpty(load());
  let filtered = [];
  let page = 1;
  const MAX_IMG = 6;
  const MAX_BYTES = 3 * 1024 * 1024;

  // Storage
  function load(){ try { return JSON.parse(localStorage.getItem(KEY) || '[]'); } catch { return []; } }
  function persist(){ localStorage.setItem(KEY, JSON.stringify(products)); }
  function seedIfEmpty(list){
    if (list.length) return list;
    const cats = ['Phones','Laptops','Audio','Gaming','Accessories','Monitors'];
    const out = [];
    for (let i=1;i<=120;i++){
      const c = cats[i%cats.length];
      const st = ['Active','Draft','Archived'][i%3];
      out.push({
        id: 2000 + i,
        title: `${c} Sample ${i}`,
        sku: `SKU-${c.slice(0,3).toUpperCase()}-${1000+i}`,
        category: c,
        price: +(Math.random()*500 + 20).toFixed(2),
        compareAt: Math.random()>0.6 ? +(Math.random()*700 + 40).toFixed(2) : 0,
        cost: +(Math.random()*200 + 10).toFixed(2),
        stock: Math.floor(Math.random()*80),
        status: st,
        created: new Date(Date.now() - Math.random()*360*24*3600*1000).toISOString(),
        barcode: '',
        visibility: 'Public',
        tags: ['demo','sample'],
        description: 'Lorem ipsum dolor sit amet, product description.',
        variants: [],
        images: [] // URLs or base64 strings (stub)
      });
    }
    localStorage.setItem(KEY, JSON.stringify(out));
    return out;
  }

  // Helpers
  const fmt = new Intl.NumberFormat(undefined, { style: 'currency', currency: 'USD' });
  const escapeHtml = s => String(s||'').replace(/[&<>"']/g, c=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]));
  function fmtDate(iso){ const d=new Date(iso); return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'})}`; }
  function sortBy(arr, key, dir='asc'){ const m = dir==='asc'?1:-1; return [...arr].sort((a,b)=> (a[key]>b[key]?1:a[key]<b[key]?-1:0)*m); }
  function chunk(arr, size, p){ const s=(p-1)*size; return arr.slice(s, s+size); }

  // Filtering
  function applyFilters(){
    const term = (productSearch.value || globalSearch.value || '').toLowerCase().trim();
    const cat = categoryFilter.value;
    const st = statusFilter.value;
    const inv = stockFilter.value;

    filtered = products.filter(p => {
      const termHit = !term || [p.id, p.title, p.sku, p.category].join(' ').toLowerCase().includes(term);
      const catHit = !cat || p.category === cat;
      const stHit = !st || p.status === st;
      const invHit = !inv ||
        (inv==='in' && p.stock > 5) ||
        (inv==='low' && p.stock > 0 && p.stock <= 5) ||
        (inv==='out' && p.stock === 0);
      return termHit && catHit && stHit && invHit;
    });

    const [key, dir] = sortSelect.value.split(':');
    filtered = sortBy(filtered, key, dir);
    page = 1;
    renderTable();
  }

  // Table
  function rowHtml(p){
    const badge = `<span class="badge ${p.status}">${p.status}</span>`;
    return `
      <tr>
        <td><input type="checkbox" class="row-check" data-id="${p.id}"/></td>
        <td>#${p.id}</td>
        <td>
          <div style="display:flex;align-items:center;gap:.6rem;">
            ${thumb(p)} <div>
              <div style="font-weight:700">${escapeHtml(p.title)}</div>
              <div style="color:#6b7280;font-size:.85rem;">${escapeHtml(p.category)}</div>
            </div>
          </div>
        </td>
        <td>${escapeHtml(p.sku)}</td>
        <td>${escapeHtml(p.category)}</td>
        <td>${fmt.format(p.price)}</td>
        <td>${p.stock}</td>
        <td>${badge}</td>
        <td>${fmtDate(p.created)}</td>
        <td class="row-actions">
          <button class="icon-mini" data-action="edit" data-id="${p.id}" title="Edit"><i class="fa fa-pen"></i></button>
          <button class="icon-mini" data-action="duplicate" data-id="${p.id}" title="Duplicate"><i class="fa fa-copy"></i></button>
          <button class="icon-mini" data-action="delete" data-id="${p.id}" title="Delete"><i class="fa fa-trash"></i></button>
        </td>
      </tr>
    `;
  }
  function thumb(p){
    const src = p.images?.[0] || 'images/products/placeholder.png';
    return `<img src="${src}" alt="" style="width:40px;height:40px;border-radius:8px;object-fit:cover;background:#f6f6f9;">`;
  }

  function renderTable(){
    const pageSize = Number(pageSizeSel.value);
    const total = filtered.length;
    const pages = Math.max(1, Math.ceil(total / pageSize));
    if (page > pages) page = pages;

    const rows = chunk(filtered, pageSize, page);
    tbody.innerHTML = rows.map(rowHtml).join('');
    renderPagination(pages);

    resultMeta.textContent = `${total.toLocaleString()} product${total===1?'':'s'}`;
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

  // Sorting via header
  document.querySelector('#productsTable thead').addEventListener('click', e => {
    const th = e.target.closest('th[data-sort]'); if (!th) return;
    const key = th.dataset.sort;
    let [curKey, curDir] = sortSelect.value.split(':');
    const dir = (curKey === key && curDir === 'asc') ? 'desc' : 'asc';
    sortSelect.value = `${key}:${dir}`;
    applyFilters();
  });

  // Events: filters/search/sort/paging
  [productSearch, categoryFilter, statusFilter, stockFilter, sortSelect].forEach(el => el.addEventListener('input', applyFilters));
  globalSearch.addEventListener('input', () => { productSearch.value = globalSearch.value; applyFilters(); });
  pageSizeSel.addEventListener('change', renderTable);
  pagination.addEventListener('click', e => { const p=e.target.dataset.page; if (!p) return; page = Number(p); renderTable(); });

  // Row actions
  tbody.addEventListener('click', e => {
    const btn = e.target.closest('.icon-mini'); if (!btn) return;
    const id = Number(btn.dataset.id);
    const action = btn.dataset.action;
    if (action === 'edit') openModal(id);
    if (action === 'duplicate') duplicateProduct(id);
    if (action === 'delete') deleteProducts([id]);
  });

  // Bulk actions
  selectAll.addEventListener('change', () => document.querySelectorAll('.row-check').forEach(cb => cb.checked = selectAll.checked));
  bulkActivate.addEventListener('click', () => bulkStatus('Active'));
  bulkArchive.addEventListener('click', () => bulkStatus('Archived'));
  bulkDelete.addEventListener('click', () => deleteProducts(selectedIds()));

  function selectedIds(){ return [...document.querySelectorAll('.row-check:checked')].map(cb => Number(cb.dataset.id)); }
  function bulkStatus(s){
    const ids = selectedIds(); if (!ids.length) return;
    products.forEach(p => { if (ids.includes(p.id)) p.status = s; });
    persist(); applyFilters();
  }
  function deleteProducts(ids){
    if (!ids.length) return;
    if (!confirm(`Delete ${ids.length} product(s)? This cannot be undone.`)) return;
    products = products.filter(p => !ids.includes(p.id));
    persist(); applyFilters();
  }
  function duplicateProduct(id){
    const p = products.find(x=>x.id===id); if (!p) return;
    const copy = JSON.parse(JSON.stringify(p));
    copy.id = (products[products.length-1]?.id || 2000) + 1;
    copy.title = p.title + ' (Copy)';
    copy.created = new Date().toISOString();
    products.push(copy);
    persist(); applyFilters();
  }

  // Export
  exportBtn.addEventListener('click', () => {
    const rows = filtered.length ? filtered : products;
    const head = ['id','title','sku','category','price','compareAt','cost','stock','status','created','visibility','barcode','tags'];
    const lines = [head.join(',')];
    rows.forEach(p => lines.push([p.id, `"${p.title}"`, `"${p.sku}"`, p.category, p.price, p.compareAt, p.cost, p.stock, p.status, p.created, p.visibility, `"${p.barcode||''}"`, `"${(p.tags||[]).join('|')}"`].join(',')));
    const blob = new Blob([lines.join('\n')], {type:'text/csv;charset=utf-8;'});
    const url = URL.createObjectURL(blob);
    const a = Object.assign(document.createElement('a'), { href:url, download:'products-export.csv' });
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  });

  // Modal open/close
  addProductBtn.addEventListener('click', () => openModal());
  modal.addEventListener('click', e => { if (e.target.hasAttribute('data-close')) closeModal(); });
  document.querySelectorAll('#productModal [data-close]').forEach(b => b.addEventListener('click', closeModal));
  function openModal(id){
    resetForm();
    const editing = !!id;
    document.getElementById('productModalTitle').textContent = editing ? 'Edit Product' : 'Add Product';
    productId.value = editing ? id : '';
    if (editing){
      const p = products.find(x=>x.id===id);
      title.value = p.title; sku.value = p.sku; category.value = p.category; status.value = p.status;
      visibility.value = p.visibility || 'Public'; price.value = p.price; compareAt.value = p.compareAt || '';
      cost.value = p.cost || ''; stock.value = p.stock; barcode.value = p.barcode || '';
      tags.value = (p.tags||[]).join(', '); description.value = p.description || '';
      (p.variants||[]).forEach(addVariantRowWithData);
      (p.images||[]).forEach(src => addImagePreview(src, true));
    } else {
      // one empty variant row as a hint
      addVariantRowWithData({ option:'', sku:'', price:'', stock:'' });
    }
    modal.setAttribute('aria-hidden','false');
  }
  function closeModal(){ modal.setAttribute('aria-hidden','true'); }

  // Form save
  productForm.addEventListener('submit', e => {
    e.preventDefault();
    if (!validate()) return;

    const data = collectFormData();
    if (productId.value){
      const id = Number(productId.value);
      const idx = products.findIndex(x=>x.id===id);
      products[idx] = { ...products[idx], ...data };
    } else {
      const id = (products[products.length-1]?.id || 2000) + 1;
      products.push({ id, created: new Date().toISOString(), ...data });
    }
    persist(); closeModal(); applyFilters();
  });

  function validate(){
    if (!title.value.trim()) return alert('Title is required'), false;
    if (!sku.value.trim()) return alert('SKU is required'), false;
    if (!category.value) return alert('Category is required'), false;
    if (!status.value) return alert('Status is required'), false;
    if (!price.value || Number(price.value) < 0) return alert('Price is required'), false;
    if (!stock.value || Number(stock.value) < 0) return alert('Stock is required'), false;
    return true;
  }

  function collectFormData(){
    const variantRows = [...variantsWrap.querySelectorAll('.variant-row')];
    const variants = variantRows.map(row => ({
      option: row.querySelector('[data-v="option"]').value.trim(),
      sku: row.querySelector('[data-v="sku"]').value.trim(),
      price: Number(row.querySelector('[data-v="price"]').value || 0),
      stock: Number(row.querySelector('[data-v="stock"]').value || 0)
    })).filter(v => v.option || v.sku);

    return {
      title: title.value.trim(),
      sku: sku.value.trim(),
      category: category.value,
      status: status.value,
      visibility: visibility.value,
      price: Number(price.value),
      compareAt: Number(compareAt.value || 0),
      cost: Number(cost.value || 0),
      stock: Number(stock.value),
      barcode: barcode.value.trim(),
      tags: tags.value.split(',').map(s=>s.trim()).filter(Boolean),
      description: description.value.trim(),
      variants,
      images: [...imageStrip.querySelectorAll('img')].map(img => img.src) // base64/data URLs as stub
    };
  }

  function resetForm(){
    productForm.reset();
    productId.value = '';
    variantsWrap.innerHTML = '';
    imageStrip.innerHTML = '';
    filesState = [];
  }

  // Variants
  addVariant.addEventListener('click', () => addVariantRowWithData({ option:'', sku:'', price:'', stock:'' }));
  function addVariantRowWithData(v){
    const row = document.createElement('div');
    row.className = 'variant-row';
    row.innerHTML = `
      <input type="text" placeholder="Option (e.g., 128GB / Blue)" data-v="option"/>
      <input type="text" placeholder="Variant SKU" data-v="sku"/>
      <input type="number" min="0" step="0.01" placeholder="Price" data-v="price"/>
      <input type="number" min="0" step="1" placeholder="Stock" data-v="stock"/>
      <button type="button" class="icon-mini" title="Remove"><i class="fa fa-times"></i></button>
    `;
    row.querySelector('[data-v="option"]').value = v.option || '';
    row.querySelector('[data-v="sku"]').value = v.sku || '';
    row.querySelector('[data-v="price"]').value = v.price ?? '';
    row.querySelector('[data-v="stock"]').value = v.stock ?? '';
    row.querySelector('.icon-mini').addEventListener('click', () => row.remove());
    variantsWrap.appendChild(row);
  }

  // Images (client-side previews only)
  let filesState = [];
  images.addEventListener('change', async () => {
    const list = [...images.files];
    const combined = [...filesState, ...list].slice(0, MAX_IMG);
    const valid = [];
    for (const f of combined){
      if (!f.type.startsWith('image/')) continue;
      if (f.size > MAX_BYTES) continue;
      if (valid.some(v => v.name===f.name && v.size===f.size)) continue;
      valid.push(f);
    }
    filesState = valid;
    renderPreviews();
  });
  function renderPreviews(){
    imageStrip.innerHTML = '';
    filesState.forEach(async (f, idx) => {
      const url = await fileToDataURL(f);
      addImagePreview(url, false, idx);
    });
  }
  function addImagePreview(url, persisted=false, idx=null){
    const box = document.createElement('div'); box.className = 'preview-thumb';
    box.innerHTML = `<img src="${url}" alt="product"/><button type="button" data-idx="${idx??''}"><i class="fa fa-times"></i></button>`;
    box.querySelector('button').addEventListener('click', () => {
      if (!persisted && box.dataset.added!=='persisted'){
        filesState.splice(Number(box.querySelector('button').dataset.idx), 1);
      }
      box.remove();
    });
    if (persisted) box.dataset.added = 'persisted';
    imageStrip.appendChild(box);
  }
  function fileToDataURL(file){
    return new Promise(res => { const r=new FileReader(); r.onload=e=>res(e.target.result); r.readAsDataURL(file); });
  }

  // Init
  function init(){
    [productSearch, categoryFilter, statusFilter, stockFilter, sortSelect].forEach(el => el.value = el.value); // no-op to ensure defaults
    applyFilters();
  }
  init();
});
