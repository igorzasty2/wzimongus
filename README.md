# WZiMongus

WZiMongus to unikalna adaptacja popularnej gry "Among Us", osadzona w środowisku akademickim. Projekt przenosi kontekst oryginalnej gry na kampus Szkoły Głównej Gospodarstwa Wiejskiego w Warszawie.


## 👨‍💻 Organizacja pracy

Pracujesz w 2-4 osobowej grupie (w zależności od poziomu skomplikowania), która musi zawierać co najmniej jednego testera i dewelopera. Dodatkowo najprawdopodobniej będziesz współpracował z art designerem.

Zadanie do wykonania otrzymujesz od Dev Managera / Test Managera / Project Managera, możesz także zgłosić się ochotniczo do wykonania czegoś.


### Integracja

Jeśli twój kod wymaga integracji z innymi funkcjami omów to z odpowiednim zespołem, aby zniwelować wszelkie problemy przy mergowaniu.

Staraj się jak najmniej ingerować w inny kod, jeśli to możliwe.


## 📂 Szkielet projektu

Do nazw plików oraz folderów używaj **snake_case**.

Do nodeów używaj **PascalCase**

(Zalecenia wzięte z dokumentacji GODOT)


```
/
    globals/ <- Autoload skrypty

    scenes/
        map/
            assets/
                [...]
            map.tscn
            map.gd
            map_test.gd

        player/
            assets/
                [...]
            player.tscn
            player.gd
            player_test.gd
        
        ui/
            chat/
                assets/
                    [...]
                chat.tscn
                chat.gd
                chat_test.gd

            main_menu/
                assets/
                    [...]
                main_menu.tscn
                main_menu.gd
                main_menu_test.gd

        minigames/
            [minigame]/
                assets/
                    [...]
                [minigame].tscn
                [minigame].gd
                [minigame]_test.gd


    common/ <- Pliki używane w wielu scenach
        assets/
        themes/
        fonts/
        shaders/
    
    project.godot
    .gitignore
    README.md

```


## 🌿 Branche

Każde nowe funkcje twórz w oddzielnych branchach, trzymając się odpowiednich prefixów:

- feature/... - dodawanie, usuwanie, modyfikowanie funkcji
- bugfix/issue#243fr - naprawianie buga
- test/... - eksperymentowanie z czymś

### Pull Requests

Jak już przygotujesz funkcję wykonaj pull request do **main** brancha, gdzie musisz opisać wszystko co przygotowałeś (z kim pracowałeś etc.). Kod musi przejść przygotowane testy jednostkowe i pozytywny code review.
