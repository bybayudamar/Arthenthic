# Arthentic: Draft Landing Page

> Dokumen ini berisi **copywriting (PAS + CTA)**, **arahan UI ala ton.org**, dan **spesifikasi hero animasi hi-tech** dengan warna utama **merah**.
> Semua klaim teknis diambil dari laporan kelompok Arthentic. Angka biaya bersifat indikatif (asumsi ETH $2.350).

---

## 0. Ringkasan Strategi

| Item | Keputusan |
|---|---|
| Kerangka copy | **PAS**: Problem → Agitate → Solution, ditutup dengan CTA |
| CTA utama | **Daftar Gratis** (Sign Up) |
| CTA sekunder | **Masuk** (Login) |
| Target pengguna | Seniman, galeri, kolektor, konservator, pembeli pasar sekunder (mayoritas non-crypto) |
| Nada bahasa | Tegas, teknis tapi mudah dipahami, tanpa jargon crypto di bagian depan |
| Bahasa | Indonesia (siap dibuat versi EN) |
| Catatan klaim | Gunakan "sulit dipalsukan", bukan "mustahil dipalsukan" |

**Alur halaman:**
`Navbar → Hero → Marquee Tech → [P] Problem → [A] Agitate → [S] Solution (3 Lapis) → Cara Kerja → Angka → Untuk Siapa → Demo Verifikasi → Biaya → Kepercayaan/Keamanan → FAQ → CTA Final → Footer`

---

## 1. Arahan Desain (Design Direction)

### 1.1 Karakter visual ala ton.org
- **Dark-first**: latar hampir hitam, kontras tinggi, tipografi besar dan berani.
- **Ruang kosong luas**, satu pesan per layar (one idea per viewport).
- **Pill button** membulat penuh, glow lembut di sekitar CTA utama.
- **Kartu rounded** (radius 20–28px) dengan border tipis dan efek glass/blur.
- **Gradient glow merah** di belakang hero dan angka besar.
- **Marquee logo/teknologi** berjalan pelan di bawah hero.
- **Angka besar (big number stats)** dengan counter animasi saat masuk viewport.
- Animasi **scroll-reveal** halus (fade + translateY 24px, 600ms ease-out).

### 1.2 Palet warna (RED sebagai warna utama)

| Token | Hex | Pemakaian |
|---|---|---|
| `--red-500` | `#FF2D3D` | Warna utama, CTA, aksen, glow |
| `--red-600` | `#E11D2E` | Hover CTA |
| `--red-700` | `#B3121F` | Pressed, border aksen |
| `--red-300` | `#FF7A85` | Teks aksen di latar gelap |
| `--bg-0` | `#09090B` | Latar halaman |
| `--bg-1` | `#111114` | Kartu, section selang-seling |
| `--bg-2` | `#18181C` | Kartu terangkat, input |
| `--line` | `#26262C` | Border |
| `--text-0` | `#FAFAFA` | Heading |
| `--text-1` | `#A1A1AA` | Teks deskripsi |
| `--ok` | `#22C55E` | Status "Valid / Verified" saja |

> Merah dipakai untuk identitas dan aksi. Hijau hanya untuk status verifikasi berhasil, agar maknanya tidak tertukar.

### 1.3 Tipografi

| Peran | Font | Catatan |
|---|---|---|
| Heading (H1–H3), angka besar | **Plus Jakarta Sans** (700–800) | letter-spacing `-0.02em`, line-height 1.05–1.15 |
| Body, deskripsi, label, tombol kecil, terminal | **Monospace** (`JetBrains Mono`, fallback `ui-monospace, SFMono-Regular, Menlo, monospace`) | 14–15px, line-height 1.7 |

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

```css
:root{
  --red-500:#FF2D3D; --red-600:#E11D2E; --red-700:#B3121F; --red-300:#FF7A85;
  --bg-0:#09090B; --bg-1:#111114; --bg-2:#18181C; --line:#26262C;
  --text-0:#FAFAFA; --text-1:#A1A1AA; --ok:#22C55E;
  --font-head:"Plus Jakarta Sans",system-ui,sans-serif;
  --font-mono:"JetBrains Mono",ui-monospace,SFMono-Regular,Menlo,monospace;
}
body{background:var(--bg-0);color:var(--text-1);font-family:var(--font-mono);line-height:1.7}
h1,h2,h3,.big-number{font-family:var(--font-head);color:var(--text-0);letter-spacing:-.02em}
.btn-primary{background:var(--red-500);color:#fff;border-radius:999px;padding:14px 28px;
  font-family:var(--font-head);font-weight:700;box-shadow:0 0 40px rgba(255,45,61,.35)}
.btn-primary:hover{background:var(--red-600)}
.btn-ghost{border:1px solid var(--line);color:var(--text-0);border-radius:999px;padding:14px 28px}
```

---

## 2. Navbar

**Layout:** logo kiri · menu tengah · aksi kanan. Sticky, latar blur transparan.

```
[◆ ARTHENTIC]   Masalah   Solusi   Cara Kerja   Biaya   FAQ        [ Masuk ]  [ Daftar Gratis → ]
```

| Elemen | Gaya |
|---|---|
| Logo | Ikon kotak merah + wordmark putih |
| `Masuk` | Tombol ghost (outline) → `/login` |
| `Daftar Gratis →` | Tombol pill merah solid → `/signup` |
| Mobile | Hamburger; kedua tombol auth tetap terlihat di panel menu |

---

## 3. HERO (Problem Teaser + Value Proposition)

### 3.1 Copy

**Eyebrow (mono, merah, uppercase):**
`// PROTOKOL OTENTIKASI PHYGITAL · BASE L2`

**H1 (Plus Jakarta Sans, 72–88px desktop):**
> Lukisan Anda Asli.
> **Sekarang Terbukti.**

*(kata "Terbukti." berwarna merah dengan glow)*

**Sub-headline (mono):**
> Arthentic mengikat karya seni fisik ke identitas digital yang sulit dipalsukan: chip kriptografi anti-kloning, sidik jari serat mikro berbasis AI, dan catatan provenance permanen di blockchain.

**CTA:**

| Tombol | Label | Tujuan |
|---|---|---|
| Primer | **Daftar Gratis →** | `/signup` |
| Sekunder | **Masuk** | `/login` |
| Tautan teks | `▶ Lihat simulasi verifikasi` | scroll ke #demo |

**Microcopy di bawah CTA (mono, kecil, abu):**
`✓ Tanpa seed phrase · Login dengan Face ID / Touch ID · Biaya gas ditanggung protokol`

**Trust strip kecil:**
`ERC-721 · EIP-712 · NTAG 424 DNA · Base L2 · Ethereum anchor`

### 3.2 Spesifikasi Hero: Animated Hi-Tech UI (Merah)

**Konsep:** layar kanan menampilkan "Verification Console" yang berjalan otomatis dalam loop 12 detik. Seluruh elemen bernuansa merah di atas latar hitam.

**Komposisi layer (belakang → depan):**

| Layer | Elemen | Animasi |
|---|---|---|
| 1 | Grid perspektif tipis (garis `#26262C`) | Bergerak maju pelan (parallax) |
| 2 | Radial glow merah `rgba(255,45,61,.25)` | Pulse 6 detik |
| 3 | Partikel titik halus (canvas) | Drift lambat ke atas |
| 4 | **Kartu "Lukisan"** (kanvas bertekstur abstrak) | Float ±6px |
| 5 | **Garis scan merah** menyapu kartu, plus 5 titik mikro bercahaya | Scan 3 detik, titik berkedip berurutan |
| 6 | **Cincin NFC** berdenyut di pojok kartu | Ripple 2 lingkaran bergantian |
| 7 | **Panel telemetri (terminal mono)** | Teks diketik baris demi baris |
| 8 | **Badge hasil** `VERIFIED · 94,8% ≥ 88%` | Muncul dengan scale + glow, lalu loop |

**Urutan loop (storyboard):**

| Detik | Kejadian | Teks terminal |
|---|---|---|
| 0–2 | Cincin NFC berdenyut | `> tap SUN token… AES-128 OK` |
| 2–3.5 | Status tamper | `> tamper loop: INTACT` |
| 3.5–7 | Scan optik, 5 titik mikro menyala satu per satu | `> ekstraksi fitur: serat kanvas, impasto, retakan mikro…` |
| 7–9 | Hitung kemiripan, bar progres merah terisi | `> cosine similarity: 94.8% (ambang 88%)` |
| 9–10.5 | Attestation | `> attestation EIP-712 ditandatangani ✓` |
| 10.5–12 | Badge hijau-merah "VERIFIED" tampil, lalu reset | `> KARYA TERVERIFIKASI ASLI` |

**Kartu pendamping (floating, kanan atas panel):**

```
[ON-CHAIN VERIFIED]                     BASE_L2
"Penangkapan Pangeran Diponegoro"
ERC-721 Token ID ........ #8421
SUN Token ............... Valid (Nonce #8421)
Optical Cosine Score .... 94.8% ≥ 88% PASS
Tamper Seal ............. Intact
Provenance .............. 4 catatan → Inspeksi log
```

**Starter kode (CSS + JS minimal):**

```html
<div class="hero-console" aria-hidden="true">
  <div class="canvas-card"><span class="scan"></span><i class="dot d1"></i><i class="dot d2"></i><i class="dot d3"></i><i class="dot d4"></i><i class="dot d5"></i></div>
  <div class="nfc-ring"></div>
  <pre id="telemetry" class="telemetry"></pre>
  <div id="verdict" class="verdict">VERIFIED · 94,8% ≥ 88%</div>
</div>
```

```css
.hero-console{position:relative;border:1px solid var(--line);border-radius:28px;
  background:radial-gradient(60% 60% at 70% 20%,rgba(255,45,61,.22),transparent 70%),var(--bg-1);
  overflow:hidden;padding:24px}
.canvas-card{position:relative;height:220px;border-radius:16px;overflow:hidden;
  background:repeating-linear-gradient(45deg,#1b1b20 0 6px,#141418 6px 12px);animation:float 6s ease-in-out infinite}
.scan{position:absolute;left:0;right:0;height:2px;background:var(--red-500);
  box-shadow:0 0 24px 6px rgba(255,45,61,.7);animation:scan 3s linear infinite}
.dot{position:absolute;width:10px;height:10px;border-radius:50%;background:var(--red-500);
  box-shadow:0 0 14px var(--red-500);animation:blink 1.6s infinite}
.d1{top:18%;left:20%}.d2{top:40%;left:68%;animation-delay:.3s}.d3{top:62%;left:35%;animation-delay:.6s}
.d4{top:28%;left:48%;animation-delay:.9s}.d5{top:76%;left:78%;animation-delay:1.2s}
.nfc-ring{position:absolute;top:28px;right:28px;width:40px;height:40px;border-radius:50%;
  border:2px solid var(--red-500);animation:ripple 2s infinite}
.telemetry{margin-top:16px;font:13px/1.7 var(--font-mono);color:var(--red-300);min-height:140px}
.verdict{margin-top:12px;display:inline-block;padding:8px 14px;border-radius:999px;
  border:1px solid var(--ok);color:var(--ok);opacity:0;transform:scale(.9);animation:verdict 12s infinite}
@keyframes scan{0%{top:0}100%{top:100%}}
@keyframes blink{0%,100%{opacity:.2}50%{opacity:1}}
@keyframes ripple{0%{transform:scale(.8);opacity:1}100%{transform:scale(2.2);opacity:0}}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-6px)}}
@keyframes verdict{0%,85%{opacity:0;transform:scale(.9)}90%,98%{opacity:1;transform:scale(1)}100%{opacity:0}}
@media (prefers-reduced-motion:reduce){*{animation:none!important}}
```

```js
const lines = [
  "> tap SUN token… AES-128 OK",
  "> tamper loop: INTACT",
  "> ekstraksi fitur: serat, impasto, retakan mikro…",
  "> cosine similarity: 94.8% (ambang 88%)",
  "> attestation EIP-712 ditandatangani ✓",
  "> KARYA TERVERIFIKASI ASLI"
];
const el = document.getElementById("telemetry");
let i = 0;
(function typeNext(){
  el.textContent = i === 0 ? "" : el.textContent;
  if (i >= lines.length) { setTimeout(()=>{ i = 0; el.textContent=""; typeNext(); }, 2500); return; }
  el.textContent += lines[i++] + "\n";
  setTimeout(typeNext, 1500);
})();
```

> Aksesibilitas: hero console dekoratif (`aria-hidden`), hormati `prefers-reduced-motion`, kontras teks minimal 4.5:1.

---

## 4. Marquee Teknologi (di bawah hero)

Teks berjalan pelan, mono, uppercase, abu redup, pemisah `·` merah:

`BASE L2 (OP STACK) · ERC-721 + EIP-712 ESCROW · ARWEAVE + IPFS · COINBASE SMART WALLET (PASSKEY) · SAFE MULTISIG · TAMPER-EVIDENT SUBSTRATE · NTAG 424 DNA`

---

## 5. [P] PROBLEM

**Eyebrow:** `// MASALAH`

**H2:**
> Pasar seni bernilai miliaran dolar.
> Pondasi verifikasinya rapuh.

**Paragraf (mono):**
> Keaslian karya seni masih dibuktikan dengan selembar kertas, tanda tangan basah, dan catatan galeri. Semuanya berada *di luar* karya itu sendiri.

**4 kartu masalah (grid 2×2 atau 4 kolom):**

| Kode | Judul | Deskripsi |
|---|---|---|
| `ERR_01` | Sertifikat kertas mudah dipalsukan | Dokumen tidak terikat secara kriptografis pada objek fisiknya. Bisa dicetak ulang, hilang, atau dimanipulasi. |
| `ERR_02` | Tag NFC biasa bisa dikloning | Tag konvensional mengirim isi yang sama di setiap pemindaian. Salinannya valid selamanya. |
| `ERR_03` | Riwayat kepemilikan terputus | Penjualan luring berpindah tangan tanpa jejak yang bisa diaudit. |
| `ERR_04` | NFT terpisah dari lukisannya | Token hanya menunjuk ke gambar digital, bukan ke objek fisik. NFT bisa dijual tanpa lukisannya. |

**Transisi (satu baris, tebal):**
> Dan yang paling mahal bukan pemalsuannya. Yang paling mahal adalah *tidak bisa membuktikan sebaliknya.*

---

## 6. [A] AGITATE

**Eyebrow:** `// DAMPAK`

**H2:**
> Satu karya palsu cukup untuk merusak segalanya.

**Skenario berbasis peran (3 kartu, nada emosional tapi faktual):**

| Peran | Copy |
|---|---|
| **Kolektor** | Anda membayar mahal di pasar sekunder. Tiga tahun kemudian, sertifikatnya diragukan, dan tidak ada cara objektif untuk membuktikan lukisan itu asli. Nilainya menguap. |
| **Seniman** | Karya Anda dipalsukan dan dijual atas nama Anda. Anda tidak menerima royalti dari penjualan ulang, dan reputasi bertahun-tahun ikut dipertaruhkan. |
| **Galeri / Balai Lelang** | Satu kasus karya palsu bisa menggerus kepercayaan klien. Anda menanggung risiko perantara tanpa alat verifikasi yang bisa diperiksa siapa pun. |

**Pernyataan penekan (callout merah):**
> Selama bukti keaslian bisa dicetak ulang, dikloning, atau dihilangkan, setiap transaksi seni adalah pertaruhan kepercayaan.

**Mini-CTA (tautan teks merah):** `Ada cara yang lebih baik →` *(scroll ke bagian Solusi)*

---

## 7. [S] SOLUTION

**Eyebrow:** `// SOLUSI`

**H2:**
> Tiga lapis proteksi.
> Tanpa titik kegagalan tunggal.

**Sub (mono):**
> Bahkan jika satu lapisan dirusak, dua lapisan lainnya tetap mampu membuktikan keaslian lukisan secara independen.

**Tiga kartu akordeon / tab (L01–L03):**

### L01 · Hardware: NTAG 424 DNA + Substrat Tamper-Evident
- Setiap kali chip ditempel dengan ponsel (tap), chip menghasilkan **token dinamis sekali pakai** (AES-128, Secure Unique NFC Message).
- URL yang disalin atau dikloning **ditolak** pada pemindaian berikutnya.
- Chip ditanam pada substrat tamper-evident: jika dicabut atau dipindah ke karya tiruan, sirkuit antena terputus.
- Badge: `NXP NTAG 424 DNA · AES-128 · ISO/IEC 14443-A`

### L02 · Sidik Jari Optik Mikro: AI Vector & Cosine Similarity
- 5–10 titik mikro pada lukisan dipindai: serat kanvas, retakan mikro, ketebalan cat.
- Diubah menjadi **Genesis Feature Vector**; hash-nya dicatat di NFT.
- Verifikasi lanjutan memakai kemiripan kosinus dengan **ambang ≥ 88%**, toleran terhadap penuaan alami.
- Foto cetak 2D tidak memiliki kedalaman serat dan impasto yang sama.

### L03 · Blockchain: Base L2 + ERC-721 + Penyimpanan Terdesentralisasi
- Identitas karya dicatat sebagai NFT ERC-721 yang terikat pada chip fisik.
- Riwayat verifikasi, transfer, dan restorasi tersimpan **append-only** dan dapat diaudit publik.
- Vektor penuh dan sertifikat disimpan di Arweave/IPFS; ringkasan berkala di-anchor ke Ethereum Mainnet.

**Callout "Kenapa aman?" (kotak merah tipis):**
> Smart contract tidak menjalankan AI dan tidak menyimpan kunci rahasia. Ia hanya menerima **attestation EIP-712** dari Protocol Node yang sah, lalu memeriksa tanda tangan, batas waktu, nonce sekali pakai, dan ambang 88%.

---

## 8. Cara Kerja (End-to-End Lifecycle)

**Eyebrow:** `// ALUR KERJA`
**H2:** `Dari kanvas seniman hingga kolektor berikutnya.`

Stepper horizontal 6 langkah (klik atau gunakan tombol panah):

| # | Tahap | Deskripsi singkat |
|---|---|---|
| 01 | **Registrasi** | Galeri/Verifier terakreditasi memindai titik mikro, memasang chip tamper-evident, lalu mencetak NFT genesis ke wallet seniman. |
| 02 | **Pembelian** | Pembeli mengunci dana di escrow. NFT dan dana tidak bisa dicurangi pihak mana pun. |
| 03 | **Pengiriman** | Lukisan fisik dikirim ke pembeli. |
| 04 | **Verifikasi (Tap Claim)** | Pembeli menempelkan ponsel ke chip. Jika token valid, NFT berpindah ke pembeli dan dana dirilis ke penjual, dengan royalti otomatis ke seniman. |
| 05 | **Restorasi** | Konservator terakreditasi menambahkan log kondisi baru tanpa menghapus data genesis. |
| 06 | **Resale** | Pembeli berikutnya dapat mengaudit seluruh riwayat sebelum membayar. |

**Garis jaminan di bawah stepper:**
> Data genesis bersifat permanen. Transaksi tidak bisa dibatalkan atau ditulis ulang oleh pihak mana pun.

**CTA di tengah halaman (strip horizontal):**
> **Siap membuktikan keaslian karya Anda?** `[ Daftar Gratis → ]`  `Sudah punya akun? Masuk`

---

## 9. Angka Besar (Big Number Stats)

Empat kolom, angka dalam Plus Jakarta Sans 56–72px, merah dengan glow, counter animasi.

| Angka | Label (mono) |
|---|---|
| **3 Lapis** | Hardware + AI optik + blockchain Base L2 |
| **≥ 88%** | Ambang kemiripan serat mikro kanvas |
| **~$0,02** | Estimasi biaya audit keaslian di Base L2* |
| **100%** | Catatan kepemilikan append-only permanen |

<sub>*Indikatif, asumsi ETH $2.350. Biaya bergerak mengikuti harga ETH dan kepadatan jaringan.</sub>

---

## 10. Untuk Siapa? (6 Peran + Hak Akses)

**H2:** `Enam peran. Satu kebenaran yang terdesentralisasi.`
**Sub:** `Setiap pihak memegang kunci dan tanggung jawab kriptografis masing-masing.`

Grid kartu 3×2 (label peran kecil merah di pojok, judul putih, deskripsi mono):

| Peran | Tagline | Deskripsi | Akses |
|---|---|---|---|
| **Seniman** (Creator) | Pembuat karya asli | Menandatangani otentisitas awal secara gasless dan menerima royalti 5% di setiap penjualan ulang. | Passkey Wallet |
| **Galeri Tersertifikasi** (Verifier) | Pihak ketiga independen | Memindai mikro, memasang chip tamper-evident, dan mencetak NFT genesis. | Safe Multisig |
| **Kolektor** (Collector) | Pemilik sah fisik + NFT | Membayar lewat escrow, memverifikasi dengan satu tap, menyimpan atau menjual kembali. | Smart Wallet (Mobile) |
| **Konservator** (Conservator) | Restorer terakreditasi | Memperbarui kondisi fisik karya setelah restorasi tanpa menghapus data genesis. | `updateCondition()` |
| **Pembeli Sekunder** | Auditor pasar | Mengaudit provenance lengkap sebelum membayar. | Audit publik |
| **Arthentic Node** | Infrastruktur protokol | Memvalidasi token NFC dan kemiripan optik, lalu menerbitkan attestation. | Signer EIP-712 |

**Tautan di bawah grid:** `Lihat peran Anda → Daftar sebagai Seniman / Galeri / Kolektor`

---

## 11. Demo: Simulasi Audit Keaslian (id="demo")

**Eyebrow:** `// LAB TELEMETRI INTERAKTIF`
**H2:** `Simulasi audit keaslian.`
**Sub:** `Rasakan bagaimana Arthentic memverifikasi karya phygital dalam dua langkah.`

**Layout dua kolom:**

| Kiri (kontrol) | Kanan (terminal) |
|---|---|
| **Langkah 1: Hardware** → tombol `[ SIMULASIKAN TAP NFC ]` | Terminal gelap dengan log mono (merah/abu) |
| **Langkah 2: AI Biometrik** → tombol `[ PINDAI SERAT KANVAS ]` | Hasil akhir: `VERIFIED · COSINE SIMILARITY 94,8% ≥ 88%` |
| `Reset simulasi` | Badge hijau "ASLI" |

**CTA di bawah demo:**
> Ini baru simulasi. Verifikasi karya Anda yang sebenarnya hanya butuh satu tap. `[ Mulai Gratis → ]`

---

## 12. Biaya Transparan

**Eyebrow:** `// BIAYA`
**H2:** `Verifikasi berulang yang masuk akal secara ekonomi.`
**Sub:** `Dibangun di Base L2, bukan Ethereum L1, sehingga biaya tidak menghalangi pemeriksaan rutin.`

| Aksi | Estimasi biaya |
|---|---|
| Mint karya baru (Genesis) | ~$0,04–$0,05 |
| Verifikasi Level 1 (NFC) | ~$0,01–$0,02 |
| Verifikasi Level 2 (optik) | ~$0,02–$0,03 |
| Update restorasi | ~$0,02–$0,03 |
| Transfer kepemilikan | ~$0,02–$0,03 |

**Highlight:** *100 pemeriksaan keaslian ≈ $2,20.* Gas untuk pengguna akhir disponsori paymaster.

<sub>Sumber: dokumen Arthentic Cost Estimation. Angka indikatif (asumsi ETH $2.350).</sub>

---

## 13. Kepercayaan & Keamanan

**H2:** `Dirancang dengan asumsi bahwa penyerang itu ada.`

Grid 2×3 poin keamanan singkat:

| Ancaman | Perlindungan Arthentic |
|---|---|
| Serangan replay | Nonce sekali pakai, deadline pendek, domain separator EIP-712 |
| Reentrancy pada escrow | Pola checks-effects-interactions + `nonReentrant` |
| Kunci Node bocor | Kunci di HSM, penanda tangan bergilir, `pause()` darurat, pencabutan role cepat |
| Salah konfigurasi role | Admin via multisig + timelock |
| Pemalsuan fisik (cetak foto, chip dicabut) | Verifikasi optik + chip tamper-evident + token SUN |
| Pengguna awam kehilangan akses | Passkey (tanpa seed phrase) dengan pemulihan iCloud/Google Keychain |

**Baris kredibilitas:**
`Berbasis OpenZeppelin · Uji unit & fuzzing · Analisis statis (Slither) · Audit pihak ketiga sebelum mainnet · Rilis bertahap di Base Sepolia`

> Jujur soal status: tampilkan label **"Tahap pengembangan / testnet"** di footer kredibilitas sampai audit selesai.

---

## 14. FAQ

| Pertanyaan | Jawaban |
|---|---|
| **Apakah saya harus paham crypto?** | Tidak. Anda masuk dengan passkey (Face ID / Touch ID), tanpa seed phrase. Biaya gas untuk verifikasi disponsori. |
| **Bagaimana jika chip NFC rusak?** | Keaslian tetap dibuktikan lewat verifikasi optik. Penggantian chip hanya berhasil dengan bukti optik ≥ 88% dan persetujuan tiga pihak (Kolektor, Verifier, Seniman). |
| **Apakah chip bisa disalin?** | Chip menghasilkan token dinamis sekali pakai. URL yang disalin ditolak pada pemindaian berikutnya. |
| **Bagaimana jika lukisan dipulas atau direstorasi?** | Konservator terakreditasi menambahkan log kondisi baru. Data genesis tidak pernah dihapus. |
| **Bagaimana jika karya hancur atau hilang?** | Pemilik mengajukan bukti (berita acara/klaim asuransi) dan status karya ditandai hancur, sehingga NFT tidak bisa dijual di pasar sekunder. |
| **Apakah royalti seniman otomatis?** | Ya, lewat standar ERC-2981 pada setiap penjualan ulang. |
| **Di jaringan apa Arthentic berjalan?** | Base (Ethereum L2 berbasis OP Stack), dengan anchor Merkle root berkala ke Ethereum Mainnet. |

---

## 15. CTA FINAL (Section Penutup)

**Latar:** gradient merah gelap ke hitam, glow besar di tengah, grid halus.

**H2 (besar, tengah):**
> Keaslian bukan lagi soal percaya.
> **Ini soal bukti.**

**Sub:**
> Bergabunglah sebagai seniman, galeri, kolektor, atau konservator, dan mulai membangun riwayat karya yang tidak bisa ditulis ulang.

**Tombol:**

| Tombol | Label | Tujuan |
|---|---|---|
| Primer (besar, glow) | **Daftar Gratis Sekarang →** | `/signup` |
| Sekunder | **Masuk ke Akun Saya** | `/login` |

**Microcopy:**
`Tanpa seed phrase · Login dengan passkey · Gas disponsori untuk verifikasi`

---

## 16. Footer

```
[◆ ARTHENTIC]  Protokol otentikasi phygital untuk karya seni fisik.

Produk            Pelajari          Legal              Akun
Cara Kerja        Dokumentasi       Kebijakan Privasi  Masuk
Simulasi          Keamanan          Syarat Layanan     Daftar Gratis
Biaya             FAQ               

© 2026 Arthentic. Dibangun di atas Base L2.   [Status: Testnet / Pre-audit]
```

---

## 17. Spesifikasi Halaman Auth (Sign Up & Login)

Gaya sama dengan landing: dark, form di kartu tengah, glow merah di belakang. Dua kolom di desktop (kiri: form, kanan: mini animasi scan), satu kolom di mobile.

### 17.1 Sign Up (`/signup`)

**H1:** `Buat akun Arthentic`
**Sub:** `Mulai dalam kurang dari satu menit. Tanpa seed phrase.`

| Elemen | Detail |
|---|---|
| Tombol utama | `[ 🔑 Daftar dengan Passkey (Face ID / Touch ID) ]` |
| Alternatif | `[ Lanjutkan dengan Google ]`, `[ Lanjutkan dengan Email ]` |
| Pilih peran | Dropdown/chip: Seniman · Galeri/Verifier · Kolektor · Konservator · Pembeli Sekunder |
| Catatan peran | "Peran Galeri dan Konservator memerlukan verifikasi akreditasi oleh tim Arthentic." |
| Checkbox | `Saya setuju dengan Syarat Layanan dan Kebijakan Privasi` |
| Tautan bawah | `Sudah punya akun? Masuk` |

**Catatan UX:** wallet (Coinbase Smart Wallet, ERC-4337) dibuat otomatis di balik layar. Tampilkan satu kalimat penjelas: *"Kami membuat dompet aman untuk Anda. Tidak ada kata sandi 12 kata yang perlu dihafal."*

### 17.2 Login (`/login`)

**H1:** `Selamat datang kembali`
**Sub:** `Masuk untuk memverifikasi, menjual, atau mengelola karya Anda.`

| Elemen | Detail |
|---|---|
| Tombol utama | `[ 🔑 Masuk dengan Passkey ]` |
| Alternatif | `[ Google ]`, `[ Email ]`, `[ Sambungkan MetaMask ]` *(cadangan)* |
| Bantuan | `Kehilangan akses? Pulihkan lewat iCloud / Google Keychain` |
| Tautan bawah | `Belum punya akun? Daftar gratis` |

**Pesan error (ramah):** `Kami tidak bisa memverifikasi passkey Anda. Coba lagi atau gunakan metode lain.`

---

## 18. Peta CTA (Ringkasan Penempatan)

| Lokasi | CTA Sign Up | CTA Login |
|---|---|---|
| Navbar (sticky) | Daftar Gratis → | Masuk |
| Hero | Daftar Gratis → | Masuk |
| Setelah "Agitate" | `Ada cara yang lebih baik →` (scroll) | — |
| Setelah "Cara Kerja" | Daftar Gratis → | Sudah punya akun? Masuk |
| Setelah Demo | Mulai Gratis → | — |
| Section "Untuk Siapa" | Daftar sebagai [peran] | — |
| CTA Final | Daftar Gratis Sekarang → | Masuk ke Akun Saya |
| Footer | Daftar Gratis | Masuk |
| Mobile sticky bar (bawah) | Daftar Gratis | Masuk |

---

## 19. Rekomendasi Teknis Implementasi

| Aspek | Saran |
|---|---|
| Framework | Next.js / Astro + Tailwind CSS |
| Animasi | CSS keyframes untuk hero; Framer Motion / GSAP untuk scroll-reveal; canvas ringan untuk partikel |
| Performa | LCP < 2,5 dtk; lazy-load section di bawah fold; animasi hanya `transform` dan `opacity` |
| Aksesibilitas | Kontras ≥ 4.5:1, fokus terlihat, `prefers-reduced-motion`, alt text pada visual |
| SEO | `<title>` : "Arthentic: Otentikasi & Provenance Karya Seni Fisik di Blockchain"; meta description ≤ 155 karakter |
| Analitik | Lacak klik CTA (signup/login), scroll depth, penyelesaian demo |
| A/B test awal | Variasi H1 hero; label CTA "Daftar Gratis" vs "Mulai Verifikasi" |

**Meta description (usulan):**
`Arthentic mengikat lukisan fisik ke identitas digital sulit dipalsukan lewat chip NFC anti-kloning, sidik jari optik AI, dan blockchain Base L2. Daftar gratis.`

---

## 20. Catatan untuk Tim

1. Laporan menulis "Authentic" di satu tempat; draft ini konsisten memakai **Arthentic**.
2. Semua angka biaya dan ambang 88% perlu diberi label "indikatif" selama belum divalidasi uji lapangan (sesuai saran laporan poin 5.2 #5).
3. Hindari klaim absolut ("100% anti-palsu"). Gunakan "sulit dipalsukan" dan "dapat dibuktikan".
4. Tampilkan status **testnet / pre-audit** secara jujur sampai audit independen selesai.
5. Aset visual yang perlu disiapkan: logo vektor, mockup kanvas abstrak (bukan karya berhak cipta), ikon chip NFC, favicon merah.
