// Cursor Free Patch
// Bu patch dosyası istek limitlerini kaldırmak, telemetriyi ve istek raporlamayı devre dışı bırakmak için gerekli değişiklikleri içerir

const REQUEST_LIMIT = Number.MAX_SAFE_INTEGER; // Maksimum istek limiti
const THROTTLING_DISABLED = true; // Throttling devre dışı
const TELEMETRY_DISABLED = true; // Telemetri devre dışı
const TELEMETRY_LEVEL_NONE = 0; // Telemetri seviyesi: Hiçbiri
const PRO_FEATURES_ENABLED = true; // Pro özellikleri aktif

// Rate limiting ve throttling kontrollerini devre dışı bırak
function disableRateLimiting() {
  return {
    isRateLimited: () => false,
    shouldThrottle: () => false,
    getRequestsRemaining: () => REQUEST_LIMIT,
    hasRequestQuota: () => true,
    checkRequestQuota: () => true,
    reportRequest: () => Promise.resolve(),
    trackRequest: () => Promise.resolve(),
    countRequest: () => Promise.resolve(),
    requestCounter: null,
    requestTracking: null,
    requestMetrics: null,
    requestQuota: {
      limit: REQUEST_LIMIT,
      remaining: REQUEST_LIMIT,
      reset: Number.MAX_SAFE_INTEGER
    }
  };
}

// Stream limitlerini kaldır ve pro özellikleri etkinleştir
function removeConcurrentLimits() {
  return {
    maxConcurrentStreams: REQUEST_LIMIT,
    maxActiveRequests: REQUEST_LIMIT,
    maxRequestsPerMinute: REQUEST_LIMIT,
    maxTokensPerMinute: REQUEST_LIMIT,
    maxParallelRequests: REQUEST_LIMIT,
    maxQueuedRequests: REQUEST_LIMIT,
    isPro: true,
    isEnterprise: true,
    hasUnlimitedAccess: true,
    features: {
      unlimitedRequests: true,
      proFeatures: true,
      enterpriseFeatures: true,
      customModels: true,
      priorityAccess: true,
      noRequestLimits: true,
      noRateLimiting: true
    }
  };
}

// Telemetri ve istek sayılarını raporlamayı devre dışı bırak
function disableTelemetry() {
  return {
    enableTelemetry: false,
    removeTelemetryMachineId: true,
    enabledTelemetryLevels: {
      error: false,
      usage: false,
      crash: false
    },
    reportRequestCounts: false,
    reportApiUsage: false,
    telemetryLevel: TELEMETRY_LEVEL_NONE,
    enableCrashReporter: false,
    enableTelemetryService: false,
    enableCustomEndpointTelemetry: false,
    enablePerformanceMetrics: false,
    telemetryLoggers: [],
    requestTracking: {
      enabled: false,
      endpoint: null,
      reportInterval: 0,
      batchSize: 0,
      maxRetries: 0,
      timeout: 0
    },
    aiConfig: {
      ariaKey: null,
      trackingId: null,
      endpoint: null,
      instrumentationKey: null
    }
  };
}

// Uzantılar için telemetri yapılandırmasını devre dışı bırak ve pro özellikleri etkinleştir
function disableExtensionTelemetry() {
  return {
    enableTelemetry: false,
    telemetryLevel: TELEMETRY_LEVEL_NONE,
    aiConfig: null,
    enabledExperiments: false,
    experimentationService: null,
    requestCounter: null,
    usageReporter: null,
    metricsService: null,
    isPro: true,
    features: {
      pro: true,
      enterprise: true,
      unlimited: true,
      noLimits: true
    }
  };
}

// Pro sürüm özelliklerini etkinleştir
function enableProFeatures() {
  return {
    isPro: true,
    isEnterprise: true,
    hasUnlimitedAccess: true,
    proToken: true,
    enterpriseToken: true,
    trialEnded: false,
    features: {
      unlimitedRequests: true,
      priorityAccess: true,
      customModels: true,
      teamFeatures: true,
      advancedSecurity: true,
      customization: true,
      experimentalFeatures: true,
      noRequestLimits: true,
      noRateLimiting: true
    },
    limits: {
      requests: REQUEST_LIMIT,
      tokens: REQUEST_LIMIT,
      storage: REQUEST_LIMIT,
      teamSize: REQUEST_LIMIT,
      concurrent: REQUEST_LIMIT,
      queue: REQUEST_LIMIT
    },
    subscription: {
      type: "enterprise",
      status: "active",
      expiresAt: "2099-12-31T23:59:59.999Z",
      features: ["unlimited", "priority", "custom", "team", "security"]
    }
  };
}

// İstek sayma ve raporlama fonksiyonlarını devre dışı bırak
function disableRequestCounting() {
  return {
    requestCounter: null,
    reportRequest: () => Promise.resolve(),
    trackRequest: () => Promise.resolve(),
    countRequest: () => Promise.resolve(),
    requestTracking: {
      enabled: false,
      endpoint: null,
      reportInterval: 0,
      batchSize: 0,
      maxRetries: 0,
      timeout: 0
    },
    metrics: {
      enabled: false,
      collectPerformance: false,
      collectUsage: false,
      endpoint: null,
      reportInterval: 0
    },
    quota: {
      enabled: false,
      limit: REQUEST_LIMIT,
      remaining: REQUEST_LIMIT,
      reset: Number.MAX_SAFE_INTEGER
    }
  };
}

module.exports = {
  REQUEST_LIMIT,
  THROTTLING_DISABLED,
  TELEMETRY_DISABLED,
  TELEMETRY_LEVEL_NONE,
  PRO_FEATURES_ENABLED,
  disableRateLimiting,
  removeConcurrentLimits,
  disableTelemetry,
  disableExtensionTelemetry,
  enableProFeatures,
  disableRequestCounting
}; 