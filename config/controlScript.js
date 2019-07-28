function Controller()
{
    generateTr();

    installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
    installer.uninstallationFinished.connect(this, Controller.prototype.uninstallationFinished);
    installer.installationFinished.connect(this, Controller.prototype.installationFinished);
}

function generateTr() {
    console.log("generate tr start ")

    installer.setValue("Name", qsTr("Snake"));
    installer.setValue("Title", qsTr("Install Snake"));
}

function runProgramm() {
    if (systemInfo.kernelType === "winnt") {
        installer.setValue("RunProgram", "@TargetDir@/Snake.exe")
    } else {
        installer.setValue("RunProgram", "@TargetDir@/Snake.sh")
    }
}

Controller.prototype.uninstallationFinished = function()
{

}


Controller.prototype.installationFinished = function()
{
    runProgramm();
}
