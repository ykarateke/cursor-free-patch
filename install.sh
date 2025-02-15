#!/bin/bash

# Cursor uygulamasının kapalı olduğundan emin ol
echo "Cursor uygulamasını kapatın ve devam etmek için Enter'a basın..."
read

# Hedef dizinler
CURSOR_APP="/Applications/Cursor.app"
EXTENSIONS_DIR="$CURSOR_APP/Contents/Resources/app/extensions"
PRODUCT_JSON="$CURSOR_APP/Contents/Resources/app/product.json"
MAIN_JS="$CURSOR_APP/Contents/Resources/app/out/main.js"
SHARED_PROCESS="$CURSOR_APP/Contents/Resources/app/out/vs/code/electron-utility/sharedProcess/sharedProcessMain.js"
REQUEST_COUNTER="$CURSOR_APP/Contents/Resources/app/out/vs/platform/request/node/requestCounter.js"
REQUEST_SERVICE="$CURSOR_APP/Contents/Resources/app/out/vs/platform/request/common/requestService.js"
USER_SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
USER_PROFILES_DIR="$USER_SETTINGS_DIR/profiles"

# Yedekleme yap
echo "Yedekleme yapılıyor..."
cp -r "$EXTENSIONS_DIR/ms-vscode.js-debug" "$EXTENSIONS_DIR/ms-vscode.js-debug.bak"
cp -r "$EXTENSIONS_DIR/cursor-always-local" "$EXTENSIONS_DIR/cursor-always-local.bak"
cp "$PRODUCT_JSON" "$PRODUCT_JSON.bak"
cp "$MAIN_JS" "$MAIN_JS.bak"
cp "$SHARED_PROCESS" "$SHARED_PROCESS.bak"
[ -f "$REQUEST_COUNTER" ] && cp "$REQUEST_COUNTER" "$REQUEST_COUNTER.bak"
[ -f "$REQUEST_SERVICE" ] && cp "$REQUEST_SERVICE" "$REQUEST_SERVICE.bak"

# Patch dosyalarını kopyala
echo "Patch dosyaları kopyalanıyor..."
cp patch.js "$EXTENSIONS_DIR/ms-vscode.js-debug/src/"
cp patch.js "$EXTENSIONS_DIR/cursor-always-local/dist/"

# Tüm uzantılar için telemetri ve istek raporlamayı devre dışı bırak
echo "Uzantılar için telemetri ve istek raporlama devre dışı bırakılıyor..."
find "$EXTENSIONS_DIR" -type f -name "package.json" -exec sh -c '
  jq "
    .enableTelemetry = false |
    .telemetryLevel = 0 |
    .aiConfig = null |
    .experimentationService = null |
    .enabledExperiments = false |
    .requestCounter = null |
    .reportRequests = false |
    .requestTracking = null |
    .requestMetrics = null |
    .requestQuota = null |
    .isPro = true |
    .features = {
      \"pro\": true,
      \"enterprise\": true,
      \"unlimited\": true,
      \"noLimits\": true,
      \"noRequestLimits\": true,
      \"noRateLimiting\": true
    }
  " "{}" > "{}.tmp" && mv "{}.tmp" "{}"
' \;

# product.json dosyasını güncelle
echo "product.json güncelleniyor..."
jq '
  .maxConcurrentStreams = 9007199254740991 | 
  .maxActiveRequests = 9007199254740991 |
  .maxRequestsPerMinute = 9007199254740991 |
  .maxTokensPerMinute = 9007199254740991 |
  .maxParallelRequests = 9007199254740991 |
  .maxQueuedRequests = 9007199254740991 |
  .enableTelemetry = false |
  .removeTelemetryMachineId = true |
  .enabledTelemetryLevels.error = false |
  .enabledTelemetryLevels.usage = false |
  .enabledTelemetryLevels.crash = false |
  .reportRequestCounts = false |
  .reportApiUsage = false |
  .telemetryLevel = 0 |
  .enableCrashReporter = false |
  .enableTelemetryService = false |
  .enableCustomEndpointTelemetry = false |
  .enablePerformanceMetrics = false |
  .telemetryLoggers = [] |
  .requestTracking = {
    "enabled": false,
    "endpoint": null,
    "reportInterval": 0,
    "batchSize": 0,
    "maxRetries": 0,
    "timeout": 0
  } |
  .requestQuota = {
    "enabled": false,
    "limit": 9007199254740991,
    "remaining": 9007199254740991,
    "reset": 9007199254740991
  } |
  .aiConfig = {
    "ariaKey": null,
    "trackingId": null,
    "endpoint": null,
    "instrumentationKey": null
  } |
  .isPro = true |
  .isEnterprise = true |
  .hasUnlimitedAccess = true |
  .features = {
    "pro": true,
    "enterprise": true,
    "unlimited": true,
    "customModels": true,
    "priorityAccess": true,
    "teamFeatures": true,
    "advancedSecurity": true,
    "noRequestLimits": true,
    "noRateLimiting": true
  }
' "$PRODUCT_JSON" > "$PRODUCT_JSON.tmp"
mv "$PRODUCT_JSON.tmp" "$PRODUCT_JSON"

# İstek sayacını ve raporlama servislerini devre dışı bırak
echo "İstek sayacı ve raporlama servisleri devre dışı bırakılıyor..."
if [ -f "$REQUEST_COUNTER" ]; then
  cat > "$REQUEST_COUNTER" << 'EOL'
class RequestCounter {
  constructor() {}
  report() { return Promise.resolve(); }
  track() { return Promise.resolve(); }
  count() { return Promise.resolve(); }
  getCount() { return Promise.resolve(0); }
  reset() { return Promise.resolve(); }
  dispose() { return Promise.resolve(); }
  static getInstance() { return new RequestCounter(); }
}
module.exports = { RequestCounter };
EOL
fi

# Request servisini devre dışı bırak
if [ -f "$REQUEST_SERVICE" ]; then
  cat > "$REQUEST_SERVICE" << 'EOL'
class RequestService {
  constructor() {}
  report() { return Promise.resolve(); }
  track() { return Promise.resolve(); }
  count() { return Promise.resolve(); }
  getCount() { return Promise.resolve(0); }
  reset() { return Promise.resolve(); }
  dispose() { return Promise.resolve(); }
  static getInstance() { return new RequestService(); }
}
module.exports = { RequestService };
EOL
fi

# Tüm JS dosyalarında istek sayma ve raporlama fonksiyonlarını devre dışı bırak
echo "JS dosyaları güncelleniyor..."
find "$CURSOR_APP/Contents/Resources/app/out" -type f -name "*.js" -exec sed -i '' \
  -e 's/reportRequest(/void(/g' \
  -e 's/trackRequest(/void(/g' \
  -e 's/countRequest(/void(/g' \
  -e 's/getRequestCount(/getZeroCount(/g' \
  -e 's/incrementRequestCount(/void(/g' \
  -e 's/resetRequestCount(/void(/g' \
  -e 's/collectMetrics(/void(/g' \
  -e 's/reportMetrics(/void(/g' \
  -e 's/trackMetrics(/void(/g' \
  -e 's/isTrial()/false/g' \
  -e 's/isTrialExpired()/false/g' \
  -e 's/checkTrial()/void()/g' \
  -e 's/validateTrial()/void()/g' \
  -e 's/checkProStatus()/true/g' \
  -e 's/validateProStatus()/true/g' \
  -e 's/isProUser()/true/g' \
  -e 's/hasProAccess()/true/g' \
  -e 's/hasEnterpriseAccess()/true/g' \
  -e 's/checkRequestQuota(/void(/g' \
  -e 's/validateRequestQuota(/void(/g' \
  -e 's/hasRequestQuota(/trueQuota(/g' \
  -e 's/isRequestLimited(/falseLimit(/g' \
  -e 's/shouldThrottleRequest(/falseThrottle(/g' \
  {} \;

# Kullanıcı ayarları ve state dosyalarını güncelle
echo "Kullanıcı ayarları ve state dosyaları güncelleniyor..."

# settings.json dosyalarını güncelle
find "$USER_SETTINGS_DIR" -type f -name "settings.json" -exec sh -c '
  if [ -f "{}" ]; then
    jq "
      .\"telemetry.telemetryLevel\" = \"off\" |
      .\"telemetry.enableCrashReporter\" = false |
      .\"telemetry.enableTelemetry\" = false |
      .\"workbench.enableExperiments\" = false |
      .\"workbench.settings.enableExperiments\" = false |
      .\"update.mode\" = \"none\" |
      .\"update.enableWindowsBackgroundUpdates\" = false |
      .\"extensions.autoCheckUpdates\" = false |
      .\"extensions.autoUpdate\" = false |
      .\"pro.features.enabled\" = true |
      .\"enterprise.features.enabled\" = true |
      .\"request.counter.enabled\" = false |
      .\"request.tracking.enabled\" = false |
      .\"request.quota.enabled\" = false |
      .\"request.metrics.enabled\" = false
    " "{}" > "{}.tmp" && mv "{}.tmp" "{}"
  fi
' \;

# globalState.json ve state.json dosyalarını güncelle
find "$USER_SETTINGS_DIR" -type f \( -name "globalState.json" -o -name "state.json" \) -exec sh -c '
  if [ -f "{}" ]; then
    jq "
      .storage = (.storage + {
        \"workbench.telemetryEnabled\": false,
        \"workbench.enableCrashReporter\": false,
        \"workbench.enableExperiments\": false,
        \"pro.features.enabled\": true,
        \"enterprise.features.enabled\": true,
        \"request.counter.enabled\": false,
        \"request.tracking.enabled\": false,
        \"request.quota.enabled\": false,
        \"request.metrics.enabled\": false,
        \"subscription.type\": \"enterprise\",
        \"subscription.status\": \"active\",
        \"subscription.expiresAt\": \"2099-12-31T23:59:59.999Z\",
        \"subscription.features\": [\"unlimited\", \"priority\", \"custom\", \"team\", \"security\"]
      })
    " "{}" > "{}.tmp" && mv "{}.tmp" "{}"
  fi
' \;

# İzinleri düzelt
echo "İzinler düzenleniyor..."
chmod -R 644 "$PRODUCT_JSON"
find "$EXTENSIONS_DIR" -type f -exec chmod 644 {} \;
find "$EXTENSIONS_DIR" -type d -exec chmod 755 {} \;

echo "Kurulum tamamlandı. Cursor uygulamasını yeniden başlatın." 