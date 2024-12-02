import AXSwift
import Accessibility
import AppKit
import Carbon
import Foundation

public func requestFullDiskAccessPermission() -> Bool {
    if let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
    {
        NSWorkspace.shared.open(url)
        return true
    }
    return false
}

public func takeScreenshot() -> Data {
    let screen = NSScreen.main
    let rect = screen!.frame
    let image = CGWindowListCreateImage(
        rect, .optionOnScreenBelowWindow, kCGNullWindowID, [.bestResolution, .nominalResolution])
    let bitmap = NSBitmapImageRep(cgImage: image!)
    return bitmap.representation(using: .png, properties: [:])!
}

public struct ApplicationDetails: Codable {
    var pid: pid_t = -1
    var appName: String = ""

    enum CodingKeys: String, CodingKey {
        case pid = "pid"
        case appName = "name"
    }
}

public func getAllApplications() -> [ApplicationDetails] {
    let runningApps = NSWorkspace.shared.runningApplications

    let visibleApps = runningApps.filter { $0.activationPolicy == .regular }

    var apps: [ApplicationDetails] = []

    for app in visibleApps {
        guard let app = Application(app) else {
            continue
        }

        var applicationDetails = ApplicationDetails()

        applicationDetails.pid = (try? app.pid()) ?? -1
        applicationDetails.appName = (try? app.attribute(.title)) ?? ""

        apps.append(applicationDetails)
    }

    return apps
}
