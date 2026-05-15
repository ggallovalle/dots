import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property var popupWindow: null

    function resolvedCommandPath() {
        var configured = pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.commandPath : "";
        if (configured && configured.trim().length > 0)
            return configured.trim();

        var defaults = pluginApi && pluginApi.manifest && pluginApi.manifest.metadata ? pluginApi.manifest.metadata.defaultSettings : null;
        if (defaults && defaults.commandPath)
            return defaults.commandPath;

        return "/home/kbroom/ghq/github.com/ggallovalle/kbzsh.jelly/apps/cli/src/main.ts";
    }

    function closePopup() {
        if (popupWindow !== null) {
            popupWindow.destroy();
            popupWindow = null;
        }
    }

    function startDownload(url) {
        ToastService.showNotice("Fetching media...");

        var component = Qt.createComponent("JobRunner.qml");
        if (component.status !== Component.Ready) {
            ToastService.showError("Media fetch failed: unable to start job runner");
            Logger.e("KBMediaGet", "Failed to load JobRunner component", component.errorString());
            return;
        }

        var runner = component.createObject(root, {
            url: url,
            commandPath: resolvedCommandPath()
        });

        if (runner === null) {
            ToastService.showError("Media fetch failed: unable to start job");
            Logger.e("KBMediaGet", "Failed to create JobRunner instance", component.errorString());
        }
    }

    function openPopup() {
        if (popupWindow !== null) {
            popupWindow.visible = true;
            return;
        }

        var component = Qt.createComponent("PopupWindow.qml");
        if (component.status !== Component.Ready) {
            ToastService.showError("Failed to open media popup");
            Logger.e("KBMediaGet", "Failed to load popup component", component.errorString());
            return;
        }

        popupWindow = component.createObject(root);
        if (popupWindow === null) {
            ToastService.showError("Failed to open media popup");
            Logger.e("KBMediaGet", "Failed to create popup instance", component.errorString());
            return;
        }

        popupWindow.submitUrl.connect(function(url) {
            closePopup();
            startDownload(url);
        });

        popupWindow.visibleChanged.connect(function() {
            if (!popupWindow || popupWindow.visible)
                return;
            closePopup();
        });
    }

    function togglePopup() {
        if (popupWindow !== null) {
            closePopup();
        } else {
            openPopup();
        }
    }

    IpcHandler {
        target: "plugin:kb-media-get"

        function toggle() {
            root.togglePopup();
        }

        function setCommandPath(path: string) {
            if (!pluginApi)
                return;

            var cleaned = path ? path.trim() : "";
            if (!cleaned) {
                ToastService.showError("Command path cannot be empty");
                return;
            }

            pluginApi.pluginSettings.commandPath = cleaned;
            pluginApi.saveSettings();
            ToastService.showNotice("KB media command path updated");
        }

        function showCommandPath() {
            ToastService.showNotice("KB media command path: " + root.resolvedCommandPath());
        }
    }
}
