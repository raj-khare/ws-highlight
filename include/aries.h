#pragma once

#include <string>
#include <dlfcn.h>

// Add any necessary type definitions
typedef bool (*RequestMicrophoneAccessFunc)();
typedef bool (*RequestFullDiskAccessFunc)();

class Aries
{
private:
    void *lib_handle;
    RequestMicrophoneAccessFunc requestMicrophoneAccess;
    RequestFullDiskAccessFunc requestFullDiskAccess;

public:
    Aries(const std::string &library_path);
    ~Aries();

    bool RequestMicrophoneAccess();
    bool RequestFullDiskAccess();
};