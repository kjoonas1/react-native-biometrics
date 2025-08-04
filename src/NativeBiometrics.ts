import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export type BiometricAuthResult =
  | { status: 'SUCCESS' }
  | { status: 'FAILED_ATTEMPT'; message?: string }
  | { status: 'CANCELLED'; message?: string }
  | { status: 'LOCKOUT'; message?: string }
  | { status: 'DISABLED'; message?: string }
  | { status: 'ERROR'; message?: string };

interface Spec extends TurboModule {
  isBiometricAvailable(): boolean;
  authenticate(reason: string): Promise<BiometricAuthResult>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Biometrics');
