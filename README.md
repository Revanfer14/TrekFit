# TrekFit

> **Know your limits before you hit the trail.**
> TrekFit uses the Chester Step Test to measure your aerobic fitness and tells you which mountain you're ready to climb.

---

## Overview

TrekFit is an iOS app that guides you through the **Chester Step Test (CST)** — a clinically validated submaximal aerobic fitness test — entirely from your iPhone and Apple Watch. No lab equipment, no treadmill, no trainer required.

After the test, TrekFit calculates your **VO₂ max** and compares it against the minimum aerobic requirements for popular hiking routes in Indonesia, giving you a personalized readiness score before you head to the trailhead.

---

## Features

- **Guided Chester Step Test** — 5 progressive stages, 2 minutes each, with audio metronome cues and a live countdown
- **Real-time heart rate monitoring** via Apple Watch using HealthKit + WatchConnectivity
- **VO₂ max calculation** based on the Sykes & Roberts (2004) linear regression method
- **Mountain readiness check** — compare your VO₂ max against Mt. Prau, Mt. Gede, Mt. Semeru, and more
- **AR step measurement** — use your iPhone camera to measure step height via ARKit/RealityKit
- **Manual step height entry** with preset quick-select options
- **Test history log** — track your fitness progress over time
- **Automatic test stop** when heart rate reaches 80% of max HR (safety threshold)

---

## How It Works

```
[Profile Setup] → [Select Mountain] → [Measure Step] → [Connect Apple Watch]
      ↓
[Guided Test — 5 Stages × 2 min]
      ↓
[Live HR Monitoring via Watch]
      ↓
[Auto-stop at 80% Max HR or Stage 5]
      ↓
[VO₂ Max Result + Mountain Recommendation]
      ↓
[Save to History Log]
```

**Max HR** = 220 − Age  
**Target HR (stop threshold)** = Max HR × 80%  
**VO₂ Max** = Linear extrapolation from workload vs. heart rate across completed stages

---

## Requirements

| Requirement | Details |
|---|---|
| iPhone | iOS 18+ |
| Apple Watch | watchOS 11+ (paired) |
| Workout Mode | Must be active on Watch during test (Activate TrekFit's companion app in Watch) |
| Permissions | HealthKit (Heart Rate read/write), Camera (AR measurement) |

---

## Tech Stack

- **SwiftUI** — UI for both iPhone and Apple Watch
- **HealthKit** — Heart rate data access
- **WatchConnectivity** — Real-time HR data streaming from Watch to iPhone
- **HKWorkoutSession / HKLiveWorkoutBuilder** — Watch-side workout session management
- **ARKit + RealityKit** — Step height measurement via camera
- **Lottie** — Animated guide illustrations
- **UserDefaults** — Local persistence for profile, test results, and history

---

## Project Structure

```
TrekFit/
├── Views/
│   ├── LandingView.swift
│   ├── SetProfileView.swift
│   ├── SelectMountainView.swift
│   ├── MeasureBoxView.swift
│   ├── ConnectWatchView.swift
│   ├── GuideView.swift
│   ├── CircleLoadingView.swift
│   ├── ChesterTestView.swift
│   ├── ResultView.swift
│   ├── TestDetailView.swift
│   └── LogHistoryView.swift
├── ViewModels/
│   ├── ChesterTestViewModel.swift
│   ├── ResultViewModel.swift
│   ├── SetProfileViewModel.swift
│   ├── SelectMountainViewModel.swift
│   └── ARMeasurementViewModel.swift
├── Models/
│   ├── UserProfile.swift
│   ├── ChesterTest.swift
│   ├── Mountain.swift
│   ├── TestResult.swift
│   └── MeasurementStore.swift
├── Services/
│   ├── HeartRateMonitor.swift
│   ├── AudioService.swift
│   ├── Haptics.swift
│   └── MountainStorage.swift
├── Components/
│   ├── InstructionCard.swift
│   ├── MountainCardView.swift
│   ├── VO2MaxCardView.swift
│   ├── RecommendedMountainCard.swift
│   ├── CameraMeasurementSheet.swift
│   ├── ManualInputCard.swift
│   └── ...
└── Extensions/
    └── Color+Hex.swift

TrekFitWatch Watch App/
├── WorkoutView.swift
├── WatchSessionManager.swift
└── TrekFitWatchApp.swift
```

---

## Mountains Supported

| Mountain | Min VO₂ Max |
|---|---|---|
| Mount Prau | 25.6 ml/kg/min |
| Mount Gede | 33.6 ml/kg/min |
| Mount Semeru | 38.4 ml/kg/min |

---

## Setup

1. Clone the repository
2. Open `TrekFit.xcodeproj` in Xcode
3. Set your development team in **Signing & Capabilities** for both the `TrekFit` and `TrekFitWatch Watch App` targets
4. Connect your iPhone and Apple Watch
5. Select the `TrekFit` scheme and run on your device

> **Note:** HealthKit and WatchConnectivity features require a physical device. The Simulator does not support heart rate data.

---

## Permissions

The following usage descriptions must be present (already configured in the project):

```
NSHealthShareUsageDescription  — Heart rate read access for the Chester Step Test
NSHealthUpdateUsageDescription — Save workout data to Health app  
NSCameraUsageDescription       — AR step height measurement
```

---

## License

This project is for educational purposes. All rights reserved.
