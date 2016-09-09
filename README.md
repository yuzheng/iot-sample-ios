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

完成後，即可點選專案目錄底下 iotapp.xcworkspace 開啟 XCode 並進行開發

### 程式說明

#### CHT IoT Group

Cloud Mode:

- OpenRESTfulClient: 負責處理IoT平台RESTful協定
- OpenMqttClient: 負責處理IoT平台MQTT協定

Local Mode:

- ControllerClient: 負責處理與設備間協定溝通
- ControllerClientBuilder: 負責處理監聽設備Broadcast的announcement資訊
- LocalModeProtocol: 負責處理Local mode各個協定package內容產生與資訊讀取

Test Code: 測試程式

- ViewController: 撰寫一測試使用 Local mode: ControllerClient與ControllerClinetBuilder, 及 Cloud mode: OpenMqttClient之應用案例

