# ephenotes App Store Submission - Quick Reference

## 📱 App Information

| Field | Value |
|-------|-------|
| **App Name** | ephenotes |
| **Subtitle** | Quick Notes & Ideas |
| **Bundle ID** | com.ephenotes.ephenotes |
| **Version** | 1.0.0 |
| **Build** | 1 |
| **Category** | Productivity (Primary), Business (Secondary) |
| **Age Rating** | 4+ |
| **Price** | Free |

## 🎨 Brand Colors

| Element | Color | Hex Code |
|---------|-------|----------|
| **App Icon Note** | Material Green | #4CAF50 |
| **Priority Indicator** | Material Orange | #FF9800 |
| **Background** | White | #FFFFFF |

## 📏 Screenshot Sizes

| Device | Resolution | Orientation |
|--------|------------|-------------|
| iPhone 6.7" | 1290 x 2796 | Portrait |
| iPhone 6.5" | 1242 x 2688 | Portrait |
| iPhone 5.5" | 1242 x 2208 | Portrait |
| iPad Pro 12.9" | 2048 x 2732 | Portrait/Landscape |
| iPad Pro 11" | 1668 x 2388 | Portrait/Landscape |

**Required:** Minimum 3, Maximum 10 screenshots per device size

## 📝 App Description (Short Version)

**Tagline:** Quick notes for busy minds

**Elevator Pitch:**  
ephenotes is a privacy-first note-taking app for quick capture and smart organization. All your notes stay on your device - no cloud, no tracking, complete privacy.

**Key Features:**
- ⚡ Instant note creation
- 🎯 Priority-based organization
- 🎨 Color coding
- 📌 Pin important notes
- 🔍 Real-time search
- 🔒 Complete privacy

## 🔑 Keywords

```
notes, productivity, quick, organize, priority, privacy, offline, tasks, ideas, simple
```

## 📧 Contact Information

| Purpose | Email |
|---------|-------|
| **General Support** | support@ephenotes.com |
| **Beta Testing** | beta@ephenotes.com |
| **Privacy Questions** | privacy@ephenotes.com |
| **Press Inquiries** | press@ephenotes.com |

## 🚀 Build Commands

### Generate Icons
```bash
cd ios/AppStore/AppIcon
python3 generate_icons.py
```

### Build for Release
```bash
flutter clean
flutter pub get
flutter build ios --release
```

### Open in Xcode
```bash
open ios/Runner.xcworkspace
```

### Archive for App Store
1. In Xcode: Product → Archive
2. Wait for archive to complete
3. Click "Distribute App"
4. Select "App Store Connect"
5. Upload to App Store Connect

## 📊 Technical Specifications

| Requirement | Value |
|-------------|-------|
| **Minimum iOS** | 13.0 |
| **Supported Devices** | iPhone, iPad |
| **Orientations** | Portrait (iPhone), All (iPad) |
| **Languages** | English (U.S.) |
| **File Size** | ~15 MB (estimated) |
| **Permissions** | None required |

## ✅ Pre-Submission Checklist (Quick)

- [x] App builds without errors
- [x] All tests passing (94/94)
- [x] App icons generated
- [ ] Screenshots captured
- [x] Metadata complete
- [x] Privacy policy ready
- [ ] TestFlight testing done
- [ ] Final build uploaded

## 🎯 Review Notes for Apple

```
ephenotes is a productivity app for quick note-taking with priority-based organization.

Key Points:
- All data stored locally on device
- No network connectivity required or used
- No user accounts or authentication
- No data collection or analytics
- Privacy-first design

The app is fully functional and ready for review. No demo account needed as the app works without user accounts.

All features are accessible and tested with VoiceOver. The app follows Apple's Human Interface Guidelines and Material Design principles.
```

## 📱 TestFlight Beta Testing

### Internal Group
- **Size:** 5-8 testers
- **Duration:** 2 days
- **Focus:** Core functionality validation

### External Group
- **Size:** 25-50 testers
- **Duration:** 1-2 weeks
- **Focus:** Real-world usage and feedback

### Beta Feedback Email
```
Subject: ephenotes Beta Feedback

Device: [iPhone/iPad model]
iOS Version: [Version]
Issue Type: [Crash/Bug/Usability/Suggestion]

Description:
[Your feedback here]

Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [What happened]
```

## 🔗 Important URLs

| Resource | URL |
|----------|-----|
| **App Store Connect** | https://appstoreconnect.apple.com |
| **Developer Portal** | https://developer.apple.com |
| **TestFlight** | https://testflight.apple.com |
| **Review Guidelines** | https://developer.apple.com/app-store/review/guidelines/ |
| **HIG** | https://developer.apple.com/design/human-interface-guidelines/ |

## 📅 Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| **Development** | Complete | ✅ Done |
| **Asset Creation** | 2-3 days | 🔄 In Progress |
| **TestFlight Beta** | 1-2 weeks | ⏳ Pending |
| **App Store Review** | 1-7 days | ⏳ Pending |
| **Launch** | Day 1 | ⏳ Pending |

**Target Launch Date:** March 1, 2026

## 🆘 Common Issues & Solutions

### Issue: Build fails in Release mode
**Solution:** 
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

### Issue: Icons not showing in Xcode
**Solution:**
1. Clean build folder (Cmd+Shift+K)
2. Delete derived data
3. Restart Xcode
4. Rebuild project

### Issue: Screenshots wrong size
**Solution:**
- Use iOS Simulator for exact sizes
- Verify device selection matches requirements
- Use `xcrun simctl io booted screenshot file.png`

### Issue: App Store Connect upload fails
**Solution:**
1. Verify certificates are valid
2. Check provisioning profiles
3. Ensure bundle ID matches
4. Try uploading via Xcode Organizer
5. Check Application Loader logs

## 📞 Emergency Contacts

### Apple Developer Support
- **Phone:** 1-800-633-2152
- **Hours:** Business hours (varies by region)
- **Email:** Through Developer Portal

### Internal Team
- **Project Lead:** [Name] - [Phone]
- **Developer:** [Name] - [Phone]
- **Marketing:** [Name] - [Phone]

## 💡 Pro Tips

1. **Submit Early in Week:** Monday-Wednesday submissions typically review faster
2. **Respond Quickly:** Answer reviewer questions within 24 hours
3. **Test Thoroughly:** Use TestFlight to catch issues before submission
4. **Monitor Status:** Check App Store Connect daily during review
5. **Prepare Marketing:** Have launch materials ready before approval

## 🎉 Launch Day Checklist

- [ ] Verify app is live on App Store
- [ ] Test download and installation
- [ ] Post on social media
- [ ] Send press release
- [ ] Email beta testers
- [ ] Update website
- [ ] Monitor reviews and ratings
- [ ] Respond to user feedback
- [ ] Celebrate with team! 🎊

---

**Quick Reference Version:** 1.0  
**Last Updated:** February 4, 2026  
**For:** ephenotes v1.0.0 iOS App Store Submission