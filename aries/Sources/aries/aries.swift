import AVFoundation
import AppKit
import CoreImage
import Darwin
import Foundation

@_cdecl("requestMicrophoneAccess")
public func requestMicrophoneAccessWrapper() -> Bool {
    if #available(macOS 10.15, *) {
        return requestMicrophonePermission()
    }
    return false
}

@available(macOS 10.15, *)
public func requestMicrophonePermission() -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .authorized:
        print("[aries] Microphone access previously authorized.")
        return true
    case .notDetermined:
        // The user has not yet been asked for microphone access. Request permission.
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                print("[aries] Microphone access granted.")
            } else {
                print("[aries] Microphone access denied.")
            }
        }
    default:
        // Open microphone permissions in settings
        if let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")
        {
            NSWorkspace.shared.open(url)
        }
        return false
    }
    return false
}

@_cdecl("requestFullDiskAccess")
public func requestFullDiskAccessWrapper() -> Bool {
    return requestFullDiskAccessPermission()
}

public func requestFullDiskAccessPermission() -> Bool {
    if let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
    {
        NSWorkspace.shared.open(url)
        return true
    }
    return false
}
