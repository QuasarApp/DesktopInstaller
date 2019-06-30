include(InstallerBase.pri);
mkpath( $$PWD/../Distro)
win32:OUT_FILE = SnakeInstaller.exe
unix:OUT_FILE = SnakeInstaller.run

INSTALL_SERVER_DIR = ~/SnakeServer

IGNORE_ENV=$$PWD/../Distro/,$$PWD/../deployTests,$$PWD/packages/Snake/data/
BASE_DEPLOY_FLAGS = clear -qmake $$QMAKE_BIN -libDir $$PWD/../ -recursiveDepth 5 -ignoreEnv $$IGNORE_ENV
BASE_DEPLOY_FLAGS_SERVER = $$BASE_DEPLOY_FLAGS -targetDir $$INSTALL_SERVER_DIR
BASE_DEPLOY_FLAGS_SNAKE = $$BASE_DEPLOY_FLAGS -targetDir $$PWD/packages/Snake/data
ANDROID_BUILD_DIR = $$PWD/../android-build
QML_DIR = $$PWD/../Snake/
DEPLOY_TARGET = $$PWD/../Snake/build/release
DEPLOY_SERVER = $$PWD/../SnakeServer/Daemon/build/release,$$PWD/../SnakeServer/Terminal/build/release

deploy_dep.commands += $$DEPLOYER -bin $$DEPLOY_TARGET -qmlDir $$QML_DIR $$BASE_DEPLOY_FLAGS_SNAKE
install_dep.commands = make INSTALL_ROOT=$$ANDROID_BUILD_DIR install


mkpath( $$PWD/../Distro)

win32:CONFIG_FILE = $$PWD/config/configWin.xml
unix:CONFIG_FILE = $$PWD/config/configLinux.xml


deploy_dep.commands += $$DEPLOYER -bin $$DEPLOY_TARGET -qmlDir $$QML_DIR $$BASE_DEPLOY_FLAGS_SNAKE

install_dep.commands = make INSTALL_ROOT=$$ANDROID_BUILD_DIR install


deploy.commands = $$EXEC \
                       -c $$CONFIG_FILE \
                       -p $$PWD/packages \
                       $$PWD/../Distro/$$OUT_FILE

deploy.depends = deploy_dep

win32:ONLINE_REPO_DIR = $$ONLINE/Snake/Windows
unix:ONLINE_REPO_DIR = $$ONLINE/Snake/Linux

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

    INPUT_ANDROID = --input $$PWD/../Snake/android-libsnake.so-deployment-settings.json
    OUTPUT_ANDROID = --output $$ANDROID_BUILD_DIR
    JDK = --jdk /usr
    GRADLE = --gradle

    !isEmpty( SIGN_PATH ): !isEmpty( SIGN_PASSWORD ): !isEmpty( SIGN_STORE_PASSWORD ) {
        SIGN = --sign $$SIGN_PATH --storepass $$SIGN_STORE_PASSWORD --keypass $$SIGN_PASSWORD --release
    }

    deploy_dep.commands = $$DEPLOYER $$INPUT_ANDROID $$OUTPUT_ANDROID $$JDK $$GRADLE $$SIGN
    deploy_dep.depends = install_dep

    deploy.commands = cp $$ANDROID_BUILD_DIR/build/outputs/apk/* $$PWD/../Distro
}

OTHER_FILES += \
    $$PWD/config/*.xml \
    $$PWD/config/*.js \
    $$PWD/config/*.ts \
    $$PWD/config/*.css \
    $$PWD/packages/Installer/meta/* \
    $$PWD/packages/Installer/data/app.check \
    $$PWD/packages/Snake/meta/* \

installSnake.commands = $$DEPLOYER -bin $$DEPLOY_SERVER $$BASE_DEPLOY_FLAGS_SERVER

createLinks.commands = ln -sf $$INSTALL_SERVER_DIR/Terminal.sh ~/.local/bin/snake-term && \
                       ln -sf $$INSTALL_SERVER_DIR/SnakeServer-daemon.sh ~/.local/bin/snake-d


runDaemon.commands = snake-d daemon

unix:!android:release.depends += installSnake
unix:!android:release.depends += createLinks


QMAKE_EXTRA_TARGETS += \
    installSnake \
    createLinks \
    runDaemon \
    deploy_dep \
    install_dep \
    deploy \
    create_repo \
    release \
