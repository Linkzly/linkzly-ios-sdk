# LinkzlySDK for iOS

[![Swift Version](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2012.0%2B%20%7C%20macOS%2010.14%2B-lightgrey.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

LinkzlySDK is a powerful iOS SDK for deep linking and attribution tracking. Track app installs, opens, and custom events while seamlessly handling Universal Links for deferred deep linking.

## Features

- 🔗 **Universal Links Support** - Handle deep links automatically
- 📊 **Attribution Tracking** - Track installs, opens, and custom events
- 🎯 **Deferred Deep Linking** - Match users to campaigns after install
- 👤 **User Identification** - Associate events with specific users
- 🔐 **Privacy-First** - Opt-in/opt-out tracking controls
- 📱 **Advertising Identifiers** - IDFA, IDFV, and ATT framework support
- 🤝 **Affiliate Attribution** - Track affiliate clicks with S2S postback support
- 🔔 **Push Notifications** - Firebase Cloud Messaging integration
- 🎮 **Gaming Intelligence** - Batch event tracking for games with session management
- ⚡ **Lightweight** - Zero third-party dependencies
- 🎨 **SwiftUI & UIKit** - Works with both frameworks
- 🔧 **Objective-C Compatible** - Full Objective-C bridging support

## Requirements

| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| iOS | 12.0+ | 15.0+ |
| macOS | 10.14+ | 12.0+ |
| Xcode | 14.0+ | 15.0+ |
| Swift | 5.7+ | 5.9+ |
| CocoaPods | 1.10+ | Latest |

**Language Support:**
- Swift (primary, all examples below)
- Objective-C (fully compatible)

## Installation

### Swift Package Manager

Add LinkzlySDK to your project using Xcode:

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/AdsGames24/linkzly-ios-package.git`
3. Select the version or branch you want to use
4. Click **Add Package**

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/AdsGames24/linkzly-ios-package.git", from: "1.0.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["Linkzly"]
)
```

### CocoaPods (Coming Soon)

```ruby
pod 'LinkzlySDK'
```

### Carthage (Coming Soon)

```
github "AdsGames24/linkzly-ios-package"
```

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
            sdkKey: "your_sdk_key_here",
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
            sdkKey: "your_sdk_key_here",
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
            sdkKey: "your_sdk_key_here",
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

#### Add Associated Domains to Your App

1. In Xcode, select your target → **Signing & Capabilities**
2. Click **+ Capability** → **Associated Domains**
3. Add: `applinks:yourdomain.com`

#### Create .apple-app-site-association File

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

```swift
// Track custom events
LinkzlySDK.trackEvent("purchase_completed", parameters: [
    "product_id": "12345",
    "amount": 29.99,
    "currency": "USD"
])

// Track screen views
LinkzlySDK.trackEvent("screen_view", parameters: [
    "screen_name": "ProductDetail"
])
```

### Track Purchases

```swift
// Track purchase events with completion handler
LinkzlySDK.trackPurchase(parameters: [
    "product_id": "12345",
    "amount": 29.99,
    "currency": "USD",
    "transaction_id": "txn_abc123"
]) { result in
    switch result {
    case .success(let response):
        print("Purchase tracked: \(response.eventId ?? "")")
    case .failure(let error):
        print("Error: \(error)")
    }
}
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

### Session Management

```swift
// Start a new session
LinkzlySDK.startSession()

// End current session
LinkzlySDK.endSession()
```

### Privacy Controls

```swift
// Disable tracking
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
// Track app install (automatically called on first launch)
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

// Track app open
LinkzlySDK.trackOpen { result in
    // Handle result
}
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

**Example Event Payload:**

```json
{
  "type": "sdk_event",
  "eventType": "purchase_completed",
  "platform": "ios",
  "idfa": "12345678-90AB-CDEF-1234-567890ABCDEF",
  "idfv": "87654321-FEDC-BA09-8765-4321FEDCBA09",
  "attStatus": "authorized",
  "deviceFingerprint": {
    "deviceModel": "iPhone14,2",
    "systemVersion": "17.2"
  }
}
```

### SKAdNetwork Support (iOS 14+)

The SDK supports SKAdNetwork for privacy-preserving attribution:

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

// Get full attribution data
if let attribution = LinkzlySDK.getAffiliateAttribution() {
    print("Click ID: \(attribution.clickId)")
    print("Network: \(attribution.network ?? "unknown")")
    print("Campaign: \(attribution.campaign ?? "unknown")")
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
| `getAffiliateAttribution()` | `AffiliateAttribution?` | Returns full attribution data |
| `hasAffiliateAttribution()` | `Bool` | Checks if attribution data exists |
| `clearAffiliateAttribution()` | `Void` | Clears stored attribution data |

**Storage & Expiry:**
- Attribution data is stored securely in the Keychain (with UserDefaults fallback)
- Data automatically expires after **30 days**
- Only the most recent affiliate click is stored (newer clicks overwrite older ones)

### Push Notification Support

The SDK provides opt-in push notification support via Firebase Cloud Messaging (FCM). This allows your app to receive broadcast push notifications from the Linkzly platform.

**Prerequisites:**
- Firebase Cloud Messaging integrated in your app
- Linkzly SDK configured and initialized

**Setup (Swift):**

```swift
import Linkzly
import FirebaseMessaging

// In your AppDelegate or app initialization
func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // 1. Configure Firebase first
    FirebaseApp.configure()

    // 2. Configure Linkzly SDK
    LinkzlySDK.configure(sdkKey: "your_sdk_key", environment: .production)

    // 3. Initialize push notifications
    let success = LinkzlySDK.initializePush()
    if success {
        print("Push notifications initialized successfully")
    }

    return true
}
```

**Setup (Objective-C):**

```objc
#import <Linkzly/Linkzly.h>
@import FirebaseMessaging;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [FIRApp configure];
    [LinkzlySDK configureWithSdkKey:@"your_sdk_key" environment:LinkzlyEnvironmentProduction];

    BOOL success = [LinkzlySDK initializePush];
    NSLog(@"Push init: %@", success ? @"YES" : @"NO");

    return YES;
}
```

**Disabling Push Notifications:**

```swift
// Unsubscribe from Linkzly push notifications
LinkzlySDK.disablePush()
```

**How It Works:**
1. `initializePush()` subscribes the device to the Linkzly FCM broadcast topic
2. The SDK uses runtime reflection to access Firebase Messaging — no Firebase dependency in the SDK itself
3. Returns `false` safely if Firebase is not available in the app

**Compatibility:**
- Works alongside other push notification providers (OneSignal, Braze, Airship, etc.)
- Does not interfere with your existing push notification setup
- Only subscribes to Linkzly-specific FCM topics

**Troubleshooting:**

| Issue | Solution |
|-------|----------|
| `initializePush()` returns `false` | Ensure Firebase is configured before calling `initializePush()` |
| No push notifications received | Verify FCM setup and APNs certificate configuration |
| Conflict with other push providers | Linkzly uses topic-based messaging, which is independent of other providers |

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
| `.linkzlyDeepLinkDataReceived` | `deepLinkData` | Posted when attribution data is available |
| `.linkzlyAffiliateAttributionCaptured` | `affiliateAttribution` | Posted when affiliate attribution is captured from a deep link |
| `.linkzlyServerConfigReceived` | Server config data | Posted when server configuration is received |

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
```swift
LinkzlySDK.trackEvent("test_event", parameters: ["test": true])
```
Console should show:
```
📤 Tracking event: test_event
📥 Event tracked successfully
```

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
- [ ] Custom events tracked successfully
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
// Disable all tracking
LinkzlySDK.setTrackingEnabled(false)

// Disable advertising identifier collection only
LinkzlySDK.setAdvertisingTrackingEnabled(false)
```

**Privacy Compliance:**
- GDPR compliant - respects user consent preferences
- CCPA compliant - opt-out controls available
- App Store compliant - includes PrivacyInfo.xcprivacy manifest
- ATT compliant - respects iOS tracking authorization

## Example App

Explore a complete working example demonstrating all SDK features:

**Repository:** [https://github.com/MarenTech/linkzly-ios-sdk-example](https://github.com/MarenTech/linkzly-ios-sdk-example.git)

```bash
git clone https://github.com/MarenTech/linkzly-ios-sdk-example.git
cd linkzly-ios-sdk-example
open LinkzlyApp.xcodeproj
```

The example app showcases:
- SDK configuration and initialization
- Universal Links handling with closure handlers
- Deep link navigation patterns
- Event tracking (custom events, purchases)
- User and visitor identification
- Session management
- Privacy controls and ATT permission requests
- Advertising identifier collection

## Changelog

### v1.2
- Added Affiliate Attribution Tracking (S2S postback support)
- Added Push Notification Support (Firebase Cloud Messaging)
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: support@linkzly.com
- 📚 Documentation: https://app.linkzly.com
- 🐛 Issues: https://github.com/MarenTech/linkzly-ios-sdk/issues
