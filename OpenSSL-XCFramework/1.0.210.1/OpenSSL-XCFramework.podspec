Pod::Spec.new do |s|
  s.name            = "OpenSSL-XCFramework"
  s.version         = "1.0.210.1"
  s.description     = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in Mac OS and gone in iOS, this spec gives your project non-deprecated OpenSSL support.Fork from FredericJacobs's repo"
  s.summary         = "OpenSSL built into universal xcframework"
  s.author          = "OpenSSL Project <openssl-dev@openssl.org>"

  s.homepage        = "https://github.com/Mamong/OpenSSL-Pod"
  s.source          = { :http => "https://openssl.org/source/openssl-1.0.2j.tar.gz", :sha1 => "bdfbdb416942f666865fa48fe13c2d0e588df54f"}
  s.license         = { :type => 'OpenSSL (OpenSSL/SSLeay)', :file => 'LICENSE' }

  s.prepare_command = <<-CMD
    build() {
      export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
      export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
      echo "Building openssl-${VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
      echo "Please stand by..."
      export CC="${DEVELOPER}/usr/bin/gcc -arch ${ARCH} ${MIN_SDK_VERSION_FLAG}"
      echo "CC = ${CC}"
      mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
      LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"
      if [ "${PLATFORM}" == "iPhoneSimulator" ] ;
      then
        LIPO_LIBSSL_SIM="${LIPO_LIBSSL_SIM} ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/lib/libssl.a"
        LIPO_LIBCRYPTO_SIM="${LIPO_LIBCRYPTO_SIM} ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/lib/libcrypto.a"
      else
        LIPO_LIBSSL="${LIPO_LIBSSL} ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/lib/libssl.a"
        LIPO_LIBCRYPTO="${LIPO_LIBCRYPTO} ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/lib/libcrypto.a"
      fi
      ./Configure ${CONFIGURE_FOR} --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1
      sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} !" "Makefile"
      make >> "${LOG}" 2>&1
      make all install_sw >> "${LOG}" 2>&1
      make clean >> "${LOG}" 2>&1
    }
    VERSION="1.0.2j"
    SDKVERSION=`xcrun --sdk iphoneos --show-sdk-version 2> /dev/null`
    BASEPATH="${PWD}"
    CURRENTPATH="/tmp/openssl"
    #CURRENTPATH="${PWD}/tmp"
    SIM_ARCHS="i386 x86_64 arm64"
    ARCHS="armv7 armv7s arm64"
    DEVELOPER=`xcode-select -print-path`
    echo "creating dir ${CURRENTPATH}"
    rm -rf "${CURRENTPATH}"
    mkdir -p "${CURRENTPATH}"
    mkdir -p "${CURRENTPATH}/bin"
    cp -rf "${BASEPATH}/" "${CURRENTPATH}/openssl-${VERSION}"
    #cp "file.tgz" "${CURRENTPATH}/file.tgz"
    cd "${CURRENTPATH}"
    #tar -xzf file.tgz
    cd "openssl-${VERSION}"
    for ARCH in ${ARCHS}
    do
      CONFIGURE_FOR="iphoneos-cross"
      sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"
      PLATFORM="iPhoneOS"
      MIN_SDK_VERSION_FLAG="-miphoneos-version-min=7.0"
      build
    done
    for ARCH in ${SIM_ARCHS}
    do
      PLATFORM="iPhoneSimulator"
      if [ "${ARCH}" == "x86_64" ] ;
      then
        CONFIGURE_FOR="darwin64-x86_64-cc"
      else
        CONFIGURE_FOR="iphoneos-cross"
      fi
      MIN_SDK_VERSION_FLAG="-mios-simulator-version-min=7.0"
      build
    done
    echo "Build library..."
    echo "${LIPO_LIBSSL_SIM}"
    echo "${LIPO_LIBSSL}"
    mkdir -p "${CURRENTPATH}/lib/iPhoneSimulator/"
    mkdir -p "${CURRENTPATH}/lib/iPhoneOS"
    lipo -create ${LIPO_LIBSSL_SIM}     -output "${CURRENTPATH}/lib/iPhoneSimulator/libssl.a"
    lipo -create ${LIPO_LIBCRYPTO_SIM}  -output "${CURRENTPATH}/lib/iPhoneSimulator/libcrypto.a"
    lipo -create ${LIPO_LIBSSL}         -output "${CURRENTPATH}/lib/iPhoneOS/libssl.a"
    lipo -create ${LIPO_LIBCRYPTO}      -output "${CURRENTPATH}/lib/iPhoneOS/libcrypto.a"
    echo "Copying headers..."
    mkdir -p "${CURRENTPATH}/opensslIncludes/"
    cp -RL "${CURRENTPATH}/openssl-${VERSION}/include/openssl" "${CURRENTPATH}/opensslIncludes/"
    cd "${BASEPATH}"
    echo "Creating xcarchive"
    libtool -static -no_warning_for_no_symbols -o "${CURRENTPATH}/lib/iPhoneSimulator/libopenssl.a" "${CURRENTPATH}/lib/iPhoneSimulator/libcrypto.a" "${CURRENTPATH}/lib/iPhoneSimulator/libssl.a"
    libtool -static -no_warning_for_no_symbols -o "${CURRENTPATH}/lib/iPhoneOS/libopenssl.a" "${CURRENTPATH}/lib/iPhoneOS/libcrypto.a" "${CURRENTPATH}/lib/iPhoneOS/libssl.a"

    rm -rf "${BASEPATH}/OpenSSL.xcframework"
    xcodebuild -create-xcframework -library "${CURRENTPATH}/lib/iPhoneSimulator/libopenssl.a" -headers "${CURRENTPATH}/opensslIncludes/openssl/" -library "${CURRENTPATH}/lib/iPhoneOS/libopenssl.a" -headers "${CURRENTPATH}/opensslIncludes/openssl/" -output "${BASEPATH}/OpenSSL.xcframework"
    echo "Building done."
    echo "Cleaning up..."
    rm -rf "${CURRENTPATH}"
    echo "Done."
  CMD

  s.ios.deployment_target   = "10.0"
  s.vendored_frameworks = 'OpenSSL.xcframework'

  s.requires_arc          = false

end