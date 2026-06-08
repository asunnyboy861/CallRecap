# Pricing Configuration

## Monetization Model: Subscription (IAP) + Lifetime Purchase

## Subscription Group
- **Group Name**: CallRecap Premium
- **Group ID**: CallRecap_Premium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: CallRecap Monthly
- **Product ID**: `com.zzoutuo.CallRecap.monthly`
- **Price**: $3.99 per month
- **Display Name**: CallRecap Pro Monthly
- **Description**: Unlimited AI transcription & summaries
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: CallRecap Yearly
- **Product ID**: `com.zzoutuo.CallRecap.yearly`
- **Price**: $29.99 per year (37% savings vs monthly)
- **Display Name**: CallRecap Pro Yearly
- **Description**: Best value — unlimited AI features
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: CallRecap Lifetime
- **Product ID**: `com.zzoutuo.CallRecap.lifetime`
- **Price**: $79.99 one-time
- **Display Name**: CallRecap Pro Lifetime
- **Description**: Pay once, own forever
- **Note**: No ongoing API costs (on-device Whisper + Apple Intelligence). One-time purchase is viable.

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial on Yearly subscription (auto-converts to paid)
- **Monthly**: No free trial
- **Lifetime**: No free trial

## Free Tier Features
- Unlimited call recording
- Recording playback and management
- 5 transcriptions per month (on-device Whisper)
- Recording search
- iCloud sync
- Recycle bin (30-day retention)

## Premium Features (Subscription/Lifetime)
- Unlimited AI transcription (on-device Whisper)
- AI smart summaries (Apple Intelligence / local rules)
- Action item extraction + Add to Reminders
- Speaker diarization
- Export as PDF / SRT / TXT
- Face ID / Touch ID lock
- Priority support

## BYO Key Model: OpenAI API (Optional Enhancement)

### For iOS 17 Users (No Apple Intelligence)
- Users can optionally provide their own OpenAI API key for enhanced AI summaries
- The local rules engine provides basic summaries without any API key
- OpenAI BYO key is NOT required for app functionality

### Key Principle
- AI transcription (Whisper) is always on-device — no API key needed
- AI summary uses Apple Intelligence (iOS 18+) or local rules (iOS 17) — no API key needed
- OpenAI BYO key is purely optional enhancement for better summaries on iOS 17
- Subscription unlocks APP features (unlimited transcription, export, etc.) — NOT AI usage

## Policy Pages Required
- Support Page: YES (Must include subscription management info)
- Privacy Policy: YES
- Terms of Use: YES (REQUIRED for subscription apps)
- **Total Policy Pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms
- [x] Cancellation instructions included
- [x] Pricing clearly stated
- [x] Free trial terms included (7-day on yearly)
- [x] Restore purchases functionality implemented
- [x] Privacy Policy link in Paywall
- [x] Terms of Use link in Paywall
- [x] No dark patterns or deceptive pricing

## Competitive Pricing Comparison

| App | Annual Cost | CallRecap Savings |
|-----|------------|-------------------|
| TapeACall | $571.48 | 95% cheaper |
| Cube ACR | $119.88 | 75% cheaper |
| Otter.ai | $203.88 | 85% cheaper |
| Rev Call Recorder | ~$150 (transcription) | 80% cheaper |
| **CallRecap** | **$29.99** | **Baseline** |
