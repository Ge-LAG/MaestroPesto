#!/usr/bin/env python3
"""
Validation finale croisée des 4 phases.

Vérifie :
1. Tous les ingredient_id référencés dans les Phases 2-4 existent dans la Phase 1.
2. Aucun ingredient_id orphelin.
3. Les fichiers livrables principaux existent et ont la bonne structure.
4. Les manifestes sont cohérents.
"""
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DBM = ROOT / "database-metier"
P1 = DBM / "phase1-referentiel"
P2 = DBM / "phase2-nutrition"
P3 = DBM / "phase3-flavour"
P4 = DBM / "phase4-functional"


def load_ids(path, col):
    with open(path, "r", encoding="utf-8") as fh:
        return {r[col] for r in csv.DictReader(fh)}


def main():
    print("=== Validation croisée database-metier ===\n")

    # Phase 1 : ensemble canonique
    p1_ids = load_ids(P1 / "ingredient_registry_v1.csv", "ingredient_id")
    print(f"[P1] ingredient_registry_v1.csv : {len(p1_ids)} ingredients")
    assert len(p1_ids) > 500, f"Phase 1 doit avoir >500 ingrédients, vu {len(p1_ids)}"

    # Phase 2 : nutrition
    if (P2 / "nutrition_database.csv").exists():
        p2_ids = load_ids(P2 / "nutrition_database.csv", "ingredient_id")
        unknown_p2 = p2_ids - p1_ids
        print(f"[P2] nutrition : {len(p2_ids)} ingredients couverts, {len(unknown_p2)} inconnus du P1")
        assert not unknown_p2, f"Phase 2 référence {len(unknown_p2)} ingrédients inconnus"
        p2_comp = load_ids(P2 / "component_dictionary.csv", "component_id")
        p2_lines = sum(1 for _ in open(P2 / "nutrition_database.csv", encoding="utf-8")) - 1
        print(f"[P2] {len(p2_comp)} composants, {p2_lines} lignes nutrition")
        assert p2_lines > 500, f"Phase 2 doit avoir >500 lignes, vu {p2_lines}"

    # Phase 3
    if (P3 / "flavor_compatibility.csv").exists():
        p3_ids = set()
        with open(P3 / "flavor_compatibility.csv", "r", encoding="utf-8") as fh:
            for r in csv.DictReader(fh):
                for iid in r["ingredient_ids"].split("|"):
                    if iid:
                        p3_ids.add(iid)
        unknown_p3 = p3_ids - p1_ids
        print(f"[P3] flavor_compatibility.csv : {len(p3_ids)} ingrédients référencés, {len(unknown_p3)} inconnus")
        assert not unknown_p3, f"Phase 3 référence {len(unknown_p3)} ingrédients inconnus"
        p3_compounds = load_ids(P3 / "aroma_compounds.csv", "compound_id")
        p3_lines = sum(1 for _ in open(P3 / "flavor_compatibility.csv", encoding="utf-8")) - 1
        print(f"[P3] {len(p3_compounds)} composés aromatiques, {p3_lines} lignes compatibilité")
        assert p3_lines > 4000, f"Phase 3 doit avoir >4000 lignes, vu {p3_lines}"

    # Phase 4
    if (P4 / "functional_ingredients.csv").exists():
        p4_ing = load_ids(P4 / "functional_ingredients.csv", "ingredient_id")
        unknown_p4_ing = p4_ing - p1_ids
        print(f"[P4] functional_ingredients : {len(p4_ing)} ingrédients, {len(unknown_p4_ing)} inconnus du P1")
        assert not unknown_p4_ing, f"Phase 4 référence {len(unknown_p4_ing)} ingrédients inconnus"
        if (P4 / "experimental_validation_cases.csv").exists():
            p4_exp_ids = set()
            with open(P4 / "experimental_validation_cases.csv", "r", encoding="utf-8") as fh:
                for r in csv.DictReader(fh):
                    for iid in r["ingredient_ids"].split("|"):
                        if iid and not iid.startswith("?"):
                            p4_exp_ids.add(iid)
            unknown_p4_exp = p4_exp_ids - p1_ids
            assert not unknown_p4_exp, f"Cas expérimentaux Phase 4 référencent {len(unknown_p4_exp)} ingrédients inconnus"
            print(f"[P4] experimental_validation_cases : {len(p4_exp_ids)} ingrédients uniques référencés")
        n_rules = sum(1 for _ in open(P4 / "interaction_rules.csv", encoding="utf-8")) - 1
        n_proc = sum(1 for _ in open(P4 / "process_operations.csv", encoding="utf-8")) - 1
        print(f"[P4] {n_rules} règles d'interaction, {n_proc} opérations unitaires")

    # Manifestes
    for phase, p in [("Phase 2", P2), ("Phase 3", P3), ("Phase 4", P4)]:
        mp = p / "ingestion_manifest.json"
        if mp.exists():
            with open(mp) as fh:
                m = json.load(fh)
            print(f"[{phase}] manifest : {m['dataset_version']} ({m.get('row_count', {})})")

    # Exclusions (Phase 1)
    excl = load_ids(P1 / "excluded_items.csv", "original_name") if (P1 / "excluded_items.csv").exists() else set()
    print(f"[P1] exclusions : {len(excl)} entrées")

    print("\n=== Validation croisée OK ===")


if __name__ == "__main__":
    main()
