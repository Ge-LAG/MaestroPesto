#!/usr/bin/env bash
# Télécharge les jeux de données en libre accès utilisés par les
# générateurs de tool/ (cache local exclu du dépôt : tool/.cache/).
#
#   USDA FoodData Central (CC0 1.0)        https://fdc.nal.usda.gov/
#   USDA Nutrient Retention Factors R6     https://catalog.data.gov/dataset/usda-table-of-nutrient-retention-factors-release-6-2007
#   Escoffier 1907, Project Gutenberg      https://www.gutenberg.org/ebooks/71395
#
# La liste FDA « Approximate pH of Foods » (2007, domaine public) est
# déjà extraite dans tool/data/fda_ph_2007.csv.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .cache && cd .cache

curl -sSfL -o sr_legacy.zip \
  https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_csv_2018-04.zip
curl -sSfL -o foundation.zip \
  https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_foundation_food_csv_2026-04-30.zip
unzip -o -q sr_legacy.zip -d sr
unzip -o -q foundation.zip -d fnd

curl -sSfL -o usda_retention_rf6.csv https://ndownloader.figshare.com/files/44488754
curl -sSfL -o escoffier_pg71395.txt https://www.gutenberg.org/cache/epub/71395/pg71395.txt

echo "Sources ouvertes téléchargées dans tool/.cache/"
