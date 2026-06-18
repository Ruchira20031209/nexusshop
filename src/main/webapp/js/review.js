document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const form = document.getElementById('reviewForm');
  const successEl = document.getElementById('reviewSuccess');
  const errorEl = document.getElementById('reviewError');
  const starWrap = document.getElementById('starRating');
  const ratingInput = document.getElementById('rating');
  const headline = document.getElementById('headline');
  const body = document.getElementById('body');
  const productName = document.getElementById('productName');
  const productThumb = document.getElementById('productThumb');
  const nickname = document.getElementById('nickname');
  const email = document.getElementById('email');
  const anonymous = document.getElementById('anonymous');
  const photos = document.getElementById('photos');
  const previewStrip = document.getElementById('previewStrip');
  const discardDraftBtn = document.getElementById('discardDraft');
  const localPreview = document.getElementById('localPreview');
  const localPreviewList = localPreview?.querySelector('.preview-list');

  // Constants (replace with real API later)
  const DRAFT_KEY = 'nx_review_draft';
  const SUBMITTED_KEY = 'nx_review_submitted';
  const MAX_FILES = 5;
  const MAX_BYTES = 3 * 1024 * 1024; // 3 MB

  // If navigated from a product page, allow ?productId= and ?name= and ?img=
  const params = new URLSearchParams(location.search);
  if (params.get('name')) productName.value = decodeURIComponent(params.get('name'));
  if (params.get('img')) productThumb.src = decodeURIComponent(params.get('img'));

  // --- Star rating interactions
  const starBtns = [...starWrap.querySelectorAll('.star')];
  function paintStars(value) {
    starBtns.forEach((btn, i) => {
      btn.classList.toggle('active', i < value);
      btn.querySelector('i').className = i < value ? 'fa-solid fa-star' : 'fa-regular fa-star';
    });
  }
  starWrap.addEventListener('mouseover', e => {
    const btn = e.target.closest('.star');
    if (!btn) return;
    const v = Number(btn.dataset.value);
    starBtns.forEach((b, i) => b.classList.toggle('hover', i < v));
  });
  starWrap.addEventListener('mouseleave', () => starBtns.forEach(b => b.classList.remove('hover')));
  starWrap.addEventListener('click', e => {
    const btn = e.target.closest('.star');
    if (!btn) return;
    const v = Number(btn.dataset.value);
    ratingInput.value = v;
    paintStars(v);
  });

  // --- Character counters
  function bindCounter(input, max, el) {
    const update = () => { el.textContent = `${input.value.length}/${max}`; };
    input.addEventListener('input', update); update();
  }
  bindCounter(headline, 100, document.querySelector('.char[data-for="headline"]'));
  bindCounter(body, 2000, document.querySelector('.char[data-for="body"]'));

  // --- Image previews (client-side only; not uploaded yet)
  let filesState = [];
  photos.addEventListener('change', () => {
    const list = [...photos.files];
    const combined = [...filesState, ...list].slice(0, MAX_FILES);
    // validate size/type
    const valid = [];
    for (const f of combined) {
      if (!f.type.startsWith('image/')) continue;
      if (f.size > MAX_BYTES) continue;
      // de-dupe by name+size
      if (valid.some(v => v.name === f.name && v.size === f.size)) continue;
      valid.push(f);
    }
    filesState = valid;
    renderPreviews();
  });

  function renderPreviews() {
    previewStrip.innerHTML = '';
    filesState.forEach((f, idx) => {
      const url = URL.createObjectURL(f);
      const box = document.createElement('div');
      box.className = 'preview-thumb';
      box.innerHTML = `
        <img src="${url}" alt="${f.name}"/>
        <button type="button" data-idx="${idx}" aria-label="Remove image"><i class="fa fa-times"></i></button>
      `;
      previewStrip.appendChild(box);
    });
  }
  previewStrip.addEventListener('click', e => {
    const btn = e.target.closest('button[data-idx]');
    if (!btn) return;
    filesState.splice(Number(btn.dataset.idx), 1);
    renderPreviews();
  });

  // --- Draft autosave
  const draftFields = ['productName','headline','body','pros','cons','nickname','email','anonymous','rating'];
  function saveDraft() {
    const payload = {};
    draftFields.forEach(id => {
      const el = document.getElementById(id);
      payload[id] = el?.type === 'checkbox' ? el.checked : el?.value ?? '';
    });
    localStorage.setItem(DRAFT_KEY, JSON.stringify(payload));
  }
  function loadDraft() {
    const raw = localStorage.getItem(DRAFT_KEY);
    if (!raw) return;
    try {
      const d = JSON.parse(raw);
      draftFields.forEach(id => {
        const el = document.getElementById(id);
        if (!el) return;
        if (el.type === 'checkbox') el.checked = !!d[id];
        else if (d[id]) el.value = d[id];
      });
      if (d.rating) paintStars(Number(d.rating));
    } catch {}
  }
  form.addEventListener('input', () => {
    // throttle lightly
    if (saveDraft._t) clearTimeout(saveDraft._t);
    saveDraft._t = setTimeout(saveDraft, 250);
  });
  loadDraft();

  // Discard draft
  discardDraftBtn.addEventListener('click', () => {
    localStorage.removeItem(DRAFT_KEY);
    form.reset();
    filesState = [];
    renderPreviews();
    paintStars(0);
  });

  // --- Helpers
  function showError(msg) {
    errorEl.hidden = false;
    errorEl.querySelector('span').textContent = msg;
    successEl.hidden = true;
  }
  function showSuccess() {
    successEl.hidden = false;
    errorEl.hidden = true;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
  function validate() {
    const required = [
      [productName, 'Product name is required'],
      [ratingInput, 'Please select a star rating'],
      [headline, 'Please add a review title'],
      [body, 'Please write your review'],
      [nickname, 'Please enter a display name'],
      [email, 'Please provide a valid email'],
      [document.getElementById('consent'), 'Please confirm the consent checkbox']
    ];
    for (const [el, msg] of required) {
      if (!el) continue;
      const ok = el.type === 'checkbox' ? el.checked : !!String(el.value).trim();
      if (!ok) { el.focus(); showError(msg); return false; }
      if (el === email && !/^\S+@\S+\.\S+$/.test(el.value)) { el.focus(); showError('Email format looks invalid'); return false; }
      if (el === ratingInput && (el.value < 1 || el.value > 5)) { showError('Rating must be between 1 and 5'); return false; }
    }
    return true;
  }

  // --- Submit handler (simulate API)
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!validate()) return;

    // Create payload (swap for real FormData/API when backend is ready)
    const payload = {
      productName: productName.value.trim(),
      rating: Number(ratingInput.value),
      headline: headline.value.trim(),
      body: body.value.trim(),
      pros: document.getElementById('pros').value.trim(),
      cons: document.getElementById('cons').value.trim(),
      nickname: nickname.value.trim(),
      email: email.value.trim(),
      anonymous: !!anonymous.checked,
      createdAt: new Date().toISOString(),
      // NOTE: files are not persisted in localStorage; backend should handle upload and return URLs.
      photos: filesState.map(f => ({ name: f.name, size: f.size, type: f.type }))
    };

    // Prevent duplicate immediate resubmits (simple hash)
    const sig = JSON.stringify([payload.productName, payload.rating, payload.headline, payload.nickname, payload.email]);
    const submitted = JSON.parse(localStorage.getItem(SUBMITTED_KEY) || '[]');
    if (submitted.includes(sig)) {
      showError('Looks like you already submitted this review recently.');
      return;
    }

    // Simulate success
    submitted.push(sig);
    localStorage.setItem(SUBMITTED_KEY, JSON.stringify(submitted));

    // Persist locally for preview
    const localList = JSON.parse(localStorage.getItem('nx_review_local') || '[]');
    localList.unshift(payload);
    localStorage.setItem('nx_review_local', JSON.stringify(localList));

    // Clean up
    localStorage.removeItem(DRAFT_KEY);
    form.reset();
    filesState = [];
    renderPreviews();
    paintStars(0);
    showSuccess();
    renderLocalPreview();
  });

  // Local preview panel (just for dev/demo)
  function renderLocalPreview() {
    const list = JSON.parse(localStorage.getItem('nx_review_local') || '[]');
    if (!list.length) { localPreview.hidden = true; return; }
    localPreview.hidden = false;
    localPreviewList.innerHTML = '';
    list.slice(0, 5).forEach(it => {
      const row = document.createElement('div');
      row.className = 'preview-item';
      row.innerHTML = `
        <div class="meta">
          <strong>${escapeHtml(it.headline)}</strong>
          <span style="margin-left:.5rem;color:#777;">${'★'.repeat(it.rating)}${'☆'.repeat(5 - it.rating)}</span>
        </div>
        <div class="tiny">${new Date(it.createdAt).toLocaleString()}</div>
        <div>${escapeHtml(it.body)}</div>
        <div class="tiny" style="color:#777;margin-top:.25rem;">by ${it.anonymous ? 'Anonymous' : escapeHtml(it.nickname)}</div>
      `;
      localPreviewList.appendChild(row);
    });
  }
  renderLocalPreview();

  // Escape helper
  function escapeHtml(s='') {
    return s.replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  }
});
