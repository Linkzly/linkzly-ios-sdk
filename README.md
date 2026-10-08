# LinkzlySDK for iOS

[![Swift Version](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2012.0%2B-lightgrey.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

LinkzlySDK is a powerful iOS SDK for deep linking and attribution tracking. Track app installs, opens, and custom events while seamlessly handling Universal Links for deferred deep linking.

Full documentation: https://docs.linkzly.com/docs/sdk-ios

Related guides: [Tracking events](https://docs.linkzly.com/docs/sdk-tracking-events), [Tracking purchases](https://docs.linkzly.com/docs/sdk-tracking-purchases), [Integrations setup](https://docs.linkzly.com/docs/sdk-integrations-setup).

## Features

- 🔗 **Universal Links Support** - Handle deep links automatically
- 📊 **Attribution Tracking** - Track installs, opens, and custom events
- 🎯 **Deferred Deep Linking** - Match users to campaigns after install
- 👤 **User Identification** - Associate events with specific users
- 🔐 **Privacy-First** - Opt-in/opt-out tracking controls
- 📱 **Advertising Identifiers** - IDFA, IDFV, and ATT framework support
- 🤝 **Affiliate Attribution** - Capture and store the affiliate click ID for your server to use in server-to-server (S2S) conversion tracking
- 🔔 **Push Notifications** - Registration of the Firebase Cloud Messaging (FCM) registration token, plus FCM broadcast topics
- 🎮 **Gaming Intelligence** - Batch event tracking for games with session management
- ⚡ **Lightweight** - Zero third-party dependencies
- 🎨 **SwiftUI & UIKit** - Works with both frameworks
- 🔧 **Objective-C Compatible** - Objective-C entry points for the core calls

## Requirements

| Component | Value |
|-----------|-------|
| Minimum deployment target declared by the SDK | iOS 12.0 |
| Swift tools version declared by the package | 5.7 |

**Language Support:**
- Swift (primary, all examples below)
- Objective-C (entry points for the core calls; `trackInstall`, `trackOpen`, `trackPurchase`, `trackRefund` and `flushEvents` have Swift-only signatures, so Objective-C uses `trackInstallObjC` and `trackOpenObjC` for install and open)

## Prerequisites

Before integrating the SDK, set up your app in the Linkzly Console:

1. Go to **Dashboard > Apps** and click "Register App"
2. Enter your iOS **Bundle ID** and **Team ID**
3. Choose a verification method (Hosted recommended for quick start)
4. Copy your **SDK Key** from the post-creation wizard or from Manage App > Overview > SDK Configuration

Your SDK key starts with `slk_` and uniquely identifies your app.

## Getting Your SDK Key

Your SDK key (`slk_` prefix) authenticates your app with Linkzly's servers. You can find it in:

- **Post-creation wizard**: Displayed prominently right after creating your app
- **Dashboard > Apps > Manage App > Overview > SDK Configuration**: Click the eye icon to reveal, or copy directly

> **Note**: Each app has a unique SDK key. Do not share keys between different apps.

## Installation

**SDK version:** 1.0.7

### Swift Package Manager

Add LinkzlySDK to your project using Xcode:

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL: `https://github.com/Linkzly/linkzly-ios-sdk.git`
3. Select the version or branch you want to use
4. Add the **Linkzly** product to your app target

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Linkzly/linkzly-ios-sdk.git", from: "1.0.7")
],
targets: [
    .target(name: "YourApp", dependencies: [.product(name: "Linkzly", package: "linkzly-ios-sdk")])
]
```

### CocoaPods

`LinkzlySDK` is not published to CocoaPods Trunk, so the pod needs its Git source and tag:

```ruby
pod 'LinkzlySDK', :git => 'https://github.com/Linkzly/linkzly-ios-sdk.git', :tag => '1.0.7'
```

Then import the module. The module is named `Linkzly`; the class you call is `LinkzlySDK`.

```swift
import Linkzly
```

### Carthage

Carthage is not supported.

## Quick Start

### 1. Configure the SDK

**SwiftUI (Recommended - with Closure Handlers):**

```swift
import SwiftUI
import Linkzly

@main
struct YourApp: App {
    init() {
        // Configure SDK on app launch
        LinkzlySDK.configure(
            sdkKey: "slk_your_key_from_console",  // Get this from Dashboard > Apps > Manage App
            environment: .production
        )

        // HANDLER 1: Universal Link Capture (IMMEDIATE NAVIGATION)
        // Called when URL is captured - provides immediate navigation for installed apps
        LinkzlySDK.onUniversalLink { url, attributionData in
            print("📎 Universal Link captured: \(url)")
            print("   Query params: \(attributionData)")
            
            // Create DeepLinkData from URL parameters for immediate navigation
            let deepLinkData = DeepLinkData(
                url: url.absoluteString,
                path: url.path,
                parameters: attributionData
            )
            
            // Navigate immediately
            DispatchQueue.main.async {
                handleNavigation(deepLinkData)
            }
        }

        // HANDLER 2: Server Attribution Data (ATTRIBUTION ENRICHMENT)
        // Called when server returns enriched attribution data
        // Works for both direct attribution and deferred deep linking (fresh installs)
        LinkzlySDK.onDeepLink { deepLinkData, url in
            print("🎯 Attribution data received:")
            print("   Path: \(deepLinkData.path ?? "none")")
            print("   Smart Link ID: \(deepLinkData.smartLinkId ?? "none")")
            print("   Click ID: \(deepLinkData.clickId ?? "none")")
            
            // Navigate with enriched data
            DispatchQueue.main.async {
                handleNavigation(deepLinkData)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    _ = LinkzlySDK.handleUniversalLink(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    _ = LinkzlySDK.handleUniversalLink(userActivity)
                }
        }
    }
}
```

**SwiftUI (Simple - with NotificationCenter):**

```swift
import SwiftUI
import Linkzly

@main
struct YourApp: App {
    init() {
        LinkzlySDK.configure(
            sdkKey: "slk_your_key_from_console",  // Get this from Dashboard > Apps > Manage App
            environment: .production
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    _ = LinkzlySDK.handleUniversalLink(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    _ = LinkzlySDK.handleUniversalLink(userActivity)
                }
        }
    }
}
```

**UIKit:**

```swift
import UIKit
import Linkzly

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        LinkzlySDK.configure(
            sdkKey: "slk_your_key_from_console",  // Get this from Dashboard > Apps > Manage App
            environment: .production
        )

        return true
    }

    func application(_ application: UIApplication,
                    continue userActivity: NSUserActivity,
                    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return LinkzlySDK.handleUniversalLink(userActivity)
    }
}
```

### 2. Setup Universal Links

#### Using Linkzly Hosted Verification (Recommended)

If you chose "Hosted Verification" when creating your app in the console, Linkzly automatically hosts your `apple-app-site-association` file. You only need to:

1. In Xcode, select your target → **Signing & Capabilities**
2. Click **+ Capability** → **Associated Domains**
3. Add: `applinks:{your-prefix}.linkz.ly`

Replace `{your-prefix}` with the brand prefix you chose in the Linkzly Console. That's it — no manual file hosting required!

#### Self-Hosted Verification

If you chose "Custom Domain Verification", follow these steps:

##### Add Associated Domains to Your App

1. In Xcode, select your target → **Signing & Capabilities**
2. Click **+ Capability** → **Associated Domains**
3. Add: `applinks:yourdomain.com`

##### Create .apple-app-site-association File

Create this file on your server at `https://yourdomain.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.yourcompany.yourapp",
        "paths": ["*"]
      }
    ]
  }
}
```

Replace:
- `TEAMID` - Your Apple Team ID (found in Developer Portal)
- `com.yourcompany.yourapp` - Your app's bundle identifier

#### Required Info.plist Configuration

Add these entries to your app's `Info.plist`:

```xml
<!-- For Custom URL Scheme Testing (Optional but recommended) -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>

<!-- For Universal Links (Required in production) -->
<!-- Associated Domains capability must also be added in Xcode target settings -->
```

**Required Xcode Capabilities:**
1. Go to target → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **Associated Domains**
4. Add entry: `applinks:yourdomain.com`

### 3. Listen for Deep Links

**Option A: Closure Handlers (Recommended)**

```swift
import Linkzly

// Register handlers once during app initialization
LinkzlySDK.onUniversalLink { url, attributionData in
    // Called immediately when Universal Link is captured
    // Use for instant navigation in installed apps
    print("URL: \(url), Params: \(attributionData)")
}

LinkzlySDK.onDeepLink { deepLinkData, url in
    // Called when server returns enriched attribution data
    // Includes smartLinkId, clickId, and full attribution
    handleDeepLink(deepLinkData)
}
```

**Option B: NotificationCenter**

```swift
import SwiftUI
import Linkzly

struct ContentView: View {
    @State private var deepLinkPath: String?

    var body: some View {
        NavigationView {
            VStack {
                if let path = deepLinkPath {
                    Text("Deep Link: \(path)")
                }
            }
        }
        .onAppear {
            setupNotifications()
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .linkzlyDeepLinkDataReceived,
            object: nil,
            queue: .main
        ) { notification in
            if let deepLinkData = notification.userInfo?["deepLinkData"] as? DeepLinkData {
                deepLinkPath = deepLinkData.path

                // Navigate based on deep link
                handleDeepLink(deepLinkData)
            }
        }
    }

    private func handleDeepLink(_ data: DeepLinkData) {
        guard let path = data.path else { return }

        switch path {
        case "/product":
            if let productId = data.getStringParameter("id") {
                // Navigate to product detail
            }
        case "/profile":
            // Navigate to profile
            break
        default:
            break
        }
    }
}
```

## Usage

### Track Events

**Register the name first.** A custom event is kept only if its name is registered for the app in the console. An unregistered name is dropped, and on the default batched path the call and the flush still report success. See [Register each name in the console](https://docs.linkzly.com/docs/sdk-tracking-events#register-each-name-in-the-console).

```swift
// Track custom events
LinkzlySDK.trackEvent("signup_completed", parameters: ["method": "email"])

// Track screen views
LinkzlySDK.trackEvent("screen_view", parameters: [
    "screen_name": "ProductDetail"
])
```

### Track Purchases

`revenue`, `currency` and `transactionId` are required. `transactionId` is the dedup key: a repeat of the same id is discarded. See [Tracking purchases](https://docs.linkzly.com/docs/sdk-tracking-purchases).

```swift
LinkzlySDK.trackPurchase(parameters: [
    "revenue": 29.99,
    "currency": "USD",
    "transactionId": "order-12345",
    "productId": "premium_monthly",
    "revenueType": "subscription" // "iap" | "subscription" | "other"
]) { result in
    switch result {
    case .success(let response):
        print("Purchase tracked: \(response.eventId ?? "")")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Refund: reuse the ORIGINAL transactionId so it nets out
LinkzlySDK.trackRefund(parameters: [
    "revenue": 29.99,
    "currency": "USD",
    "transactionId": "order-12345"
])
```

### User Identification

```swift
// Set user ID after login
LinkzlySDK.setUserID("user_12345")

// Get current user ID
if let userId = LinkzlySDK.getUserID() {
    print("Current user: \(userId)")
}
```

### Visitor Identification

```swift
// Get persistent visitor ID (auto-generated UUID)
let visitorId = LinkzlySDK.getVisitorID()

// Reset visitor ID (generates new UUID)
LinkzlySDK.resetVisitorID()
```

### Sessions

Sessions are automatic. The SDK records an open when the app becomes active more than 30 seconds after the last session and sends a session-end event when the app resigns active. There is nothing to start or end yourself. (Gaming sessions have their own `startGamingSession` and `endGamingSession`, below.)

### Privacy Controls

```swift
// Stop custom events, purchases and refunds
// (install, open and session-end events are not affected; trackEventBatch is not stopped)
LinkzlySDK.setTrackingEnabled(false)

// Check tracking status
let isEnabled = LinkzlySDK.isTrackingEnabled()

// Disable advertising tracking (IDFA collection)
LinkzlySDK.setAdvertisingTrackingEnabled(false)

// Check advertising tracking status
let isAdTrackingEnabled = LinkzlySDK.isAdvertisingTrackingEnabled()
```

### Track Install/Open

```swift
// The SDK sends the install itself on the first launch of a new install.
// Calling trackInstall yourself on a new install sends a second install event;
// register LinkzlySDK.onDeepLink to get the deferred DeepLinkData without it.
LinkzlySDK.trackInstall { result in
    switch result {
    case .success(let deepLinkData):
        if let data = deepLinkData {
            print("Install attributed to: \(data.smartLinkId ?? "organic")")
        }
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Track app open. The SDK already sends opens itself (when the app becomes active more than
// 30 seconds after the last session); each explicit call sends one more open event.
// Call it only when you need the DeepLinkData it returns.
LinkzlySDK.trackOpen { result in
    // Handle result
}
```

**Objective-C:** `trackInstall` and `trackOpen` return a Swift `Result`. From Objective-C use `trackInstallObjC` and `trackOpenObjC`, whose completion receives `DeepLinkData` and `NSError`:

```objc
[LinkzlySDK trackInstallObjCWithCompletion:^(DeepLinkData *data, NSError *error) {
    // data is nil when there is no deep link data or the call failed
}];

[LinkzlySDK trackOpenObjCWithCompletion:^(DeepLinkData *data, NSError *error) {
    // same shape as trackInstallObjC
}];
```

### Event Queue Management

```swift
// Get number of pending events in queue
let pendingCount = LinkzlySDK.getPendingEventCount()

// Manually flush event queue
LinkzlySDK.flushEvents { success, error in
    if success {
        print("Events flushed successfully")
    } else if let error = error {
        print("Flush failed: \(error)")
    }
}

// Track multiple events in batch
LinkzlySDK.trackEventBatch([
    ["eventName": "view_item", "parameters": ["item_id": "123"]],
    ["eventName": "add_to_cart", "parameters": ["item_id": "123", "quantity": 1]]
]) { success, error in
    // Handle completion
}
```

### Advertising Identifiers (IDFA/IDFV)

The SDK automatically collects and includes advertising identifiers in all events when available and authorized:

**What's Collected:**
- **IDFA** (Identifier for Advertisers) - Requires ATT permission on iOS 14.5+
- **IDFV** (Identifier for Vendor) - Always available, no permission required
- **ATT Status** - User's tracking authorization status

**Request Tracking Permission (iOS 14.5+):**

```swift
import AppTrackingTransparency

// Request ATT permission
LinkzlySDK.requestTrackingPermission { result in
    switch result {
    case .success(let status):
        switch status {
        case .authorized:
            print("✅ User authorized tracking - IDFA will be collected")
        case .denied:
            print("❌ User denied tracking - IDFA will not be collected")
        case .restricted:
            print("⚠️ Tracking restricted by parental controls or device management")
        case .notDetermined:
            print("⏳ User hasn't made a decision yet")
        @unknown default:
            break
        }
    case .failure(let error):
        print("Error requesting permission: \(error)")
    }
}
```

**From Objective-C**, use `requestTrackingPermissionObjC`, which returns the status as a string (`"authorized"`, `"denied"`, `"restricted"`, `"notDetermined"` or `"unknown"`):

```objc
[LinkzlySDK requestTrackingPermissionObjCWithCompletion:^(NSString *status, NSError *error) {
    // status is nil when error is set
}];
```

**Get Current IDFA/ATT Status:**

```swift
// Get IDFA (returns nil if not authorized)
if let idfa = LinkzlySDK.getIDFA() {
    print("IDFA: \(idfa)")
}

// Get ATT authorization status
if let attStatus = LinkzlySDK.getATTStatus() {
    print("ATT Status: \(attStatus)")  // "authorized", "denied", "restricted", "notDetermined"
}
```

**Required Info.plist Entry:**

Add this key to your app's `Info.plist` to explain why you request tracking permission:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use your data to provide personalized content and improve your app experience. Your privacy is important to us.</string>
```

**Two-Tier Consent Model:**

The SDK provides both platform-level (ATT) and app-level consent controls:

```swift
// Platform-level: Request ATT permission (iOS 14.5+)
LinkzlySDK.requestTrackingPermission { result in
    // Handle result
}

// App-level: Disable advertising tracking in your app
LinkzlySDK.setAdvertisingTrackingEnabled(false)

// Check current status
let isEnabled = LinkzlySDK.isAdvertisingTrackingEnabled()
```

**When Are Identifiers Collected?**

Advertising identifiers are collected on **every event** (install, open, custom events):
- No caching - fresh collection ensures consent changes are respected
- IDFA: Only included when ATT status is "authorized"
- IDFV: Always included (no permission required)
- ATT status: Always included for iOS 14+

### SKAdNetwork Support (iOS 14+)

The SDK registers and updates SKAdNetwork conversion values on the device. Your app decides the value; the SDK passes it to StoreKit:

```swift
// Update conversion value (iOS 14.0+)
LinkzlySDK.updateConversionValue(5)

// Update with completion handler
LinkzlySDK.updateConversionValue(5) { success in
    print("Conversion value updated: \(success)")
}

// iOS 16.1+ with coarse conversion values
if #available(iOS 16.1, *) {
    LinkzlySDK.updateConversionValue(5, coarseValue: .high)
    
    // With lock window option
    LinkzlySDK.updateConversionValue(5, coarseValue: .medium, lockWindow: true) { success in
        print("Updated with lock: \(success)")
    }
}
```

### Affiliate Attribution Tracking

Track affiliate clicks from deep links and retrieve attribution data for server-to-server (S2S) postback integration at checkout.

**Capture Attribution from Deep Link Handler:**

```swift
import Linkzly

// In your deep link handler (SwiftUI)
LinkzlySDK.onUniversalLink { url, attributionData in
    // Automatically captures affiliate click ID from URL
    let captured = LinkzlySDK.captureAffiliateAttribution(from: url)
    if captured {
        print("Affiliate attribution captured from: \(url)")
    }
}

// Or in AppDelegate
func application(_ application: UIApplication,
                continue userActivity: NSUserActivity,
                restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let url = userActivity.webpageURL {
        LinkzlySDK.captureAffiliateAttribution(from: url)
    }
    return LinkzlySDK.handleUniversalLink(userActivity)
}
```

**Retrieve Click ID at Checkout (S2S Postback):**

```swift
// At checkout, retrieve the affiliate click ID for server-to-server attribution
if let clickId = LinkzlySDK.getAffiliateClickId() {
    // Send clickId to your server for S2S postback to the affiliate network
    sendToServer(clickId: clickId, orderId: orderId, amount: amount)
}

// Get full attribution data (always returns a value; check hasAttribution)
let attribution = LinkzlySDK.getAffiliateAttribution()
if attribution.hasAttribution {
    print("Click ID: \(attribution.clickId ?? "none")")
    print("Program: \(attribution.programId ?? "none")")
    print("Affiliate: \(attribution.affiliateId ?? "none")")
    print("Source: \(attribution.source)")  // .deepLink, .stored or .none
}

// Check if attribution exists
if LinkzlySDK.hasAffiliateAttribution() {
    // Show affiliate-specific checkout flow
}

// Clear attribution data (e.g., after successful conversion)
LinkzlySDK.clearAffiliateAttribution()
```

**API Reference:**

| Method | Return Type | Description |
|--------|-------------|-------------|
| `captureAffiliateAttribution(from: URL)` | `Bool` | Captures affiliate attribution from a deep link URL |
| `getAffiliateClickId()` | `String?` | Returns the stored affiliate click ID |
| `getAffiliateAttribution()` | `AffiliateAttribution` | Returns full attribution data (`clickId`, `programId`, `affiliateId`, `timestamp`, `source`) |
| `hasAffiliateAttribution()` | `Bool` | Checks if attribution data exists |
| `clearAffiliateAttribution()` | `Void` | Clears stored attribution data |

**Storage & Expiry:**
- Attribution data is stored securely in the Keychain (with UserDefaults fallback)
- Data automatically expires after **30 days**
- Only the most recent affiliate click is stored (newer clicks overwrite older ones)

### Push Notification Support

The SDK exposes **two independent push features** — most apps that target individual users want the first one:

| Feature | Methods | What it does | When to use |
|---|---|---|---|
| **Device token registration** | `setNotificationToken` / `getNotificationToken` / `hasNotificationToken` / `clearNotificationToken` | Registers this device's **Firebase Cloud Messaging (FCM) registration token** in Linkzly's device registry so campaigns can target the specific device/user. On iOS pass the token Firebase Messaging gives you, **never** the APNs device token. | You want Linkzly to send (or target) notifications to individual devices/users. |
| **Broadcast topic subscription** | `initializePush` / `disablePush` | Re-runs or reverses this device's subscription to its **per-(Smart App, platform) FCM topic** for "send to All" campaigns. The subscribe already happens **automatically** inside `setNotificationToken` — these are recovery / opt-out controls, not the mechanism. FCM-only, via runtime reflection. | Rarely: to opt back in after `disablePush()`, or to retry a subscribe Firebase was not ready for. |

The two are not mutually exclusive, but they solve different problems. Start with **device token registration** below.

#### Registering a device push token

`setNotificationToken` records the device's push token in Linkzly's device registry (`/api/sdk/devices/register`). On iOS the token must be the **Firebase Cloud Messaging registration token** that Firebase Messaging gives your app. Do **not** pass the APNs device token from `didRegisterForRemoteNotificationsWithDeviceToken`: devices registered through the SDK are reached through Firebase Cloud Messaging, so an APNs device token can never receive a push. Your app therefore requires Firebase Messaging, and Firebase needs your APNs key or certificate (set up in the Firebase console). Call `setNotificationToken` whenever Firebase gives you a token — the SDK throttles network calls (it only re-registers when the token, user, or app version changes, or after 7 days), so it is safe to call on every launch.

```swift
import FirebaseMessaging

// Firebase calls this with the FCM registration token at launch and whenever it changes.
// (Set `Messaging.messaging().delegate = self` on your MessagingDelegate.)
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let fcmToken else { return }
    LinkzlySDK.setNotificationToken(fcmToken)
}

// Or read the current token on demand:
func registerCurrentFcmToken() async {
    if let fcmToken = try? await Messaging.messaging().token() {
        LinkzlySDK.setNotificationToken(fcmToken)
    }
}
```

The Swift samples in this section were compiled against Firebase iOS SDK 13.0.1 (`FirebaseMessaging`).

On iOS, `setNotificationToken` is ignored until `configure` has run (it logs a warning and stores nothing). If your app delays `configure`, for example until the user has consented, call `setNotificationToken` again after `configure`, for example with the current token from Firebase Messaging; a call made after `configure` registers normally.

**Binding to a user:** when you call `LinkzlySDK.setUserID(...)`, the SDK automatically re-registers the stored token against the new user id, so campaigns can target that user.

**On logout / notifications disabled:** clear the token. This removes it locally and revokes it server-side.

```swift
LinkzlySDK.clearNotificationToken()
```

**Inspecting state:**

```swift
let token = LinkzlySDK.getNotificationToken()   // String?
let has   = LinkzlySDK.hasNotificationToken()   // Bool
```

> **Objective-C:** all four methods are exposed via `@objc` — `[LinkzlySDK setNotificationToken:tokenString]`, `[LinkzlySDK clearNotificationToken]`, etc.

**API Reference:**

| Method | Returns | Description |
|--------|---------|-------------|
| `setNotificationToken(_ token: String)` | `Void` | Registers the device's FCM registration token in Linkzly's device registry (throttled). On iOS this is the Firebase Messaging token, not the APNs device token |
| `getNotificationToken()` | `String?` | Returns the currently stored push token, if any |
| `hasNotificationToken()` | `Bool` | Checks whether a push token is stored |
| `clearNotificationToken()` | `Void` | Clears the token locally and revokes it server-side |

#### Broadcast topic subscription (optional, FCM-only)

Use this only if you want "send to All" broadcast campaigns and your app uses Firebase Cloud Messaging.

> **Most apps never call these.** A successful `setNotificationToken` registration **already subscribes** the device to its broadcast topic, and the SDK re-subscribes to the stored topic on every launch. `initializePush()` only re-runs that subscribe; `disablePush()` reverses it.

**Prerequisites:**
- Firebase Cloud Messaging integrated in your app, with `FirebaseApp.configure()` called **before** the token is registered
- Linkzly SDK configured and initialized
- A successful `setNotificationToken` registration (the topic name is returned by the register call)

> **Note:** `initializePush()` and `disablePush()` are **Firebase Cloud Messaging only**. They subscribe/unsubscribe the device to its server-assigned FCM broadcast topic (`linkzly_broadcast_<smartAppId>_ios`) using runtime reflection. **`initializePush()` does nothing until token registration has succeeded** — it subscribes to the topic that registration stored, and returns `false` when there is none.
>
> If your app also uses another push provider for its own delivery, you do **not** need these methods for that. Linkzly delivers through Firebase Cloud Messaging, so register the FCM token with `setNotificationToken` to have Linkzly target the device.

**Setup (Swift):**

```swift
import FirebaseCore
import FirebaseMessaging
import UIKit
import Linkzly

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 1. Firebase first — it must be live before the token is registered,
        //    or the topic subscribe is deferred to the next launch.
        FirebaseApp.configure()

        // 2. Configure Linkzly
        LinkzlySDK.configure(sdkKey: "slk_your_key_from_console", environment: .production)

        // 3. Let Firebase deliver its registration token to this delegate, then register for remote notifications
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        return true
    }

    // 4. This is what enables broadcasts: registration stores the topic and subscribes to it.
    //    Firebase calls this with the FCM registration token at launch and whenever it changes.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        LinkzlySDK.setNotificationToken(fcmToken)
    }
}
```

Asking the user for notification permission (`UNUserNotificationCenter.requestAuthorization`) is a separate step that you do in your own app. Giving Firebase your APNs key or certificate is Firebase's own setup, done in the Firebase console.

> Calling `initializePush()` in `didFinishLaunchingWithOptions` returns `false` on a first launch — no registration has completed yet, so there is no topic to subscribe to.

**When to call `initializePush()`:**

```swift
// Opt back in after a disablePush(), or retry a subscribe that
// Firebase Messaging had not yet loaded for.
let subscribed = LinkzlySDK.initializePush()
```

It returns `false` when the SDK is not configured, no topic is stored yet, or Firebase Messaging is unavailable.

**Setup (Objective-C):** (derived from the compiled Swift sample and Firebase's documented Objective-C API; not compiled)

```objc
@import FirebaseMessaging;

@interface AppDelegate () <FIRMessagingDelegate>
@end

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [FIRApp configure];
    [LinkzlySDK configureWithSdkKey:@"slk_your_key_from_console"];  // production
    [FIRMessaging messaging].delegate = self;
    [application registerForRemoteNotifications];

    return YES;
}

// Firebase calls this with the FCM registration token at launch and whenever it changes.
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    if (fcmToken.length == 0) { return; }
    [LinkzlySDK setNotificationToken:fcmToken];
}
```

**Disabling Push Notifications:**

```swift
// Unsubscribe from the Linkzly broadcast topic
LinkzlySDK.disablePush()
```

> **`disablePush()` is session-scoped.** It unsubscribes from the broadcast topic but keeps the stored token and topic, so the next app launch re-subscribes. For a **durable** opt-out, clear the token instead — that unsubscribes, revokes the token server-side, and drops the stored topic:
>
> ```swift
> LinkzlySDK.clearNotificationToken()
> ```

**How It Works:**
1. `setNotificationToken` registers the device; the server returns its topic (`linkzly_broadcast_<smartAppId>_ios`), which the SDK stores and **subscribes to immediately**
2. On every launch with a stored token, the SDK re-subscribes to the stored topic — so a subscribe that failed (for example, Firebase Messaging not yet loaded) self-heals on the next launch
3. `initializePush()` performs that same subscribe on demand; it is a no-op returning `false` while no topic is stored
4. Subscription uses runtime reflection — Firebase is not a compile dependency of the SDK

**Compatibility:**
- If your app also uses another push provider for its own delivery, you do **not** need these calls for it. Devices registered through the SDK are reached through Firebase Cloud Messaging.
- Only subscribes to Linkzly-specific FCM topics

**Troubleshooting:**

| Issue | Solution |
|-------|----------|
| `initializePush()` returns `false` | Expected before the first successful `setNotificationToken` — there is no topic yet. Otherwise: SDK not configured, or Firebase Messaging not linked into the app |
| No push notifications received | Verify that you pass the **FCM registration token** (not the APNs device token) to `setNotificationToken`, that your APNs key or certificate is uploaded in the Firebase console, and that registration succeeded — without it the device holds no topic |
| Broadcasts resume after `disablePush()` | Expected: `disablePush()` lasts the session only and the next launch re-subscribes. Use `clearNotificationToken()` for a durable opt-out |
| Another push provider is also in the app | You do not need these calls for that provider's own delivery. Devices registered through the SDK are reached through Firebase Cloud Messaging |

### Gaming Intelligence

The Gaming Intelligence module provides high-performance batch event tracking designed for games. It includes automatic session management, event queuing with retry logic, and optional request signing.

**Configuration:**

```swift
import Linkzly

// Basic configuration
LinkzlySDK.configureGamingTracking(
    apiKey: "your_gaming_api_key",
    organizationId: "your_org_id",
    gameId: "your_game_id",
    environment: .production,
    options: nil
)

// Advanced configuration with options
let options = LinkzlyGamingOptions()
options.gameVersion = "1.2.0"
options.maxBatchSize = 50
options.flushIntervalMs = 10_000  // 10 seconds
options.debug = true

LinkzlySDK.configureGamingTracking(
    apiKey: "your_gaming_api_key",
    organizationId: "your_org_id",
    gameId: "your_game_id",
    environment: .production,
    options: options
)
```

**Player Identification:**

```swift
// Identify the current player
LinkzlySDK.identifyGamingPlayer("player_12345", traits: [
    "level": 42,
    "vip_tier": "gold",
    "registration_date": "2024-01-15"
])

// Reset player identification (e.g., on logout)
LinkzlySDK.resetGamingTracking()
```

**Session Management:**

```swift
// Sessions are tracked automatically by default
// Manual session control:
LinkzlySDK.startGamingSession()
LinkzlySDK.endGamingSession()
```

**Event Tracking:**

```swift
// Track a gaming event (batched and sent automatically)
LinkzlySDK.trackGamingEvent("level_complete", data: [
    "level": 5,
    "score": 12500,
    "time_seconds": 120,
    "stars": 3
])

// Track a high-priority event (sent immediately, bypasses batching)
LinkzlySDK.trackGamingEventImmediate("purchase", data: [
    "item_id": "sword_of_fire",
    "price": 4.99,
    "currency": "USD"
])
```

A gaming `purchase` event is game telemetry and is not recorded as revenue; report revenue with `trackPurchase`.

**Attribution:**

```swift
// Set attribution data for gaming events
LinkzlySDK.setGamingAttribution(
    clickId: "click_abc123",
    deferredDeepLink: "https://yourgame.com/promo",
    metadata: ["campaign": "summer_sale"]
)

// Clear attribution
LinkzlySDK.clearGamingAttribution()
```

**Flush Management:**

```swift
// Manually flush queued events
LinkzlySDK.flushGamingEvents { success, error in
    if success {
        print("Gaming events flushed successfully")
    }
}

// Check queue status
LinkzlySDK.getGamingStatus { status in
    print("Pending events: \(status.pendingEventCount)")
    print("Batch in flight: \(status.hasInflightBatch)")
}
```

**Configuration Options:**

| Option | Default | Description |
|--------|---------|-------------|
| `gameVersion` | `""` | Your game's version string |
| `maxBatchSize` | `100` | Maximum events per batch |
| `maxBatchBytes` | `512 KB` | Maximum batch size in bytes |
| `flushIntervalMs` | `5,000` | Auto-flush interval in milliseconds |
| `maxRetries` | `3` | Maximum retry attempts per batch |
| `retryDelayMs` | `1,000` | Delay between retries in milliseconds |
| `maxQueueSize` | `10,000` | Maximum events in queue |
| `sessionTimeoutMs` | `1,800,000` | Session timeout (30 minutes) |
| `autoSessionTracking` | `true` | Enable automatic session management |
| `debug` | `false` | Enable debug logging |
| `signingSecret` | `nil` | Optional HMAC signing secret for requests |

## Environments

The SDK supports three environments:

```swift
// Development (logging enabled)
LinkzlySDK.configure(sdkKey: "dev_key", environment: .development)

// Staging
LinkzlySDK.configure(sdkKey: "staging_key", environment: .staging)

// Production (logging disabled, default)
LinkzlySDK.configure(sdkKey: "prod_key", environment: .production)
```

## Deep Link Handlers

The SDK provides two handler methods for receiving deep link data:

### onUniversalLink

Called immediately when a Universal Link URL is captured, before server attribution:

```swift
LinkzlySDK.onUniversalLink { url, attributionData in
    // url: The captured URL
    // attributionData: Query parameters from the URL
    // Use for immediate navigation in installed apps
}
```

### onDeepLink

Called when the server returns enriched attribution data:

```swift
LinkzlySDK.onDeepLink { deepLinkData, url in
    // deepLinkData: Enriched data with smartLinkId, clickId, etc.
    // url: Original URL string (optional)
    // Use for attribution tracking and deferred deep linking
}
```

## Notifications

The SDK posts NSNotification events for flexibility:

| Notification | UserInfo Keys | Description |
|-------------|---------------|-------------|
| `.linkzlyUniversalLinkReceived` | `url`, `attributionData` | Posted when a Universal Link is received |
| `.linkzlyDeepLinkDataReceived` | `deepLinkData`, and `url` when present | Posted when attribution data is available |
| `.linkzlyAffiliateAttributionCaptured` | `clickId` | Posted when affiliate attribution is captured from a deep link |
| `.linkzlyServerConfigReceived` | `headers` | Posted when server configuration is received |

## App Delegate Helpers

Two helpers forward `UIApplicationDelegate` callbacks to the SDK and return whether the link was handled:

```swift
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return LinkzlySDK.application(app, open: url, options: options)
}

func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return LinkzlySDK.application(application, continue: userActivity, restorationHandler: restorationHandler)
}
```

The `continue` helper handles only web-browsing activities (Universal Links) and returns `false` for anything else.

## DeepLinkData API

```swift
class DeepLinkData {
    let url: String?                // Original URL
    let path: String?               // Deep link path (e.g., "/product")
    let smartLinkId: String?        // Link identifier
    let clickId: String?            // Click identifier
    let parameters: [String: Any]   // All URL parameters

    // Helper methods
    func getParameter(_ key: String) -> Any?
    func getStringParameter(_ key: String) -> String?
    func getNumberParameter(_ key: String) -> NSNumber?
    func getBoolParameter(_ key: String) -> Bool
    
    // Objective-C compatible
    var allParameters: NSDictionary { get }
}
```

## Verify Your Setup

After integration, verify the SDK is working correctly:

**1. Check SDK Initialization:**
```
Run your app and check the console for:
✅ "🚀 LinkzlySDK configured with key: your_key (environment: development)"
✅ "📊 Tracking install event (first launch detected)"
```

**2. Verify Event Tracking:**

Register `test_event` for the app first (see [Register each name in the console](https://docs.linkzly.com/docs/sdk-tracking-events#register-each-name-in-the-console)). Linkzly drops an event whose name is not registered.

```swift
LinkzlySDK.trackEvent("test_event", parameters: ["test": true])
```
Console should show:
```
📤 Tracking event: test_event
📥 Event tracked successfully
```

These lines only show that the SDK sent the event. An unregistered name is dropped by Linkzly.

**3. Test Deep Links:**
```bash
# For Universal Links
xcrun simctl openurl booted "https://yourdomain.com/product?id=123"

# For Custom URL Schemes (testing only)
xcrun simctl openurl booted "yourapp://product?id=123"
```
Console should show:
```
🔗 Universal Link received: https://yourdomain.com/product?id=123
📥 Deep link data received: /product
```

**4. Verify Deep Link Notification:**
- Set up notification observer for `.linkzlyDeepLinkDataReceived`
- Trigger a deep link
- Confirm your app receives the notification with deep link data

**Setup Verification Checklist:**
- [ ] SDK imports without errors (`import Linkzly`)
- [ ] SDK initializes on app launch (check console)
- [ ] First install event tracked automatically
- [ ] Custom events tracked successfully, once their names are registered for the app
- [ ] Deep links open your app
- [ ] Deep link data received via notifications or handlers
- [ ] Associated Domains capability configured
- [ ] Info.plist has URL schemes (for testing)

## Testing

### Test Universal Links in Simulator

```bash
xcrun simctl openurl booted "https://yourdomain.com/product?id=123"
```

### Test with Custom URL Scheme

Custom URL scheme should already be in your `Info.plist` (see configuration section above).

Test:
```bash
xcrun simctl openurl booted "yourapp://product?id=123"
```

### Expected Console Output

When running in `.development` environment, you should see detailed logs:

```
🚀 LinkzlySDK configured with key: your_sdk_key (environment: development)
📊 Tracking install event (first launch detected)
📤 Request: POST https://ske.linkzly.com/sdk/events
📥 Response: 200 OK
✅ Install tracked successfully
🔗 Universal Link received: https://yourdomain.com/product?id=123
📥 Deep link data received: DeepLinkData(path: /product, smartLinkId: abc123)
```

## Error Handling

The SDK provides detailed error information through `LinkzlyError`:

```swift
enum LinkzlyError: Error {
    case notConfigured        // SDK not initialized
    case invalidSDKKey        // Invalid SDK key
    case networkError(Error)  // Network request failed
    case invalidResponse      // Server returned invalid data
    case noDeepLinkData       // No deep link data available
}
```

## Architecture

Key components:
- **LinkzlySDK** - Main SDK interface
- **AttributionService** - Handles event tracking and attribution
- **NetworkService** - HTTP client with retry logic
- **DeviceInfo** - Collects device fingerprint

## Privacy

The SDK collects the following information:
- Device model and OS version
- App version and bundle identifier
- Screen size
- Locale and timezone
- Carrier name (if available)
- User-provided user ID (optional)
- **Advertising identifiers (with user consent):**
  - IDFA (Identifier for Advertisers) - Requires ATT permission on iOS 14.5+
  - IDFV (Identifier for Vendor) - Always available, no permission required
  - ATT authorization status

All data is sent over HTTPS. You can disable tracking at any time:

```swift
// Stop custom events, purchases and refunds (not install, open or session-end events)
LinkzlySDK.setTrackingEnabled(false)

// Disable advertising identifier collection only
LinkzlySDK.setAdvertisingTrackingEnabled(false)
```

**Privacy controls:**
- `setTrackingEnabled` and `setAdvertisingTrackingEnabled` let your app honor a user's choice. `setTrackingEnabled(false)` stops custom events, purchases and refunds; it does not stop the install, open and session-end events the SDK sends itself, and it does not stop `trackEventBatch`, so skip that call in your own code while tracking is off
- The SDK sends nothing before `configure`: an app that must send nothing before the user consents delays `configure` until the user has consented, and uses `setTrackingEnabled(false)` afterwards to stop events, purchases and refunds
- The framework includes a `PrivacyInfo.xcprivacy` manifest
- IDFA is only collected when ATT status is authorized

Whether your app meets GDPR, CCPA or App Store requirements depends on how you use these controls.

## Changelog

### v1.2
- Added Affiliate Attribution Tracking (captures and stores the affiliate click ID for your server to use in server-to-server conversion tracking)
- Added Push Notification Support — per-device token registration (`setNotificationToken`, which takes the FCM registration token) and FCM broadcast topic subscription
- Added Gaming Intelligence Module (batch event tracking)

### v1.1
- Added IDFA/IDFV advertising identifier support
- Added ATT (App Tracking Transparency) framework integration
- Added two-tier consent model (platform + app level)
- Improved UI in Example app
- Activity Logs fixes

### v1.0
- Initial release
- Universal Links support
- Attribution tracking
- Custom events
- Privacy controls

## Integration Checklist

- [ ] Created app in Linkzly Console (Dashboard > Apps)
- [ ] Copied SDK key from console
- [ ] Added the `Linkzly` package via SPM (or the Git-pinned pod)
- [ ] Called `LinkzlySDK.configure(sdkKey:environment:)` at launch
- [ ] Added Associated Domain (`applinks:{prefix}.linkz.ly`) in Xcode
- [ ] Implemented Universal Link handling in AppDelegate
- [ ] Registered device push token via `setNotificationToken` (and cleared on logout)
- [ ] Verified integration in Linkzly Console (Manage App > Integration tab)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: support@linkzly.com
- 📚 Documentation: https://docs.linkzly.com/docs/sdk-ios
- 🐛 Issues: https://github.com/Linkzly/linkzly-ios-sdk/issues
