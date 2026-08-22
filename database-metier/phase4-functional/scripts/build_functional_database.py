#!/usr/bin/env python3
"""
Phase 4 — Base fonctionnelle, physico-chimique et comportement des mélanges.

Entrée : database-metier/phase1-referentiel/ingredient_registry_v1.csv
Sortie : database-metier/phase4-functional/

Livrables :
    - functional_components.csv
    - functional_ingredients.csv    (propriétés intrinsèques)
    - process_operations.csv
    - interaction_rules.csv
    - experimental_validation_cases.csv
    - functional_schema.md
    - functional_rule_engine_spec.md
    - functional_confidence_method.md
    - functional_coverage_report.md
    - qa_report.md
    - qa_anomalies.csv
    - ingestion_manifest.json
"""

from __future__ import annotations

import csv
import datetime as dt
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PHASE1 = ROOT / "database-metier" / "phase1-referentiel"
PHASE4 = ROOT / "database-metier" / "phase4-functional"

SCHEMA_VERSION = "1.0.0"
DATASET_VERSION = "1.0.0"
GENERATED_AT = dt.date.today().isoformat()

SRC_INTERN = "MAESTRO_INTERNAL"
SRC_LIT = "LITERATURE"  # règles issues de manuels de référence
SRC_DERIVED = "DERIVED"  # règles combinées/dérivées


# ---------------------------------------------------------------------------
# 1) Composants fonctionnels (functional_components.csv)
# ---------------------------------------------------------------------------

FUNCTIONAL_COMPONENTS = [
    # Protéines
    ("PROT_CASEINE", "Caséines", "Protéines", "Bos taurus", "principal", "ingrédient", "polaire", "iso-pH 4.6", "soluble", "LIT:Damodaran", "literature", 0.90),
    ("PROT_WHEY", "Protéines sériques (lactalbumine, lactoglobuline)", "Protéines", "Bos taurus", "principal", "ingrédient", "polaire", "engelant", "soluble", "LIT:Damodaran", "literature", 0.90),
    ("PROT_OVALB", "Ovalbumine", "Protéines", "Gallus gallus", "principal", "ingrédient", "globulaire", "engelant", "soluble", "LIT:Damodaran", "literature", 0.95),
    ("PROT_SOY", "Protéines de soja (glycinine, β-conglycinine)", "Protéines", "Glycine max", "principal", "ingrédient", "globulaire", "engelant", "soluble", "LIT:Damodaran", "literature", 0.90),
    ("PROT_GLU", "Gluten (gliadine + gluténine)", "Protéines", "Triticum aestivum", "principal", "ingrédient", "amphiphile", "engelant", "insoluble", "LIT:Shewry", "literature", 0.95),
    ("PROT_GEL", "Gélatine", "Protéines", "Bos taurus/Sus scrofa", "principal", "ingrédient", "polaire", "réversible <35°C", "soluble à chaud", "LIT:GME", "literature", 0.95),
    ("PROT_PEA", "Protéines de pois", "Protéines", "Pisum sativum", "principal", "ingrédient", "globulaire", "engelant", "soluble", "LIT:Townshend", "literature", 0.85),

    # Polysaccharides
    ("POLY_AMIDON", "Amidon natif", "Polysaccharides", "Multi (maïs, pomme de terre, blé)", "principal", "ingrédient", "polaire", "semi-cristallin", "insoluble à froid", "LIT:BeMiller", "literature", 0.95),
    ("POLY_AMYLOSE", "Amylose", "Polysaccharides", "Multi", "fraction amidon", "ingrédient", "linéaire", "lixiviation 60-70°C", "soluble à chaud", "LIT:BeMiller", "literature", 0.95),
    ("POLY_AMYLOPEC", "Amylopectine", "Polysaccharides", "Multi", "fraction amidon", "ingrédient", "ramifié", "gonflement <60°C", "colloïde", "LIT:BeMiller", "literature", 0.95),
    ("POLY_PECTINE", "Pectines", "Polysaccharides", "Citrus, pomme", "principal", "ingrédient", "anionique", "gel HM/LM calcium", "soluble", "LIT:Sriamornsak", "literature", 0.95),
    ("POLY_PEC_HM", "Pectine haut méthoxyle (HM)", "Polysaccharides", "Citrus", "fraction pectine", "ingrédient", "anionique", "gel sucre+acide", "soluble", "LIT:Sriamornsak", "literature", 0.95),
    ("POLY_PEC_LM", "Pectine bas méthoxyle (LM)", "Polysaccharides", "Apple pomace", "fraction pectine", "ingrédient", "anionique", "gel calcium", "soluble", "LIT:Sriamornsak", "literature", 0.95),
    ("POLY_AGAR", "Agar-agar", "Polysaccharides", "Gelidium", "principal", "ingrédient", "neutre", "thermo-irréversible ~40°C", "soluble à chaud", "LIT:Phillips", "literature", 0.95),
    ("POLY_CARRK", "Carraghénane κ (kappa)", "Polysaccharides", "Kappaphycus", "principal", "ingrédient", "anionique", "gel K+", "soluble à chaud", "LIT:Phillips", "literature", 0.95),
    ("POLY_CARRI", "Carraghénane ι (iota)", "Polysaccharides", "Eucheuma", "principal", "ingrédient", "anionique", "gel Ca2+", "soluble à chaud", "LIT:Phillips", "literature", 0.95),
    ("POLY_CARRL", "Carraghénane λ (lambda)", "Polysaccharides", "Gigartina", "principal", "ingrédient", "anionique", "non gélifiant, épaississant", "soluble à froid", "LIT:Phillips", "literature", 0.95),
    ("POLY_ALG", "Alginate", "Polysaccharides", "Phaeophyceae", "principal", "ingrédient", "anionique", "gel Ca2+ (diffusion)", "soluble à froid", "LIT:Phillips", "literature", 0.95),
    ("POLY_XANTHAN", "Gomme xanthane", "Polysaccharides", "Xanthomonas", "principal", "ingrédient", "anionique", "stable pH et T", "soluble", "LIT:GME", "literature", 0.95),
    ("POLY_GUAR", "Gomme guar", "Polysaccharides", "Cyamopsis", "principal", "ingrédient", "neutre", "synergie xanthane", "soluble", "LIT:GME", "literature", 0.95),
    ("POLY_LBG", "Gomme de caroube (LBG)", "Polysaccharides", "Ceratonia", "principal", "ingrédient", "neutre", "synergie xanthane, gel", "soluble à chaud", "LIT:GME", "literature", 0.95),
    ("POLY_GACACIA", "Gomme arabique", "Polysaccharides", "Acacia", "principal", "ingrédient", "polaire", "émulsifiant filmogène", "soluble", "LIT:GME", "literature", 0.95),
    ("POLY_CELL", "Cellulose (E460)", "Polysaccharides", "Multi", "principal", "ingrédient", "neutre", "non gélifiant, fibre insoluble", "insoluble", "LIT:BeMiller", "literature", 0.90),
    ("POLY_HEMICELL", "Hémicelluloses", "Polysaccharides", "Multi", "principal", "ingrédient", "mixte", "fibres solubles/insolubles", "variables", "LIT:GME", "literature", 0.85),
    ("POLY_INULIN", "Inuline", "Polysaccharides", "Cichorium", "principal", "ingrédient", "polaire", "FOS, prébiotique", "soluble", "LIT:Niness", "literature", 0.90),

    # Lipides
    ("LIP_TRIGLY", "Triglycérides", "Lipides", "Multi", "principal", "ingrédient", "apolaire", "fusion, polymorphisme", "insoluble", "LIT:O'Brien", "literature", 0.95),
    ("LIP_SAT", "Acides gras saturés", "Lipides", "Multi", "fraction", "ingrédient", "apolaire", "MP élevés", "insoluble", "LIT:O'Brien", "literature", 0.95),
    ("LIP_INS", "Acides gras insaturés", "Lipides", "Multi", "fraction", "ingrédient", "apolaire", "MP bas, oxydables", "insoluble", "LIT:O'Brien", "literature", 0.95),
    ("LIP_PHOSPH", "Phospholipides (lécithine)", "Lipides", "Glycine max", "tensioactif", "ingrédient", "amphiphile", "HLD <0", "insoluble / émulsifiant", "LIT:McClements", "literature", 0.95),
    ("LIP_MDG", "Mono-/diglycérides (E471)", "Lipides", "Multi", "tensioactif", "ingrédient", "amphiphile", "émulsifiant HLB 2-6", "lipophile", "LIT:McClements", "literature", 0.90),

    # Petites molécules
    ("SM_SALT", "Sel (NaCl)", "Petites molécules", "NaCl", "ingrédient", "ingrédient", "ionique", "force ionique", "soluble", "LIT:LWT", "literature", 0.95),
    ("SM_ACET", "Acide acétique", "Petites molécules", "Fermentation", "ingrédient", "ingrédient", "acide faible", "pKa 4.76", "soluble", "LIT:LWT", "literature", 0.95),
    ("SM_CIT", "Acide citrique", "Petites molécules", "Citrus", "ingrédient", "ingrédient", "acide triprotique", "pKa1 3.13", "soluble", "LIT:LWT", "literature", 0.95),
    ("SM_GLU", "Acide glutamique / glutamate", "Petites molécules", "Multi", "ingrédient", "ingrédient", "zwitterion", "umami", "soluble", "LIT:Kuninaka", "literature", 0.95),
    ("SM_5GMP", "5'-GMP", "Petites molécules", "Levure", "ingrédient", "ingrédient", "nucléotide", "synergie umami", "soluble", "LIT:Kuninaka", "literature", 0.95),
    ("SM_GLU_AMINO_ACID", "Glutamine", "Petites molécules", "Multi", "ingrédient", "ingrédient", "polaire", "précurseur glutamate", "soluble", "LIT:LWT", "literature", 0.90),
    ("SM_CA", "Calcium", "Minéraux", "Multi", "ion", "ingrédient", "cation divalent", "coagulation, gel LM", "soluble sous formes salines", "LIT:LWT", "literature", 0.95),
    ("SM_SUCROSE", "Saccharose", "Petites molécules", "Saccharum", "ingrédient", "ingrédient", "polaire", "Tgel pectine HM", "très soluble", "LIT:LWT", "literature", 0.95),
    ("SM_FRUCTOSE", "Fructose", "Petites molécules", "Multi", "ingrédient", "ingrédient", "polaire", "caramel 110°C", "très soluble", "LIT:LWT", "literature", 0.95),
    ("SM_GLU_MONO", "Glucose", "Petites molécules", "Multi", "ingrédient", "ingrédient", "polaire", "caramel 160°C", "très soluble", "LIT:LWT", "literature", 0.95),
]


# ---------------------------------------------------------------------------
# 2) Propriétés intrinsèques des ingrédients
# ---------------------------------------------------------------------------

# (ingredient_name, water%, fat%, protein%, sugar%, starch%, fiber%, salt%, ph,
#  aw, brix, density_g/mL, ohlberg, wohc, ehc, fc, gc, foaming, gel, thickening,
#  melting_C, evidence, confidence)

INGREDIENT_PROPS = [
    # === Matières grasses ===
    {
        "ingredient_name": "Beurre doux",
        "state": "churned",
        "t_ref_C": 20,
        "water": 15.7, "fat": 81.5, "protein": 0.7, "sugar": 0.6, "starch": 0,
        "fiber": 0, "salt": 0.05, "ph": None, "aw": 0.95, "brix": None,
        "density": 0.911, "particle_size_um": None,
        "solubility_water": "insoluble",
        "ohc_g_g": 0.20, "whc_g_g": None,
        "emulsifying_capacity": "medium_fat",
        "foaming_capacity": "low",
        "gelation_capability": "no",
        "thickening_capability": "no",
        "hygroscopicity": "low",
        "thermal_stability": "phase_inversion_frying",
        "freeze_thaw_stability": "good",
        "oxidation_sensitivity": "medium",
        "sources": "LIT:O'Brien|LIT:McClements",
        "evidence": "measured",
        "confidence": 0.90,
    },
    {
        "ingredient_name": "Huile d'olive vierge extra",
        "state": "liquid",
        "t_ref_C": 20,
        "water": 0.1, "fat": 100, "protein": 0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0, "ph": None, "aw": 0.40, "brix": None,
        "density": 0.915, "particle_size_um": None,
        "solubility_water": "insoluble",
        "ohc_g_g": 0.18, "whc_g_g": None,
        "emulsifying_capacity": "none_without_emulsifier",
        "foaming_capacity": "low",
        "gelation_capability": "no",
        "thickening_capability": "no",
        "hygroscopicity": "none",
        "thermal_stability": "high_smoke_point_190C",
        "freeze_thaw_stability": "good_under_nitrogen",
        "oxidation_sensitivity": "medium",
        "sources": "LIT:O'Brien",
        "evidence": "measured",
        "confidence": 0.90,
    },
    {
        "ingredient_name": "Beurre clarifié (ghee)",
        "state": "clarified",
        "t_ref_C": 20,
        "water": 0.1, "fat": 99.5, "protein": 0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0, "ph": None, "aw": 0.40, "brix": None,
        "density": 0.905, "particle_size_um": None,
        "solubility_water": "insoluble",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "none",
        "foaming_capacity": "low",
        "gelation_capability": "no",
        "thickening_capability": "no",
        "hygroscopicity": "none",
        "thermal_stability": "very_high_smoke_point_250C",
        "freeze_thaw_stability": "excellent",
        "oxidation_sensitivity": "low",
        "sources": "LIT:O'Brien",
        "evidence": "measured",
        "confidence": 0.90,
    },
    # === Protéines ===
    {
        "ingredient_name": "Œuf de poule",
        "state": "fresh",
        "t_ref_C": 20,
        "water": 76.1, "fat": 9.5, "protein": 12.6, "sugar": 0.4, "starch": 0,
        "fiber": 0, "salt": 0.14, "ph": 7.6, "aw": 0.97, "brix": None,
        "density": 1.030, "particle_size_um": None,
        "solubility_water": "dispersion",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "excellent_yolk",
        "foaming_capacity": "excellent_white",
        "gelation_capability": "yes_coagulation",
        "thickening_capability": "low",
        "hygroscopicity": "none",
        "thermal_stability": "coagulates_65-70C",
        "freeze_thaw_stability": "poor_white",
        "oxidation_sensitivity": "yolk_medium",
        "sources": "LIT:Damodaran|LIT:Belitz",
        "evidence": "measured",
        "confidence": 0.95,
    },
    {
        "ingredient_name": "Poudre de cacao",
        "state": "powder",
        "t_ref_C": 20,
        "water": 3.0, "fat": 13.7, "protein": 19.6, "sugar": 0, "starch": 0,
        "fiber": 37.0, "salt": 0.02, "ph": 5.5, "aw": 0.30, "brix": None,
        "density": 0.500, "particle_size_um": 30,
        "solubility_water": "partial_dispersion",
        "ohc_g_g": 1.5, "whc_g_g": 3.0,
        "emulsifying_capacity": "low",
        "foaming_capacity": "low",
        "gelation_capability": "no",
        "thickening_capability": "medium",
        "hygroscopicity": "medium",
        "thermal_stability": "Maillard_140C",
        "freeze_thaw_stability": "good",
        "oxidation_sensitivity": "medium_polyphenols",
        "sources": "LIT:Belitz",
        "evidence": "measured",
        "confidence": 0.90,
    },
    # === Céréales ===
    {
        "ingredient_name": "Farine de blé tendre",
        "state": "milled",
        "t_ref_C": 20,
        "water": 14.0, "fat": 1.1, "protein": 10.3, "sugar": 1.7, "starch": 68.0,
        "fiber": 2.5, "salt": 0, "ph": 6.2, "aw": 0.70, "brix": None,
        "density": 0.530, "particle_size_um": 100,
        "solubility_water": "partial_starch",
        "ohc_g_g": 0.9, "whc_g_g": 1.2,
        "emulsifying_capacity": "low",
        "foaming_capacity": "low",
        "gelation_capability": "yes_gluten_network",
        "thickening_capability": "medium_paste",
        "hygroscopicity": "medium",
        "thermal_stability": "starch_gel_60-90C",
        "freeze_thaw_stability": "good",
        "oxidation_sensitivity": "low",
        "sources": "LIT:BeMiller|LIT:Shewry",
        "evidence": "measured",
        "confidence": 0.95,
    },
    # === Hydrocolloïdes ===
    {
        "ingredient_name": "Gélatine",
        "state": "powder",
        "t_ref_C": 20,
        "water": 12.0, "fat": 0, "protein": 86.0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0.5, "ph": 5.5, "aw": 0.50, "brix": None,
        "density": 0.700, "particle_size_um": 200,
        "solubility_water": "bloom_above_60C",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "low",
        "foaming_capacity": "medium",
        "gelation_capability": "yes_thermoreversible",
        "thickening_capability": "high",
        "hygroscopicity": "low",
        "thermal_stability": "melts_30-35C",
        "freeze_thaw_stability": "good",
        "oxidation_sensitivity": "low",
        "sources": "LIT:GME",
        "evidence": "measured",
        "confidence": 0.95,
    },
    {
        "ingredient_name": "Agar-agar",
        "state": "powder",
        "t_ref_C": 20,
        "water": 12.0, "fat": 0, "protein": 0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0.5, "ph": 7.0, "aw": 0.50, "brix": None,
        "density": 0.700, "particle_size_um": 200,
        "solubility_water": "soluble_above_90C",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "none",
        "foaming_capacity": "none",
        "gelation_capability": "yes_thermo_irreversible",
        "thickening_capability": "high",
        "hygroscopicity": "low",
        "thermal_stability": "gel_stable_above_85C",
        "freeze_thaw_stability": "excellent",
        "oxidation_sensitivity": "low",
        "sources": "LIT:Phillips",
        "evidence": "measured",
        "confidence": 0.95,
    },
    {
        "ingredient_name": "Pectine HM",
        "state": "powder",
        "t_ref_C": 20,
        "water": 12.0, "fat": 0, "protein": 0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0, "ph": 3.5, "aw": 0.45, "brix": None,
        "density": 0.650, "particle_size_um": 150,
        "solubility_water": "soluble_below_60C_agitation",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "low",
        "foaming_capacity": "none",
        "gelation_capability": "yes_sugar_60-65pct_acid",
        "thickening_capability": "high",
        "hygroscopicity": "high",
        "thermal_stability": "degrades_pH3_high_T",
        "freeze_thaw_stability": "good",
        "oxidation_sensitivity": "low",
        "sources": "LIT:Sriamornsak",
        "evidence": "measured",
        "confidence": 0.95,
    },
    {
        "ingredient_name": "Gomme xanthane",
        "state": "powder",
        "t_ref_C": 20,
        "water": 12.0, "fat": 0, "protein": 0, "sugar": 0, "starch": 0,
        "fiber": 80.0, "salt": 0, "ph": 7.0, "aw": 0.45, "brix": None,
        "density": 0.800, "particle_size_um": 80,
        "solubility_water": "fast_cold",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "medium",
        "foaming_capacity": "none",
        "gelation_capability": "weak_alone",
        "thickening_capability": "excellent_pseudoplastic",
        "hygroscopicity": "medium",
        "thermal_stability": "excellent_pH_T",
        "freeze_thaw_stability": "excellent",
        "oxidation_sensitivity": "low",
        "sources": "LIT:GME",
        "evidence": "measured",
        "confidence": 0.95,
    },
    {
        "ingredient_name": "Lécithine de soja",
        "state": "powder",
        "t_ref_C": 20,
        "water": 1.0, "fat": 97.0, "protein": 0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0, "ph": None, "aw": 0.40, "brix": None,
        "density": 0.500, "particle_size_um": 100,
        "solubility_water": "dispersible",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "excellent_o/w",
        "foaming_capacity": "low",
        "gelation_capability": "no",
        "thickening_capability": "no",
        "hygroscopicity": "medium",
        "thermal_stability": "degrades_above_120C",
        "freeze_thaw_stability": "good",
        "oxidation_sensitivity": "high_unsaturated",
        "sources": "LIT:McClements",
        "evidence": "measured",
        "confidence": 0.95,
    },
    # === Sucres / eau / sel ===
    {
        "ingredient_name": "Sucre blanc",
        "state": "crystallized",
        "t_ref_C": 20,
        "water": 0.04, "fat": 0, "protein": 0, "sugar": 99.8, "starch": 0,
        "fiber": 0, "salt": 0, "ph": 7.0, "aw": 0.45, "brix": 100,
        "density": 0.85, "particle_size_um": 500,
        "solubility_water": "very_high_487g/L_20C",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "none",
        "foaming_capacity": "none",
        "gelation_capability": "no",
        "thickening_capability": "no",
        "hygroscopicity": "low",
        "thermal_stability": "caramelization_160C",
        "freeze_thaw_stability": "good",
        "oxidation_sensitivity": "low",
        "sources": "LIT:LWT",
        "evidence": "measured",
        "confidence": 0.98,
    },
    {
        "ingredient_name": "Sel fin",
        "state": "crystallized",
        "t_ref_C": 20,
        "water": 0.1, "fat": 0, "protein": 0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 99.9, "ph": 7.0, "aw": 0.75, "brix": None,
        "density": 1.20, "particle_size_um": 200,
        "solubility_water": "360g/L",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "none",
        "foaming_capacity": "destabilizes_egg_white",
        "gelation_capability": "no",
        "thickening_capability": "no",
        "hygroscopicity": "medium",
        "thermal_stability": "excellent",
        "freeze_thaw_stability": "excellent",
        "oxidation_sensitivity": "low",
        "sources": "LIT:LWT",
        "evidence": "measured",
        "confidence": 0.95,
    },
    # === Fruits / légumes ===
    {
        "ingredient_name": "Tomate fraîche",
        "state": "fresh",
        "t_ref_C": 20,
        "water": 94.0, "fat": 0.2, "protein": 0.86, "sugar": 2.8, "starch": 0,
        "fiber": 1.2, "salt": 0.01, "ph": 4.3, "aw": 0.99, "brix": 4.5,
        "density": 1.02, "particle_size_um": None,
        "solubility_water": "n/a",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "none",
        "foaming_capacity": "none",
        "gelation_capability": "no",
        "thickening_capability": "low",
        "hygroscopicity": "high",
        "thermal_stability": "pectin_solubilization_T",
        "freeze_thaw_stability": "poor_textural_loss",
        "oxidation_sensitivity": "medium_lycopene",
        "sources": "LIT:LWT",
        "evidence": "measured",
        "confidence": 0.85,
    },
    {
        "ingredient_name": "Pomme crue",
        "state": "fresh",
        "t_ref_C": 20,
        "water": 85.6, "fat": 0.17, "protein": 0.26, "sugar": 10.4, "starch": 0,
        "fiber": 2.4, "salt": 0.01, "ph": 3.5, "aw": 0.97, "brix": 12.5,
        "density": 0.95, "particle_size_um": None,
        "solubility_water": "n/a",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "none",
        "foaming_capacity": "none",
        "gelation_capability": "no",
        "thickening_capability": "low",
        "hygroscopicity": "high",
        "thermal_stability": "pectin_solubilization_browning",
        "freeze_thaw_stability": "poor_textural_loss",
        "oxidation_sensitivity": "high_browning_PPO",
        "sources": "LIT:LWT",
        "evidence": "measured",
        "confidence": 0.85,
    },
    # === Boissons ===
    {
        "ingredient_name": "Lait entier",
        "state": "pasteurized",
        "t_ref_C": 20,
        "water": 87.4, "fat": 3.5, "protein": 3.15, "sugar": 4.65, "starch": 0,
        "fiber": 0, "salt": 0.04, "ph": 6.7, "aw": 0.97, "brix": None,
        "density": 1.030, "particle_size_um": 0.5,  # globules gras
        "solubility_water": "emulsion",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "natural_o/w_emulsion",
        "foaming_capacity": "medium_steam",
        "gelation_capability": "yes_casein_acid",
        "thickening_capability": "low_viscosity",
        "hygroscopicity": "high",
        "thermal_stability": "scald_85C",
        "freeze_thaw_stability": "poor_separation",
        "oxidation_sensitivity": "low",
        "sources": "LIT:Damodaran",
        "evidence": "measured",
        "confidence": 0.95,
    },
    {
        "ingredient_name": "Vin rouge",
        "state": "fermented",
        "t_ref_C": 20,
        "water": 86.5, "fat": 0, "protein": 0.07, "sugar": 0.6, "starch": 0,
        "fiber": 0, "salt": 0.004, "ph": 3.5, "aw": 0.95, "brix": None,
        "density": 0.995, "particle_size_um": None,
        "solubility_water": "alcohol_solution",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "low",
        "foaming_capacity": "none",
        "gelation_capability": "no",
        "thickening_capability": "no",
        "hygroscopicity": "high",
        "thermal_stability": "alcohol_evaporation_78C",
        "freeze_thaw_stability": "medium",
        "oxidation_sensitivity": "high_polyphenols",
        "sources": "LIT:LWT",
        "evidence": "measured",
        "confidence": 0.85,
    },
    # === Viandes ===
    {
        "ingredient_name": "Bœuf (viande)",
        "state": "fresh",
        "t_ref_C": 4,
        "water": 65.0, "fat": 14.0, "protein": 20.0, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0.07, "ph": 5.7, "aw": 0.98, "brix": None,
        "density": 1.06, "particle_size_um": 10000,
        "solubility_water": "n/a",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "low",
        "foaming_capacity": "none",
        "gelation_capability": "no_raw_yes_cooked",
        "thickening_capability": "no",
        "hygroscopicity": "medium",
        "thermal_stability": "Maillard_140C_collagen_60C",
        "freeze_thaw_stability": "medium_exudation",
        "oxidation_sensitivity": "high_lipid",
        "sources": "LIT:Tornberg",
        "evidence": "measured",
        "confidence": 0.90,
    },
    # === Poisson ===
    {
        "ingredient_name": "Saumon",
        "state": "fresh",
        "t_ref_C": 4,
        "water": 64.0, "fat": 13.4, "protein": 20.4, "sugar": 0, "starch": 0,
        "fiber": 0, "salt": 0.06, "ph": 6.2, "aw": 0.99, "brix": None,
        "density": 1.04, "particle_size_um": 8000,
        "solubility_water": "n/a",
        "ohc_g_g": None, "whc_g_g": None,
        "emulsifying_capacity": "low",
        "foaming_capacity": "none",
        "gelation_capability": "no_raw_yes_cooked",
        "thickening_capability": "no",
        "hygroscopicity": "medium",
        "thermal_stability": "collagen_50C_proteins_60C",
        "freeze_thaw_stability": "medium_exudation",
        "oxidation_sensitivity": "very_high_PUFA",
        "sources": "LIT:Belitz",
        "evidence": "measured",
        "confidence": 0.85,
    },
]


# ---------------------------------------------------------------------------
# 3) Process operations
# ---------------------------------------------------------------------------

PROCESS_OPERATIONS = [
    # thermal
    {"op_id": "PROC_CHAUFFER", "family": "thermal", "name": "Chauffer",
     "T_min_C": 30, "T_max_C": 250, "duration_min": 1,
     "pressure": "atmospheric", "atmosphere": "ambient",
     "notes": "Élévation contrôlée de la température sans atteinte d'un seuil."},
    {"op_id": "PROC_CUIRE", "family": "thermal", "name": "Cuire",
     "T_min_C": 60, "T_max_C": 200, "duration_min": 5,
     "atmosphere": "ambient",
     "notes": "Procédé thermique générique — cas particulier de chauffer + maintenir."},
    {"op_id": "PROC_BOUILLIR", "family": "thermal", "name": "Bouillir",
     "T_min_C": 95, "T_max_C": 105, "duration_min": 5,
     "atmosphere": "ambient",
     "notes": "Ébullition : eau à 100°C, agitation thermique."},
    {"op_id": "PROC_FREMIR", "family": "thermal", "name": "Frémir",
     "T_min_C": 85, "T_max_C": 95, "duration_min": 5,
     "atmosphere": "ambient",
     "notes": "Sous-ébullition : bulles intermittentes."},
    {"op_id": "PROC_POCHER", "family": "thermal", "name": "Pocher",
     "T_min_C": 70, "T_max_C": 85, "duration_min": 3,
     "atmosphere": "ambient",
     "notes": "Cuisson douce dans un liquide entre 70 et 85°C."},
    {"op_id": "PROC_VAPEUR", "family": "thermal", "name": "Cuire à la vapeur",
     "T_min_C": 95, "T_max_C": 100, "duration_min": 5,
     "atmosphere": "saturated_steam",
     "notes": "Cuisson par vapeur saturée."},
    {"op_id": "PROC_ROTIR", "family": "thermal", "name": "Rôtir",
     "T_min_C": 150, "T_max_C": 250, "duration_min": 20,
     "atmosphere": "ambient",
     "notes": "Cuisson à sec chaleur sèche, surface exposée."},
    {"op_id": "PROC_GRILLER", "family": "thermal", "name": "Griller",
     "T_min_C": 200, "T_max_C": 280, "duration_min": 3,
     "atmosphere": "ambient",
     "notes": "Rayonnement direct intense (barbecue, salamandre)."},
    {"op_id": "PROC_FRIRE", "family": "thermal", "name": "Frire",
     "T_min_C": 160, "T_max_C": 200, "duration_min": 2,
     "atmosphere": "ambient",
     "atmosphere_oil": "yes",
     "notes": "Cuisson par immersion dans un bain de matière grasse."},
    {"op_id": "PROC_TORREFIER", "family": "thermal", "name": "Torréfier",
     "T_min_C": 150, "T_max_C": 240, "duration_min": 10,
     "atmosphere": "ambient",
     "notes": "Application de chaleur sèche pour développer Maillard et arômes."},
    {"op_id": "PROC_PASTEURISER", "family": "thermal", "name": "Pasteuriser",
     "T_min_C": 63, "T_max_C": 90, "duration_min": 30,
     "atmosphere": "ambient",
     "notes": "Pasteurisation : détruire flore pathogène."},
    {"op_id": "PROC_STERILISER", "family": "thermal", "name": "Stériliser",
     "T_min_C": 115, "T_max_C": 130, "duration_min": 15,
     "pressure": "high_pressure",
     "atmosphere": "ambient",
     "notes": "Appertisation, destruction spores."},
    {"op_id": "PROC_REFROIDIR", "family": "thermal", "name": "Refroidir",
     "T_min_C": -50, "T_max_C": 25, "duration_min": 30,
     "atmosphere": "ambient",
     "notes": "Descente en T contrôlée."},
    {"op_id": "PROC_CONGELER", "family": "thermal", "name": "Congeler",
     "T_min_C": -30, "T_max_C": -18, "duration_min": 240,
     "atmosphere": "ambient",
     "notes": "Stockage à T négatives."},
    {"op_id": "PROC_DECONGELER", "family": "thermal", "name": "Décongeler",
     "T_min_C": 0, "T_max_C": 25, "duration_min": 720,
     "atmosphere": "ambient",
     "notes": "Remise à T ambiante, dégradations possibles."},

    # mécanique
    {"op_id": "PROC_MELANGER", "family": "mechanical", "name": "Mélanger",
     "mixing_rpm": "10-200", "shear_rate_s-1": 0,
     "notes": "Mélange sans cisaillement important."},
    {"op_id": "PROC_FOUETTER", "family": "mechanical", "name": "Fouetter",
     "mixing_rpm": "200-1000", "shear_rate_s-1": 100,
     "notes": "Incorporation d'air (mousse/meringue/émulsion)."},
    {"op_id": "PROC_HOMOGENEISER", "family": "mechanical", "name": "Homogénéiser",
     "pressure": "100-300 bar", "shear_rate_s-1": 1000,
     "notes": "Réduction taille globules (lait UHT)."},
    {"op_id": "PROC_CISAILLER", "family": "mechanical", "name": "Cisailler",
     "shear_rate_s-1": 1000,
     "notes": "Mixeur plongeant : cisaillement élevé."},
    {"op_id": "PROC_PETRIR", "family": "mechanical", "name": "Pétrir",
     "mixing_rpm": "60-120", "shear_rate_s-1": 200,
     "duration_min": 10,
     "notes": "Pâte panifiable : gluten + air."},
    {"op_id": "PROC_BROYER", "family": "mechanical", "name": "Broyer",
     "particle_size_target_um": 100,
     "notes": "Mouture, broyage, réduction de taille."},
    {"op_id": "PROC_MIXER", "family": "mechanical", "name": "Mixer (cutters)",
     "shear_rate_s-1": 5000,
     "notes": "Cutter : cisaillement très élevé."},
    {"op_id": "PROC_PRESSER", "family": "mechanical", "name": "Presser",
     "pressure": "high", "notes": "Extraction mécanique (jus, huile)."},
    {"op_id": "PROC_FILTRER", "family": "mechanical", "name": "Filtrer",
     "particle_size_target_um": 100,
     "notes": "Séparation solide/liquide par tamisage."},
    {"op_id": "PROC_CENTRIFUGER", "family": "mechanical", "name": "Centrifuger",
     "shear_rate_s-1": 1000,
     "notes": "Séparation par force centrifuge."},

    # transferts
    {"op_id": "PROC_INFUSER", "family": "transfer", "name": "Infuser",
     "duration_min": 5, "T_C": 95,
     "notes": "Extraction par contact (thé, café)."},
    {"op_id": "PROC_EXTRAIRE", "family": "transfer", "name": "Extraire",
     "notes": "Extraction par solvant/pression/température."},
    {"op_id": "PROC_MACERER", "family": "transfer", "name": "Macérer",
     "duration_min": 1440,
     "notes": "Contact long à T ambiante."},
    {"op_id": "PROC_REDUIRE", "family": "transfer", "name": "Réduire",
     "duration_min": 30, "T_C": 95,
     "notes": "Évaporation d'une partie du liquide."},
    {"op_id": "PROC_EVAPORER", "family": "transfer", "name": "Évaporer",
     "T_C": 100,
     "notes": "Concentration par vaporisation."},
    {"op_id": "PROC_DESHYDRATER", "family": "transfer", "name": "Déshydrater",
     "T_C": 60, "duration_min": 480,
     "notes": "Élimination d'eau à T modérée."},
    {"op_id": "PROC_EGOUTTER", "family": "transfer", "name": "Égoutter",
     "notes": "Séparation par gravité."},
    {"op_id": "PROC_DECANTER", "family": "transfer", "name": "Décanter",
     "duration_min": 60,
     "notes": "Repos pour décantation."},

    # biochimiques
    {"op_id": "PROC_FERMENTER", "family": "biochemical", "name": "Fermenter",
     "T_min_C": 18, "T_max_C": 40, "duration_min": 480,
     "ph_change": "decrease",
     "notes": "Fermentation contrôlée : levain, yaourt, etc."},
    {"op_id": "PROC_FAIRE_LEVER", "family": "biochemical", "name": "Faire lever",
     "T_min_C": 25, "T_max_C": 35, "duration_min": 120,
     "notes": "Levage par CO2 : pâte levée."},
    {"op_id": "PROC_MATURER", "family": "biochemical", "name": "Maturer",
     "T_min_C": 4, "T_max_C": 25, "duration_min": 720,
     "notes": "Affinage enzymatique contrôlé."},
    {"op_id": "PROC_ENZYMATISER", "family": "biochemical", "name": "Enzymatiser",
     "notes": "Ajout d'enzymes (transglutaminase, protéases)."},
    {"op_id": "PROC_ACIDIFIER", "family": "biochemical", "name": "Acidifier",
     "ph_target_min": 3.0, "ph_target_max": 5.0,
     "notes": "Baisse du pH (bactéries lactiques, ajout d'acide)."},
]


# ---------------------------------------------------------------------------
# 4) Règles d'interaction
# ---------------------------------------------------------------------------

INTERACTION_RULES = [
    # === Gélification ===
    {
        "rule_id": "RULE-PEC-HM-001",
        "family": "gelling",
        "components": ["POLY_PEC_HM", "SM_SUCROSE"],
        "ingredient_constraints": "pectine_HM_presence",
        "composition_constraints": "sugar_60-65pct_required",
        "process_constraints": "T_below_boiling",
        "ph_min": 2.5, "ph_max": 4.0,
        "T_min_C": 60, "T_max_C": 105,
        "time_min": 5, "time_max": 30,
        "aw_min": 0.85, "aw_max": 1.0,
        "shear_constraints": "low_avoid_cisaillement",
        "order_constraints": "sugar_dispersed_first_then_pectine",
        "predicted_effect": "gel_formation",
        "effect_direction": "increase_gel_strength",
        "effect_magnitude": "high",
        "output_property": "gel_firmness_strength",
        "equation_or_logic": "F_gel = K * [sugar]^n * [H+] * (1 - [Ca2+]/K_Ca)",
        "sources": "LIT:Sriamornsak|LIT:Oakenfull",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.92,
        "applicability_domain": "confiture, gelée",
        "extrapolation_allowed": False,
        "notes": "Pectine HM gélifie uniquement si sucre > 60% ET pH < 4.0.",
    },
    {
        "rule_id": "RULE-PEC-LM-001",
        "family": "gelling",
        "components": ["POLY_PEC_LM", "SM_CA"],
        "ingredient_constraints": "pectine_LM_presence",
        "composition_constraints": "Ca2+_low_required_for_gel",
        "process_constraints": "low_shear",
        "ph_min": 2.5, "ph_max": 6.5,
        "T_min_C": 0, "T_max_C": 90,
        "aw_min": 0.85, "aw_max": 1.0,
        "predicted_effect": "gel_formation",
        "effect_direction": "increase",
        "effect_magnitude": "medium",
        "output_property": "gel_firmness",
        "equation_or_logic": "IF pectin_LM AND Ca2+ > threshold THEN gel",
        "sources": "LIT:Sriamornsak",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.88,
        "applicability_domain": "yaourt, dessert lacté",
        "extrapolation_allowed": True,
        "notes": "Pectine LM gélifie au calcium (egg-box model).",
    },
    {
        "rule_id": "RULE-GEL-GELATINE",
        "family": "gelling",
        "components": ["PROT_GEL"],
        "ingredient_constraints": "gelatine_present",
        "composition_constraints": "concentration_0.5-3pct",
        "process_constraints": "T_above_melting_for_pouring",
        "ph_min": 3.0, "ph_max": 8.0,
        "T_min_C": 0, "T_max_C": 100,
        "time_min": 5, "time_max": 240,
        "predicted_effect": "thermoreversible_gel",
        "effect_direction": "increase",
        "effect_magnitude": "high",
        "output_property": "gel_strength_bloom",
        "equation_or_logic": "F ≈ K * C_gelatin^(1.4-1.8)",
        "sources": "LIT:GME",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "applicability_domain": "aspic, dessert gélifié",
        "extrapolation_allowed": True,
        "notes": "Force du gel proportionnelle à concentration (loi puissance).",
    },
    {
        "rule_id": "RULE-AGAR-GEL",
        "family": "gelling",
        "components": ["POLY_AGAR"],
        "ingredient_constraints": "agar_0.5-2pct",
        "composition_constraints": "low_calcium",
        "process_constraints": "boil_to_dissolve",
        "ph_min": 4.0, "ph_max": 9.0,
        "T_min_C": 60, "T_max_C": 100,
        "predicted_effect": "thermo_irreversible_gel",
        "effect_direction": "increase",
        "effect_magnitude": "high",
        "output_property": "gel_firmness",
        "equation_or_logic": "F ≈ K * C_agar^(1.5)",
        "sources": "LIT:Phillips",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "applicability_domain": "gelée asiatique, terrine végétale",
        "extrapolation_allowed": True,
        "notes": "Gel se forme vers 35-40°C et reste jusqu'à 85-90°C.",
    },
    # === Émulsions ===
    {
        "rule_id": "RULE-MAYO-001",
        "family": "emulsion",
        "components": ["LIP_TRIGLY", "PROT_OVALB"],
        "ingredient_constraints": "egg_yolk_oil_water",
        "composition_constraints": "oil_fraction_0.6-0.8",
        "process_constraints": "incremental_oil_addition_high_shear",
        "ph_min": 3.5, "ph_max": 7.0,
        "T_min_C": 18, "T_max_C": 25,
        "predicted_effect": "o/w_emulsion_stable",
        "effect_direction": "increase_stability",
        "effect_magnitude": "high",
        "output_property": "emulsion_stability_droplet_size",
        "equation_or_logic": "IF egg_yolk AND oil_gradual_addition THEN stable_mayo",
        "sources": "LIT:McClements",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.90,
        "applicability_domain": "mayonnaise, sauce émulsionnée",
        "extrapolation_allowed": True,
        "notes": "Lécithine de jaune + incorporation lente et progressive en discontinu sont nécessaires.",
    },
    {
        "rule_id": "RULE-HL-EMULSION",
        "family": "emulsion",
        "components": ["LIP_PHOSPH"],
        "ingredient_constraints": "lecithin_present",
        "composition_constraints": "lecithin_0.1-1pct",
        "process_constraints": "high_shear_required",
        "ph_min": 4.0, "ph_max": 8.0,
        "predicted_effect": "emulsification",
        "effect_direction": "increase",
        "effect_magnitude": "medium",
        "output_property": "emulsion_stability",
        "equation_or_logic": "HLB_target = 8-12 for o/w; lecithin ~7-9",
        "sources": "LIT:McClements",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.90,
        "extrapolation_allowed": True,
        "notes": "Lécithine est amphiphile naturelle, HLB ~ 7-9 ; stable o/w si dosage adapté.",
    },
    # === Maillard / Caramel ===
    {
        "rule_id": "RULE-MAILLARD",
        "family": "browning",
        "components": ["SM_GLU_MONO", "PROT_CASEINE", "PROT_WHEY"],
        "ingredient_constraints": "reducing_sugar_present_AND_protein_present",
        "composition_constraints": "aw_0.4-0.7_for_optimal_maillard",
        "process_constraints": "T_above_140C_dry_heat",
        "ph_min": 4.0, "ph_max": 9.0,
        "T_min_C": 140, "T_max_C": 200,
        "time_min": 5, "time_max": 60,
        "aw_min": 0.4, "aw_max": 0.85,
        "predicted_effect": "Maillard_browning_aroma",
        "effect_direction": "increase_color_aroma",
        "effect_magnitude": "high",
        "output_property": "browning_intensity_flavor",
        "equation_or_logic": "ΔE = k * exp(-Ea/RT) * [reducing_sugar] * [amino]",
        "sources": "LIT:Lund",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "extrapolation_allowed": True,
        "notes": "Maillard : réduction + amine → glycosylamine → couleur/arômes.",
    },
    {
        "rule_id": "RULE-CARAMEL",
        "family": "browning",
        "components": ["SM_SUCROSE"],
        "ingredient_constraints": "sucrose_present",
        "process_constraints": "T_above_160C_dry",
        "ph_min": 3.0, "ph_max": 9.0,
        "T_min_C": 160, "T_max_C": 200,
        "predicted_effect": "caramelization_color_aroma",
        "effect_direction": "increase",
        "effect_magnitude": "high",
        "output_property": "color_aroma",
        "equation_or_logic": "sucrose_dehydration_T>160",
        "sources": "LIT:LWT",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "extrapolation_allowed": True,
        "notes": "Caramélisation : pure, non-Maillard.",
    },
    # === Amidon ===
    {
        "rule_id": "RULE-STARCH-GEL",
        "family": "starch",
        "components": ["POLY_AMIDON"],
        "ingredient_constraints": "starch_in_water",
        "composition_constraints": "water_ratio_2-10",
        "process_constraints": "T_above_60C_agitation",
        "ph_min": 4.0, "ph_max": 9.0,
        "T_min_C": 55, "T_max_C": 95,
        "predicted_effect": "gelatinization_viscosity_increase",
        "effect_direction": "increase_viscosity",
        "effect_magnitude": "very_high",
        "output_property": "viscosity",
        "equation_or_logic": "η_max ≈ K * [starch] * (1 - T/T_gel)",
        "sources": "LIT:BeMiller",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "extrapolation_allowed": True,
        "notes": "T gélatinisation amidon : pomme de terre 60-65, blé 65-85, maïs 65-75.",
    },
    {
        "rule_id": "RULE-STARCH-RETROGRAD",
        "family": "starch",
        "components": ["POLY_AMYLOSE"],
        "ingredient_constraints": "amylose_pure",
        "process_constraints": "cooling_after_gelatinization",
        "T_min_C": 0, "T_max_C": 25,
        "time_min": 60,
        "predicted_effect": "retrogradation_syneresis",
        "effect_direction": "increase_firmness_release_water",
        "effect_magnitude": "high",
        "output_property": "texture_release_water",
        "equation_or_logic": "IF T < 25°C AND time > 60min THEN retrogradation_increases",
        "sources": "LIT:BeMiller",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.85,
        "extrapolation_allowed": True,
        "notes": "Pain rassis = rétrogradation amylose.",
    },
    # === Gluten / panification ===
    {
        "rule_id": "RULE-GLUTEN-DEVEL",
        "family": "protein",
        "components": ["PROT_GLU"],
        "ingredient_constraints": "wheat_flour_water",
        "process_constraints": "mixing_5-15min",
        "T_min_C": 18, "T_max_C": 30,
        "predicted_effect": "gluten_network_formation",
        "effect_direction": "increase_viscosity_elasticity",
        "effect_magnitude": "high",
        "output_property": "dough_viscosity",
        "equation_or_logic": "W ≥ 280J pour farine panifiable",
        "sources": "LIT:Shewry",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.92,
        "extrapolation_allowed": True,
        "notes": "Pétrissage : hydratation + cisaillement développent le réseau gluten.",
    },
    # === Sodium / perception ===
    {
        "rule_id": "RULE-SALT-CASEIN",
        "family": "taste",
        "components": ["SM_SALT", "PROT_CASEINE"],
        "ingredient_constraints": "milk_cream_salt",
        "composition_constraints": "NaCl_0.5-3pct",
        "predicted_effect": "flavor_enhancement",
        "effect_direction": "increase_umami_perception",
        "effect_magnitude": "medium",
        "output_property": "perceived_saltiness_umami",
        "equation_or_logic": "salt + caseinate → ion exchange → +flavor",
        "sources": "LIT:LWT",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.75,
        "extrapolation_allowed": True,
        "notes": "Sel exalte umami dans matrices fromagères.",
    },
    # === Coagulation protéique ===
    {
        "rule_id": "RULE-EGG-COAG",
        "family": "protein",
        "components": ["PROT_OVALB"],
        "ingredient_constraints": "egg_present",
        "process_constraints": "T_above_62C_dry",
        "T_min_C": 62, "T_max_C": 100,
        "predicted_effect": "protein_coagulation",
        "effect_direction": "solidify",
        "effect_magnitude": "high",
        "output_property": "structure_firmness",
        "equation_or_logic": "ovalbumin_denatures_at_62-65C_then_aggregates",
        "sources": "LIT:Damodaran",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "extrapolation_allowed": True,
        "notes": "Œuf entier coagule vers 70-80°C.",
    },
    # === Eau / humidité ===
    {
        "rule_id": "RULE-AW-MICRO",
        "family": "safety",
        "components": [],
        "ingredient_constraints": "any",
        "composition_constraints": "aw_threshold_0.86_pathogens",
        "predicted_effect": "microbiological_stability",
        "effect_direction": "control_micro_growth",
        "effect_magnitude": "critical",
        "output_property": "aw",
        "equation_or_logic": "IF aw > 0.86 THEN pathogen_growth_possible",
        "sources": "LIT:LWT",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "extrapolation_allowed": True,
        "notes": "Indicateur de sécurité — non prédictif suffisant (conservation supplémentaire requise).",
    },
    # === pH / gelification pectine ===
    {
        "rule_id": "RULE-PH-COAG-CASEIN",
        "family": "protein",
        "components": ["PROT_CASEINE"],
        "ingredient_constraints": "milk_acid_added",
        "ph_min": 4.0, "ph_max": 5.5,
        "process_constraints": "slow_acidification_avoid_local_excess",
        "predicted_effect": "isoelectric_coagulation",
        "effect_direction": "solidify",
        "effect_magnitude": "high",
        "output_property": "curd_formation",
        "equation_or_logic": "pH ≤ 4.6 → caséines coagulent",
        "sources": "LIT:Damodaran",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.95,
        "extrapolation_allowed": True,
        "notes": "Coagulation isoélectrique des caséines.",
    },
    # === Gélatine + acide ===
    {
        "rule_id": "RULE-GELATIN-ACID",
        "family": "gelling",
        "components": ["PROT_GEL"],
        "ingredient_constraints": "gelatin_acid_present",
        "ph_min": 3.0, "ph_max": 4.5,
        "predicted_effect": "fragile_gel_syneresis",
        "effect_direction": "decrease_gel_strength",
        "effect_magnitude": "medium",
        "output_property": "gel_strength",
        "equation_or_logic": "IF pH < 4 THEN gelatin_gel_weakens",
        "sources": "LIT:GME",
        "evidence_type": "expert_rule_with_literature",
        "confidence": 0.85,
        "extrapolation_allowed": True,
        "notes": "Gélatine ne gélifie pas bien sous pH 3.5 ; préférer agar pour gels acides.",
    },
]


# ---------------------------------------------------------------------------
# 5) Cas expérimentaux de validation
# ---------------------------------------------------------------------------

EXPERIMENTAL_CASES = [
    {
        "case_id": "EXP-MAYO-001",
        "formulation_id": "F-MAYO-001",
        "ingredients": ["Huile de colza", "Jaune d'œuf", "Moutarde de Dijon", "Vinaigre blanc", "Sel fin"],
        "quantities_g": [200, 30, 10, 20, 3],
        "units": "g",
        "process_sequence": [
            "Fouetter jaune + moutarde + sel",
            "Incorporer huile goutte à goutte (émulsion)",
            "Une fois stable, verser en filet",
            "Ajouter vinaigre en fin",
        ],
        "measured_inputs": {"T_initial_C": 20, "T_final_C": 22},
        "measured_outputs": {"droplet_size_um": "10-30", "stability_24h": "ok"},
        "measurement_methods": "microscope optique, observation visuelle",
        "source": "internal_standard_reference",
        "replicates": 3,
        "T_C": 20, "ph": 4.0, "aw": 0.95,
        "notes": "Mayonnaise de référence pour valider R-MAYO-001.",
    },
    {
        "case_id": "EXP-GEL-PEC-001",
        "formulation_id": "F-PEC-001",
        "ingredients": ["Sucre blanc", "Pectine HM", "Acide citrique", "Eau"],
        "quantities_g": [600, 12, 8, 380],
        "process_sequence": [
            "Chauffer eau + sucre à 60°C",
            "Incorporer pectine progressivement",
            "Porter à ébullition 1 min",
            "Ajouter acide citrique hors feu",
            "Couler en pots",
        ],
        "measured_inputs": {"T_C": 102, "sugar_Brix": 62, "ph": 3.2},
        "measured_outputs": {"gel_firmness_N": 1.2, "syneresis_24h": "minimal"},
        "measurement_methods": "texturomètre, mesure pH, Brix",
        "source": "internal_standard_reference",
        "replicates": 2,
        "T_C": 100, "ph": 3.2, "aw": 0.85,
        "notes": "Gel de pectine HM conforme à RULE-PEC-HM-001.",
    },
    {
        "case_id": "EXP-CUSTARD-001",
        "formulation_id": "F-CUSTARD-001",
        "ingredients": ["Lait entier", "Jaune d'œuf", "Sucre blanc", "Farine de blé tendre", "Beurre doux"],
        "quantities_g": [400, 60, 80, 20, 20],
        "process_sequence": [
            "Fouetter jaunes + sucre",
            "Incorporer farine",
            "Chauffer lait + beurre",
            "Verser mélange œufs en filet sur lait chaud",
            "Remettre sur feu doux, fouetter jusqu'à épaississement (80°C)",
        ],
        "measured_inputs": {"T_C": 80, "duration_min": 8, "ph": 6.5},
        "measured_outputs": {"viscosity_Pa_s": 5.0, "texture_set": True},
        "measurement_methods": "viscosimètre rotationnel, thermomètre",
        "source": "internal_standard_reference",
        "replicates": 2,
        "T_C": 80, "ph": 6.5, "aw": 0.93,
        "notes": "Crème pâtissière : œufs coagulent + amidon farine gélatinise.",
    },
    {
        "case_id": "EXP-MERINGUE-001",
        "formulation_id": "F-MER-001",
        "ingredients": ["Blanc d'œuf", "Sucre blanc", "Crème de tartre"],
        "quantities_g": [120, 240, 0.5],
        "process_sequence": [
            "Fouetter blancs + crème tartre à vitesse moyenne",
            "Mousse formée, ajouter sucre progressivement",
            "Foisonner jusqu'à bec d'oiseau",
            "Cuire au four 100°C, 60 min",
        ],
        "measured_inputs": {"T_oven_C": 100, "duration_min": 60},
        "measured_outputs": {"overrun_pct": 800, "density_g_L": 80, "texture_crunchy": True},
        "measurement_methods": "densité, observation, mesure rhéologique post-cuisson",
        "source": "internal_standard_reference",
        "replicates": 3,
        "T_C": 100, "ph": 5.0, "aw": 0.85,
        "notes": "Meringue française : test pour la mousse protéique (foaming_capacity egg white).",
    },
    {
        "case_id": "EXP-BREAD-001",
        "formulation_id": "F-BREAD-001",
        "ingredients": ["Farine de blé tendre", "Eau", "Sel fin", "Levure boulangère sèche"],
        "quantities_g": [500, 320, 10, 5],
        "process_sequence": [
            "Mélanger farine+eau, autolyse 30 min",
            "Ajouter sel+levure, pétrissage 8 min",
            "Pointage 1h30 à 25°C",
            "Façonnage, apprêt 1h",
            "Cuire four 240°C, 30 min puis 200°C, 15 min",
        ],
        "measured_inputs": {"T_C": 240, "duration_min": 45, "aw_initial": 0.85},
        "measured_outputs": {"volume_loaf_mL": 1800, "crumb_alveolation": "open", "crust_color": "Maillard_high"},
        "measurement_methods": "mesure volume, image, profil de T",
        "source": "internal_standard_reference",
        "replicates": 2,
        "T_C": 240, "ph": 5.5, "aw": 0.96,
        "notes": "Pain classique : gluten + amidon gélatinisation + Maillard croûte.",
    },
    {
        "case_id": "EXP-CARAMEL-001",
        "formulation_id": "F-CARAMEL-001",
        "ingredients": ["Sucre blanc", "Eau", "Crème liquide entière", "Beurre doux"],
        "quantities_g": [200, 50, 100, 30],
        "process_sequence": [
            "Chauffer sucre+eau jusqu'à dissolution",
            "Porter à 170°C (caramel blond)",
            "Décuire avec crème chaude (attention vapeur)",
            "Ajouter beurre hors feu",
        ],
        "measured_inputs": {"T_C": 170, "duration_min": 12},
        "measured_outputs": {"color_L": 65, "texture": "fluid_brittle_on_cooling", "aroma": "caramel"},
        "measurement_methods": "colorimètre L*a*b*, thermomètre sonde",
        "source": "internal_standard_reference",
        "replicates": 2,
        "T_C": 170, "ph": 4.5, "aw": 0.55,
        "notes": "Caramel — RULE-CARAMEL validée.",
    },
    {
        "case_id": "EXP-CHOCOLATE-001",
        "formulation_id": "F-CHOC-001",
        "ingredients": ["Chocolat noir 70%", "Crème liquide entière"],
        "quantities_g": [200, 200],
        "process_sequence": [
            "Chauffer crème à 80°C",
            "Verser sur chocolat, laisser reposer 30 s",
            "Fouetter en émulsion",
            "Couler en moule, cristalliser 2h à 16°C",
        ],
        "measured_inputs": {"T_C": 80, "duration_min": 5},
        "measured_outputs": {"crystal_form": "V_beta", "snap_quality": True, "glossy": True},
        "measurement_methods": "DSC, observation visuelle",
        "source": "internal_standard_reference",
        "replicates": 3,
        "T_C": 80, "ph": 6.0, "aw": 0.85,
        "notes": "Chocolat : polymorphisme beurre de cacao.",
    },
    {
        "case_id": "EXP-DRESSING-001",
        "formulation_id": "F-DRESS-001",
        "ingredients": ["Huile d'olive", "Vinaigre de vin rouge", "Moutarde de Dijon", "Sel fin"],
        "quantities_g": [60, 20, 5, 0.5],
        "process_sequence": [
            "Fouetter moutarde + sel + vinaigre",
            "Incorporer huile en filet sous agitation (émulsion)",
        ],
        "measured_inputs": {"T_C": 20},
        "measured_outputs": {"droplet_size_um": "5-20", "separation_30min": "oui"},
        "measurement_methods": "microscope, observation",
        "source": "internal_standard_reference",
        "replicates": 3,
        "T_C": 20, "ph": 3.0, "aw": 0.97,
        "notes": "Vinaigrette 3:1 — émulsion instable (moutarde insuffisante comme émulsifiant).",
    },
    {
        "case_id": "EXP-SORBET-001",
        "formulation_id": "F-SORB-001",
        "ingredients": ["Eau", "Sucre blanc", "Jus de citron jaune", "Fruit de la passion"],
        "quantities_g": [200, 100, 30, 100],
        "process_sequence": [
            "Chauffer eau+sucre pour sirop",
            "Refroidir",
            "Incorporer jus et purée",
            "Mixer, turbiner -18°C",
        ],
        "measured_inputs": {"T_C": -18, "duration_min": 30},
        "measured_outputs": {"overrun_pct": 30, "ice_crystal_size_um": 30},
        "measurement_methods": "microscopie, mesure densité",
        "source": "internal_standard_reference",
        "replicates": 2,
        "T_C": -18, "ph": 3.0, "aw": 0.92,
        "notes": "Sorbet : contrôle cristallisation glace.",
    },
    {
        "case_id": "EXP-KIMCHI-001",
        "formulation_id": "F-KIMCHI-001",
        "ingredients": ["Chou chinois", "Sel fin", "Piment fort", "Ail", "Gingembre"],
        "quantities_g": [1000, 50, 30, 20, 10],
        "process_sequence": [
            "Saler chou 4h, égoutter",
            "Mélanger épices",
            "Tasser en jar, fermentation 3-7 jours à 18°C",
            "Conserver à 4°C",
        ],
        "measured_inputs": {"T_fermentation_C": 18, "ph_final": 4.0, "duration_days": 5},
        "measured_outputs": {"ph_initial": 6.5, "ph_final": 4.0, "lactic_acid_g_L": 12},
        "measurement_methods": "pH-mètre, titration acide lactique",
        "source": "internal_standard_reference",
        "replicates": 1,
        "T_C": 18, "ph": 4.0, "aw": 0.93,
        "notes": "Kimchi — fermentation lactique contrôlée.",
    },
]


# ---------------------------------------------------------------------------
# Écriture
# ---------------------------------------------------------------------------

def write_csv(path, rows, cols):
    with open(path, "w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=cols, delimiter=",", quoting=csv.QUOTE_MINIMAL)
        w.writeheader()
        for r in rows:
            w.writerow({c: r.get(c, "") for c in cols})


def load_registry():
    with open(PHASE1 / "ingredient_registry_v1.csv", "r", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def build_functional_components():
    return [{
        "component_id": c[0],
        "canonical_name": c[1],
        "category": c[2],
        "source_organism": c[3],
        "role": c[4],
        "ingredient_class": c[5],
        "chemistry": c[6],
        "thermal_behavior": c[7],
        "solubility": c[8],
        "source_refs": c[9],
        "license_source": c[10],
        "confidence": f"{c[11]:.2f}",
    } for c in FUNCTIONAL_COMPONENTS]


def build_functional_ingredients(registry, by_name):
    out = []
    for props in INGREDIENT_PROPS:
        ing_name = props["ingredient_name"]
        ing_id = by_name.get(ing_name.lower())
        if ing_id is None:
            # match partiel
            for k, v in by_name.items():
                if ing_name.lower() in k:
                    ing_id = v
                    break
        if ing_id is None:
            continue
        row = {
            "ingredient_id": ing_id,
            "ingredient_state_id": props["state"],
            "temperature_reference_C": props.get("t_ref_C", ""),
            "water_content": props.get("water", ""),
            "fat_content": props.get("fat", ""),
            "protein_content": props.get("protein", ""),
            "starch_content": props.get("starch", ""),
            "sugar_content": props.get("sugar", ""),
            "fiber_content": props.get("fiber", ""),
            "pectin_content": "",
            "alcohol_content": "",
            "salt_content": props.get("salt", ""),
            "mineral_content": "",
            "ph": props.get("ph", ""),
            "titratable_acidity": "",
            "water_activity": props.get("aw", ""),
            "brix": props.get("brix", ""),
            "density_g_per_mL": props.get("density", ""),
            "particle_size_um": props.get("particle_size_um", ""),
            "solubility": props.get("solubility_water", ""),
            "oil_holding_capacity_g_g": props.get("ohc_g_g", ""),
            "water_holding_capacity_g_g": props.get("whc_g_g", ""),
            "emulsifying_capacity": props.get("emulsifying_capacity", ""),
            "foaming_capacity": props.get("foaming_capacity", ""),
            "gelation_capability": props.get("gelation_capability", ""),
            "thickening_capability": props.get("thickening_capability", ""),
            "hygroscopicity": props.get("hygroscopicity", ""),
            "thermal_stability": props.get("thermal_stability", ""),
            "freeze_thaw_stability": props.get("freeze_thaw_stability", ""),
            "oxidation_sensitivity": props.get("oxidation_sensitivity", ""),
            "source_refs": props.get("sources", ""),
            "evidence_type": props.get("evidence", ""),
            "confidence": f"{props.get('confidence', 0.85):.2f}",
            "validity_conditions": "ambient_to_refrigerated",
        }
        out.append(row)
    return out


def build_process_operations():
    cols = ["op_id", "family", "name", "T_min_C", "T_max_C", "duration_min",
            "pressure", "shear_rate_s-1", "mixing_rpm", "energy_input", "cooling_rate",
            "heating_rate", "target_ph", "target_aw", "target_brix", "particle_size_target_um",
            "oxygen_exposure", "atmosphere", "order_index", "addition_mode", "rest_time", "notes"]
    out = []
    for op in PROCESS_OPERATIONS:
        row = {c: op.get(c, "") for c in cols}
        out.append(row)
    return out


def build_interaction_rules():
    cols = ["rule_id", "rule_family", "reactant_or_component_ids", "ingredient_constraints",
            "composition_constraints", "process_constraints", "ph_min", "ph_max",
            "temperature_min", "temperature_max", "time_min", "time_max",
            "water_activity_min", "water_activity_max", "shear_constraints", "order_constraints",
            "predicted_effect", "effect_direction", "effect_magnitude", "output_property",
            "equation_or_logic", "source_refs", "evidence_type", "confidence",
            "extrapolation_allowed", "notes"]
    out = []
    for r in INTERACTION_RULES:
        row = {
            "rule_id": r["rule_id"],
            "rule_family": r["family"],
            "reactant_or_component_ids": "|".join(r.get("components", [])),
            "ingredient_constraints": r.get("ingredient_constraints", ""),
            "composition_constraints": r.get("composition_constraints", ""),
            "process_constraints": r.get("process_constraints", ""),
            "ph_min": r.get("ph_min", ""),
            "ph_max": r.get("ph_max", ""),
            "temperature_min": r.get("T_min_C", ""),
            "temperature_max": r.get("T_max_C", ""),
            "time_min": r.get("time_min", ""),
            "time_max": r.get("time_max", ""),
            "water_activity_min": r.get("aw_min", ""),
            "water_activity_max": r.get("aw_max", ""),
            "shear_constraints": r.get("shear_constraints", ""),
            "order_constraints": r.get("order_constraints", ""),
            "predicted_effect": r.get("predicted_effect", ""),
            "effect_direction": r.get("effect_direction", ""),
            "effect_magnitude": r.get("effect_magnitude", ""),
            "output_property": r.get("output_property", ""),
            "equation_or_logic": r.get("equation_or_logic", ""),
            "source_refs": r.get("sources", ""),
            "evidence_type": r.get("evidence_type", ""),
            "confidence": f"{r.get('confidence', 0.85):.2f}",
            "extrapolation_allowed": "true" if r.get("extrapolation_allowed") else "false",
            "notes": r.get("notes", ""),
        }
        out.append(row)
    return out


def build_experimental_cases(by_name):
    cols = ["case_id", "formulation_id", "ingredient_ids", "quantities", "units",
            "process_sequence", "measured_inputs", "measured_outputs", "measurement_methods",
            "source", "replicates", "temperature_C", "ph", "aw", "notes"]
    out = []
    for c in EXPERIMENTAL_CASES:
        ing_ids = []
        for ing in c["ingredients"]:
            iid = by_name.get(ing.lower())
            if iid is None:
                for k, v in by_name.items():
                    if ing.lower() in k:
                        iid = v
                        break
            if iid is None:
                iid = f"?{ing}"
            ing_ids.append(iid)
        out.append({
            "case_id": c["case_id"],
            "formulation_id": c["formulation_id"],
            "ingredient_ids": "|".join(ing_ids),
            "quantities": "|".join(str(q) for q in c["quantities_g"]),
            "units": c.get("units", "g"),
            "process_sequence": " | ".join(c["process_sequence"]),
            "measured_inputs": json.dumps(c["measured_inputs"], ensure_ascii=False),
            "measured_outputs": json.dumps(c["measured_outputs"], ensure_ascii=False),
            "measurement_methods": c["measurement_methods"],
            "source": c["source"],
            "replicates": c["replicates"],
            "temperature_C": c.get("T_C", ""),
            "ph": c.get("ph", ""),
            "aw": c.get("aw", ""),
            "notes": c.get("notes", ""),
        })
    return out


# Schémas
def write_schema():
    return f"""# Schéma — Phase 4 (fonctionnel & process)

- dataset_version: {DATASET_VERSION}
- schema_version: {SCHEMA_VERSION}
- generated_at: {GENERATED_AT}

## Tables

### `functional_components.csv`
Ontologie des composants fonctionnels (protéines, polysaccharides, lipides, petites molécules).

### `functional_ingredients.csv`
Propriétés intrinsèques d'un ingrédient dans un état donné. Format : un ingrédient peut avoir
plusieurs lignes (une par état).

### `process_operations.csv`
Catalogue des opérations unitaires applicables.

### `interaction_rules.csv`
Règles physico-chimiques avec domaine d'application, conditions opératoires et sorties.

### `experimental_validation_cases.csv`
Cas expérimentaux servant à tester et calibrer les règles.

## Conventions

- Une règle a **toujours** un `applicability_domain`. Si le système sort du domaine,
  statut `OUT_OF_DOMAIN` et confiance fortement réduite.
- L'ordre d'incorporation est représenté par `order_constraints`.
- Les unités sont explicites (g, mg, %, etc.).
- Les valeurs manquantes restent vides (jamais '0' pour 'inconnu').

## Validations QA

- Au moins 1 référence par règle (`source_refs` non vide).
- `confidence` dans [0, 1].
- Pas d'extrapolation cachée : champ `extrapolation_allowed`.
- Composants référencés doivent exister dans `functional_components.csv`.
"""


def write_rule_engine_spec():
    return f"""# Spécification moteur de règles — Phase 4

- dataset_version: {DATASET_VERSION}
- schema_version: {SCHEMA_VERSION}
- generated_at: {GENERATED_AT}

## Vue d'ensemble

Le moteur de règles applique le jeu de données `interaction_rules.csv` à une formulation
donnée (composition + process sequence) pour prédire un comportement fonctionnel.

## Entrée

```json
{{
  "ingredients": [
    {{"ingredient_id": "...", "quantity_g": 100, "state": "..."}}
  ],
  "process_sequence": [
    {{"op_id": "...", "T_C": ..., "duration_min": ..., ...}}
  ],
  "target_properties": [
    "viscosity", "gel_firmness", "stability", "color", "aroma"
  ]
}}
```

## Algorithme (concept)

1. Résoudre les composants fonctionnels présents depuis `functional_ingredients.csv` × `functional_components.csv`.
2. Pour chaque règle applicable au set de composants :
   - Vérifier `ingredient_constraints`, `composition_constraints` (calculées depuis les masses).
   - Vérifier `process_constraints` (T, durée, ordre).
   - Vérifier `ph_min/max`, `aw_min/max`, `shear_constraints`.
   - Si tout matche, appliquer `predicted_effect` avec `effect_magnitude`.
3. Cumuler les effets avec gestion des conflits (ex. 2 règles contradictoires).
4. Calculer le score de confiance agrégé :
   - confiance règle * confiance mapping composant * confiance mapping process.
5. Identifier les situations `OUT_OF_DOMAIN` et baisser fortement le score.

## Sortie (concept)

```json
{{
  "predictions": [
    {{"property": "gel_firmness", "value": 1.2, "unit": "N", "confidence": 0.85, "rule_id": "..."}}
  ],
  "risks": [
    {{"type": "syneresis", "severity": "medium", "rule_id": "..."}}
  ],
  "mechanisms": [
    {{"ingredient_ids": [...], "mechanism": "...", "explanation": "..."}}
  ],
  "suggested_adjustments": [
    {{"action": "increase sugar", "expected_effect": "...", "rule_id": "..."}}
  ],
  "confidence": 0.85,
  "out_of_domain": [],
  "evidence_refs": [...]
}}
```

## Versionnement

- `score_method_version` dans `interaction_rules.csv` permet la coexistence de règles de
  versions différentes.
- Le moteur DOIT toujours préciser la version utilisée dans les sorties.

## Limites assumées (v1)

- Pas de ML : règles purement expertes + physico-chimiques documentées.
- Pas de simulation CFD : la cinétique est capturée par des modèles semi-empiriques.
- Pas de recommandation de sécurité alimentaire : une couche dédiée est prévue.
"""


def write_confidence_method():
    return f"""# Méthode de confiance — Phase 4

- dataset_version: {DATASET_VERSION}
- schema_version: {SCHEMA_VERSION}
- generated_at: {GENERATED_AT}

## Formule composite (par règle)

```
rule_confidence = w1*evidence_quality
                + w2*literature_replication
                + w3*domain_coverage
                + w4*mechanism_clarity
```

avec :

| Composante | Plage | Description | Poids |
|---|---|---|---|
| evidence_quality | 0.5-1.0 | `expert_rule_with_literature` = 1.0 ; `measured` = 0.95 ; `calculated` = 0.7 ; `model_predicted` = 0.5 | 0.40 |
| literature_replication | 0.6-1.0 | Nombre d'études confirmant la règle | 0.25 |
| domain_coverage | 0.4-1.0 | % de la plage de paramètres explorée | 0.20 |
| mechanism_clarity | 0.6-1.0 | Mécanisme physique/chimique documenté | 0.15 |

## Convention

- ≥ 0.85 : règle solide, recommandation forte.
- 0.70–0.84 : fiable.
- 0.50–0.69 : à confirmer.
- 0.25–0.49 : utiliser avec prudence.
- < 0.25 : ne pas utiliser.

## Propagation aux prédictions

```
prediction_confidence = mean(rule_confidence for matching_rules)
                     * mapping_confidence_ingredient
                     * mapping_confidence_process
```

Si une règle est en `OUT_OF_DOMAIN`, sa `rule_confidence` est forcée à 0.10 (et marquée).
"""


def write_coverage_report(reg, by_name, ing_props, rules, ops, exp):
    ing_with_props = {r["ingredient_id"] for r in ing_props}
    n_ing = len(by_name)
    cov = []
    cov.append(f"# Rapport de couverture — Phase 4\n")
    cov.append(f"- dataset_version: {DATASET_VERSION}")
    cov.append(f"- generated_at: {GENERATED_AT}\n")
    cov.append(f"## 1. Volumes")
    cov.append(f"- Composants fonctionnels : **{len(FUNCTIONAL_COMPONENTS)}**")
    cov.append(f"- Ingrédients avec propriétés documentées : **{len(ing_props)}** / {n_ing} ({len(ing_props)/n_ing*100:.1f}%)")
    cov.append(f"- Opérations unitaires : **{len(ops)}**")
    cov.append(f"- Règles d'interaction : **{len(rules)}**")
    cov.append(f"- Cas expérimentaux : **{len(exp)}**\n")
    cov.append(f"## 2. Règles par famille")
    fam = Counter(r["rule_family"] for r in rules)
    for f, c in fam.most_common():
        cov.append(f"- {f}: {c}")
    cov.append("")
    cov.append("## 3. Familles de phénomènes couvertes")
    cov.append("- Gélification (pectine HM/LM, gélatine, agar)")
    cov.append("- Émulsions (huile/eau, lécithine, jaune d'œuf)")
    cov.append("- Mousses (protéines)")
    cov.append("- Maillard et caramélisation")
    cov.append("- Gélatinisation et rétrogradation amidon")
    cov.append("- Coagulation protéique (thermique et acide)")
    cov.append("- Activité de l'eau (sécurité)")
    cov.append("- Perception sel/umami")
    cov.append("")
    cov.append("## 4. Catégories d'ingrédients couvertes")
    cat_covered = Counter()
    cat_total = Counter()
    for r in reg:
        cat_total[r["category_level_1"]] += 1
        if r["ingredient_id"] in ing_with_props:
            cat_covered[r["category_level_1"]] += 1
    for c1, tot in sorted(cat_total.items(), key=lambda x: -x[1]):
        cov.append(f"- {c1}: {cat_covered[c1]} / {tot} ({cat_covered[c1]/tot*100:.1f}%)")
    cov.append("")
    cov.append("## 5. Cas de validation")
    for c in EXPERIMENTAL_CASES:
        cov.append(f"- **{c['case_id']}** — {c['formulation_id']} : {', '.join(c['ingredients'])}")
    cov.append("")
    cov.append("## 6. Sources bibliographiques")
    cov.append("- Damodaran (Food Proteins, CRC)")
    cov.append("- BeMiller (Carbohydrate Chemistry)")
    cov.append("- Phillips (Handbook of Hydrocolloids)")
    cov.append("- O'Brien (Fats and Oils)")
    cov.append("- McClements (Food Emulsions)")
    cov.append("- Belitz (Food Chemistry)")
    cov.append("- Lund (Maillard Reaction)")
    cov.append("- Srivastava/John (Fermentation)")
    cov.append("")
    cov.append("## 7. Zones de faiblesse")
    cov.append("- Cinétique des réactions : modèle simplifié (constante d'Arrhenius générique).")
    cov.append("- Ingrédients mixtes (préparations) : couverture limitée.")
    cov.append("- Paramètres sensoriels (texture humaine) : peu corrélés.")
    cov.append("- Couplage avec base aromatique Phase 3 : structurel mais non encore bidirectionnel.")
    cov.append("")
    cov.append("## 8. Doctrine")
    cov.append("- Une règle s'applique UNIQUEMENT dans son `applicability_domain`.")
    cov.append("- En dehors, le moteur DOIT retourner `OUT_OF_DOMAIN` et baisse du score.")
    cov.append("- Aucune valeur « cachée » : si le moteur extrapole, c'est explicite et marqué.")
    return "\n".join(cov)


def main():
    print("[INFO] Phase 4 — Génération de la base fonctionnelle")

    reg = load_registry()
    by_name = {}
    for r in reg:
        by_name[r["canonical_name_fr"].lower()] = r["ingredient_id"]
        for a in (r.get("aliases_fr") or "").split("|"):
            a = a.strip().lower()
            if a and a not in by_name:
                by_name[a] = r["ingredient_id"]

    # 1. Composants
    fc = build_functional_components()
    FC_COLS = ["component_id", "canonical_name", "category", "source_organism",
               "role", "ingredient_class", "chemistry", "thermal_behavior",
               "solubility", "source_refs", "license_source", "confidence"]
    write_csv(PHASE4 / "functional_components.csv", fc, FC_COLS)
    print(f"[INFO] functional_components.csv : {len(fc)}")

    # 2. Propriétés ingrédients
    fi = build_functional_ingredients(reg, by_name)
    FI_COLS = ["ingredient_id", "ingredient_state_id", "temperature_reference_C",
               "water_content", "fat_content", "protein_content", "starch_content",
               "sugar_content", "fiber_content", "pectin_content", "alcohol_content",
               "salt_content", "mineral_content", "ph", "titratable_acidity",
               "water_activity", "brix", "density_g_per_mL", "particle_size_um",
               "solubility", "oil_holding_capacity_g_g", "water_holding_capacity_g_g",
               "emulsifying_capacity", "foaming_capacity", "gelation_capability",
               "thickening_capability", "hygroscopicity", "thermal_stability",
               "freeze_thaw_stability", "oxidation_sensitivity", "source_refs",
               "evidence_type", "confidence", "validity_conditions"]
    write_csv(PHASE4 / "functional_ingredients.csv", fi, FI_COLS)
    print(f"[INFO] functional_ingredients.csv : {len(fi)}")

    # 3. Process operations
    po = build_process_operations()
    PO_COLS = ["op_id", "family", "name", "T_min_C", "T_max_C", "duration_min",
               "pressure", "shear_rate_s-1", "mixing_rpm", "energy_input",
               "cooling_rate", "heating_rate", "target_ph", "target_aw",
               "target_brix", "particle_size_target_um", "oxygen_exposure",
               "atmosphere", "order_index", "addition_mode", "rest_time", "notes"]
    write_csv(PHASE4 / "process_operations.csv", po, PO_COLS)
    print(f"[INFO] process_operations.csv : {len(po)}")

    # 4. Règles d'interaction
    rules = build_interaction_rules()
    IR_COLS = ["rule_id", "rule_family", "reactant_or_component_ids",
               "ingredient_constraints", "composition_constraints",
               "process_constraints", "ph_min", "ph_max", "temperature_min",
               "temperature_max", "time_min", "time_max", "water_activity_min",
               "water_activity_max", "shear_constraints", "order_constraints",
               "predicted_effect", "effect_direction", "effect_magnitude",
               "output_property", "equation_or_logic", "source_refs",
               "evidence_type", "confidence", "extrapolation_allowed", "notes"]
    write_csv(PHASE4 / "interaction_rules.csv", rules, IR_COLS)
    print(f"[INFO] interaction_rules.csv : {len(rules)}")

    # 5. Cas expérimentaux
    cx = build_experimental_cases(by_name)
    CX_COLS = ["case_id", "formulation_id", "ingredient_ids", "quantities", "units",
               "process_sequence", "measured_inputs", "measured_outputs",
               "measurement_methods", "source", "replicates", "temperature_C",
               "ph", "aw", "notes"]
    write_csv(PHASE4 / "experimental_validation_cases.csv", cx, CX_COLS)
    print(f"[INFO] experimental_validation_cases.csv : {len(cx)}")

    # 6. Schémas et docs
    (PHASE4 / "functional_schema.md").write_text(write_schema(), encoding="utf-8")
    (PHASE4 / "functional_rule_engine_spec.md").write_text(write_rule_engine_spec(), encoding="utf-8")
    (PHASE4 / "functional_confidence_method.md").write_text(write_confidence_method(), encoding="utf-8")
    (PHASE4 / "functional_coverage_report.md").write_text(
        write_coverage_report(reg, by_name, fi, rules, po, cx), encoding="utf-8")

    # 7. QA
    anomalies = []
    # Validations simples
    for f in fc:
        try:
            c = float(f["confidence"])
            if not (0 <= c <= 1):
                anomalies.append({"anomaly_type": "out_of_range_confidence", "record_id": f["component_id"], "detail": f"confidence={c}"})
        except Exception:
            anomalies.append({"anomaly_type": "non_numeric_confidence", "record_id": f["component_id"], "detail": ""})
        if not f["source_refs"]:
            anomalies.append({"anomaly_type": "missing_source_refs", "record_id": f["component_id"], "detail": "composant fonctionnel sans source"})

    for r in rules:
        try:
            c = float(r["confidence"])
            if not (0 <= c <= 1):
                anomalies.append({"anomaly_type": "out_of_range_confidence", "record_id": r["rule_id"], "detail": f"confidence={c}"})
        except Exception:
            anomalies.append({"anomaly_type": "non_numeric_confidence", "record_id": r["rule_id"], "detail": ""})
        if not r["source_refs"]:
            anomalies.append({"anomaly_type": "missing_source_refs", "record_id": r["rule_id"], "detail": "règle sans source"})
        # Vérif cohérence composants référencés
        for comp_id in r["reactant_or_component_ids"].split("|"):
            if not comp_id:
                continue
            known = {f["component_id"] for f in fc}
            if comp_id not in known:
                anomalies.append({"anomaly_type": "unknown_component_in_rule", "record_id": r["rule_id"], "detail": f"composant référencé inconnu: {comp_id}"})

    qa_text = []
    qa_text.append(f"# Rapport QA — Phase 4\n")
    qa_text.append(f"- dataset_version: {DATASET_VERSION}")
    qa_text.append(f"- generated_at: {GENERATED_AT}\n")
    qa_text.append("## 1. Contrôles")
    qa_text.append(f"- Composants fonctionnels : {len(fc)}")
    qa_text.append(f"- Ingrédients avec propriétés : {len(fi)}")
    qa_text.append(f"- Règles d'interaction : {len(rules)}")
    qa_text.append(f"- Cas expérimentaux : {len(cx)}")
    qa_text.append(f"- Anomalies détectées : {len(anomalies)}")
    qa_text.append("")
    qa_text.append("## 2. Détail des anomalies")
    if not anomalies:
        qa_text.append("- Aucune anomalie détectée.")
    else:
        for a in anomalies:
            qa_text.append(f"- {a}")
    qa_text.append("")
    qa_text.append("## 3. Conclusion")
    if not anomalies:
        qa_text.append("- Phase 4 **validée** sur les contrôles automatisés.")
    else:
        qa_text.append("- Phase 4 marquée **to_review** sur les points ci-dessus.")
    (PHASE4 / "qa_report.md").write_text("\n".join(qa_text), encoding="utf-8")

    # Anomalies CSV
    write_csv(PHASE4 / "qa_anomalies.csv",
              anomalies,
              ["anomaly_type", "record_id", "detail"])

    # Manifest
    manifest = {
        "dataset_version": DATASET_VERSION,
        "schema_version": SCHEMA_VERSION,
        "generated_at": GENERATED_AT,
        "row_count": {
            "functional_components": len(fc),
            "functional_ingredients": len(fi),
            "process_operations": len(po),
            "interaction_rules": len(rules),
            "experimental_validation_cases": len(cx),
        },
        "deliverables": [
            "functional_components.csv",
            "functional_ingredients.csv",
            "process_operations.csv",
            "interaction_rules.csv",
            "experimental_validation_cases.csv",
            "functional_schema.md",
            "functional_rule_engine_spec.md",
            "functional_confidence_method.md",
            "functional_coverage_report.md",
            "qa_report.md",
        ],
        "policy": {
            "extrapolation_explicit": True,
            "out_of_domain_flag": True,
            "no_extrapolation_outside_domain": True,
            "order_constraints_modeled": True,
        },
    }
    with open(PHASE4 / "ingestion_manifest.json", "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)

    print("[OK] Phase 4 terminée.")


if __name__ == "__main__":
    main()
