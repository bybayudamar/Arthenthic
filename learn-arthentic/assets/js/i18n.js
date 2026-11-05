/**
 * Arthentic Internationalization (i18n) Engine
 * Supported Languages: Indonesian ('id') & English ('en')
 * Default: 'id' (preserves user preference in localStorage)
 */

const ArthenticI18n = (() => {
  const STORAGE_KEY = "arthentic_lang";

  const translations = {
    id: {
      // Navbar
      "nav.masalah": "Masalah",
      "nav.solusi": "Solusi",
      "nav.cara_kerja": "Cara Kerja",
      "nav.demo": "Simulasi",
      "nav.biaya": "Biaya",
      "nav.keamanan": "Keamanan",
      "nav.faq": "FAQ",
      "nav.login": "Masuk",
      "nav.signup": "Daftar Gratis →",

      // Hero
      "hero.eyebrow": "PROTOKOL OTENTIKASI PHYGITAL · BASE L2",
      "hero.title": "Lukisan Anda Asli.<br><span class=\"glow-text\">Sekarang Terbukti.</span>",
      "hero.desc": "Arthentic mengikat karya seni fisik ke identitas digital yang sulit dipalsukan: chip kriptografi anti-kloning, sidik jari serat mikro berbasis AI, dan catatan provenance permanen di blockchain.",
      "hero.cta_signup": "Daftar Gratis →",
      "hero.cta_demo": "Lihat simulasi verifikasi",
      "hero.cta_cert": "Lihat Contoh Sertifikat On-Chain (CoA) →",
      "hero.stat_val1": "$65 Miliar+",
      "hero.stat_lbl1": "Nilai Pasar Seni Global",
      "hero.stat_val2": "30–50%",
      "hero.stat_lbl2": "Diduga Tiruan / Palsu",
      "hero.stat_val3": "0%",
      "hero.stat_lbl3": "Peluang Kloning Tag SUN",
      "hero.telemetry_title": "LIVE TELEMETRY NODE #01",
      "hero.telemetry_net_lbl": "Jaringan:",
      "hero.telemetry_net_val": "Base L2 Sepolia Aktif",
      "hero.telemetry_gas_lbl": "Gas Sponsorship:",
      "hero.telemetry_gas_val": "ERC-4337 Paymaster Siap",
      "hero.telemetry_ai_lbl": "Ambang Biometrik:",
      "hero.telemetry_ai_val": "≥ 88.0% Kesamaan Kosinus",
      "hero.telemetry_chip_lbl": "Enkripsi Kunci:",
      "hero.telemetry_chip_val": "NTAG 424 DNA AES-128 SUN",

      // Problem
      "problem.eyebrow": "MASALAH VERIFIKASI KONVENSIONAL",
      "problem.title": "Pasar seni bernilai miliaran dolar.<br>Pondasi verifikasinya rapuh.",
      "problem.desc": "Keaslian karya seni masih dibuktikan dengan selembar kertas, tanda tangan basah, dan catatan galeri. Semuanya berada <em>di luar</em> karya itu sendiri.",
      "problem.card1_title": "Sertifikat kertas mudah dipalsukan",
      "problem.card1_desc": "Dokumen tidak terikat secara kriptografis pada objek fisiknya. Bisa dicetak ulang oleh pihak tak berwenang, rusak karena usia, hilang, atau dimanipulasi saat perpindahan tangan di pasar gelap.",
      "problem.card2_title": "Tag NFC biasa bisa dikloning",
      "problem.card2_desc": "Tag konvensional murah hanya mengirim teks/URL statis yang identik di setiap pemindaian ponsel. Sekali disalin ke chip kosong lain seharga ribuan rupiah, salinannya dianggap valid selamanya.",
      "problem.card3_title": "Riwayat kepemilikan terputus",
      "problem.card3_desc": "Penjualan luring berpindah tangan secara privat tanpa jejak audit publik. Saat lukisan muncul 10 tahun kemudian, riwayat kurasi dan restorasi masa lalunya mustahil dibuktikan secara objektif.",
      "problem.card4_title": "NFT terpisah dari lukisannya",
      "problem.card4_desc": "Token digital di masa lalu hanya menunjuk URI gambar web, bukan ke struktur fisik kanvas. Akibatnya, token bisa diperdagangkan sementara lukisan aslinya tertinggal, tertukar, atau dicuri.",

      // Solution
      "solution.eyebrow": "ARSITEKTUR PERLINDUNGAN ARTHENTIC",
      "solution.title": "Tiga lapis proteksi.<br>Tanpa titik kegagalan tunggal.",
      "solution.tab1": "L01 · Hardware Anti-Kloning",
      "solution.tab2": "L02 · AI Biometrik Serat Mikro",
      "solution.tab3": "L03 · Blockchain Base L2",
      "solution.l1_tag": "// LAPIS PERTAMA: FISIK KRIPTOGRAFIS",
      "solution.l1_title": "NTAG 424 DNA + Substrat Tamper-Evident",
      "solution.l1_desc": "Setiap kali chip didekatkan dengan ponsel (tap), chip menghitung token kriptografi dinamis sekali pakai (AES-128, Secure Unique NFC Message / SUN).",
      "solution.l1_f1_t": "Anti-Kloning:",
      "solution.l1_f1_d": "URL yang disalin langsung ditolak pada pemindaian berikutnya karena nonce kriptografis sudah hangus.",
      "solution.l1_f2_t": "Tamper-Evident:",
      "solution.l1_f2_d": "Ditanam dengan antena sirkuit pecah. Jika chip dicabut paksa untuk dipindahkan ke lukisan tiruan, sirkuit putus permanen.",
      "solution.l1_f3_t": "Standar Terbuka:",
      "solution.l1_f3_d": "Dapat dipindai langsung oleh iPhone & Android melalui CoreNFC tanpa memerlukan alat pembaca khusus.",
      "solution.l2_tag": "// LAPIS KEDUA: BIOMETRIK SERAT MIKRO",
      "solution.l2_title": "Sidik Jari Optik Mikro: AI Vector & Cosine Similarity",
      "solution.l2_desc": "Karya seni fisik memiliki topografi serat mikro yang unik seperti sidik jari manusia. Sensor LiDAR dan lensa makro memindai 5–10 koordinat mikroskopis kanvas.",
      "solution.l2_f1_t": "Genesis Feature Vector:",
      "solution.l2_f1_d": "Pola tenun katun/linen, relief ketebalan cat (impasto), dan retakan mikro diubah menjadi vektor 128-dimensi.",
      "solution.l2_f2_t": "Ambang Kritis ≥ 88%:",
      "solution.l2_f2_d": "Algoritma kemiripan kosinus mencocokkan kondisi fisik saat ini dengan data genesis, toleran terhadap penuaan pigmen wajar.",
      "solution.l2_f3_t": "Tolak Tiruan 2D:",
      "solution.l2_f3_d": "Cetakan foto resolusi tinggi tidak memiliki kedalaman serat 3D dan ketebalan relief cat minyak asli.",
      "solution.l3_tag": "// LAPIS KETIGA: BUKU BESAR IMMUTABLE",
      "solution.l3_title": "Base L2 + ERC-721 + Penyimpanan Abadi Arweave",
      "solution.l3_desc": "Identitas karya seni dicetak sebagai smart contract ERC-721 di Base L2 (Ethereum Layer 2) dengan biaya gas yang disubsidi oleh Paymaster.",
      "solution.l3_f1_t": "Smart Contract Escrow:",
      "solution.l3_f1_d": "Dana pembelian terkunci otomatis hingga pembeli memverifikasi keaslian fisik karya via tap NFC dan pemindaian optik.",
      "solution.l3_f2_t": "Royalti Otomatis (ERC-2981):",
      "solution.l3_f2_d": "Seniman menerima bagi hasil otomatis pada setiap penjualan kembali di pasar sekunder.",
      "solution.l3_f3_t": "Arweave Permanent Storage:",
      "solution.l3_f3_d": "Metadata resolusi tinggi, koordinat biometrik, dan sertifikat diarsipkan abadi tanpa risiko server padam.",

      // How it Works / Stepper
      "stepper.eyebrow": "ALUR KERJA END-TO-END",
      "stepper.title": "Dari kanvas seniman hingga kolektor berikutnya.",
      "stepper.desc": "Proses verifikasi phygital tanpa friksi yang mengamankan setiap tahap siklus hidup karya seni fisik.",
      "stepper.s1_title": "Registrasi",
      "stepper.s1_desc": "Seniman mendaftarkan metadata karya, dimensi kanvas, dan tahun pembuatan.",
      "stepper.s2_title": "Pembelian",
      "stepper.s2_desc": "Kolektor menyetor dana ke smart contract Escrow Arthentic.",
      "stepper.s3_title": "Pengiriman",
      "stepper.s3_desc": "Karya seni dikirim menggunakan kurir seni bernomor lacak terverifikasi.",
      "stepper.s4_title": "Tap Claim",
      "stepper.s4_desc": "Pembeli menerima karya, tap NFC + scan serat optik untuk merilis dana escrow.",
      "stepper.s5_title": "Restorasi",
      "stepper.s5_desc": "Jika kanvas rusak, konservator mengajukan penggantian chip 3-of-3 multisig.",
      "stepper.s6_title": "Resale",
      "stepper.s6_desc": "Dijual kembali di pasar sekunder, royalti ERC-2981 langsung cair ke seniman.",

      // Roles
      "roles.eyebrow": "EKOSISTEM TERHUBUNG",
      "roles.title": "Enam peran.<br>Satu kebenaran yang terdesentralisasi.",
      "roles.r1_name": "Seniman",
      "roles.r1_desc": "Pembuat karya asli yang memiliki wewenang mencetak genesis token dan menerima royalti.",
      "roles.r2_name": "Galeri Verifier",
      "roles.r2_desc": "Lembaga terakreditasi yang bertugas melakukan audit fisik awal dan co-signing safe minting.",
      "roles.r3_name": "Kolektor Seni",
      "roles.r3_desc": "Pemilik fisik dan digital yang dapat memverifikasi keaslian karya kapan saja dengan sekali tap.",
      "roles.r4_name": "Konservator",
      "roles.r4_desc": "Pakar restorasi yang berhak menerbitkan condition report dan memproses penggantian chip rusak.",
      "roles.r5_name": "Pembeli Sekunder",
      "roles.r5_desc": "Pihak yang bertransaksi dengan jaminan escrow fisik dan proteksi anti-tiruan otomatis.",
      "roles.r6_name": "Arthentic Node",
      "roles.r6_desc": "Node penandatangan HSM/KMS yang memvalidasi token SUN CMAC dan menandatangani EIP-712.",

      // Simulator Demo
      "demo.eyebrow": "LAB TELEMETRI & INSPEKTUR INTERAKTIF",
      "demo.title": "Simulasi audit keaslian phygital.",
      "demo.desc": "Uji bagaimana sistem memvalidasi chip NFC dinamis dan kemiripan biometrik serat kain.",
      "demo.select_scenario": "PILIH SKENARIO PENGUJIAN:",
      "demo.btn_run": "Jalankan Simulasi Verifikasi",
      "demo.btn_reset": "Reset Skenario",
      "demo.sim_title": "HASIL VERIFIKASI AKHIR",
      "demo.sim_cert_btn": "Buka Sertifikat Lengkap (CoA) →",

      // Pricing
      "pricing.eyebrow": "EFISIENSI BIAYA",
      "pricing.title": "Verifikasi berulang yang masuk akal secara ekonomi.",
      "pricing.desc": "Tanpa biaya berlangganan mahal. Biaya transaksi disubsidi oleh Base L2 Paymaster.",
      "pricing.p1_title": "Seniman Pemula",
      "pricing.p1_desc": "Untuk seniman independen yang ingin memproteksi hingga 3 karya pertama.",
      "pricing.p2_title": "Galeri & Studio",
      "pricing.p2_desc": "Paket lengkap untuk galeri seni komersial dan studio aktif.",
      "pricing.p3_title": "Institusi & Balai Lelang",
      "pricing.p3_desc": "Infrastruktur enterprise untuk museum, asuransi, dan rumah lelang.",
      "pricing.btn_choose": "Pilih Paket Ini →",
      "pricing.btn_contact": "Hubungi Tim Institusi →",

      // Security
      "security.eyebrow": "MODEL KEAMANAN PROAKTIF",
      "security.title": "Dirancang dengan asumsi bahwa penyerang itu ada.",
      "security.desc": "Keamanan berlapis standar institusional perbankan dan kriptografi tingkat militer.",

      // FAQ
      "faq.eyebrow": "PERTANYAAN UMUM",
      "faq.title": "Pertanyaan yang Sering Diajukan",
      "faq.desc": "Semua hal teknis dan non-teknis tentang cara kerja Arthentic.",

      // CTA Final & Footer
      "cta.eyebrow": "MULAI HARI INI",
      "cta.title": "Mulai Lindungi Karya Seni Anda Hari Ini.",
      "cta.desc": "Bergabunglah dengan ratusan seniman, kurator, dan galeri yang telah beralih ke standar otentikasi phygital terpercaya.",
      "cta.btn_signup": "Daftar Akun Gratis →",
      "cta.btn_demo": "Coba Simulasi Verifikasi",
      "footer.desc": "Protokol otentikasi phygital terdesentralisasi untuk karya seni fisik dan warisan budaya bernilai tinggi.",
      "footer.rights": "© 2026 Arthentic Protocol. Hak Cipta Dilindungi. Dibangun di atas Base L2.",

      // Modals
      "modal.signup_title": "Buat akun Arthentic",
      "modal.signup_desc": "Mulai amankan lukisan fisik Anda dengan otentikasi blockchain terdesentralisasi.",
      "modal.login_title": "Selamat datang kembali",
      "modal.login_desc": "Masuk ke portal kurator, seniman, atau kolektor Arthentic Anda.",
      "modal.btn_google": "Lanjutkan dengan Google",
      "modal.btn_siwe": "Sign-In with Ethereum (Web3)",
    },

    en: {
      // Navbar
      "nav.masalah": "Problem",
      "nav.solusi": "Solution",
      "nav.cara_kerja": "How It Works",
      "nav.demo": "Simulation",
      "nav.biaya": "Pricing",
      "nav.keamanan": "Security",
      "nav.faq": "FAQ",
      "nav.login": "Sign In",
      "nav.signup": "Get Started Free →",

      // Hero
      "hero.eyebrow": "PHYGITAL AUTHENTICATION PROTOCOL · BASE L2",
      "hero.title": "Your Art is Original.<br><span class=\"glow-text\">Now Cryptographically Proven.</span>",
      "hero.desc": "Arthentic binds physical fine art to an unforgeable digital identity: anti-cloning cryptographic chips, AI-powered micro-weave optical fingerprinting, and permanent blockchain provenance.",
      "hero.cta_signup": "Get Started Free →",
      "hero.cta_demo": "Try Verification Simulation",
      "hero.cta_cert": "Inspect Sample On-Chain CoA →",
      "hero.stat_val1": "$65 Billion+",
      "hero.stat_lbl1": "Global Fine Art Market",
      "hero.stat_val2": "30–50%",
      "hero.stat_lbl2": "Estimated Forged or Disputed",
      "hero.stat_val3": "0%",
      "hero.stat_lbl3": "SUN Tag Cloning Surface",
      "hero.telemetry_title": "LIVE TELEMETRY NODE #01",
      "hero.telemetry_net_lbl": "Network:",
      "hero.telemetry_net_val": "Base L2 Sepolia Active",
      "hero.telemetry_gas_lbl": "Gas Sponsorship:",
      "hero.telemetry_gas_val": "ERC-4337 Paymaster Ready",
      "hero.telemetry_ai_lbl": "Biometric Threshold:",
      "hero.telemetry_ai_val": "≥ 88.0% Cosine Similarity",
      "hero.telemetry_chip_lbl": "Key Cryptography:",
      "hero.telemetry_chip_val": "NTAG 424 DNA AES-128 SUN",

      // Problem
      "problem.eyebrow": "CONVENTIONAL VERIFICATION CHALLENGES",
      "problem.title": "A multi-billion dollar art market.<br>Resting on fragile paper foundations.",
      "problem.desc": "Fine art authenticity is still proven with loose paper certificates, wet signatures, and dealer records. Everything exists <em>outside</em> the canvas itself.",
      "problem.card1_title": "Paper certificates are easily forged",
      "problem.card1_desc": "Documents are not cryptographically tethered to the physical painting. They can be counterfeited, lost, damaged over decades, or manipulated in secondary black markets.",
      "problem.card2_title": "Standard NFC tags are easily cloned",
      "problem.card2_desc": "Cheap generic RFID stickers only broadcast static UIDs that can be duplicated in seconds using handheld devices like Flipper Zero or ordinary smartphones.",
      "problem.card3_title": "Provenance chains break in transit",
      "problem.card3_desc": "Offline private sales change hands without permanent public audit trails. When an artwork resurfaces a decade later, historical conservation and restoration records are lost.",
      "problem.card4_title": "Pure NFTs disconnect from physical canvas",
      "problem.card4_desc": "Digital tokens alone on blockchain merely point to web image URIs rather than physical canvas weaves. Tokens get traded while the actual physical canvas is swapped or stolen.",

      // Solution
      "solution.eyebrow": "ARTHENTIC DEFENSE ARCHITECTURE",
      "solution.title": "Three layers of cryptographic defense.<br>Zero single points of failure.",
      "solution.tab1": "L01 · Anti-Cloning Hardware",
      "solution.tab2": "L02 · AI Micro-Weave Biometrics",
      "solution.tab3": "L03 · Blockchain Base L2",
      "solution.l1_tag": "// LAYER 1: HARDWARE SECURITY TOKEN",
      "solution.l1_title": "NTAG 424 DNA + Tamper-Evident Substrate",
      "solution.l1_desc": "Every physical smartphone tap triggers the onboard cryptographic coprocessor to calculate a dynamic single-use AES-128 SUN CMAC nonce.",
      "solution.l1_f1_t": "Anti-Cloning:",
      "solution.l1_f1_d": "Copied URLs are rejected on the next scan because cryptographic nonces expire instantly upon verification.",
      "solution.l1_f2_t": "Tamper-Evident:",
      "solution.l1_f2_d": "Embedded with a conductive tamper-detection loop. If ripped from the canvas, the circuit breaks permanently.",
      "solution.l1_f3_t": "Open Standard:",
      "solution.l1_f3_d": "Tap directly with modern iPhone & Android devices via CoreNFC without requiring proprietary hardware readers.",
      "solution.l2_tag": "// LAYER 2: MICRO-WEAVE BIOMETRICS",
      "solution.l2_title": "Optical Fingerprint: AI Vector & Cosine Similarity",
      "solution.l2_desc": "Fine art canvases possess unique surface relief topographies akin to human fingerprints. LiDAR and macro optics capture 5–10 microscopic anchor points.",
      "solution.l2_f1_t": "Genesis Feature Vector:",
      "solution.l2_f1_d": "Linen weave patterns, oil impasto relief heights, and micro-cracking are compressed into a 128-dimensional embedding vector.",
      "solution.l2_f2_t": "Critical Threshold ≥ 88%:",
      "solution.l2_f2_d": "Cosine similarity algorithms match physical condition against genesis records, gracefully tolerating natural pigment aging.",
      "solution.l2_f3_t": "2D Replica Rejection:",
      "solution.l2_f3_d": "High-resolution photographic canvas prints lack authentic 3D spatial depth variance and textural relief.",
      "solution.l3_tag": "// LAYER 3: IMMUTABLE LEDGER",
      "solution.l3_title": "Base L2 + ERC-721 + Arweave Permanent Storage",
      "solution.l3_desc": "Artwork identity is settled as an ERC-721 smart contract on Base L2 with gas fees sponsored by our decentralized Paymaster.",
      "solution.l3_f1_t": "Smart Contract Escrow:",
      "solution.l3_f1_d": "Buyer funds remain locked until the collector physically taps the NFC chip and confirms LiDAR surface authenticity.",
      "solution.l3_f2_t": "Automated Royalties (ERC-2981):",
      "solution.l3_f2_d": "Original creators automatically receive resale royalties on all secondary market transactions.",
      "solution.l3_f3_t": "Arweave Permanent Archival:",
      "solution.l3_f3_d": "High-resolution capture bundles, biometric coordinates, and CoAs are permanently pinned without server downtime risk.",

      // How it Works / Stepper
      "stepper.eyebrow": "END-TO-END WORKFLOW PIPELINE",
      "stepper.title": "From artist's easel to the next collector.",
      "stepper.desc": "A frictionless phygital verification pipeline securing each milestone of physical fine art ownership.",
      "stepper.s1_title": "Registration",
      "stepper.s1_desc": "Artist registers artwork metadata, canvas medium, dimensions, and creation year.",
      "stepper.s2_title": "Purchase",
      "stepper.s2_desc": "Buyer deposits payment directly into the Arthentic Escrow smart contract.",
      "stepper.s3_title": "Transit",
      "stepper.s3_desc": "The painting is dispatched via insured fine art courier with tracked chain-of-custody.",
      "stepper.s4_title": "Tap Claim",
      "stepper.s4_desc": "Buyer inspects physical canvas, taps NFC tag & runs LiDAR scan to release escrow funds.",
      "stepper.s5_title": "Conservation",
      "stepper.s5_desc": "If damaged, conservators submit restoration reports and 3-of-3 multisig tag recovery.",
      "stepper.s6_title": "Resale",
      "stepper.s6_desc": "Sold on secondary markets with guaranteed provenance and automated ERC-2981 royalties.",

      // Roles
      "roles.eyebrow": "CONNECTED ECOSYSTEM",
      "roles.title": "Six institutional roles.<br>One decentralized truth.",
      "roles.r1_name": "Artist",
      "roles.r1_desc": "Original creator authorized to mint genesis tokens and receive continuous secondary royalties.",
      "roles.r2_name": "Gallery Verifier",
      "roles.r2_desc": "Accredited institution executing initial physical verification intake and safe mint co-signing.",
      "roles.r3_name": "Art Collector",
      "roles.r3_desc": "Physical and digital custodian capable of verifying authenticity instantly with a zero-install smartphone tap.",
      "roles.r4_name": "Conservator",
      "roles.r4_desc": "Restoration expert authorized to publish condition reports and execute multisig chip recovery.",
      "roles.r5_name": "Secondary Buyer",
      "roles.r5_desc": "Transacts with cryptographic physical escrow assurance and automated anti-counterfeit gates.",
      "roles.r6_name": "Arthentic Node",
      "roles.r6_desc": "Decentralized KMS/HSM signer node evaluating SUN CMAC nonces and issuing signed EIP-712 attestations.",

      // Simulator Demo
      "demo.eyebrow": "INTERACTIVE TELEMETRY & AUDIT LAB",
      "demo.title": "Simulate an on-chain phygital authenticity audit.",
      "demo.desc": "Experience how Arthentic validates dynamic NFC SUN nonces and optical biometric weave similarity in real-time.",
      "demo.select_scenario": "SELECT TEST SCENARIO:",
      "demo.btn_run": "Execute Verification Simulation",
      "demo.btn_reset": "Reset Scenario",
      "demo.sim_title": "FINAL VERIFICATION REPORT",
      "demo.sim_cert_btn": "Inspect Full Certificate of Authenticity (CoA) →",

      // Pricing
      "pricing.eyebrow": "COST EFFICIENCY",
      "pricing.title": "Economically sustainable fine art authentication.",
      "pricing.desc": "Zero predatory subscriptions. On-chain gas sponsored by our ERC-4337 Base L2 Paymaster.",
      "pricing.p1_title": "Emerging Artist",
      "pricing.p1_desc": "For independent creators protecting their first 3 fine art pieces.",
      "pricing.p2_title": "Galleries & Studios",
      "pricing.p2_desc": "Complete provenance suite for commercial galleries and active ateliers.",
      "pricing.p3_title": "Institutions & Auctioneers",
      "pricing.p3_desc": "Enterprise infrastructure for museums, fine art insurers, and auction houses.",
      "pricing.btn_choose": "Select Tier →",
      "pricing.btn_contact": "Contact Institutional Desk →",

      // Security
      "security.eyebrow": "PROACTIVE SECURITY MODEL",
      "security.title": "Engineered under adversarial assumptions.",
      "security.desc": "Institutional-grade hardware security modules, low-s EIP-2 signatures, and decentralized custody.",

      // FAQ
      "faq.eyebrow": "FREQUENTLY ASKED QUESTIONS",
      "faq.title": "Frequently Asked Questions",
      "faq.desc": "Technical and operational insights into the Arthentic protocol.",

      // CTA Final & Footer
      "cta.eyebrow": "GET STARTED TODAY",
      "cta.title": "Start Protecting Your Artwork Today.",
      "cta.desc": "Join hundreds of artists, curators, and accredited galleries anchoring their physical collections on-chain.",
      "cta.btn_signup": "Create Free Account →",
      "cta.btn_demo": "Try Verification Simulation",
      "footer.desc": "Decentralized phygital authentication protocol for physical fine art and high-value cultural heritage.",
      "footer.rights": "© 2026 Arthentic Protocol. All Rights Reserved. Built on Base L2.",

      // Modals
      "modal.signup_title": "Create Arthentic Account",
      "modal.signup_desc": "Start anchoring your physical paintings with decentralized blockchain authentication.",
      "modal.login_title": "Welcome Back",
      "modal.login_desc": "Log into your curator, artist, or collector workspace.",
      "modal.btn_google": "Continue with Google",
      "modal.btn_siwe": "Sign-In with Ethereum (Web3)",
    }
  };

  function getCurrentLang() {
    return localStorage.getItem(STORAGE_KEY) || "id";
  }

  function setLanguage(lang) {
    if (!translations[lang]) lang = "id";
    localStorage.setItem(STORAGE_KEY, lang);
    document.documentElement.setAttribute("lang", lang);

    // Update active class on all language buttons
    document.querySelectorAll(".lang-btn").forEach((btn) => {
      const btnLang = btn.getAttribute("data-lang");
      if (btnLang === lang) {
        btn.classList.add("active");
      } else {
        btn.classList.remove("active");
      }
    });

    // Translate all elements with [data-i18n]
    const dict = translations[lang];
    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const key = el.getAttribute("data-i18n");
      if (dict && dict[key]) {
        el.innerHTML = dict[key];
      }
    });

    // Translate placeholder attributes if any
    document.querySelectorAll("[data-i18n-placeholder]").forEach((el) => {
      const key = el.getAttribute("data-i18n-placeholder");
      if (dict && dict[key]) {
        el.setAttribute("placeholder", dict[key]);
      }
    });

    // Dispatch event so any custom widget can listen
    window.dispatchEvent(new CustomEvent("arthentic:lang-changed", { detail: { lang } }));
  }

  function init() {
    const initialLang = getCurrentLang();
    setLanguage(initialLang);

    // Bind click events on all language switch buttons
    document.querySelectorAll(".lang-btn").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        const selected = btn.getAttribute("data-lang");
        if (selected) {
          setLanguage(selected);
        }
      });
    });
  }

  return {
    init,
    setLanguage,
    getCurrentLang,
    translations,
  };
})();

// Auto-initialize when DOM is ready
document.addEventListener("DOMContentLoaded", () => {
  ArthenticI18n.init();
});
