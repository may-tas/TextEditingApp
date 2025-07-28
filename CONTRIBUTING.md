# Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/TextEditingApp.git
   ```
3. Set the upstream remote to the original repository:
   ```bash
   git remote add upstream https://github.com/may-tas/TextEditingApp.git
   ```
4. Verify your remotes are set correctly:
   ```bash
   git remote -v
   ```
   You should see both origin (your fork) and upstream (original repo).
   
5. Before creating a new feature, fetch the latest changes from upstream:
   ```bash
   git fetch upstream
   ```
6. Check out the main branch and update it:
   ```bash
   git checkout main
   git merge upstream/main
   ```
7. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature-name
   ```
8. Make your changes and commit them:
   ```bash
   git commit -m "Add some feature"
   ```
9. Push to your branch:
   ```bash
   git push origin feature-name
   ```
8. Open a pull request from your fork's branch to the original repository's main branch.

📌 Guidelines for Working on Issues

1. **First come, first serve**: Issues are assigned on a first-come, first-serve basis.

2. **Comment before you start**: To claim an issue, comment on it first. You’ll be assigned if it's still available.

3. **Max 2 issues** per contributor at a time to ensure fairness and better focus.

4. If an issue is already assigned to someone, please wait or pick a different one.

5. Inactive issues may be unassigned after a reasonable period of no updates (usually 7 days).
