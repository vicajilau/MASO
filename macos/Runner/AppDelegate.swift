import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let appPath = Bundle.main.bundlePath
        NSLog("La ubicación de la aplicación es: \(appPath)")
    }
    
    override func application(_ application: NSApplication, open urls: [URL]) {
        NSLog("🔍 macOS intentó abrir un archivo con open")
        for url in urls {
            NSLog("📂 Archivo recibido en open urls: \(url.path)")
            sendToFlutter(url.path)
        }
    }
    
    override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        NSLog("✅ Se llamó a openFile con: \(filename)")
        
        sendToFlutter(filename)
        
        return true
    }
    
    override func application(_ sender: NSApplication, openFiles filenames: [String]) {
        NSLog("🔍 macOS intentó abrir un archivo con openFiles")
        for url in filenames {
            sendToFlutter(url)
        }
    }
    
    override func application(_ sender: Any, openFileWithoutUI filename: String) -> Bool {
        NSLog("🔍 macOS intentó abrir un archivo con openFileWithoutUI")
        NSLog("📂 Archivo recibido en open urls: \(filename)")
        sendToFlutter(filename)
        return true
    }
    
    override func application(_ sender: NSApplication, openTempFile filename: String) -> Bool {
        NSLog("🔍 macOS intentó abrir un archivo con openTempFile")
        NSLog("📂 Archivo recibido en open urls: \(filename)")
        sendToFlutter(filename)
        return true
    }
    
    override func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        NSLog("🔍 macOS intentó abrir un archivo con applicationOpenUntitledFile")
        return true
    }
    
    override func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        NSLog("🔍 macOS intentó abrir un archivo con applicationShouldOpenUntitledFile")
        return true
    }
    
    func sendToFlutter(_ filename: String) {
        if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "maso.file", binaryMessenger: controller.engine.binaryMessenger)
            channel.invokeMethod("openFile", arguments: filename)
            NSLog("📢 Se envió el archivo a Flutter: \(filename)")
        } else {
            NSLog("❌ No se encontró el controlador de Flutter")
        }
    }
    
}
