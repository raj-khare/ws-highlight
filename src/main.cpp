#include <websocketpp/config/asio_no_tls.hpp>
#include <websocketpp/server.hpp>
#include <iostream>
#include <functional>
#include <nlohmann/json.hpp>
#include <memory>
#include "aries.h"

using websocketpp::lib::bind;
using websocketpp::lib::placeholders::_1;
using websocketpp::lib::placeholders::_2;
using json = nlohmann::json;

// Define the WebSocket server type
typedef websocketpp::server<websocketpp::config::asio> server;
typedef server::message_ptr message_ptr;

class WebSocketServer
{
private:
    server ws_server;
    std::unique_ptr<Aries> aries;

    void handle_request(websocketpp::connection_hdl hdl, const json &request)
    {
        json response;
        response["type"] = "response";
        response["method"] = request["method"];

        if (request["method"] == "accessibility.requestMicrophoneAccess")
        {
            bool result = aries->RequestMicrophoneAccess();
            response["data"]["granted"] = result;
        }
        else if (request["method"] == "accessibility.requestFullDiskAccess")
        {
            bool result = aries->RequestFullDiskAccess();
            response["data"]["success"] = result;
        }
        else if (request["method"] == "clipboard.get")
        {
            response["data"]["content"] = "Hello, world!";
        }
        else
        {
            throw std::runtime_error("Unknown method: " + std::string(request["method"]));
        }

        ws_server.send(hdl, response.dump(), websocketpp::frame::opcode::text);
    }

    void send_event(websocketpp::connection_hdl hdl, const std::string &event, const json &data)
    {
        json event_message;
        event_message["type"] = "event";
        event_message["event"] = event;
        event_message["data"] = data;

        ws_server.send(hdl, event_message.dump(), websocketpp::frame::opcode::text);
    }

public:
    WebSocketServer()
    {
        aries = std::make_unique<Aries>("libaries.dylib");

        // Initialize the server
        ws_server.set_access_channels(websocketpp::log::alevel::all);
        ws_server.clear_access_channels(websocketpp::log::alevel::frame_payload);

        // Initialize ASIO
        ws_server.init_asio();

        // Register handlers
        ws_server.set_message_handler(bind(&WebSocketServer::on_message, this, ::_1, ::_2));
        ws_server.set_open_handler(bind(&WebSocketServer::on_open, this, ::_1));
        ws_server.set_close_handler(bind(&WebSocketServer::on_close, this, ::_1));
    }

    void on_message(websocketpp::connection_hdl hdl, message_ptr msg)
    {
        try
        {
            json message = json::parse(msg->get_payload());

            if (!message.contains("type"))
            {
                throw std::runtime_error("Message missing 'type' field");
            }

            std::string type = message["type"];
            if (type == "request")
            {
                if (!message.contains("method") || !message.contains("data"))
                {
                    throw std::runtime_error("Invalid request format");
                }
                handle_request(hdl, message);
            }
            else
            {
                throw std::runtime_error("Unknown message type: " + type);
            }
        }
        catch (const json::exception &e)
        {
            json error_response;
            error_response["type"] = "response";
            error_response["error"] = "Invalid JSON format: " + std::string(e.what());
            ws_server.send(hdl, error_response.dump(), websocketpp::frame::opcode::text);
        }
        catch (const std::exception &e)
        {
            json error_response;
            error_response["type"] = "response";
            error_response["error"] = e.what();
            ws_server.send(hdl, error_response.dump(), websocketpp::frame::opcode::text);
        }
    }

    void on_open(websocketpp::connection_hdl hdl)
    {
        std::cout << "New connection opened" << std::endl;
    }

    void on_close(websocketpp::connection_hdl hdl)
    {
        std::cout << "Connection closed" << std::endl;
    }

    void run(uint16_t port)
    {
        // Listen on the specified port
        ws_server.listen(port);

        // Start the server accept loop
        ws_server.start_accept();

        // Start the ASIO io_service run loop
        try
        {
            std::cout << "WebSocket server listening on port " << port << std::endl;
            ws_server.run();
        }
        catch (websocketpp::exception const &e)
        {
            std::cout << "WebSocket server error: " << e.what() << std::endl;
        }
    }
};

int main()
{
    WebSocketServer server;
    server.run(11200); // Run server on port 11200
    return 0;
}