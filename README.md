# Pipeline de prédiction du churn avec BigQuery ML

Ce projet montre comment construire et automatiser un pipeline de prédiction du churn client entièrement dans Google BigQuery.

Le pipeline utilise SQL et BigQuery ML pour :

* générer un jeu de données synthétique sur le comportement des clients ;
* créer des jeux de données d'entraînement et de test ;
* entraîner un modèle de régression logistique ;
* évaluer le modèle sur des données de test mises de côté ;
* générer des prédictions de churn et leurs probabilités ;
* automatiser le réentraînement du modèle et les prédictions avec les Scheduled Queries.

## Cas d'usage métier

Le churn client désigne les clients qui cessent d'acheter ou d'utiliser les services d'une entreprise.

L'objectif du modèle est d'identifier les clients présentant un risque élevé de churn à partir de caractéristiques comportementales telles que :

* le nombre de commandes précédentes ;
* le nombre de jours écoulés depuis la dernière commande ;
* le taux de remboursement ;
* le consentement marketing ;
* la valeur vie client.

La probabilité de churn obtenue pourrait être utilisée pour prioriser des actions de rétention telles que des e-mails ciblés, des offres promotionnelles ou des appels du service client.

## Architecture

![Architecture du pipeline BigQuery ML Churn Prediction]("C:\Users\lydia\Downloads\ml_churn.png")

```text
Données clients synthétiques
          |
          v
Table BigQuery raw
customer_behavior_raw
          |
          v
Séparation entraînement / test
     |          |
     |          +-------------------------+
     v                                    |
Jeu de données d'entraînement             |
     |                                    |
     v                                    v
Modèle BigQuery ML                Jeu de données de test
Régression logistique                     |
     |                                    |
     +----------------+-------------------+
                      |
                      v
                ML.PREDICT
                      |
                      v
        Table de prédictions du churn
        + probabilité de churn
                      |
                      v
                ML.EVALUATE
```

## Structure du projet

```text
.
├── README.md
├── .gitignore
└── sql/
    ├── 01_generate_customer_data.sql
    ├── 02_create_train_test_split.sql
    ├── 03_train_churn_model.sql
    ├── 04_predict_test_data.sql
    ├── 05_evaluate_model.sql
    ├── 06_generate_daily_kpis.sql
    └── 07_scheduled_retrain_and_predict.sql
```

## Technologies

* Google Cloud Platform
* BigQuery
* BigQuery ML
* GoogleSQL
* BigQuery Scheduled Queries

## Modèle

Le projet utilise un modèle de régression logistique BigQuery ML :

```sql
OPTIONS (
  model_type = 'logistic_reg',
  input_label_cols = ['churned']
)
```

La variable cible est :

```text
churned
```

Les variables d'entrée sont :

| Variable                | Description                                               |
| ----------------------- | --------------------------------------------------------- |
| `lifetime_value`        | Valeur estimée générée par le client                      |
| `total_orders`          | Nombre de commandes précédentes du client                 |
| `refund_ratio`          | Proportion de commandes remboursées                       |
| `days_since_last_order` | Récence du client                                         |
| `marketing_opt_in`      | Indique si le client accepte les communications marketing |

## Stratégie des jeux de données

Le jeu de données généré est d'abord divisé en :

```text
80 % TRAIN
20 % TEST
```

BigQuery ML crée ensuite sa propre séparation interne entre entraînement et validation à partir du jeu de données d'entraînement.

Le jeu de données de test externe reste séparé et est uniquement utilisé pour l'évaluation finale du modèle.

```text
Jeu de données complet
       |
       +-- Jeu de données d'entraînement
       |       |
       |       +-- Sous-ensemble d'entraînement interne
       |       +-- Sous-ensemble de validation interne
       |
       +-- Jeu de données de test externe
```

## Exécution du projet

### 1. Prérequis

Vous avez besoin de :

* un projet Google Cloud ;
* la facturation activée ;
* l'API BigQuery activée ;
* l'autorisation de créer des datasets, des tables et des modèles BigQuery.

### 2. Définir l'ID du projet

Remplacez chaque occurrence de :

```text
YOUR_PROJECT_ID
```

par l'ID de votre projet Google Cloud.

### 3. Exécuter les fichiers SQL

Exécutez les fichiers dans cet ordre :

```text
01_generate_customer_data.sql
02_create_train_test_split.sql
03_train_churn_model.sql
04_predict_test_data.sql
05_evaluate_model.sql
```

La sixième requête montre une Scheduled Query simple pour la génération de KPI.

La septième requête peut être configurée comme une Scheduled Query hebdomadaire pour le réentraînement du modèle et la génération des prédictions.

## Résultat des prédictions

La table de prédictions contient :

| Colonne                 | Description                                         |
| ----------------------- | --------------------------------------------------- |
| `customer_id`           | Identifiant du client                               |
| `predicted_churned`     | Classe de churn prédite                             |
| `churn_probability`     | Probabilité que le client churn                     |
| `actual_churned`        | Label réel dans le jeu de données de test           |
| Caractéristiques client | Valeurs utilisées pour comprendre chaque prédiction |

## Réentraînement planifié

Le workflow suivant peut être exécuté automatiquement :

```text
Nouvelles données d'entraînement
       |
       v
Réentraînement du modèle BigQuery ML
       |
       v
Génération de nouvelles prédictions
       |
       v
Stockage des prédictions dans BigQuery
```

Pour ce projet pédagogique, la requête automatisée effectue les prédictions sur la table de test.

Dans une architecture de production, le modèle générerait normalement des prédictions sur une table distincte contenant de nouveaux enregistrements clients non labellisés.

## Limites

Ce projet est volontairement simplifié :

* les données clients sont synthétiques ;
* le label de churn est généré à partir de règles prédéfinies ;
* la même logique de variables est utilisée pour générer et prédire la cible ;
* les données changent à chaque nouvelle exécution de la requête de génération car elle utilise `RAND()` ;
* aucune optimisation des hyperparamètres n'est mise en œuvre ;
* aucun monitoring de la dérive du modèle ou de la qualité des données n'est inclus ;
* la Scheduled Query est utilisée comme mécanisme d'orchestration léger.

Pour un cas d'usage de production plus avancé, les améliorations possibles incluraient :

* l'ingestion d'événements clients réels ;
* l'ajout de tests de qualité des données ;
* l'utilisation de séparations entraînement/test basées sur le temps ;
* la mise en œuvre d'une optimisation des hyperparamètres ;
* le suivi des performances du modèle dans le temps ;
* le monitoring de la dérive des variables et des prédictions ;
* l'orchestration du pipeline complet avec Cloud Composer ou Workflows.

## Compétences mises en œuvre

* Préparation des données avec BigQuery
* Feature engineering en SQL
* Machine Learning supervisé avec BigQuery ML
* Gestion des jeux de données d'entraînement, de validation et de test
* Régression logistique
* Évaluation du modèle
* Prédiction par batch
* Scheduled Queries
* Automatisation légère d'un pipeline ML

## Contexte

Ce projet a été réalisé dans le cadre de la formation Cloud Data Engineering sur Google Cloud dispensée par Data Upskilling.
