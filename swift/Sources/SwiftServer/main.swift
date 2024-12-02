import AppKit
import Darwin
import Foundation
import Vapor

struct WSMessage<DataType: Codable>: Codable {
    let type: String
    let method: String
    let data: DataType?
}

extension WebSocket {
    func sendResponse<DataType: Codable>(method: String, data: DataType) {
        let response = WSMessage(
            type: "response",
            method: method,
            data: data
        )

        if let jsonData = try? JSONEncoder().encode(response),
            let jsonString = String(data: jsonData, encoding: .utf8)
        {
            try? self.send(jsonString)
        }
    }
}

class ClipboardMonitor {
    private var lastChangeCount: Int
    private var timer: Timer?
    private var webSocket: WebSocket?

    init() {
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring(webSocket: WebSocket) {
        self.webSocket = webSocket

        // Run timer on the main thread
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.checkClipboard()
            }
            // Make sure the timer is added to the main run loop
            RunLoop.main.add(self.timer!, forMode: .common)
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let currentCount = NSPasteboard.general.changeCount
        if currentCount != lastChangeCount {
            lastChangeCount = currentCount
            let content = NSPasteboard.general.string(forType: .string) ?? ""
            webSocket?.sendResponse(method: "clipboard.changed", data: content)
        }
    }
}

public func configure(_ app: Application) throws {
    app.webSocket("socket") { req, ws in
        let clipboardMonitor = ClipboardMonitor()
        clipboardMonitor.startMonitoring(webSocket: ws)

        // Handle incoming messages
        ws.onText { [weak clipboardMonitor] ws, text in
            print(text)
            guard let data = text.data(using: .utf8),
                let message = try? JSONDecoder().decode(WSMessage<String>.self, from: data)
            else {
                return
            }

            // Handle requests using switch
            switch (message.type, message.method) {
            case ("request", "clipboard.get"):
                let content = NSPasteboard.general.string(forType: .string) ?? ""
                ws.sendResponse(method: message.method, data: content)

            case ("request", "accessibility.request_full_disk_access"):
                let success = requestFullDiskAccessPermission()
                ws.sendResponse(method: message.method, data: success)

            case ("request", "screenshot.take"):
                let screenshotData = takeScreenshot()
                let base64String = screenshotData.base64EncodedString()
                ws.sendResponse(method: message.method, data: base64String)

            case ("request", "accessibility.get_all_applications"):
                let apps = getAllApplications()
                ws.sendResponse(method: message.method, data: apps)

            default:
                print("Unhandled message: \(message)")
            }
        }

        // Handle client disconnect
        ws.onClose.whenComplete { _ in
            clipboardMonitor.stopMonitoring()
        }
    }
}

let app = try Application(.detect())
defer { app.shutdown() }

// Configure server to run on port 8000
app.http.server.configuration.port = 8000

// Configure the application
try configure(app)

// Before running the application, ensure we have a running main RunLoop
let runLoop = RunLoop.main

DispatchQueue.global().async {
    try! app.run()
}
runLoop.run()
