import 'dart:io';

const ACCESS_TOKEN_KEY = 'ACCESS TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

// localhost
// wifi ip는 주기적으로 변경된다.
final emulatorIp = '10.0.2.2:3000';
final simulatorIp = '127.0.0.1:3000';
final doitIp = '172.30.1.78:3000';
final homeIp = '192.168.25.37:3000';
final yuIP = '165.229.75.129:3000';

final androidIp = doitIp;
final ip = Platform.isIOS ? simulatorIp : androidIp;
