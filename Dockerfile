# -----------------------------------------------------------------------------
# ÉTAPE 1 : La Compilation (Build)
# -----------------------------------------------------------------------------
FROM maven:3.9.8-eclipse-temurin-21 AS build

# Définir le répertoire de travail dans le conteneur de build
WORKDIR /app

# Copier le fichier de configuration Maven (pom.xml)
COPY pom.xml .

# Télécharger les dépendances du projet à l'avance pour utiliser le cache Docker
RUN mvn dependency:go-offline -B

# Copier tout le dossier des sources (src/)
COPY src ./src

# Compiler le projet et générer le fichier JAR en ignorant les tests unitaires (plus rapide)
RUN mvn clean package -DskipTests

# -----------------------------------------------------------------------------
# ÉTAPE 2 : L'Exécution (Runtime)
# -----------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine

# Définir le répertoire de travail pour l'application
WORKDIR /app

# Copier uniquement le fichier JAR généré à l'étape précédente
# Note : L'étoile (*) cible automatiquement le nom de votre jar généré (ex: democyber-0.0.1-SNAPSHOT.jar)
COPY --from=build /app/target/*.jar app.jar

# Informer Docker que l'application écoute sur le port par défaut de Spring Boot (8080)
EXPOSE 8080

# Commande pour démarrer l'application Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]
