# MetroPulse
## Real-Time Crowd Intelligence for Bengaluru Metro

MetroPulse is a community-driven mobile application that transforms the daily metro commute in Bengaluru. By providing real-time crowd density information and predictive insights, it helps commuters avoid packed trains and reclaim their journey.

<!-- ## Demo

*Coming Soon: Demo video and screenshots* -->

## Key Features

- 🚇 **Real-Time Crowd Intelligence**: Know how crowded each station is before you arrive, powered by live community reports.
- 🎯 **Coach-Level Granularity**: Get specific insights like "Rear coach less crowded" for tactical boarding decisions.
- 🔮 **Predictive Crowd Forecasting**: See expected crowd levels throughout the day using ML-powered predictions based on historical ridership data.
- 🗺️ **Smart Trip Planner**: Get three route options — Fastest, Least Crowded, and Balanced, with real-time crowd data integrated.
- 🤝 **Community-Powered**: Built by commuters, for commuters. Every report makes the system smarter for everyone.
- 📍 **Live Interactive Map**: Visualize crowd levels across all stations on Purple, Green, and Yellow lines with color-coded markers (🟢🟡🔴).
- 🎖️ **Trust & Verification**: Future-ready architecture for community trust scores and gamification to ensure data quality.
- 🔒 **Privacy by Design**: No photo uploads, anonymous reporting, minimal data collection; your privacy is paramount.

## 💡 Why MetroPulse Exists

<details>

The daily commute on Bengaluru's Namma Metro has escalated from a public convenience into a city-wide crisis. With daily ridership consistently surging past 900,000 passengers (and projected to cross 1 million), the system is straining under pressure. Key interchange stations like Majestic witness over 220,000 daily footfalls, with trains so packed that security staff must physically push commuters into coaches.

The problems are systemic:
- **Supply Chain Failures**: Delayed delivery of new train coaches from manufacturers has led to wait times of 15-25 minutes on new lines.
- **Poor Operational Planning**: Incidents like running holiday schedules on working days have caused "absolute chaos" at major stations.
- **Digital Void**: The official BMRCL app is plagued with bugs, slow servers, and lacks essential features like real-time crowd information.

MetroPulse is a necessary intervention to impose predictability and control onto a fundamentally unreliable and overburdened system. It's not just an app to navigate crowds, it's like a tool to reclaim your commute and your time.

</details>

### The Real Problem

<details>

This isn't just about crowded trains during rush hour. It's about:
- **Lost Productivity**: Commuters spending 1.5+ hours each way, unable to even breathe in packed coaches
- **Unpredictability**: Never knowing if you'll be crushed into a coach or wait 25 minutes for the next train
- **No Information**: The official app provides no crowd data, no real-time updates, no trip planning
- **System Failures**: A complete breakdown of capacity planning and operational management

The market validates this need: competitor apps like NammaConnect are actively developing "Station Vibes & Crowd Meter" features. Apps like Chalo already provide crowd density for buses. The technology exists, it just doesn't exist for Namma Metro yet.

MetroPulse fills this void with a community-driven, open-source solution that puts commuters first.

</details>

## Quick Start

### 1. Installation

> **Coming Soon:** MetroPulse will be available on Google Play Store and Apple App Store. Currently being developed as a 24-hour hackathon MVP.

**For Development Installation:**
```bash
# Clone the repository
git clone https://github.com/yourusername/metropulse.git
cd metropulse

# Install dependencies
flutter pub get

# Run the app
flutter run
```

**Once Published:**
- Download from Play Store (Android) or App Store (iOS)
- Open the app and grant location permissions
- Start reporting and planning your trips!

### 2. Get Started

MetroPulse works immediately with no account required for basic features.

### 3. Basic Usage

- **Check Crowd Levels**: View the live crowd map to see real-time station density
- **Plan Your Trip**: Use the Smart Trip Planner to compare Fastest, Least Crowded, and Balanced routes
- **Report Crowds**: Submit quick 1-5 ratings to help fellow commuters
- **View Predictions**: See forecasted crowd levels for your planned travel time

## Usage Guide

### Core Features

**Home Dashboard**
- Quick view of nearby station crowd levels
- Color-coded indicators (🟢 Low, 🟡 Moderate, 🔴 High)
- Direct access to map and alerts

**Smart Trip Planner**
- Enter origin and destination
- Get three route options with crowd data
- Filter for low-crowding routes only
- View crowd trends for your travel time

**Live Crowd Map**
- Interactive map of Purple, Green, and Yellow lines
- Tap any station for detailed crowd information
- See report counts and timestamps for transparency

**Report Crowd**
- Simple 1-5 scale with intuitive icons
- Auto-tagged with location and time
- No photo uploads for privacy and simplicity

### Commands & Actions

- **🗺 View Map**: Open the live network-wide crowd map
- **⚠ View All Alerts**: See system-wide service alerts
- **🔁 Refresh**: Get the latest crowd data
- **📈 View Trends**: See predictive crowd forecasts

## Technical Architecture

### The Stack

**Frontend**
- **Flutter**: Single codebase for Android and iOS with hot reload for rapid development
- **Google Maps**: Interactive map visualization
- **Provider/Riverpod**: Lightweight state management

**Backend**
- **Supabase**: Open-source Firebase alternative providing PostgreSQL, real-time updates, and authentication
- **PostgREST API**: Auto-generated RESTful API
- **Realtime Engine**: WebSocket-based live updates

**Predictive Model**
- **Python + TensorFlow/PyTorch**: GRU/LSTM model for time-series prediction
- **Pre-computed predictions**: Static dataset generated from historical ridership data

### Data Flow

```
User Reports → Supabase Database → Real-time Updates → All Connected Clients
                     ↓
              Aggregation Engine
                     ↓
         Color-Coded Crowd Levels
```

### Database Schema

**Stations Table**
- Station metadata (name, line, coordinates)

**Crowd Reports Table**
- User-submitted reports (station, coach position, level, timestamp)

**Predicted Crowd Table**
- Pre-computed ML predictions (station, day, time, predicted level)

## Privacy & Ethics

MetroPulse is designed with privacy-first principles:

- ✅ **Anonymous Reporting**: No account required to submit crowd reports
- ✅ **No Photo Uploads**: Prevents voyeurism and privacy violations
- ✅ **Minimal Data Collection**: Location used only to identify nearest station, never stored or tracked
- ✅ **Aggregated Display**: Show "21 reports in last hour," not individual data points
- ✅ **Transparent Consent**: Clear explanations for all permissions requested

## Future Roadmap

### Phase 2: Refinement 
- Dynamic ML model retraining with live crowd-sourced data
- Full gamification and community trust system
- User profiles with contribution tracking and rewards
- Station facilities information (parking, elevators, etc.)
- First/last train timings

### Phase 3: Ecosystem 
- **Last-Mile Integration**: Partner with Namma Yatri, Yulu, and other services for end-to-end journey planning
- **BMRCL Partnership**: Official integration with BMRCL data streams and AI crowd management system
- **Pan-India Expansion**: Adapt to Delhi, Mumbai, Chennai, Kolkata metro systems
- **Multi-Modal Support**: Expand to BMTC buses and other public transport

## Contributing

MetroPulse is an open-source project built by commuters, for commuters. We welcome contributions from:

- **Developers**: Flutter, backend, ML expertise
- **UI/UX Designers**: Improving user experience and visual design
- **Data Scientists**: Enhancing prediction models and analytics
- **Commuters**: Bug reports, feature requests, crowd reports

**Get Involved:**
1. Star and fork the repository
2. Check out open issues
3. Read our contribution guidelines
4. Submit pull requests

**Join the Movement.**

## Engaging with BMRCL

MetroPulse aims to be a partner, not an adversary:

- **Social Media**: Active engagement via [@OfficialBMRCL](https://twitter.com/OfficialBMRCL) on X
- **Formal Channels**: contactus@bmrc.co.in and travelhelp@bmrc.co.in
- **Value Proposition**: Free granular crowd data to help BMRCL optimize train frequency and manage platform congestion

## License

MetroPulse is licensed under the MIT License. Free forever, open-source forever.

---

## Mission Statement

> "By the commuters, for the commuters. Reclaim your commute. Power Bengaluru's Metro with people data."

---

**Enjoy your stress-free commute!** 🚇✨

<!-- A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
-->