Bin It Right
    An AI-powered mobile application that promotes proper waste segregation through real-time image classification and interactive educational mini-games.

    Built with Flutter and TensorFlow Lite, the app runs fully on-device — no internet required.

Features
    AI Waste Classification
        Real-time waste detection using the device camera
        On-device inference with TensorFlow Lite
        Offline support (no API calls)
        Confidence threshold filtering
        Animated bin result with color feedback

    Waste Categories
        Biodegradable
        Recyclable
        Non-recyclable
        Reusable

    Educational Mini-Games
        Clean the Park
            Collect scattered trash in an interactive park scene
            Teaches environmental responsibility
            Custom collision logic and object spawning
            Built using pure Flutter (no game engine)

        Sort the Waste
            Drag-and-drop waste items into the correct bin
            Reinforces proper segregation habits
            Instant visual feedback for correct/incorrect answers
        
        What Bin Is It? (Quiz Mode)
            Multiple-choice waste segregation quiz
            Randomized questions
            Score tracking system

Tech Stack
    Mobile App
    Flutter
    Dart
    tflite_flutter
    Camera plugin

Machine Learning
    TensorFlow / Keras
    Transfer learning (Xception)
    TensorFlow Lite conversion

UI/UX Highlights
    Animated classification result cards
    Color-coded bin feedback
    Gamified learning experience
    Mobile-first responsive layout

Performance Notes
    Runs fully offline
    Optimized TFLite model for mobile
    Uses confidence threshold to avoid low-quality predictions
    Designed to prevent UI blocking during inference

Use Case
    This app is designed for:
    Environmental education
    School awareness programs
    Waste management campaigns
    Smart city prototypes

Author
Jeremie Deuna
Flutter Developer
AI-integrated Mobile Apps
Environmental Tech Enthusiast

License
This project is for educational and portfolio purposes.