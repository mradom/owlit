# 🦉 OWLIT Server Setup

Este script instala y configura un servidor Ubuntu 24.04 limpio con todo lo necesario para alojar sitios modernos con PHP, WordPress o Laravel, siguiendo buenas prácticas de seguridad y performance. Inspirado en Laravel Forge, pero 100% libre, personalizable y orientado a la excelencia técnica.

---

## 🛠️ ¿Qué hace este script?

✔️ Crea el usuario `owlit` con acceso por llave SSH  
✔️ Desactiva el acceso root por SSH  
✔️ Instala:  
- Nginx  
- PHP 8.2 + extensiones  
- MySQL 8 + usuario `owlit`  
- Supervisor  
- Certbot (SSL Let's Encrypt)  
- Composer, Node.js, npm  
✔️ Configura un sitio default visual de OWLIT para dominios no asignados  
✔️ Deja todo listo para instalar WordPress o Laravel

---

## 🚀 Instalación rápida

Conectate al servidor como `root` y ejecutá:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mradom/owlit-server-setup/main/setup-owlit.sh)
```

> ⚠️ Este script debe ejecutarse como `root` en un servidor Ubuntu 24.04 limpio.

---

## 📁 Estructura

```
owlit-server-setup/
├── setup-owlit.sh           # Script principal
├── default-site/
│   ├── index.html           # HTML del sitio por defecto
│   └── owlit.png            # Logo de OWLIT
```

---

## 🧠 Requisitos

- Servidor Ubuntu 24.04 limpio
- Tu llave pública debe estar disponible en GitHub (`https://github.com/TU_USUARIO.keys`)
- Puerto 80/443 habilitados para Nginx y Certbot

---

## ✨ Próximamente

- Instalador de WordPress con WP-CLI  
- Instalador de Laravel con opciones  
- Panel web de gestión de sitios  
- Soporte para Docker, Redis y más

---

## 🧑‍💻 Autor

Desarrollado por [Omar Mrad](https://github.com/mradom).

---

## 🪪 Licencia

MIT
