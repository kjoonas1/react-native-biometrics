# @kjoonas1/react-native-biometrics

Simple biometrics library

## Installation


```sh
npm install @kjoonas1/react-native-biometrics
```


## Usage


```js
import { authenticate, isBiometricAvailable } from '@kjoonas1/react-native-biometrics';

const available = isBiometricAvailable();
if (available) {
    const authenticated = await authenticate('reason for auth')
    // ...
}
```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
