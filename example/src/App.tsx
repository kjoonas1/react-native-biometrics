import { useEffect, useState } from 'react';
import {
  Text,
  View,
  StyleSheet,
  SafeAreaView,
  Alert,
  TouchableOpacity,
} from 'react-native';
import {
  authenticate,
  isBiometricAvailable,
  type BiometricAuthResult,
  BiometricAuthStatus,
  generateKeyPair,
  getPublicKey,
  type BiometricAuthChallengeResult,
  deleteKeyPair,
} from '@kjoonas1/react-native-biometrics';

const base64Chars =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function base64Encode(uint8Array: Uint8Array) {
  let output = '';
  let i = 0;

  while (i < uint8Array.length) {
    const byte1 = uint8Array[i++] || 0;
    const byte2 = uint8Array[i++] || 0;
    const byte3 = uint8Array[i++] || 0;

    const enc1 = byte1 >> 2;
    const enc2 = ((byte1 & 3) << 4) | (byte2 >> 4);
    const enc3 = ((byte2 & 15) << 2) | (byte3 >> 6);
    const enc4 = byte3 & 63;

    if (i - 1 > uint8Array.length) {
      output += base64Chars.charAt(enc1) + base64Chars.charAt(enc2) + '==';
    } else if (i > uint8Array.length) {
      output +=
        base64Chars.charAt(enc1) +
        base64Chars.charAt(enc2) +
        base64Chars.charAt(enc3) +
        '=';
    } else {
      output +=
        base64Chars.charAt(enc1) +
        base64Chars.charAt(enc2) +
        base64Chars.charAt(enc3) +
        base64Chars.charAt(enc4);
    }
  }

  return output;
}

function generateRandomChallenge(length = 32) {
  const randomBytes = new Uint8Array(length);
  for (let i = 0; i < length; i++) {
    randomBytes[i] = Math.floor(Math.random() * 256);
  }
  return base64Encode(randomBytes);
}

export default function App() {
  const [status, setStatus] = useState<BiometricAuthStatus | 'Unknown'>(
    'Unknown'
  );
  const [publicKey, setPublicKey] = useState('');

  useEffect(() => {
    const pk = getPublicKey();
    if (pk) {
      setPublicKey(pk);
    }
  }, []);

  const handleStorePublicKeyToBackend = (key: string) => {
    setPublicKey(key);
  };

  const handleBackendAuthentication = (
    signature: string,
    challenge: string
  ) => {
    console.log('Verifying signature:', signature);
    console.log('Against challenge:', challenge);
    console.log('Using public key:', publicKey);
  };

  const handleAuth = async () => {
    try {
      const available = isBiometricAvailable();
      if (!available) {
        setStatus(BiometricAuthStatus.DISABLED);
        return;
      }

      const result: BiometricAuthResult = await authenticate(
        'Authenticate to continue'
      );

      setStatus(result.status);

      if (result.status === BiometricAuthStatus.SUCCESS) {
        Alert.alert('Success', 'Authentication succeeded!');
      } else if (result.message) {
        Alert.alert(result.status, result.message);
      }
    } catch (err) {
      setStatus(BiometricAuthStatus.ERROR);
      Alert.alert('Error', 'Unexpected error during authentication');
    }
  };

  const handleAuthWithChallenge = async () => {
    try {
      const available = isBiometricAvailable();
      if (!available) {
        setStatus(BiometricAuthStatus.DISABLED);
        return;
      }
      const challenge = generateRandomChallenge(25);
      const result: BiometricAuthChallengeResult = await authenticate(
        'Authenticate to continue',
        challenge
      );

      console.log('RESULT', result);
      setStatus(result.status);

      if (result.status === BiometricAuthStatus.SUCCESS) {
        handleBackendAuthentication(result.signature, challenge);
        Alert.alert('Success', 'Authentication succeeded!');
      } else if (result.message) {
        Alert.alert(result.status, result.message);
      }
    } catch (err) {
      setStatus(BiometricAuthStatus.ERROR);
      Alert.alert('Error', 'Unexpected error during authentication');
    }
  };

  const handleCreateKeyPair = () => {
    const pubKey = generateKeyPair();
    if (pubKey) {
      handleStorePublicKeyToBackend(pubKey);
    } else {
      console.log('Creating keys failed');
    }
  };

  const handleDeleteKeyPair = () => {
    deleteKeyPair();
    setPublicKey('');
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Biometric Authentication</Text>
      <Text style={styles.status}>Status: {status}</Text>
      {publicKey ? (
        <Text style={styles.publicKeyLabel}>Public Key:</Text>
      ) : null}
      {publicKey ? <Text style={styles.publicKey}>{publicKey}</Text> : null}
      <View style={styles.buttonContainer}>
        <TouchableOpacity onPress={handleAuth} style={styles.button}>
          <Text style={styles.buttonText}>
            Use Biometrics without challenge
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={handleAuthWithChallenge}
          style={styles.button}
        >
          <Text style={styles.buttonText}>Use Biometrics with Challenge</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={handleCreateKeyPair} style={styles.button}>
          <Text style={styles.buttonText}>Create Key Pair</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={handleDeleteKeyPair} style={styles.button}>
          <Text style={styles.buttonText}>Delete key pair</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: 24,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f2f2f2',
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    marginBottom: 24,
  },
  status: {
    fontSize: 16,
    marginBottom: 24,
    color: '#333',
  },
  publicKeyLabel: {
    fontWeight: '600',
    marginBottom: 4,
    textAlign: 'center',
    paddingHorizontal: 10,
  },
  publicKey: {
    fontSize: 12,
    fontFamily: 'monospace',
    paddingHorizontal: 12,
    marginBottom: 24,
    maxWidth: '90%',
    textAlign: 'center',
    color: '#444',
  },
  buttonContainer: {
    width: '80%',
    gap: 12,
  },
  button: {
    backgroundColor: '#00cc3aff',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    shadowColor: '#009930ff',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 4,
  },
  buttonText: {
    color: 'white',
    fontWeight: '600',
    fontSize: 16,
  },
});
