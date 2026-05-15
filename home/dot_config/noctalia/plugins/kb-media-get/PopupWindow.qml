import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons

PanelWindow {
    id: popup

    signal submitUrl(string url)

    implicitWidth: Screen.width > 0 ? Screen.width : 1920
    implicitHeight: Screen.height > 0 ? Screen.height : 1080

    color: "transparent"
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    MouseArea {
        anchors.fill: parent
        onClicked: popup.visible = false
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 560 * Style.uiScaleRatio
        height: 170 * Style.uiScaleRatio
        z: 1
        radius: Style.radiusL
        color: Qt.alpha(Color.mSurface, 0.96)
        border.color: errorText.visible ? Color.mError : Color.mOutline
        border.width: Style.borderS

        MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) {
                mouse.accepted = true;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginS

            Text {
                text: "Media Get"
                color: Color.mOnSurface
                font.pointSize: Style.fontSizeL
                font.weight: Font.DemiBold
            }

            TextField {
                id: urlInput
                Layout.fillWidth: true
                placeholderText: "Paste URL"
                selectByMouse: true

                onAccepted: popup.trySubmit()
            }

            Text {
                id: errorText
                visible: text.length > 0
                text: ""
                color: Color.mError
                font.pointSize: Style.fontSizeS
            }

            Text {
                text: "Enter: download  •  Esc: cancel"
                color: Color.mOnSurfaceVariant
                font.pointSize: Style.fontSizeS
            }
        }
    }

    function trySubmit() {
        var raw = urlInput.text ? urlInput.text.trim() : "";

        if (!raw) {
            errorText.text = "URL required";
            return;
        }

        var parts = raw.split(/\s+/).filter(function(part) { return part.length > 0; });
        if (parts.length !== 1) {
            errorText.text = "Please paste a single URL";
            return;
        }

        var value = parts[0];
        if (!/^https?:\/\//i.test(value)) {
            errorText.text = "URL must start with http:// or https://";
            return;
        }

        errorText.text = "";
        submitUrl(value);
    }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.visible = false
    }

    Shortcut {
        sequence: "Ctrl+C"
        onActivated: popup.visible = false
    }

    Component.onCompleted: {
        urlInput.forceActiveFocus();
    }
}
