class PrivacySettings {
  const PrivacySettings({this.locationSharingConsentGiven = false});

  /// falseの間は位置情報を送信しない。
  final bool locationSharingConsentGiven;

  PrivacySettings copyWith({bool? locationSharingConsentGiven}) {
    return PrivacySettings(
      locationSharingConsentGiven:
          locationSharingConsentGiven ?? this.locationSharingConsentGiven,
    );
  }
}
