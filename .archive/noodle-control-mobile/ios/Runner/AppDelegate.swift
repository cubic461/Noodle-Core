import UIKit
import Flutter
import UserNotifications
import BackgroundTasks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Set up Flutter
        GeneratedPluginRegistrant.register(with: self)
        
        // Set up notification delegates
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
        
        // Register background tasks
        registerBackgroundTasks()
        
        // Set up method channel for native communication
        setupMethodChannel()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Background Tasks
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.noodlecontrol.app.background-sync", using: nil) { task in
            self.handleBackgroundSync(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleBackgroundSync(task: BGAppRefreshTask) {
        // Schedule the next background refresh
        scheduleBackgroundSync()
        
        // Handle background sync
        let operation = BackgroundSyncOperation()
        task.expirationHandler = {
            operation.cancel()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        let queue = OperationQueue()
        queue.addOperation(operation)
    }
    
    private func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.noodlecontrol.app.background-sync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background refresh: \(error)")
        }
    }
    
    // MARK: - Method Channel
    private func setupMethodChannel() {
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.noodlecontrol.app/native", binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "getPlatformVersion":
                result("iOS " + UIDevice.current.systemVersion)
            case "getDeviceInfo":
                let deviceInfo: [String: Any] = [
                    "model": UIDevice.current.model,
                    "systemVersion": UIDevice.current.systemVersion,
                    "name": UIDevice.current.name,
                    "localizedModel": UIDevice.current.localizedModel
                ]
                result(deviceInfo)
            case "scheduleNotification":
                if let args = call.arguments as? [String: Any],
                   let title = args["title"] as? String,
                   let body = args["body"] as? String {
                    self?.scheduleNotification(title: title, body: body)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                }
            case "enableBackgroundRefresh":
                self?.scheduleBackgroundSync()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - Notifications
    private func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // MARK: - URL Handling
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle deep links
        if url.scheme == "noodlecontrol" {
            handleDeepLink(url: url)
            return true
        }
        
        return false
    }
    
    private func handleDeepLink(url: URL) {
        // Process deep link URL and communicate with Flutter
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.noodlecontrol.app/deeplink", binaryMessenger: controller.binaryMessenger)
        
        methodChannel.invokeMethod("onDeepLinkReceived", arguments: url.absoluteString)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        
        // Communicate with Flutter about the notification
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.noodlecontrol.app/notifications", binaryMessenger: controller.binaryMessenger)
        
        methodChannel.invokeMethod("onNotificationTapped", arguments: userInfo)
        
        completionHandler()
    }
}

// MARK: - Background Operation
class BackgroundSyncOperation: Operation {
    override func main() {
        if isCancelled {
            return
        }
        
        // Perform background sync operations here
        // This would typically sync data with the server
        
        // Simulate work
        Thread.sleep(forTimeInterval: 2)
    }
}