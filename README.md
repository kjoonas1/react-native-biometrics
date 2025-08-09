# @kjoonas1/react-native-biometrics
![Build Status](https://github.com/kjoonas1/react-native-biometrics/actions/workflows/ci.yml/badge.svg)

A simple, lightweight biometrics API for React Native apps **with zero runtime dependencies**. Uses native BiometricPrompt (Android) and LocalAuthentication (iOS) directly.

This library requries that your app is using the **New React Native Architecture** and **TurboModules** enabled.

## Installation

```sh
npm install @kjoonas1/react-native-biometrics
```

## Usage

### iOS Permissions
Add the following key to your Info.plist to allow Face ID authentication on iOS:

```xml
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID to authenticate you.</string>
```

### Example

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
