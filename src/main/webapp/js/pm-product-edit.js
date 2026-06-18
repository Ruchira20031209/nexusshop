document.addEventListener('DOMContentLoaded', () => {


  // Data stores
  const PRODUCTS_KEY = 'nx_admin_products_v1';
  let products = loadProducts();

  function loadProducts(){ try { return JSON.parse(localStorage.getItem(PRODUCTS_KEY) || '[]'); } catch { return []; } }
  function saveProducts(){ localStorage.setItem(PRODUCTS_KEY, JSON.stringify(products)); }

  // Elements
  const pageTitle = document.getElementById('pageTitle');
  const crumbHere = document.getElementById('crumbHere');
  const editForm = document.getElementById('editForm');
  const titleInput = document.getElementById('titleInput');
  const skuInput = document.getElementById('skuInput');
  const categoryInput = document.getElementById('categoryInput');
  const priceInput = document.getElementById('priceInput');
  const statusInput = document.getElementById('statusInput');
  const stockInput = document.getElementById('stockInput');
  const createdInput = document.getElementById('createdInput');
  const descInput = document.getElementById('descInput');
  const imageInput = document.getElementById('imageInput');
  const gallery = document.getElementById('gallery');

  const duplicateBtn = document.getElementById('duplicateBtn');
  const archiveBtn = document.getElementById('archiveBtn');
  const deleteBtn = document.getElementById('deleteBtn');
  const previewBtn = document.getElementById('previewBtn');

  const metaId = document.getElementById('metaId');
  const metaSku = document.getElementById('metaSku');
  const metaStatus = document.getElementById('metaStatus');

  // Determine product by query ?id=...
  const params = new URLSearchParams(location.search);
  const idParam = params.get('id'); // id or 'new'
  let product = null;

  if (idParam && idParam !== 'new') {
    product = products.find(p => String(p.id) === idParam);
  }
  if (!product) {
    // Create mode
    pageTitle.textContent = 'Create Product';
    crumbHere.textContent = 'Create';
    product = {
      id: (products[products.length-1]?.id || 3000) + 1,
      title: '',
      sku: '',
      category: '',
      price: 0,
      stock: 0,
      status: 'Draft',
      created: new Date().toISOString(),
      description: '',
      images: []
    };
  }

  // Fill form
  titleInput.value = product.title || '';
  skuInput.value = product.sku || '';
  categoryInput.value = product.category || '';
  priceInput.value = product.price ?? 0;
  statusInput.value = product.status || 'Draft';
  stockInput.value = product.stock ?? 0;
  createdInput.value = new Date(product.created).toLocaleString();
  descInput.value = product.description || '';
  renderGallery();

  metaId.textContent = product.id;
  metaSku.textContent = product.sku || '—';
  metaStatus.textContent = product.status;

  // Stock quick adjust
  document.querySelectorAll('[data-stock]').forEach(btn => {
    btn.addEventListener('click', () => {
      const val = Number(btn.getAttribute('data-stock').replace('+',''));
      stockInput.value = Math.max(0, Number(stockInput.value || 0) + (btn.getAttribute('data-stock').includes('-') ? -Math.abs(val) : val));
    });
  });

  // Image upload preview
  imageInput.addEventListener('change', async (e) => {
    const files = [...e.target.files];
    for (const f of files) {
      const dataUrl = await fileToDataUrl(f);
      product.images.push(dataUrl);
    }
    renderGallery();
  });
  function fileToDataUrl(file){
    return new Promise((resolve,reject) => {
      const fr = new FileReader();
      fr.onload = () => resolve(fr.result);
      fr.onerror = reject; fr.readAsDataURL(file);
    });
  }
  function renderGallery(){
    gallery.innerHTML = (product.images || []).map((src, idx) => `
      <div class="tile">
        <img src="${src}" alt=""/>
        <button type="button" data-remove="${idx}" title="Remove"><i class="fa fa-xmark"></i></button>
      </div>
    `).join('');
    gallery.querySelectorAll('[data-remove]').forEach(b => b.addEventListener('click', () => {
      const i = Number(b.getAttribute('data-remove'));
      product.images.splice(i, 1); renderGallery();
    }));
  }

  // Form submit
  editForm.addEventListener('submit', e => {
    e.preventDefault();
    if (!titleInput.value.trim() || !skuInput.value.trim() || !categoryInput.value || !priceInput.value || !stockInput.value){
      return alert('Please fill all required fields.');
    }
    // Persist changes
    product.title = titleInput.value.trim();
    product.sku = skuInput.value.trim();
    product.category = categoryInput.value;
    product.price = Number(priceInput.value);
    product.status = statusInput.value;
    product.stock = Number(stockInput.value);
    product.description = descInput.value;

    const idx = products.findIndex(p => p.id === product.id);
    if (idx >= 0) products[idx] = product; else products.push(product);
    saveProducts();

    metaSku.textContent = product.sku;
    metaStatus.textContent = product.status;

    alert('Saved!');
    // On first save in create mode, switch to edit URL
    if (!idParam || idParam === 'new') {
      location.replace(`pm-product-edit.html?id=${product.id}`);
    }
  });

  // Quick actions
  duplicateBtn.addEventListener('click', () => {
    const copy = { ...product, id: (products[products.length-1]?.id || 3000) + 1, title: product.title + ' (Copy)', sku: product.sku + '-COPY', created:new Date().toISOString() };
    products.push(copy); saveProducts();
    location.href = `pm-product-edit.html?id=${copy.id}`;
  });
  archiveBtn.addEventListener('click', () => {
    product.status = 'Archived'; saveProducts(); statusInput.value = 'Archived'; metaStatus.textContent = 'Archived'; alert('Archived.');
  });
  deleteBtn.addEventListener('click', () => {
    if (!confirm('Delete this product? This cannot be undone.')) return;
    products = products.filter(p => p.id !== product.id); saveProducts(); alert('Deleted.'); location.href = 'pm-dashboard.html';
  });
  previewBtn.addEventListener('click', () => {
    // For now, jump to storefront; later you can open a product preview page
    window.open('products.html', '_blank');
  });
});
