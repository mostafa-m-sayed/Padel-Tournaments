//
//  AppIconSetupGuide.md
//  Padel-Tournaments
//
//  Created by Mostafa Sayed on 12/05/2026.
//

# App Icon Setup Guide

## Step 1: Prepare Your Icon
- Create a 1024x1024px PNG icon
- Ensure it follows iOS design guidelines
- No transparency, rounded corners will be added automatically

## Step 2: Add to Xcode
1. **Open Xcode** → Navigate to your project
2. **Find Assets.xcassets** in the Project Navigator
3. **Click on "AppIcon"** in the Assets catalog
4. **Drag your 1024x1024 icon** into the "App Store iOS 1024pt" slot

Xcode will automatically generate all required sizes:
- iPhone: 60x60, 87x87, 120x120, 180x180
- iPad: 76x76, 152x152, 167x167
- Settings: 58x58, 87x87
- Notification: 40x40, 60x60

## Step 3: Verify Setup
1. **Build and run** your app
2. **Check home screen** - icon should appear
3. **Test on different devices** - iPhone, iPad
4. **Check Settings app** - your app should show the icon

## Step 4: App Store Preparation
- The 1024x1024 icon will be used for App Store listing
- Ensure it looks good in App Store search results
- Test visibility against different backgrounds

## Design Tips
- Keep it simple - complex details don't show at small sizes
- Use contrasting colors
- Avoid text or small details
- Make it unique and memorable
- Test at 29x29px to ensure recognizability

## Padel Tournament App Icon Ideas
- 🎾 Padel racket with ball
- 🏆 Trophy with padel elements
- 📊 Tournament bracket stylized
- 🎯 Combination of court, racket, and trophy

Remember: Your icon is the first impression users have of your app!