#!/usr/bin/env bash
set -euo pipefail

USB_DIR="/media/pi/KINGSTON"

# Espera a que el USB esté disponible al arrancar.
for _ in {1..60}; do
  if [[ -d "$USB_DIR" ]]; then
    break
  fi
  sleep 1
done

if [[ ! -d "$USB_DIR" ]]; then
  echo "No se encontró el USB en $USB_DIR"
  exit 1
fi

shopt -s nullglob nocaseglob
videos=(
  "$USB_DIR"/*.mp4
  "$USB_DIR"/*.mkv
  "$USB_DIR"/*.avi
  "$USB_DIR"/*.mov
  "$USB_DIR"/*.webm
)

if [[ ${#videos[@]} -eq 0 ]]; then
  echo "No hay vídeos en $USB_DIR"
  exit 1
fi

PLAYLIST="/tmp/usb-video-loop.m3u"
printf '%s\n' "${videos[@]}" > "$PLAYLIST"

# Reproduce la playlist completa y la cicla sin cerrar VLC.
while true; do
  /usr/bin/cvlc \
    --fullscreen \
    --no-video-title-show \
    --avcodec-hw=none \
    --loop \
    "$PLAYLIST"
  sleep 1
done
