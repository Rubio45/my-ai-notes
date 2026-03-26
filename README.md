# myAINotes 

Aplicación de notas inteligente con integración de IA generativa. Proyecto full-stack compuesto por una app nativa iOS y un backend RESTful en Python.

**Autor:** Alex Ivan Diaz Yanez  
**Email:** adiazy@uamv.edu.ni

---

## Descripción

myAINotes es una aplicación móvil para iOS que permite a los usuarios crear, editar y organizar notas, con la posibilidad de chatear con un asistente de inteligencia artificial (OpenAI GPT) directamente desde la app. El backend expone una API REST que maneja autenticación JWT, almacenamiento de notas y usuarios en MongoDB.

---

## Estructura del proyecto

```
myNotesApp/
├── myAINotes/                  # App iOS (Swift / SwiftUI)
│   └── myAINotes/
│       ├── Core/
│       │   ├── Network/        # Clientes HTTP y OpenAI
│       │   └── Storage/        # Keychain Manager
│       ├── Features/
│       │   ├── Auth/           # Login y registro
│       │   ├── Chat/           # Chat con IA
│       │   ├── Notes/          # Lista, detalle y editor de notas
│       │   └── Onboarding/     # Pantallas de bienvenida
│       ├── Models/             # Modelos de datos (Auth, Chat, Notes)
│       └── ViewModels/         # Lógica de presentación (MVVM)
│
└── my-ai-notes-backend/        # Backend (Python / FastAPI)
    └── app/
        ├── api/v1/
        │   ├── auth/           # Endpoints de autenticación
        │   ├── notes/          # Endpoints de notas
        │   └── examples/       # Endpoints de ejemplo
        ├── repos/v1/
        │   ├── notes/          # Repositorio y datasource de notas
        │   └── users/          # Repositorio y datasource de usuarios
        ├── core/               # Seguridad y JWT
        ├── services/           # Servicio de MongoDB (Motor)
        ├── dependencies/       # Inyección de dependencias (auth)
        └── main.py             # Punto de entrada FastAPI
```

---

## Tecnologías

### iOS App
| Tecnología | Descripción |
|---|---|
| **Swift** | Lenguaje principal |
| **SwiftUI** | Framework de UI declarativa |
| **MVVM** | Patrón de arquitectura |
| **URLSession** | Comunicación HTTP / Streaming SSE |
| **OpenAI API** | Chat con IA (GPT, streaming token a token) |
| **Keychain** | Almacenamiento seguro de credenciales |
| **Xcode** | IDE de desarrollo |

### Backend
| Tecnología | Descripción |
|---|---|
| **Python 3.12** | Lenguaje principal |
| **FastAPI** | Framework web asíncrono |
| **MongoDB** | Base de datos NoSQL |
| **Motor** | Driver asíncrono de MongoDB |
| **JWT (python-jose)** | Autenticación con tokens |
| **bcrypt** | Hash de contraseñas |
| **orjson** | Serialización JSON de alta performance |
| **uv** | Gestor de paquetes y entornos virtuales |
| **Docker** | Containerización |
| **pytest** | Testing |
| **ruff** | Linter y formateador de código |

---

## Funcionalidades

- Registro e inicio de sesión con JWT
- Crear, editar y eliminar notas
- Chat con asistente de IA (OpenAI GPT) con streaming en tiempo real
- Onboarding para nuevos usuarios
- Almacenamiento seguro de tokens en Keychain
- API versionada (`/api/v1`)
- Documentación automática con Swagger (modo desarrollo)

---

## Requisitos previos

### Backend
- Python 3.12+
- MongoDB en ejecución
- [uv](https://docs.astral.sh/uv/) instalado

### iOS
- macOS con Xcode 15+
- Simulador o dispositivo iOS 17+
- Cuenta de desarrollador Apple (opcional para dispositivo físico)

---

## Instalación y ejecución

### Backend

```bash
cd my-ai-notes-backend

# Copiar y configurar variables de entorno
cp app/.env.example app/.env
# Editar app/.env con tu MongoDB URI, JWT secret, etc.

# Instalar dependencias
uv sync

# Ejecutar servidor de desarrollo
uv run fastapi dev app/main.py
```

La API estará disponible en `http://localhost:8000`  
Documentación Swagger: `http://localhost:8000/docs`

#### Con Docker

```bash
cd my-ai-notes-backend
docker build -t my-ai-notes-backend .
docker run -p 8000:8000 --env-file app/.env my-ai-notes-backend
```

### iOS App

1. Abrir `myAINotes/myAINotes.xcodeproj` en Xcode
2. Seleccionar un simulador o dispositivo
3. Ejecutar con `Cmd + R`

---

## Variables de entorno (Backend)

Crear el archivo `app/.env` basándose en `app/.env.example`:

```env
MONGO_URI=mongodb://localhost:27017
DB_NAME=my_ai_notes
JWT_SECRET=tu_secreto_super_seguro
JWT_ALGORITHM=HS256
MODE=DEV
```

---

## Endpoints principales

| Método | Ruta | Descripción |
|---|---|---|
| `POST` | `/api/v1/auth/register` | Registro de usuario |
| `POST` | `/api/v1/auth/login` | Login, retorna JWT |
| `GET` | `/api/v1/notes` | Listar notas del usuario |
| `POST` | `/api/v1/notes` | Crear nota |
| `PUT` | `/api/v1/notes/{id}` | Actualizar nota |
| `DELETE` | `/api/v1/notes/{id}` | Eliminar nota |

---

## Testing (Backend)

```bash
cd my-ai-notes-backend
uv run pytest
```

---

## Licencia

Proyecto académico — Universidad Americana (UAMV)  
Alex Ivan Diaz Yanez — adiazy@uamv.edu.ni
