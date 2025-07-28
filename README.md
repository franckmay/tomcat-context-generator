# Repository : tomcat-context-generator

## Description

Ce dépôt contient un **script Bash** (`generate-tomcat-context.sh`) qui automatise la génération :

* d’un **fichier XML de contexte Tomcat** (`<app>.xml`) à placer dans `TOMCAT_HOME/conf/Catalina/localhost/`
* d’un **fichier de propriétés Spring Boot** (`application-<profile>.properties`)

Ces fichiers permettent d’externaliser les paramètres sensibles (base de données, email, sécurité, etc.) **sans recompiler** l’application Spring Boot packagée en WAR.

---

## Structure du dépôt

```text
tomcat-context-generator/
├── generate-tomcat-context.sh    # Script principal
├── README.md                     # Documentation d’utilisation
└── .gitignore                    # Fichiers à ignorer par Git
```

---

## Prérequis

* Bash (Linux/Mac) ou Git Bash (Windows)
* `application.properties` propre, sans commentaires superflus
* Droits d’exécution sur le script

---

## Installation

1. Clonez le dépôt :

   ```bash
   git clone https://github.com/<votre-utilisateur>/tomcat-context-generator.git
   cd tomcat-context-generator
   ```
2. Rendre le script exécutable :

   ```bash
   chmod +x generate-tomcat-context.sh
   ```

---

## Usage

```bash
./generate-tomcat-context.sh \
  --app <APP_NAME> \
  [--input <INPUT_FILE>] \
  [--output-dir <OUTPUT_DIR>] \
  [--profile <PROFILE>]
```

| Option             | Description                                                                  | Défaut                     |
| ------------------ | ---------------------------------------------------------------------------- | -------------------------- |
| `-a, --app`        | **(Obligatoire)** Nom de l’application (ex: `monapp`) – génère `monapp.xml`. | —                          |
| `-i, --input`      | Chemin vers le fichier `application.properties` source                       | `./application.properties` |
| `-o, --output-dir` | Répertoire de sortie pour `<app>.xml` et `application-<profile>.properties`  | Répertoire courant (`.`)   |
| `-p, --profile`    | Suffixe de profil pour le fichier de propriétés (`prod`, `staging`, etc.)    | `prod`                     |
| `-h, --help`       | Affiche cette aide                                                           | —                          |

### Exemples

**Génération basique** :

```bash
./generate-tomcat-context.sh --app monapp
```

Crée `monapp.xml` et `application-prod.properties` dans le dossier courant.

**Génération avancée** :

```bash
./generate-tomcat-context.sh \
  --app monapp \
  --input config/application.properties \
  --output-dir /opt/tomcat/conf/Catalina/localhost \
  --profile staging
```

Crée `/opt/tomcat/conf/Catalina/localhost/monapp.xml` et `/opt/tomcat/conf/Catalina/localhost/application-staging.properties`.

---

## Fonctionnement interne

1. Lecture ligne par ligne de `application.properties`.
2. Ignorance des lignes vides et des commentaires (`#`).
3. Transformation des clés : `.` et `-` → `_`, passage en MAJUSCULES.
4. Échappement des caractères spéciaux XML (`&`, `<`, `>`, `"`, `'`).
5. Génération de la balise `<Environment>` pour chaque propriété.
6. Création du fichier `application-<profile>.properties` avec placeholders `${ENV_VAR}`.

---

## Déploiement sur GitHub

1. Créez un nouveau repository GitHub nommé **`tomcat-context-generator`**.
2. Poussez le contenu local :

   ```bash
   git init
   git add .
   git commit -m "Initial commit: ajout du script et de la documentation"
   git branch -M main
   git remote add origin https://github.com/<votre-utilisateur>/tomcat-context-generator.git
   git push -u origin main
   ```
3. Activez la protection de la branche `main` et ajoutez un **fichier LICENSE** (MIT, Apache 2.0…).

---

## .gitignore

```gitignore
# Scripts et logs
*.log
*.tmp

# Propriétés générées
*.xml
application-*.properties

# Système
.DS_Store
```

---

## Licence

Choisissez une licence adaptée (MIT, Apache 2.0, etc.) et ajoutez un fichier `LICENSE` à la racine.

---

*Script et documentation fournis pour simplifier la gestion de la configuration des applications Spring Boot sur Tomcat.*
