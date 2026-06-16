#!/usr/bin/env python3
"""
Generate breed_exercise.json from the Kaggle CSV dataset.
Converts 'Exercise Requirements (hrs/day)' → minutes and outputs a JSON lookup.
"""

import csv
import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(SCRIPT_DIR, "PawPing", "Dog Breads Around The World.csv")
OUTPUT_PATH = os.path.join(SCRIPT_DIR, "PawPing", "breed_exercise.json")

DEFAULT_MINUTES = 60  # Fallback when data is missing

def main():
    breed_exercise = {}

    with open(CSV_PATH, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get("Name", "").strip()
            hrs_raw = row.get("Exercise Requirements (hrs/day)", "").strip()

            if not name:
                continue

            try:
                hrs = float(hrs_raw)
                minutes = int(round(hrs * 60))
            except (ValueError, TypeError):
                minutes = DEFAULT_MINUTES

            breed_exercise[name] = minutes

    # Sort alphabetically for readability
    sorted_data = dict(sorted(breed_exercise.items()))

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(sorted_data, f, indent=2, ensure_ascii=False)

    print(f"✅ Generated {OUTPUT_PATH}")
    print(f"   Total breeds: {len(sorted_data)}")

    # Print some stats
    values = list(sorted_data.values())
    print(f"   Min exercise: {min(values)} min")
    print(f"   Max exercise: {max(values)} min")
    print(f"   Avg exercise: {sum(values) / len(values):.0f} min")

if __name__ == "__main__":
    main()
