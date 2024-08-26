import Flutter
import UIKit
import SwiftAvroCore

public class FlutterAvroPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_avro", binaryMessenger: registrar.messenger())
    let instance = FlutterAvroPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
       if let args = call.arguments as? Dictionary<String, Any> {
        switch call.method {
          case "decode":
            let schema = args["schema"] as! String
            let data = args["data"] as! String

            let decoded = decode(schema: schema, data: Data(base64Encoded: data.data(using: .utf8)!)!)
            
            result(decoded)
          default:
            result(FlutterMethodNotImplemented)
        }
      } else {
        result(FlutterError(code: "noargs", message: "bad args", details: nil))
      }
    } catch let error {
      result(FlutterError(code: "unknown", message: error.localizedDescription, details: nil))
    }
   
    
  }

  public func decode(schema: String, data: Data) -> Any {
    let avro = Avro()
    try! avro.decodeSchema(schema: schema)
    return try! avro.decode(from: data)
  }
}
