#include <simplehttp/simplehttpserver.h>

#include <optional>
#include <string>

void instantiate(std::optional<simplehttp::SimpleHttpServer>& obj,
                 const std::string& address, unsigned short port) {
  obj.emplace(address, port);
}
