@echo off
md lib\core\error
md lib\core\network
md lib\core\utils
md lib\core\widgets
md lib\features\feature_a\data\datasources
md lib\features\feature_a\data\models
md lib\features\feature_a\data\repositories
md lib\features\feature_a\domain\entities
md lib\features\feature_a\domain\repositories
md lib\features\feature_a\domain\usecases
md lib\features\feature_a\presentation\bloc
md lib\features\feature_a\presentation\pages
md lib\features\feature_a\presentation\widgets
md lib\features\feature_b\data\datasources
md lib\features\feature_b\data\models
md lib\features\feature_b\data\repositories
md lib\features\feature_b\domain\entities
md lib\features\feature_b\domain\repositories
md lib\features\feature_b\domain\usecases
md lib\features\feature_b\presentation\bloc
md lib\features\feature_b\presentation\pages
md lib\features\feature_b\presentation\widgets
type nul > lib\main.dart
echo Directorios creados.
pause
