# PawPing – Smart Pet Care Companion

PawPing is a modern iOS application designed to help pet owners **track, manage, and care for their pets’ daily health and activities** in a simple, intuitive, and visually engaging way.

From **daily walks and meals** to **vaccination reminders and medical history**, PawPing brings all essential pet-care features into one clean and user-friendly app.

---

## Features

### Activity Tracking

* Track daily walk goals and progress
* Circular progress visualization
* Quick activity overview on the home screen

### Meals & Care

* Scheduled meals (morning, afternoon, night)
* Visual indicators for taken / pending meals
* Simple toggle-based interaction

### Vaccine Management

* Dedicated Vaccine tab with 3 sections:

  * **Upcoming Vaccines**
  * **Missed Vaccines**
  * **Vaccination History**
* “Mark as Done” action:

  * Moves vaccines from Upcoming/Missed → History
* Stores last taken date and clinic details
* Export Vaccine Passport (planned)

### Profile & Authentication

* Clean login and account creation UI
* Email & password authentication UI
* Social login options:

  * Continue with Apple
  * Continue with Google
* Designed for easy backend integration (Firebase-ready)

### Tab-Based Navigation

* Activity
* Care
* Vaccine
* Smooth bottom tab experience with custom styling

---

## UI / UX Design

* Designed using **Figma**
* Clean, soft card-based layout
* Consistent red brand color (`baseRed`)
* Minimal, pet-friendly design language
* SwiftUI previews enabled for rapid UI iteration

---

## Tech Stack

| Technology           | Usage                        |
| -------------------- | ---------------------------- |
| **SwiftUI**          | UI development               |
| **Swift**            | Core logic                   |
| **MVC Architecture** | Clean separation of concerns |
| **Xcode**            | Development                  |
| **Figma**            | UI/UX design                 |
| **Git & GitHub**     | Version control              |

---

## Architecture

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
---

## Key App Logic

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

## SwiftUI Previews

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

## Planned Features

* Firebase Authentication
* CoreData / CloudKit persistence
* Vaccine Passport PDF export
* Push notifications for upcoming vaccines
* Multi-pet support

---

## Team

This project is built collaboratively as part of a **student iOS development team**, focusing on:

* Clean code practices
* Real-world app architecture
* UI/UX excellence
* Scalable feature design

---


## License

This project is currently for **educational and learning purposes**.
License will be added later.
