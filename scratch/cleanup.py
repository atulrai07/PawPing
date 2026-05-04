import os
import shutil

path = "/Users/sidmoon/Downloads/PawPing-develop-atul/PawPing/Activity Tab/Symptom Checker"
if os.path.exists(path):
    shutil.rmtree(path)
    print(f"Deleted {path}")
else:
    print(f"{path} does not exist")
