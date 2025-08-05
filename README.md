# start-dart-api

A sample command-line application built using Dart and [Shelf](https://pub.dev/packages/shelf), designed for building lightweight web APIs.

## 📦 Project Info

- **Name:** start-dart-api
- **Version:** 1.0.0
- **SDK:** Dart ^3.8.3
- **Description:** A sample command-line application using shelf for serving HTTP and WebSocket endpoints.

---

## 🚀 Features

- 🌐 RESTful routing with `shelf_router`
- 🔒 CORS support via `shelf_cors_headers`
- 📁 Static file serving using `shelf_static`
- 🔌 WebSocket support with `shelf_web_socket`
- ⚙️ Easy to configure and extend

---

## 📁 Dependencies

```yaml
dependencies:
  shelf: ^1.4.2
  shelf_cors_headers: ^0.1.5
  shelf_router: ^1.1.4
  shelf_static: ^1.1.1
  shelf_web_socket: ^1.0.1

dev_dependencies:
  lints: ^5.0.0
  test: ^1.24.0
```

---

## ▶️ Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/karimny21/start-dart-api.git
cd start-dart-api
```

> Replace `karimny21` with your GitHub username or organization.

### 2. Install dependencies

```bash
dart pub get
```

### 3. Run the server

```bash
dart run bin/server.dart
```

> Make sure the entry point `bin/server.dart` exists and starts your HTTP server.

---

## 🧪 Running Tests

```bash
dart test
```

---

## 🧹 Linting

Analyze your code for issues using:

```bash
dart analyze
```

---

## 📂 Project Structure

```
start-dart-api/
├── bin/              # Entry point of the application (e.g., server.dart)
├── lib/              # Optional business logic
├── test/             # Unit and integration tests
├── pubspec.yaml      # Project configuration and dependencies
└── README.md         # Project documentation (this file)
```

---

## 📌 TODO

- [ ] Add environment-based configuration
- [ ] Implement error handling middleware
- [ ] Docker support (optional)
- [ ] Authentication middleware (optional)

---

## 📃 License

This project is licensed under the MIT License.

---

## 🙋‍♂️ Contributing

Contributions are welcome!  
Feel free to open issues or submit pull requests 🙌

---

## 🔗 Links

- [Dart Language](https://dart.dev)
- [Shelf Package](https://pub.dev/packages/shelf)
- [Dart CLI Guide](https://dart.dev/tools/dart-tool)
