import React, { useState } from 'react';
import {
  Text,
  View,
  StyleSheet,
  Button,
  SafeAreaView,
  Alert,
} from 'react-native';
import {
  authenticate,
  isBiometricAvailable,
  type BiometricAuthResult,
} from '@kjoonas1/react-native-biometrics';

export default function App() {
  const [status, setStatus] = useState<string>('Unknown');

  const handleAuth = async () => {
    try {
      const available = isBiometricAvailable();
      if (!available) {
        setStatus('Biometrics not available');
        return;
      }

      const result: BiometricAuthResult = await authenticate(
        'Authenticate to continue'
      );

      setStatus(result.status);

      if (result.status === 'SUCCESS') {
        Alert.alert('Success', 'Authentication succeeded!');
      } else if (result.message) {
        Alert.alert(result.status, result.message);
      }
    } catch (err) {
      setStatus('ERROR');
      Alert.alert('Error', 'Unexpected error during authentication');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Biometric Authentication</Text>
      <Text style={styles.status}>Status: {status}</Text>
      <View style={styles.buttonContainer}>
        <Button title="Use Biometrics" onPress={handleAuth} />
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
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 20,
  },
  status: {
    fontSize: 16,
    marginBottom: 20,
  },
  buttonContainer: {
    width: '60%',
  },
});
