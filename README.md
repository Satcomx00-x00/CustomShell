# CustomShell

CustomShell fournit une configuration moderne pour Zsh, Powerlevel10k et tmux, optimisée pour le développement sur Linux et macOS.  
Elle inclut des thèmes, plugins, alias, et une expérience terminal enrichie (affichage RAM, charge, IP, etc).

## Fonctionnalités principales

- Zsh avec Oh My Zsh et de nombreux plugins utiles
- Thème Powerlevel10k moderne, violet, compatible ASCII
- Configuration tmux avancée avec gestionnaire de plugins
- Alias pratiques pour git, docker, tmux, etc.
- Détection automatique d’outils modernes (`exa`, `bat`, etc.)
- Prise en charge de la langue française (locale fr_FR.UTF-8)

## Installation rapide

```bash
git clone https://github.com/Satcomx00-x00/CustomShell
cd CustomShell
./scripts/install.sh
```

> **Astuce** : Pour mettre à jour la configuration Powerlevel10k après modification :
> ```bash
> ./scripts/update-p10k.sh
> ```

## Désinstallation

```bash
./scripts/uninstall.sh
```

## Personnalisation

- Modifiez les fichiers dans `config/` pour adapter les alias, le prompt ou tmux à vos besoins.
- Relancez votre terminal ou exécutez `exec zsh` pour appliquer les changements.

---

Licence : Apache 2.0
