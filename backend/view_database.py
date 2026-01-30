"""
Script untuk melihat isi database diagnosis_history.db
"""
import database

print("=" * 50)
print("DATABASE VIEWER - Diagnosis History")
print("=" * 50)

# Get all diagnoses
history = database.get_all_diagnoses()
print(f"\nTotal records: {len(history)}\n")

if history:
    print("-" * 50)
    for h in history:
        print(f"ID: {h['id']}")
        print(f"  Jenis Batuk: {h['jenis_batuk']}")
        print(f"  Confidence: {h['confidence']:.2%}")
        print(f"  Tingkat: {h['tingkat_kondisi']}")
        print(f"  Waktu: {h['created_at']}")
        if h['rekomendasi_obat']:
            print(f"  Rekomendasi: {len(h['rekomendasi_obat'])} obat")
        print("-" * 50)
else:
    print("(Belum ada data diagnosa)")

# Statistics
print("\n" + "=" * 50)
print("STATISTIK")
print("=" * 50)
stats = database.get_statistics()
print(f"Total Diagnosa: {stats['total_diagnoses']}")
print(f"Rata-rata Confidence: {stats['average_confidence']:.2%}")
print(f"Per Jenis: {stats['by_type']}")
