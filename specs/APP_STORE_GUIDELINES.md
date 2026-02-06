# App Store Guidelines Compliance

This document provides comprehensive checklists to ensure ephenotes complies with Apple App Store and Google Play Store guidelines.

## Table of Contents

1. [Apple App Store Guidelines](#apple-app-store-guidelines)
2. [Google Play Store Guidelines](#google-play-store-guidelines)
3. [Common Rejection Reasons](#common-rejection-reasons)
4. [Pre-Submission Checklist](#pre-submission-checklist)
5. [Review Response Templates](#review-response-templates)

---

## Apple App Store Guidelines

Reference: [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### 1. Safety

#### 1.1 Objectionable Content

- [ ] **1.1.1** App does not contain defamatory, discriminatory, or mean-spirited content
- [ ] **1.1.2** No realistic portrayals of violence toward people or animals
- [ ] **1.1.3** No depictions encouraging illegal activities, drugs, or excessive weapons
- [ ] **1.1.4** No overtly sexual or pornographic material
- [ ] **1.1.5** No inflammatory religious commentary or inaccurate religious texts
- [ ] **1.1.6** False information that could be harmful or misleading

**ephenotes Status:** ✅ Compliant (content-neutral note-taking app)

#### 1.2 User-Generated Content

- [ ] **1.2.1** Requires content moderation (if applicable)
- [ ] **1.2.2** Mechanism to report objectionable content
- [ ] **1.2.3** Ability to block abusive users
- [ ] **1.2.4** Published contact info for takedown requests

**ephenotes Status:** ✅ N/A (single-user, offline app - no user-generated content sharing)

#### 1.3 Kids Category

- [ ] **1.3.1** Apps in Kids Category follow special requirements
- [ ] **1.3.2** No third-party analytics or advertising
- [ ] **1.3.3** No links out of the app (except parental gate)
- [ ] **1.3.4** Age-appropriate content

**ephenotes Status:** ✅ N/A (not targeting Kids Category - rated 4+, designed for adults)

#### 1.4 Physical Harm

- [ ] **1.4.1** Medical apps have disclaimers and are from recognized entities
- [ ] **1.4.2** Drug dosage calculators must be submitted by recognized entities
- [ ] **1.4.3** Apps encouraging consumption of tobacco, illegal drugs, or alcohol are prohibited
- [ ] **1.4.4** Apps facilitating DUI or similar violations are prohibited
- [ ] **1.4.5** Apps encouraging dangerous activities (e.g., bomb-making) are prohibited

**ephenotes Status:** ✅ Compliant (general productivity app)

#### 1.5 Developer Information

- [ ] **1.5.1** Apps from a developer with terrorism or hate group connections will be rejected
- [ ] **1.5.2** Apps with untruthful or misleading developer information will be rejected

**ephenotes Status:** ✅ Compliant (legitimate developer)

#### 1.6 Data Security

- [ ] **1.6.1** Apps must use appropriate security measures when handling personal data
- [ ] **1.6.2** Apps must comply with applicable privacy and data security laws
- [ ] **1.6.3** Apps that provide services in regulated fields must submit proof of licenses

**ephenotes Status:** ✅ Compliant (no personal data collected, all data stored locally)

### 2. Performance

#### 2.1 App Completeness

- [ ] **2.1.1** App must be complete and ready for review
- [ ] **2.1.2** App must not be a beta, demo, or trial version
- [ ] **2.1.3** Provide complete, working functionality
- [ ] **2.1.4** Include all necessary metadata and URLs

**ephenotes Status:** ✅ Compliant (complete app with all features functional)

#### 2.2 Beta Testing

- [ ] **2.2.1** Use TestFlight for beta testing only
- [ ] **2.2.2** Beta apps submitted to App Store will be rejected

**ephenotes Status:** ✅ Compliant (TestFlight for beta, App Store for production)

#### 2.3 Accurate Metadata

- [ ] **2.3.1** App name, description, and screenshots accurately represent the app
- [ ] **2.3.2** Don't include placeholder text
- [ ] **2.3.3** Include app-specific keywords in metadata
- [ ] **2.3.4** Use app category appropriate to the app's content and function
- [ ] **2.3.5** Screenshots must show the app in use
- [ ] **2.3.6** Choose the most appropriate category for your app
- [ ] **2.3.7** Provide accurate release notes
- [ ] **2.3.8** Metadata must be appropriate for the youngest age in your age range
- [ ] **2.3.9** Don't use terms like "beta" or "pre-release" in metadata
- [ ] **2.3.10** Ensure all URLs in app are working and lead to appropriate content
- [ ] **2.3.11** Support contact info must be current and working

**ephenotes Checklist:**
- [ ] App name: "ephenotes" (accurate)
- [ ] Description matches functionality
- [ ] Screenshots show actual app screens
- [ ] Category: Productivity (appropriate)
- [ ] Keywords relevant to note-taking
- [ ] Support URL functional
- [ ] Privacy policy URL functional

#### 2.4 Hardware Compatibility

- [ ] **2.4.1** App must work on all devices and screen sizes it claims to support
- [ ] **2.4.2** Universal apps must work natively on iPhone, iPad, and iPod touch
- [ ] **2.4.3** Watch apps must function independently

**ephenotes Requirements:**
- [ ] iPhone support (all screen sizes)
- [ ] iPad support (all screen sizes)
- [ ] Dark mode support
- [ ] Landscape and portrait orientation support

#### 2.5 Software Requirements

- [ ] **2.5.1** Apps must use public APIs only
- [ ] **2.5.2** Apps may only use Documented APIs
- [ ] **2.5.3** Audio/video downloading must use proper entitlements
- [ ] **2.5.4** Multi-platform services must comply with each platform's guidelines
- [ ] **2.5.5** Apps that alter or disable standard features are prohibited
- [ ] **2.5.6** Apps should use iOS built-in features where possible
- [ ] **2.5.7** Video streaming must use HTTP Live Streaming over HTTPS
- [ ] **2.5.8** Apps must restore full functionality after call interruptions
- [ ] **2.5.9** Apps must not suggest device restart
- [ ] **2.5.10** Apps using Face ID must use LocalAuthentication framework
- [ ] **2.5.11** SiriKit intents must be implemented correctly
- [ ] **2.5.12** Apps using Camera must implement photo capture
- [ ] **2.5.13** Apps must respect VPN configurations
- [ ] **2.5.14** Apps using push notifications must comply with guidelines

**ephenotes Status:** ✅ Compliant (uses standard Flutter/iOS APIs, no special features)

### 3. Business

#### 3.1 Payments

- [ ] **3.1.1** In-App Purchase must be used for digital goods/services
- [ ] **3.1.2** Apps may not use alternative purchasing mechanisms
- [ ] **3.1.3** Free apps may not unlock full features through external purchases
- [ ] **3.1.4** Apps may not require payment for basic functionality
- [ ] **3.1.5** Physical goods/services may use alternative payment methods

**ephenotes Status:** ✅ Compliant (free app, no purchases)

#### 3.2 Other Business Model Issues

- [ ] **3.2.1** Acceptable business models: free, freemium, subscriptions, paid
- [ ] **3.2.2** No "cryptocurrency mining" apps

**ephenotes Status:** ✅ Compliant (free app)

### 4. Design

#### 4.1 Copycats

- [ ] **4.1.1** Don't simply copy the latest popular app
- [ ] **4.1.2** Don't create multiple bundle IDs for the same app
- [ ] **4.1.3** Do something unique or provide significant value

**ephenotes Status:** ✅ Compliant (unique 140-character limit, ephemeral notes concept)

#### 4.2 Minimum Functionality

- [ ] **4.2.1** App must do something useful or provide some entertainment
- [ ] **4.2.2** More than a website wrapped in an app
- [ ] **4.2.3** Apps should not require extensive reading before understanding

**ephenotes Status:** ✅ Compliant (clear note-taking functionality, native app)

#### 4.3 Spam

- [ ] **4.3.1** Don't create duplicate apps for the same content
- [ ] **4.3.2** "Select which business/location/event" apps are spam
- [ ] **4.3.3** Use In-App Purchase to unlock functionality, not separate apps

**ephenotes Status:** ✅ Compliant (single-purpose app)

#### 4.4 Extensions

- [ ] **4.4.1** Keyboard extensions provide keyboard functionality
- [ ] **4.4.2** Widgets provide timely, relevant information
- [ ] **4.4.3** Extensions don't advertise or market unless related to functionality

**ephenotes Status:** ✅ N/A (no extensions in v1.0)

#### 4.5 Apple Sites and Services

- [ ] **4.5.1** Don't use Apple trademarks without permission
- [ ] **4.5.2** Don't use Apple product names in app name
- [ ] **4.5.3** iTunes music previews must use proper attribution

**ephenotes Status:** ✅ Compliant (no Apple trademarks used)

### 5. Legal

#### 5.1 Privacy

- [ ] **5.1.1** Privacy Policy
  - [ ] Privacy policy URL provided in App Store Connect
  - [ ] Privacy policy clearly explains what data is collected and how it's used
  - [ ] Privacy policy URL is functional and publicly accessible
  - [ ] Privacy policy applies to the app being reviewed

- [ ] **5.1.2** Permission Requests
  - [ ] All permission requests include purpose strings
  - [ ] Purpose strings clearly explain why permission is needed
  - [ ] App handles denied permissions gracefully

- [ ] **5.1.3** Health and Research
  - [ ] N/A for ephenotes

- [ ] **5.1.4** Kids Apps
  - [ ] N/A for ephenotes (not targeting children)

- [ ] **5.1.5** Location Services
  - [ ] N/A for ephenotes (doesn't use location)

**ephenotes Privacy Checklist:**
- [ ] Privacy policy URL: https://ephenotes.app/privacy-policy
- [ ] Privacy policy states "no data collection"
- [ ] Privacy policy states "all data stored locally"
- [ ] No permissions requested (camera, location, contacts, etc.)
- [ ] App Privacy labels filled out (Data Not Collected)

#### 5.2 Intellectual Property

- [ ] **5.2.1** Generally
  - [ ] Only use content you have rights to use
  - [ ] App is not too similar to an Apple product
  - [ ] Don't use "Apple" or Apple products in app name

- [ ] **5.2.2** Third-Party Sites/Services
  - [ ] Must have permission to use third-party services
  - [ ] Provide proof of rights to use content

- [ ] **5.2.3** Audio/Video Downloading
  - [ ] Apps facilitating piracy will be rejected
  - [ ] Must have rights to stream/download content

- [ ] **5.2.4** Apple Trademarks
  - [ ] Don't use Apple trademarks without written permission

- [ ] **5.2.5** Apple Products
  - [ ] Don't use screenshots/images of Apple products

**ephenotes Status:** ✅ Compliant (original app, no third-party content, no Apple references)

#### 5.3 Gaming, Gambling, and Lotteries

- [ ] **5.3.1** Gambling apps must have necessary licensing
- [ ] **5.3.2** Lotteries require consideration, chance, and a prize
- [ ] **5.3.3** Apps offering real money gaming must use In-App Purchase

**ephenotes Status:** ✅ N/A (not a gaming or gambling app)

#### 5.4 VPN Apps

- [ ] **5.4.1** VPN apps must use NEVPNManager API

**ephenotes Status:** ✅ N/A (not a VPN app)

#### 5.5 Mobile Device Management

- [ ] **5.5.1** MDM apps must use Apple's MDM APIs

**ephenotes Status:** ✅ N/A (not an MDM app)

#### 5.6 Developer Code of Conduct

- [ ] **5.6.1** Treat everyone with respect
- [ ] **5.6.2** Don't engage in harassment, trolling, or spamming
- [ ] **5.6.3** Don't attempt to manipulate ratings or reviews
- [ ] **5.6.4** Don't use fraudulent purchase methods
- [ ] **5.6.5** Follow the law and be honest

**ephenotes Status:** ✅ Compliant (professional conduct)

---

## Google Play Store Guidelines

Reference: [Google Play Developer Policy Center](https://play.google.com/about/developer-content-policy/)

### 1. Restricted Content

#### 1.1 Child Safety

- [ ] **COPPA Compliance** (if targeting children under 13)
  - [ ] No behavioral advertising
  - [ ] No third-party analytics
  - [ ] Parental consent for data collection
  - [ ] Content appropriate for children

**ephenotes Status:** ✅ N/A (targeting adults, rated Everyone for broad compatibility)

#### 1.2 Inappropriate Content

- [ ] **Sexual Content** - None present
- [ ] **Hate Speech** - None present
- [ ] **Violence** - None present
- [ ] **Dangerous Products** - None promoted
- [ ] **Marijuana** - None referenced
- [ ] **Tobacco & Alcohol** - None referenced

**ephenotes Status:** ✅ Compliant (content-neutral productivity app)

#### 1.3 Intellectual Property

- [ ] **Copyright** - No copyrighted material used without permission
- [ ] **Trademarks** - No unauthorized use of trademarks
- [ ] **Counterfeit** - Not promoting counterfeit goods

**ephenotes Status:** ✅ Compliant (original app)

#### 1.4 Gambling

- [ ] Real-money gambling apps must be approved by Google
- [ ] Must be licensed in all deployment locations
- [ ] Must not be accessible to underage users

**ephenotes Status:** ✅ N/A (not a gambling app)

#### 1.5 Financial Services

- [ ] Apps offering financial services must comply with local laws
- [ ] Cryptocurrency apps must comply with all applicable laws

**ephenotes Status:** ✅ N/A (not a financial app)

### 2. Privacy, Deception, and Device Abuse

#### 2.1 User Data

- [ ] **Data Collection Disclosure**
  - [ ] Privacy policy URL provided
  - [ ] Clearly disclose data access, collection, use, and sharing
  - [ ] Handle user data securely (HTTPS transmission)
  - [ ] Data Safety form filled out accurately

- [ ] **Personal and Sensitive User Data**
  - [ ] Prominent disclosure before data collection
  - [ ] Data collection limited to what's disclosed
  - [ ] Don't sell personal data
  - [ ] Secure data transmission (TLS/SSL)

- [ ] **Permissions**
  - [ ] Request minimum permissions necessary
  - [ ] Only request permissions related to core functionality
  - [ ] Don't request permissions for tracking or ads

**ephenotes Privacy Checklist:**
- [ ] Privacy policy URL: https://ephenotes.app/privacy-policy
- [ ] Data Safety form: "No data collected"
- [ ] No permissions requested
- [ ] All data stored locally
- [ ] No network access required
- [ ] No third-party SDKs with data collection

#### 2.2 Deceptive Behavior

- [ ] **Misleading Claims**
  - [ ] App description is accurate
  - [ ] Screenshots show actual app functionality
  - [ ] Don't impersonate others
  - [ ] Don't make false claims about health, financial promises, etc.

- [ ] **System Interference**
  - [ ] Don't block or interfere with other apps
  - [ ] Don't modify system settings without user consent
  - [ ] Don't encourage users to disable security features

- [ ] **Manipulated Media**
  - [ ] Disclose when media is synthetic or manipulated

**ephenotes Status:** ✅ Compliant (accurate representation, no system interference)

#### 2.3 Malicious Behavior

- [ ] **Malware** - App does not contain malicious code
- [ ] **Mobile Unwanted Software** - Follows MUwS guidelines
  - [ ] Clear and honest app representation
  - [ ] Easy-to-use uninstall
  - [ ] No unauthorized changes to device
  - [ ] No deceptive behavior

**ephenotes Status:** ✅ Compliant (clean, transparent app)

### 3. Monetization and Ads

#### 3.1 Payments

- [ ] **Google Play Billing** must be used for:
  - [ ] In-app features or services (virtual items)
  - [ ] App functionality (subscriptions, upgrades)

- [ ] **Alternative payment methods** allowed for:
  - [ ] Physical goods
  - [ ] Physical services
  - [ ] Peer-to-peer payments
  - [ ] Account management

**ephenotes Status:** ✅ Compliant (free app, no payments)

#### 3.2 Ads

- [ ] Ads are clearly identified as ads
- [ ] Ads don't interfere with app functionality
- [ ] Ads don't trick users into clicking
- [ ] No disruptive ads (e.g., full-screen interstitials on launch)

**ephenotes Status:** ✅ Compliant (no ads)

#### 3.3 In-App Purchases

- [ ] Clearly disclose pricing and terms
- [ ] Use Google Play Billing system
- [ ] No misleading purchase flows

**ephenotes Status:** ✅ N/A (no in-app purchases)

### 4. Store Listing and Promotion

#### 4.1 App Promotion

- [ ] Don't manipulate placement in Google Play (no fake reviews, installs, ratings)
- [ ] Don't engage in rating manipulation
- [ ] Don't incentivize positive reviews
- [ ] No review gating (prompting only satisfied users to rate)

**ephenotes Status:** ✅ Compliant (organic reviews only)

#### 4.2 Metadata

- [ ] **App Title** - Accurately represents app, max 30 characters
- [ ] **Short Description** - Max 80 characters, no keywords stuffing
- [ ] **Full Description** - Max 4000 characters, accurate and complete
- [ ] **Graphics** - High quality, represent app accurately
  - [ ] App icon: 512x512, 32-bit PNG
  - [ ] Feature graphic: 1024x500
  - [ ] Screenshots: At least 2, show actual app

**ephenotes Checklist:**
- [ ] Title: "ephenotes" (9 chars, accurate)
- [ ] Short description: Clear, under 80 chars
- [ ] Full description: Detailed, accurate
- [ ] App icon: 512x512 PNG
- [ ] Feature graphic: 1024x500
- [ ] Screenshots: 4+ showing key features

#### 4.3 User Ratings, Reviews, and Installs

- [ ] Don't offer incentives for positive reviews
- [ ] Don't ask users to rate while using an incentive
- [ ] Don't manipulate install counts

**ephenotes Status:** ✅ Compliant (organic growth)

### 5. Families Policy

#### 5.1 Target Audience

- [ ] If targeting children under 13:
  - [ ] Must participate in Designed for Families program
  - [ ] COPPA compliance required
  - [ ] No monetization restrictions for kids apps

**ephenotes Status:** ✅ N/A (targeting adults, rated Everyone but designed for 18+)

#### 5.2 Ads and Monetization

- [ ] Apps targeting children must not have certain ad formats
- [ ] No ads based on user activity within the app

**ephenotes Status:** ✅ N/A (no ads, not targeting children)

### 6. Data Safety

#### 6.1 Required Disclosure

- [ ] **Data types collected:**
  - [ ] Personal info (name, email, address)
  - [ ] Financial info
  - [ ] Location
  - [ ] Photos/videos
  - [ ] Audio files
  - [ ] Messages
  - [ ] Contacts
  - [ ] App activity
  - [ ] Web browsing
  - [ ] App info and performance
  - [ ] Device/other IDs

- [ ] **Data usage:**
  - [ ] Why data is collected
  - [ ] How data is used
  - [ ] Whether data is shared with third parties

- [ ] **Security practices:**
  - [ ] Data encryption in transit
  - [ ] Data encryption at rest
  - [ ] User can request data deletion
  - [ ] Data collection is optional
  - [ ] Committed to Google Play Families Policy
  - [ ] Validated security practices

**ephenotes Data Safety Response:**

```
✅ Does your app collect or share user data?
   → No, this app doesn't collect or share user data

✅ Is all user data encrypted in transit?
   → N/A (no data transmitted)

✅ Do you provide a way for users to request data deletion?
   → N/A (data is local only, users can delete notes within app)

✅ Have you validated your app's safety section?
   → Yes

✅ Is this a Designed for Families app?
   → No
```

---

## Common Rejection Reasons

### iOS Rejections

#### 1. Missing Privacy Policy

**Reason:** App Store Connect requires a privacy policy URL.

**Solution:**
- Create and publish privacy policy at https://ephenotes.app/privacy-policy
- Add URL to App Store Connect

#### 2. Incomplete App Functionality

**Reason:** App crashes or doesn't work as described.

**Solution:**
- Test thoroughly on physical devices
- Ensure all features work in release mode
- Provide demo account if needed (N/A for ephenotes)

#### 3. Misleading Metadata

**Reason:** Screenshots don't match app, description is inaccurate.

**Solution:**
- Update screenshots to show actual app screens
- Ensure description matches functionality
- Remove placeholder text

#### 4. Using Private APIs

**Reason:** App uses non-public iOS APIs.

**Solution:**
- Only use documented Flutter/iOS APIs
- Remove any undocumented API usage

#### 5. Data Collection Without Disclosure

**Reason:** App collects data but doesn't disclose it.

**Solution:**
- Fill out App Privacy labels accurately
- Update privacy policy
- Request permissions with clear purpose strings

**ephenotes Status:** ✅ No data collection, privacy labels indicate "Data Not Collected"

### Android Rejections

#### 1. Data Safety Form Incomplete

**Reason:** Data Safety section not filled out or inaccurate.

**Solution:**
- Complete Data Safety form
- Declare "No data collected" if applicable
- Match declarations to app behavior

#### 2. Content Rating Missing

**Reason:** Content rating questionnaire not completed.

**Solution:**
- Complete IARC questionnaire
- Answer all questions accurately
- Expected rating: Everyone

#### 3. Target API Level Too Low

**Reason:** App targets outdated Android API level.

**Solution:**
- Update `targetSdkVersion` to 34 (Android 14)
- Test on latest Android version
- Update `android/app/build.gradle`

**ephenotes Config:**
```gradle
targetSdkVersion 34  // Android 14
```

#### 4. Privacy Policy Missing/Broken

**Reason:** Privacy policy URL not working or not provided.

**Solution:**
- Publish privacy policy at https://ephenotes.app/privacy-policy
- Ensure URL is accessible and functional
- Add URL to Play Console store listing

#### 5. Permissions Not Justified

**Reason:** App requests permissions not needed for core functionality.

**Solution:**
- Remove unnecessary permissions from AndroidManifest.xml
- Only request permissions essential to app function

**ephenotes Status:** ✅ No permissions requested

---

## Pre-Submission Checklist

### iOS Pre-Submission

- [ ] **App Store Connect Setup**
  - [ ] App created in App Store Connect
  - [ ] Bundle ID matches: `com.ephenotes.app`
  - [ ] Team selected
  - [ ] App icon uploaded (1024x1024)

- [ ] **Build**
  - [ ] Version number updated in pubspec.yaml
  - [ ] Build number incremented
  - [ ] Release build succeeds
  - [ ] No analyzer warnings
  - [ ] All tests passing

- [ ] **Metadata**
  - [ ] App name: "ephenotes"
  - [ ] Subtitle (if any)
  - [ ] Description written (accurate, compelling)
  - [ ] Keywords optimized
  - [ ] Screenshots uploaded (all required sizes)
  - [ ] App preview video (optional)
  - [ ] Privacy policy URL functional
  - [ ] Support URL functional
  - [ ] Marketing URL (optional)

- [ ] **Privacy**
  - [ ] App Privacy labels filled out
  - [ ] "Data Not Collected" selected for all categories
  - [ ] Privacy policy published and linked

- [ ] **Pricing & Availability**
  - [ ] Price: Free
  - [ ] Availability: All countries selected
  - [ ] Release date: Manual release after approval

- [ ] **App Review Information**
  - [ ] Contact information provided
  - [ ] Demo account (if applicable): N/A
  - [ ] Notes for reviewer written
  - [ ] Export compliance: No encryption

- [ ] **Testing**
  - [ ] Tested on iPhone (physical device)
  - [ ] Tested on iPad (physical device)
  - [ ] Tested on iOS 13 (minimum version)
  - [ ] Tested in dark mode
  - [ ] Tested with VoiceOver
  - [ ] No crashes in release mode

### Android Pre-Submission

- [ ] **Play Console Setup**
  - [ ] App created in Play Console
  - [ ] App name: "ephenotes"
  - [ ] Default language: English (United States)

- [ ] **Build**
  - [ ] Version name updated: `1.0.0`
  - [ ] Version code incremented: `1`
  - [ ] AAB built successfully
  - [ ] App bundle size < 150 MB
  - [ ] No analyzer warnings
  - [ ] All tests passing

- [ ] **Store Listing**
  - [ ] Short description (80 chars max)
  - [ ] Full description (4000 chars max)
  - [ ] App icon: 512x512 PNG
  - [ ] Feature graphic: 1024x500
  - [ ] Phone screenshots: 2-8 images
  - [ ] 7" tablet screenshots (optional)
  - [ ] 10" tablet screenshots (optional)
  - [ ] App category: Productivity
  - [ ] Tags selected
  - [ ] Contact email: support@ephenotes.app
  - [ ] Privacy policy URL functional

- [ ] **Data Safety**
  - [ ] Data Safety form completed
  - [ ] "No data collected" declared
  - [ ] Form validated

- [ ] **Content Rating**
  - [ ] IARC questionnaire completed
  - [ ] Rating received: Everyone

- [ ] **Pricing & Distribution**
  - [ ] App type: Free
  - [ ] Countries: Available in all
  - [ ] Ads: No
  - [ ] In-app purchases: No
  - [ ] Content guidelines acknowledged
  - [ ] Device categories: Phone, Tablet, Chromebook

- [ ] **App Content**
  - [ ] Target audience: Adults (18+)
  - [ ] News app: No
  - [ ] COVID-19 app: No
  - [ ] Government app: No

- [ ] **Testing**
  - [ ] Tested on Android phone (physical)
  - [ ] Tested on Android tablet (physical)
  - [ ] Tested on Android 6 (API 23, minimum version)
  - [ ] Tested with TalkBack
  - [ ] No crashes in release mode
  - [ ] ProGuard/R8 minification working

---

## Review Response Templates

### iOS Response Templates

#### Request for More Information

```
Dear App Review Team,

Thank you for reviewing ephenotes.

[Answer specific questions]

If you need any additional information or have further questions,
please don't hesitate to contact me.

Best regards,
[Your Name]
Developer, ephenotes
support@ephenotes.app
```

#### Addressing Privacy Concerns

```
Dear App Review Team,

Thank you for your feedback regarding privacy concerns.

ephenotes does not collect, transmit, or share any user data. All notes
are stored locally on the user's device using Flutter's Hive database.

We have:
- Updated our App Privacy labels to reflect "Data Not Collected"
- Published our privacy policy at https://ephenotes.app/privacy-policy
- Removed all third-party SDKs that collect data
- Ensured no network requests are made by the app

Please let me know if you need any additional clarification.

Best regards,
[Your Name]
```

#### Addressing Metadata Issues

```
Dear App Review Team,

Thank you for identifying the metadata issues.

We have updated:
- Screenshots to show actual app functionality
- App description to accurately represent features
- Keywords to be relevant to note-taking functionality

The updated metadata has been submitted. Please re-review at your convenience.

Best regards,
[Your Name]
```

### Android Response Templates

#### Addressing Data Safety Concerns

```
Hello Google Play Review Team,

Thank you for reviewing ephenotes.

Regarding the Data Safety section:

ephenotes does not collect, share, or transmit any user data. All notes
are stored locally on the device using the Hive local database.

Our Data Safety declaration of "No data collected" is accurate because:
1. No network permissions are requested
2. No third-party SDKs with data collection
3. No analytics or crash reporting in this version
4. No advertising frameworks
5. All data stays on the user's device

Privacy policy: https://ephenotes.app/privacy-policy

Please let me know if you need additional information.

Best regards,
[Your Name]
support@ephenotes.app
```

#### Addressing Permission Questions

```
Hello Google Play Review Team,

Thank you for your inquiry regarding app permissions.

ephenotes does not request any runtime permissions. The app functions
entirely offline with local storage only.

No permissions in AndroidManifest.xml beyond the standard:
- android.permission.INTERNET (not used, but included by Flutter)

We do not use: camera, location, contacts, storage, or any sensitive permissions.

Please let me know if you need further clarification.

Best regards,
[Your Name]
```

---

## Compliance Timeline

### Week -4: Preparation

- [ ] Create privacy policy webpage
- [ ] Prepare app store assets (icons, screenshots, descriptions)
- [ ] Complete internal testing
- [ ] Review all guidelines

### Week -2: Beta Testing

- [ ] Submit to TestFlight (iOS)
- [ ] Internal testing (Android)
- [ ] Gather feedback
- [ ] Fix critical bugs

### Week -1: Pre-Submission

- [ ] Complete all pre-submission checklists
- [ ] Final testing on physical devices
- [ ] Prepare review notes
- [ ] Set up support email

### Week 0: Submission

- [ ] Submit to App Store
- [ ] Submit to Google Play
- [ ] Monitor review status daily
- [ ] Respond to questions within 24 hours

### Week 1-2: Review Period

- [ ] iOS review (24-48 hours typical)
- [ ] Android review (3-7 days typical)
- [ ] Address any issues immediately
- [ ] Prepare for launch

### Week 2+: Post-Approval

- [ ] Release to 100% of users (or staged rollout)
- [ ] Monitor crash reports
- [ ] Respond to reviews
- [ ] Plan first update

---

## Additional Resources

### Official Guidelines

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policy Center](https://play.google.com/about/developer-content-policy/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect)

### Privacy & Legal

- [Apple Privacy Best Practices](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)
- [Google Play Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [COPPA Compliance Guide](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)

### Tools

- [App Store Screenshot Sizes](https://appfollow.io/blog/app-store-screenshot-sizes)
- [Google Play Screenshot Specs](https://support.google.com/googleplay/android-developer/answer/9866151)
- [App Privacy Policy Generator](https://www.freeprivacypolicy.com/)

---

**Last Updated:** 2026-02-03
**Review Before:** First app submission
**Next Update:** After any policy changes or rejections
