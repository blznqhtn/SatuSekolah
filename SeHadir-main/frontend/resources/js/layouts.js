document.addEventListener('DOMContentLoaded', () => {
    
    if (localStorage.theme === "dark" || (!("theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
        document.documentElement.classList.add("dark");
    } else {
        document.documentElement.classList.remove("dark");
    }

    const toggleDarkMode = () => {
        if (document.documentElement.classList.contains("dark")) {
            document.documentElement.classList.remove("dark");
            localStorage.theme = "light";
        } else {
            document.documentElement.classList.add("dark");
            localStorage.theme = "dark";
        }
    };

    const darkModeBtn = document.getElementById('dark-mode-toggle');

    if (darkModeBtn) {
        darkModeBtn.addEventListener('click', toggleDarkMode);
    }

    function updateTime() {
        const now = new Date();
        const options = { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false };
        const timeElement = document.getElementById('current-time');
        let timeString = now.toLocaleTimeString('id-ID', options).replace(/\./g, ':');
        
        if (timeElement) {
            timeElement.textContent = timeString;
        }
    }

    updateTime();
    setInterval(updateTime, 1000);

    localStorage.removeItem("uid");
});