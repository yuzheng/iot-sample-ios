# iot-sample-ios

> 提供 CHT IoT iOS 開放協定之程式碼

## Setup

### 使用 CocoaPods 工具

安裝 CocoaPods (需要 Ruby 環境，Mac default都有安裝)

```
 $ sudo gem install cocoapods
 $ pod setup
```
下載本專案，並解壓縮，並於該目錄底下透過終端機視窗，輸入底下指令

```
$ pod install
```

即可進行本專案第三方套件安裝設定。
套件包含：
- 'AFNetworking', '~> 2.6'
- 'BWJSONMatcher', '~> 1.1.0'
- 'CocoaAsyncSocket'
- 'MQTTClient'
- 'SWRevealViewController', '~> 2.1'
- 'QRCodeReaderViewController', '~> 4.0.2'
- 'JBChartView'

完成後，即可點選專案目錄底下 iotapp.xcworkspace 開啟 XCode 並進行開發

### 程式說明

#### CHT IoT Group

- OpenRESTfulClient: 負責處理IoT平台RESTful協定
- OpenMqttClient: 負責處理IoT平台MQTT協定

### CHT IoT App

- ViewController: APP 首頁
- MyDevicesViewController: 我的設備 
- EditDeviceViewController: 新增/編輯我的設備
- DeviceViewController: 設備感測器(顯示設備底下感測器列表與最新的感測數據, 使用OpenRESTfulClient與OpenMqttClient之應用)
- EditSensorViewController: 新增/編輯我的感測器
- SnapshotViewController: 快照功能服務
- RawdataViewController: 顯示歷史感測數據資料
- RegistryViewContoller: 設備納管服務
