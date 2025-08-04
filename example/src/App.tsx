import { Text, View, StyleSheet } from 'react-native';
import { authenticate, isBiometricAvailable } from 'react-native-biometrics';
const av = isBiometricAvailable();
const result = av ? authenticate('asd') : 'nope';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>Result: {av.toString()}</Text>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
