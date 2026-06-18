// Wishlist Page Logic (storage-first; backend can replace endpoints later)
document.addEventListener('DOMContentLoaded', () => {
  const grid = document.getElementById('wishlistGrid');
  const empty = document.getElementById('wishlistEmpty');
  const moveAllBtn = document.querySelector('.move-all-to-cart');
  const clearBtn = document.querySelector('.clear-wishlist');
  const cartCountEl = document.querySelector('.cart-count');

  // STORAGE KEYS
  const WL_KEY = 'nx_wishlist';
  const CART_KEY = 'nx_cart';

  // UTILITIES
  const loadJSON = (k, fallback) => {
    try { return JSON.parse(localStorage.getItem(k)) ?? fallback; }
    catch { return fallback; }
  };
  const saveJSON = (k, v) => localStorage.setItem(k, JSON.stringify(v));

  // In absence of backend, seed with sample products once (or leave empty)
  function seedIfEmpty() {
    const existing = loadJSON(WL_KEY, null);
    if (existing !== null) return;

    const sample = [
      {
        id: 1,
        name: 'MacBook Pro 14" M2',
        price: 1999.99,
        originalPrice: 2199.99,
        image: '../../images/products/macbook-pro.jpg',
        rating: 4.8,
        badge: 'New'
      },
      {
        id: 2,
        name: 'iPhone 14 Pro Max',
        price: 1099.99,
        originalPrice: 1299.99,
        image: '../../images/products/iphone-14.jpg',
        rating: 4.7,
        badge: 'Popular'
      },
      {
        id: 3,
        name: 'Sony WH-1000XM5',
        price: 349.99,
        originalPrice: 399.99,
        image: '../../images/products/sony-headphones.jpg',
        rating: 4.9,
        badge: 'Best Seller'
      }
    ];
    saveJSON(WL_KEY, sample);
  }

  // RENDER
  function render() {
    const items = loadJSON(WL_KEY, []);
    grid.innerHTML = '';

    if (!items.length) {
      empty.hidden = false;
      return;
    }
    empty.hidden = true;

    items.forEach(p => {
      const card = document.createElement('article');
      card.className = 'wishlist-card fade-in';

      card.innerHTML = `
        ${p.badge ? `<span class="badge">${p.badge}</span>` : ''}
        <div class="thumb"><img src="${p.image}" alt="${p.name}"/></div>
        <div class="meta-row">
          <span class="title">${p.name}</span>
          <span class="rating" title="Rating">
            <i class="fas fa-star"></i> ${p.rating?.toFixed?.(1) ?? '—'}
          </span>
        </div>
        <div class="price">
          <span class="now">$${p.price.toFixed(2)}</span>
          ${p.originalPrice ? `<span class="was">$${p.originalPrice.toFixed(2)}</span>` : ''}
        </div>
        <div class="actions">
          <button class="to-cart" data-id="${p.id}">
            <i class="fas fa-cart-plus"></i> Move to Cart
          </button>
          <button class="remove" data-id="${p.id}" aria-label="Remove from wishlist">
            <i class="fas fa-trash"></i>
          </button>
        </div>
      `;

      grid.appendChild(card);
    });
  }

  // CART COUNT (header)
  function updateCartCount(delta = 0) {
    let count = parseInt(cartCountEl?.textContent || '0', 10) || 0;
    count += delta;
    if (cartCountEl) {
      cartCountEl.textContent = count;
      cartCountEl.classList.add('pulse');
      setTimeout(() => cartCountEl.classList.remove('pulse'), 500);
    }
  }

  // MOVE SINGLE ITEM
  function moveToCart(id) {
    const wl = loadJSON(WL_KEY, []);
    const cart = loadJSON(CART_KEY, []);

    const idx = wl.findIndex(i => String(i.id) === String(id));
    if (idx === -1) return;

    const [item] = wl.splice(idx, 1);
    cart.push({ ...item, qty: 1 }); // default qty 1; backend can override

    saveJSON(WL_KEY, wl);
    saveJSON(CART_KEY, cart);

    updateCartCount(1);
    render();
  }

  // REMOVE SINGLE
  function removeFromWishlist(id) {
    const wl = loadJSON(WL_KEY, []);
    const filtered = wl.filter(i => String(i.id) !== String(id));
    saveJSON(WL_KEY, filtered);
    render();
  }

  // MOVE ALL
  function moveAllToCart() {
    const wl = loadJSON(WL_KEY, []);
    if (!wl.length) return;

    const cart = loadJSON(CART_KEY, []);
    const moved = wl.map(i => ({ ...i, qty: 1 }));
    saveJSON(CART_KEY, cart.concat(moved));
    saveJSON(WL_KEY, []);

    updateCartCount(moved.length);
    render();
  }

  // CLEAR ALL
  function clearAll() {
    saveJSON(WL_KEY, []);
    render();
  }

  // EVENTS (delegate)
  grid.addEventListener('click', (e) => {
    const moveBtn = e.target.closest('.to-cart');
    const delBtn = e.target.closest('.remove');

    if (moveBtn) {
      moveToCart(moveBtn.dataset.id);
    } else if (delBtn) {
      removeFromWishlist(delBtn.dataset.id);
    }
  });

  moveAllBtn?.addEventListener('click', moveAllToCart);
  clearBtn?.addEventListener('click', clearAll);

  // INIT
  seedIfEmpty();
  render();
});
