import csv

with open('./PawPing/animal_disease_prediction.csv', 'r') as f:
    reader = csv.DictReader(f)
    dogs = [row for row in reader if row['Animal_Type'] == 'Dog']

symptoms = set()
for row in dogs:
    for i in range(1, 5):
        sym = row.get(f'Symptom_{i}', '').strip()
        if sym and sym.lower() != 'no':
            symptoms.add(sym)
    
    bool_symptoms = ['Appetite_Loss', 'Vomiting', 'Diarrhea', 'Coughing', 
                     'Labored_Breathing', 'Lameness', 'Skin_Lesions', 
                     'Nasal_Discharge', 'Eye_Discharge']
    for b_sym in bool_symptoms:
        if row.get(b_sym, '').lower() == 'yes':
            symptoms.add(b_sym.replace('_', ' '))

print("All unique symptoms in dataset:")
for s in sorted(list(symptoms)):
    print(s)
