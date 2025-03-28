# Petunjuk Implementasi untuk Text to Image Edit

Berikut adalah langkah-langkah yang diperlukan untuk mengimplementasikan fitur Text to Image Edit dengan model fal-ai/gemini-flash-edit:

## 1. Buat File utils/imageEditUtils.js

Buat file baru di folder utils dengan nama imageEditUtils.js yang berisi fungsi untuk mengupload hasil edit ke Supabase dan fungsi untuk memanggil API fal.ai.

## 2. Tambahkan Komponen di focus-components.jsx

- Tambahkan import FaEdit dari react-icons/fa
- Tambahkan komponen ImageEditUpload untuk menangani upload gambar
- Tambahkan komponen TextToImageEditPlayer untuk menampilkan hasil edit gambar
- Tambahkan createFocusComponent untuk 'Text to Image Edit'

## 3. Tambahkan Model di model-components.js

- Tambahkan model 'fal-ai/gemini-flash-edit' ke dalam textToImageEditModels
- Ekspor textToImageEditModels

## 4. Tambahkan Fokus di focus-selector.jsx

- Tambahkan import TextToImageEdit
- Tambahkan 'Text to Image Edit' di categoryModels
- Tambahkan ke daftar focusComponents

## 5. Perbarui App.jsx

- Tambahkan state uploadedImageForEdit, editedImageUrl, dan isEditingImage
- Tambahkan case Text to Image Edit di getPlaceholderText
- Tambahkan penanganan untuk updateModelsForFocus
- Tambahkan kondisi untuk menampilkan ImageEditUpload dan TextToImageEditPlayer
- Tambahkan logika penanganan untuk Text to Image Edit di handleSubmit

## Implementasi Kode Lengkap

Untuk melihat implementasi kode lengkap, lihat cabang git 'text-to-image-edit'.
