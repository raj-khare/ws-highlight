#include "aries.h"
#include <stdexcept>

Aries::Aries(const std::string &library_path)
{
    lib_handle = dlopen(library_path.c_str(), RTLD_LAZY);
    if (!lib_handle)
    {
        throw std::runtime_error("Failed to load dynamic library: " + std::string(dlerror()));
    }

    requestMicrophoneAccess = (RequestMicrophoneAccessFunc)dlsym(lib_handle, "requestMicrophoneAccess");
    if (!requestMicrophoneAccess)
    {
        throw std::runtime_error("Failed to load requestMicrophoneAccess function: " + std::string(dlerror()));
    }

    requestFullDiskAccess = (RequestFullDiskAccessFunc)dlsym(lib_handle, "requestFullDiskAccess");
    if (!requestFullDiskAccess)
    {
        throw std::runtime_error("Failed to load requestFullDiskAccess function: " + std::string(dlerror()));
    }
}

Aries::~Aries()
{
    if (lib_handle)
    {
        dlclose(lib_handle);
    }
}

bool Aries::RequestMicrophoneAccess()
{
    return requestMicrophoneAccess();
}

bool Aries::RequestFullDiskAccess()
{
    return requestFullDiskAccess();
}