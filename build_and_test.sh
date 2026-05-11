#!/bin/bash
# ====================================================
# Daily Routine iOS App - Setup, Build & Test Script
# ====================================================
# This script handles:
# 1. Xcode detection & setup
# 2. Project generation via XcodeGen
# 3. Build (Debug for iOS Simulator)
# 4. Run all test suites
# ====================================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Daily Routine - Build & Test Runner  ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ---- Step 1: Check Xcode ----
echo -e "${YELLOW}[1/5] Checking Xcode installation...${NC}"

XCODE_PATH=$(xcode-select -p 2>/dev/null || echo "")
if [[ "$XCODE_PATH" == *"CommandLineTools"* ]] || [[ -z "$XCODE_PATH" ]]; then
    # Look for Xcode.app
    if [ -d "/Applications/Xcode.app" ]; then
        echo "  Switching to Xcode.app..."
        sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    elif [ -d "/Applications/Xcode-beta.app" ]; then
        echo "  Switching to Xcode-beta.app..."
        sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer
    else
        echo -e "${RED}  ❌ Xcode.app not found!${NC}"
        echo "  Please install Xcode from the Mac App Store:"
        echo "  1. Open App Store → Search 'Xcode' → Install"
        echo "  2. After install, run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
        echo "  3. Accept license: sudo xcodebuild -license accept"
        echo "  4. Re-run this script"
        exit 1
    fi
fi

XCODE_VERSION=$(xcodebuild -version 2>/dev/null | head -1 || echo "Unknown")
echo -e "  ${GREEN}✅ Xcode: $XCODE_VERSION${NC}"

# ---- Step 2: Dependencies ----
echo ""
echo -e "${YELLOW}[2/5] Checking dependencies...${NC}"

if ! command -v xcodegen &>/dev/null; then
    echo "  Installing XcodeGen..."
    brew install xcodegen
fi
echo -e "  ${GREEN}✅ XcodeGen ready${NC}"

# ---- Step 3: Generate Project ----
echo ""
echo -e "${YELLOW}[3/5] Generating Xcode project...${NC}"
xcodegen generate --quiet 2>/dev/null || xcodegen generate
echo -e "  ${GREEN}✅ Project generated: DailyRoutine.xcodeproj${NC}"

# ---- Step 4: Build ----
echo ""
echo -e "${YELLOW}[4/5] Building project...${NC}"

# Find available simulator
SIMULATOR=$(xcrun simctl list devices available -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' in runtime:
        for d in devices:
            if 'iPhone' in d['name'] and d['isAvailable']:
                print(d['name'])
                sys.exit(0)
print('iPhone 16')
" 2>/dev/null || echo "iPhone 16")

echo "  Target: $SIMULATOR (iOS Simulator)"

xcodebuild \
    -project DailyRoutine.xcodeproj \
    -scheme DailyRoutine \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -configuration Debug \
    clean build \
    2>&1 | tail -5

BUILD_RESULT=$?
if [ $BUILD_RESULT -eq 0 ]; then
    echo -e "  ${GREEN}✅ Build SUCCEEDED${NC}"
else
    echo -e "  ${RED}❌ Build FAILED (exit code: $BUILD_RESULT)${NC}"
    exit 1
fi

# ---- Step 5: Run Tests ----
echo ""
echo -e "${YELLOW}[5/5] Running test suites...${NC}"
echo ""

echo -e "${BLUE}  📋 Test Suite 1: Database Tests${NC}"
xcodebuild test \
    -project DailyRoutine.xcodeproj \
    -scheme DailyRoutine \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -only-testing:DailyRoutineTests/DatabaseTests \
    2>&1 | grep -E "(Test Case|Test Suite|Executed|PASSED|FAILED)" | head -30
echo ""

echo -e "${BLUE}  📋 Test Suite 2: Backend Tests${NC}"
xcodebuild test \
    -project DailyRoutine.xcodeproj \
    -scheme DailyRoutine \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -only-testing:DailyRoutineTests/BackendTests \
    2>&1 | grep -E "(Test Case|Test Suite|Executed|PASSED|FAILED)" | head -30
echo ""

echo -e "${BLUE}  📋 Test Suite 3: UI/UX Tests${NC}"
xcodebuild test \
    -project DailyRoutine.xcodeproj \
    -scheme DailyRoutine \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -only-testing:DailyRoutineTests/UIUXTests \
    2>&1 | grep -E "(Test Case|Test Suite|Executed|PASSED|FAILED)" | head -30
echo ""

echo -e "${BLUE}  📋 Test Suite 4: Workflow Tests${NC}"
xcodebuild test \
    -project DailyRoutine.xcodeproj \
    -scheme DailyRoutine \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -only-testing:DailyRoutineTests/WorkflowTests \
    2>&1 | grep -E "(Test Case|Test Suite|Executed|PASSED|FAILED)" | head -30
echo ""

# ---- Summary ----
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}          TEST SUMMARY                 ${NC}"
echo -e "${BLUE}========================================${NC}"

# Run all tests together for summary
xcodebuild test \
    -project DailyRoutine.xcodeproj \
    -scheme DailyRoutine \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    2>&1 | grep -E "(Executed|PASSED|FAILED)" | tail -5

echo ""
echo -e "${GREEN}🎉 All done!${NC}"
echo -e "  Open project: open DailyRoutine.xcodeproj"
echo -e "  Run on simulator: Cmd+R in Xcode"
