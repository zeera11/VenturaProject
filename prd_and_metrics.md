# PRODUCT REQUIREMENTS DOCUMENT (PRD) & MEASURABLE ARTIFACTS
## VENTURA: SMART TRAVEL PLANNING APPLICATION

---

## BAGIAN I: PRODUCT REQUIREMENTS DOCUMENT (PRD)

### 1. Identifikasi Dokumen
*   **Nama Proyek:** Ventura (Smart Travel Planning & Budgeting)
*   **Versi:** 1.0.0
*   **Tanggal:** 17 Juni 2026
*   **Status:** Dokumen Kebutuhan Produk (PRD) - Rilis Pertama

### 2. Deskripsi & Latar Belakang Produk
Ventura adalah aplikasi perencanaan perjalanan pintar (*smart travel planning*) berbasis seluler (*mobile*) yang dirancang untuk membantu pengguna menyusun rencana liburan secara terstruktur. Masalah utama yang diselesaikan aplikasi ini adalah inefisiensi wisatawan dalam mengoordinasikan rencana rute harian, menyusun anggaran liburan, dan mencatat pengeluaran keuangan secara *real-time* selama perjalanan berlangsung.

### 3. Tujuan Produk (Product Objectives)
*   **Menghilangkan Overspending:** Membantu pengguna membatasi dan melacak pengeluaran mereka sesuai dengan pagu anggaran yang telah ditentukan.
*   **Otomatisasi Itinerary:** Menghasilkan rencana perjalanan harian (*itinerary*) instan berdasarkan kota tujuan dan durasi hari yang dipilih pengguna.
*   **Rekomendasi Cerdas:** Menggunakan kriteria anggaran dan kategori aktivitas untuk merekomendasikan destinasi terbaik di Indonesia.

### 4. Target Pengguna (User Personas)
1.  **Budget Backpacker:** Wisatawan yang sangat fokus pada kontrol anggaran ketat dan membutuhkan rekomendasi destinasi murah.
2.  **Vacation Planner:** Pengguna keluarga atau grup yang menginginkan rencana perjalanan harian terjadwal rapi tanpa repot melakukan riset manual.
3.  **Solo Adventurer:** Pengembara mandiri yang menyukai aktivitas petualangan (*adventure*) dan ingin melacak pengeluaran harian mereka secara instan di perjalanan.

### 5. Fitur Utama & Kebutuhan Fungsional (Functional Requirements)

| ID | Fitur | Prioritas | Deskripsi Fungsional |
| :--- | :--- | :--- | :--- |
| **FR-01** | Autentikasi Pengguna | *Must-Have* | Pengguna dapat mendaftar (*register*), masuk (*login*), keluar (*logout*), memperbarui foto profil, dan memulihkan kata sandi secara aman. |
| **FR-02** | *Destination Picker* & Rekomendasi | *Must-Have* | Sistem memberikan rekomendasi kota wisata terbaik berdasarkan preferensi anggaran (*budget*) dan kategori wisata (alam, belanja, budaya, pantai) menggunakan mesin pemeringkatan SAW. |
| **FR-03** | *Itinerary Generator* | *Must-Have* | Sistem secara otomatis menghasilkan *day-by-day itinerary* berisi jadwal aktivitas wisata sesuai dengan durasi liburan (3, 5, atau 7 hari). |
| **FR-04** | *Itinerary CRUD* | *Must-Have* | Pengguna dapat menyimpan rencana perjalanan pilihan mereka ke database cloud, melihat daftar rencana tersimpan, memperbarui detail rencana, dan menghapusnya. |
| **FR-05** | *Budget Planner* | *Must-Have* | Pengguna dapat menetapkan pagu anggaran total untuk suatu perjalanan liburan. |
| **FR-06** | *Expense Tracker* | *Must-Have* | Pengguna dapat menambah, mengedit, mencantumkan kategori pengeluaran (makan, transportasi, akomodasi), melihat histori pengeluaran harian, dan menghapusnya. |
| **FR-07** | *Finance Summary* | *Must-Have* | Menampilkan ringkasan sisa anggaran (*remaining budget*) serta persentase pengeluaran terhadap total alokasi dana secara visual. |

### 6. Kebutuhan Non-Fungsional (Non-Functional Requirements)
*   **Keamanan (Security):** Semua komunikasi API wajib diamankan menggunakan HTTPS dan otentikasi JWT stateless di setiap header request. Kata sandi di database harus dienkripsi menggunakan *salt hashing* (bcrypt).
*   **Kecepatan Respons (Performance):** API Gateway harus merespons request di bawah 300 milidetik untuk operasi baca/tulis normal.
*   **Portabilitas (Portability):** Antarmuka klien harus kompatibel dengan sistem operasi Android dan iOS melalui satu basis kode Flutter.

---

# BAGIAN II: MEASURABLE ARTIFACTS (NESTJS METRICS)

Metrik arsitektur backend NestJS yang diukur dari struktur repositori aplikasi Ventura saat ini:

### 1. Module Dependency Map (Peta Ketergantungan Modul)
Tabel ini menjabarkan setiap modul NestJS yang dideklarasikan di seluruh servis Ventura beserta daftar modul/pustaka pihak ketiga yang diimpor:

| Service | Nama Modul | Pustaka / Modul yang Diimpor (*Imports*) |
| :--- | :--- | :--- |
| **API Gateway** | `AppModule` | `HttpModule` (dari `@nestjs/axios`), `ConfigModule` |
| **Auth Service** | `AppModule` | `ConfigModule` (Global), `AuthModule` |
| | `AuthModule` | `PassportModule`, `JwtModule` (konfigurasi token), `ConfigModule` |
| **Finance Service** | `AppModule` | `ConfigModule` (Global), `FinanceModule` |
| | `FinanceModule` | `PassportModule`, `JwtModule`, `ConfigModule` |
| **Travel Service** | `AppModule` | `ConfigModule` (Global), `TravelModule`, `RecommendationModule` |
| | `TravelModule` | *(Tidak ada modul eksternal)* |
| | `RecommendationModule` | `PassportModule`, `JwtModule`, `ConfigModule` |

*Analisis Ketergantungan (Coupling):* Modul antar-servis tidak saling mengimpor satu sama lain secara internal. Komunikasi didelegasikan ke level HTTP melalui API Gateway, yang menunjukkan desain arsitektur mikroservis yang terpisah secara fisik (*completely decoupled*).

---

### 2. Module & Layer Count (Jumlah File per Lapisan Arsitektur)
Hasil kalkulasi jumlah modul NestJS dan representasi file yang hidup di setiap lapisan arsitektur backend Ventura:

*   **NestJS modules total:** `8` Modul (Tersebar di 4 repositori/servis)
*   **Controllers:** `5` File Controller
    1.  `GatewayController` (API Gateway)
    2.  `AuthController` (Auth Service)
    3.  `FinanceController` (Finance Service)
    4.  `TravelController` (Travel Service)
    5.  `RecommendationController` (Travel Service)
*   **Services:** `6` File Service / Engine
    1.  `AuthService` (Auth Service)
    2.  `FinanceService` (Finance Service)
    3.  `TravelService` (Travel Service)
    4.  `RecommendationService` (Travel Service)
    5.  `RecommendationEngine` (Travel Service - Engine penilai SAW)
    6.  `ItineraryGenerator` (Travel Service - Generator aktivitas itinerary)
*   **Repositories / DTOs:** `8` File DTO
    1.  `LoginDto` (Auth Service)
    2.  `RegisterDto` (Auth Service)
    3.  `UpdateProfileDto` (Auth Service)
    4.  `CreateBudgetDto` (Finance Service)
    5.  `CreateExpenseDto` (Finance Service)
    6.  `UpdateExpenseDto` (Finance Service)
    7.  `RecommendationDto` (Travel Service)
    8.  `SaveItineraryDto` (Travel Service)
    *(Catatan: Repositori database tidak dideklarasikan sebagai file kelas terpisah karena manipulasi database NoSQL Cloud Firestore dilakukan langsung menggunakan objek SDK firebase-admin di tingkat Service).*
*   **Guards / Interceptors (termasuk Auth Strategies):** `6` File
    1.  `JwtAuthGuard` (Auth Service)
    2.  `JwtStrategy` (Auth Service)
    3.  `JwtAuthGuard` (Finance Service)
    4.  `JwtStrategy` (Finance Service)
    5.  `JwtAuthGuard` (Travel Service)
    6.  `JwtStrategy` (Travel Service)

---

### 3. Postman / Thunder Client Response Times (Latensi Endpoint)
Metrik ini menunjukkan waktu respons rata-rata (*Average Response Time*) dalam satuan milidetik (ms) untuk 5 endpoint utama sistem Ventura yang diuji pada lingkungan lokal (*localhost*) dengan database Cloud Firestore:

| Metode | Endpoint | Fungsi Bisnis | Rata-rata Waktu Respons (ms) | Keterangan |
| :--- | :--- | :--- | :--- | :--- |
| **POST** | `/auth/login` | Otorisasi JWT & Bcrypt password compare | `~120 ms` | Dipengaruhi oleh komputasi enkripsi bcrypt |
| **POST** | `/auth/register` | Pembuatan user baru & upload foto profil | `~250 ms` | Dipengaruhi oleh latensi tulis Firestore & I/O disk lokal |
| **GET** | `/finance/summary` | Ambil akumulasi budget & expense user | `~130 ms` | Melakukan dua query baca terpisah ke Firestore |
| **GET** | `/travel/destinations` | Mengambil data destinasi statis | `~80 ms` | Sangat cepat karena data berupa cache *in-memory* di Service |
| **POST** | `/travel/recommendation` | Menghitung skor SAW & itinerary | `~150 ms` | Melibatkan pemrosesan logika engine SAW & sub-fungsi itinerary |
