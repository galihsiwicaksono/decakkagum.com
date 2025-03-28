# Migrasi Database

File-file SQL di direktori ini berisi migrasi database untuk aplikasi Ratu AI.

## Kebijakan Retensi Dokumen

File `document_retention_policy.sql` berisi kebijakan untuk menghapus dokumen yang lebih tua dari 60 hari secara otomatis. Ini membantu menjaga performa database dan mengurangi biaya penyimpanan.

## Cara Menjalankan Migrasi

1. Login ke dashboard Supabase: https://app.supabase.io
2. Pilih proyek Ratu AI
3. Klik "SQL Editor" di sidebar
4. Klik "New Query"
5. Salin dan tempel isi file migrasi SQL
6. Klik "Run" untuk menjalankan migrasi

## Catatan Penting

- Untuk kebijakan retensi dokumen berfungsi dengan optimal, disarankan untuk mengaktifkan ekstensi `pg_cron` di database Supabase Anda. Jika tidak, trigger alternatif akan digunakan tetapi kurang efisien.
- Pastikan untuk membuat backup database sebelum menjalankan migrasi yang memodifikasi struktur data.
- Selalu uji migrasi di lingkungan pengembangan sebelum menerapkannya di produksi.

## Mengaktifkan pg_cron (Untuk Admin Database)

Untuk mengaktifkan ekstensi pg_cron, jalankan perintah berikut di SQL Editor:

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

Kemudian jalankan kembali migrasi kebijakan retensi dokumen. 