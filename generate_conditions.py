import csv
import json
from collections import defaultdict

# Mapping dataset symptoms to app IDs
symptom_map = {
    'Appetite Loss': 'loss_of_appetite',
    'Appetite_Loss': 'loss_of_appetite',
    'Loss of Appetite': 'loss_of_appetite',
    'Coughing': 'coughing',
    'Dehydration': 'dehydration',
    'Diarrhea': 'diarrhea',
    'Eye Discharge': 'eye_discharge',
    'Eye_Discharge': 'eye_discharge',
    'Fever': 'fever',
    'Labored Breathing': 'rapid_breathing',
    'Labored_Breathing': 'rapid_breathing',
    'Lameness': 'limping',
    'Lethargy': 'lethargy',
    'Nasal Discharge': 'runny_nose',
    'Nasal_Discharge': 'runny_nose',
    'Skin Lesions': 'red_bumps_on_skin',
    'Skin_Lesions': 'red_bumps_on_skin',
    'Sneezing': 'sneezing',
    'Swelling': 'swollen_lymph_nodes',
    'Vomiting': 'vomiting',
    'Weight Loss': 'weight_loss',
    'Weight_Loss': 'weight_loss'
}

# Consolidate overlapping diseases
disease_map = {
    'Canine Parvovirus': 'Parvovirus',
    'Canine Distemper': 'Distemper',
    'Canine Infectious Hepatitis': 'Canine Hepatitis',
    'Canine Leptospirosis': 'Leptospirosis',
    'Canine Influenza': 'Canine Flu',
    'Canine Cough': 'Kennel Cough',
    'Bordetella Infection': 'Kennel Cough',
    'Canine Heartworm Disease': 'Heartworm Disease'
}

# Default severity and advice for known diseases
severity_map = {
    'Parvovirus': ('critical', 'Seek emergency veterinary care immediately. Parvovirus is life-threatening and requires IV fluids and intensive supportive care.'),
    'Distemper': ('critical', 'This is a medical emergency. Rush to the vet immediately. Distemper is highly contagious and can be fatal without aggressive treatment.'),
    'Kennel Cough': ('moderate', 'Keep your dog isolated from other dogs. Most cases resolve within 1–3 weeks. Visit your vet if symptoms worsen or persist beyond a week.'),
    'Gastroenteritis': ('moderate', 'Withhold food for 12–24 hours, then reintroduce a bland diet. If vomiting or diarrhea persists beyond 24 hours, see your vet.'),
    'Tick-Borne Disease': ('serious', 'See your vet for blood work and antibiotic treatment. Remove any visible ticks and start a tick prevention plan.'),
    'Canine Hepatitis': ('serious', 'Requires immediate veterinary attention. Keep your dog isolated and comfortable.'),
    'Leptospirosis': ('serious', 'Requires antibiotics and supportive care from your vet. Can be transmitted to humans, so handle with care.'),
    'Canine Flu': ('moderate', 'Keep your dog isolated and well-hydrated. Consult your vet if breathing becomes labored.'),
    'Chronic Bronchitis': ('moderate', 'Requires long-term management with your vet, often involving cough suppressants or anti-inflammatories.'),
    'Pancreatitis': ('serious', 'Visit your vet promptly. Treatment includes fasting, IV fluids, and a long-term low-fat diet.'),
    'Lyme Disease': ('serious', 'Consult your vet for antibiotics and tick prevention strategies. Joint pain may persist.'),
    'Arthritis': ('moderate', 'Consult your vet about pain management options. Keep your dog at a healthy weight and provide joint supplements if recommended.'),
    'Heartworm Disease': ('serious', 'Requires intensive veterinary treatment. Prevention is the best approach.'),
    'Allergic Rhinitis': ('mild', 'Identify and minimize exposure to allergens. Your vet may prescribe antihistamines.')
}

with open('./PawPing/animal_disease_prediction.csv', 'r') as f:
    reader = csv.DictReader(f)
    dogs = [row for row in reader if row['Animal_Type'] == 'Dog']

disease_counts = defaultdict(int)
disease_symptoms = defaultdict(lambda: defaultdict(int))

for row in dogs:
    raw_disease = row['Disease_Prediction'].strip()
    disease = disease_map.get(raw_disease, raw_disease)
    
    disease_counts[disease] += 1
    
    # Text symptoms
    for i in range(1, 5):
        sym = row.get(f'Symptom_{i}', '').strip()
        if sym and sym.lower() != 'no':
            mapped_sym = symptom_map.get(sym, sym)
            disease_symptoms[disease][mapped_sym] += 1
            
    # Boolean symptoms
    bool_symptoms = ['Appetite_Loss', 'Vomiting', 'Diarrhea', 'Coughing', 
                     'Labored_Breathing', 'Lameness', 'Skin_Lesions', 
                     'Nasal_Discharge', 'Eye_Discharge']
    for b_sym in bool_symptoms:
        if row.get(b_sym, '').lower() == 'yes':
            mapped_sym = symptom_map.get(b_sym, b_sym)
            disease_symptoms[disease][mapped_sym] += 1

output_data = []

for disease, count in disease_counts.items():
    symptoms_list = []
    for sym, freq in disease_symptoms[disease].items():
        # Calculate weight: frequency of symptom / total cases of disease
        weight = round(freq / count, 2)
        # Cap at 1.0 just in case
        weight = min(weight, 1.0)
        
        # Only include significant symptoms (e.g. > 20% occurrence)
        if weight > 0.2:
            symptoms_list.append({
                "name": sym,
                "weight": weight
            })
            
    # Sort symptoms by weight descending
    symptoms_list.sort(key=lambda x: x['weight'], reverse=True)
    
    sev_adv = severity_map.get(disease, ('moderate', 'Consult your veterinarian for proper diagnosis and treatment options.'))
    
    condition_id = disease.lower().replace(' ', '_').replace('-', '_')
    
    output_data.append({
        "id": condition_id,
        "name": disease,
        "symptoms": symptoms_list,
        "severity": sev_adv[0],
        "advice": sev_adv[1]
    })

# Output to JSON
out_path = './PawPing/Care Tab/Models/dog_conditions.json'
with open(out_path, 'w') as f:
    json.dump(output_data, f, indent=2)

print(f"Generated {len(output_data)} diseases and saved to {out_path}")
