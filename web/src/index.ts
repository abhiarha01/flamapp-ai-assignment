const overlay = document.getElementById('overlay') as HTMLDivElement;
const img = document.getElementById('frame') as HTMLImageElement;

function updateOverlay() {
    const w = img.naturalWidth;
    const h = img.naturalHeight;
    overlay.textContent = `FPS: 30 | ${w}x${h}`;
}

// FORCE image reload so 'load' event will ALWAYS fire
img.src = img.src + '?v=' + Date.now();

img.addEventListener('load', updateOverlay);

// in case browser loads instantly
setTimeout(updateOverlay, 300);
