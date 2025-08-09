#ifdef __cplusplus
#pragma once
#include <string>
#include <vector>

class CryptoHelper {
public:
    CryptoHelper();
    ~CryptoHelper();
    bool generateKeyPair(std::string& privateKey, std::string& publicKey);
    std::vector<uint8_t> sign(const std::vector<uint8_t>& data, const std::vector<uint8_t>& privateKey);
};
#endif
