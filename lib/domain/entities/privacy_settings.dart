/// プライバシー関連の同意状態(仕様書セクション6 セキュリティ・プライバシー)。
class PrivacySettings {
  const PrivacySettings({this.locationSharingConsentGiven = false});

  /// 位置情報共有機能(仲間・家族への現在地送信)への同意状態。
  /// falseの間は、グループに参加していても現在地の送信は行わない。
  final bool locationSharingConsentGiven;

  PrivacySettings copyWith({bool? locationSharingConsentGiven}) {
    return PrivacySettings(
      locationSharingConsentGiven:
          locationSharingConsentGiven ?? this.locationSharingConsentGiven,
    );
  }
}
