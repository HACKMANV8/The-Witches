# 🛠️ Contributing

Contributions are welcome and appreciated! 🎉
Follow the guide below to get started.

---

## 1. Fork the Repository

Click the **“Fork”** button at the top-right of this repo on GitHub to create your own copy.

---

## 2. Sync Your Fork

Make sure your fork is up to date with the main branch before starting work:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

---

## 3. Clone Your Fork

Clone your forked repository and navigate into it:

```bash
git clone <your-repository-url>
cd <your-repository>
```

---

## 4. Create a New Branch

Create a branch for your feature or bug fix:

```bash
git checkout -b feature/your-feature-name
```

Use a clear, descriptive name for your branch (e.g., `feature/add-login-screen` or `fix/button-alignment`).

---

## 5. Set Up Flutter Environment

Ensure you have Flutter installed and set up properly.
If not, follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).

Check your environment with:

```bash
flutter doctor
```

---

## 6. Get Dependencies

Fetch all required dependencies for the project:

```bash
flutter pub get
```

---

## 7. Run the Project

To make sure everything works as expected:

```bash
flutter run
```

---

## 8. Format & Analyze Code

Before committing, please format and analyze your code:

```bash
flutter format .
flutter analyze
```

Run tests (if available):

```bash
flutter test
```

---

## 9. Commit Your Changes

Once everything is good to go:

```bash
git add .
git commit -m "feat: add <feature description>"
```

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) style for commit messages (e.g., `feat:`, `fix:`, `docs:`).

---

## 10. Push Your Branch

Push your changes to your forked repo:

```bash
git push origin feature/your-feature-name
```

---

## 11. Open a Pull Request

Go to your fork on GitHub and click **“Compare & pull request”**.
Describe your changes clearly and link any related issues.

---

## ✅ Tips for a Great Contribution

* Keep pull requests small and focused.
* Make sure your code follows project conventions.
* Update documentation if your change affects usage.

---
