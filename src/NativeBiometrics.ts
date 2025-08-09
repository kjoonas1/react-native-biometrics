import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export enum BiometricAuthStatus {
  SUCCESS = 'SUCCESS',
  FAILED_ATTEMPT = 'FAILED_ATTEMPT',
  CANCELLED = 'CANCELLED',
  LOCKOUT = 'LOCKOUT',
  DISABLED = 'DISABLED',
  ERROR = 'ERROR',
  FALLBACK = 'FALLBACK',
}

export type BiometricAuthResult =
  | { status: BiometricAuthStatus.SUCCESS }
  | { status: BiometricAuthStatus.FAILED_ATTEMPT; message?: string }
  | { status: BiometricAuthStatus.CANCELLED; message?: string }
  | { status: BiometricAuthStatus.LOCKOUT; message?: string }
  | { status: BiometricAuthStatus.DISABLED; message?: string }
  | { status: BiometricAuthStatus.ERROR; message?: string }
  | { status: BiometricAuthStatus.FALLBACK; message?: string };

export type BiometricAuthChallengeResult = BiometricAuthResult & {
  signature: string;
};

export interface KeyPairResult {
  publicKey: string;
  status: 'SUCCESS' | 'ERROR';
}

interface Spec extends TurboModule {
  generateKeyPair(): string | undefined;
  deleteKeyPair(): boolean;
  isBiometricAvailable(): boolean;
  getPublicKey(): string | undefined;
  authenticate(reason: string): Promise<BiometricAuthResult>;
  authenticateWithChallenge(
    reason: string,
    challenge: string
  ): Promise<BiometricAuthChallengeResult>;

  /**
   * iOS only method — checks if NSFaceIDUsageDescription is set in Info.plist
   */
  isFaceIDUsageDescriptionPresent(): boolean;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Biometrics');
