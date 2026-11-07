#!/usr/bin/env bash
# Хүн оролцсон (human-in-the-loop) давтах loop.
# Энэ файлыг хуулж, доорх алхмуудыг засаад ажиллуул.
# Script-ийг agent ажиллуулна; хэрэглэгч terminal дээрээ зааврыг дагана.
#
# Хэрэглээ:
#   bash hitl-loop.template.sh
#
# Хоёр туслах:
#   step "<instruction>"          → зааврыг харуулаад Enter дарахыг хүлээнэ
#   capture VAR "<question>"      → асуултыг харуулаад хариултыг VAR руу уншина
#
# Эцэст нь цуглуулсан утгуудыг agent уншихаар KEY=VALUE хэлбэрээр хэвлэнэ.
#
# `capture` утгаа terminal руу буцааж хэвлэдэг, agent тэндээс уншина.
# Тиймээс `capture`-ээр ажигласан зүйлээ цуглуул, нэвтрэх (sign in) алхмыг
# хэрэглэгчид `step` болгож үлдээ.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Дууссан бол Enter дар] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- доор засна ---------------------------------------------------------

step "Аппаа http://localhost:3000 дээр нээгээд нэвтэр."

capture ERRORED "'Export' товчийг дар. Алдаа гарсан уу? (y/n)"

capture ERROR_MSG "Алдааны мессежийг энд тавь (байхгүй бол 'none'):"

# --- дээр засна ---------------------------------------------------------

printf '\n--- Цуглуулсан утгууд ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
