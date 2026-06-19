/// Build flavor — selected by the entrypoint (`main_<flavor>.dart`) and the
/// matching Gradle product flavor. See docs/PLAN.md §7.
enum Flavor { dev, staging, prod }

/// Per-flavor runtime configuration. Injected at startup so the rest of the app
/// reads settings from here instead of branching on the flavor directly.
class AppConfig {
  const AppConfig({required this.flavor, required this.appName});

  final Flavor flavor;
  final String appName;

  bool get isProd => flavor == Flavor.prod;

  static const dev = AppConfig(flavor: Flavor.dev, appName: 'archivo Dev');
  static const staging = AppConfig(
    flavor: Flavor.staging,
    appName: 'archivo Staging',
  );
  static const prod = AppConfig(flavor: Flavor.prod, appName: 'archivo');
}
