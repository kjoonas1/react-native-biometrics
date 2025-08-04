import Biometrics from './NativeBiometrics';

export function authenticate(reason: string): Promise<boolean> {
  return Biometrics.authenticate(reason);
}

export function isBiometricAvailable(): boolean {
  return Biometrics.isBiometricAvailable();
}
