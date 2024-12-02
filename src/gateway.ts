const MAPPINGS: Record<string, string> = {
    'clipboard.get': 'swift',
    'accessibility.request_full_disk_access': 'swift',
    'accessibility.get_all_applications': 'swift',
    'screenshot.take': 'swift',
}

class Gateway {
    private servers: Map<string, WebSocket>;

    constructor() {
        this.servers = new Map();
        this.initializeConnections();
    }

    private initializeConnections() {
        // Connect to different service WebSocket servers
        this.connectToServer('swift', 'ws://localhost:8000/socket');
        // Add more services as needed
    }

    private onMessage(event: MessageEvent) {
        const data = JSON.parse(event.data);
        console.log(`Response from server:`, data);

        if (data.type === "response" && data.method === "screenshot.take") {
            const image = new Image();
            // Prefix the base64 data with proper data URL format
            image.src = `data:image/png;base64,${data.data}`;
            document.body.appendChild(image);
        }
    }

    private connectToServer(service: string, url: string) {
        const ws = new WebSocket(url);
        ws.onopen = () => console.log(`Connected to ${service} service`);
        ws.onerror = (error) => console.error(`${service} connection error:`, error);
        ws.onmessage = this.onMessage;
        this.servers.set(service, ws);
    }

    public send(request: { method: string, data: any }) {
        const targetServer = this.servers.get(MAPPINGS[request.method]);
        if (targetServer) {
            targetServer.send(JSON.stringify({
                type: "request",
                method: request.method,
                data: request.data,
            }));
        } else {
            console.error(`No server found for service: ${request.method}`);
        }
    }
}

export default Gateway;