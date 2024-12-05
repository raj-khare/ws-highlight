CXX = g++
CXXFLAGS = -std=c++17 -Wall -I/opt/homebrew/include -Iinclude
LDFLAGS = -L/opt/homebrew/lib -lboost_system -ldl

TARGET = dist/main
SRCS = src/main.cpp src/aries.cpp
OBJS = $(SRCS:.cpp=.o)

$(TARGET): $(OBJS) dist/aries.dylib | dist
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

dist/aries.dylib: | dist
	cd aries && swift build -c release
	cp aries/.build/release/libaries.dylib dist/libaries.dylib

dist:
	mkdir -p dist

clean:
	rm -rf dist
	rm -f $(OBJS)