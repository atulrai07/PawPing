<<<<<<< HEAD
# PawPing – Smart Pet Care Companion
=======
# 🐾 PawPing – Smart Pet Care Companion
>>>>>>> develop

PawPing is a modern iOS application designed to help pet owners **track, manage, and care for their pets’ daily health and activities** in a simple, intuitive, and visually engaging way.

From **daily walks and meals** to **vaccination reminders and medical history**, PawPing brings all essential pet-care features into one clean and user-friendly app.

---

<<<<<<< HEAD
## Features

### Activity Tracking
=======
## 📱 Features

### 🏃 Activity Tracking
>>>>>>> develop

* Track daily walk goals and progress
* Circular progress visualization
* Quick activity overview on the home screen

<<<<<<< HEAD
### Meals & Care
=======
### 🍽 Meals & Care
>>>>>>> develop

* Scheduled meals (morning, afternoon, night)
* Visual indicators for taken / pending meals
* Simple toggle-based interaction

<<<<<<< HEAD
### Vaccine Management
=======
### 💉 Vaccine Management
>>>>>>> develop

* Dedicated Vaccine tab with 3 sections:

  * **Upcoming Vaccines**
  * **Missed Vaccines**
  * **Vaccination History**
* “Mark as Done” action:

  * Moves vaccines from Upcoming/Missed → History
* Stores last taken date and clinic details
* Export Vaccine Passport (planned)

<<<<<<< HEAD
### Profile & Authentication
=======
### 👤 Profile & Authentication
>>>>>>> develop

* Clean login and account creation UI
* Email & password authentication UI
* Social login options:

  * Continue with Apple
  * Continue with Google
* Designed for easy backend integration (Firebase-ready)

<<<<<<< HEAD
### Tab-Based Navigation
=======
### 🧭 Tab-Based Navigation
>>>>>>> develop

* Activity
* Care
* Vaccine
* Smooth bottom tab experience with custom styling

---

<<<<<<< HEAD
## UI / UX Design
=======
## 🎨 UI / UX Design
>>>>>>> develop

* Designed using **Figma**
* Clean, soft card-based layout
* Consistent red brand color (`baseRed`)
* Minimal, pet-friendly design language
* SwiftUI previews enabled for rapid UI iteration

---

<<<<<<< HEAD
## Tech Stack
=======
## 🛠 Tech Stack
>>>>>>> develop

| Technology           | Usage                        |
| -------------------- | ---------------------------- |
| **SwiftUI**          | UI development               |
| **Swift**            | Core logic                   |
| **MVC Architecture** | Clean separation of concerns |
| **Xcode**            | Development                  |
| **Figma**            | UI/UX design                 |
| **Git & GitHub**     | Version control              |

---

<<<<<<< HEAD
## Architecture
=======
## 🧱 Architecture
>>>>>>> develop

The app follows a **clean, beginner-friendly MVC structure**:

```
PawPing/
│
├── Models/
│   ├── ActivityModel.swift
│   ├── VaccineModel.swift
│   └── AuthModel.swift
│
├── Views/
│   ├── ActivityView.swift
│   ├── VaccineView.swift
│   ├── LoginView.swift
│   └── CreateAccountView.swift
│
├── Components/
│   ├── CircularProgressBarView.swift
│   ├── MealsCardView.swift
│   ├── VaccineRowView.swift
│   └── AuthTextField.swift
│
├── Stores/
│   └── VaccineStore.swift
│
└── PawPingApp.swift
```
<<<<<<< HEAD
---

## Key App Logic
=======

### Why MVC?

* Clear separation of logic and UI
* Easy to debug and scale
* Perfect for student + team projects
* Ready for backend and persistence integration

---

## 🔁 Key App Logic
>>>>>>> develop

### Vaccine Flow

```
Upcoming / Missed
      ↓
 Mark as Done
      ↓
   History
```

* State managed centrally using `ObservableObject`
* Views remain lightweight and reusable

---

<<<<<<< HEAD
## SwiftUI Previews
=======
## 🧪 SwiftUI Previews
>>>>>>> develop

All major views include SwiftUI previews:

* `ActivityView`
* `VaccineView`
* `VaccineRowView`
* `LoginView`
* `CreateAccountView`

This enables:

* Faster UI development
* Safer refactoring
* Easier collaboration

---

<<<<<<< HEAD
## Planned Features

* Firebase Authentication
* CoreData / CloudKit persistence
* Vaccine Passport PDF export
* Push notifications for upcoming vaccines
* Multi-pet support

---

## Team
=======
## 🚀 Planned Features

* 🔐 Firebase Authentication
* 💾 CoreData / CloudKit persistence
* 📄 Vaccine Passport PDF export
* 🔔 Push notifications for upcoming vaccines
* 🐶 Multi-pet support
* 🌙 Dark mode support

---

## 🧑‍💻 Team
>>>>>>> develop

This project is built collaboratively as part of a **student iOS development team**, focusing on:

* Clean code practices
* Real-world app architecture
* UI/UX excellence
* Scalable feature design

---

<<<<<<< HEAD

## License
=======
## 📌 Getting Started

1. Clone the repository

   ```bash
   git clone https://github.com/atulrai07/PawPing.git
   ```

2. Open in Xcode

   ```bash
   open PawPing.xcodeproj
   ```

3. Run on Simulator or Device
   *(iOS 17+ recommended)*

---

## 📄 License
>>>>>>> develop

This project is currently for **educational and learning purposes**.
License will be added later.
