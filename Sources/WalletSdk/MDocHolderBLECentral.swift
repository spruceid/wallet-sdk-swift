import CoreBluetooth
import Foundation

enum CharacteristicsError: Error {
    case missingMandatoryCharacteristic(name: String)
    case missingMandatoryProperty(name: String, characteristicName: String)
}

enum DataError: Error {
    case noData(characteristic: CBUUID)
    case invalidStateLength
    case unknownState(byte: UInt8)
    case unknownCharacteristic(uuid: CBUUID)
    case unknownDataTransferPrefix(byte: UInt8)
}

class MDocHolderBLECentral: NSObject {
    var centralManager: CBCentralManager!
    var serviceUuid: CBUUID
    var callback: MDocBLEDelegate
    var peripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?

    var incomingMessageBuffer = Data()

    init(callback: MDocBLEDelegate, serviceUuid: CBUUID) {
        self.serviceUuid = serviceUuid
        self.callback = callback
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        centralManager.scanForPeripherals(withServices: [serviceUuid])
    }

    func disconnectFromDevice () {
        centralManager.cancelPeripheralConnection(peripheral!)
    }

    func writeOutgoingValue(data: Data) {
        peripheral?.writeValue(_: data, for: writeCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
    }

    func processCharacteristics(peripheral: CBPeripheral, characteristics: [CBCharacteristic]) throws {
        if let characteristic = characteristics.first(where: {$0.uuid == readerStateCharacteristicId}) {
            if !characteristic.properties.contains(CBCharacteristicProperties.notify) {
                throw CharacteristicsError.missingMandatoryProperty(name: "notify", characteristicName: "State")
            }
            if !characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                throw CharacteristicsError.missingMandatoryProperty(
                    name: "write without response",
                    characteristicName: "State"
                )
            }
        } else {
            throw CharacteristicsError.missingMandatoryCharacteristic(name: "State")
        }

        if let characteristic = characteristics.first(where: {$0.uuid == readerClient2ServerCharacteristicId}) {
            if !characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                throw CharacteristicsError.missingMandatoryProperty(
                    name: "write without response",
                    characteristicName: "Client2Server"
                )
            }
            self.writeCharacteristic = characteristic
        } else {
            throw CharacteristicsError.missingMandatoryCharacteristic(name: "Client2Server")
        }

        if let characteristic = characteristics.first(where: {$0.uuid == readerServer2ClientCharacteristicId}) {
            if !characteristic.properties.contains(CBCharacteristicProperties.notify) {
                throw CharacteristicsError.missingMandatoryProperty(name: "notify", characteristicName: "Server2Client")
            }
        } else {
            throw CharacteristicsError.missingMandatoryCharacteristic(name: "Server2Client")
        }

        if let characteristic = characteristics.first(where: {$0.uuid == readerIdentCharacteristicId}) {
            if !characteristic.properties.contains(CBCharacteristicProperties.read) {
                throw CharacteristicsError.missingMandatoryProperty(name: "read", characteristicName: "Ident")
            }
            peripheral.readValue(for: characteristic)
        } else {
            throw CharacteristicsError.missingMandatoryCharacteristic(name: "Ident")
        }

        if let characteristic = characteristics.first(where: {$0.uuid == readerL2CAPCharacteristicId}) {
            if !characteristic.properties.contains(CBCharacteristicProperties.read) {
                throw CharacteristicsError.missingMandatoryProperty(name: "read", characteristicName: "L2CAP")
            }
        }
    }

    func processData(peripheral: CBPeripheral, characteristic: CBCharacteristic) throws {
        if var data = characteristic.value {
            switch characteristic.uuid {
            case readerStateCharacteristicId:
                if data.count != 1 {
                    throw DataError.invalidStateLength
                }
                switch data[0] {
                case 0x02:
                    self.disconnectFromDevice()
                case let byte:
                    throw DataError.unknownState(byte: byte)
                }
            case readerServer2ClientCharacteristicId:
                let firstByte = data.popFirst()
                incomingMessageBuffer.append(data)
                switch firstByte {
                case .none:
                    throw DataError.noData(characteristic: characteristic.uuid)
                case 0x00: // end
                    self.callback.callback(message: MDocBLECallback.message(incomingMessageBuffer))
                    self.incomingMessageBuffer = Data()
                    return
                case 0x01: // partial
                    // TODO check length against MTU
                    return
                case let .some(byte):
                    throw DataError.unknownDataTransferPrefix(byte: byte)
                }
            case readerIdentCharacteristicId:
                return
            case readerL2CAPCharacteristicId:
                return
            case let uuid:
                throw DataError.unknownCharacteristic(uuid: uuid)
            }
        } else {
            throw DataError.noData(characteristic: characteristic.uuid)
        }
    }
}

extension MDocHolderBLECentral: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            if #available(iOS 13.1, *) {
                switch CBManager.authorization {
                case .denied:
                    print("Authorization denied")
                case .restricted:
                    print("Authorization restricted")
                case .allowedAlways:
                    print("Authorized")
                case .notDetermined:
                    print("Authorization not determined")
                @unknown default:
                    print("Unknown authorization error")
                }
            } else {
                switch central.authorization {
                case .denied:
                    print("Authorization denied")
                case .restricted:
                    print("Authorization restricted")
                case .allowedAlways:
                    print("Authorized")
                case .notDetermined:
                    print("Authorization not determined")
                @unknown default:
                    print("Unknown authorization error")
                }
            }
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
    }
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        peripheral.delegate = self
        self.peripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager?.stopScan()
        peripheral.discoverServices([self.serviceUuid])
    }
}

extension MDocHolderBLECentral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error) != nil {
            self.callback.callback(
                message: MDocBLECallback.error("Error discovering services: \(error!.localizedDescription)")
            )
            return
        }
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error) != nil {
            self.callback.callback(
                message: MDocBLECallback.error("Error discovering characteristics: \(error!.localizedDescription)")
            )
            return
        }
        if let characteristics = service.characteristics {
            do {
                try self.processCharacteristics(peripheral: peripheral, characteristics: characteristics)
            } catch {
                self.callback.callback(message: MDocBLECallback.error("\(error)"))
                centralManager?.cancelPeripheralConnection(peripheral)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        do {
            try self.processData(peripheral: peripheral, characteristic: characteristic)
        } catch {
            self.callback.callback(message: MDocBLECallback.error("\(error)"))
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
}

extension MDocHolderBLECentral: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Is Powered On.")
        case .unsupported:
            print("Peripheral Is Unsupported.")
        case .unauthorized:
            print("Peripheral Is Unauthorized.")
        case .unknown:
            print("Peripheral Unknown")
        case .resetting:
            print("Peripheral Resetting")
        case .poweredOff:
            print("Peripheral Is Powered Off.")
        @unknown default:
            print("Error")
        }
    }
}
