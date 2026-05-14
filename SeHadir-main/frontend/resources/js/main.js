AOS.init({
    once: true,
    duration: 800,
    easing: 'ease-out-cubic',
});

document.addEventListener("DOMContentLoaded", function () {
    showReviewsSkeleton();
    fetchReviews();

    document
    .getElementById("scroll-left")
    .addEventListener("click", function () {
        document.getElementById("scroll-wrapper").scrollBy({
            left: -300,
            behavior: "smooth",
        });
    });

    document
    .getElementById("scroll-right")
    .addEventListener("click", function () {
        document.getElementById("scroll-wrapper").scrollBy({
            left: 300,
            behavior: "smooth",
        });
    });

    document.querySelectorAll(".nav-btn").forEach(btn => {
        btn.addEventListener("click", function () {
            const page = this.getAttribute("data-page");
            window.location.hash = page;
        });
    });
});

window.addEventListener("hashchange", function () {
    hashToURL();
});

window.addEventListener("load", function () {
    hashToURL();
});

function hashToURL() {
    const hash = window.location.hash.replace("#", "");

    if (hash) {
        history.replaceState(null, null, "/");
    }
}

function showReviewsSkeleton() {
    const container = document.getElementById("reviews-container");
    
    const skeletonHTML = Array(4).fill(0).map(() => `
        <div class="bg-gray-800 border border-gray-700 rounded-lg shadow-lg flex flex-col w-80 min-w-[320px] animate-pulse">
            <div class="p-5">
                <div class="flex justify-between items-start">
                    <div class="flex flex-col">
                        <div class="flex items-center gap-3 mb-2">
                            <div class="w-10 h-10 rounded-full bg-gray-600"></div>
                            <div class="h-4 w-32 bg-gray-600 rounded"></div>
                        </div>
                        <div class="flex gap-1">
                            ${Array(5).fill(0).map(() => `<div class="w-4 h-4 bg-gray-600 rounded"></div>`).join('')}
                        </div>
                    </div>
                    <div class="w-6 h-6 bg-gray-600 rounded"></div>
                </div>
            
                <div class="mt-4 space-y-2">
                    <div class="h-3 bg-gray-600 rounded w-full"></div>
                    <div class="h-3 bg-gray-600 rounded w-5/6"></div>
                    <div class="h-3 bg-gray-600 rounded w-2/3"></div>
                </div>
            </div>
            
            <div class="mt-auto px-5 py-3 border-t border-gray-700">
                <div class="h-3 w-40 bg-gray-600 rounded"></div>
            </div>
        </div>
    `).join('');

    container.innerHTML = skeletonHTML;
}

function fetchReviews() {
    axios
    .get('/reviews')
    .then((response) => {
        const data = response.data;
        const container = document.getElementById("reviews-container");

        if (
            data.result &&
            Array.isArray(data.result.reviews) &&
            data.result.reviews.length > 0
        ) {
            container.innerHTML = data.result.reviews
                .slice(0, 8)
                .map(
                    (review, index) => `
                    <div class="bg-gray-800 border border-gray-700 rounded-lg shadow-lg flex flex-col w-80 min-w-[320px]" 
                        data-aos="fade-up" data-aos-duration="1000" data-aos-delay="${400 + index * 100}">
                        <!-- Header with profile, name, stars -->
                        <div class="p-5">
                            <div class="flex justify-between items-start">
                            <div class="flex flex-col">
                                <div class="flex items-center gap-3 mb-2">
                                <img src="${review.profile_photo_url}" 
                                    alt="${review.author_name}" 
                                    loading="lazy"
                                    class="w-10 h-10 rounded-full object-cover">
                                <h4 class="font-medium text-white">${review.author_name}</h4>
                                </div>
                                <div class="text-yellow-400 flex">
                                ${"★".repeat(review.rating)}${"☆".repeat(5 - review.rating)}
                                </div>
                            </div>
                            <span class="text-2xl font-bold text-white">G</span>
                            </div>
                        
                            <!-- Review Content -->
                            <div class="mt-4">
                            <p class="text-gray-300">
                                ${review.text || "-"}
                            </p>
                            </div>
                        </div>
                        
                        <!-- Footer -->
                        <div class="mt-auto px-5 py-3 border-t border-gray-700">
                            <p class="text-xs text-gray-500">
                            Diposting pada: ${new Date(review.time * 1000).toLocaleDateString("id-ID")}
                            </p>
                        </div>
                    </div>
                `,
                )
                .join("");
        } else {
            container.innerHTML = `
                    <div class="text-center py-10 text-gray-400 w-full">
                        Belum ada ulasan. Jadilah yang pertama memberikan ulasan di Google!
                    </div>`;
        }
    })
    .catch((err) => {
        document.getElementById("reviews-container").innerHTML = `
                <div class="text-center py-10 text-red-400 w-full">
                Gagal memuat ulasan. Silakan coba lagi nanti.
                </div>`;
        console.error("Error:", err);
    });
}

const mobileMenuButton = document.getElementById('mobile-menu-button');
const mobileMenu = document.getElementById('mobile-menu');

mobileMenuButton.addEventListener('click', () => {
    mobileMenu.classList.toggle('hidden');
});

function toggleFAQ(button) {
    const faqItem = button.parentNode;
    const answer = faqItem.querySelector('div');
    const icon = button.querySelector('i');
    
    answer.classList.toggle('hidden');
    icon.classList.toggle('rotate-180');
}

// Generate barcode lines
const barcodeContainer = document.getElementById('barcode-container');
if (barcodeContainer) {
    barcodeContainer.innerHTML = '';
    
    const lineCount = window.innerWidth < 640 ? 80 : (window.innerWidth < 1024 ? 100 : 170);
    
    for (let i = 0; i < lineCount; i++) {
        const line = document.createElement('div');
        line.className = 'barcode-line';
        
        const width = Math.random() > 0.7 ? 
            (Math.random() > 0.5 ? 3 : 2) : 1;
        
        line.style.width = `${width}px`;
        line.style.opacity = Math.random() > 0.2 ? 1 : 0;
        
        barcodeContainer.appendChild(line);
    }
}

// 3D Card Effect based on cursor position
const card = document.getElementById('card');
const cardContainer = document.getElementById('card-container');

if (card && cardContainer) {
    function handleCardTilt(e) {
        const rect = cardContainer.getBoundingClientRect();
        const x = e.clientX - rect.left; // x position within the element
        const y = e.clientY - rect.top; // y position within the element
        
        // Calculate the position relative to the center of the card
        const centerX = rect.width / 2;
        const centerY = rect.height / 2;
        
        // Calculate the quadrant of the cursor
        const isLeft = x < centerX;
        const isTop = y < centerY;
        
        let rotateY, rotateX;
        
        if (isLeft && isTop) {
            // Top-left quadrant: tilt toward bottom-right
            rotateY = 15; // Tilt right
            rotateX = -15; // Tilt down
        } else if (isLeft && !isTop) {
            // Bottom-left quadrant: tilt toward top-right
            rotateY = 15; // Tilt right
            rotateX = 15; // Tilt up
        } else if (!isLeft && isTop) {
            // Top-right quadrant: tilt toward bottom-left
            rotateY = -15; // Tilt left
            rotateX = -15; // Tilt down
        } else {
            // Bottom-right quadrant: tilt toward top-left
            rotateY = -15; // Tilt left
            rotateX = 15; // Tilt up
        }
        
        card.style.transform = `rotateY(${rotateY}deg) rotateX(${rotateX}deg)`;
        
        // Update shine effect based on cursor position
        const shine = card.querySelector('.card-shine');
        const hologram = card.querySelector('.hologram');
        
        if (shine && hologram) {
            shine.style.opacity = '0.2';
            hologram.style.opacity = '0.2';
            
            // Adjust the gradient angle based on cursor position
            const angle = Math.atan2(y - centerY, x - centerX) * (180 / Math.PI);
            shine.style.background = `linear-gradient(${angle + 90}deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.2) 50%, rgba(255, 255, 255, 0) 100%)`;
            hologram.style.background = `linear-gradient(${angle}deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.1) 50%, rgba(255, 255, 255, 0) 100%)`;
        }
    }
    
    // Reset card position when mouse leaves
    function resetCardPosition() {
        card.style.transform = 'rotateY(0deg) rotateX(0deg)';
        
        const shine = card.querySelector('.card-shine');
        const hologram = card.querySelector('.hologram');
        
        if (shine && hologram) {
            shine.style.opacity = '0';
            hologram.style.opacity = '0';
        }
    }
    
    cardContainer.addEventListener('mousemove', handleCardTilt);
    cardContainer.addEventListener('mouseleave', resetCardPosition);
    
    cardContainer.addEventListener('touchmove', function(e) {
        e.preventDefault();
        const touch = e.touches[0];
        const touchEvent = new MouseEvent('mousemove', {
            clientX: touch.clientX,
            clientY: touch.clientY
        });
        handleCardTilt(touchEvent);
    });
    
    cardContainer.addEventListener('touchend', resetCardPosition);
}

// Responsive adjustments
function handleResize() {
    // Regenerate barcode on resize for better responsiveness
    const barcodeContainer = document.getElementById('barcode-container');
    if (barcodeContainer) {
        barcodeContainer.innerHTML = '';
        const lineCount = window.innerWidth < 640 ? 80 : 
                 window.innerWidth < 768 ? 100 : 
                 window.innerWidth < 1024 ? 110 : 170;

        for (let i = 0; i < lineCount; i++) {
            const line = document.createElement('div');
            line.className = 'barcode-line';
            const width = Math.random() > 0.7 ? (Math.random() > 0.5 ? 3 : 2) : 1;
            line.style.width = `${width}px`;
            line.style.opacity = Math.random() > 0.2 ? 1 : 0;
            barcodeContainer.appendChild(line);
        }
    }
    
    if (window.innerWidth < 768) {
        AOS.init({
            disable: true
        });
    } else {
        AOS.init({
            once: true,
            duration: 800,
            easing: 'ease-out-cubic',
            disable: false
        });
    }
    
    // Adjust card display for mobile
    const cardSection = document.querySelector('.card-display-section');
    if (cardSection) {
        if (window.innerWidth < 768) {
            cardSection.classList.remove('max-md:hidden');
        }
    }
}

handleResize();
window.addEventListener('resize', handleResize);