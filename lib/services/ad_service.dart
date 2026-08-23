import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/constants.dart';
import 'dart:async';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  bool _initFailed = false;
  StreamSubscription? _connectivitySubscription;
  Timer? _periodicTimer;
  Timer? _kickoffTimer;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _interstitialLoading = false;
  bool _rewardedLoading = false;
  int _bannersInFlight = 0;

  // Preloaded banner ads, ready to be shown instantly when a screen needs
  // one. Kept SMALL on purpose: every banner ad is a WebView created on the
  // Android main thread. Loading several at once during launch froze
  // low-end devices whenever data was on — so we cap the cache at 2 and
  // load them one at a time, staggered.
  final List<BannerAd> _bannerCache = [];
  static const int _bannerCacheTarget = 2;

  /// First ad load happens this long after the app started — never during
  /// launch or the first navigation.
  static const Duration _firstLoadDelay = Duration(seconds: 15);

  /// Gap between individual ad loads so the ad SDK's main-thread work
  /// (WebView creation) never piles up.
  static const Duration _stagger = Duration(seconds: 4);

  bool get _interstitialReady => _interstitialAd != null;
  bool get _rewardedReady => _rewardedAd != null;
  int get cachedBannerCount => _bannerCache.length;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('[AdService] Initializing Google Mobile Ads');
    try {
      // Timeout: a wedged SDK init must never leave the app waiting.
      await MobileAds.instance.initialize().timeout(const Duration(seconds: 10));
      debugPrint('[AdService] Google Mobile Ads initialized');
    } catch (e) {
      // Ads are disabled for this session only — the app itself is unaffected.
      debugPrint('[AdService] Mobile Ads init failed - ads disabled this session: $e');
      _initFailed = true;
      return;
    }
    _listenConnectivity();
    _startPeriodicPreload();
    _scheduleLoads();
  }

  /// True when the device currently has a network connection. When unsure,
  /// assumes online so ads still try (a failed load just retries later).
  Future<bool> _hasConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      return true;
    }
  }

  /// Loads ads ONE AT A TIME, well after launch:
  /// interstitial -> (+4s) rewarded -> (+4s) banner cache top-up.
  void _scheduleLoads() {
    if (_initFailed) return;
    _kickoffTimer?.cancel();
    _kickoffTimer = Timer(_firstLoadDelay, () async {
      if (!await _hasConnection()) return; // reconnect listener re-kicks
      loadInterstitial();
      await Future<void>.delayed(_stagger);
      if (!await _hasConnection()) return;
      loadRewarded();
      await Future<void>.delayed(_stagger);
      if (await _hasConnection()) _topUpBannerCache();
    });
  }

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        debugPrint('[AdService] Network available - loading ads');
        _scheduleLoads();
      }
    });
  }

  void _startPeriodicPreload() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_initFailed) return;
      // All three are no-ops when the ad is already loaded or loading.
      loadInterstitial();
      loadRewarded();
      _topUpBannerCache();
    });
  }

  void onAppResume() {
    if (!_initFailed) {
      debugPrint('[AdService] App resumed - refreshing ad cache');
      _scheduleLoads();
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
    _kickoffTimer?.cancel();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    for (final ad in _bannerCache) {
      ad.dispose();
    }
    _bannerCache.clear();
  }

  void loadInterstitial() {
    // Guard: never start a second load while one is in flight or an ad is
    // already ready (prevents leaks and duplicate main-thread work).
    if (_initFailed || _interstitialReady || _interstitialLoading) return;
    _interstitialLoading = true;
    debugPrint('[AdService] Loading interstitial');
    InterstitialAd.load(
      adUnitId: AppConstants.admobInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          debugPrint('[AdService] Interstitial loaded');
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('[AdService] Interstitial dismissed');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[AdService] Interstitial show failed: $error');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          debugPrint('[AdService] Interstitial load failed: $error');
          _interstitialAd = null;
          Timer(const Duration(seconds: 10), () async {
            if (await _hasConnection()) loadInterstitial();
          });
        },
      ),
    );
  }

  void loadRewarded() {
    if (_initFailed || _rewardedReady || _rewardedLoading) return;
    _rewardedLoading = true;
    debugPrint('[AdService] Loading rewarded');
    RewardedAd.load(
      adUnitId: AppConstants.admobRewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoading = false;
          debugPrint('[AdService] Rewarded loaded');
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('[AdService] Rewarded dismissed');
              ad.dispose();
              _rewardedAd = null;
              loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[AdService] Rewarded show failed: $error');
              ad.dispose();
              _rewardedAd = null;
              loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          debugPrint('[AdService] Rewarded load failed: $error');
          _rewardedAd = null;
          Timer(const Duration(seconds: 10), () async {
            if (await _hasConnection()) loadRewarded();
          });
        },
      ),
    );
  }

  void showInterstitial({VoidCallback? onComplete}) {
    debugPrint('[AdService] showInterstitial called (ready: $_interstitialReady)');

    bool callbackFired = false;
    void fireCallback() {
      if (!callbackFired) {
        callbackFired = true;
        onComplete?.call();
      }
    }

    if (!_interstitialReady || _interstitialAd == null) {
      debugPrint('[AdService] Interstitial not ready - skipping');
      Future.microtask(() => fireCallback());
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        debugPrint('[AdService] Interstitial dismissed');
        a.dispose();
        loadInterstitial();
        fireCallback();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        debugPrint('[AdService] Interstitial show failed: $error');
        a.dispose();
        loadInterstitial();
        fireCallback();
      },
    );

    ad.show();
  }

  void showRewarded({VoidCallback? onRewarded, VoidCallback? onFailed}) {
    debugPrint('[AdService] showRewarded called (ready: $_rewardedReady)');

    bool callbackFired = false;
    void fireReward() {
      if (!callbackFired) {
        callbackFired = true;
        onRewarded?.call();
      }
    }

    void fireFail() {
      if (!callbackFired) {
        callbackFired = true;
        onFailed?.call();
      }
    }

    if (!_rewardedReady || _rewardedAd == null) {
      debugPrint('[AdService] Rewarded not ready - skipping');
      Future.microtask(() => fireFail());
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        debugPrint('[AdService] Rewarded dismissed');
        a.dispose();
        loadRewarded();
        fireFail();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        debugPrint('[AdService] Rewarded show failed: $error');
        a.dispose();
        loadRewarded();
        fireFail();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdService] Rewarded completed - granting reward');
        fireReward();
      },
    );
  }

  void preloadInterstitial() => loadInterstitial();
  void preloadRewarded() => loadRewarded();
  void preloadBanner() => _topUpBannerCache();

  /// Fills the banner cache up to the target size, loading one banner at a
  /// time. Safe to call any number of times.
  void _topUpBannerCache() {
    if (_initFailed) return;
    while (_bannerCache.length + _bannersInFlight < _bannerCacheTarget) {
      _bannersInFlight++;
      _loadOneBanner();
    }
  }

  void _loadOneBanner() {
    BannerAd(
      adUnitId: AppConstants.admobBannerUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (_bannersInFlight > 0) _bannersInFlight--;
          debugPrint('[AdService] Banner preloaded (cache ${_bannerCache.length + 1}/$_bannerCacheTarget)');
          _bannerCache.add(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          if (_bannersInFlight > 0) _bannersInFlight--;
          debugPrint('[AdService] Banner preload failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Hands a preloaded banner to a widget for display (or null if the cache is
  /// empty). The widget that calls this owns the returned ad and must dispose
  /// it, but the cache keeps top-ups flowing so a replacement is already being
  /// fetched in the background.
  BannerAd? takeBanner() {
    if (_bannerCache.isEmpty) return null;
    final ad = _bannerCache.removeLast();
    _topUpBannerCache();
    return ad;
  }
} 
