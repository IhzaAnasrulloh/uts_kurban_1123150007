# Pengembang
 * Ihza Anasrullah Bil Haq
 * 1123150007
 * TI SE P1 23
 * Teknik Informatika
 * Software Engineering 
 * [Link-Youtube-presentation](https://www.youtube.com/)

# UTS Kurban

> Aplikasi mobile pemesanan hewan kurban berbasis Flutter.
> UTS Kurban memudahkan pengguna dalam mencari, memasukkan ke keranjang, dan melakukan *checkout* pembelian hewan kurban dengan integrasi sistem pembayaran eksternal (Kurban Connect / Dompet Kampus Global) melalui sistem *Deep Link*.

---

## Tampilan Aplikasi

### Splash Screen
*(Screenshot Splash Screen)*

### Dashboard Kurban
*(Screenshot Dashboard Kurban)*

### Keranjang & Checkout
*(Screenshot Keranjang & Checkout)*

### Histori & Status Pembayaran
*(Screenshot Histori Pembayaran)*

---

## Fitur Utama

### 🛒 Pemesanan Kurban
- **Dashboard Katalog**: Menampilkan daftar hewan kurban (sapi, kambing, domba) beserta harga dan detailnya.
- **Keranjang Belanja**: Menambah produk ke keranjang, mengubah jumlah (*quantity*), dan menghitung total harga secara *real-time*.
- **Checkout**: Form pengisian alamat pengiriman, catatan khusus, dan pemilihan metode pembayaran.

### 💳 Integrasi Pembayaran (Deep Link)
- **Kurban Connect**: Pembayaran terintegrasi langsung dengan E-Wallet menggunakan *Deep Link*.
- **Custom Callback URI**: Menangkap *intent* `pasarmalam://payment-callback/callback` dari E-Wallet untuk mengkonfirmasi status pembayaran.
- **Auto-Clear Cart**: Keranjang akan otomatis dikosongkan ketika pembayaran via E-Wallet dinyatakan berhasil.

### 📜 Histori & Status
- **Halaman Status**: Menampilkan status keberhasilan atau kegagalan transaksi secara *real-time* setelah kembali dari E-Wallet.
- **Histori Pembelian**: Mencatat seluruh pesanan yang berhasil lengkap dengan urutan kode resi (1, 2, 3, dst.), total pembayaran, dan rincian *item*.

---

## Teknologi

| Kategori | Teknologi |
|---|---|
| **Framework** | Flutter 3.x (Dart SDK) |
| **State Management** | Provider (ChangeNotifier) |
| **Navigasi** | Material Page Route & Named Routes |
| **Integrasi Pembayaran** | app_links, url_launcher |
| **Local Storage** | Shared Preferences (opsional/tergantung *CartRepository*) |
| **Animasi & UI** | Material Design, Custom Widgets |

---

## Susunan Project

```
uts_kurban_1123150007/
├── android/                        # Konfigurasi Android (Manifest intent-filter app links)
├── lib/
│   ├── core/                       # Layer inti aplikasi
│   │   ├── routes/                 #   AppRouter (Pengatur rute dan deep link parsing)
│   │   └── services/               #   KurbanConnectService (Pengirim & Pembangun URL deeplink)
│   │
│   ├── features/                   # Fitur-fitur utama aplikasi
│   │   ├── auth/                   #   Fitur Autentikasi & Dashboard
│   │   │   └── presentation/       #     DashboardPage (Katalog & navigasi atas)
│   │   │
│   │   ├── cart/                   #   Fitur Keranjang
│   │   │   └── presentation/       #     CartProvider, CartPage
│   │   │
│   │   └── order/                  #   Fitur Checkout & Histori
│   │       ├── presentation/
│   │       │   ├── pages/          #     CheckoutPage, HistoryPage, PaymentPendingPage
│   │       │   │                   #     PaymentCallbackHandlerPage, OrderSuccessPage
│   │       │   └── providers/      #     HistoryProvider
│   │
│   └── main.dart                   # Entry point aplikasi & Inisialisasi Provider
│
├── pubspec.yaml                    # Konfigurasi dependencies
└── README.md                       # Dokumentasi project
```

---

## Penggunaan

### Alur Pemesanan Normal

```
Dashboard Kurban (Pilih Hewan)
    ↓
Tambah ke Keranjang
    ↓
Buka Keranjang → Checkout
    ↓
Isi Alamat & Catatan
    ↓
Pilih Metode "Kurban Connect" → Buat Pesanan
```

### Alur Pembayaran via Deep Link

```
Halaman "Menunggu Pembayaran"
    ↓
Klik "Buka Kurban Connect"
    ↓
Aplikasi melompat ke E-Wallet (dompetkampus://pay?...)
    ↓
Selesaikan Pembayaran (Isi PIN & TOTP) di E-Wallet
    ↓
Klik "Selesai" di E-Wallet
    ↓
Aplikasi kembali ke Kurban (pasarmalam://payment-callback/callback)
    ↓
Halaman Sukses & Histori Ditambahkan (Keranjang Kosong)
```
