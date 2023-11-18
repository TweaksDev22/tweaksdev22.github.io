#!/bin/bash
VERSION=0.1
AUTHOR=vungoctrong@gmail.com

DATE=`date '+%Y-%m-%d_%H%M%S'`
#build xarchive file
xcodebuild -workspace $1.xcworkspace -scheme $1 -sdk iphoneos archive -archivePath $1.xcarchive

#build IPA file with development provisioning file
xcodebuild -exportArchive -archivePath $1*.xcarchive -exportPath tmp -exportOptionsPlist ExportOptions.plist

#re-generate IPA file
cd tmp
mv $1.ipa $1.zip
unzip -qo $1.zip
rm -rf $1.zip

#adding Swift support folder (copy from xarchive file to IPA)
cp -R ../$1*.xcarchive/SwiftSupport .
#replace Frameworks folder
rm -rf Payload/*.app/Frameworks/
cp -R ../$1*.xcarchive/Products/Applications/*.app/Frameworks Payload/*.app/

#remove arm64e
#refer https://developer.apple.com/documentation/xcode_release_notes/xcode_10_1_release_notes
for i in Payload/*.app/Frameworks/libswift*.dylib; do
    lipo ${i} -remove arm64e -output ${i}
done

#zipping
zip -qr $1.zip Payload SwiftSupport
mv $1.zip ../$1_${DATE}.ipa

cd ..
echo "IPA file @ `pwd`/$1_${DATE}.ipa"
rm -rf *.xcarchive
rm -rf tmp
echo "**IPA GENERATED**"
