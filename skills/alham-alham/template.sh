#!/usr/bin/env bash
#
# Wizard нь хүнийг гар ажиллагаагаар алхам алхмаар хөтөлнө.
# /alham-alham skill-ээр үүсгэсэн.
#
# "STAGES" тэмдэгээс дээших бүх зүйл бол wizard-ийн library: гараар бүү засварла.
# Алхам бүрийн үе шатуудыг тэмдэгээс доош бич.

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────
# Wizard library: таатай, тогтвортой UX, wizard бүрт адилхан.
# ──────────────────────────────────────────────────────────────────────────

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
else
  BOLD=""; DIM=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""
fi

# Бичигч үүнийг үе шатуудын хэсгийн эхэнд тохируулна.
TOTAL_STAGES=0

_STAGE_INDEX=0
ENV_FILE="${ENV_FILE:-.env}"
WRITTEN_ENV=()    # энэ удаа ENV_FILE руу бичсэн KEY-үүд
WRITTEN_SECRET=() # энэ удаа тохируулсан secret-ийн NAME-үүд
SKIPPED=()        # хийж чадаагүй зүйлс (жишээ нь gh байхгүй)

# _clear нь terminal-ийг цэвэрлэж зөвхөн одоогийн алхмыг үлдээнэ. Гаралт
# terminal биш бол юу ч хийхгүй, тэгвэл pipe хийсэн log уншигдахуйц хэвээр.
_clear() {
  [[ -t 1 ]] || return 0
  if command -v tput >/dev/null 2>&1 && tput clear 2>/dev/null; then return 0; fi
  printf '\033[2J\033[3J\033[H'
}

# banner "Гарчиг" нь нээлтийн хүрээг харуулна: энэ wizard юу хийх вэ.
banner() {
  _clear
  printf '\n%s%s  %s%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
  printf '%s  %s үе шат%s\n\n' "$DIM" "$TOTAL_STAGES" "$RESET"
  printf '%s  Browser-оо чи удирдана; энэ wizard яг юу хийхийг хэлж, чиний хуулж\n' "$DIM"
  printf '  буцааж тавьсан утгуудыг хадгална. Хүссэн үедээ Ctrl-C-ээр зогсоогоод дараа\n'
  printf '  дахин ажиллуулж болно, аль хэдийн хадгалсан утгуудыг санаж байдаг.%s\n' "$RESET"
  pause "Эхлэхэд бэлэн үү?"
}

# stage "Нэр" нь дэлгэцийг цэвэрлээд үе шатыг зарлаж, явцыг харуулна.
# Цэвэрлэснээр дэлгэцэн дээр зөвхөн одоогийн алхам үлдэнэ.
stage() {
  _clear
  _STAGE_INDEX=$((_STAGE_INDEX + 1))
  printf '\n%s%s▸ Үе шат %s/%s · %s%s\n' \
    "$BOLD" "$BLUE" "$_STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}

# say "..." энгийн зааврын мөр хэвлэнэ.
say()  { printf '  %s\n' "$1"; }
# step "..." хүний browser дээр хийх, дугаарласан мэт үйлдэл.
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }

# open_url URL нь түүнийг хүний browser-т нээнэ, WSL-ийг оруулаад платформ бүрт.
open_url() {
  local url="$1"
  printf '  %s↗ нээж байна%s %s\n' "$GREEN" "$RESET" "$url"
  { if   command -v wslview     >/dev/null 2>&1; then wslview "$url"
    elif command -v explorer.exe >/dev/null 2>&1; then explorer.exe "$url"
    elif command -v xdg-open    >/dev/null 2>&1; then xdg-open "$url"
    elif command -v open        >/dev/null 2>&1; then open "$url"
    else false; fi
  } >/dev/null 2>&1 || warn "browser нээж чадсангүй, өөрөө орж үзээрэй: $url"
}

# pause "мессеж" нь хүн гар ажлаа хийснээ батлахыг хүлээнэ.
pause() {
  printf '  %s%s%s ' "$DIM" "${1:-Үргэлжлүүлэх бол Enter дар}" "$RESET"
  read -r _ || true
}

# confirm "асуулт" нь y/N хаалт; тийм гэвэл амжилт буцаана.
confirm() {
  local reply=""
  printf '  %s? %s [y/N] ' "$YELLOW" "$1"
  read -r reply || true
  [[ "$reply" =~ ^[Yy] ]]
}

# _existing KEY: ENV_FILE дахь KEY-ийн одоогийн утга (байвал). write_env-ийн
# дан хашилт эсвэл энгийн dotenv-ийн давхар хашилттай утгыг задалсан байна.
_existing() {
  [[ -f "$ENV_FILE" ]] || return 1
  local line value sq="'\\''"; line=$(grep -E "^${1}=" "$ENV_FILE" | tail -n1) || return 1
  value="${line#*=}"
  if [[ "$value" == \'*\' ]]; then value="${value:1:${#value}-2}"; value="${value//"$sq"/\'}"
  elif [[ "$value" == \"*\" ]]; then
    value="${value:1:${#value}-2}"
    [[ "$value" == *[\\\$\"]* ]] && return 1   # escape, $ эсвэл ": найдвартай задалж чадахгүй; дахин асууна
  fi
  printf '%s' "$value"
}

# ask KEY "Асуулт" нь утгыг $KEY руу уншина. Дахин ажиллуулахад .env-д байгаа
# утгыг анхдагчаар санал болгоно (Enter дарвал хэвээр). Оролт харагдана (нууц
# биш), Readline-ээр засна. Оролтгүйгээр EOF ирвэл алдаа буцаана.
ask() {
  local key="$1" prompt="$2" current input s=$'\001' e=$'\002' p rc=0
  current=$(_existing "$key" || true)
  # Курсорыг зөв байрлуулахын тулд Readline өнгөний кодуудыг \001..\002-оор хүрээлэхийг шаарддаг.
  p="  $s$BOLD$e$prompt$s$RESET$e "
  [[ -n "$current" ]] && p+="$s$DIM$e[Enter дарвал одоогийнх хэвээр]$s$RESET$e "
  read -e -r -p "$p" input || rc=1
  if (( rc )) && [[ -z "$input" ]]; then return 1; fi
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# ask_secret KEY "Асуулт" нь ask-тай адил, гэхдээ оролт нуугдана.
ask_secret() {
  local key="$1" prompt="$2" current input rc=0
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Enter дарвал одоогийнх хэвээр]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -rs input || rc=1
  printf '\n'
  if (( rc )) && [[ -z "$input" ]]; then return 1; fi
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# write_env KEY VALUE нь ENV_FILE руу KEY='VALUE'-г upsert хийж (байгаа мөрийг
# солино) $KEY-г тохируулна. Idempotent. ENV_FILE-ийг 0600 эрхтэй үүсгэнэ;
# symlink-ээр дамжуулж бичиж, байгаа файлын эрхийг хэвээр үлдээнэ.
write_env() {
  local key="$1" value="$2" tmp sq="'\\''"
  [[ -e "$ENV_FILE" ]] || (umask 077 && : > "$ENV_FILE")
  tmp=$(mktemp)
  grep -vE "^${key}=" "$ENV_FILE" > "$tmp" || true
  printf "%s='%s'\n" "$key" "${value//\'/$sq}" >> "$tmp"
  cat "$tmp" > "$ENV_FILE"
  rm -f "$tmp"
  printf -v "$key" '%s' "$value"
  WRITTEN_ENV+=("$key")
  printf '  %s✓ бичлээ%s %s → %s\n' "$GREEN" "$RESET" "$key" "$ENV_FILE"
}

# set_secret NAME VALUE нь gh-ээр GitHub Actions-ийн repo secret тохируулна.
# gh байхгүй эсвэл нэвтрээгүй бол анхааруулга өгч (мөн тэмдэглэж) өнгөрнө.
set_secret() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if printf '%s' "$value" | gh secret set "$name" >/dev/null 2>&1; then
      WRITTEN_SECRET+=("$name")
      printf '  %s✓ тохирууллаа:%s GitHub secret %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("GitHub secret $name (гараар тохируул: gh secret set $name)")
  warn "GitHub secret $name алгаслаа: gh бэлэн биш; дараа тохируулаарай"
}

# set_var NAME VALUE нь GitHub Actions-ийн repo variable (нууц биш) тохируулна.
set_var() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if gh variable set "$name" --body "$value" >/dev/null 2>&1; then
      printf '  %s✓ тохирууллаа:%s GitHub variable %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("GitHub variable $name")
  warn "GitHub variable $name алгаслаа, gh бэлэн биш; дараа тохируулаарай"
}

# finish нь дэлгэцийг цэвэрлээд тохируулсан бүх зүйлийн хураангуйг харуулна.
finish() {
  _clear
  printf '\n%s%s  ✓ Тохиргоо дууслаа%s\n' "$BOLD" "$GREEN" "$RESET"
  (( ${#WRITTEN_ENV[@]} ))    && note "$ENV_FILE руу ${#WRITTEN_ENV[@]} утга бичлээ: ${WRITTEN_ENV[*]}"
  (( ${#WRITTEN_SECRET[@]} )) && note "${#WRITTEN_SECRET[@]} GitHub secret тохирууллаа: ${WRITTEN_SECRET[*]}"
  if (( ${#SKIPPED[@]} )); then
    printf '\n'; warn "гараар хийх үлдсэн зүйлс:"
    for s in "${SKIPPED[@]}"; do note "  - $s"; done
  fi
  printf '\n'
}

# ──────────────────────────────────────────────────────────────────────────
# STAGES: энэ хэсгийг бич. Хүний хийх алхам бүрт нэг stage().
# Доорх жишээг соль. TOTAL_STAGES-г бичсэн үе шатуудынхаа тоонд тохируул.
# Үе шат бүрийг run_wizard дотор, сүүлийн мөрийг хэвээр нь үлдээ: тэгвэл bash
# эхний асуултаас өмнө файлыг бүтнээр нь уншдаг тул ажиллаж байхад засвар хийсэн
# ч эвдрэхгүй.
# ──────────────────────────────────────────────────────────────────────────

run_wizard() {

TOTAL_STAGES=1

banner "Stripe тохиргоо"

# ── Жишээ үе шат: өөрийн бодит алхмуудаар соль ───────────────────────────
stage "Stripe: API key-үүд"
say "Stripe-ийн test key-үүдийг аваад local хөгжүүлэлт + CI-д зориулж хадгална."
open_url "https://dashboard.stripe.com/test/apikeys"
step "API keys хуудсан дээр Publishable key-г хуул (pk_test_-ээр эхэлнэ)."
ask STRIPE_PUBLISHABLE_KEY "Publishable key-г энд тавь:"
step "Secret key мөрөн дээрх 'Reveal test key'-г дараад хуул."
ask_secret STRIPE_SECRET_KEY "Secret key-г энд тавь:"
write_env STRIPE_PUBLISHABLE_KEY "$STRIPE_PUBLISHABLE_KEY"
write_env STRIPE_SECRET_KEY "$STRIPE_SECRET_KEY"
set_secret STRIPE_SECRET_KEY "$STRIPE_SECRET_KEY"   # CI-д энэ нь хэрэгтэй
# ──────────────────────────────────────────────────────────────────────────

finish
}

run_wizard "$@"; exit
