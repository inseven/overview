(() => {
    const scroll = document.querySelector('.showcase-scroll');
    const dotsContainer = document.querySelector('.showcase-dots');
    const items = document.querySelectorAll('.showcase-item');

    if (!scroll || !dotsContainer || items.length === 0) return;

    // Create dots
    items.forEach((_, i) => {
        const dot = document.createElement('div');
        dot.className = `showcase-dot ${i === 0 ? 'active' : ''}`;
        dot.addEventListener('click', () => {
            items[i].scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
        });
        dotsContainer.appendChild(dot);
    });

    const dots = dotsContainer.querySelectorAll('.showcase-dot');

    // Update active dot on scroll
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const index = Array.from(items).indexOf(entry.target);
                dots.forEach((d, i) => d.classList.toggle('active', i === index));
            }
        });
    }, { threshold: 0.5 });

    items.forEach(item => observer.observe(item));
})();