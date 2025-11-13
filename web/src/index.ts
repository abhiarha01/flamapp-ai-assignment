const overlay = document.getElementById('overlay')! as HTMLDivElement;
const img = document.getElementById('frame')! as HTMLImageElement;

function updateOverlay() {
  // Static demo data; replace with real metrics if needed.
  overlay.textContent = `FPS: 30 | ${img.naturalWidth}x${img.naturalHeight}`;
}

img.addEventListener('load', updateOverlay);
updateOverlay();
