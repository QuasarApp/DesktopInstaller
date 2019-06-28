function Controller()
{
    generateTr();

    installer.uninstallationFinished.connect(this, Controller.prototype.uninstallationFinished);
    installer.installationFinished.connect(this, Controller.prototype.installationFinished);
}

function generateTr() {
    console.log("generate tr start ")

}

Controller.prototype.uninstallationFinished = function()
{
}


Controller.prototype.installationFinished = function()
{
}
