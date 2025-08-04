import Biometrics, { type BiometricAuthResult } from './NativeBiometrics';

export function authenticate(reason: string): Promise<BiometricAuthResult> {
  return Biometrics.authenticate(reason);
}

export function isBiometricAvailable(): boolean {
  return Biometrics.isBiometricAvailable();
}

export type { BiometricAuthResult } from './NativeBiometrics';
export { BiometricAuthStatus } from './NativeBiometrics';
