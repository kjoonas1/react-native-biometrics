# @kjoonas1/react-native-biometrics

A simple, lightweight biometrics API for React Native apps **with zero dependencies**. Uses native BiometricPrompt (Android) and LocalAuthentication (iOS) directly.

This library requries that your app is using the **New React Native Architecture** and **TurboModules** enabled.


## Installation


```sh
npm install @kjoonas1/react-native-biometrics
```


## Usage


```js
import { authenticate, isBiometricAvailable, BiometricAuthStatus } from '@kjoonas1/react-native-biometrics';

const available = isBiometricAvailable();
if (available) {
    const result = await authenticate('reason for auth')
    if (result.status === BiometricAuthStatus.SUCCESS) {
        // ...
    }
    // ...
}
```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
