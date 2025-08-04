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

interface Spec extends TurboModule {
  isBiometricAvailable(): boolean;
  authenticate(reason: string): Promise<BiometricAuthResult>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Biometrics');
