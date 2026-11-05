/**
 * Arthentic Interactive Phygital Verification Engine
 * Default Theme: LIGHT (with Theme Toggle support)
 */

document.addEventListener("DOMContentLoaded", () => {
  initThemeManager();
  initAmbientCanvas();
  initLottieAnimations();
  initHeroTelemetry();
  initSolutionTabs();
  initStatCounters();
  initInteractivePhygitalSim();
  initFaqAccordion();
  initAuthModals();
  initCertificateModal();
  initMobileMenu();
});

/* ==========================================================================
   1. THEME MANAGER (Default: LIGHT)
   ========================================================================== */
function initThemeManager() {
  const toggleBtn = document.getElementById("theme-toggle-btn");
  const storedTheme = localStorage.getItem("arthentic-theme") || "light";

  setTheme(storedTheme);

  if (toggleBtn) {
    toggleBtn.addEventListener("click", () => {
      const current = document.documentElement.getAttribute("data-theme") || "light";
      const next = current === "light" ? "dark" : "light";
      setTheme(next);
    });
  }

  function setTheme(t) {
    document.documentElement.setAttribute("data-theme", t);
    localStorage.setItem("arthentic-theme", t);
    updateThemeIcon(t);
  }

  function updateThemeIcon(t) {
    const icon = document.getElementById("theme-toggle-icon");
    if (!icon) return;
    if (t === "dark") {
      // Show sun icon
      icon.innerHTML = `<path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>`;
    } else {
      // Show moon icon
      icon.innerHTML = `<path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>`;
    }
  }
}

/* ==========================================================================
   2. AMBIENT DRIFTING PARTICLES CANVAS
   ========================================================================== */
function initAmbientCanvas() {
  const canvas = document.getElementById("ambient-canvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  let w = (canvas.width = window.innerWidth);
  let h = (canvas.height = window.innerHeight);

  window.addEventListener("resize", () => {
    w = canvas.width = window.innerWidth;
    h = canvas.height = window.innerHeight;
  });

  const particles = [];
  const count = Math.min(35, Math.floor(w / 35));

  for (let i = 0; i < count; i++) {
    particles.push({
      x: Math.random() * w,
      y: Math.random() * h,
      r: Math.random() * 1.5 + 0.5,
      vx: (Math.random() - 0.5) * 0.2,
      vy: -Math.random() * 0.3 - 0.1,
      alpha: Math.random() * 0.4 + 0.1,
    });
  }

  function draw() {
    ctx.clearRect(0, 0, w, h);
    ctx.fillStyle = "#E11D2E";

    for (let i = 0; i < particles.length; i++) {
      const p = particles[i];
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.globalAlpha = p.alpha;
      ctx.fill();

      p.x += p.vx;
      p.y += p.vy;

      if (p.y < 0) {
        p.y = h;
        p.x = Math.random() * w;
      }
      if (p.x < 0) p.x = w;
      if (p.x > w) p.x = 0;
    }

    ctx.globalAlpha = 1.0;
    requestAnimationFrame(draw);
  }

  draw();
}

/* ==========================================================================
   3. LOTTIE ANIMATIONS LOADER
   ========================================================================== */
let lottieHeroInstance = null;
let lottieNfcInstance = null;
let lottieAiInstance = null;
let lottieBlockchainInstance = null;
let lottieVerifiedInstance = null;

function initLottieAnimations() {
  if (typeof lottie === "undefined") return;

  const heroEl = document.getElementById("hero-lottie");
  if (heroEl) {
    lottieHeroInstance = lottie.loadAnimation({
      container: heroEl,
      renderer: "svg",
      loop: true,
      autoplay: true,
      path: "assets/lottie/hero-security.json",
    });
  }

  const nfcEl = document.getElementById("lottie-sol-nfc");
  if (nfcEl) {
    lottieNfcInstance = lottie.loadAnimation({
      container: nfcEl,
      renderer: "svg",
      loop: true,
      autoplay: true,
      path: "assets/lottie/nfc-handshake.json",
    });
  }

  const aiEl = document.getElementById("lottie-sol-ai");
  if (aiEl) {
    lottieAiInstance = lottie.loadAnimation({
      container: aiEl,
      renderer: "svg",
      loop: true,
      autoplay: false,
      path: "assets/lottie/ai-microscan.json",
    });
  }

  const bcEl = document.getElementById("lottie-sol-bc");
  if (bcEl) {
    lottieBlockchainInstance = lottie.loadAnimation({
      container: bcEl,
      renderer: "svg",
      loop: true,
      autoplay: false,
      path: "assets/lottie/blockchain-ledger.json",
    });
  }

  const badgeEl = document.getElementById("demo-lottie-badge");
  if (badgeEl) {
    lottieVerifiedInstance = lottie.loadAnimation({
      container: badgeEl,
      renderer: "svg",
      loop: true,
      autoplay: false,
      path: "assets/lottie/verified-badge.json",
    });
  }
}

/* ==========================================================================
   4. HERO VERIFICATION & WORLDWIDE ARTIST GLOBE ANIMATION (Loop & Interactive)
   ========================================================================== */

/**
 * High-performance 3D Holographic Globe Canvas Renderer
 * Illustrates the decentralized Arthentic protocol connecting artists worldwide.
 */
class HeroGlobeRenderer {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.animationFrameId = null;
    this.rotationAngle = 0.85; // Initial view focuses on Asia/Pacific & Europe/Africa sweep
    this.pitch = 0.22; // 12.6 degrees orbital tilt
    this.autoRotateSpeed = 0.0042;
    this.isDragging = false;
    this.lastMouseX = 0;
    this.lastMouseY = 0;
    this.dpr = Math.min(window.devicePixelRatio || 1, 2);

    // Key Global Artist Hubs
    this.hubs = [
      { name: "Jakarta", country: "ID", lat: -6.2088, lon: 106.8456, role: "Nusantara Studio", color: "#E11D2E", primary: true },
      { name: "Tokyo", country: "JP", lat: 35.6762, lon: 139.6503, role: "Ginza Phygital", color: "#10B981", primary: true },
      { name: "Paris", country: "FR", lat: 48.8566, lon: 2.3522, role: "Musée Provenance", color: "#E11D2E", primary: true },
      { name: "London", country: "GB", lat: 51.5074, lon: -0.1278, role: "Tate Curator", color: "#3B82F6", primary: false },
      { name: "New York", country: "US", lat: 40.7128, lon: -74.006, role: "Chelsea Atelier", color: "#F59E0B", primary: true },
      { name: "São Paulo", country: "BR", lat: -23.5505, lon: -46.6333, role: "Bienal Arts", color: "#10B981", primary: false },
      { name: "Berlin", country: "DE", lat: 52.52, lon: 13.405, role: "Kreuzberg Base", color: "#8B5CF6", primary: false },
      { name: "Sydney", country: "AU", lat: -33.8688, lon: 151.2093, role: "Pacific Heritage", color: "#06B6D4", primary: false },
      { name: "Cape Town", country: "ZA", lat: -33.9249, lon: 18.4241, role: "Zeitz Gallery", color: "#EC4899", primary: false },
      { name: "Florence", country: "IT", lat: 43.7696, lon: 11.2558, role: "Renaissance Vault", color: "#F97316", primary: false },
    ];

    // Cryptographic Interconnection Arcs
    this.arcs = [
      { from: "Jakarta", to: "Tokyo", speed: 0.0035, offset: 0.1 },
      { from: "Jakarta", to: "Paris", speed: 0.0028, offset: 0.35 },
      { from: "Paris", to: "London", speed: 0.0045, offset: 0.2 },
      { from: "London", to: "New York", speed: 0.0030, offset: 0.6 },
      { from: "New York", to: "São Paulo", speed: 0.0032, offset: 0.4 },
      { from: "Tokyo", to: "Sydney", speed: 0.0028, offset: 0.75 },
      { from: "Paris", to: "Berlin", speed: 0.0040, offset: 0.5 },
      { from: "Paris", to: "Cape Town", speed: 0.0025, offset: 0.15 },
    ];

    this.landPoints = this.generateLandmassPoints();
    this.initEvents();
    this.resize();
    this.start();
  }

  generateLandmassPoints() {
    const pts = [];
    const continents = [
      // Asia & SE Asia & Indonesia
      { minLat: -10, maxLat: 50, minLon: 70, maxLon: 145, count: 120 },
      // Europe
      { minLat: 36, maxLat: 64, minLon: -10, maxLon: 40, count: 80 },
      // Africa
      { minLat: -34, maxLat: 35, minLon: -17, maxLon: 50, count: 90 },
      // North America
      { minLat: 20, maxLat: 60, minLon: -125, maxLon: -65, count: 90 },
      // South America
      { minLat: -54, maxLat: 12, minLon: -80, maxLon: -35, count: 70 },
      // Oceania / Australia
      { minLat: -42, maxLat: -12, minLon: 114, maxLon: 154, count: 50 },
    ];

    continents.forEach((c) => {
      for (let i = 0; i < c.count; i++) {
        const lat = c.minLat + Math.random() * (c.maxLat - c.minLat);
        const lon = c.minLon + Math.random() * (c.maxLon - c.minLon);
        pts.push({ lat, lon });
      }
    });

    return pts;
  }

  initEvents() {
    window.addEventListener("resize", () => this.resize());

    // Mouse drag controls for interactive spinning
    this.canvas.addEventListener("mousedown", (e) => {
      this.isDragging = true;
      this.lastMouseX = e.clientX;
      this.lastMouseY = e.clientY;
    });

    window.addEventListener("mousemove", (e) => {
      if (!this.isDragging) return;
      const dx = e.clientX - this.lastMouseX;
      const dy = e.clientY - this.lastMouseY;
      this.rotationAngle += dx * 0.006;
      this.pitch = Math.max(-0.55, Math.min(0.55, this.pitch + dy * 0.004));
      this.lastMouseX = e.clientX;
      this.lastMouseY = e.clientY;
    });

    window.addEventListener("mouseup", () => {
      this.isDragging = false;
    });

    // Touch controls for mobile
    this.canvas.addEventListener("touchstart", (e) => {
      if (e.touches.length === 1) {
        this.isDragging = true;
        this.lastMouseX = e.touches[0].clientX;
        this.lastMouseY = e.touches[0].clientY;
      }
    }, { passive: true });

    window.addEventListener("touchmove", (e) => {
      if (!this.isDragging || e.touches.length !== 1) return;
      const dx = e.touches[0].clientX - this.lastMouseX;
      const dy = e.touches[0].clientY - this.lastMouseY;
      this.rotationAngle += dx * 0.006;
      this.pitch = Math.max(-0.55, Math.min(0.55, this.pitch + dy * 0.004));
      this.lastMouseX = e.touches[0].clientX;
      this.lastMouseY = e.touches[0].clientY;
    }, { passive: true });

    window.addEventListener("touchend", () => {
      this.isDragging = false;
    });
  }

  resize() {
    const rect = this.canvas.parentElement.getBoundingClientRect();
    this.width = rect.width || 600;
    this.height = rect.height || 265;
    this.canvas.width = this.width * this.dpr;
    this.canvas.height = this.height * this.dpr;
    this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);

    // Responsive globe center and radius
    if (this.width < 500) {
      // Mobile: Globe is placed slightly higher with smaller radius
      this.globeRadius = Math.min(this.width, this.height) * 0.32;
      this.cx = this.width * 0.5;
      this.cy = this.height * 0.36;
    } else {
      // Desktop: Globe placed on left side to balance with floating spec card on right
      this.globeRadius = Math.min(this.height * 0.42, 98);
      this.cx = Math.max(140, this.width * 0.34);
      this.cy = this.height * 0.52;
    }
  }

  // 3D Spherical Coordinate Projection with Euler Rotation
  project(lat, lon, extraRadius = 0) {
    const phi = (lat * Math.PI) / 180;
    const lambda = (lon * Math.PI) / 180;
    const r = this.globeRadius + extraRadius;

    // Unit sphere coordinates
    const x0 = r * Math.cos(phi) * Math.sin(lambda);
    const y0 = r * Math.sin(phi);
    const z0 = r * Math.cos(phi) * Math.cos(lambda);

    // Rotate Y axis (yaw / spin)
    const sinA = Math.sin(this.rotationAngle);
    const cosA = Math.cos(this.rotationAngle);
    const x1 = x0 * cosA + z0 * sinA;
    const y1 = y0;
    const z1 = -x0 * sinA + z0 * cosA;

    // Rotate X axis (pitch / tilt)
    const sinB = Math.sin(this.pitch);
    const cosB = Math.cos(this.pitch);
    const x2 = x1;
    const y2 = y1 * cosB - z1 * sinB;
    const z2 = y1 * sinB + z1 * cosB;

    return {
      x: this.cx + x2,
      y: this.cy - y2,
      z: z2,
      visible: z2 > -10,
      isFront: z2 > 0,
    };
  }

  draw() {
    const ctx = this.ctx;
    const now = performance.now();
    ctx.clearRect(0, 0, this.width, this.height);

    if (!this.isDragging) {
      this.rotationAngle += this.autoRotateSpeed;
    }

    const cx = this.cx;
    const cy = this.cy;
    const R = this.globeRadius;

    // 1. Atmosphere / Outer Rim Glow
    const glowGrad = ctx.createRadialGradient(cx, cy, R * 0.7, cx, cy, R * 1.35);
    glowGrad.addColorStop(0, "rgba(225, 29, 46, 0.12)");
    glowGrad.addColorStop(0.5, "rgba(225, 29, 46, 0.04)");
    glowGrad.addColorStop(1, "rgba(225, 29, 46, 0)");
    ctx.fillStyle = glowGrad;
    ctx.beginPath();
    ctx.arc(cx, cy, R * 1.35, 0, Math.PI * 2);
    ctx.fill();

    // 2. Dark Sphere Body Base
    const sphereGrad = ctx.createRadialGradient(cx - R * 0.35, cy - R * 0.35, R * 0.1, cx, cy, R);
    sphereGrad.addColorStop(0, "#191D28");
    sphereGrad.addColorStop(0.7, "#0D111A");
    sphereGrad.addColorStop(1, "#07090E");
    ctx.fillStyle = sphereGrad;
    ctx.beginPath();
    ctx.arc(cx, cy, R, 0, Math.PI * 2);
    ctx.fill();

    // Sphere Rim Stroke
    ctx.strokeStyle = "rgba(225, 29, 46, 0.38)";
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    ctx.arc(cx, cy, R, 0, Math.PI * 2);
    ctx.stroke();

    // Clip rendering inside the sphere for wireframe & landmass
    ctx.save();
    ctx.beginPath();
    ctx.arc(cx, cy, R, 0, Math.PI * 2);
    ctx.clip();

    // 3. Longitude Meridians
    for (let lon = -180; lon < 180; lon += 30) {
      ctx.beginPath();
      let first = true;
      for (let lat = -90; lat <= 90; lat += 5) {
        const p = this.project(lat, lon);
        if (p.isFront) {
          if (first) {
            ctx.moveTo(p.x, p.y);
            first = false;
          } else {
            ctx.lineTo(p.x, p.y);
          }
        } else {
          first = true;
        }
      }
      ctx.strokeStyle = "rgba(255, 255, 255, 0.07)";
      ctx.lineWidth = 0.75;
      ctx.stroke();
    }

    // 4. Latitude Parallels
    const latLines = [-60, -30, 0, 30, 60];
    latLines.forEach((lat) => {
      ctx.beginPath();
      let first = true;
      for (let lon = -180; lon <= 180; lon += 6) {
        const p = this.project(lat, lon);
        if (p.isFront) {
          if (first) {
            ctx.moveTo(p.x, p.y);
            first = false;
          } else {
            ctx.lineTo(p.x, p.y);
          }
        } else {
          first = true;
        }
      }
      if (lat === 0) {
        // Equator Highlight
        ctx.strokeStyle = "rgba(225, 29, 46, 0.35)";
        ctx.lineWidth = 1;
      } else {
        ctx.strokeStyle = "rgba(255, 255, 255, 0.06)";
        ctx.lineWidth = 0.75;
      }
      ctx.stroke();
    });

    // 5. Continental Landmass Dots
    this.landPoints.forEach((pt) => {
      const p = this.project(pt.lat, pt.lon);
      if (p.isFront) {
        const alpha = Math.max(0.15, (p.z / R) * 0.75);
        ctx.fillStyle = `rgba(180, 200, 225, ${alpha.toFixed(2)})`;
        ctx.beginPath();
        ctx.arc(p.x, p.y, 1.1, 0, Math.PI * 2);
        ctx.fill();
      }
    });

    ctx.restore(); // End clipping

    // Map city names to projection
    const hubMap = {};
    this.hubs.forEach((h) => {
      hubMap[h.name] = { ...h, proj: this.project(h.lat, h.lon) };
    });

    // 6. 3D Cryptographic Connection Arcs
    this.arcs.forEach((arc) => {
      const hFrom = hubMap[arc.from];
      const hTo = hubMap[arc.to];
      if (!hFrom || !hTo) return;

      const pA = hFrom.proj;
      const pB = hTo.proj;

      // Draw arc if at least one node is partially visible
      if (pA.visible || pB.visible) {
        const steps = 24;
        ctx.beginPath();
        let first = true;
        for (let i = 0; i <= steps; i++) {
          const t = i / steps;
          const lat = hFrom.lat + (hTo.lat - hFrom.lat) * t;
          const lon = hFrom.lon + (hTo.lon - hFrom.lon) * t;
          // Arc height reaches its peak in the center
          const arcElevation = Math.sin(Math.PI * t) * (R * 0.28);
          const p = this.project(lat, lon, arcElevation);

          if (first) {
            ctx.moveTo(p.x, p.y);
            first = false;
          } else {
            ctx.lineTo(p.x, p.y);
          }
        }
        ctx.strokeStyle = "rgba(225, 29, 46, 0.32)";
        ctx.lineWidth = 1.2;
        ctx.setLineDash([3, 4]);
        ctx.stroke();
        ctx.setLineDash([]);

        // Animated traveling attestation photon
        const tPhoton = ((now * arc.speed + arc.offset) % 1);
        const latP = hFrom.lat + (hTo.lat - hFrom.lat) * tPhoton;
        const lonP = hFrom.lon + (hTo.lon - hFrom.lon) * tPhoton;
        const elevP = Math.sin(Math.PI * tPhoton) * (R * 0.28);
        const photon = this.project(latP, lonP, elevP);

        if (photon.isFront) {
          ctx.fillStyle = "#FFFFFF";
          ctx.shadowColor = "#E11D2E";
          ctx.shadowBlur = 10;
          ctx.beginPath();
          ctx.arc(photon.x, photon.y, 2.2, 0, Math.PI * 2);
          ctx.fill();
          ctx.shadowBlur = 0;
        }
      }
    });

    // 7. Global Artist Hub Nodes & Pulsing Beacons
    this.hubs.forEach((hub) => {
      const p = hubMap[hub.name].proj;
      if (!p.isFront) return;

      const depthRatio = Math.max(0.2, p.z / R);
      const pulseT = (now * 0.003) % 1;
      const rippleR = 3 + pulseT * 12;

      // Radar Ripple
      ctx.strokeStyle = hub.color;
      ctx.lineWidth = 1;
      ctx.globalAlpha = (1 - pulseT) * depthRatio * 0.85;
      ctx.beginPath();
      ctx.arc(p.x, p.y, rippleR, 0, Math.PI * 2);
      ctx.stroke();
      ctx.globalAlpha = 1;

      // Core Node Dot
      ctx.fillStyle = hub.color;
      ctx.shadowColor = hub.color;
      ctx.shadowBlur = 8;
      ctx.beginPath();
      ctx.arc(p.x, p.y, hub.primary ? 3.5 : 2.6, 0, Math.PI * 2);
      ctx.fill();
      ctx.shadowBlur = 0;

      // Hub Label Typography (rendered when facing viewer)
      if (p.z > R * 0.15) {
        ctx.font = "600 9px 'JetBrains Mono', monospace";
        ctx.fillStyle = "#FFFFFF";
        ctx.fillText(hub.name, p.x + 8, p.y + 3);

        if (hub.primary && p.z > R * 0.35) {
          ctx.font = "500 7.5px 'Plus Jakarta Sans', sans-serif";
          ctx.fillStyle = "rgba(225, 29, 46, 0.9)";
          ctx.fillText(`● ${hub.role}`, p.x + 8, p.y + 13);
        }
      }
    });

    this.animationFrameId = requestAnimationFrame(() => this.draw());
  }

  start() {
    if (!this.animationFrameId) {
      this.draw();
    }
  }

  stop() {
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = null;
    }
  }
}

/**
 * Unified Hero Console Orchestrator
 * Coordinates Phase 1 (Physical Artwork Verification) and Phase 2 (Global Artist Network Globe)
 */
function initHeroTelemetry() {
  const terminal = document.getElementById("hero-telemetry");
  const verdict = document.getElementById("hero-verdict");
  const verdictText = document.getElementById("hero-verdict-text");
  const stageArtwork = document.getElementById("hero-stage-artwork");
  const stageGlobe = document.getElementById("hero-stage-globe");
  const tabArtwork = document.getElementById("tab-phase-artwork");
  const tabGlobe = document.getElementById("tab-phase-globe");
  const specContentArtwork = document.getElementById("spec-content-artwork");
  const specContentGlobe = document.getElementById("spec-content-globe");
  const globeCanvas = document.getElementById("hero-globe-canvas");

  if (!terminal) return;

  // Initialize Canvas 3D Globe
  let globeInstance = null;
  if (globeCanvas) {
    globeInstance = new HeroGlobeRenderer(globeCanvas);
  }

  let currentPhase = "artwork"; // 'artwork' | 'globe'
  let isManualOverride = false;
  let overrideTimer = null;

  function switchPhase(newPhase, manual = false) {
    currentPhase = newPhase;

    if (newPhase === "artwork") {
      if (stageArtwork) stageArtwork.classList.add("active");
      if (stageGlobe) stageGlobe.classList.remove("active");
      if (tabArtwork) {
        tabArtwork.classList.add("active");
        tabArtwork.setAttribute("aria-selected", "true");
      }
      if (tabGlobe) {
        tabGlobe.classList.remove("active");
        tabGlobe.setAttribute("aria-selected", "false");
      }
      if (specContentArtwork) specContentArtwork.style.display = "block";
      if (specContentGlobe) specContentGlobe.style.display = "none";
    } else {
      if (stageArtwork) stageArtwork.classList.remove("active");
      if (stageGlobe) stageGlobe.classList.add("active");
      if (tabArtwork) {
        tabArtwork.classList.remove("active");
        tabArtwork.setAttribute("aria-selected", "false");
      }
      if (tabGlobe) {
        tabGlobe.classList.add("active");
        tabGlobe.setAttribute("aria-selected", "true");
      }
      if (specContentArtwork) specContentArtwork.style.display = "none";
      if (specContentGlobe) specContentGlobe.style.display = "block";
    }

    if (manual) {
      isManualOverride = true;
      clearTimeout(overrideTimer);
      // Resume autonomous cycle after 14 seconds of user inactivity
      overrideTimer = setTimeout(() => {
        isManualOverride = false;
      }, 14000);
    }
  }

  // Bind Header Phase Buttons
  if (tabArtwork) {
    tabArtwork.addEventListener("click", () => switchPhase("artwork", true));
  }
  if (tabGlobe) {
    tabGlobe.addEventListener("click", () => switchPhase("globe", true));
  }

  // Bilingual Telemetry Sequences
  function getSequence() {
    const isEn = typeof ArthenticI18n !== "undefined" && ArthenticI18n.getCurrentLang() === "en";

    if (isEn) {
      return [
        // --- PHASE 1: Physical Fine Art Intake & On-Chain Authentication ---
        { phase: "artwork", text: "> initializing node: chain_id 8453 (Base L2 Sepolia)", delay: 900 },
        { phase: "artwork", text: "> tapping SUN crypto-chip… AES-128 handshake OK (#8421)", delay: 1500 },
        { phase: "artwork", text: "> tamper-evident substrate: INTACT (loop antenna intact)", delay: 1400 },
        { phase: "artwork", text: "> AI optical fingerprint: canvas weave, micro-cracks & impasto…", delay: 2000 },
        { phase: "artwork", text: "> cosine similarity: 94.8% (threshold ≥ 88.0%) PASS", delay: 1500 },
        { phase: "artwork", text: "> EIP-712 attestation signed via Protocol HSM Node ✓", delay: 1300 },
        {
          phase: "artwork",
          text: "> STATUS: MASTERPIECE ON-CHAIN VERIFIED AUTHENTIC",
          delay: 2800,
          showVerdict: true,
          verdictMsg: "VERIFIED · 94.8% ≥ 88% PASS"
        },

        // --- PHASE 2: Global Protocol Synchronization (Artists Worldwide) ---
        {
          phase: "globe",
          text: "> BROADCASTING PROVENANCE TO WORLDWIDE ARTIST NETWORK 🌐…",
          delay: 1600,
          switchPhase: true
        },
        { phase: "globe", text: "> node [Jakarta 🇮🇩]: local artist genesis registered on Base L2", delay: 1600 },
        { phase: "globe", text: "> node [Paris 🇫🇷]: museum & gallery curator syncs EIP-712 certificate", delay: 1600 },
        { phase: "globe", text: "> node [Tokyo 🇯🇵]: cross-continent consensus confirmed in 1.4s", delay: 1600 },
        { phase: "globe", text: "> node [New York 🇺🇸]: smart escrow ready for secure global custody", delay: 1600 },
        {
          phase: "globe",
          text: "> ARTHENTIC MISSION: INITIATIVE FOR ALL ARTISTS IN THE WORLD 🌍",
          delay: 3800,
          showVerdict: true,
          verdictMsg: "GLOBAL ARTIST NETWORK · 7 CONTINENTS CONNECTED"
        },
      ];
    }

    // Default: Indonesian (ID)
    return [
      // --- FASE 1: Verifikasi Karya Fisik Seni di Node Lokal ---
      { phase: "artwork", text: "> inisialisasi node arthentic: chain_id 8453 (Base L2)", delay: 900 },
      { phase: "artwork", text: "> tap SUN token… enkripsi AES-128 OK (Nonce #8421)", delay: 1500 },
      { phase: "artwork", text: "> tamper-evident substrate: INTACT (antena utuh)", delay: 1400 },
      { phase: "artwork", text: "> ekstraksi fitur AI: serat kanvas, impasto, retakan mikro…", delay: 2000 },
      { phase: "artwork", text: "> cosine similarity: 94.8% (ambang minimal 88.0%) PASS", delay: 1500 },
      { phase: "artwork", text: "> attestation EIP-712 ditandatangani via HSM Node ✓", delay: 1300 },
      {
        phase: "artwork",
        text: "> STATUS: KARYA TERVERIFIKASI ASLI SECARA ON-CHAIN",
        delay: 2800,
        showVerdict: true,
        verdictMsg: "TERVERIFIKASI · 94,8% ≥ 88% PASS"
      },

      // --- FASE 2: Siaran & Sinkronisasi Jaringan Seniman Global ---
      {
        phase: "globe",
        text: "> BROADCAST ATTESTATION KE JARINGAN SENIMAN DUNIA 🌐…",
        delay: 1600,
        switchPhase: true
      },
      { phase: "globe", text: "> node [Jakarta 🇮🇩]: genesis karya seniman lokal terdaftar di L2", delay: 1600 },
      { phase: "globe", text: "> node [Paris 🇫🇷]: kurator galeri menyinkronkan sertifikat EIP-712", delay: 1600 },
      { phase: "globe", text: "> node [Tokyo 🇯🇵]: konsensus provenance lintas benua diverifikasi", delay: 1600 },
      { phase: "globe", text: "> node [New York 🇺🇸]: smart escrow siap untuk transaksi global aman", delay: 1600 },
      {
        phase: "globe",
        text: "> MISI ARTHENTIC: INISIATIF UNTUK SELURUH SENIMAN DI DUNIA 🌍",
        delay: 3800,
        showVerdict: true,
        verdictMsg: "JARINGAN SENIMAN DUNIA · 7 BENUA TERHUBUNG"
      },
    ];
  }

  let currentStep = 0;
  let stepTimeout = null;

  function runStep() {
    const sequence = getSequence();

    if (currentStep === 0) {
      terminal.innerHTML = "";
      if (verdict) verdict.classList.remove("active");
      if (!isManualOverride) {
        switchPhase("artwork");
      }
    }

    if (currentStep >= sequence.length) {
      stepTimeout = setTimeout(() => {
        currentStep = 0;
        runStep();
      }, 2500);
      return;
    }

    const item = sequence[currentStep];

    // Automatically transition visual phase unless user manually locked it
    if (!isManualOverride && item.switchPhase) {
      switchPhase(item.phase);
    } else if (!isManualOverride && currentStep === 0) {
      switchPhase("artwork");
    }

    const line = document.createElement("div");
    if (item.showVerdict) {
      line.className = "spec-val-ok";
      line.style.fontWeight = "700";
    }
    line.textContent = item.text;
    terminal.appendChild(line);
    terminal.scrollTop = terminal.scrollHeight;

    if (item.showVerdict && verdict) {
      if (verdictText && item.verdictMsg) {
        verdictText.textContent = item.verdictMsg;
      }
      verdict.classList.add("active");
    }

    currentStep++;
    stepTimeout = setTimeout(runStep, item.delay);
  }

  // Language Change Listener: Restart sequence with updated bilingual strings
  window.addEventListener("arthentic:lang-changed", () => {
    clearTimeout(stepTimeout);
    currentStep = 0;
    runStep();
  });

  runStep();
}

/* ==========================================================================

/* ==========================================================================
   5. SOLUTION TABS (3 LAPIS PROTEKSI)
   ========================================================================== */
function initSolutionTabs() {
  const tabBtns = document.querySelectorAll(".sol-tab-btn");
  const tabPanes = document.querySelectorAll(".sol-tab-pane");

  tabBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      const targetId = btn.getAttribute("data-target");

      tabBtns.forEach((b) => b.classList.remove("active"));
      tabPanes.forEach((p) => p.classList.remove("active"));

      btn.classList.add("active");
      const activePane = document.getElementById(targetId);
      if (activePane) {
        activePane.classList.add("active");

        if (targetId === "pane-l01" && lottieNfcInstance) lottieNfcInstance.play();
        if (targetId === "pane-l02" && lottieAiInstance) lottieAiInstance.play();
        if (targetId === "pane-l03" && lottieBlockchainInstance) lottieBlockchainInstance.play();
      }
    });
  });
}

/* ==========================================================================
   6. STAT COUNTERS
   ========================================================================== */
function initStatCounters() {
  const statElements = document.querySelectorAll(".stat-num");
  let triggered = false;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting && !triggered) {
          triggered = true;
          animateCounters();
        }
      });
    },
    { threshold: 0.25 }
  );

  const statsSection = document.getElementById("stats-section");
  if (statsSection) observer.observe(statsSection);

  function animateCounters() {
    statElements.forEach((el) => {
      const target = parseFloat(el.getAttribute("data-target"));
      const prefix = el.getAttribute("data-prefix") || "";
      const suffix = el.getAttribute("data-suffix") || "";
      const isDecimal = el.getAttribute("data-decimal") === "true";

      let current = 0;
      const duration = 1600;
      const stepTime = 30;
      const steps = duration / stepTime;
      const increment = target / steps;

      const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
          current = target;
          clearInterval(timer);
        }
        const valStr = isDecimal ? current.toFixed(2).replace(".", ",") : Math.floor(current);
        el.textContent = `${prefix}${valStr}${suffix}`;
      }, stepTime);
    });
  }
}

/* ==========================================================================
   7. HIGHLY INTERACTIVE PHYGETAL AUDIT SIMULATION LAB
   ========================================================================== */
function initInteractivePhygitalSim() {
  // Mode selection
  let simMode = "authentic"; // or 'tamper'
  let nfcScanned = false;
  let scannedPoints = new Set();
  let currentSimilarity = 0;

  const modeBtnAuth = document.getElementById("btn-mode-authentic");
  const modeBtnTamper = document.getElementById("btn-mode-tamper");
  const nfcTagZone = document.getElementById("sim-nfc-tag");
  const btnTriggerNfc = document.getElementById("sim-btn-trigger-nfc");
  const btnScanAllPoints = document.getElementById("sim-btn-scan-all");
  const btnReset = document.getElementById("sim-btn-reset");
  const logBox = document.getElementById("sim-terminal-log");
  const gaugeVal = document.getElementById("sim-gauge-val");
  const gaugeNeedle = document.getElementById("sim-gauge-needle");
  const verdictBanner = document.getElementById("sim-verdict-banner");
  const verdictTitle = document.getElementById("sim-verdict-title");
  const verdictSub = document.getElementById("sim-verdict-sub");
  const stepItem1 = document.getElementById("sim-step-item-1");
  const stepItem2 = document.getElementById("sim-step-item-2");
  const stepItem3 = document.getElementById("sim-step-item-3");

  const hotspots = document.querySelectorAll(".sim-hotspot");

  const hotspotData = [
    { id: 1, name: "Serat Kanvas Katun 1857", detail: "Pola tenun katun impasto 42μm", authSim: 22.4, failSim: 12.1 },
    { id: 2, name: "Pigmen Biru Ultramarine", detail: "Spektrometri lapisan pigmen", authSim: 21.8, failSim: 14.5 },
    { id: 3, name: "Craquelure Retakan Mikro", detail: "Topografi retakan alami penuaan", authSim: 18.5, failSim: 10.2 },
    { id: 4, name: "Varnish Linseed Oil", detail: "Reflektansi specular 18μm", authSim: 16.2, failSim: 11.4 },
    { id: 5, name: "Sapuan Tanda Tangan Raden Saleh", detail: "Vektor mikro sapuan kuas genesis", authSim: 15.9, failSim: 13.2 }
  ];

  function addLog(text, type = "normal") {
    if (!logBox) return;
    const div = document.createElement("div");
    if (type === "ok") div.className = "log-ok";
    else if (type === "warn") div.className = "log-warn";
    div.textContent = text;
    logBox.appendChild(div);
    logBox.scrollTop = logBox.scrollHeight;
  }

  // Switch simulation mode
  if (modeBtnAuth) {
    modeBtnAuth.addEventListener("click", () => {
      simMode = "authentic";
      modeBtnAuth.classList.add("active");
      if (modeBtnTamper) modeBtnTamper.classList.remove("active");
      resetSimulation();
      addLog("// Mode simulasi: [KARYA ASLI (Authentic Phygital)].");
      addLog("// Klik chip NFC atau tombol 'Tempelkan Ponsel' untuk memulai.");
    });
  }

  if (modeBtnTamper) {
    modeBtnTamper.addEventListener("click", () => {
      simMode = "tamper";
      modeBtnTamper.classList.add("active");
      if (modeBtnAuth) modeBtnAuth.classList.remove("active");
      resetSimulation();
      addLog("// Mode simulasi: [UJI COBA PEMALSUAN & TAMPER ATTACK]!");
      addLog("// Simulasikan serangan chip kloning atau cetak ulang kanvas 2D.");
    });
  }

  // NFC Tap Trigger (Either clicking tag or button)
  function handleNfcTap() {
    if (nfcScanned) return;
    addLog("> [NFC_READER] Mengirim tantangan enkripsi AES-128 ke chip NTAG 424...");

    if (btnTriggerNfc) btnTriggerNfc.disabled = true;

    setTimeout(() => {
      if (simMode === "authentic") {
        nfcScanned = true;
        const nonce = Math.floor(1000 + Math.random() * 9000);
        addLog(`> [NFC_OK] Diterima SUN Token Dinamis: 0x8421_F9B2_${nonce}`, "ok");
        addLog("> [NFC_OK] Dekripsi AES-128 CMAC: Valid ✓", "ok");
        addLog("> [NFC_OK] Sirkuit Tamper Substrat: INTACT (Antena Utuh) ✓", "ok");

        if (nfcTagZone) {
          nfcTagZone.classList.add("scanned");
          nfcTagZone.querySelector(".nfc-tag-label").textContent = "✓ INTACT";
        }

        if (stepItem1) {
          stepItem1.classList.remove("active");
          stepItem1.classList.add("completed");
        }
        if (stepItem2) stepItem2.classList.add("active");

        if (btnTriggerNfc) {
          btnTriggerNfc.innerHTML = `<span>✓ NFC Terverifikasi (Token Valid)</span>`;
          btnTriggerNfc.style.borderColor = "var(--ok)";
          btnTriggerNfc.style.color = "var(--ok)";
        }

        if (btnScanAllPoints) btnScanAllPoints.disabled = false;
        addLog("> [AI_SCANNER] Lapis 1 Selesai. Silakan klik 5 titik serat pada lukisan.");
      } else {
        // Tamper Attack Scenario
        addLog("> [NFC_ALERT] PERINGATAN: Nonce SUN Token Ditolak!", "warn");
        addLog("> [NFC_ALERT] Alasan: Token telah hangus / Tag NFC terindikasi hasil kloning!", "warn");
        addLog("> [NFC_ALERT] Sirkuit Tamper Loop: BROKEN (Antena terputus akibat congkelan)!", "warn");

        if (nfcTagZone) {
          nfcTagZone.style.borderColor = "var(--red-500)";
          nfcTagZone.style.background = "var(--red-50)";
          nfcTagZone.querySelector(".nfc-tag-label").textContent = "✕ BROKEN";
        }

        if (btnTriggerNfc) {
          btnTriggerNfc.innerHTML = `<span>✕ Tag Tidak Valid / Cloned</span>`;
          btnTriggerNfc.style.borderColor = "var(--red-500)";
          btnTriggerNfc.style.color = "var(--red-500)";
        }

        if (btnScanAllPoints) btnScanAllPoints.disabled = false;
      }
    }, 1000);
  }

  if (nfcTagZone) nfcTagZone.addEventListener("click", handleNfcTap);
  if (btnTriggerNfc) btnTriggerNfc.addEventListener("click", handleNfcTap);

  // Hotspot Click Handling
  hotspots.forEach((hs) => {
    hs.addEventListener("click", () => {
      const idx = parseInt(hs.getAttribute("data-index"));
      scanSingleHotspot(idx, hs);
    });
  });

  function scanSingleHotspot(idx, element) {
    if (scannedPoints.has(idx)) return;
    scannedPoints.add(idx);

    const data = hotspotData.find((d) => d.id === idx);
    const addedScore = simMode === "authentic" ? data.authSim : data.failSim;
    currentSimilarity += addedScore;

    if (element) {
      element.classList.add("scanned");
      if (simMode === "tamper") {
        element.style.borderColor = "var(--red-500)";
        element.style.color = "var(--red-500)";
      }
    }

    addLog(`> [AI_MICROSCOPE] Memindai Titik ${idx} [${data.name}]…`);
    addLog(`  ↳ ${data.detail} -> +${addedScore.toFixed(1)}% kecocokan.`);

    updateGauge();

    if (scannedPoints.size === 5) {
      finishOpticalScan();
    }
  }

  // Scan all hotspots button
  if (btnScanAllPoints) {
    btnScanAllPoints.addEventListener("click", () => {
      btnScanAllPoints.disabled = true;
      hotspots.forEach((hs, i) => {
        setTimeout(() => {
          const idx = parseInt(hs.getAttribute("data-index"));
          scanSingleHotspot(idx, hs);
        }, (i + 1) * 350);
      });
    });
  }

  function updateGauge() {
    const displayVal = Math.min(simMode === "authentic" ? 94.8 : 61.4, currentSimilarity);
    if (gaugeVal) {
      gaugeVal.textContent = `${displayVal.toFixed(1)}%`;
      if (simMode === "tamper" && displayVal > 50) {
        gaugeVal.classList.add("fail");
      } else {
        gaugeVal.classList.remove("fail");
      }
    }

    if (gaugeNeedle) {
      // Rotate needle from -90deg (0%) to 90deg (100%)
      const angle = -90 + (displayVal / 100) * 180;
      gaugeNeedle.style.transform = `rotate(${angle}deg)`;
    }
  }

  function finishOpticalScan() {
    if (stepItem2) {
      stepItem2.classList.remove("active");
      stepItem2.classList.add("completed");
    }
    if (stepItem3) stepItem3.classList.add("active");

    setTimeout(() => {
      if (simMode === "authentic") {
        addLog("> [AI_ENGINE] Komputasi Cosine Similarity: 94.8% (Ambang ≥ 88.0% PASS) ✓", "ok");
        addLog("> [BASE_L2] Menandatangani Attestation EIP-712 dengan Protocol HSM Node...", "ok");
        addLog("> [BASE_L2] Transaksi Valid! Hash: 0x7c9f4...8421_SEPOLIA", "ok");

        if (stepItem3) {
          stepItem3.classList.remove("active");
          stepItem3.classList.add("completed");
        }

        if (verdictBanner) {
          verdictBanner.className = "sim-verdict-banner show";
          if (verdictTitle) verdictTitle.textContent = "KARYA TERVERIFIKASI ASLI (94.8% ≥ 88% PASS)";
          if (verdictSub) verdictSub.textContent = "Token ID #8421 terkonfirmasi utuh di Base L2. Sertifikat provenance siap diinspeksi.";
        }

        if (lottieVerifiedInstance) lottieVerifiedInstance.play();
      } else {
        addLog("> [AI_ENGINE] HASIL: Cosine Similarity 61.4% (DI BAWAH AMBANG 88.0%)!", "warn");
        addLog("> [AI_ENGINE] Deteksi: Permukaan 2D datar tanpa kedalaman impasto serat 3D asli!", "warn");
        addLog("> [BASE_L2] KONTRAK MENOLAK TRANSAKSI: ATTESTATION_THRESHOLD_FAILED!", "warn");

        if (verdictBanner) {
          verdictBanner.className = "sim-verdict-banner show fail";
          if (verdictTitle) verdictTitle.textContent = "VERIFIKASI DITOLAK: INDIKASI PEMALSUAN (61.4% < 88%)";
          if (verdictSub) verdictSub.textContent = "Sertifikat tidak diterbitkan. Smart contract Base L2 menggagalkan klaim palsu.";
        }
      }
    }, 1200);
  }

  function resetSimulation() {
    nfcScanned = false;
    scannedPoints.clear();
    currentSimilarity = 0;

    if (logBox) {
      logBox.innerHTML = `
        <div style="color: #64748B;">// Terminal Siap. Pilih langkah 1 atau klik titik pada kanvas.</div>
      `;
    }

    if (gaugeVal) {
      gaugeVal.textContent = "0.0%";
      gaugeVal.classList.remove("fail");
    }
    if (gaugeNeedle) gaugeNeedle.style.transform = "rotate(-90deg)";

    if (nfcTagZone) {
      nfcTagZone.className = "sim-nfc-tag-zone";
      nfcTagZone.style = "";
      nfcTagZone.querySelector(".nfc-tag-label").textContent = "TAP NFC";
    }

    hotspots.forEach((hs) => {
      hs.className = "sim-hotspot " + hs.classList[1];
      hs.style = "";
    });

    if (btnTriggerNfc) {
      btnTriggerNfc.disabled = false;
      btnTriggerNfc.innerHTML = `<span>1. Tempelkan Ponsel ke Chip NFC</span>`;
      btnTriggerNfc.style = "";
    }

    if (btnScanAllPoints) {
      btnScanAllPoints.disabled = true;
    }

    if (verdictBanner) {
      verdictBanner.className = "sim-verdict-banner";
    }

    if (stepItem1) stepItem1.className = "sim-step-item active";
    if (stepItem2) stepItem2.className = "sim-step-item";
    if (stepItem3) stepItem3.className = "sim-step-item";
  }

  if (btnReset) btnReset.addEventListener("click", resetSimulation);
}

/* ==========================================================================
   8. FAQ ACCORDION
   ========================================================================== */
function initFaqAccordion() {
  const faqItems = document.querySelectorAll(".faq-item");

  faqItems.forEach((item) => {
    const questionBtn = item.querySelector(".faq-question");
    if (!questionBtn) return;

    questionBtn.addEventListener("click", () => {
      const isActive = item.classList.contains("active");

      faqItems.forEach((other) => other.classList.remove("active"));
      if (!isActive) item.classList.add("active");
    });
  });
}

/* ==========================================================================
   9. CERTIFICATE MODAL
   ========================================================================== */
function initCertificateModal() {
  const certModal = document.getElementById("cert-modal");
  const openBtns = document.querySelectorAll("[data-action='open-cert']");

  openBtns.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      if (certModal) certModal.classList.add("open");
    });
  });
}

/* ==========================================================================
   10. AUTH MODALS (SIGN UP & LOGIN)
   ========================================================================== */
function initAuthModals() {
  const signupModal = document.getElementById("signup-modal");
  const loginModal = document.getElementById("login-modal");

  document.querySelectorAll("[data-action='open-signup']").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      closeAllModals();
      if (signupModal) signupModal.classList.add("open");
    });
  });

  document.querySelectorAll("[data-action='open-login']").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      closeAllModals();
      if (loginModal) loginModal.classList.add("open");
    });
  });

  document.querySelectorAll(".modal-close-btn, .modal-backdrop").forEach((el) => {
    el.addEventListener("click", (e) => {
      if (e.target === el) closeAllModals();
    });
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeAllModals();
  });

  function closeAllModals() {
    if (signupModal) signupModal.classList.remove("open");
    if (loginModal) loginModal.classList.remove("open");
    const certModal = document.getElementById("cert-modal");
    if (certModal) certModal.classList.remove("open");
  }

  // Passkey Simulation
  const btnPasskeySignup = document.getElementById("btn-passkey-signup");
  if (btnPasskeySignup) {
    btnPasskeySignup.addEventListener("click", () => {
      btnPasskeySignup.innerHTML = `<span>Membuat Kunci Passkey & Wallet Base L2…</span>`;
      btnPasskeySignup.disabled = true;

      setTimeout(() => {
        closeAllModals();
        btnPasskeySignup.innerHTML = `<span>🔑 Daftar dengan Passkey (Face ID / Touch ID)</span>`;
        btnPasskeySignup.disabled = false;
        showToast("✓ Akun & Smart Wallet Anda berhasil dibuat! Selamat datang di Arthentic.");
      }, 1400);
    });
  }

  const btnPasskeyLogin = document.getElementById("btn-passkey-login");
  if (btnPasskeyLogin) {
    btnPasskeyLogin.addEventListener("click", () => {
      btnPasskeyLogin.innerHTML = `<span>Memverifikasi Biometrik Face ID / Touch ID…</span>`;
      btnPasskeyLogin.disabled = true;

      setTimeout(() => {
        closeAllModals();
        btnPasskeyLogin.innerHTML = `<span>🔑 Masuk dengan Passkey</span>`;
        btnPasskeyLogin.disabled = false;
        showToast("✓ Selamat datang kembali! Kunci passkey Anda telah terautentikasi.");
      }, 1200);
    });
  }
}

/* ==========================================================================
   11. TOAST HELPER
   ========================================================================== */
function showToast(message) {
  const toast = document.getElementById("toast-notice");
  const toastText = document.getElementById("toast-text");
  if (!toast || !toastText) return;

  toastText.textContent = message;
  toast.style.display = "flex";

  setTimeout(() => {
    toast.style.display = "none";
  }, 4500);
}

/* ==========================================================================
   12. MOBILE MENU HAMBURGER
   ========================================================================== */
function initMobileMenu() {
  const hamburger = document.getElementById("hamburger-btn");
  const drawer = document.getElementById("mobile-drawer");

  if (!hamburger || !drawer) return;

  hamburger.addEventListener("click", () => {
    const isOpen = drawer.style.display === "flex";
    drawer.style.display = isOpen ? "none" : "flex";
  });

  drawer.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      drawer.style.display = "none";
    });
  });
}
