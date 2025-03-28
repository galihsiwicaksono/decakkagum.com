-- Kebijakan retensi untuk dokumen (60 hari)
-- Fungsi untuk menghapus dokumen yang lebih lama dari 60 hari

-- Pertama, tambahkan kolom last_accessed_at jika belum ada
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'documents' 
    AND column_name = 'last_accessed_at'
  ) THEN
    ALTER TABLE documents ADD COLUMN last_accessed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;
    
    -- Update nilai awal last_accessed_at ke updated_at
    UPDATE documents SET last_accessed_at = updated_at;
  END IF;
END $$;

-- Buat fungsi untuk memperbarui last_accessed_at
CREATE OR REPLACE FUNCTION update_document_access_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_accessed_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Buat trigger untuk memperbarui last_accessed_at saat dokumen dibuka
DO $$
BEGIN
  DROP TRIGGER IF EXISTS update_last_accessed_timestamp ON documents;
  
  CREATE TRIGGER update_last_accessed_timestamp
  BEFORE UPDATE ON documents
  FOR EACH ROW
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE PROCEDURE update_document_access_timestamp();
END $$;

-- Fungsi untuk menghapus dokumen yang lebih lama dari 60 hari
CREATE OR REPLACE FUNCTION delete_old_documents()
RETURNS void AS $$
BEGIN
  -- Hapus dokumen yang tidak diakses selama 60 hari
  DELETE FROM documents
  WHERE last_accessed_at < CURRENT_TIMESTAMP - INTERVAL '60 days';
  
  -- Log aktivitas
  INSERT INTO audit_logs (action, table_name, description)
  VALUES ('DELETE', 'documents', 'Dokumen yang lebih tua dari 60 hari dihapus oleh sistem');
  
  EXCEPTION WHEN OTHERS THEN
    -- Tangani error dengan mencatat ke log
    INSERT INTO audit_logs (action, table_name, description)
    VALUES ('ERROR', 'documents', 'Gagal menghapus dokumen lama: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- Buat fungsi yang akan dijalankan oleh trigger
CREATE OR REPLACE FUNCTION trigger_delete_old_documents()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM delete_old_documents();
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Periksa apakah tabel audit_logs ada, jika tidak maka buat
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'audit_logs') THEN
    CREATE TABLE audit_logs (
      id SERIAL PRIMARY KEY,
      action TEXT NOT NULL,
      table_name TEXT NOT NULL,
      description TEXT,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );
  END IF;
END $$;

-- Buat atau perbarui trigger yang berjalan setiap hari pada tengah malam
DO $$
BEGIN
  -- Drop trigger jika sudah ada
  DROP TRIGGER IF EXISTS daily_cleanup_documents ON documents;
  
  -- Buat cron trigger (diperlukan ekstensi pg_cron)
  -- Periksa jika ekstensi pg_cron sudah diinstal
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    -- Hapus jadwal yang mungkin sudah ada
    PERFORM cron.unschedule(job_id) 
    FROM cron.job 
    WHERE command LIKE '%delete_old_documents%';
    
    -- Buat jadwal cron untuk menjalankan fungsi setiap hari pada tengah malam
    PERFORM cron.schedule('0 0 * * *', 'SELECT delete_old_documents()');
  ELSE
    -- Jika pg_cron tidak tersedia, gunakan trigger biasa yang akan dijalankan pada setiap operasi
    CREATE TRIGGER daily_cleanup_documents
    AFTER INSERT OR UPDATE ON documents
    EXECUTE PROCEDURE trigger_delete_old_documents();
  END IF;
END $$; 