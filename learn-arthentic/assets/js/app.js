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
   4. HERO TELEMETRY TYPEWRITER (12-Second Loop)
   ========================================================================== */
function initHeroTelemetry() {
  const terminal = document.getElementById("hero-telemetry");
  const verdict = document.getElementById("hero-verdict");
  if (!terminal) return;

  const sequence = [
    { text: "> inisialisasi node arthentic: chain_id 8453 (Base L2)", delay: 800 },
    { text: "> tap SUN token… enkripsi AES-128 OK (Nonce #8421)", delay: 1500 },
    { text: "> tamper-evident substrate: INTACT (antena utuh)", delay: 1600 },
    { text: "> ekstraksi fitur AI: serat kanvas, impasto, retakan mikro…", delay: 2200 },
    { text: "> cosine similarity: 94.8% (ambang minimal 88.0%) PASS", delay: 1600 },
    { text: "> attestation EIP-712 ditandatangani via HSM Node ✓", delay: 1400 },
    { text: "> STATUS: KARYA TERVERIFIKASI ASLI SECARA ON-CHAIN", delay: 2600, showVerdict: true },
  ];

  let currentStep = 0;

  function runStep() {
    if (currentStep === 0) {
      terminal.innerHTML = "";
      if (verdict) verdict.classList.remove("active");
    }

    if (currentStep >= sequence.length) {
      setTimeout(() => {
        currentStep = 0;
        runStep();
      }, 3000);
      return;
    }

    const item = sequence[currentStep];
    const line = document.createElement("div");
    if (item.showVerdict) line.className = "spec-val-ok";
    line.textContent = item.text;
    terminal.appendChild(line);
    terminal.scrollTop = terminal.scrollHeight;

    if (item.showVerdict && verdict) {
      verdict.classList.add("active");
    }

    currentStep++;
    setTimeout(runStep, item.delay);
  }

  runStep();
}

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
