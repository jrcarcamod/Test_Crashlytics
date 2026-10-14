"""Guard the Xcode 27 scene lifecycle required to reach the Flutter screen."""
import pathlib
import plistlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]


class SceneConfigurationTest(unittest.TestCase):
    def test_scene_manifest_creates_flutter_main_scene(self):
        with (ROOT / "ios/Runner/Info.plist").open("rb") as source:
            info = plistlib.load(source)
        manifest = info.get("UIApplicationSceneManifest")
        self.assertIsNotNone(manifest, "iOS 27 refuses to launch without a scene manifest")
        self.assertFalse(manifest["UIApplicationSupportsMultipleScenes"])
        scenes = manifest["UISceneConfigurations"]["UIWindowSceneSessionRoleApplication"]
        self.assertEqual(len(scenes), 1)
        self.assertEqual(scenes[0]["UISceneClassName"], "UIWindowScene")
        self.assertEqual(scenes[0]["UISceneDelegateClassName"], "FlutterSceneDelegate")
        self.assertEqual(scenes[0]["UISceneStoryboardFile"], "Main")

    def test_plugins_use_the_scene_created_implicit_engine(self):
        delegate = (ROOT / "ios/Runner/AppDelegate.swift").read_text()
        self.assertIn("FlutterImplicitEngineDelegate", delegate)
        self.assertIn("didInitializeImplicitFlutterEngine", delegate)
        self.assertIn("GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)", delegate)
        self.assertNotIn("GeneratedPluginRegistrant.register(with: self)", delegate)


if __name__ == "__main__":
    unittest.main()
