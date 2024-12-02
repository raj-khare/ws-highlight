extension WebSocket {
    func sendResponse<T: Encodable>(method: String, content: T) {
        let response = WSMessage(
            type: "response",
            method: method,
            data: WSData(content: content)
        )

        if let jsonData = try? JSONEncoder().encode(response),
            let jsonString = String(data: jsonData, encoding: .utf8)
        {
            try? self.send(jsonString)
        }
    }
}
