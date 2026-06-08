# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | CallRecap |
| **Git URL** | git@github.com:asunnyboy861/CallRecap.git |
| **Repo URL** | https://github.com/asunnyboy861/CallRecap |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/CallRecap/ | ✅ Active |
| Support | https://asunnyboy861.github.io/CallRecap/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/CallRecap/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/CallRecap/terms.html | ✅ Active |

## Repository Structure

```
CallRecap/
├── CallRecap/                        # iOS App Source Code
│   ├── CallRecap.xcodeproj/          # Xcode Project
│   ├── CallRecap/                    # Swift Source Files
│   │   ├── Views/
│   │   │   ├── Onboarding/
│   │   │   ├── Paywall/
│   │   │   ├── Player/
│   │   │   ├── Recording/
│   │   │   ├── Settings/
│   │   │   ├── Summary/
│   │   │   ├── Transcript/
│   │   │   └── Trash/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── ViewModels/
│   │   └── Extensions/
│   └── ...
├── docs/                             # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── keytext.md
├── capabilities.md
├── icon.md
├── price.md
├── app_review_info.md
└── nowgit.md
```
