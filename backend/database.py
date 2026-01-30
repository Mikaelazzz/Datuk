"""
SQLite Database module for storing cough diagnosis history.
"""
import sqlite3
import json
import os
from datetime import datetime
from typing import List, Dict, Any, Optional

# Database file path
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "diagnosis_history.db")


def get_connection() -> sqlite3.Connection:
    """Get a database connection with row factory for dict-like access."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_database():
    """Initialize the database and create tables if they don't exist."""
    conn = get_connection()
    cursor = conn.cursor()
    
    # Create diagnosis_history table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS diagnosis_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis_batuk TEXT NOT NULL,
            confidence REAL NOT NULL,
            tingkat_kondisi TEXT,
            rekomendasi_obat TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    conn.close()
    print(f"Database initialized at: {DB_PATH}")


def save_diagnosis(
    jenis_batuk: str,
    confidence: float,
    tingkat_kondisi: str = None,
    rekomendasi_obat: List[Dict[str, Any]] = None
) -> int:
    """
    Save a diagnosis result to the database.
    
    Args:
        jenis_batuk: Type of cough (e.g., "Batuk kering", "Batuk berdahak")
        confidence: Confidence score (0.0 - 1.0)
        tingkat_kondisi: Severity level (e.g., "Ringan", "Sedang", "Tingkat Lanjut")
        rekomendasi_obat: List of medicine recommendations as dicts
        
    Returns:
        The ID of the inserted record
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    # Convert recommendations to JSON string
    rekomendasi_json = json.dumps(rekomendasi_obat, ensure_ascii=False) if rekomendasi_obat else None
    
    cursor.execute("""
        INSERT INTO diagnosis_history (jenis_batuk, confidence, tingkat_kondisi, rekomendasi_obat)
        VALUES (?, ?, ?, ?)
    """, (jenis_batuk, confidence, tingkat_kondisi, rekomendasi_json))
    
    record_id = cursor.lastrowid
    conn.commit()
    conn.close()
    
    print(f"Saved diagnosis record with ID: {record_id}")
    return record_id


def get_all_diagnoses(limit: int = 50) -> List[Dict[str, Any]]:
    """
    Get all diagnosis records, most recent first.
    
    Args:
        limit: Maximum number of records to return
        
    Returns:
        List of diagnosis records as dictionaries
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT id, jenis_batuk, confidence, tingkat_kondisi, rekomendasi_obat, created_at
        FROM diagnosis_history
        ORDER BY created_at DESC
        LIMIT ?
    """, (limit,))
    
    rows = cursor.fetchall()
    conn.close()
    
    results = []
    for row in rows:
        record = dict(row)
        # Parse JSON back to list
        if record['rekomendasi_obat']:
            record['rekomendasi_obat'] = json.loads(record['rekomendasi_obat'])
        results.append(record)
    
    return results


def get_diagnosis_by_id(diagnosis_id: int) -> Optional[Dict[str, Any]]:
    """
    Get a specific diagnosis record by ID.
    
    Args:
        diagnosis_id: The ID of the record to retrieve
        
    Returns:
        The diagnosis record as a dictionary, or None if not found
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT id, jenis_batuk, confidence, tingkat_kondisi, rekomendasi_obat, created_at
        FROM diagnosis_history
        WHERE id = ?
    """, (diagnosis_id,))
    
    row = cursor.fetchone()
    conn.close()
    
    if row:
        record = dict(row)
        if record['rekomendasi_obat']:
            record['rekomendasi_obat'] = json.loads(record['rekomendasi_obat'])
        return record
    
    return None


def delete_diagnosis(diagnosis_id: int) -> bool:
    """
    Delete a diagnosis record by ID.
    
    Args:
        diagnosis_id: The ID of the record to delete
        
    Returns:
        True if deleted, False if not found
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("DELETE FROM diagnosis_history WHERE id = ?", (diagnosis_id,))
    deleted = cursor.rowcount > 0
    
    conn.commit()
    conn.close()
    
    return deleted


def get_statistics() -> Dict[str, Any]:
    """
    Get statistics about diagnosis history.
    
    Returns:
        Dictionary with statistics
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    # Total count
    cursor.execute("SELECT COUNT(*) as total FROM diagnosis_history")
    total = cursor.fetchone()['total']
    
    # Count by type
    cursor.execute("""
        SELECT jenis_batuk, COUNT(*) as count 
        FROM diagnosis_history 
        GROUP BY jenis_batuk
    """)
    by_type = {row['jenis_batuk']: row['count'] for row in cursor.fetchall()}
    
    # Average confidence
    cursor.execute("SELECT AVG(confidence) as avg_confidence FROM diagnosis_history")
    avg_confidence = cursor.fetchone()['avg_confidence'] or 0
    
    conn.close()
    
    return {
        "total_diagnoses": total,
        "by_type": by_type,
        "average_confidence": round(avg_confidence, 4)
    }


# Initialize database when module is imported
init_database()
