import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

interface Spec extends TurboModule {
  isBiometricAvailable(): boolean;
  authenticate(reason: string): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Biometrics');
