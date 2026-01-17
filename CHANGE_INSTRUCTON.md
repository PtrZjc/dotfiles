To solidny i nowoczesny setup (WezTerm, Neovim, narzędzia w Rust), ale widzę w nim kilka krytycznych problemów bezpieczeństwa oraz kwestie, które utrudnią Ci pracę w środowisku hybrydowym (macOS local <-> Ubuntu remote).

Oto techniczna analiza i rekomendowane poprawki.

### 2. Kompatybilność macOS <-> Ubuntu (Remote)

Twój config jest mocno zależny od macOS (`pbcopy`, `pbpaste`, `open`, `brew`). Na serwerach Ubuntu te polecenia nie zadziałają, co spowoduje błędy przy ładowaniu `.zshrc` lub wywołaniu funkcji.

#### A. Abstrakcja Schowka (Clipboard)

W `zsh/text_processing.zsh` i aliasach używasz `pbpaste`/`pbcopy`. Zrób wrapper:

```bash
# Dodaj do zsh/custom.zsh
function clip_copy() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pbcopy
    elif command -v xclip >/dev/null; then
        xclip -selection clipboard
    elif command -v wl-copy >/dev/null; then
        wl-copy # Wayland
    else
        cat > /dev/null # Fallback to avoid error
    fi
}

function clip_paste() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pbpaste
    elif command -v xclip >/dev/null; then
        xclip -selection clipboard -o
    elif command -v wl-paste >/dev/null; then
        wl-paste
    fi
}

# Zaktualizuj aliasy
alias C='| clip_copy'

```

#### B. Abstrakcja `open`

Ubuntu nie ma `open` (ma `xdg-open`), a na serwerze headless `xdg-open` też może nie działać tak jak chcesz.

```bash
function open_file() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$@"
    elif command -v xdg-open >/dev/null; then
        xdg-open "$@" > /dev/null 2>&1
    else
        echo "Brak GUI - wyświetlam ścieżkę: $@"
    fi
}

```

### 3. Optymalizacja Funkcji ZSH

#### Ulepszenie `set_aws_profile` (zsh/job_specific.zsh)

Zamiast `read choice` i `case`, wykorzystaj `fzf` (który już masz), aby wybór był szybszy i bardziej interaktywny.

```bash
function set_aws_profile() {
    # ... (logika --set-only bez zmian)

    # Definicja profili: Nazwa_wyświetlana|Profile_AWS|Cluster|Region
    local profiles=(
        "1) LIVEDATA_IGP_NONPROD|LIVEDATA_IGP_NONPROD|nonprod-euc1-igp-srld-io|eu-central-1"
        "2) LIVEDATA_IGP_PROD_OBSERVER|LIVEDATA_IGP_PROD_OBSERVER|prod-euc1-igp-srld-io|eu-central-1"
        "3) LIVEDATA_IGP_PROD_DEVELOPER|LIVEDATA_IGP_PROD_DEVELOPER|prod-euc1-igp-srld-io|eu-central-1"
        "5) priv|priv||"
    )

    local selected=$(printf "%s\n" "${profiles[@]}" | fzf --height 20% --reverse)
    
    if [[ -z "$selected" ]]; then echo "Anulowano."; return; fi

    local profile_name=$(echo "$selected" | cut -d'|' -f2)
    local cluster=$(echo "$selected" | cut -d'|' -f3)
    local region=$(echo "$selected" | cut -d'|' -f4)

    # ... (reszta logiki sso login z użyciem zmiennych powyżej)
}

```

#### Fix Ścieżek (zsh/custom.zsh)

Masz hardcoded ścieżkę: `export REPO="${HOME}/workspace"`.
Jeśli na serwerze Ubuntu sklonujesz dotfiles do `~/dotfiles` zamiast `~/workspace/private/dotfiles`, wszystko się posypie.

Użyj dynamicznego wykrywania ścieżki w `2-configure-rest.sh` (już to robisz) i zapisuj ją do pliku np. `~/.dotfiles_path`, który `zsh` odczyta, LUB użyj standardowej zmiennej:

```bash
# W zsh/custom.zsh
# Jeśli DOTFILES nie jest ustawione, zgadnij lokalizację na podstawie lokalizacji skryptu
if [[ -z "$DOTFILES" ]]; then
    export DOTFILES=${0:A:h:h} # Pobierz absolutną ścieżkę do rodzica rodzica tego pliku
fi

```

### 4. Sugestie Narzędziowe (Tooling)

Biorąc pod uwagę Twój stack (macOS, WezTerm, Neovim, AWS, K8s):

1. **`lazygit`**: Masz mnóstwo aliasów gitowych (`gcr`, `gcb`, `glg`). `lazygit` zastąpi 90% z nich jednym interfejsem TUI. Jest znacznie szybszy przy rozwiązywaniu konfliktów merge/rebase.
* `brew install lazygit`


2. **`eza` zamiast `lsd**`: `lsd` jest OK, ale `eza` (fork `exa`) jest obecnie standardem w społeczności Rust/modern-unix, ma lepsze domyślne kolory i obsługę git status w widoku drzewa.
3. **`kubectx` / `kubens**`: W `Brewfile` masz `kubectx` (zakładam), ale w `job_specific.zsh` napisałeś własną funkcję `k-set-ns`. Narzędzie `kubens` (część pakietu kubectx) robi to interaktywnie z fzf.
4. **WezTerm + Remote**: Ponieważ używasz WezTerm, sprawdź funkcję **WezTerm SSH Domains**. Pozwala ona na utrzymanie sesji (jak tmux) bez konieczności instalowania tmuxa na serwerze, o ile zainstalujesz tam binarkę wezterm-mux. Jeśli nie możesz instalować softu na serwerach, rozważ **Zellij** lub **Tmux** lokalnie, aby zarządzać wieloma sesjami SSH.

### 5. `fdf` dla LLM

Twoja funkcja `fdf` w `zsh/custom.zsh` jest świetna do karmienia kontekstem LLM-ów.
Drobna optymalizacja: dodaj flagę `--no-filename` do `fd` wewnątrz exec, jeśli chcesz czystszy output, lub użyj narzędzia **`repomix`** (dawniej `repopack`), które jest stworzone dokładnie do tego celu (pakowanie plików do prompta z XML tags/Markdown).

```bash
# Opcjonalnie:
npm install -g repomix
alias llmpack="repomix --style xml --output show"

```

### Co mogę dla Ciebie zrobić?

Czy chcesz, abym przygotował poprawioną wersję pliku `zsh/job_specific.zsh` z wykorzystaniem `fzf` do przełączania profili AWS, czy wolisz skrypt "czyszczący" repozytorium z hardcoded secrets (git filter-repo)?