# USB Video Loop en Raspberry Pi

Documentacion tecnica del servicio `usb-video-loop` para reproducir videos de un USB en bucle, a pantalla completa y sin interrupciones visibles entre archivos.

## 1) Objetivo

- Reproducir automaticamente todos los videos de un pendrive al arrancar sesion.
- Evitar que se vea el escritorio entre un video y el siguiente.
- Mantener el servicio autorecuperable si VLC termina por error.

## 2) Entorno y hardware detectado

### Sistema

- Equipo: `Raspberry Pi 4 Model B Rev 1.1`
- Kernel: `Linux 6.12.75+rpt-rpi-v8`
- SO: `Debian GNU/Linux 13 (trixie)`
- Arquitectura: `aarch64`

### Dispositivos USB detectados

- Teclado Logitech K120 (`046d:c31c`)
- Raton Pixart (`093a:2510`)
- Pendrive Kingston DataTraveler (`0951:1666`)

## 3) Componentes configurados

- Script principal: `~/usb-video-loop.sh`
- Servicio systemd de usuario: `~/.config/systemd/user/usb-video-loop.service`
- Archivo de playlist temporal generado en runtime: `/tmp/usb-video-loop.m3u`

## 4) Configuracion final aplicada

### Servicio `usb-video-loop.service`

- Define `DISPLAY=:0` y `XAUTHORITY=/home/pi/.Xauthority` para ejecutar VLC en sesion grafica.
- Ejecuta el script `ExecStart=/home/pi/usb-video-loop.sh`.
- `Restart=always` y `RestartSec=5` para autocuracion.
- Arranque en sesion de usuario con `WantedBy=default.target`.

### Script `usb-video-loop.sh`

Flujo actual:

1. Espera hasta 60s a que exista `/media/pi/KINGSTON`.
2. Detecta videos con extensiones `mp4`, `mkv`, `avi`, `mov`, `webm`.
3. Si no hay videos, termina con error.
4. Genera playlist en `/tmp/usb-video-loop.m3u`.
5. Lanza `cvlc` en fullscreen con `--loop` sobre la playlist.
6. Si VLC termina, el script lo relanza tras `sleep 1`.

Comando clave de reproduccion:

```bash
/usr/bin/cvlc --fullscreen --no-video-title-show --loop /tmp/usb-video-loop.m3u
```

## 5) Comandos usados durante la implementacion

### Inspeccion del sistema

```bash
uname -a
cat /etc/os-release
cat /proc/device-tree/model
lsusb
```

### Inspeccion del servicio

```bash
systemctl --user cat usb-video-loop.service
systemctl --user status usb-video-loop.service --no-pager
systemctl --user is-enabled usb-video-loop.service
systemctl --user is-active usb-video-loop.service
journalctl --user -u usb-video-loop.service -n 120 --no-pager
```

### Validaciones y pruebas

```bash
bash -n /home/pi/usb-video-loop.sh
command -v vlc
vlc --version
DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority /usr/bin/cvlc --fullscreen --no-video-title-show --loop /tmp/usb-video-loop.m3u
```

### Despliegue/reinicio

```bash
systemctl --user daemon-reload
systemctl --user restart usb-video-loop.service
systemctl --user status usb-video-loop.service --no-pager
```

## 6) Requisitos para que funcione

- Tener sesion grafica abierta del usuario `pi`.
- Existencia de `~/.Xauthority`.
- Pendrive montado en `/media/pi/KINGSTON`.
- Videos con extensiones soportadas por el script.
- VLC instalado (`/usr/bin/vlc`, `cvlc`).

## 7) Troubleshooting rapido

### Reproduce un video y se para

- Verifica contenido de playlist:

```bash
cat /tmp/usb-video-loop.m3u
```

- Verifica videos en USB:

```bash
ls -1 /media/pi/KINGSTON
```

- Lanza VLC manualmente con la misma playlist:

```bash
DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority /usr/bin/cvlc --fullscreen --no-video-title-show --loop /tmp/usb-video-loop.m3u
```

### No arranca tras reiniciar

- Revisar estado/log:

```bash
systemctl --user status usb-video-loop.service --no-pager
journalctl --user -u usb-video-loop.service -n 200 --no-pager
```

- Confirmar ruta USB real:

```bash
ls -la /media/pi
```

Si cambia el nombre del volumen, actualizar `USB_DIR` en `~/usb-video-loop.sh`.

## 8) Estructura recomendada del repo

```text
usb-video-loop-docs/
  README.md
  config/
    usb-video-loop.sh
    usb-video-loop.service
```

## 9) Estado actual

- Servicio habilitado: `enabled`
- Servicio activo: `active`
- Reproduccion basada en playlist `.m3u` para continuidad

