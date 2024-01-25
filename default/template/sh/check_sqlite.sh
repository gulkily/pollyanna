#!/bin/bash

# Check for multi-line data in a SQLite database
# Usage: ./check_sqlite.sh <sqlite_database>
# Example: ./check_sqlite.sh ./cache/b/index.sqlite3
#
# Pollyanna is designed so that the SQLite index database does not store any multi-line data
# If a multi-line piece of data is necessary, it is stored in a separate file
# This script checks for multi-line data in the SQLite database
#
# This script was hastily written with the aid of ChatGPT, and that's why
# it uses python3 and sqlite package as a dependency.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <sqlite_database>"
    exit 1
fi

database="$1"

# Check for multi-line data using a Python script
result=$(python3 - <<EOF
import sqlite3

database = "$database"
conn = sqlite3.connect(database)
cursor = conn.cursor()

# Get list of tables in the database
tables = cursor.execute("SELECT name FROM sqlite_master WHERE type='table';").fetchall()

for table in tables:
    print(f"Checking table: {table[0]}")
    
    # Get list of columns in the table
    columns = cursor.execute(f"PRAGMA table_info({table[0]});").fetchall()
    
    for column in columns:
        column_name = column[1]
        print(f"Checking column: {column_name}")
        
        # Check for multi-line data in the column
        result = cursor.execute(f"SELECT {column_name} FROM {table[0]};").fetchall()
        
        for row in result:
            if any('\n' in str(cell) or '\r' in str(cell) for cell in row):
                print(f"Error: Multi-line data found in table {table[0]}, column {column_name}")
                exit(1)

print("No multi-line data found in the database.")
EOF
)

echo "$result"
