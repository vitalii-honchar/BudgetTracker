---
description: Build and run the app on connected iPhone
---

First, find your device ID:
```bash
xcodebuild -scheme BudgetTracker -project BudgetTracker.xcodeproj -showdestinations | grep "platform:iOS, arch:arm64"
```

Then build and run on your device (replace YOUR_DEVICE_ID with the ID from above):
```bash
xcodebuild -scheme BudgetTracker -project BudgetTracker.xcodeproj -destination 'platform=iOS,id=YOUR_DEVICE_ID' build
```
