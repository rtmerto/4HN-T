# 4Hn Story Glass

Theos source for a blue-tinted UIKit Liquid Glass effect on small TikTok controls whose class name or accessibility label/identifier identifies them as a story-add button.

- Builds against the latest iOS SDK. iOS 26 and later use `UIGlassEffect`; earlier iOS versions use a translucent blur fallback.
- The control lookup is heuristic because the supplied IPA does not include the tweak's source. If TikTok's story button has no accessible story/add identifier, update `H4NIsStoryAddControl` with the matching view class or accessibility identifier.
- Build with Theos, then inject the resulting tweak into the TikTok app bundle `com.zhiliaoapp.musically` and sign the IPA with your normal signing workflow.
