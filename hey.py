import json
from opencc import OpenCC

# Step 1: Load idioms.json
with open('idioms.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Step 2: Initialize converter
cc = OpenCC('s2t')  # Simplified to Traditional

# Step 3: Convert target fields and add _tr variants
fields_to_convert = ['description', 'chineseExample']

for entry in data:
    for field in fields_to_convert:
        if field in entry:
            entry[f"{field}_tr"] = cc.convert(entry[field])

# Step 4: Save result to a new file
with open('idioms_with_tr.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("✅ Traditional fields added and saved to idioms_with_tr.json")
