<section id="reviews" class="py-16 md:py-20 bg-gray-800 relative overflow-hidden">
    <div class="absolute inset-0 bg-linear-to-b from-gray-800 via-gray-900 to-gray-900"></div>
    <div class="container mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="text-center max-w-3xl mx-auto mb-10" data-aos="fade-up" data-aos-duration="1000">
            <h2 class="text-2xl md:text-3xl lg:text-4xl font-bold mb-3 md:mb-4 text-white mt-12">Ulasan Pelanggan</h2>
            <p class="text-gray-400 text-base md:text-lg">
                Lihat apa kata pelanggan kami tentang raadeveloperz
            </p>
        </div>

        <!-- Google Rating Summary -->
        <div class="flex flex-col items-center justify-center mb-10" data-aos="fade-up" data-aos-duration="1000"
            data-aos-delay="200">
            <div class="flex items-center mb-4">
                <img src="https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png"
                    loading="lazy" alt="Google" class="h-12 mt-3 mb-2">
            </div>

            <button
                class="bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-6 rounded-md flex items-center transition-all duration-300"
                onclick="window.open('https://g.page/r/CZp_ANlt6d-oEBM/review', '_blank')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
                Tulis Review
            </button>
        </div>

        <!-- Reviews Header with Navigation -->
        <div class="flex justify-between items-center mb-6" data-aos="fade-up" data-aos-duration="1000"
            data-aos-delay="300">
            <h4 class="text-lg font-medium text-white">Google Reviews</h4>
            <div class="flex gap-2">
                <button id="scroll-left"
                    class="bg-gray-800 hover:bg-gray-700 text-white rounded-full p-2 transition-all duration-300">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                </button>
                <button id="scroll-right"
                    class="bg-gray-800 hover:bg-gray-700 text-white rounded-full p-2 transition-all duration-300">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                    </svg>
                </button>
            </div>
        </div>

        <!-- Scrollable Container -->
        <div class="overflow-x-auto pb-4 hide-scrollbar" data-aos="fade-up" data-aos-duration="1000"
            data-aos-delay="400" id="scroll-wrapper">
            <div class="flex gap-5 min-w-max" id="reviews-container">
                <!-- Reviews will be loaded here -->
            </div>
        </div>
    </div>
</section>
