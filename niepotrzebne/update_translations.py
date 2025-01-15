import json
import os

# Ścieżki do plików tłumaczeń
files = {
    "en": os.path.join("assets", "i18n", "en.json"),
    "pl": os.path.join("assets", "i18n", "pl.json"),
}

# Funkcja sprawdzająca, czy pliki istnieją
def check_files_exist(files):
    for lang, path in files.items():
        if not os.path.exists(path):
            print(f"File not found: {path}")
            raise FileNotFoundError(f"Translation file for '{lang}' not found at {path}")

# Sprawdzenie istnienia plików
try:
    check_files_exist(files)
except FileNotFoundError as e:
    print(e)
    exit(1)

# Odczytanie istniejących tłumaczeń
translations = {lang: json.load(open(path, encoding="utf-8")) for lang, path in files.items()}

# Klucze z kodu
keys_in_code = {
    "editBox": "Edit Box",
    "deleteBoxConfirmation": "Are you sure you want to delete this box?",
    "deleteBoxMessage": "This action cannot be undone.",
    "delete": "Delete",
    "addBox": "Add Box",
    "boxName": "Box Name",
    "boxTypeParts": "Parts",
    "boxTypeSets": "Sets",
    "boxTypeForSale": "For Sale",
    "cancel": "Cancel",
    "save": "Save",
}

# Dodanie brakujących kluczy
def add_missing_keys(translations, keys_in_code):
    for lang, lang_translations in translations.items():
        for key, value in keys_in_code.items():
            if key not in lang_translations:
                lang_translations[key] = value if lang == "en" else ""

add_missing_keys(translations, keys_in_code)

# Zapisanie plików tłumaczeń
def save_translations(files, translations):
    for lang, path in files.items():
        with open(path, "w", encoding="utf-8") as f:
            json.dump(translations[lang], f, indent=4, ensure_ascii=False)

save_translations(files, translations)

print("Pliki tłumaczeń zostały uzupełnione.")
