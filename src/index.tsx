import { Platform } from 'react-native';
import Biometrics, {
  type BiometricAuthResult,
  type BiometricAuthChallengeResult,
} from './NativeBiometrics';

export function authenticate(reason: string): Promise<BiometricAuthResult>;
export function authenticate(
  reason: string,
  challenge: string
): Promise<BiometricAuthChallengeResult>;
export function authenticate(
  reason: string,
  challenge?: string
): Promise<BiometricAuthResult | BiometricAuthChallengeResult> {
  if (challenge) {
    return Biometrics.authenticateWithChallenge(reason, challenge);
  }
  return Biometrics.authenticate(reason);
}

export function deleteKeyPair(): boolean {
  return Biometrics.deleteKeyPair();
}

export function generateKeyPair(): string | undefined {
  return Biometrics.generateKeyPair();
}

export function isBiometricAvailable(): boolean {
  return Biometrics.isBiometricAvailable();
}

export function getPublicKey(): string | undefined {
  return Biometrics.getPublicKey();
}

if (Platform.OS === 'ios') {
  if (!Biometrics.isFaceIDUsageDescriptionPresent()) {
    console.warn(
      '⚠️ NSFaceIDUsageDescription key is missing in Info.plist. Face ID will not work properly.'
    );
  }
}

export type {
  BiometricAuthResult,
  BiometricAuthChallengeResult,
} from './NativeBiometrics';
export { BiometricAuthStatus } from './NativeBiometrics';
