include(InstallerBase.pri);
mkpath( $$PWD/../Distro)
win32:OUT_FILE = HanoiTowerInstaller.exe
unix:OUT_FILE = HanoiTowerInstaller.run

IGNORE_ENV=$$PWD/../Distro/,$$PWD/../deployTests,$$PWD/packages/HanoiTower/data/
BASE_DEPLOY_FLAGS = clear -qmake $$QMAKE_BIN -libDir $$PWD/../ -recursiveDepth 5 -ignoreEnv $$IGNORE_ENV -targetDir $$PWD/packages/HanoiTowers/data

ANDROID_BUILD_DIR = $$PWD/../android-build
QML_DIR = $$PWD/../hanoi_towers/
DEPLOY_TARGET = $$PWD/../hanoi_towers/build/release


deploy_dep.commands += $$DEPLOYER -bin $$DEPLOY_TARGET -qmlDir $$QML_DIR $$BASE_DEPLOY_FLAGS
install_dep.commands = make INSTALL_ROOT=$$ANDROID_BUILD_DIR install


mkpath( $$PWD/../Distro)

win32:CONFIG_FILE = $$PWD/config/configWin.xml
unix:CONFIG_FILE = $$PWD/config/configLinux.xml


deploy_dep.commands += $$DEPLOYER -bin $$DEPLOY_TARGET -qmlDir $$QML_DIR $$BASE_DEPLOY_FLAGS

install_dep.commands = make INSTALL_ROOT=$$ANDROID_BUILD_DIR install


deploy.commands = $$EXEC \
                       -c $$CONFIG_FILE \
                       -p $$PWD/packages \
                       $$PWD/../Distro/$$OUT_FILE

deploy.depends = deploy_dep

win32:ONLINE_REPO_DIR = $$ONLINE/HanoiTowers/Windows
unix:ONLINE_REPO_DIR = $$ONLINE/HanoiTowers/Linux

create_repo.commands = $$REPOGEN \
                        --update-new-components \
                        -p $$PWD/packages \
                        $$ONLINE_REPO_DIR

message( ONLINE_REPO_DIR $$ONLINE_REPO_DIR)
!isEmpty( ONLINE ) {

    message(online)

    release.depends = create_repo

    deploy.commands = $$EXEC \
                           --online-only \
                           -c $$CONFIG_FILE \
                           -p $$PWD/packages \
                           $$PWD/../Distro/$$OUT_FILE
}

android {

    INPUT_ANDROID = --input $$PWD/../hanoi_towers/android-libHanoiTowers.so-deployment-settings.json
    OUTPUT_ANDROID = --output $$ANDROID_BUILD_DIR
    JDK = --jdk /usr
    GRADLE = --gradle

    !isEmpty( SIGN_PATH ): !isEmpty( SIGN_STORE_PASSWORD ) {
        SIGN_PATH = $$dirname(SIGN_PATH)/DigitalFaceMobily.keystore

        SIGN_VALUE = --sign '$$SIGN_PATH'

        !isEmpty( SIGN_ALIES ): {
            SIGN_VALUE += $$SIGN_ALIES
        }

        SIGN = $$SIGN_VALUE  --storepass '$$SIGN_STORE_PASSWORD' --release
        !isEmpty( SIGN_STORE_PASSWORD ): {
            SIGN += --keypass '$$SIGN_PASSWORD'
        }
    }

    deploy_dep.commands = $$DEPLOYER $$INPUT_ANDROID $$OUTPUT_ANDROID $$JDK $$GRADLE $$SIGN
    deploy_dep.depends = install_dep

    deploy.commands = cp $$ANDROID_BUILD_DIR/build/outputs/apk/* $$PWD/../Distro
}

releaseSnap.commands = rm *.snap -rdf && chmod 777 -R $$PWD/../prime && snapcraft && snapcraft push *.snap # bad patern
buildSnap.commands = snapcraft
clearSnap.commands = rm parts prime stage *.snap -rdf

unix:!android:release.depends += clearSnap
unix:!android:release.depends += buildSnap
unix:!android:release.depends += releaseSnap

OTHER_FILES += \
    $$PWD/config/*.xml \
    $$PWD/config/*.js \
    $$PWD/config/*.ts \
    $$PWD/config/*.css \
    $$PWD/packages/Installer/meta/* \
    $$PWD/packages/Installer/data/app.check \
    $$PWD/packages/HanoiTowers/meta/* \


QMAKE_EXTRA_TARGETS += \
    deploy_dep \
    install_dep \
    deploy \
    create_repo \
    release \
    clearSnap \
    releaseSnap \
    buildSnap \
    chmodSnap
