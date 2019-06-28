include(InstallerBase.pri);
mkpath( $$PWD/../Distro)
win32:OUT_FILE = CQtDeployerInstaller.exe
unix:OUT_FILE = CQtDeployerInstaller.run

DEPLOY_TARGET = $$PWD/../CQtDeployer/build/release

BASE_DEPLOY_FLAGS = clear -qmake $$QMAKE_BIN -libDir $$PWD/../ -recursiveDepth 4
BASE_DEPLOY_FLAGS_SNAKE = $$BASE_DEPLOY_FLAGS -targetDir $$PWD/packages/cqtdeployer/data

deploy_dep.commands += $$DEPLOYER -bin $$DEPLOY_TARGET $$BASE_DEPLOY_FLAGS_SNAKE

mkpath( $$PWD/../Distro)

win32:CONFIG_FILE = $$PWD/config/configWin.xml
unix:CONFIG_FILE = $$PWD/config/configLinux.xml

deploy.commands = $$EXEC \
                       --offline-only \
                       -c $$CONFIG_FILE \
                       -p $$PWD/packages \
                       $$PWD/../Distro/$$OUT_FILE

deploy.depends = deploy_dep

win32:ONLINE_REPO_DIR = $$ONLINE/CQtDeployer/Windows
unix:ONLINE_REPO_DIR = $$ONLINE/CQtDeployer/Linux

create_repo.commands = $$REPOGEN \
                        --update-new-components \
                        -p $$PWD/packages \
                        $$ONLINE_REPO_DIR

chmodSnap.commands = chmod 777 -R $$PWD/packages/cqtdeployer/data
unix:release.depends += chmodSnap


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

releaseSnap.commands = rm *.snap -rdf && chmod 777 -R $$PWD/../prime && snapcraft && snapcraft push *.snap # bad patern
buildSnap.commands = snapcraft
clearSnap.commands = rm parts prime stage *.snap -rdf

unix:release.depends += clearSnap
unix:release.depends += buildSnap
unix:release.depends += releaseSnap

OTHER_FILES += \
    $$PWD/config/*.* \
    $$PWD/packages/cqtdeployer/meta/* \


QMAKE_EXTRA_TARGETS += \
    deploy_dep \
    deploy \
    create_repo \
    release \
    clearSnap \
    releaseSnap \
    buildSnap \
    chmodSnap
