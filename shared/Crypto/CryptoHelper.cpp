#include "CryptoHelper.h"
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <string>
#include <vector>
#include <openssl/evp.h>

CryptoHelper::CryptoHelper() {}

CryptoHelper::~CryptoHelper() {}

std::vector<uint8_t> CryptoHelper::sign(const std::vector<uint8_t> &data, const std::vector<uint8_t> &privateKey)
{
    std::vector<uint8_t> signature;

    BIO *bio = BIO_new_mem_buf(privateKey.data(), static_cast<int>(privateKey.size()));
    if (!bio)
        return signature;

    EVP_PKEY *pkey = PEM_read_bio_PrivateKey(bio, nullptr, nullptr, nullptr);
    BIO_free(bio);
    if (!pkey)
        return signature;

    EVP_MD_CTX *ctx = EVP_MD_CTX_new();
    if (!ctx)
    {
        EVP_PKEY_free(pkey);
        return signature;
    }

    if (EVP_DigestSignInit(ctx, nullptr, EVP_sha256(), nullptr, pkey) <= 0)
    {
        EVP_MD_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return signature;
    }

    if (EVP_DigestSignUpdate(ctx, data.data(), data.size()) <= 0)
    {
        EVP_MD_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return signature;
    }

    size_t sigLen = 0;
    if (EVP_DigestSignFinal(ctx, nullptr, &sigLen) <= 0)
    {
        EVP_MD_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return signature;
    }

    signature.resize(sigLen);
    if (EVP_DigestSignFinal(ctx, signature.data(), &sigLen) <= 0)
    {
        signature.clear();
    }
    else
    {
        signature.resize(sigLen);
    }

    EVP_MD_CTX_free(ctx);
    EVP_PKEY_free(pkey);

    return signature;
}

bool CryptoHelper::generateKeyPair(std::string &privateKey, std::string &publicKey)
{
    EVP_PKEY_CTX *ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, NULL);
    if (!ctx)
    {
        return false;
    }

    if (EVP_PKEY_keygen_init(ctx) <= 0)
    {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    if (EVP_PKEY_CTX_set_rsa_keygen_bits(ctx, 2048) <= 0)
    {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    EVP_PKEY *pkey = NULL;
    if (EVP_PKEY_keygen(ctx, &pkey) <= 0)
    {
        EVP_PKEY_CTX_free(ctx);
        return false;
    }

    BIO *privateBio = BIO_new(BIO_s_mem());
    if (!PEM_write_bio_PrivateKey(privateBio, pkey, NULL, NULL, 0, NULL, NULL))
    {
        EVP_PKEY_free(pkey);
        EVP_PKEY_CTX_free(ctx);
        BIO_free(privateBio);
        return false;
    }

    char *privateData = NULL;
    long privateLength = BIO_get_mem_data(privateBio, &privateData);
    privateKey.assign(privateData, privateLength);
    BIO_free(privateBio);

    BIO *publicBio = BIO_new(BIO_s_mem());
    if (!PEM_write_bio_PUBKEY(publicBio, pkey))
    {
        EVP_PKEY_free(pkey);
        EVP_PKEY_CTX_free(ctx);
        BIO_free(publicBio);
        return false;
    }

    char *publicData = NULL;
    long publicLength = BIO_get_mem_data(publicBio, &publicData);
    publicKey.assign(publicData, publicLength);
    BIO_free(publicBio);

    EVP_PKEY_free(pkey);
    EVP_PKEY_CTX_free(ctx);
    return true;
}
